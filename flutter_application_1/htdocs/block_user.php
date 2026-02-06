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
    $stmt = $pdo->prepare("UPDATE users SET blocked = 1 WHERE username = :username");
    $stmt->execute(['username' => $username]);

    if ($stmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => "Benutzer '$username' wurde blockiert."
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => "Benutzer '$username' wurde nicht gefunden oder war bereits blockiert."
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Fehler beim Blockieren des Benutzers: ' . $e->getMessage()
    ]);
}
