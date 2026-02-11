<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

$fieldId = $_POST['field_id'] ?? null;
$title = trim($_POST['title'] ?? '');
$startAt = trim($_POST['start_at'] ?? '');
$endAt = trim($_POST['end_at'] ?? '');
$description = trim($_POST['description'] ?? '');
$location = trim($_POST['location'] ?? '');
$locationLat = trim($_POST['location_lat'] ?? '');
$locationLng = trim($_POST['location_lng'] ?? '');
$scenario = trim($_POST['scenario'] ?? '');
$organizer = trim($_POST['organizer'] ?? '');
$minAge = trim($_POST['min_age'] ?? '');
$requiredGear = trim($_POST['required_gear'] ?? '');
$chronoAt = trim($_POST['chrono_at'] ?? '');
$briefingAt = trim($_POST['briefing_at'] ?? '');
$medicContact = trim($_POST['medic_contact'] ?? '');
$ticketsJson = $_POST['tickets'] ?? null;
$powerLimitsJson = $_POST['power_limits'] ?? null;
$status = $_POST['status'] ?? 'active';

if (!$fieldId || $title === '' || $startAt === '' || $endAt === '' || $description === '' || $scenario === '' || $organizer === '') {
    echo json_encode(['success' => false, 'message' => 'Pflichtfelder fehlen (field_id, title, start_at, end_at, description, scenario, organizer).']);
    exit;
}

if ($locationLat === '' || $locationLng === '') {
    echo json_encode(['success' => false, 'message' => 'Positionsdaten fehlen (location_lat, location_lng).']);
    exit;
}

if ($minAge === '' || $requiredGear === '' || $medicContact === '') {
    echo json_encode(['success' => false, 'message' => 'Sicherheitsfelder fehlen (min_age, required_gear, medic_contact).']);
    exit;
}

$tickets = [];
if ($ticketsJson !== null) {
    $tickets = json_decode($ticketsJson, true);
    if (!is_array($tickets)) {
        echo json_encode(['success' => false, 'message' => 'Ticketdaten ungueltig.']);
        exit;
    }
}

$powerLimits = [];
if ($powerLimitsJson !== null) {
    $powerLimits = json_decode($powerLimitsJson, true);
    if (!is_array($powerLimits) || count($powerLimits) === 0) {
        echo json_encode(['success' => false, 'message' => 'Mindestens ein Limit ist erforderlich.']);
        exit;
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Limits fehlen.']);
    exit;
}

try {
    $pdo->beginTransaction();

    $stmt = $pdo->prepare('INSERT INTO field_events (field_id, title, start_at, end_at, description, status, location, location_lat, location_lng, scenario, organizer, min_age, required_gear, chrono_at, briefing_at, medic_contact) VALUES (:field_id, :title, :start_at, :end_at, :description, :status, :location, :location_lat, :location_lng, :scenario, :organizer, :min_age, :required_gear, :chrono_at, :briefing_at, :medic_contact)');
    $ok = $stmt->execute([
        'field_id' => (int)$fieldId,
        'title' => $title,
        'start_at' => $startAt,
        'end_at' => $endAt ?: null,
        'description' => $description,
        'status' => $status,
        'location' => $location !== '' ? $location : null,
        'location_lat' => (float)$locationLat,
        'location_lng' => (float)$locationLng,
        'scenario' => $scenario,
        'organizer' => $organizer,
        'min_age' => (int)$minAge,
        'required_gear' => $requiredGear,
        'chrono_at' => $chronoAt !== '' ? $chronoAt : null,
        'briefing_at' => $briefingAt !== '' ? $briefingAt : null,
        'medic_contact' => $medicContact,
    ]);

    if (!$ok) {
        $pdo->rollBack();
        echo json_encode(['success' => false, 'message' => 'Event konnte nicht erstellt werden.']);
        exit;
    }

    $eventId = (int)$pdo->lastInsertId();

    $ticketStmt = $pdo->prepare('INSERT INTO field_event_tickets (event_id, label, price, currency, notes, sort_order) VALUES (:event_id, :label, :price, :currency, :notes, :sort_order)');
    foreach ($tickets as $index => $ticket) {
        $label = trim($ticket['label'] ?? '');
        $price = $ticket['price'] ?? null;
        $currency = trim($ticket['currency'] ?? 'EUR');
        $notes = trim($ticket['notes'] ?? '');
        if ($label === '' || $price === null || $price === '') {
            $pdo->rollBack();
            echo json_encode(['success' => false, 'message' => 'Ticketdaten ungueltig.']);
            exit;
        }

        $ticketStmt->execute([
            'event_id' => $eventId,
            'label' => $label,
            'price' => (float)$price,
            'currency' => $currency !== '' ? $currency : 'EUR',
            'notes' => $notes !== '' ? $notes : null,
            'sort_order' => (int)$index,
        ]);
    }

    $limitStmt = $pdo->prepare('INSERT INTO field_event_power_limits (event_id, class_name, limit_value, distance, requirement, sort_order) VALUES (:event_id, :class_name, :limit_value, :distance, :requirement, :sort_order)');
    foreach ($powerLimits as $index => $limit) {
        $className = trim($limit['class_name'] ?? '');
        $limitValue = trim($limit['limit_value'] ?? '');
        $distance = trim($limit['distance'] ?? '');
        $requirement = trim($limit['requirement'] ?? '');
        if ($className === '' || $distance === '' || $requirement === '') {
            $pdo->rollBack();
            echo json_encode(['success' => false, 'message' => 'Limitdaten ungueltig.']);
            exit;
        }

        $limitStmt->execute([
            'event_id' => $eventId,
            'class_name' => $className,
            'limit_value' => $limitValue,
            'distance' => $distance,
            'requirement' => $requirement,
            'sort_order' => (int)$index,
        ]);
    }

    $pdo->commit();
    echo json_encode(['success' => true, 'message' => 'Event erstellt.', 'id' => $eventId]);
} catch (PDOException $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
