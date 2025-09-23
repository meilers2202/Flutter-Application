<?php
require_once 'db_config.php';
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli($servername, $username, $password, $dbname);

// Verbindung überprüfen
if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Verbindungsfehler: ' . $conn->connect_error]);
    exit();
}

// Überprüfen, ob die POST-Anfrage die erforderlichen Felder enthält
if (isset($_POST['username']) && isset($_POST['teamName'])) {
    $username = $conn->real_escape_string($_POST['username']);
    $teamName = $conn->real_escape_string($_POST['teamName']);

    // 1. Hole die 'id' des Teams aus der 'groups'-Tabelle, basierend auf dem 'name'
    $stmt_team = $conn->prepare("SELECT id FROM groups WHERE name = ?");
    $stmt_team->bind_param("s", $teamName);
    $stmt_team->execute();
    $result_team = $stmt_team->get_result();

    if ($result_team->num_rows > 0) {
        $row = $result_team->fetch_assoc();
        $groupId = $row['id'];

        // 2. Aktualisiere die 'group_id' und 'teamrole' des Benutzers in einem Schritt
        $stmt_user = $conn->prepare("UPDATE users SET group_id = ?, teamrole = 2 WHERE username = ?");
        $stmt_user->bind_param("is", $groupId, $username);

        if ($stmt_user->execute()) {
            echo json_encode(['success' => true, 'message' => 'Team erfolgreich beigetreten.']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Fehler beim Beitreten des Teams: ' . $stmt_user->error]);
        }
        $stmt_user->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'Team nicht gefunden.']);
    }

    $stmt_team->close();
} else {
    // Fehler, wenn 'username' oder 'teamName' in der Anfrage fehlen
    echo json_encode(['success' => false, 'message' => 'Ungültige Anfrage. Benutzername oder Teamname fehlen.']);
}

$conn->close();
?>