<?php

// Configuración de base de datos y funciones auxiliares.
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

// Configura CORS y gestiona solicitudes preflight.
setCorsHeaders();
handlePreflight();

// Obtiene la conexión, el método HTTP y la acción solicitada.
$pdo    = getConnection();
$method = $_SERVER['REQUEST_METHOD'];
$action = $_GET['action'] ?? '';


/**
 * Inicia sesión verificando el correo y la contraseña del usuario.
 *
 * POST /api/auth.php?action=login
 */
if ($method === 'POST' && $action === 'login') {
    $body = getRequestBody();

    // Comprueba que se hayan enviado las credenciales.
    if (empty($body['email']) || empty($body['password'])) {
        sendError('Correo y contraseña son obligatorios');
    }

    // Busca el usuario por su correo.
    $stmt = $pdo->prepare("SELECT * FROM usuarios WHERE email = ?");
    $stmt->execute([$body['email']]);
    $usuario = $stmt->fetch();

    // Verifica que el usuario exista y que la contraseña sea correcta.
    if (!$usuario || !password_verify($body['password'], $usuario['password_hash'])) {
        sendError('Correo o contraseña incorrectos', 401);
    }

    // No devuelve la contraseña al frontend.
    unset($usuario['password_hash']);

    // Devuelve los datos del usuario.
    sendResponse($usuario);
}


/**
 * Registra un nuevo usuario con el rol "cliente".
 *
 * POST /api/auth.php?action=register
 */
if ($method === 'POST' && $action === 'register') {
    $body = getRequestBody();

    // Comprueba que todos los campos obligatorios estén completos.
    foreach (['nombre', 'apellido', 'email', 'password'] as $f) {
        if (empty($body[$f])) sendError("El campo '$f' es obligatorio");
    }

    // Comprueba la longitud mínima de la contraseña.
    if (strlen($body['password']) < 6) {
        sendError('La contraseña debe tener al menos 6 caracteres');
    }

    try {
        // Encripta la contraseña antes de guardarla.
        $hash = password_hash($body['password'], PASSWORD_DEFAULT);

        // Crea el usuario con el rol "cliente".
        $pdo->prepare("
            INSERT INTO usuarios (nombre, apellido, email, password_hash, rol)
            VALUES (?, ?, ?, ?, 'cliente')
        ")->execute([$body['nombre'], $body['apellido'], $body['email'], $hash]);

        // Obtiene el ID del usuario creado.
        $id = $pdo->lastInsertId();

        // Obtiene los datos del nuevo usuario sin su contraseña.
        $stmt = $pdo->prepare("SELECT id, nombre, apellido, email, rol, created_at FROM usuarios WHERE id = ?");
        $stmt->execute([$id]);

        // Devuelve el usuario creado con código HTTP 201.
        sendResponse($stmt->fetch(), 201);

    } catch (\PDOException $e) {

        // Controla el caso en que el correo ya esté registrado.
        if ($e->getCode() === '23000') sendError('Ese correo ya está registrado');

        throw $e;
    }
}

// Devuelve un error si la acción o método no está permitido.
sendError('Método no soportado', 405);
