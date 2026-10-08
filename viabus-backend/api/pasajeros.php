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


// GET  /api/pasajeros.php?documento=12345678 -> busca por documento.
// GET  /api/pasajeros.php?id=3              -> busca por ID.
// POST /api/pasajeros.php                   -> crea un pasajero.
// PUT  /api/pasajeros.php?id=3              -> actualiza un pasajero.


/**
 * Consulta pasajeros mediante GET.
 */
if ($method === 'GET') {

    // Busca un pasajero utilizando su documento.
    if (isset($_GET['documento'])) {
        $stmt = $pdo->prepare("SELECT * FROM pasajeros WHERE documento = ?");
        $stmt->execute([$_GET['documento']]);
        $row = $stmt->fetch();

        // Si no existe, devuelve un error 404.
        if (!$row) sendError('Pasajero no encontrado', 404);

        sendResponse($row);
    }

    // Busca un pasajero utilizando su ID.
    if (isset($_GET['id'])) {
        $stmt = $pdo->prepare("SELECT * FROM pasajeros WHERE id = ?");
        $stmt->execute([(int)$_GET['id']]);
        $row = $stmt->fetch();

        // Si no existe, devuelve un error 404.
        if (!$row) sendError('Pasajero no encontrado', 404);

        sendResponse($row);
    }

    // Si no se especifica documento ni ID, devuelve todos los pasajeros.
    $stmt = $pdo->query("SELECT * FROM pasajeros ORDER BY apellido, nombre");
    sendResponse($stmt->fetchAll());
}


/**
 * Crea un nuevo pasajero mediante POST.
 */
if ($method === 'POST') {
    $body = getRequestBody();

    // Comprueba que los campos obligatorios estén completos.
    foreach (['nombre','apellido','documento'] as $f) {
        if (empty($body[$f])) sendError("El campo '$f' es obligatorio");
    }

    try {

        // Guarda el nuevo pasajero en la base de datos.
        $pdo->prepare("
            INSERT INTO pasajeros (nombre,apellido,documento,email,telefono)
            VALUES (?,?,?,?,?)
        ")->execute([
            $body['nombre'],
            $body['apellido'],
            $body['documento'],
            $body['email'] ?? null,
            $body['telefono'] ?? null
        ]);

        // Devuelve el ID del pasajero creado.
        sendResponse([
            'id' => $pdo->lastInsertId(),
            'message' => 'Pasajero creado'
        ], 201);

    } catch (\PDOException $e) {

        // Controla el caso en que el documento ya esté registrado.
        if ($e->getCode() === '23000') sendError('El documento ya está registrado');

        throw $e;
    }
}


/**
 * Actualiza los datos de un pasajero mediante PUT.
 */
if ($method === 'PUT') {

    // Comprueba que se haya enviado el ID del pasajero.
    if (empty($_GET['id'])) sendError('ID requerido');

    $body   = getRequestBody();
    $id     = (int)$_GET['id'];
    $fields = [];
    $values = [];

    // Agrega únicamente los campos enviados para actualizar.
    foreach (['nombre','apellido','email','telefono'] as $f) {
        if (array_key_exists($f, $body)) {
            $fields[] = "$f = ?";
            $values[] = $body[$f];
        }
    }

    // Comprueba que haya al menos un campo para actualizar.
    if (empty($fields)) sendError('Sin campos para actualizar');

    // Agrega el ID y ejecuta la actualización.
    $values[] = $id;
    $pdo->prepare("UPDATE pasajeros SET " . implode(', ', $fields) . " WHERE id = ?")->execute($values);

    // Confirma que el pasajero fue actualizado.
    sendResponse(['message' => 'Pasajero actualizado']);
}


// Rechaza cualquier método HTTP que no esté soportado.
sendError('Método no soportado', 405);
