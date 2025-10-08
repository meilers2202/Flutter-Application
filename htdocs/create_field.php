<?php
require_once 'db_service.php';  // hier ist die PDO-Verbindung $pdo drin

header('Content-Type: application/json; charset=UTF-8');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// POST-Daten holen
$fieldname = $_POST['fieldname'] ?? null;
$description = $_POST['description'] ?? null;
$rules = $_POST['rules'] ?? null;
$street = $_POST['street'] ?? null;
$housenumber = $_POST['housenumber'] ?? null;
$postalcode = $_POST['postalcode'] ?? null;
$city = $_POST['city'] ?? null;
$company = $_POST['company'] ?? null;
$field_owner_id = isset($_POST['field_owner_id']) ? (int)$_POST['field_owner_id'] : null;

// Validierung
if (!$fieldname || !$description || !$field_owner_id) {
    echo json_encode(['success' => false, 'message' => 'Feldname, Beschreibung oder Eigentümer-ID fehlt.']);
    exit();
}

try {
    $stmt = $pdo->prepare("INSERT INTO fields (fieldname, description, rules, street, housenumber, postalcode, city, company, field_owner_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
    $success = $stmt->execute([$fieldname, $description, $rules, $street, $housenumber, $postalcode, $city, $company, $field_owner_id]);

    if ($success) {
        echo json_encode(['success' => true, 'message' => 'Feld erfolgreich erstellt.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Fehler beim Erstellen des Feldes.']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
