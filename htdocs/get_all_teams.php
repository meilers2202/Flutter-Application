<?php
require_once 'db_service.php'; // Stellt Verbindung via $pdo bereit
header('Content-Type: application/json');

try {
    // SQL-Abfrage: Alle Teamnamen + Mitgliederzahl
    $sql = "SELECT g.name AS teamName, COUNT(u.id) AS memberCount
            FROM groups g
            LEFT JOIN users u ON g.id = u.group_id
            GROUP BY g.id";

    $stmt = $pdo->query($sql); // Kein prepare nötig, da keine User-Inputs

    $teams = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true,
        'teams' => $teams,
        'message' => 'Teams erfolgreich abgerufen.'
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Fehler bei der Abfrage: ' . $e->getMessage()
    ]);
}
