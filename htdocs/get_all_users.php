<?php
require_once 'db_service.php';  // enthält $pdo

try {
    $stmt = $pdo->query("SELECT username FROM users");
    $users = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if ($users && count($users) > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Benutzer erfolgreich abgerufen.',
            'users' => $users
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Keine Benutzer gefunden.',
            'users' => []
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Fehler bei der Datenbankabfrage: ' . $e->getMessage(),
        'users' => []
    ]);
}
