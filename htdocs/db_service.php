<?php

header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Konfiguration laden
require_once 'db_config.php';

// Datenbankverbindung via PDO
try {
    $pdo = new PDO($dsn, $user, $pass, $options);
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => "Verbindung fehlgeschlagen: " . $e->getMessage()]);
    exit;
}
