<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

$fieldId = $_POST['field_id'] ?? null;
if ($fieldId === null) {
    echo json_encode(['success' => false, 'message' => 'field_id fehlt.']);
    exit;
}

try {
    $stmt = $pdo->prepare('SELECT id, field_id, title, start_at, end_at, description, status, created_at, location, location_street, location_house_number, location_postalcode, location_city, location_state, location_country, location_lat, location_lng, scenario, organizer, min_age, required_gear, chrono_at, briefing_at, medic_contact FROM field_events WHERE field_id = :field_id ORDER BY start_at ASC');
    $stmt->execute(['field_id' => (int)$fieldId]);
    $events = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $ticketStmt = $pdo->prepare('SELECT id, event_id, label, price, currency, notes, sort_order FROM field_event_tickets WHERE event_id = :event_id ORDER BY sort_order ASC, id ASC');
    $limitStmt = $pdo->prepare('SELECT id, event_id, class_name, limit_value, distance, requirement, sort_order FROM field_event_power_limits WHERE event_id = :event_id ORDER BY sort_order ASC, id ASC');

    foreach ($events as &$event) {
        $ticketStmt->execute(['event_id' => (int)$event['id']]);
        $event['tickets'] = $ticketStmt->fetchAll(PDO::FETCH_ASSOC);

        $limitStmt->execute(['event_id' => (int)$event['id']]);
        $event['power_limits'] = $limitStmt->fetchAll(PDO::FETCH_ASSOC);
    }
    unset($event);

    echo json_encode(['success' => true, 'events' => $events]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler bei der Datenbankabfrage: ' . $e->getMessage()]);
}
