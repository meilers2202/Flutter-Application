<?php
require_once 'db_config.php';
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    // Fehler bei der Datenbankverbindung
    echo json_encode(["success" => false, "message" => "Verbindungsfehler: " . $conn->connect_error]);
    exit();
}

// Wählt ALLE Felder (Spalten) aus der 'fields'-Tabelle
$sql = "SELECT id, fieldname, description, rules, street, housenumber, postalcode, city, company, field_owner_id, checkstate FROM fields";
$result = $conn->query($sql);

$fields = []; // Variable für die Felder
if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        // Fügt jede Zeile (jedes Feld) zur Liste hinzu
        $fields[] = $row; 
    }
    
    // Gibt die gesamte Feldliste unter dem Key 'fields' zurück
    echo json_encode(["success" => true, "fields" => $fields]);
} else {
    // Keine Felder gefunden
    echo json_encode(["success" => true, "fields" => [], "message" => "Keine registrierten Spielfelder gefunden."]);
}

$conn->close();
?>