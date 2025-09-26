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
$id = $_POST['id'] ?? null; // Die ID ist zwingend erforderlich
$fieldname = $_POST['fieldname'] ?? null;
$description = $_POST['description'] ?? null;
$rules = $_POST['rules'] ?? null;
$street = $_POST['street'] ?? null;
$housenumber = $_POST['housenumber'] ?? null;
$city = $_POST['city'] ?? null;
$company = $_POST['company'] ?? null;

// Einfache Validierung der Pflichtfelder (ID und Feldname)
if (!$id || !$fieldname) {
    echo json_encode(['success' => false, 'message' => 'Feld-ID oder Feldname fehlt.']);
    $conn->close();
    exit();
}

// SQL-Abfrage vorbereiten (UPDATE)
$stmt = $conn->prepare("UPDATE fields SET fieldname = ?, description = ?, rules = ?, street = ?, housenumber = ?, city = ?, company = ? WHERE id = ?");

// Parameter binden (sind alle Strings, außer die ID, die als Integer gebunden wird)
$stmt->bind_param("sssssssi", $fieldname, $description, $rules, $street, $housenumber, $city, $company, $id);

// Abfrage ausführen
if ($stmt->execute()) {
    // Überprüfen, ob tatsächlich eine Zeile aktualisiert wurde
    if ($stmt->affected_rows > 0) {
        echo json_encode(['success' => true, 'message' => 'Feld erfolgreich aktualisiert.']);
    } else {
        // Dies kann passieren, wenn das Feld existiert, aber keine Änderungen vorgenommen wurden
        echo json_encode(['success' => true, 'message' => 'Keine Änderungen vorgenommen oder Feld nicht gefunden.']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Fehler beim Aktualisieren des Feldes: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>