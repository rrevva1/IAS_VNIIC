# Руководство по миграции namespace после рефакторинга

## Проблема

После реорганизации моделей по подпапкам могут возникать ошибки типа:
```
Class "app\models\Users" not found
```

## Решение

### 1. В контроллерах и моделях

Обновите `use` statements в начале файла:

```php
// ❌ СТАРОЕ (не работает)
use app\models\Tasks;
use app\models\Users;
use app\models\TasksSearch;
use app\models\LoginForm;
use app\models\DicTaskStatus;
use app\models\Roles;

// ✅ НОВОЕ (правильно)
use app\models\entities\Tasks;
use app\models\entities\Users;
use app\models\search\TasksSearch;
use app\models\forms\LoginForm;
use app\models\dictionaries\DicTaskStatus;
use app\models\dictionaries\Roles;
```

### 2. В view-файлах (PHP блоки)

#### Вариант A: Добавить use в начало файла
```php
<?php
use yii\helpers\Html;
use app\models\entities\Users;
use app\models\dictionaries\DicTaskStatus;
?>
```

#### Вариант B: Использовать полный namespace inline
```php
// ❌ СТАРОЕ
$users = \app\models\Users::find()->all();
$statuses = \app\models\DicTaskStatus::getStatusList();

// ✅ НОВОЕ
$users = \app\models\entities\Users::find()->all();
$statuses = \app\models\dictionaries\DicTaskStatus::getStatusList();
```

### 3. В конфигурации (config/web.php)

```php
// ❌ СТАРОЕ
'user' => [
    'identityClass' => 'app\models\Users',
    // ...
],

// ✅ НОВОЕ
'user' => [
    'identityClass' => 'app\models\entities\Users',
    // ...
],
```

### 4. В миграциях

```php
// ❌ СТАРОЕ
use app\models\Users;
use app\models\Roles;

// ✅ НОВОЕ
use app\models\entities\Users;
use app\models\dictionaries\Roles;
```

## Таблица соответствия

| Старый namespace | Новый namespace | Тип |
|------------------|-----------------|-----|
| `app\models\Tasks` | `app\models\entities\Tasks` | Entity |
| `app\models\Users` | `app\models\entities\Users` | Entity |
| `app\models\DeskAttachments` | `app\models\entities\DeskAttachments` | Entity |
| `app\models\LoginForm` | `app\models\forms\LoginForm` | Form |
| `app\models\ContactForm` | `app\models\forms\ContactForm` | Form |
| `app\models\TasksSearch` | `app\models\search\TasksSearch` | Search |
| `app\models\UsersSearch` | `app\models\search\UsersSearch` | Search |
| `app\models\DicTaskStatus` | `app\models\dictionaries\DicTaskStatus` | Dictionary |
| `app\models\Roles` | `app\models\dictionaries\Roles` | Dictionary |

## Поиск проблемных мест

Используйте grep для поиска всех мест с старыми импортами:

```bash
# Поиск use statements со старыми namespace
grep -r "use app\\models\\Users" views/ controllers/

# Поиск inline вызовов
grep -r "\\app\\models\\Users" views/
```

## Быстрое исправление через find + sed

```bash
# Замена в view-файлах (осторожно, проверьте перед запуском!)
find views/ -type f -name "*.php" -exec sed -i 's/\\app\\models\\Users/\\app\\models\\entities\\Users/g' {} +
find views/ -type f -name "*.php" -exec sed -i 's/\\app\\models\\Tasks/\\app\\models\\entities\\Tasks/g' {} +
find views/ -type f -name "*.php" -exec sed -i 's/\\app\\models\\DicTaskStatus/\\app\\models\\dictionaries\\DicTaskStatus/g' {} +
find views/ -type f -name "*.php" -exec sed -i 's/\\app\\models\\Roles/\\app\\models\\dictionaries\\Roles/g' {} +
```

## Проверка после исправлений

1. **Линтер**
```bash
# Через PHP (если установлен phpcs)
phpcs --standard=PSR12 models/ controllers/
```

2. **Попробовать открыть проблемные страницы**
- `/tasks/index-aggrid`
- `/tasks/index`
- `/users/index`

3. **Проверить логи Yii**
```bash
tail -f runtime/logs/app.log
```

## Профилактика

При создании новых файлов сразу используйте правильные namespace:

```php
<?php
// В новом контроллере
namespace app\controllers;

use app\models\entities\MyNewModel;      // Entity
use app\models\forms\MyNewForm;          // Form  
use app\models\search\MyNewSearch;       // Search
use app\models\dictionaries\MyNewDict;   // Dictionary
```

## Дополнительная информация

- Подробная структура проекта: `/STRUCTURE.md`
- Отчет о рефакторинге: `/docs/РЕФАКТОРИНГ_СТРУКТУРЫ_ПРОЕКТА.md`
- Быстрый старт: `/QUICKSTART.md`

---

*Документ создан: 31 октября 2025*  
*Версия: 1.0*

