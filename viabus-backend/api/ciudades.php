<?php

// Configuración de base de datos y funciones auxiliares.
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/helpers.php';

// Configura CORS y gestiona solicitudes preflight.
setCorsHeaders();
handlePreflight();

// Obtiene la conexión con la base de datos.
$pdo = getConnection();

// Solo permite solicitudes GET.
// Solo acepta solicitudes, ya que este endpoint solo permite hacer consolutas por ciudades.
if ($_SERVER['REQUEST_METHOD'] !== 'GET') sendError('Método no soportado', 405);

// Obtiene todas las ciudades ordenadas alfabéticamente.
$stmt = $pdo->query("SELECT id, nombre FROM ciudades ORDER BY nombre");

// Devuelve la lista de ciudades.
sendResponse($stmt->fetchAll());
