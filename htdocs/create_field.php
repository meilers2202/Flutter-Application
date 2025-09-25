<?php
// Binden Sie Ihre Datenbankkonfigurationsdatei ein
require_once 'db_config.php';
header('Content-Type: application/json');

// Überprüfen, ob die Anfragemethode POST ist
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Ungültige Anfragemethode.']);
    exit();
}

// Erstellen Sie die Verbindung
$conn = new mysqli($servername, $username, $password, $dbname);

// Überprüfen Sie die Verbindung
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Verbindungsfehler: ' . $conn->connect_error]);
    exit();
}

// Holen Sie die Daten aus dem POST-Request
$fieldname = $_POST['fieldname'] ?? null;
$description = $_POST['description'] ?? null;
$rules = $_POST['rules'] ?? null;
$street = $_POST['street'] ?? null;
$housenumber = $_POST['housenumber'] ?? null;
$postalcode = $_POST['postalcode'] ?? null;
$city = $_POST['city'] ?? null;
$company = $_POST['company'] ?? null;
$field_owner_id = $_POST['field_owner_id'] ?? null;

// Einfache Validierung der Pflichtfelder
if (!$fieldname || !$description || !$field_owner_id) {
    echo json_encode(['success' => false, 'message' => 'Feldname, Beschreibung oder Eigentümer-ID fehlt.']);
    $conn->close();
    exit();
}

// SQL-Abfrage vorbereiten
$stmt = $conn->prepare("INSERT INTO fields (fieldname, description, rules, street, housenumber, postalcode, city, company, field_owner_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
$stmt->bind_param("ssssssssi", $fieldname, $description, $rules, $street, $housenumber, $postalcode, $city, $company, $field_owner_id);

// Abfrage ausführen
if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Feld erfolgreich erstellt.']);
} else {
    echo json_encode(['success' => false, 'message' => 'Fehler beim Erstellen des Feldes: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>