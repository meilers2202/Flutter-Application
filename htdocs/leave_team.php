<?php
require_once 'db_config.php';
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode(['success' => false, 'message' => 'Verbindungsfehler: ' . $conn->connect_error]);
    exit();
}

// Überprüfen, ob die POST-Anfrage das Feld 'username' enthält
if (isset($_POST['username'])) {
    $username = $conn->real_escape_string($_POST['username']);

    // SQL-Abfrage vorbereiten: Setze die group_id und teamrole auf NULL in einem Schritt
    $stmt = $conn->prepare("UPDATE users SET group_id = NULL, teamrole = NULL WHERE username = ?");
    $stmt->bind_param("s", $username);

    // Abfrage ausführen und Erfolg überprüfen
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'Team erfolgreich verlassen.']);
        } else {
            // Dies passiert, wenn der Benutzer bereits keinem Team zugewiesen war
            echo json_encode(['success' => false, 'message' => 'Benutzer ist keinem Team zugewiesen oder nicht vorhanden.']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Fehler beim Ausführen der Abfrage: ' . $stmt->error]);
    }

    $stmt->close();
} else {
    // Fehler, wenn 'username' in der Anfrage fehlt
    echo json_encode(['success' => false, 'message' => 'Ungültige Anfrage. Der Benutzername fehlt.']);
}

$conn->close();
?>