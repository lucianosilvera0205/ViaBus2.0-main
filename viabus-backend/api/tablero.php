<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

// Configuración de CORS y solicitudes preflight.
setCorsHeaders();
handlePreflight();

// Obtiene la conexión y el método HTTP utilizado.
$pdo    = getConnection();
$method = $_SERVER['REQUEST_METHOD'];

// Cantidad de andenes físicos disponibles en la terminal.
const TOTAL_ANDENES = 7;
const VENTANA_EMBARQUE_MIN = 15; // Servicios que salen dentro de estos minutos.

// GET /api/tablero.php
// Obtiene los servicios de hoy que salen desde Melo.
// Los separa entre próximos a salir y servicios que ya partieron.
//
// PUT /api/tablero.php?servicio_id=5
// Marca o quita la demora manual de un servicio para el día actual.

if ($method === 'GET') {
    $hoy   = date('Y-m-d');
    $ahora = date('H:i');

    // Obtiene los servicios activos que salen desde Melo.
    // También consulta si tienen una demora registrada para hoy.
    $stmt = $pdo->prepare("
        SELECT s.id, c_d.nombre AS destino, e.nombre AS empresa, e.logo AS empresa_logo,
               s.hora, s.tipo, s.bus,
               COALESCE(ed.demorado, 0) AS demorado
        FROM servicios s
        JOIN ciudades c_d ON s.destino_id = c_d.id
        JOIN ciudades c_o ON s.origen_id  = c_o.id
        JOIN empresas e   ON s.empresa_id = e.id
        LEFT JOIN estado_diario ed ON ed.servicio_id = s.id AND ed.fecha = ?
        WHERE c_o.nombre = 'Melo' AND s.activo = 1
        ORDER BY s.hora
    ");
    $stmt->execute([$hoy]);
    $todos = $stmt->fetchAll();

    // Convierte una hora (HH:MM) a minutos desde medianoche.
    // Esto permite calcular cuánto falta para cada servicio.
    $toMinutos = fn(string $hhmm) => ((int)substr($hhmm, 0, 2)) * 60 + (int)substr($hhmm, 3, 2);
    $minAhora  = $toMinutos($ahora);

    $proximos = [];
    $salidos  = [];

    // Clasifica los servicios según su hora de salida.
    foreach ($todos as $row) {
        $minServicio = $toMinutos($row['hora']);
        $faltan      = $minServicio - $minAhora;

        // Si la hora ya pasó, el servicio se considera que partió.
        if ($faltan < 0) {
            $row['estado'] = 'partio';
            $row['anden']  = null;
            $salidos[] = $row;
            continue;
        }

        // Determina el estado actual del servicio.
        if ((int)$row['demorado'] === 1) {
            $row['estado'] = 'demorado';
        } elseif ($faltan <= VENTANA_EMBARQUE_MIN) {
            $row['estado'] = 'embarcando';
        } else {
            $row['estado'] = 'horario';
        }

        $row['minutos_restantes'] = $faltan;
        $row['demorado'] = (bool)(int)$row['demorado'];
        $proximos[] = $row;
    }

    // Selecciona los servicios que están dentro de la ventana de embarque.
    $enVentana = array_values(array_filter(
        $proximos,
        fn($r) => $r['minutos_restantes'] <= VENTANA_EMBARQUE_MIN
    ));

    // Asigna los andenes disponibles de forma rotativa.
    $andenPorServicio = [];
    foreach ($enVentana as $i => $r) {
        $andenPorServicio[$r['id']] = 'A-0' . (($i % TOTAL_ANDENES) + 1);
    }

    // Agrega el andén correspondiente a cada servicio.
    // Los que todavía no están en la ventana quedan sin andén.
    foreach ($proximos as &$r) {
        $r['anden'] = $andenPorServicio[$r['id']] ?? null;
    }
    unset($r);

    // Ordena los servicios que ya partieron, mostrando primero los más recientes.
    usort($salidos, fn($a, $b) => $toMinutos($b['hora']) <=> $toMinutos($a['hora']));

    // Devuelve la información del tablero.
    sendResponse([
        'fecha'           => $hoy,
        'hora_actual'     => $ahora,
        'andenes_activos' => count($enVentana),
        'andenes_totales' => TOTAL_ANDENES,
        'proximos'        => $proximos,
        'salidos'         => $salidos,
    ]);
}

if ($method === 'PUT') {
    // Verifica que se haya indicado el servicio a modificar.
    if (empty($_GET['servicio_id'])) sendError('servicio_id requerido');

    // Obtiene los datos enviados en el cuerpo de la solicitud.
    $body = getRequestBody();

    // El campo demorado es obligatorio para modificar el estado.
    if (!array_key_exists('demorado', $body)) sendError('El campo "demorado" es obligatorio');

    $servicioId = (int)$_GET['servicio_id'];
    $demorado   = $body['demorado'] ? 1 : 0;
    $hoy        = date('Y-m-d');

    // Comprueba que el servicio exista.
    $stmtCheck = $pdo->prepare("SELECT id FROM servicios WHERE id = ?");
    $stmtCheck->execute([$servicioId]);

    if (!$stmtCheck->fetch()) sendError('Servicio no encontrado', 404);

    // Registra o actualiza la demora del servicio para el día actual.
    $pdo->prepare("
        INSERT INTO estado_diario (servicio_id, fecha, demorado)
        VALUES (?, ?, ?)
        ON CONFLICT(servicio_id, fecha) DO UPDATE SET
            demorado = excluded.demorado,
            updated_at = CURRENT_TIMESTAMP
    ")->execute([$servicioId, $hoy, $demorado]);

    // Informa si la demora fue activada o quitada.
    sendResponse([
        'message' => $demorado
            ? 'Servicio marcado como demorado'
            : 'Demora quitada'
    ]);
}

// Rechaza cualquier método HTTP que no esté implementado.
sendError('Método no soportado', 405);

