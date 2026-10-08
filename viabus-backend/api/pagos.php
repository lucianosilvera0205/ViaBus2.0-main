<?php

// Configuración de base de datos, funciones auxiliares y Mercado Pago.
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';
require_once __DIR__ . '/../config/mercadopago.php';

// Configura CORS y gestiona solicitudes preflight.
setCorsHeaders();
handlePreflight();

// Obtiene la conexión, el método HTTP y la acción solicitada.
$pdo    = getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? null;


// Acciones disponibles:
// POST ?action=crear-preferencia -> crea un pago en Mercado Pago.
// GET  ?action=estado            -> consulta el estado de un pago.
// POST ?action=webhook            -> recibe actualizaciones de Mercado Pago.

if ($method === 'POST' && $action === 'crear-preferencia') {
    crearPreferencia($pdo);
}

if ($method === 'GET' && $action === 'estado') {
    consultarEstado($pdo);
}

if ($method === 'POST' && $action === 'webhook') {
    procesarWebhook($pdo);
}

// Si la acción no coincide con ninguna de las anteriores, devuelve un error.
sendError('Acción no soportada. Use action=crear-preferencia | estado | webhook', 404);


// --------------------------------------------------------------------

/**
 * Crea una preferencia de pago para una reserva en Mercado Pago.
 */
function crearPreferencia(PDO $pdo): void {
    $body = getRequestBody();

    // Comprueba que se haya enviado el ID de la reserva.
    if (empty($body['reserva_id'])) sendError('El campo reserva_id es obligatorio');

    $reservaId = (int)$body['reserva_id'];

    // Obtiene la información de la reserva y del viaje.
    $stmt = $pdo->prepare("
        SELECT r.id, r.total, r.estado_pago,
               c_o.nombre AS origen, c_d.nombre AS destino
        FROM reservas r
        JOIN servicios s  ON r.servicio_id = s.id
        JOIN ciudades c_o ON s.origen_id  = c_o.id
        JOIN ciudades c_d ON s.destino_id = c_d.id
        WHERE r.id = ?
    ");
    $stmt->execute([$reservaId]);
    $reserva = $stmt->fetch();

    // Comprueba que la reserva exista y que todavía no esté pagada.
    if (!$reserva) sendError('Reserva no encontrada', 404);
    if ($reserva['estado_pago'] === 'pagado') sendError('Esta reserva ya fue pagada');

    try {
        // Crea la preferencia de pago en Mercado Pago.
        $preferencia = mpRequest('POST', '/checkout/preferences', [
            'items' => [[
                'title'       => "Pasaje {$reserva['origen']} → {$reserva['destino']} (Reserva #{$reservaId})",
                'quantity'    => 1,
                'currency_id' => 'UYU',
                'unit_price'  => (float)$reserva['total'],
            ]],
            'external_reference' => (string)$reservaId,
            'back_urls' => [
                'success' => MP_FRONTEND_URL . "/comprar?reserva_id={$reservaId}",
                'failure' => MP_FRONTEND_URL . "/comprar?reserva_id={$reservaId}",
                'pending' => MP_FRONTEND_URL . "/comprar?reserva_id={$reservaId}",
            ],
            'auto_return'      => 'approved',
            'notification_url' => MP_WEBHOOK_URL,
        ]);
    } catch (Exception $e) {
        // Devuelve un error si no se pudo crear el pago.
        sendError('No se pudo crear la preferencia de pago: ' . $e->getMessage(), 502);
    }

    // Guarda o actualiza el pago asociado a la reserva.
    $pdo->prepare("
        INSERT INTO pagos (reserva_id, mercadopago_preference_id, estado, monto)
        VALUES (?, ?, 'pendiente', ?)
        ON CONFLICT(reserva_id) DO UPDATE SET
            mercadopago_preference_id = excluded.mercadopago_preference_id,
            estado     = 'pendiente',
            monto      = excluded.monto,
            updated_at = CURRENT_TIMESTAMP
    ")->execute([$reservaId, $preferencia['id'], $reserva['total']]);

    // Devuelve los datos necesarios para abrir el checkout.
    sendResponse([
        'preference_id' => $preferencia['id'],
        'init_point'    => $preferencia['init_point'],
    ]);
}


/**
 * Consulta el estado actual del pago de una reserva.
 */
function consultarEstado(PDO $pdo): void {

    // Comprueba que se haya enviado el ID de la reserva.
    if (empty($_GET['reserva_id'])) sendError('reserva_id requerido');

    // Busca el estado del pago y de la reserva.
    $stmt = $pdo->prepare("
        SELECT p.estado, p.monto, p.mercadopago_payment_id,
               r.estado AS estado_reserva
        FROM pagos p
        JOIN reservas r ON r.id = p.reserva_id
        WHERE p.reserva_id = ?
    ");
    $stmt->execute([(int)$_GET['reserva_id']]);
    $pago = $stmt->fetch();

    // Si no existe un pago para la reserva, devuelve un error.
    if (!$pago) sendError('No hay un pago registrado para esa reserva', 404);

    // Devuelve la información del pago.
    sendResponse($pago);
}


/**
 * Procesa las notificaciones enviadas por Mercado Pago.
 */
function procesarWebhook(PDO $pdo): void {

    // Obtiene los datos enviados por Mercado Pago.
    $body      = getRequestBody();
    $tipo      = $_GET['type'] ?? $_GET['topic'] ?? $body['type'] ?? null;
    $paymentId = $_GET['data_id'] ?? $_GET['id'] ?? ($body['data']['id'] ?? null);

    // Ignora las notificaciones que no correspondan a pagos.
    if ($tipo !== 'payment' || !$paymentId) {
        sendResponse(['message' => 'Notificación ignorada (no es de tipo payment)']);
    }

    try {
        // Consulta directamente a Mercado Pago para verificar el pago.
        $pago = mpRequest('GET', "/v1/payments/{$paymentId}");
    } catch (Exception $e) {

        // Registra el error si no se pudo consultar el pago.
        error_log('Error al consultar pago de Mercado Pago: ' . $e->getMessage());
        sendResponse(['message' => 'No se pudo verificar el pago en este intento']);
    }

    // Obtiene la reserva relacionada con el pago.
    $reservaId = (int)($pago['external_reference'] ?? 0);

    // Ignora pagos que no estén relacionados con una reserva.
    if (!$reservaId) {
        sendResponse(['message' => 'Pago sin external_reference, ignorado']);
    }

    // Convierte el estado de Mercado Pago al estado utilizado por el sistema.
    $estado = match ($pago['status']) {
        'approved'  => 'pagado',
        'rejected'  => 'rechazado',
        'cancelled' => 'cancelado',
        default     => 'pendiente',
    };

    // Actualiza la información del pago en la base de datos.
    $pdo->prepare("
        UPDATE pagos SET
            mercadopago_payment_id = ?,
            estado       = ?,
            respuesta_mp = ?,
            updated_at   = CURRENT_TIMESTAMP
        WHERE reserva_id = ?
    ")->execute([$paymentId, $estado, json_encode($pago), $reservaId]);

    // Actualiza el estado de pago de la reserva.
    $pdo->prepare("UPDATE reservas SET estado_pago = ? WHERE id = ?")
        ->execute([$estado, $reservaId]);

    // Si el pago fue aprobado, confirma automáticamente la reserva.
    if ($estado === 'pagado') {
        $pdo->prepare("UPDATE reservas SET estado = 'confirmada' WHERE id = ?")
            ->execute([$reservaId]);
    }

    // Confirma que el pago fue procesado correctamente.
    sendResponse(['message' => 'Pago actualizado', 'estado' => $estado]);
}

