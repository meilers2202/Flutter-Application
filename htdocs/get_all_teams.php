<?php
require_once 'db_config.php';
header('Content-Type: application/json');

// Erstelle Verbindung zur Datenbank
$conn = new mysqli($servername, $username, $password, $dbname);

// Überprüfe die Verbindung
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Verbindungsfehler: ' . $conn->connect_error]);
    exit();
}

$teams = [];

// SQL-Abfrage, um alle Teamnamen und die Anzahl der Mitglieder zu bekommen
$sql = "SELECT g.name AS teamName, COUNT(u.id) AS memberCount FROM groups g LEFT JOIN users u ON g.id = u.group_id GROUP BY g.id";

$result = $conn->query($sql);

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $teams[] = $row;
    }
    echo json_encode(['success' => true, 'teams' => $teams, 'message' => 'Teams erfolgreich abgerufen.']);
} else {
    echo json_encode(['success' => false, 'message' => 'Fehler bei der Abfrage: ' . $conn->error]);
}

$conn->close();
?>