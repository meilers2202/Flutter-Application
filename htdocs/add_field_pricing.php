<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

$fieldId = $_POST['field_id'] ?? null;
$name = trim($_POST['name'] ?? '');
$price = trim($_POST['price'] ?? '');
$currency = trim($_POST['currency'] ?? 'EUR');
$description = trim($_POST['description'] ?? '');
$playTime = trim($_POST['play_time'] ?? '');
$ageRating = trim($_POST['age_rating'] ?? '');
$notes = trim($_POST['notes'] ?? '');
$areasJson = $_POST['areas'] ?? null;

if (!$fieldId || $name === '' || $price === '') {
    echo json_encode(['success' => false, 'message' => 'Pflichtfelder fehlen (field_id, name, price).']);
    exit;
}

$areas = [];
if ($areasJson !== null && $areasJson !== '') {
    $areas = json_decode($areasJson, true);
    if (!is_array($areas)) {
        echo json_encode(['success' => false, 'message' => 'Bereiche ungueltig.']);
        exit;
    }
}

try {
    $stmt = $pdo->prepare('INSERT INTO field_pricing_packages (field_id, name, price, currency, description, play_time, age_rating, notes, areas_json) VALUES (:field_id, :name, :price, :currency, :description, :play_time, :age_rating, :notes, :areas_json)');
    $ok = $stmt->execute([
        'field_id' => (int)$fieldId,
        'name' => $name,
        'price' => (float)$price,
        'currency' => $currency !== '' ? $currency : 'EUR',
        'description' => $description !== '' ? $description : null,
        'play_time' => $playTime !== '' ? $playTime : null,
        'age_rating' => $ageRating !== '' ? $ageRating : null,
        'notes' => $notes !== '' ? $notes : null,
        'areas_json' => !empty($areas) ? json_encode($areas, JSON_UNESCAPED_UNICODE) : null,
    ]);

    if (!$ok) {
        echo json_encode(['success' => false, 'message' => 'Paket konnte nicht erstellt werden.']);
        exit;
    }

    echo json_encode(['success' => true, 'message' => 'Paket erstellt.', 'id' => (int)$pdo->lastInsertId()]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
