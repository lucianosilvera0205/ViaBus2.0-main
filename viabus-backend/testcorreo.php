<?php

// Carga las librerías instaladas por Composer.
require __DIR__ . '/vendor/autoload.php';

// Importa las clases necesarias de PHPMailer.
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Crea una instancia de PHPMailer y activa el manejo de excepciones.
$mail = new PHPMailer(true);

try {
    // Configura el envío de correos mediante SMTP.
    $mail->isSMTP();

    // Indica que se utilizará el servidor SMTP de Gmail.
    $mail->Host = 'smtp.gmail.com';

    // Activa la autenticación para conectarse al servidor.
    $mail->SMTPAuth = true;

    // Define la cuenta de Gmail que enviará el correo.
    $mail->Username = 'lucasperezsampayo7@gmail.com';

    // Define la contraseña de aplicación de la cuenta de Gmail.
    $mail->Password = 'REDACTED_APP_PASSWORD';

    // Configura una conexión segura mediante STARTTLS.
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;

    // Define el puerto utilizado por SMTP con STARTTLS.
    $mail->Port = 587;


    // Define el remitente del correo.
    $mail->setFrom(
        'lucasperezsampayo7@gmail.com',
        'ViaBus'
    );


    // Define la dirección que recibirá el correo.
    $mail->addAddress(
        'facugatonegro@gmail.com'
    );


    // Configura el contenido del correo como HTML.
    $mail->isHTML(true);

    // Define el asunto del correo.
    $mail->Subject = 'Prueba de ViaBus';

    // Define el contenido HTML que tendrá el correo.
    $mail->Body = '
        <h1>¡Funciona!</h1>
        <p>Este correo fue enviado desde ViaBus usando PHPMailer.</p>
    ';

    // Envía el correo.
    $mail->send();

    // Informa que el correo fue enviado correctamente.
    echo 'Correo enviado correctamente';

} catch (Exception $e) {

    // Muestra el error producido durante el envío.
    echo 'Error: ' . $mail->ErrorInfo;
}