<?php
require_once 'db_service.php';

// Überprüfen, ob die POST-Anfrage das Feld 'username' enthält
if (isset($_POST['username'])) {
    $username = $_POST['username'];

    // SQL-Abfrage: Setze die group_id und teamrole auf NULL
    $sql = "UPDATE users SET group_id = NULL, teamrole = NULL WHERE username = :username";
    $stmt = $pdo->prepare($sql);

    if ($stmt->execute(['username' => $username])) {
        if ($stmt->rowCount() > 0) {
            echo json_encode(['success' => true, 'message' => 'Team erfolgreich verlassen.']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Benutzer ist keinem Team zugewiesen oder nicht vorhanden.']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Fehler beim Ausführen der Abfrage.']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Ungültige Anfrage. Der Benutzername fehlt.']);
}
