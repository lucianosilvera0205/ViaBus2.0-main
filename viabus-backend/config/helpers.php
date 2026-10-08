<?php

// Define la zona horaria de Uruguay para trabajar con fechas y horarios locales.
date_default_timezone_set('America/Montevideo');

// Guarda la fecha actual para utilizarla en diferentes partes de la aplicación.
$hoy   = date('Y-m-d');

// Guarda la hora actual para poder comparar horarios de servicios.
$ahora = date('H:i');


// Configura los permisos y el formato de las respuestas de la API.
function setCorsHeaders(): void {

    // Permite que el frontend pueda comunicarse con esta API.
    header('Access-Control-Allow-Origin: *');

    // Indica qué tipos de solicitudes puede recibir la API.
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');

    // Permite recibir datos y credenciales enviados desde el frontend.
    header('Access-Control-Allow-Headers: Content-Type, Authorization');

    // Indica que las respuestas de la API estarán en formato JSON.
    header('Content-Type: application/json; charset=utf-8');
}


// Comprueba las solicitudes OPTIONS que realiza el navegador antes de algunas peticiones.
function handlePreflight(): void {

    // Verifica si la solicitud actual es una petición OPTIONS.
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {

        // Indica que la solicitud fue aceptada correctamente sin contenido.
        http_response_code(204);

        // Detiene la ejecución porque no hay nada más que procesar.
        exit;
    }
}


// Envía una respuesta al frontend utilizando el código HTTP indicado.
function sendResponse(mixed $data, int $code = 200): void {

    // Define el código que informa el resultado de la solicitud.
    http_response_code($code);

    // Convierte los datos a JSON para que el frontend pueda leerlos.
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

    // Detiene el programa después de enviar la respuesta.
    exit;
}


// Envía un mensaje de error utilizando el formato estándar de la API.
function sendError(string $message, int $code = 400): void {

    // Utiliza la respuesta general para enviar el error correspondiente.
    sendResponse(['error' => $message], $code);
}


// Obtiene los datos enviados por el frontend dentro de la solicitud.
function getRequestBody(): array {

    // Lee la información enviada dentro de la petición HTTP.
    $raw = file_get_contents('php://input');

    // Convierte los datos recibidos desde JSON a un array.
    $data = json_decode($raw, true);

    // Devuelve los datos recibidos o un array vacío si no hay datos.
    return $data ?? [];
}


// Comprueba que la solicitud utilice el método HTTP esperado por el endpoint.
function requireMethod(string $method): void {

    // Compara el método recibido con el método que debería utilizarse.
    if ($_SERVER['REQUEST_METHOD'] !== $method) {

        // Informa al frontend que ese método no está permitido.
        sendError('Método no permitido', 405);
    }
}

