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

// Überprüfe, ob der 'teamName' im POST-Request vorhanden ist
if (isset($_POST['teamName'])) {
    $teamName = $_POST['teamName'];

    // Zuerst überprüfen, ob das Team bereits existiert
    $stmt_check = $conn->prepare("SELECT COUNT(*) FROM groups WHERE name = ?");
    $stmt_check->bind_param("s", $teamName);
    $stmt_check->execute();
    $stmt_check->bind_result($count);
    $stmt_check->fetch();
    $stmt_check->close();

    if ($count > 0) {
        echo json_encode(['success' => false, 'message' => 'Team existiert bereits.']);
    } else {
        // Füge das neue Team in die Datenbanktabelle 'groups' ein
        $stmt_insert = $conn->prepare("INSERT INTO groups (name) VALUES (?)");
        $stmt_insert->bind_param("s", $teamName);

        if ($stmt_insert->execute()) {
            echo json_encode(['success' => true, 'message' => 'Team erfolgreich hinzugefügt.']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Fehler beim Hinzufügen des Teams: ' . $stmt_insert->error]);
        }
        $stmt_insert->close();
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Teamname nicht angegeben.']);
}

$conn->close();
?>