<?php
require_once 'db_config.php';
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Verbindung zur Datenbank herstellen
$conn = new mysqli($servername, $username, $password, $dbname);

// Prüfen, ob eine detaillierte Abfrage gewünscht ist
$detailed = isset($_GET['detailed']) && $_GET['detailed'] === 'true';

$teams = [];

if ($detailed) {
    // Abfrage für die detaillierte Ansicht mit Mitgliedszahl
    $stmt = $conn->prepare("SELECT g.id, g.name AS teamName, COUNT(u.id) AS memberCount FROM groups g LEFT JOIN users u ON g.id = u.group_id GROUP BY g.id ORDER BY g.name ASC");
    $stmt->execute();
    $result = $stmt->get_result();

    while ($row = $result->fetch_assoc()) {
        $teams[] = [
            'id' => $row['id'],
            'teamName' => $row['teamName'],
            'memberCount' => (int)$row['memberCount'],
        ];
    }

    echo json_encode(['success' => true, 'teams' => $teams]);

} else {
    // Abfrage für die einfache Teamliste (ID und Name)
    $stmt = $conn->prepare("SELECT id, name FROM groups ORDER BY name ASC");
    $stmt->execute();
    $result = $stmt->get_result();
    
    while ($row = $result->fetch_assoc()) {
        $teams[] = [
            'id' => $row['id'],
            'name' => $row['name'],
        ];
    }
    
    echo json_encode(["success" => true, "teams" => $teams]);
}

if (isset($stmt)) {
    $stmt->close();
}
$conn->close();

?>