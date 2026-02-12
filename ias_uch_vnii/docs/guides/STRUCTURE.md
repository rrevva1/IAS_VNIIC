# Структура проекта IAS UCH VNII

Данный документ описывает организацию файлов и папок проекта.

## Структура директорий

```
/var/www/ias_uch_vnii/
├── assets/                    # Asset bundles (PHP классы для управления JS/CSS)
│   ├── AgGridAsset.php
│   ├── AgGridCoreAsset.php
│   ├── AgGridThemeAsset.php
│   ├── AppAsset.php
│   ├── LayoutAsset.php
│   ├── SiteAsset.php
│   ├── StatisticsAsset.php
│   ├── TasksAsset.php
│   ├── TasksIndexAsset.php
│   └── UsersAsset.php
│
├── commands/                  # Консольные команды (CLI)
│   └── HelloController.php
│
├── components/                # Переиспользуемые компоненты приложения
│   └── .gitkeep
│
├── config/                    # Конфигурационные файлы
│   ├── console.php
│   ├── db.php
│   ├── params.php
│   ├── test.php
│   ├── test_db.php
│   └── web.php
│
├── controllers/               # Контроллеры (MVC)
│   ├── HelpDeskController.php
│   ├── SiteController.php
│   ├── TasksController.php
│   └── UsersController.php
│
├── docs/                      # Документация проекта
│   ├── README.md
│   ├── ASSETS_ARCHITECTURE.md
│   ├── ASSETS_DOCUMENTATION.md
│   ├── ОБНОВЛЕНИЕ_ГЛАВНОЙ_СТРАНИЦЫ_ЗАЯВОК.md
│   ├── ОБНОВЛЕНИЕ_ПОЛЬЗОВАТЕЛЬСКОЙ_СТРАНИЦЫ.md
│   ├── ОБНОВЛЕНИЕ_СТИЛЯ_АДМИНИСТРАТИВНЫХ_ФОРМ.md
│   ├── ОТЧЕТ_РЕФАКТОРИНГ_VIEW_PHP.md
│   ├── ПРОЕКТ_ОТЧЕТ.md
│   ├── ФУНКЦИОНАЛЬНОСТЬ_ЗАГРУЗКИ_ФАЙЛОВ.md
│   └── ШПАРГАЛКА.md
│
├── mail/                      # Email-шаблоны
│
├── migrations/                # Миграции базы данных
│
├── models/                    # Модели данных (разделены по типам)
│   ├── dictionaries/          # Справочники
│   │   ├── DicTaskStatus.php
│   │   └── Roles.php
│   ├── entities/              # Основные сущности (ActiveRecord)
│   │   ├── DeskAttachments.php
│   │   ├── Tasks.php
│   │   └── Users.php
│   ├── forms/                 # Формы (не связанные с БД)
│   │   ├── ContactForm.php
│   │   └── LoginForm.php
│   └── search/                # Модели для поиска
│       ├── TasksSearch.php
│       └── UsersSearch.php
│
├── runtime/                   # Временные файлы (кеш, логи)
│
├── services/                  # Бизнес-логика
│   └── .gitkeep
│
├── tests/                     # Тесты
│   └── unit/
│       └── models/
│
├── vendor/                    # Зависимости Composer
│
├── views/                     # Представления (View)
│   ├── layouts/
│   ├── site/
│   ├── tasks/
│   └── users/
│
├── web/                       # Публичная директория (доступна из браузера)
│   ├── assets/               # Скомпилированные asset-файлы (генерируются автоматически)
│   ├── css/                  # CSS файлы
│   ├── js/                   # JavaScript файлы
│   ├── uploads/              # Загруженные пользователями файлы
│   ├── ag-grid-community/    # Библиотека AG Grid
│   ├── ag-charts-types/      # Типы для AG Charts
│   ├── favicon.ico
│   └── index.php             # Точка входа
│
├── widgets/                   # Виджеты
│   └── Alert.php
│
├── composer.json              # Зависимости PHP (Composer)
├── package.json               # Зависимости JavaScript (npm)
├── README.md                  # Основной README проекта
├── STRUCTURE.md               # Этот файл - описание структуры
└── yii                        # CLI-скрипт для консольных команд
```

## Соглашения об именовании

### Модели

- **entities/** - Основные модели-сущности, работающие с БД (ActiveRecord)
  - Пример: `Tasks`, `Users`, `DeskAttachments`
  
- **forms/** - Модели форм, не связанные напрямую с таблицами БД
  - Пример: `LoginForm`, `ContactForm`
  
- **search/** - Модели для поиска и фильтрации
  - Пример: `TasksSearch`, `UsersSearch`
  - Наследуются от соответствующих entity-моделей
  
- **dictionaries/** - Справочники и словари
  - Пример: `DicTaskStatus`, `Roles`

### Namespace

```php
// Entities
namespace app\models\entities;

// Forms
namespace app\models\forms;

// Search models
namespace app\models\search;

// Dictionaries
namespace app\models\dictionaries;
```

### Импорты в контроллерах

```php
use app\models\entities\Tasks;
use app\models\entities\Users;
use app\models\search\TasksSearch;
use app\models\forms\LoginForm;
use app\models\dictionaries\DicTaskStatus;
```

## Основные принципы организации

1. **Разделение ответственности** - каждая папка имеет четкое назначение
2. **Модульность** - код организован так, чтобы легко находить нужные компоненты
3. **Безопасность** - публичная папка `/web/` содержит только необходимые файлы
4. **Масштабируемость** - структура позволяет легко добавлять новые модули

## Важные замечания

- Папка `/web/` - единственная публично доступная директория
- Папки `/runtime/` и `/web/assets/` генерируются автоматически
- Все sensitive-данные (пароли, ключи) хранятся в `/config/` и исключены из Git
- Документация проекта находится в `/docs/`

---

Последнее обновление структуры: октябрь 2025

