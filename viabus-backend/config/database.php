<?php

// Los datos de conexión se toman de variables de entorno, con valores por
// defecto pensados para desarrollo local. Para producción, definí las
// variables DB_HOST / DB_PORT / DB_NAME / DB_USER / DB_PASS en el entorno
// (o en un .env cargado antes de este archivo) en vez de tocar el código.

define('DB_HOST', getenv('DB_HOST') ?: '127.0.0.1');
define('DB_PORT', getenv('DB_PORT') ?: '5432');
define('DB_NAME', getenv('DB_NAME') ?: 'viabus');
define('DB_USER', getenv('DB_USER') ?: 'postgres');
define('DB_PASS', getenv('DB_PASS') ?: 'postgres');

// Indica dónde se encuentra el archivo que contiene las tablas.
// Se utiliza para crear la estructura inicial si todavía no existe.

define('DB_SCHEMA', __DIR__ . '/../sql/schema.sql');


// Crea y devuelve la conexión reutilizable con la base de datos.
// Evita abrir múltiples conexiones innecesarias durante una misma ejecución.

function getConnection(): PDO {

    // Guarda la conexión para reutilizarla cuando vuelva a solicitarse.
// Así se evita establecer nuevamente la conexión en cada llamada.

    static $pdo = null;

    // Comprueba si todavía no existe una conexión activa.
// Solo se conecta a PostgreSQL cuando realmente es necesario.

    if ($pdo === null) {

        try {

            // Construye los datos necesarios para conectarse a PostgreSQL.
// Define servidor, puerto y nombre de la base de datos utilizada.

            $dsn = 'pgsql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME;

            // Abre la conexión utilizando las credenciales configuradas.
// Permite que el sistema pueda ejecutar consultas sobre PostgreSQL.

            $pdo = new PDO($dsn, DB_USER, DB_PASS);

            // Configura PDO para informar errores mediante excepciones.
// Facilita detectar y controlar problemas durante las consultas.

            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

            // Configura las consultas para devolver resultados como arrays asociativos.
// Permite acceder a cada dato utilizando directamente el nombre de la columna.

            $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);


            // Comprueba si la tabla principal de usuarios ya existe.
// Esto permite saber si la estructura de la base está inicializada.

            // Si la tabla principal no existe todavía, inicializamos el
            // esquema completo (equivalente a lo que antes hacía SQLite
            // automáticamente al crear el archivo .sqlite).

            $stmt = $pdo->query("SELECT to_regclass('public.usuarios')");
            $existe = $stmt->fetchColumn();

            // Si no existe la tabla y encontramos el archivo del esquema,
// ejecutamos automáticamente la estructura inicial de la base de datos.

            if (!$existe && file_exists(DB_SCHEMA)) {
                $pdo->exec(file_get_contents(DB_SCHEMA));
            }

        } catch (PDOException $e) {

            // Informa al cliente que ocurrió un error interno del servidor.
// Se utiliza cuando la aplicación no puede conectarse correctamente.

            http_response_code(500);

            // Indica que la respuesta enviada al cliente tendrá formato JSON.
// Permite que el frontend pueda interpretar correctamente el mensaje.

            header('Content-Type: application/json; charset=utf-8');

            // Devuelve información sobre el error ocurrido durante la conexión.
// Ayuda a identificar qué problema impidió acceder a la base de datos.

            echo json_encode([
                'error' => 'Error de conexión a la base de datos: ' . $e->getMessage()
            ]);

            // Detiene inmediatamente la ejecución después del error.
// Evita que el sistema continúe funcionando sin una conexión válida.

            exit;
        }
    }

    // Devuelve la conexión disponible para ejecutar consultas.
// Así las demás partes del sistema pueden acceder a PostgreSQL.

    return $pdo;
}

