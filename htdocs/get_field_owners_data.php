<?php
require_once 'db_config.php';
header('Content-Type: application/json');


// Erstelle die Verbindung
$conn = new mysqli($servername, $username, $password, $dbname);

// Überprüfe die Verbindung
if ($conn->connect_error) {
    die(json_encode([
        'success' => false,
        'message' => 'Verbindungsfehler zur Datenbank: ' . $conn->connect_error
    ]));
}

$sql = "SELECT name FROM fieldowner";
$result = $conn->query($sql);

$users = [];
if ($result->num_rows > 0) {
    // Daten von jeder Zeile abrufen und zum Array hinzufügen
    while($row = $result->fetch_assoc()) {
        $users[] = $row["name"];
    }
    echo json_encode([
        'success' => true,
        'message' => 'Benutzer erfolgreich abgerufen.',
        'users' => $users
    ]);
} else {
    // Wenn keine Benutzer gefunden wurden
    echo json_encode([
        'success' => false,
        'message' => 'Keine Benutzer gefunden.',
        'users' => []
    ]);
}

$conn->close();

?>