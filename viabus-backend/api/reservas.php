<?php

// Configuración de base de datos y funciones auxiliares.
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

// Configura CORS y gestiona solicitudes preflight.
setCorsHeaders();
handlePreflight();

// Obtiene la conexión y el método HTTP utilizado.
$pdo    = getConnection();
$method = $_SERVER['REQUEST_METHOD'];

// Cantidad mínima de horas antes de la salida para poder cancelar.
const PLAZO_CANCELACION_HORAS = 3;


// GET  /api/reservas.php                        -> consulta reservas.
// GET  /api/reservas.php?id=3                   -> busca una reserva por ID.
// GET  /api/reservas.php?usuario_id=5           -> obtiene las reservas de un usuario.
// GET  /api/reservas.php?servicio_id=5&fecha=... -> obtiene los asientos ocupados.
// POST /api/reservas.php                        -> crea una reserva.
// PUT  /api/reservas.php?id=3                   -> cambia el estado.
// DELETE /api/reservas.php?id=3                 -> cancela una reserva.


/**
 * Consulta reservas mediante GET.
 */
if ($method === 'GET') {

    // Busca una reserva específica mediante su ID.
    if (isset($_GET['id'])) {
        $stmt = $pdo->prepare("
            SELECT r.id, r.fecha_viaje, r.asiento, r.estado, r.estado_pago, r.total, r.created_at,
                   s.hora, s.tipo,
                   c_o.nombre AS origen, c_d.nombre AS destino,
                   e.nombre   AS empresa,
                   p.nombre   AS pasajero_nombre, p.apellido AS pasajero_apellido,
                   p.documento, p.email, p.telefono
            FROM reservas r
            JOIN servicios s ON r.servicio_id = s.id
            JOIN ciudades c_o ON s.origen_id  = c_o.id
            JOIN ciudades c_d ON s.destino_id = c_d.id
            JOIN empresas e   ON s.empresa_id = e.id
            JOIN pasajeros p  ON r.pasajero_id = p.id
            WHERE r.id = ?
        ");
        $stmt->execute([(int)$_GET['id']]);
        $row = $stmt->fetch();

        // Si la reserva no existe, devuelve un error 404.
        if (!$row) sendError('Reserva no encontrada', 404);

        sendResponse($row);
    }

    // Obtiene todas las reservas pertenecientes a un usuario.
    if (isset($_GET['usuario_id'])) {
        $stmt = $pdo->prepare("
            SELECT r.id, r.fecha_viaje, r.asiento, r.estado, r.estado_pago, r.total, r.created_at,
                   s.id AS servicio_id, s.hora, s.tipo, s.anden, s.bus,
                   c_o.nombre AS origen, c_d.nombre AS destino,
                   e.nombre   AS empresa,
                   (p.nombre || ' ' || p.apellido) AS pasajero
            FROM reservas r
            JOIN servicios s ON r.servicio_id = s.id
            JOIN ciudades c_o ON s.origen_id  = c_o.id
            JOIN ciudades c_d ON s.destino_id = c_d.id
            JOIN empresas e   ON s.empresa_id = e.id
            JOIN pasajeros p  ON r.pasajero_id = p.id
            WHERE r.usuario_id = ?
            ORDER BY r.fecha_viaje DESC, s.hora DESC
        ");
        $stmt->execute([(int)$_GET['usuario_id']]);
        sendResponse($stmt->fetchAll());
    }

    // Obtiene los asientos ocupados para un servicio y fecha determinada.
    if (isset($_GET['servicio_id'], $_GET['fecha'])) {
        $stmt = $pdo->prepare("
            SELECT asiento FROM reservas
            WHERE servicio_id = ? AND fecha_viaje = ? AND estado != 'cancelada'
        ");
        $stmt->execute([(int)$_GET['servicio_id'], $_GET['fecha']]);

        // Convierte los números de asiento en un array de enteros.
        $ocupados = array_map('intval', array_column($stmt->fetchAll(), 'asiento'));

        sendResponse(['asientos_ocupados' => $ocupados]);
    }

    // Si no se especifica ningún filtro, devuelve todas las reservas.
    $stmt = $pdo->query("
        SELECT r.id, r.fecha_viaje, r.asiento, r.estado, r.total,
               s.hora,
               c_o.nombre AS origen, c_d.nombre AS destino,
               e.nombre   AS empresa,
               (p.nombre || ' ' || p.apellido) AS pasajero
        FROM reservas r
        JOIN servicios s ON r.servicio_id = s.id
        JOIN ciudades c_o ON s.origen_id  = c_o.id
        JOIN ciudades c_d ON s.destino_id = c_d.id
        JOIN empresas e   ON s.empresa_id = e.id
        JOIN pasajeros p  ON r.pasajero_id = p.id
        ORDER BY r.created_at DESC
    ");
    sendResponse($stmt->fetchAll());
}


/**
 * Crea una nueva reserva mediante POST (correo).
 */
if ($method === 'POST') {
    $body = getRequestBody();
    $required = ['servicio_id','fecha_viaje','asiento','pasajero'];

    // Comprueba que los datos principales de la reserva estén completos.
    foreach ($required as $f) {
        if (empty($body[$f]) && $body[$f] !== 0) {
            sendError("El campo '$f' es obligatorio");
        }
    }

    $p = $body['pasajero'];

    // Comprueba los datos obligatorios del pasajero.
    foreach (['nombre','apellido','documento'] as $f) {
        if (empty($p[$f])) sendError("El campo pasajero.$f es obligatorio");
    }

    // Comprueba que el servicio exista.
    $stmtS = $pdo->prepare("SELECT id, precio FROM servicios WHERE id = ?");
    $stmtS->execute([(int)$body['servicio_id']]);
    $servicio = $stmtS->fetch();

    if (!$servicio) sendError('Servicio no encontrado', 404);


    // Busca un pasajero existente utilizando su documento.
    $stmtP = $pdo->prepare("SELECT id FROM pasajeros WHERE documento = ?");
    $stmtP->execute([$p['documento']]);
    $pasajeroId = $stmtP->fetchColumn();

    // Si no existe, crea el pasajero.
    if (!$pasajeroId) {
        $pdo->prepare("
            INSERT INTO pasajeros (nombre,apellido,documento,email,telefono)
            VALUES (?,?,?,?,?)
        ")->execute([
            $p['nombre'],
            $p['apellido'],
            $p['documento'],
            $p['email'] ?? null,
            $p['telefono'] ?? null
        ]);

        $pasajeroId = $pdo->lastInsertId();
    }


    // Comprueba que el asiento seleccionado no esté ocupado.
    $stmtA = $pdo->prepare("
        SELECT id FROM reservas
        WHERE servicio_id=? AND fecha_viaje=? AND asiento=? AND estado!='cancelada'
    ");
    $stmtA->execute([
        (int)$body['servicio_id'],
        $body['fecha_viaje'],
        (int)$body['asiento']
    ]);

    if ($stmtA->fetch()) sendError('El asiento ya está ocupado para esa fecha');


    // Utiliza el total enviado o, si no existe, el precio del servicio.
    $total     = $body['total'] ?? $servicio['precio'];
    $usuarioId = !empty($body['usuario_id']) ? (int)$body['usuario_id'] : null;

    // Crea la reserva con estado inicial "pendiente".
    $pdo->prepare("
        INSERT INTO reservas (servicio_id,pasajero_id,usuario_id,fecha_viaje,asiento,estado,total)
        VALUES (?,?,?,?,?,'pendiente',?)
    ")->execute([
        (int)$body['servicio_id'],
        $pasajeroId,
        $usuarioId,
        $body['fecha_viaje'],
        (int)$body['asiento'],
        $total,
    ]);

    // Devuelve el ID y el total de la reserva creada.
    sendResponse([
        'id' => $pdo->lastInsertId(),
        'message' => 'Reserva creada',
        'total' => $total
    ], 201);
}


/**
 * Cambia el estado de una reserva mediante PUT.
 */
if ($method === 'PUT') {

    // Comprueba que se haya enviado el ID de la reserva.
    if (empty($_GET['id'])) sendError('ID requerido');

    $body   = getRequestBody();
    $id     = (int)$_GET['id'];
    $estado = $body['estado'] ?? null;

    // Solo permite los estados definidos para las reservas.
    if (!in_array($estado, ['pendiente','confirmada','cancelada'])) {
        sendError('Estado inválido. Use: pendiente | confirmada | cancelada');
    }

    // Actualiza el estado de la reserva.
    $pdo->prepare("UPDATE reservas SET estado=? WHERE id=?")->execute([$estado, $id]);

    sendResponse(['message' => 'Estado actualizado']);
}


/**
 * Cancela una reserva mediante DELETE.
 */
if ($method === 'DELETE') {

    // Comprueba que se haya enviado el ID.
    if (empty($_GET['id'])) sendError('ID requerido');

    $id = (int)$_GET['id'];

    // Obtiene la fecha y hora de salida de la reserva.
    $stmt = $pdo->prepare("
        SELECT r.estado, r.fecha_viaje, s.hora
        FROM reservas r
        JOIN servicios s ON r.servicio_id = s.id
        WHERE r.id = ?
    ");
    $stmt->execute([$id]);
    $reserva = $stmt->fetch();

    // Comprueba que la reserva exista.
    if (!$reserva) sendError('Reserva no encontrada', 404);

    // Evita cancelar una reserva que ya fue cancelada.
    if ($reserva['estado'] === 'cancelada') {
        sendError('Esta reserva ya estaba cancelada');
    }


    // Calcula cuántas horas faltan para la salida.
    $salida         = new DateTime($reserva['fecha_viaje'] . ' ' . $reserva['hora']);
    $horasRestantes = (strtotime($salida->format('Y-m-d H:i:s')) - time()) / 3600;

    // Impide cancelar si faltan menos de 3 horas para la salida.
    if ($horasRestantes < PLAZO_CANCELACION_HORAS) {
        sendError(
            'Ya no se puede cancelar: faltan menos de ' . PLAZO_CANCELACION_HORAS . ' horas para la salida',
            409
        );
    }

    // Marca la reserva como cancelada.
    $pdo->prepare("UPDATE reservas SET estado='cancelada' WHERE id=?")->execute([$id]);

    sendResponse(['message' => 'Reserva cancelada']);
}


// Rechaza cualquier método HTTP que no esté soportado.
sendError('Método no soportado', 405);
