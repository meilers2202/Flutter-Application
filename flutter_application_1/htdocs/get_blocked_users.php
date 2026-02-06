<?php
require_once 'db_service.php'; // enthält $pdo

try {
    $stmt = $pdo->query("SELECT username FROM users WHERE blocked = 1");
    $blockedUsers = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if ($blockedUsers && count($blockedUsers) > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Blockierte Benutzer erfolgreich abgerufen.',
            'users' => $blockedUsers
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Keine blockierten Benutzer gefunden.',
            'users' => []
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Fehler bei der Abfrage: ' . $e->getMessage(),
        'users' => []
    ]);
}
