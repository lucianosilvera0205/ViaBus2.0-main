<?php

// Configuración de base de datos y funciones auxiliares.
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

// Configura CORS y gestiona solicitudes preflight.
setCorsHeaders();
handlePreflight();

// Obtiene la conexión y el método HTTP utilizado.
$pdo = getConnection();
$method = $_SERVER['REQUEST_METHOD'];


// GET /api/servicios.php              -> obtiene todos los servicios activos.
// GET /api/servicios.php?id=5         -> busca un servicio por ID.
// GET /api/servicios.php?origen=Melo&destino=Montevideo -> busca por origen y destino.
// POST /api/servicios.php             -> crea un servicio.
// PUT /api/servicios.php?id=5         -> modifica un servicio.
// DELETE /api/servicios.php?id=5      -> desactiva un servicio.


/**
 * Consulta los servicios disponibles mediante GET.
 */
if ($method === 'GET') {

    // Busca un servicio específico mediante su ID.
    if (isset($_GET['id'])) {
        $stmt = $pdo->prepare("
            SELECT s.id, c_o.nombre AS origen, c_d.nombre AS destino,
                   e.nombre AS empresa, e.logo AS empresa_logo, s.hora, s.tipo,
                   s.duracion, s.precio, s.asientos, s.anden, s.bus, s.estado, s.activo
            FROM servicios s
            JOIN ciudades c_o ON s.origen_id  = c_o.id
            JOIN ciudades c_d ON s.destino_id = c_d.id
            JOIN empresas e   ON s.empresa_id = e.id
            WHERE s.id = ?
        ");
        $stmt->execute([(int)$_GET['id']]);
        $row = $stmt->fetch();

        // Si el servicio no existe, devuelve un error 404.
        if (!$row) sendError('Servicio no encontrado', 404);

        sendResponse($row);
    }

    // Busca servicios activos según la ciudad de origen y destino.
    if (isset($_GET['origen']) && isset($_GET['destino'])) {
        $stmt = $pdo->prepare("
            SELECT s.id, c_o.nombre AS origen, c_d.nombre AS destino,
                   e.nombre AS empresa, e.logo AS empresa_logo, s.hora,
                   s.tipo, s.duracion, s.precio, s.asientos, s.anden, s.bus, s.estado
            FROM servicios s
            JOIN ciudades c_o ON s.origen_id  = c_o.id
            JOIN ciudades c_d ON s.destino_id = c_d.id
            JOIN empresas e   ON s.empresa_id = e.id
            WHERE c_o.nombre = ? AND c_d.nombre = ? AND s.activo = 1
            ORDER BY s.hora
        ");
        $stmt->execute([$_GET['origen'], $_GET['destino']]);
        sendResponse($stmt->fetchAll());
    }

    // Obtiene todos los servicios activos ordenados por ciudad y horario.
    $stmt = $pdo->query("
        SELECT s.id, c_o.nombre AS origen, c_d.nombre AS destino,
               e.nombre AS empresa, e.logo AS empresa_logo, s.hora,
               s.tipo, s.duracion, s.precio, s.asientos, s.anden, s.bus, s.estado, s.activo
        FROM servicios s
        JOIN ciudades c_o ON s.origen_id  = c_o.id
        JOIN ciudades c_d ON s.destino_id = c_d.id
        JOIN empresas e   ON s.empresa_id = e.id
        WHERE s.activo = 1
        ORDER BY c_o.nombre, s.hora
    ");
    sendResponse($stmt->fetchAll());
}


/**
 * Crea un nuevo servicio mediante POST.
 */
if ($method === 'POST') {
    $body = getRequestBody();
    $required = ['origen', 'destino', 'empresa', 'hora', 'tipo'];

    // Comprueba que los datos principales estén completos.
    foreach ($required as $field) {
        if (empty($body[$field])) sendError("El campo '$field' es obligatorio");
    }

    // Busca los IDs correspondientes al origen, destino y empresa.
    $stmtO   = $pdo->prepare("SELECT id FROM ciudades WHERE nombre = ?"); $stmtO->execute([$body['origen']]);
    $stmtD   = $pdo->prepare("SELECT id FROM ciudades WHERE nombre = ?"); $stmtD->execute([$body['destino']]);
    $stmtE   = $pdo->prepare("SELECT id FROM empresas  WHERE nombre = ?"); $stmtE->execute([$body['empresa']]);

    $oid = $stmtO->fetchColumn();
    $did = $stmtD->fetchColumn();
    $eid = $stmtE->fetchColumn();

    // Comprueba que las ciudades y la empresa existan.
    if (!$oid) sendError('Ciudad de origen no encontrada');
    if (!$did) sendError('Ciudad de destino no encontrada');
    if (!$eid) sendError('Empresa no encontrada');


    // Crea el nuevo servicio con los datos recibidos.
    $stmt = $pdo->prepare("
        INSERT INTO servicios (origen_id,destino_id,empresa_id,hora,tipo,duracion,precio,asientos,anden,bus,estado)
        VALUES (?,?,?,?,?,?,?,?,?,?,?)
    ");
    $stmt->execute([
        $oid, $did, $eid,
        $body['hora'],
        $body['tipo'],
        $body['duracion'] ?? null,
        $body['precio']   ?? null,
        $body['asientos'] ?? 40,
        $body['anden']    ?? null,
        $body['bus']      ?? null,
        $body['estado']   ?? 'horario',
    ]);

    // Devuelve el ID del servicio creado.
    sendResponse(['id' => $pdo->lastInsertId(), 'message' => 'Servicio creado'], 201);
}


/**
 * Actualiza un servicio mediante PUT.
 */
if ($method === 'PUT') {

    // Comprueba que se haya enviado el ID.
    if (empty($_GET['id'])) sendError('ID requerido');

    $body = getRequestBody();
    $id   = (int)$_GET['id'];

    $fields = [];
    $values = [];

    // Agrega únicamente los campos enviados para actualizar.
    foreach (['hora','tipo','duracion','precio','asientos','bus'] as $f) {
        if (array_key_exists($f, $body)) {
            $fields[] = "$f = ?";
            $values[] = $body[$f];
        }
    }

    // Comprueba que haya campos para actualizar.
    if (empty($fields)) sendError('Sin campos para actualizar');

    // Ejecuta la actualización del servicio.
    $values[] = $id;
    $pdo->prepare("UPDATE servicios SET " . implode(', ', $fields) . " WHERE id = ?")->execute($values);

    sendResponse(['message' => 'Servicio actualizado']);
}


/**
 * Desactiva un servicio mediante DELETE.
 */
if ($method === 'DELETE') {

    // Comprueba que se haya enviado el ID.
    if (empty($_GET['id'])) sendError('ID requerido');

    // En lugar de eliminarlo, marca el servicio como inactivo.
$pdo->prepare("UPDATE servicios SET activo = 0 WHERE id = ?")->execute([(int)$_GET['id']]);
    sendResponse(['message' => 'Servicio desactivado']);
}


// Rechaza cualquier método HTTP que no esté soportado.
sendError('Método no soportado', 405);


