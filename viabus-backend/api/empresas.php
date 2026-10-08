<?php

// Configuración de base de datos y funciones auxiliares.
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

// Configura CORS y gestiona solicitudes preflight.
setCorsHeaders();
handlePreflight();

// Obtiene la conexión con la base de datos.
$pdo = getConnection();

// Solo acepta solicitudes GET, ya que este endpoint se utiliza para consultar empresas.
if ($_SERVER['REQUEST_METHOD'] !== 'GET') sendError('Método no soportado', 405);


// GET /api/empresas.php         -> obtiene una lista de empresas.
// GET /api/empresas.php?id=3    -> obtiene los datos completos de una empresa y sus rutas.

if (isset($_GET['id'])) {
    obtenerEmpresa($pdo, (int)$_GET['id']);
}

// Obtiene las empresas mostrando solo los datos necesarios para la grilla de logos.
$stmt = $pdo->query("SELECT id, nombre, logo FROM empresas ORDER BY nombre");
sendResponse($stmt->fetchAll());


// --------------------------------------------------------------------

/**
 * Obtiene la información completa de una empresa y las rutas que opera.
 */
function obtenerEmpresa(PDO $pdo, int $id): void {

    // Busca los datos principales de la empresa mediante su ID.
    $stmt = $pdo->prepare("
        SELECT id, nombre, logo, descripcion, telefono, email, sitio_web, direccion
        FROM empresas
        WHERE id = ?
    ");
    $stmt->execute([$id]);
    $empresa = $stmt->fetch();

    // Si la empresa no existe, devuelve un error 404.
    if (!$empresa) sendError('Empresa no encontrada', 404);


    // Obtiene las rutas activas que opera la empresa y sus frecuencias diarias.
    $stmt = $pdo->prepare("
        SELECT c_o.nombre AS origen, c_d.nombre AS destino, COUNT(*) AS frecuencias
        FROM servicios s
        JOIN ciudades c_o ON s.origen_id  = c_o.id
        JOIN ciudades c_d ON s.destino_id = c_d.id
        WHERE s.empresa_id = ? AND s.activo = 1
        GROUP BY c_o.nombre, c_d.nombre
        ORDER BY c_o.nombre, c_d.nombre
    ");
    $stmt->execute([$id]);

    // Agrega las rutas obtenidas a los datos de la empresa.
    $empresa['rutas'] = $stmt->fetchAll();

    // Devuelve toda la información de la empresa.
    sendResponse($empresa);
}
