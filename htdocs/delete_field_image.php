<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

$id = $_POST['id'] ?? null;
if (!$id) {
    echo json_encode(['success' => false, 'message' => 'id fehlt.']);
    exit;
}

try {
    $select = $pdo->prepare('SELECT image_url FROM field_images WHERE id = :id');
    $select->execute(['id' => (int)$id]);
    $image = $select->fetch(PDO::FETCH_ASSOC);

    $stmt = $pdo->prepare('DELETE FROM field_images WHERE id = :id');
    $stmt->execute(['id' => (int)$id]);

    if ($stmt->rowCount() > 0) {
        if (!empty($image['image_url'])) {
            $url = $image['image_url'];
            $path = parse_url($url, PHP_URL_PATH) ?: $url;
            if ($path !== '' && $path[0] !== '/') {
                $path = '/' . $path;
            }
            if (strpos($path, '/IMAGES/FIELD/') !== false || strpos($path, '/uploads/field_images/') !== false) {
                $fullPath = rtrim($_SERVER['DOCUMENT_ROOT'] ?? '', '/') . $path;
                if (is_file($fullPath)) {
                    @unlink($fullPath);
                }
            }
        }
        echo json_encode(['success' => true, 'message' => 'Bild gelöscht.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Bild nicht gefunden.']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
