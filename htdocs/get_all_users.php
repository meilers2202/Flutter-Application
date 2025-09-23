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

// SQL-Abfrage, um alle Benutzernamen aus der 'users'-Tabelle abzurufen
// Passe 'users' und 'username' an die tatsächlichen Namen deiner Tabelle und Spalte an.
$sql = "SELECT username FROM users";
$result = $conn->query($sql);

$users = [];
if ($result->num_rows > 0) {
    // Daten von jeder Zeile abrufen und zum Array hinzufügen
    while($row = $result->fetch_assoc()) {
        $users[] = $row["username"];
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