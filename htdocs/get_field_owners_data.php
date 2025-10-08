<?php
require_once 'db_service.php'; // enthält $pdo

try {
    $stmt = $pdo->query("SELECT name FROM fieldowner");
    $owners = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if ($owners && count($owners) > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Fieldowner erfolgreich abgerufen.',
            'users' => $owners
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Keine Fieldowner gefunden.',
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
