<?php

// Guarda las credenciales y configuraciones necesarias para Mercado Pago.
define('MP_ACCESS_TOKEN', 'TEST-000000000000000-000000-00000000000000000000000000000-000000000');

// Indica dónde está el frontend al que vuelve el usuario después del pago.
define('MP_FRONTEND_URL', 'http://localhost:9000');

// Indica dónde Mercado Pago enviará avisos sobre los cambios de los pagos.
define('MP_WEBHOOK_URL', 'http://localhost:8000/api/pagos.php?action=webhook');

// Guarda la dirección principal utilizada para comunicarse con Mercado Pago.
define('MP_API_BASE', 'https://api.mercadopago.com');


// Envía una solicitud a Mercado Pago y devuelve la respuesta recibida.
function mpRequest(string $method, string $endpoint, ?array $body = null): array {

    // Inicia la conexión utilizando la dirección del servicio solicitado.
    $ch = curl_init(MP_API_BASE . $endpoint);

    // Indica que queremos guardar la respuesta para utilizarla después.
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    // Define el tipo de solicitud que se enviará a Mercado Pago.
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);

    // Envía la autorización y avisa que trabajaremos con datos JSON.
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . MP_ACCESS_TOKEN,
        'Content-Type: application/json',
    ]);

    // Establece un límite de 15 segundos para recibir una respuesta.
    curl_setopt($ch, CURLOPT_TIMEOUT, 15);


    // Comprueba si hay información que debe enviarse junto con la solicitud.
    if ($body !== null) {

        // Convierte los datos a JSON para enviarlos correctamente.
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
    }


    // Ejecuta la solicitud y guarda la respuesta de Mercado Pago.
    $response = curl_exec($ch);

    // Obtiene el código HTTP para conocer el resultado de la solicitud.
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    // Guarda cualquier problema ocurrido durante la conexión.
    $curlError = curl_error($ch);

    // Cierra la conexión porque la solicitud ya terminó.
    curl_close($ch);


    // Comprueba si ocurrió un error al conectarse con Mercado Pago.
    if ($curlError) {
        throw new Exception('Error de conexión con Mercado Pago: ' . $curlError);
    }


    // Convierte la respuesta recibida de JSON a un array de PHP.
    $data = json_decode($response, true) ?? [];


    // Comprueba si Mercado Pago respondió indicando algún error.
    if ($httpCode >= 400) {

        // Obtiene el mensaje de error enviado por Mercado Pago.
        $msg = $data['message'] ?? 'Error desconocido de Mercado Pago';

        // Informa el código y motivo para poder manejar correctamente el error.
        throw new Exception("Mercado Pago respondió $httpCode: $msg");
    }


    // Devuelve los datos recibidos para continuar con el proceso del pago.
    return $data;
}

