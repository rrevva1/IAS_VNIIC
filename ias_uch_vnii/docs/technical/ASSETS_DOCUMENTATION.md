# Документация по Asset классам для задач

## Обзор

Все CSS и JavaScript код для страниц задач был вынесен в отдельные файлы и организован через Asset Bundle классы Yii2. Это обеспечивает:

- Разделение логики и представления
- Кэширование и минификацию ресурсов
- Управление зависимостями
- Лучшую производительность

## Структура файлов

### CSS файлы
- `web/css/tasks-view.css` - стили для страницы просмотра заявки
- `web/css/tasks-form.css` - стили для форм создания/редактирования
- `web/css/tasks-index.css` - стили для списка заявок

### JavaScript файлы
- `web/js/tasks-view.js` - функциональность страницы просмотра
- `web/js/tasks-form.js` - функциональность форм
- `web/js/tasks-index.js` - функциональность списка

### Asset классы
- `assets/TasksAsset.php` - основной Asset для всех страниц задач
- `assets/TasksIndexAsset.php` - специализированный Asset для списка

## Использование

### В контроллере или view файле

```php
<?php
use app\assets\TasksAsset;

// Подключение основного Asset (включает все CSS/JS)
TasksAsset::register($this);

// Или подключение специализированного Asset только для списка
use app\assets\TasksIndexAsset;
TasksIndexAsset::register($this);
?>
```

### Пример использования в view файле

```php
<?php
use yii\helpers\Html;
use app\assets\TasksAsset;

/* @var $this yii\web\View */
/* @var $model app\models\Tasks */

$this->title = 'Заявка #' . $model->id;

// Подключение Asset bundle
TasksAsset::register($this);
?>

<div class="tasks-view">
    <!-- HTML контент -->
</div>
```

## Функциональность

### TasksView (просмотр заявки)
- Быстрое изменение статуса через AJAX
- Назначение исполнителя
- Модальное окно для просмотра изображений
- Уведомления об успехе/ошибках
- Анимации и эффекты

### TasksForm (формы)
- Drag & Drop загрузка файлов
- Валидация в реальном времени
- Автосохранение черновиков
- Предварительный просмотр файлов
- Прогресс-бар загрузки

### TasksIndex (список)
- Фильтрация и поиск
- Массовые операции
- Сортировка таблицы
- Автообновление
- Статистика

## CSS классы

### Основные классы
- `.tasks-view` - контейнер страницы просмотра
- `.tasks-form` - контейнер форм
- `.tasks-index` - контейнер списка

### Компоненты
- `.attachment-card` - карточка вложения
- `.status-badge` - бейдж статуса
- `.file-upload-area` - область загрузки файлов
- `.search-panel` - панель поиска

### Модификаторы
- `.hover-effect` - эффект при наведении
- `.loading` - состояние загрузки
- `.has-error` - ошибка валидации

## JavaScript API

### Основные функции
- `initTasksView()` - инициализация страницы просмотра
- `initTasksForm()` - инициализация форм
- `initTasksIndex()` - инициализация списка

### Утилиты
- `showNotification(message, type)` - показ уведомлений
- `validateFile(file)` - валидация файла
- `formatFileSize(bytes)` - форматирование размера файла

## Зависимости

### CSS зависимости
- Bootstrap 5 (включен в AppAsset)
- Font Awesome (для иконок)

### JavaScript зависимости
- jQuery (включен в JqueryAsset)
- Bootstrap 5 JavaScript
- Yii2 JavaScript

## Кастомизация

### Добавление новых стилей
1. Добавьте CSS в соответствующий файл
2. Используйте префикс для избежания конфликтов
3. Следуйте BEM методологии

### Добавление новой функциональности
1. Добавьте JavaScript в соответствующий файл
2. Используйте модульный подход
3. Добавьте обработчики событий

### Создание нового Asset
```php
<?php
namespace app\assets;

use yii\web\AssetBundle;

class CustomTasksAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    
    public $css = [
        'css/custom-tasks.css',
    ];
    
    public $js = [
        'js/custom-tasks.js',
    ];
    
    public $depends = [
        'app\assets\TasksAsset', // Наследование от основного
    ];
}
```

## Производительность

### Оптимизация
- Файлы объединены в один Asset
- Минификация в продакшене
- Кэширование браузером
- Ленивая загрузка при необходимости

### Рекомендации
- Используйте специализированные Asset для конкретных страниц
- Не подключайте ненужные зависимости
- Оптимизируйте изображения
- Используйте CDN для библиотек

## Отладка

### Включение отладки
```php
// В конфигурации
'components' => [
    'assetManager' => [
        'forceCopy' => true, // Принудительное копирование в dev
    ],
],
```

### Проверка загрузки
- Откройте DevTools
- Проверьте вкладку Network
- Убедитесь в загрузке CSS/JS файлов
- Проверьте отсутствие ошибок в Console

## Миграция

### Из старого кода
1. Удалите встроенные `<style>` и `<script>` теги
2. Замените на `TasksAsset::register($this)`
3. Замените inline стили на CSS классы
4. Перенесите JavaScript в отдельные файлы

### Пример миграции
```php
// Было
$this->registerCssFile('@web/css/tasks-view.css');
$this->registerJsFile('@web/js/tasks-view.js');

// Стало
TasksAsset::register($this);
```
