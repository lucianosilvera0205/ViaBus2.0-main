<?php

// Define el router utilizado por el servidor embebido de PHP (php -S).
// Permite acceder directamente a los archivos de la API.
// Para otras rutas devuelve un error 404 en formato JSON.

$uri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
$file = __DIR__ . $uri;

// Comprueba si la ruta corresponde a un archivo existente.
if ($uri !== '/' && file_exists($file) && !is_dir($file)) {

    // Permite que el servidor integrado de PHP procese el archivo.
    return false;
}

// Define que la respuesta será enviada en formato JSON.
header('Content-Type: application/json; charset=utf-8');

// Indica que la ruta solicitada no fue encontrada.
http_response_code(404);

// Envía el mensaje de error al frontend.
echo json_encode(['error' => 'Ruta no encontrada. Endpoints disponibles en /api/*.php']);
