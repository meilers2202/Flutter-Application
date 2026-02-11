<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

$id = $_POST['id'] ?? null;
$name = trim($_POST['name'] ?? '');
$price = trim($_POST['price'] ?? '');
$currency = trim($_POST['currency'] ?? 'EUR');
$description = trim($_POST['description'] ?? '');
$playTime = trim($_POST['play_time'] ?? '');
$ageRating = trim($_POST['age_rating'] ?? '');
$notes = trim($_POST['notes'] ?? '');
$areasJson = $_POST['areas'] ?? null;

if (!$id || $name === '' || $price === '') {
    echo json_encode(['success' => false, 'message' => 'Pflichtfelder fehlen (id, name, price).']);
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
    $stmt = $pdo->prepare('UPDATE field_pricing_packages SET name = :name, price = :price, currency = :currency, description = :description, play_time = :play_time, age_rating = :age_rating, notes = :notes, areas_json = :areas_json WHERE id = :id');
    $stmt->execute([
        'name' => $name,
        'price' => (float)$price,
        'currency' => $currency !== '' ? $currency : 'EUR',
        'description' => $description !== '' ? $description : null,
        'play_time' => $playTime !== '' ? $playTime : null,
        'age_rating' => $ageRating !== '' ? $ageRating : null,
        'notes' => $notes !== '' ? $notes : null,
        'areas_json' => !empty($areas) ? json_encode($areas, JSON_UNESCAPED_UNICODE) : null,
        'id' => (int)$id,
    ]);

    echo json_encode(['success' => true, 'message' => 'Paket aktualisiert.']);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
