<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

$id = $_POST['id'] ?? null;
$title = trim($_POST['title'] ?? '');
$startAt = trim($_POST['start_at'] ?? '');
$endAt = trim($_POST['end_at'] ?? '');
$description = trim($_POST['description'] ?? '');
$location = trim($_POST['location'] ?? '');
$locationStreet = trim($_POST['location_street'] ?? '');
$locationHouseNumber = trim($_POST['location_house_number'] ?? '');
$locationPostalcode = trim($_POST['location_postalcode'] ?? '');
$locationCity = trim($_POST['location_city'] ?? '');
$locationState = trim($_POST['location_state'] ?? '');
$locationCountry = trim($_POST['location_country'] ?? '');
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
$status = $_POST['status'] ?? null;

if (!$id || $title === '' || $startAt === '') {
    echo json_encode(['success' => false, 'message' => 'id, title oder start_at fehlt.']);
    exit;
}

try {
    $pdo->beginTransaction();

    if ($location === '') {
        $parts = [];
        $line1 = trim($locationStreet . ' ' . $locationHouseNumber);
        $line2 = trim($locationPostalcode . ' ' . $locationCity);
        if ($line1 !== '') $parts[] = $line1;
        if ($line2 !== '') $parts[] = $line2;
        if ($locationState !== '') $parts[] = $locationState;
        if ($locationCountry !== '') $parts[] = $locationCountry;
        $location = implode(', ', $parts);
    }

    $stmt = $pdo->prepare('UPDATE field_events SET title = :title, start_at = :start_at, end_at = :end_at, description = :description, status = :status, location = :location, location_street = :location_street, location_house_number = :location_house_number, location_postalcode = :location_postalcode, location_city = :location_city, location_state = :location_state, location_country = :location_country, location_lat = :location_lat, location_lng = :location_lng, scenario = :scenario, organizer = :organizer, min_age = :min_age, required_gear = :required_gear, chrono_at = :chrono_at, briefing_at = :briefing_at, medic_contact = :medic_contact WHERE id = :id');
    $stmt->execute([
        'title' => $title,
        'start_at' => $startAt,
        'end_at' => $endAt ?: null,
        'description' => $description,
        'status' => $status ?: 'active',
        'location' => $location !== '' ? $location : null,
        'location_street' => $locationStreet !== '' ? $locationStreet : null,
        'location_house_number' => $locationHouseNumber !== '' ? $locationHouseNumber : null,
        'location_postalcode' => $locationPostalcode !== '' ? $locationPostalcode : null,
        'location_city' => $locationCity !== '' ? $locationCity : null,
        'location_state' => $locationState !== '' ? $locationState : null,
        'location_country' => $locationCountry !== '' ? $locationCountry : null,
        'location_lat' => $locationLat !== '' ? (float)$locationLat : null,
        'location_lng' => $locationLng !== '' ? (float)$locationLng : null,
        'scenario' => $scenario !== '' ? $scenario : null,
        'organizer' => $organizer !== '' ? $organizer : null,
        'min_age' => $minAge !== '' ? (int)$minAge : null,
        'required_gear' => $requiredGear !== '' ? $requiredGear : null,
        'chrono_at' => $chronoAt !== '' ? $chronoAt : null,
        'briefing_at' => $briefingAt !== '' ? $briefingAt : null,
        'medic_contact' => $medicContact !== '' ? $medicContact : null,
        'id' => (int)$id,
    ]);

    if ($ticketsJson !== null) {
        $tickets = json_decode($ticketsJson, true);
        if (!is_array($tickets)) {
            $pdo->rollBack();
            echo json_encode(['success' => false, 'message' => 'Ticketdaten ungueltig.']);
            exit;
        }

        $del = $pdo->prepare('DELETE FROM field_event_tickets WHERE event_id = :event_id');
        $del->execute(['event_id' => (int)$id]);

        if (count($tickets) > 0) {
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
                    'event_id' => (int)$id,
                    'label' => $label,
                    'price' => (float)$price,
                    'currency' => $currency !== '' ? $currency : 'EUR',
                    'notes' => $notes !== '' ? $notes : null,
                    'sort_order' => (int)$index,
                ]);
            }
        }
    }

    if ($powerLimitsJson !== null) {
        $powerLimits = json_decode($powerLimitsJson, true);
        if (!is_array($powerLimits) || count($powerLimits) === 0) {
            $pdo->rollBack();
            echo json_encode(['success' => false, 'message' => 'Mindestens ein Limit ist erforderlich.']);
            exit;
        }

        $delLimits = $pdo->prepare('DELETE FROM field_event_power_limits WHERE event_id = :event_id');
        $delLimits->execute(['event_id' => (int)$id]);

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
                'event_id' => (int)$id,
                'class_name' => $className,
                'limit_value' => $limitValue,
                'distance' => $distance,
                'requirement' => $requirement,
                'sort_order' => (int)$index,
            ]);
        }
    }

    $pdo->commit();
    echo json_encode(['success' => true, 'message' => 'Event aktualisiert.']);
} catch (PDOException $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
