<?php

// Indica que todas las respuestas de este archivo serán enviadas en formato JSON.
header('Content-Type: application/json');

// Carga las librerías necesarias del proyecto.
require_once __DIR__ . '/../../vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

try {

    // Obtiene el ID de la reserva desde la dirección de la solicitud.
    $reservaId = $_GET['reserva_id'] ?? null;

    // Obtiene los datos enviados desde Vue en formato JSON.
    $input = json_decode(file_get_contents('php://input'), true);

    // Obtiene el correo electrónico al que se enviará el QR.
    $email = $input['email'] ?? null;

    // Verifica que se haya indicado una reserva.
    if (!$reservaId) {
        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Falta el ID de la reserva.'
        ]);

        exit;
    }

    // Verifica que el correo exista y tenga un formato válido.
    if (!$email || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'El email no es válido.'
        ]);

        exit;
    }

    // El código QR se genera en el frontend mediante un canvas
    // y se recibe aquí como una imagen codificada en Base64.
    $qrBase64 = $input['qrBase64'] ?? null;

    // Verifica que se haya recibido el código QR.
    if (!$qrBase64) {

        http_response_code(400);

        echo json_encode([
            'success' => false,
            'message' => 'Falta el QR de la reserva.'
        ]);

        exit;
    }

    // Elimina la información inicial del formato de imagen Base64
    // y convierte el contenido en datos de imagen.
    $qrData = base64_decode(preg_replace('#^data:image/\w+;base64,#', '', $qrBase64));

    // Crea el objeto encargado de enviar el correo.
    $mail = new PHPMailer(true);

    // Configura el envío mediante el servidor SMTP de Gmail.
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;

    // Cuenta utilizada para enviar los correos.
    $mail->Username = 'servicioviabus@gmail.com';

    // Contraseña de la cuenta utilizada para la autenticación SMTP.
    // Se recomienda almacenar este dato en una configuración segura
    // y no directamente dentro del código fuente.
    $mail->Password = 'CLAVE_SMTP_CONFIGURADA';

    // Utiliza una conexión segura mediante STARTTLS.
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;

    // Define la dirección y el nombre que aparecerán como remitente.
    $mail->setFrom(
        'servicioviabus@gmail.com',
        'ViaBus'
    );

    // Define el correo electrónico que recibirá el mensaje.
    $mail->addAddress($email);

    // Adjunta el código QR al correo.
    // El archivo se genera directamente desde los datos recibidos,
    // sin necesidad de guardarlo previamente en el servidor.
    $mail->addStringAttachment(
        $qrData,
        "QR_Reserva_$reservaId.png"
    );

    // Configura el contenido del correo como HTML.
    $mail->isHTML(true);

    // Define el asunto del correo.
    $mail->Subject = "QR de tu reserva - ViaBus";

    // Contenido principal del correo.
    $mail->Body = "
        <h2>¡Reserva confirmada!</h2>

        <p>Adjuntamos el código QR correspondiente a tu reserva.</p>

        <p>
            <strong>Reserva:</strong> #$reservaId
        </p>

        <p>
            Presentá este código QR al momento de abordar.
        </p>

        <p>Gracias por utilizar ViaBus.</p>
    ";

    // Versión de texto del mensaje para clientes de correo
    // que no muestran contenido HTML.
    $mail->AltBody =
        "Reserva #$reservaId\n\n" .
        "Adjuntamos el código QR correspondiente a tu reserva.\n\n" .
        "Gracias por utilizar ViaBus.";

    // Envía el correo electrónico.
    $mail->send();

    // Informa que el envío se realizó correctamente.
    echo json_encode([
        'success' => true,
        'message' => 'QR enviado correctamente.'
    ]);

} catch (Exception $e) {

    // Si ocurre un problema durante el envío,
    // devuelve un error interno del servidor.
    http_response_code(500);

    echo json_encode([
        'success' => false,
        'message' => 'No se pudo enviar el correo.'
    ]);
}

