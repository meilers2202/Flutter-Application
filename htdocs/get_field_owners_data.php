<?php
require_once 'db_service.php'; // enthält $pdo
header('Content-Type: application/json; charset=utf-8');

set_error_handler(function ($severity, $message, $file, $line) {
    throw new ErrorException($message, 0, $severity, $file, $line);
});

try {
    $stmt = $pdo->prepare("SELECT user_id, name FROM fieldowner");
    $stmt->execute();
    $owners = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (!empty($owners)) {
        echo json_encode([
            'success' => true,
            'message' => 'Fieldowner erfolgreich abgerufen.',
            'users' => $owners,
        ]);
        exit;
    }

    echo json_encode([
        'success' => false,
        'message' => 'Keine Fieldowner gefunden.',
        'users' => [],
    ]);
    exit;
} catch (Throwable $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Serverfehler: ' . $e->getMessage(),
        'users' => [],
    ]);
    exit;
} finally {
    restore_error_handler();
}
