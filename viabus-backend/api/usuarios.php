<?php
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

// Configuración de CORS y solicitudes preflight.
setCorsHeaders();
handlePreflight();

// Obtiene la conexión a la base de datos y el método HTTP utilizado.
$pdo    = getConnection();
$method = $_SERVER['REQUEST_METHOD'];

// PUT /api/usuarios.php?id=5
// Actualiza el nombre, apellido o correo electrónico de un usuario.
//
// PUT /api/usuarios.php?id=5&action=password
// Permite cambiar la contraseña del usuario.

if ($method === 'PUT') {

    // Verifica que se haya indicado el ID del usuario.
    if (empty($_GET['id'])) sendError('ID requerido');

    $id     = (int)$_GET['id'];
    $body   = getRequestBody();
    $action = $_GET['action'] ?? 'datos';

    // Busca el usuario que se quiere modificar.
    $stmtU = $pdo->prepare("SELECT * FROM usuarios WHERE id = ?");
    $stmtU->execute([$id]);
    $usuario = $stmtU->fetch();

    // Si el usuario no existe, devuelve un error.
    if (!$usuario) sendError('Usuario no encontrado', 404);

    // La acción solicitada es cambiar la contraseña.
    if ($action === 'password') {

        // Verifica que se hayan enviado la contraseña actual y la nueva.
        if (empty($body['actual']) || empty($body['nueva'])) {
            sendError('Ingresá la contraseña actual y la nueva');
        }

        // Comprueba que la contraseña actual sea correcta.
        if (!password_verify($body['actual'], $usuario['password_hash'])) {
            sendError('La contraseña actual es incorrecta', 401);
        }

        // Verifica que la nueva contraseña tenga al menos 6 caracteres.
        if (strlen($body['nueva']) < 6) {
            sendError('La nueva contraseña debe tener al menos 6 caracteres');
        }

        // Genera una versión protegida de la nueva contraseña.
        $hash = password_hash($body['nueva'], PASSWORD_DEFAULT);

        // Guarda la nueva contraseña del usuario.
        $pdo->prepare("UPDATE usuarios SET password_hash = ? WHERE id = ?")->execute([$hash, $id]);

        // Informa que la contraseña fue actualizada correctamente.
        sendResponse(['message' => 'Contraseña actualizada']);
    }

    // Actualizar datos personales.

    // Verifica que nombre, apellido y correo electrónico hayan sido enviados.
    foreach (['nombre', 'apellido', 'email'] as $f) {
        if (empty($body[$f])) sendError("El campo '$f' es obligatorio");
    }

    try {

        // Actualiza los datos personales del usuario.
        $pdo->prepare("
            UPDATE usuarios SET nombre = ?, apellido = ?, email = ? WHERE id = ?
        ")->execute([$body['nombre'], $body['apellido'], $body['email'], $id]);

        // Obtiene nuevamente los datos actualizados del usuario.
        // No devuelve la contraseña por seguridad.
        $stmt = $pdo->prepare("SELECT id, nombre, apellido, email, rol, created_at FROM usuarios WHERE id = ?");
        $stmt->execute([$id]);

        // Devuelve los datos actualizados.
        sendResponse($stmt->fetch());

    } catch (\PDOException $e) {

        // Si el correo ya pertenece a otra cuenta, informa el conflicto.
        if ($e->getCode() === '23000') sendError('Ese correo ya está en uso por otra cuenta');

        // Devuelve cualquier otro error de base de datos.
        throw $e;
    }
}

// Rechaza cualquier método HTTP que no esté implementado.
sendError('Método no soportado', 405);
