<?php
require_once 'db_service.php'; // stellt $pdo bereit

try {
    // Teams (Gruppennamen) auslesen
    $stmt = $pdo->query("SELECT name FROM groups");
    $teams = $stmt->fetchAll(PDO::FETCH_COLUMN); // gibt nur die Spalte 'name' als Array zurück

    if ($teams) {
        echo json_encode([
            'success' => true,
            'message' => 'Teams erfolgreich abgerufen.',
            'teams' => $teams
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Keine Teams gefunden.',
            'teams' => []
        ]);
    }
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Fehler bei der Datenbankabfrage: ' . $e->getMessage(),
        'teams' => []
    ]);
}
