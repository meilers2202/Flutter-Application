<?php
require_once 'db_service.php';
header('Content-Type: application/json; charset=utf-8');

// add_field_image.php – Upload fuer Feldbilder (Datei oder URL)
// Hinweis: Bevorzugt Datei-Upload, URL ist nur Fallback.

$fieldId = $_POST['field_id'] ?? null;
$imageUrl = $_POST['image_url'] ?? null;
$upload = $_FILES['image'] ?? null;
$sortOrder = isset($_POST['sort_order']) ? (int)$_POST['sort_order'] : 0;
$isCover = isset($_POST['is_cover']) && $_POST['is_cover'] === '1';

if (!$fieldId) {
    echo json_encode(['success' => false, 'message' => 'field_id fehlt.']);
    exit;
}

if ($upload && $upload['error'] === UPLOAD_ERR_OK) {
    $maxSize = 8 * 1024 * 1024; // 8 MB
    if ($upload['size'] > $maxSize) {
        echo json_encode(['success' => false, 'message' => 'Datei darf maximal 8 MB gross sein.']);
        exit;
    }

    $allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mime = finfo_file($finfo, $upload['tmp_name']);
    finfo_close($finfo);
    if (!in_array($mime, $allowedTypes, true)) {
        echo json_encode(['success' => false, 'message' => 'Ungueltiger Bildtyp.']);
        exit;
    }

    $ext = strtolower(pathinfo($upload['name'], PATHINFO_EXTENSION));
    if ($ext === '') {
        $ext = $mime === 'image/png' ? 'png' : ($mime === 'image/webp' ? 'webp' : ($mime === 'image/gif' ? 'gif' : 'jpg'));
    }

    $targetDir = __DIR__ . '/IMAGES/FIELD/' . (int)$fieldId . '/';
    if (!is_dir($targetDir)) {
        mkdir($targetDir, 0755, true);
    }

    $safeName = 'FIELD_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . $ext;
    $targetPath = $targetDir . $safeName;
    if (!move_uploaded_file($upload['tmp_name'], $targetPath)) {
        echo json_encode(['success' => false, 'message' => 'Upload fehlgeschlagen.']);
        exit;
    }

    chmod($targetPath, 0644);
    $imageUrl = 'IMAGES/FIELD/' . (int)$fieldId . '/' . $safeName;
}

if (!$imageUrl) {
    echo json_encode(['success' => false, 'message' => 'image_url oder Upload fehlt.']);
    exit;
}

try {
    $pdo->beginTransaction();

    if ($isCover) {
        $reset = $pdo->prepare('UPDATE field_images SET is_cover = 0 WHERE field_id = :field_id');
        $reset->execute(['field_id' => (int)$fieldId]);
    }

    $stmt = $pdo->prepare('INSERT INTO field_images (field_id, image_url, sort_order, is_cover) VALUES (:field_id, :image_url, :sort_order, :is_cover)');
    $ok = $stmt->execute([
        'field_id' => (int)$fieldId,
        'image_url' => $imageUrl,
        'sort_order' => $sortOrder,
        'is_cover' => $isCover ? 1 : 0,
    ]);

    $pdo->commit();

    if ($ok) {
        echo json_encode(['success' => true, 'message' => 'Bild hinzugefügt.', 'id' => (int)$pdo->lastInsertId()]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Bild konnte nicht hinzugefügt werden.']);
    }
} catch (PDOException $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    echo json_encode(['success' => false, 'message' => 'Fehler: ' . $e->getMessage()]);
}
