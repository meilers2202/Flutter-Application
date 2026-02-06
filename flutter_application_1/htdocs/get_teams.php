<?php
require_once 'db_service.php'; // stellt $pdo bereit

try {
    $detailed = isset($_GET['detailed']) && $_GET['detailed'] === 'true';
    $teams = [];

    if ($detailed) {
        // Detaillierte Ansicht mit Mitgliederanzahl
        $stmt = $pdo->query("
            SELECT g.id, g.name AS teamName, COUNT(u.id) AS memberCount
            FROM groups g
            LEFT JOIN users u ON g.id = u.group_id
            GROUP BY g.id
            ORDER BY g.name ASC
        ");
        $teams = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['success' => true, 'teams' => $teams]);
    } else {
        // Einfache Teamliste
        $stmt = $pdo->query("SELECT id, name FROM groups ORDER BY name ASC");
        $teams = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(['success' => true, 'teams' => $teams]);
    }

} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Fehler bei der Datenbankabfrage: ' . $e->getMessage()
    ]);
}
