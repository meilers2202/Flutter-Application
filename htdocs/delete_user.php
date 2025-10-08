<?php
require_once 'db_service.php'; // enthält $pdo

header('Content-Type: application/json');

$username = $_POST['username'] ?? null;

if (!$username) {
    echo json_encode([
        'success' => false,
        'message' => 'Kein Benutzername angegeben.'
    ]);
    exit;
}

try {
    $stmt = $pdo->prepare("DELETE FROM users WHERE username = :username");
    $stmt->execute(['username' => $username]);

    if ($stmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => "Benutzer '$username' wurde gelöscht."
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => "Benutzer '$username' wurde nicht gefunden."
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Fehler beim Löschen des Benutzers: ' . $e->getMessage()
    ]);
}
