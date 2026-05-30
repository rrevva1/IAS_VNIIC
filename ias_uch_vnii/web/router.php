<?php
/**
 * Router script для встроенного PHP сервера разработки
 * Используется для правильной маршрутизации запросов в Yii2
 */

// Если запрашивается существующий файл или директория, отдаем его напрямую
if (php_sapi_name() === 'cli-server') {
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/';

    // Вложения не отдаются статикой — только через контроллер с проверкой прав
    if (preg_match('#^/uploads(/|$)#', $path)) {
        http_response_code(403);
        header('Content-Type: text/plain; charset=UTF-8');
        echo 'Forbidden';
        return true;
    }

    $file = __DIR__ . $path;

    // Если файл существует и это не PHP файл, отдаем его напрямую
    if ($path !== '/' && file_exists($file) && !is_dir($file)) {
        return false;
    }
}

// Все остальные запросы направляем на index.php
$_SERVER['SCRIPT_NAME'] = '/index.php';
$_SERVER['SCRIPT_FILENAME'] = __DIR__ . '/index.php';

require __DIR__ . '/index.php';

