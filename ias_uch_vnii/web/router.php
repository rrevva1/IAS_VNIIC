<?php
/**
 * Router script для встроенного PHP сервера разработки
 * Используется для правильной маршрутизации запросов в Yii2
 */

// Если запрашивается существующий файл или директория, отдаем его напрямую
if (php_sapi_name() === 'cli-server') {
    $path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
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

