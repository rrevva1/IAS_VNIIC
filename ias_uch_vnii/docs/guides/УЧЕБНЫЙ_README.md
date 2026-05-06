# Учебный README - Система Help Desk (IAS UCH VNII)

## 📋 Описание проекта

Система управления заявками Help Desk, разработанная на базе Yii2 Framework. Проект предназначен для организации процесса обработки заявок пользователей с возможностью отслеживания статусов, назначения исполнителей и ведения статистики.

## 🎯 Основные возможности

### Для пользователей:
- 📝 Создание новых заявок с описанием проблемы
- 📎 Прикрепление файлов к заявкам (множественная загрузка)
- 👁️ Просмотр своих заявок и их статусов
- 💬 Добавление комментариев к заявкам

### Для администраторов:
- 📊 Просмотр всех заявок в системе с фильтрацией
- ✏️ Редактирование заявок и изменение их статусов
- 👤 Назначение исполнителей на заявки
- 📈 Просмотр статистики по заявкам
- 📥 Экспорт данных в Excel
- 🔄 Массовые операции с заявками

## 🏗️ Архитектура проекта

### Полная структура директорий

```
/var/www/ias_uch_vnii/
├── assets/                     # Asset Bundle классы для управления CSS/JS
│   ├── AgGridAsset.php         # AG Grid assets (библиотека таблиц с темой Quartz)
│   ├── AppAsset.php            # Базовые assets приложения
│   ├── LayoutAsset.php         # Assets для layout шаблонов
│   ├── SiteAsset.php           # Assets для страниц сайта
│   ├── StatisticsAsset.php     # Assets для страницы статистики
│   ├── TasksAsset.php          # Assets для страниц задач
│   ├── TasksIndexAsset.php     # Assets для списка задач
│   └── UsersAsset.php          # Assets для страниц пользователей
│
├── commands/                   # Console команды для CLI
├── components/                 # Компоненты приложения
│
├── config/                     # Конфигурационные файлы
│   ├── __autocomplete.php      # Автодополнение для IDE
│   ├── console.php             # Конфигурация консольного приложения
│   ├── db.php                  # Настройки подключения к БД
│   ├── params.php              # Параметры приложения
│   ├── test.php                # Конфигурация для тестирования
│   ├── test_db.php             # БД для тестирования
│   └── web.php                 # Основная конфигурация веб-приложения
│
├── controllers/                # Контроллеры (обработка запросов)
│   ├── HelpDeskController.php  # Контроллер Help Desk
│   ├── SiteController.php      # Главный контроллер сайта
│   ├── TasksController.php     # Контроллер управления заявками
│   └── UsersController.php     # Контроллер управления пользователями
│
├── models/                     # Модели данных
│   ├── dictionaries/           # Справочники и словари
│   │   ├── DicTaskStatus.php   # Справочник статусов задач
│   │   └── Roles.php           # Справочник ролей пользователей
│   │
│   ├── entities/               # Entity модели (сущности БД)
│   │   ├── DeskAttachments.php # Модель вложений к задачам
│   │   ├── Tasks.php           # Модель задач/заявок
│   │   └── Users.php           # Модель пользователей
│   │
│   ├── forms/                  # Модели форм
│   │   ├── LoginForm.php       # Форма авторизации
│   │   └── ContactForm.php     # Форма обратной связи
│   │
│   └── search/                 # Search модели для GridView
│       ├── TasksSearch.php     # Модель поиска задач
│       └── UsersSearch.php     # Модель поиска пользователей
│
├── migrations/                 # Миграции базы данных
│
├── services/                   # Сервисный слой (бизнес-логика)
│
├── views/                      # Представления (View layer)
│   ├── layouts/                # Шаблоны макетов
│   │   ├── main.php            # Главный layout
│   │   └── ...
│   │
│   ├── site/                   # Страницы сайта
│   │   ├── index.php           # Главная страница
│   │   ├── login.php           # Страница авторизации
│   │   ├── about.php           # Страница "О нас"
│   │   └── ...
│   │
│   ├── tasks/                  # Страницы управления заявками
│   │   ├── index.php           # Список заявок (Kartik GridView)
│   │   ├── index.php    # Список заявок (AG Grid)
│   │   ├── view.php            # Просмотр одной заявки
│   │   ├── create.php          # Создание новой заявки
│   │   ├── update.php          # Редактирование заявки
│   │   ├── statistics.php      # Страница статистики
│   │   ├── _form.php           # Форма создания/редактирования
│   │   └── _search.php         # Форма поиска
│   │
│   └── users/                  # Страницы управления пользователями
│       ├── index.php           # Список пользователей
│       ├── view.php            # Просмотр пользователя
│       ├── create.php          # Создание пользователя
│       └── update.php          # Редактирование пользователя
│
├── web/                        # Публичная директория (DocumentRoot)
│   ├── assets/                 # Скомпилированные assets
│   │
│   ├── css/                    # CSS файлы
│   │   ├── common/             # Общие стили
│   │   │   └── site.css        # Базовые стили сайта
│   │   ├── site/               # Стили для страниц сайта
│   │   │   └── pages.css       # Стили общих страниц
│   │   ├── tasks/              # Стили для задач
│   │   │   ├── view.css        # Просмотр задачи
│   │   │   ├── form.css        # Форма задачи
│   │   │   ├── form-modal.css  # Модальная форма
│   │   │   ├── index.css       # Список задач
│   │   │   ├── statistics.css  # Страница статистики
│   │   │   └── ag-grid.css     # AG Grid для задач
│   │   └── users/              # Стили для пользователей
│   │       └── index.css       # Список пользователей
│   │
│   ├── js/                     # JavaScript файлы
│   │   ├── site/               # Скрипты для страниц сайта
│   │   │   └── pages.js        # Скрипты общих страниц
│   │   ├── tasks/              # Скрипты для задач
│   │   │   ├── view.js         # Просмотр задачи
│   │   │   ├── form.js         # Форма задачи
│   │   │   ├── form-modal.js   # Модальная форма
│   │   │   ├── index.js        # Список задач
│   │   │   ├── statistics.js   # Статистика
│   │   │   ├── ag-grid.js      # Конфигурация AG Grid
│   │   │   └── ag-grid-init.js # Инициализация AG Grid
│   │   └── users/              # Скрипты для пользователей
│   │       └── index.js        # Список пользователей
│   │
│   ├── uploads/                # Загруженные пользователями файлы
│   │   └── tasks/              # Файлы, прикрепленные к задачам
│   │
│   ├── ag-grid-community/      # Библиотека AG Grid (скопирована из node_modules)
│   │   ├── dist/               # JavaScript файлы
│   │   │   └── ag-grid-community.min.js
│   │   └── styles/             # CSS файлы
│   │       └── ag-theme-quartz.css
│   │
│   └── index.php               # Точка входа приложения
│
├── widgets/                    # Виджеты Yii2
├── runtime/                    # Временные файлы (логи, кэш)
├── tests/                      # Автоматические тесты
├── vendor/                     # Composer зависимости
├── node_modules/               # NPM зависимости (ag-grid-community)
│
├── composer.json               # Зависимости PHP
├── package.json                # Зависимости JavaScript
├── codeception.yml             # Конфигурация тестирования
├── (Docker: см. папку docker/ в корне проекта)
├── yii                         # Консольный скрипт Yii (Linux/Mac)
├── yii.bat                     # Консольный скрипт Yii (Windows)
│
├── docs/                       # Дополнительная документация
│   └── AGGRID_DATE_FILTER_REPORT.md  # Отчет о фильтре дат AG Grid
│
├── README.md                   # Основная документация
├── УЧЕБНЫЙ_README.md           # Учебная документация (этот файл)
├── QUICKSTART.md               # Быстрый старт
├── STRUCTURE.md                # Описание структуры проекта
├── ОТЧЕТ_КОСМЕТИКА_ПРОЕКТА.md  # Отчет о косметических изменениях
└── ОТЧЕТ_РЕОРГАНИЗАЦИЯ_ASSETS.md  # Отчет о реорганизации Assets
```

## 🛠️ Технологический стек

- **Backend Framework**: Yii2 Framework 2.0
- **Frontend**: 
  - Bootstrap 5
  - jQuery
  - AG Grid Community v34.3.1 (таблицы с расширенными возможностями, тема Quartz)
  - Highcharts (графики и диаграммы)
- **Database**: PostgreSQL 12+
- **PHP**: версия 7.4+
- **Node.js**: для установки AG Grid

## 📦 Установка и настройка

### Требования
- PHP 7.4 или выше
- PostgreSQL 12 или выше
- Composer
- Node.js и npm (для работы с AG Grid)

### Шаги установки

1. **Клонирование репозитория**
```bash
cd /var/www/
git clone [repository-url] ias_uch_vnii
cd ias_uch_vnii
```

2. **Установка зависимостей PHP**
```bash
composer install
```

3. **Установка Node.js зависимостей**
```bash
npm install

# AG Grid будет установлен в node_modules/
# Для использования в веб-приложении файлы нужно скопировать:
cp -r node_modules/ag-grid-community web/ag-grid-community
```

**Примечание**: Файлы AG Grid уже скопированы в `web/ag-grid-community/`, включая:
- `web/ag-grid-community/dist/ag-grid-community.min.js` - библиотека
- `web/ag-grid-community/styles/ag-theme-quartz.css` - тема Quartz

4. **Настройка базы данных**

Создайте базу данных и импортируйте схему:
```bash
# Подключение к PostgreSQL
psql -U postgres 

# Создание базы данных
CREATE DATABASE ias_vniic WITH ENCODING 'UTF8' TEMPLATE template0;
\q

# Импорт дампа
psql -U postgres -d ias_vniic -f ../db/IAS_VNIIC_dump.sql
```

5. **Конфигурация подключения к БД**

Отредактируйте файл `config/db.php`:
```php
return [
    'class' => 'yii\db\Connection',
    'dsn' => 'pgsql:host=localhost;dbname=ias_vniic',
    'username' => 'postgres',
    'password' => 'your_password',
    'charset' => 'utf8',
];
```

6. **Настройка прав доступа**
```bash
chmod -R 775 web/assets
chmod -R 775 web/uploads
chmod -R 775 runtime
```

7. **Запуск приложения**

Для разработки:
```bash
php yii serve --port=8080
```

Или настройте веб-сервер (Apache/Nginx) для работы с директорией `web/`.

## 🔐 Учетные записи по умолчанию

После импорта базы данных доступны следующие пользователи:

- **Администратор**: 
  - Логин: `admin`
  - Пароль: `admin123`
  
- **Обычный пользователь**:
  - Логин: `user`
  - Пароль: `user123`

**⚠️ Важно**: Обязательно смените пароли после первого входа!

## 📊 Детальное описание модулей и компонентов

---

## 🎮 КОНТРОЛЛЕРЫ (Controllers)

### 1. TasksController - Управление заявками
**Путь**: `controllers/TasksController.php`

Основной контроллер для работы с заявками Help Desk. Реализует полный CRUD функционал и дополнительные операции.

#### Публичные методы (Actions):

##### actionIndex()
```php
public function actionIndex(): string
```
Отображает список всех заявок с использованием Kartik GridView.
- **Возвращает**: HTML страницу со списком заявок
- **Особенности**: 
  - Поддержка фильтрации и сортировки
  - Пагинация (10 записей на страницу)
  - Обычные пользователи видят только свои заявки
  - Администраторы видят все заявки

##### actionIndexAggrid()
```php
public function actionIndexAggrid(): string
```
Отображает список заявок с использованием AG Grid (продвинутая таблица).
- **Возвращает**: HTML страницу с AG Grid
- **Особенности**: 
  - Серверная пагинация
  - Фильтрация по всем колонкам
  - Inline редактирование (для администраторов)
  - Экспорт в Excel/CSV

##### actionView($id)
```php
public function actionView(int $id): string
```
Отображает детальную информацию об одной заявке.
- **Параметры**: `$id` - ID заявки
- **Возвращает**: HTML страницу просмотра заявки
- **Исключения**: `NotFoundHttpException` если заявка не найдена

##### actionCreate()
```php
public function actionCreate(): string|Response
```
Создает новую заявку.
- **Возвращает**: HTML форму (GET) или редирект (POST)
- **Особенности**:
  - Автоматически устанавливает текущего пользователя как автора
  - Устанавливает статус по умолчанию
  - Поддерживает множественную загрузку файлов
  - Поддерживает AJAX запросы

##### actionCreateModal()
```php
public function actionCreateModal(): string|array
```
Создает новую заявку через модальное окно (AJAX).
- **Возвращает**: HTML форму (GET) или JSON ответ (POST)
- **Формат JSON ответа**:
```json
{
    "success": true,
    "message": "Заявка успешно создана!",
    "task_id": 123,
    "attachments_count": 2
}
```

##### actionUpdate($id)
```php
public function actionUpdate(int $id): string|Response
```
Обновляет существующую заявку.
- **Параметры**: `$id` - ID заявки
- **Возвращает**: HTML форму (GET) или редирект (POST)
- **Особенности**: Поддерживает добавление новых файлов

##### actionDelete($id)
```php
public function actionDelete(int $id): Response
```
Удаляет заявку и все связанные вложения.
- **Параметры**: `$id` - ID заявки
- **Возвращает**: Редирект на список заявок
- **HTTP метод**: POST

##### actionDeleteAttachment($taskId, $attachmentId)
```php
public function actionDeleteAttachment(int $taskId, int $attachmentId): Response
```
Удаляет вложение из заявки.
- **Параметры**: 
  - `$taskId` - ID заявки
  - `$attachmentId` - ID вложения
- **Возвращает**: Редирект на просмотр заявки

##### actionDownloadAttachment($attachmentId)
```php
public function actionDownloadAttachment(int $attachmentId): Response
```
Скачивание файла вложения.
- **Параметры**: `$attachmentId` - ID вложения
- **Возвращает**: Файл для скачивания
- **Исключения**: `NotFoundHttpException` если файл не найден

##### actionPreview($id)
```php
public function actionPreview(int $id): Response
```
Предпросмотр файла в браузере (изображения и PDF).
- **Параметры**: `$id` - ID вложения
- **Возвращает**: Файл с заголовком inline
- **Поддерживаемые форматы**: PDF, PNG, JPG, JPEG, GIF, BMP, SVG

##### actionDownload($id)
```php
public function actionDownload(int $id): Response
```
Скачивание файла вложения (альтернативный метод).
- **Параметры**: `$id` - ID вложения
- **Возвращает**: Файл для скачивания

##### actionChangeStatus($id)
```php
public function actionChangeStatus(int $id): array
```
Изменение статуса заявки через AJAX.
- **Параметры**: `$id` - ID заявки
- **HTTP метод**: POST
- **POST параметры**: `status_id` - новый ID статуса
- **Возвращает**: JSON ответ
```json
{
    "success": true,
    "message": "Статус успешно изменен.",
    "status_name": "Название статуса"
}
```

##### actionAssignExecutor($id)
```php
public function actionAssignExecutor(int $id): array
```
Назначение исполнителя заявке через AJAX.
- **Параметры**: `$id` - ID заявки
- **HTTP метод**: POST
- **POST параметры**: `executor_id` - ID исполнителя
- **Возвращает**: JSON ответ
```json
{
    "success": true,
    "message": "Исполнитель успешно назначен.",
    "executor_name": "ФИО исполнителя"
}
```

##### actionUpdateComment($id)
```php
public function actionUpdateComment(int $id): array
```
Обновление комментария заявки через AJAX.
- **Параметры**: `$id` - ID заявки
- **HTTP метод**: POST
- **POST параметры**: `comment` - текст комментария
- **Возвращает**: JSON ответ

##### actionStatistics()
```php
public function actionStatistics(): string
```
Отображает страницу статистики заявок.
- **Возвращает**: HTML страницу с графиками
- **Статистика включает**:
  - Количество заявок по пользователям
  - Количество завершенных заявок по исполнителям
  - Диаграммы Highcharts

##### actionGetGridData()
```php
public function actionGetGridData(): array
```
API endpoint для получения данных заявок в формате JSON для AG Grid.
- **Возвращает**: JSON массив с данными заявок
- **Формат ответа**:
```json
{
    "success": true,
    "data": [...],
    "total": 100
}
```

##### actionExportUserStats()
```php
public function actionExportUserStats(): void
```
Экспорт статистики по пользователям в Excel.
- **Возвращает**: XLSX файл
- **Содержимое**: Количество заявок по каждому пользователю с процентами

##### actionExportExecutorStats()
```php
public function actionExportExecutorStats(): void
```
Экспорт статистики по исполнителям в Excel.
- **Возвращает**: XLSX файл
- **Содержимое**: Количество завершенных заявок по исполнителям

#### Защищенные методы:

##### findModel($id)
```php
protected function findModel(int $id): Tasks
```
Находит модель Tasks по ID.
- **Параметры**: `$id` - первичный ключ
- **Возвращает**: Загруженную модель Tasks
- **Исключения**: `NotFoundHttpException` если не найдена

##### getUsersList()
```php
public function getUsersList(): array
```
Получить список пользователей для выпадающего списка.
- **Возвращает**: Массив `[id => full_name]`

##### getStatusList()
```php
public function getStatusList(): array
```
Получить список статусов для выпадающего списка.
- **Возвращает**: Массив `[id => status_name]`

---

### 2. SiteController - Основной контроллер сайта
**Путь**: `controllers/SiteController.php`

Обрабатывает основные действия сайта: авторизацию, главную страницу, контакты и другие общие страницы.

#### Публичные методы (Actions):

##### actionIndex()
```php
public function actionIndex(): Response
```
Отображает главную страницу.
- **Логика перенаправления**:
  - Гости → страница авторизации
  - Администраторы → список всех пользователей
  - Обычные пользователи → просмотр своего профиля

##### actionLogin()
```php
public function actionLogin(): Response|string
```
Действие для авторизации пользователя.
- **Возвращает**: HTML форму или редирект
- **Особенности**:
  - Использует модель LoginForm
  - Поддерживает "Запомнить меня"
  - Логирует попытки входа для отладки

##### actionLogout()
```php
public function actionLogout(): Response
```
Действие для выхода из системы.
- **HTTP метод**: POST
- **Возвращает**: Редирект на главную

##### actionContact()
```php
public function actionContact(): Response|string
```
Отображает страницу контактов.
- **Использует**: ContactForm модель
- **Отправляет**: Email на adminEmail

##### actionAbout()
```php
public function actionAbout(): string
```
Отображает страницу "О нас".

##### actionSay($message)
```php
public function actionSay(string $message = 'Привет'): string
```
Тестовое действие для демонстрации передачи параметров.
- **Параметры**: `$message` - сообщение для отображения

##### actionRebbe()
```php
public function actionRebbe(): string
```
Тестовая страница Rebbe.

##### actionTestAuth()
```php
public function actionTestAuth(): string|Response
```
Тестирование авторизации - проверка текущего пользователя.

---

### 3. UsersController - Управление пользователями
**Путь**: `controllers/UsersController.php`

Реализует CRUD операции для модели Users с разграничением прав доступа.

#### Публичные методы (Actions):

##### actionIndex()
```php
public function actionIndex(): string|Response
```
Отображает список всех пользователей.
- **Права доступа**: Только администраторы
- **Особенности**: Обычные пользователи перенаправляются на свой профиль

##### actionView($id)
```php
public function actionView(int $id): string
```
Отображает одного пользователя.
- **Права доступа**: 
  - Администраторы видят всех
  - Пользователи видят только себя
- **Исключения**: `ForbiddenHttpException` при попытке просмотра чужих данных

##### actionCreate()
```php
public function actionCreate(): string|Response
```
Создает нового пользователя.
- **Сценарий**: 'create'
- **Обязательные поля**: full_name, email, password_plain, id_role

##### actionUpdate($id)
```php
public function actionUpdate(int $id): string|Response
```
Обновляет существующего пользователя.
- **Параметры**: `$id` - ID пользователя

##### actionDelete($id)
```php
public function actionDelete(int $id): Response
```
Удаляет пользователя.
- **HTTP метод**: POST

##### actionResetPassword($id)
```php
public function actionResetPassword(int $id): Response
```
Сброс пароля пользователя.
- **Права доступа**: Только администраторы
- **Новый пароль**: 'password123' (в продакшене лучше делать случайным)

##### actionTestPasswords()
```php
public function actionTestPasswords(): void
```
Тестирование хешей паролей - проверяет формат сохраненных паролей.
- **Назначение**: Отладка

##### actionIndex2()
```php
public function actionIndex2(): string
```
Альтернативное представление списка пользователей.
- **Назначение**: Тестирование

#### Защищенные методы:

##### findModel($id)
```php
protected function findModel(int $id): Users
```
Находит модель Users по ID.
- **Исключения**: `NotFoundHttpException` если не найдена

---

## 📦 МОДЕЛИ (Models)

### Модели сущностей (Entities)

#### 1. Tasks - Модель заявки
**Путь**: `models/entities/Tasks.php`

Основная модель для работы с заявками Help Desk.

##### Свойства (Properties):
```php
int $id                    // ID заявки
int $id_status            // ID статуса
string $description       // Описание проблемы
int $id_user              // ID автора заявки
string $date              // Дата создания
string $last_time_update  // Дата последнего обновления
string $comment           // Комментарий
int $executor_id          // ID исполнителя
array $attachments        // Массив ID вложений
UploadedFile[] $uploadFiles  // Массив загружаемых файлов
```

##### Основные методы:

###### tableName()
```php
public static function tableName(): string
```
Возвращает имя таблицы в БД: 'tasks'.

###### rules()
```php
public function rules(): array
```
Правила валидации:
- `id_status, description, id_user` - обязательные
- `id_status, id_user, executor_id` - integer
- `description, comment` - string
- `uploadFiles` - file, расширения: png, jpg, jpeg, gif, pdf, doc, docx, xls, xlsx, txt, max 10 файлов

###### behaviors()
```php
public function behaviors(): array
```
Поведения модели:
- `TimestampBehavior` - автоматически устанавливает дату создания и обновления

###### getStatus()
```php
public function getStatus(): ActiveQuery
```
Связь с моделью DicTaskStatus (один-к-одному).

###### getUser()
```php
public function getUser(): ActiveQuery
```
Связь с моделью Users - автор заявки (один-к-одному).

###### getExecutor()
```php
public function getExecutor(): ActiveQuery
```
Связь с моделью Users - исполнитель заявки (один-к-одному).

###### getTaskAttachments()
```php
public function getTaskAttachments(): ActiveQuery
```
Связь с моделью DeskAttachments через таблицу task_attachments (один-ко-многим).

###### getAttachmentsArray()
```php
public function getAttachmentsArray(): array
```
Получить массив ID вложений.

###### setAttachmentsArray($attachments)
```php
public function setAttachmentsArray(array $attachments): void
```
Установить массив ID вложений.

###### addAttachment($attachmentId)
```php
public function addAttachment(int $attachmentId): void
```
Добавить вложение к заявке.

###### removeAttachment($attachmentId)
```php
public function removeAttachment(int $attachmentId): void
```
Удалить вложение из заявки.

###### getAllAttachments()
```php
public function getAllAttachments(): DeskAttachments[]
```
Получить все объекты вложений заявки.

###### uploadFiles()
```php
public function uploadFiles(): bool
```
Загрузить файлы и создать вложения.
- **Процесс**:
  1. Проверяет наличие файлов
  2. Сохраняет каждый файл в `/web/uploads/tasks/`
  3. Создает запись в БД (DeskAttachments)
  4. Добавляет ID вложения в массив attachments
  5. Сохраняет обновленную заявку

###### beforeSave($insert)
```php
public function beforeSave(bool $insert): bool
```
Обработка массива attachments перед сохранением в БД.
- Конвертирует PHP массив в JSON строку

###### afterSave($insert, $changedAttributes)
```php
public function afterSave(bool $insert, array $changedAttributes): void
```
После сохранения восстанавливает массив из JSON.

###### afterFind()
```php
public function afterFind(): void
```
Обработка attachments после загрузки из БД.
- Конвертирует JSON строку в PHP массив
- Поддерживает PostgreSQL массивы формата `{1,2,3}`

###### AllTasks()
```php
public static function AllTasks(): Tasks[]
```
Получить все заявки с подгруженными связями (user, executor, status).

---

#### 2. Users - Модель пользователя
**Путь**: `models/entities/Users.php`

Модель пользователя с реализацией интерфейса IdentityInterface для авторизации.

##### Свойства (Properties):
```php
int $id_user               // ID пользователя
string $full_name          // ФИО
string $email              // Email (используется как username)
int $id_role               // ID роли
string $password           // Хеш пароля
string $auth_key           // Ключ аутентификации
string $access_token       // Токен доступа
string $password_reset_token  // Токен сброса пароля
string $password_plain     // Виртуальное поле для ввода пароля
```

##### Основные методы:

###### tableName()
```php
public static function tableName(): string
```
Возвращает имя таблицы: 'users'.

###### rules()
```php
public function rules(): array
```
Правила валидации с обязательными полями и ограничениями.

###### getRole()
```php
public function getRole(): ActiveQuery
```
Связь с моделью Roles (один-к-одному).

###### isAdmin()
```php
public function isAdmin(): bool
```
Проверяет, является ли пользователь администратором по ID роли (id_role == 5).

###### isAdministrator()
```php
public function isAdministrator(): bool
```
Проверяет, является ли пользователь администратором по названию роли ('администратор').

###### isUser()
```php
public function isUser(): bool
```
Проверяет, является ли пользователь обычным пользователем (id_role == 4).

###### isRegularUser()
```php
public function isRegularUser(): bool
```
Проверяет, является ли пользователь обычным пользователем по названию роли ('пользователь').

##### Методы IdentityInterface:

###### findIdentity($id)
```php
public static function findIdentity($id): Users|null
```
Найти пользователя по ID.

###### findIdentityByAccessToken($token, $type)
```php
public static function findIdentityByAccessToken($token, $type = null): Users|null
```
Найти пользователя по токену доступа.

###### getId()
```php
public function getId(): int
```
Получить ID пользователя.

###### getAuthKey()
```php
public function getAuthKey(): string|null
```
Получить ключ аутентификации.

###### validateAuthKey($authKey)
```php
public function validateAuthKey($authKey): bool
```
Проверить ключ аутентификации.

##### Методы авторизации:

###### findByUsername($username)
```php
public static function findByUsername(string $username): Users|null
```
Найти пользователя по username (в нашем случае email).

###### findByEmail($email)
```php
public static function findByEmail(string $email): Users|null
```
Найти пользователя по email.

###### validatePassword($password)
```php
public function validatePassword(string $password): bool
```
Проверить пароль пользователя.
- Поддерживает старый формат MD5
- Поддерживает новый формат Yii2 Security
- Автоматически обновляет хеш при входе со старым форматом

###### setPassword($password)
```php
public function setPassword(string $password): void
```
Генерирует хеш пароля и устанавливает его в модель.
- Использует MD5 для совместимости со старой системой

###### generateAuthKey()
```php
public function generateAuthKey(): void
```
Генерирует случайный ключ аутентификации "запомнить меня".

##### Вспомогательные методы:

###### getUsername()
```php
public function getUsername(): string
```
Виртуальное свойство username (возвращает email).

###### getRoleName()
```php
public function getRoleName(): string|null
```
Получить название роли пользователя.

###### getRoleDisplayName()
```php
public function getRoleDisplayName(): string
```
Получить отображаемое имя роли на русском языке.

###### getDisplayName()
```php
public function getDisplayName(): string
```
Получить имя пользователя для отображения (ФИО или email).

##### Статические методы:

###### getUsersWithRoles()
```php
public static function getUsersWithRoles(): Users[]
```
Получить всех пользователей с загруженными ролями.

###### getUsersWithRussianRoles()
```php
public static function getUsersWithRussianRoles(): Users[]
```
Получить пользователей с русскими названиями ролей.

###### getRolesList()
```php
public static function getRolesList(): array
```
Получить список ролей для выпадающего списка.

##### События:

###### beforeSave($insert)
```php
public function beforeSave(bool $insert): bool
```
Событие перед сохранением:
- Генерирует auth_key при создании
- Хэширует пароль если он был изменен

###### afterValidate()
```php
public function afterValidate(): void
```
Событие после валидации:
- Хэширует пароль после успешной валидации

---

#### 3. DeskAttachments - Модель вложений
**Путь**: `models/entities/DeskAttachments.php`

Модель для хранения файлов, прикрепленных к заявкам.

##### Свойства (Properties):
```php
int $attach_id       // ID вложения
string $path         // Относительный путь к файлу
string $name         // Имя файла
string $extension    // Расширение файла
string $created_at   // Дата создания
```

##### Основные методы:

###### tableName()
```php
public static function tableName(): string
```
Возвращает имя таблицы: 'desk_attachments'.

###### behaviors()
```php
public function behaviors(): array
```
Поведения:
- `TimestampBehavior` - автоматически устанавливает created_at

###### getFullPath()
```php
public function getFullPath(): string
```
Получить полный путь к файлу на сервере.

###### fileExists()
```php
public function fileExists(): bool
```
Проверить существование файла на диске.

###### getFileSize()
```php
public function getFileSize(): int|false
```
Получить размер файла в байтах.

###### getFormattedFileSize()
```php
public function getFormattedFileSize(): string
```
Получить размер файла в читаемом формате (B, KB, MB, GB).

###### getFileIcon()
```php
public function getFileIcon(): string
```
Получить CSS класс иконки FontAwesome для типа файла.
- Поддерживаемые типы: PDF, Word, Excel, текст, изображения

###### isImageOrScan()
```php
public function isImageOrScan(): bool
```
Проверить, является ли файл изображением или PDF (может быть предпросмотрен).

###### getPreviewUrl()
```php
public function getPreviewUrl(): string
```
Получить URL для предпросмотра файла.

###### getDownloadUrl()
```php
public function getDownloadUrl(): string
```
Получить URL для скачивания файла.

###### deleteFile()
```php
public function deleteFile(): bool
```
Удалить файл с диска.

###### delete()
```php
public function delete(): bool
```
Переопределенный метод удаления - удаляет файл и запись из БД.

---

### Модели справочников (Dictionaries)

#### 1. DicTaskStatus - Справочник статусов задач
**Путь**: `models/dictionaries/DicTaskStatus.php`

##### Свойства:
```php
int $id_status        // ID статуса
string $status_name   // Название статуса
```

##### Основные методы:

###### getStatusList()
```php
public static function getStatusList(): array
```
Получить список статусов для выпадающего списка.
- **Возвращает**: `[id_status => status_name]`

###### getDefaultStatusId()
```php
public static function getDefaultStatusId(): int|null
```
Получить ID статуса по умолчанию (первый в списке).

###### getTasks()
```php
public function getTasks(): ActiveQuery
```
Связь с моделью Tasks (один-ко-многим).

---

#### 2. Roles - Справочник ролей пользователей
**Путь**: `models/dictionaries/Roles.php`

##### Свойства:
```php
int $id_role        // ID роли
string $role_name   // Название роли
```

---

### Модели поиска (Search Models)

#### 1. TasksSearch - Модель поиска задач
**Путь**: `models/search/TasksSearch.php`

Наследуется от Tasks и добавляет дополнительные атрибуты для фильтрации.

##### Дополнительные свойства:
```php
string $date_from       // Дата создания от
string $date_to         // Дата создания до
string $user_name       // Имя автора
string $executor_name   // Имя исполнителя
```

##### Основной метод:

###### search($params)
```php
public function search(array $params): ActiveDataProvider
```
Создает экземпляр провайдера данных с примененным поисковым запросом.
- **Особенности**:
  - Администраторы видят все заявки
  - Пользователи видят только свои заявки
  - Фильтрация по всем полям
  - Сортировка по умолчанию: по ID DESC
  - Пагинация: 10 записей на страницу

---

#### 2. UsersSearch - Модель поиска пользователей
**Путь**: `models/search/UsersSearch.php`

Наследуется от Users и реализует поиск и фильтрацию пользователей

## 🎨 ASSET BUNDLES - Управление ресурсами

Проект использует систему Asset Bundles Yii2 для централизованного управления CSS и JavaScript файлами.

### 1. AppAsset - Базовый bundle
**Путь**: `assets/AppAsset.php`

Базовый asset bundle, подключаемый на всех страницах.

**Зависимости**:
- `yii\web\YiiAsset` - Yii2 JavaScript
- `yii\bootstrap5\BootstrapAsset` - Bootstrap 5 CSS
- `yii\web\JqueryAsset` - jQuery

---

### 2. LayoutAsset - Layout ресурсы
**Путь**: `assets/LayoutAsset.php`

Стили и скрипты для layout шаблонов.

---

### 3. TasksAsset - Ресурсы задач
**Путь**: `assets/TasksAsset.php`

Asset bundle для страниц задач (просмотр, создание, редактирование).

**CSS файлы**:
- `css/tasks/view.css` - Стили просмотра задачи
- `css/tasks/form.css` - Стили формы задачи
- `css/tasks/index.css` - Стили списка задач

**JavaScript файлы**:
- `js/tasks/view.js` - Скрипты просмотра задачи
- `js/tasks/form.js` - Скрипты формы задачи
- `js/tasks/index.js` - Скрипты списка задач

**Зависимости**:
- `yii\web\YiiAsset`
- `yii\bootstrap5\BootstrapAsset`
- `yii\web\JqueryAsset`

**Использование в представлениях**:
```php
use app\assets\TasksAsset;

TasksAsset::register($this);
```

---

### 4. TasksIndexAsset - Ресурсы списка задач
**Путь**: `assets/TasksIndexAsset.php`

Специализированный bundle для страницы списка задач.

---

### 5. AgGridAsset - AG Grid таблицы
**Путь**: `assets/AgGridAsset.php`

Asset bundle для подключения AG Grid - продвинутой библиотеки таблиц с темой Quartz.

**CSS файлы**:
- `ag-grid-community/styles/ag-theme-quartz.css` - Официальная тема Quartz (версия 34.3.1)
- `css/tasks/ag-grid.css` - Кастомные стили для задач

**JavaScript файлы**:
- `ag-grid-community/dist/ag-grid-community.min.js` - Библиотека AG Grid (версия 34.3.1)
- `js/tasks/ag-grid.js` - Конфигурация AG Grid

**Примечание**: Файлы AG Grid расположены в `web/ag-grid-community/` (скопированы из `node_modules/`)

**Зависимости**:
- `yii\web\YiiAsset`
- `yii\bootstrap5\BootstrapAsset`
- `yii\bootstrap5\BootstrapPluginAsset`
- `yii\web\JqueryAsset`

---

### 6. StatisticsAsset - Ресурсы статистики
**Путь**: `assets/StatisticsAsset.php`

Asset bundle для страницы статистики с графиками Highcharts.

**JavaScript файлы**:
- `js/tasks/statistics.js` - Конфигурация графиков и диаграмм

---

### 7. SiteAsset - Ресурсы общих страниц
**Путь**: `assets/SiteAsset.php`

Ресурсы для общих страниц сайта (главная, контакты, о нас).

---

### 8. UsersAsset - Ресурсы пользователей
**Путь**: `assets/UsersAsset.php`

Asset bundle для страниц управления пользователями.

---

## 📜 JAVASCRIPT ФАЙЛЫ

### Скрипты для задач (web/js/tasks/)

#### 1. ag-grid.js - Конфигурация AG Grid
**Путь**: `web/js/tasks/ag-grid.js`

Основной файл конфигурации AG Grid для таблицы заявок.

##### Глобальные переменные:
```javascript
let gridApi;              // API экземпляр AG Grid
let gridOptions;          // Настройки таблицы
let isAdmin = false;      // Флаг администратора
let allUsers = [];        // Список всех пользователей
let allStatuses = [];     // Список всех статусов
let previewModalInstance; // Экземпляр модального окна Bootstrap
```

##### Функции парсинга дат:

###### parseRuDateTime(text)
```javascript
function parseRuDateTime(text)
```
Парсит дату в русском формате `dd.mm.yyyy HH:MM` в объект Date.
- **Параметры**: `text` - строка даты в формате `dd.mm.yyyy HH:MM`
- **Возвращает**: объект Date или null при ошибке
- **Использование**: для корректной работы фильтров и сортировки по датам в AG Grid
- **Подробнее**: см. `docs/AGGRID_DATE_FILTER_REPORT.md`

##### Основные функции:

###### initializeAgGrid()
```javascript
function initializeAgGrid()
```
Инициализация AG Grid при загрузке страницы.
- Проверяет доступность AG Grid
- Настраивает колонки таблицы
- Подключает данные с сервера
- Настраивает фильтрацию и сортировку

###### openPreviewModalFromGrid(attachmentId, filename, previewUrl)
```javascript
window.openPreviewModalFromGrid = function(attachmentId, filename, previewUrl)
```
Глобальная функция для открытия модального окна предпросмотра файла.
- **Параметры**:
  - `attachmentId` - ID вложения
  - `filename` - Имя файла
  - `previewUrl` - URL предпросмотра
- **Поддерживаемые форматы**: PDF (iframe), изображения (img)

###### getColumnDefs()
```javascript
function getColumnDefs()
```
Возвращает конфигурацию колонок таблицы AG Grid.
- **Колонки**:
  - ID заявки
  - Описание
  - Статус (с inline редактированием для админов)
  - Автор
  - Исполнитель (с inline редактированием для админов)
  - Дата создания
  - Последнее обновление
  - Комментарий
  - Вложения (с предпросмотром)
  - Действия (просмотр, редактирование, удаление)

###### loadGridData()
```javascript
function loadGridData()
```
Загрузка данных с сервера через API endpoint.
- **Endpoint**: `/index.php?r=tasks/get-grid-data`
- **Метод**: GET
- **Формат**: JSON

###### onCellValueChanged(event)
```javascript
function onCellValueChanged(event)
```
Обработчик изменения значения ячейки (inline редактирование).
- Отправляет AJAX запрос на сервер
- Обновляет данные в БД
- Показывает уведомления об успехе/ошибке

---

#### 2. ag-grid-init.js - Инициализация AG Grid
**Путь**: `web/js/tasks/ag-grid-init.js`

Простой инициализационный скрипт, запускает `initializeAgGrid()` при загрузке страницы.

```javascript
document.addEventListener('DOMContentLoaded', function() {
    if (typeof initializeAgGrid === 'function') {
        initializeAgGrid();
    }
});
```

---

#### 3. form.js - Скрипты формы задачи
**Путь**: `web/js/tasks/form.js`

JavaScript для формы создания/редактирования заявки.

##### Основные функции:

###### Множественная загрузка файлов
- Обработка выбора нескольких файлов
- Отображение списка выбранных файлов
- Удаление файлов из списка перед отправкой

###### Валидация формы
- Проверка обязательных полей
- Проверка размера файлов
- Проверка типов файлов

---

#### 4. form-modal.js - Модальная форма
**Путь**: `web/js/tasks/form-modal.js`

JavaScript для модального окна создания заявки.

##### Основные функции:

###### Открытие модального окна
```javascript
function openCreateTaskModal()
```
Загружает форму создания через AJAX и показывает в модальном окне.

###### Отправка формы
```javascript
function submitTaskModalForm()
```
Отправляет форму через AJAX и обрабатывает ответ:
- При успехе: закрывает модальное окно и обновляет список
- При ошибке: показывает ошибки валидации

---

#### 5. view.js - Скрипты просмотра задачи
**Путь**: `web/js/tasks/view.js`

JavaScript для страницы просмотра одной заявки.

##### Основные функции:

###### Изменение статуса
```javascript
function changeTaskStatus(taskId, newStatusId)
```
Отправляет AJAX запрос на изменение статуса заявки.

###### Назначение исполнителя
```javascript
function assignExecutor(taskId, executorId)
```
Отправляет AJAX запрос на назначение исполнителя.

###### Обновление комментария
```javascript
function updateTaskComment(taskId, comment)
```
Отправляет AJAX запрос на обновление комментария.

###### Предпросмотр файлов
```javascript
function previewFile(attachmentId, filename)
```
Открывает модальное окно с предпросмотром файла.

---

#### 6. index.js - Скрипты списка задач
**Путь**: `web/js/tasks/index.js`

JavaScript для страницы списка заявок (Kartik GridView).

##### Основные функции:

###### Фильтрация и поиск
- Обработка изменений в фильтрах
- Динамическое обновление таблицы

###### Массовые операции
- Выбор нескольких заявок
- Массовое изменение статуса
- Массовое назначение исполнителя

---

#### 7. statistics.js - Статистика
**Путь**: `web/js/tasks/statistics.js`

JavaScript для страницы статистики с графиками Highcharts.

##### Основные функции:

###### Инициализация графиков
```javascript
function initCharts()
```
Создает графики Highcharts:
- График заявок по пользователям (горизонтальный столбчатый)
- График завершенных заявок по исполнителям (горизонтальный столбчатый)

**Конфигурация Highcharts**:
```javascript
Highcharts.chart('userStatsChart', {
    chart: {
        type: 'bar'
    },
    title: {
        text: 'Количество заявок по пользователям'
    },
    xAxis: {
        categories: [...userNames],
        title: {
            text: null
        }
    },
    yAxis: {
        min: 0,
        title: {
            text: 'Количество заявок',
            align: 'high'
        }
    },
    series: [{
        name: 'Заявки',
        data: [...counts]
    }]
});
```

###### Экспорт в Excel
```javascript
function exportToExcel(type)
```
Отправляет запрос на экспорт статистики:
- `type = 'users'` - статистика по пользователям
- `type = 'executors'` - статистика по исполнителям

---

### Скрипты для пользователей (web/js/users/)

Скрипты для управления пользователями (CRUD операции, фильтрация, поиск).

---

### Скрипты сайта (web/js/site/)

Общие скрипты для страниц сайта (главная, контакты, о нас).

---

## 🎨 CSS ФАЙЛЫ - Полное описание

### 📊 Сводная таблица всех CSS файлов

| # | Файл | Путь | Назначение | Используется на |
|---|------|------|------------|-----------------|
| 1 | **site.css** | `web/css/common/site.css` | Базовые стили всего приложения | Все страницы |
| 2 | **pages.css** | `web/css/site/pages.css` | Стили общих страниц | site/index, site/about, site/contact |
| 3 | **view.css** | `web/css/tasks/view.css` | Просмотр одной задачи | tasks/view |
| 4 | **form.css** | `web/css/tasks/form.css` | Форма создания/редактирования | tasks/create, tasks/update |
| 5 | **form-modal.css** | `web/css/tasks/form-modal.css` | Модальная форма создания | Модальное окно на всех страницах |
| 6 | **index.css** | `web/css/tasks/index.css` | Список задач (GridView) | tasks/index |
| 7 | **ag-grid.css** | `web/css/tasks/ag-grid.css` | Специфичные стили AG Grid | tasks/index |
| 8 | **statistics.css** | `web/css/tasks/statistics.css` | Страница статистики | tasks/statistics |
| 9 | **index.css** | `web/css/users/index.css` | Список пользователей | users/index |

**Итого**: 9 CSS файлов, ~2000+ строк стилей

---

### Общие стили (web/css/common/)

#### 1. site.css - Базовые стили сайта
**Путь**: `web/css/common/site.css`

Основные стили для всего приложения:
- **Layout стили**: структура страницы, header, footer, sidebar
- **Типографика**: стили для заголовков, текста, списков
- **Кнопки**: универсальные стили кнопок
- **Формы**: базовые стили для input, select, textarea
- **Карточки**: стили для блоков контента
- **Утилиты**: margin, padding, цвета, выравнивание
- **Навигация**: стили меню и breadcrumbs
- **Уведомления**: стили для flash сообщений

**Используется**: На всех страницах приложения

---

### Стили страниц сайта (web/css/site/)

#### 1. pages.css - Стили общих страниц
**Путь**: `web/css/site/pages.css`

Стили для страниц сайта (главная, о нас, контакты):
- **Hero секции**: баннеры и приветственные блоки
- **Карточки функций**: отображение возможностей
- **Контактная форма**: стилизация формы обратной связи
- **О проекте**: блоки с информацией
- **Футер**: дополнительные стили подвала

**Используется**: На страницах site/index, site/about, site/contact

---

### Стили задач (web/css/tasks/)

#### 1. view.css - Стили просмотра задачи
**Путь**: `web/css/tasks/view.css`

Стили для страницы детального просмотра одной заявки:
- **Карточка задачи**: основной контейнер информации
- **Информационные блоки**: автор, исполнитель, даты, статус
- **Блок описания**: стилизация текста описания проблемы
- **Блок комментариев**: оформление комментариев
- **Вложения**: отображение списка файлов с иконками
- **Галерея**: предпросмотр изображений
- **Кнопки действий**: редактировать, удалить, изменить статус
- **Модальные окна**: предпросмотр файлов
- **Бейджи статусов**: цветовая индикация статусов
- **Временная шкала**: история изменений (если реализована)

**Основные классы**:
```css
.task-card { }              /* Основная карточка задачи */
.task-header { }            /* Заголовок с ID и статусом */
.task-info-block { }        /* Блок информации */
.task-description { }       /* Блок описания */
.task-comment { }           /* Блок комментария */
.attachments-list { }       /* Список вложений */
.attachment-item { }        /* Элемент вложения */
.file-preview-modal { }     /* Модальное окно предпросмотра */
.status-badge { }           /* Бейдж статуса */
.action-buttons { }         /* Кнопки действий */
```

**Используется**: На странице tasks/view

---

#### 2. form.css - Стили формы задачи
**Путь**: `web/css/tasks/form.css`

Стили для формы создания и редактирования заявки:
- **Форма**: общая структура и layout
- **Поля ввода**: стилизация текстовых полей, textarea, select
- **Загрузка файлов**: drag & drop зона, список выбранных файлов
- **Превью файлов**: миниатюры выбранных изображений
- **Валидация**: стили для ошибок и подсказок
- **Кнопки отправки**: основные и дополнительные действия
- **Подсказки**: tooltip для полей
- **Обязательные поля**: индикация звездочкой

**Основные классы**:
```css
.task-form { }              /* Основная форма */
.form-group { }             /* Группа полей */
.file-upload-area { }       /* Зона загрузки файлов */
.file-list { }              /* Список выбранных файлов */
.file-item { }              /* Элемент файла */
.file-preview { }           /* Превью файла */
.remove-file-btn { }        /* Кнопка удаления файла */
.required-field { }         /* Обязательное поле */
.error-message { }          /* Сообщение об ошибке */
.form-actions { }           /* Кнопки действий */
```

**Используется**: На страницах tasks/create, tasks/update

---

#### 3. form-modal.css - Стили модальной формы
**Путь**: `web/css/tasks/form-modal.css`

Стили для модального окна создания заявки:
- **Модальное окно**: размеры, позиционирование, анимация
- **Заголовок модального окна**: стилизация header
- **Тело модального окна**: body с формой
- **Подвал модального окна**: footer с кнопками
- **Overlay**: затемнение фона
- **Адаптивность**: стили для мобильных устройств
- **Анимации**: появление/исчезновение модального окна
- **Форма внутри модального окна**: компактный layout

**Основные классы**:
```css
.modal-task-form { }        /* Модальное окно формы */
.modal-header { }           /* Заголовок */
.modal-body { }             /* Тело с формой */
.modal-footer { }           /* Подвал с кнопками */
.modal-backdrop { }         /* Затемнение фона */
.modal-close-btn { }        /* Кнопка закрытия */
.modal-compact-form { }     /* Компактная форма */
```

**Используется**: На всех страницах со списком задач (модальное создание)

---

#### 4. index.css - Стили списка задач
**Путь**: `web/css/tasks/index.css`

Стили для страницы списка заявок (Kartik GridView):
- **Таблица**: стилизация GridView
- **Фильтры**: поля фильтрации над таблицей
- **Пагинация**: стили навигации по страницам
- **Сортировка**: индикаторы сортировки колонок
- **Строки таблицы**: hover эффекты, выделение
- **Ячейки**: выравнивание, padding
- **Статусы**: цветовая индикация
- **Действия**: кнопки просмотра, редактирования, удаления
- **Массовые операции**: чекбоксы выбора
- **Экспорт**: кнопки экспорта данных
- **Toolbar**: панель инструментов над таблицей

**Основные классы**:
```css
.tasks-index { }            /* Основной контейнер */
.grid-view { }              /* Таблица GridView */
.filters { }                /* Блок фильтров */
.table-header { }           /* Заголовок таблицы */
.table-row { }              /* Строка таблицы */
.status-cell { }            /* Ячейка со статусом */
.actions-cell { }           /* Ячейка с действиями */
.pagination { }             /* Пагинация */
.toolbar { }                /* Панель инструментов */
```

**Используется**: На странице tasks/index

---

#### 5. ag-grid.css - Стили AG Grid для задач
**Путь**: `web/css/tasks/ag-grid.css`

Специфичные стили для таблицы AG Grid с заявками (тема Quartz):
- **Контейнер AG Grid**: размеры и позиционирование
- **Ячейки**: кастомные стили для разных типов данных
- **Редактирование**: стили inline редактирования
- **Вложения в ячейках**: миниатюры файлов и ссылки на предпросмотр
- **Кнопки действий**: компактные кнопки в ячейках
- **Статусы**: цветовое кодирование
- **Загрузка**: индикаторы loading
- **Пустое состояние**: сообщение "Нет данных"
- **Фильтры дат**: корректная работа фильтра и сортировки по датам (см. AGGRID_DATE_FILTER_REPORT.md)

**Основные классы**:
```css
.ag-grid-tasks { }          /* Контейнер AG Grid */
.ag-cell-custom { }         /* Кастомные ячейки */
.ag-cell-actions { }        /* Ячейка с действиями */
.ag-cell-attachments { }    /* Ячейка с вложениями */
.ag-cell-status { }         /* Ячейка со статусом */
.ag-editor-cell { }         /* Ячейка в режиме редактирования */
```

**Используется**: На странице tasks/index

**Примечание**: Фильтр дат использует функцию `parseRuDateTime()` для корректного парсинга дат в формате `dd.mm.yyyy HH:MM`

---

#### 6. statistics.css - Стили статистики
**Путь**: `web/css/tasks/statistics.css`

Стили для страницы статистики с графиками:
- **Контейнеры графиков**: размещение диаграмм Highcharts
- **Карточки статистики**: блоки с числовыми показателями
- **Легенда**: стилизация легенды графиков
- **Заголовки**: заголовки секций статистики
- **Фильтры**: выбор периода для статистики
- **Экспорт**: кнопки экспорта в Excel/PDF
- **Адаптивность**: layout для разных экранов
- **Grid layout**: размещение графиков в сетке

**Основные классы**:
```css
.statistics-page { }        /* Основная страница */
.chart-container { }        /* Контейнер графика */
.stat-card { }              /* Карточка со статистикой */
.stat-number { }            /* Большое число */
.stat-label { }             /* Подпись к числу */
.chart-title { }            /* Заголовок графика */
.export-buttons { }         /* Кнопки экспорта */
.stats-grid { }             /* Сетка графиков */
```

**Используется**: На странице tasks/statistics

---

### Стили пользователей (web/css/users/)

#### 1. index.css - Стили списка пользователей
**Путь**: `web/css/users/index.css`

Стили для страницы списка пользователей:
- **Таблица пользователей**: GridView с пользователями
- **Фильтры**: поиск по ФИО, email, роли
- **Роли**: цветовые бейджи для ролей
- **Аватары**: отображение фото или инициалов
- **Статус активности**: индикатор онлайн/оффлайн
- **Действия**: кнопки просмотра, редактирования
- **Создание**: кнопка добавления нового пользователя
- **Пагинация**: навигация по страницам

**Основные классы**:
```css
.users-index { }            /* Основной контейнер */
.user-row { }               /* Строка пользователя */
.user-avatar { }            /* Аватар */
.role-badge { }             /* Бейдж роли */
.user-status { }            /* Статус активности */
.user-actions { }           /* Действия */
```

**Используется**: На странице users/index

---

## 📜 JAVASCRIPT ФАЙЛЫ - Полное описание

### 📊 Сводная таблица всех JavaScript файлов

| # | Файл | Путь | Назначение | Основные функции | Используется на |
|---|------|------|------------|------------------|-----------------|
| 1 | **pages.js** | `web/js/site/pages.js` | Скрипты общих страниц | Валидация форм, анимации | site/index, site/about, site/contact |
| 2 | **ag-grid.js** | `web/js/tasks/ag-grid.js` | Конфигурация AG Grid | initializeAgGrid(), getColumnDefs(), loadGridData(), parseRuDateTime() | tasks/index |
| 3 | **ag-grid-init.js** | `web/js/tasks/ag-grid-init.js` | Инициализация AG Grid | Запуск initializeAgGrid() при загрузке | tasks/index |
| 4 | **form.js** | `web/js/tasks/form.js` | Форма задачи | Множественная загрузка файлов, валидация | tasks/create, tasks/update |
| 5 | **form-modal.js** | `web/js/tasks/form-modal.js` | Модальная форма | openCreateTaskModal(), submitTaskModalForm() | Модальное окно |
| 6 | **view.js** | `web/js/tasks/view.js` | Просмотр задачи | changeTaskStatus(), assignExecutor(), previewFile() | tasks/view |
| 7 | **index.js** | `web/js/tasks/index.js` | Список задач | Фильтрация, массовые операции, поиск | tasks/index |
| 8 | **statistics.js** | `web/js/tasks/statistics.js` | Статистика | initCharts(), exportToExcel() | tasks/statistics |
| 9 | **index.js** | `web/js/users/index.js` | Список пользователей | filterUsers(), deleteUser(), resetPassword() | users/index |

**Итого**: 9 JavaScript файлов, ~1800+ строк кода

---

### Скрипты страниц сайта (web/js/site/)

#### 1. pages.js - Скрипты общих страниц
**Путь**: `web/js/site/pages.js`

JavaScript для страниц сайта (главная, о нас, контакты):

**Функции**:
- Валидация контактной формы
- Анимации при скролле страницы
- Интерактивные элементы на главной
- Слайдеры (если есть)
- Обработка отправки формы обратной связи

**Используется**: На страницах site/index, site/about, site/contact

---

### Скрипты пользователей (web/js/users/)

#### 1. index.js - Скрипты списка пользователей
**Путь**: `web/js/users/index.js`

JavaScript для страницы списка пользователей:

**Функции**:

##### Фильтрация и поиск
```javascript
function filterUsers()
```
Динамическая фильтрация пользователей по ФИО, email, роли.

##### AJAX операции
```javascript
function deleteUser(userId)
```
Удаление пользователя через AJAX с подтверждением.

```javascript
function resetPassword(userId)
```
Сброс пароля пользователя.

```javascript
function toggleUserStatus(userId)
```
Активация/деактивация пользователя.

##### Массовые операции
```javascript
function bulkOperation(action)
```
Массовые действия с выбранными пользователями.

**Используется**: На странице users/index

---

## 📝 Работа с AG Grid

AG Grid - это мощная библиотека JavaScript для создания продвинутых таблиц с расширенными возможностями.

### Возможности AG Grid в проекте:

#### 1. Серверная пагинация и сортировка
- Данные загружаются с сервера по мере необходимости
- Сортировка выполняется на стороне сервера
- Минимальная нагрузка на клиент

#### 2. Фильтрация по всем колонкам
- Текстовые фильтры для строковых полей
- Выпадающие списки для статусов и пользователей
- Фильтры по датам

#### 3. Изменение размера колонок
- Пользователи могут изменять ширину колонок
- Поддержка автоматического подбора ширины

#### 4. Экспорт в Excel/CSV
- Экспорт текущих данных
- Экспорт с учетом фильтров
- Кастомизация формата экспорта

#### 5. Inline редактирование (для администраторов)
- Изменение статуса прямо в таблице
- Назначение исполнителя без перехода на другую страницу
- Автоматическое сохранение изменений

### Конфигурационные файлы:
- **JavaScript**: `web/js/tasks/ag-grid.js` - основная конфигурация
- **CSS**: `web/css/tasks/ag-grid.css` - кастомные стили для задач
- **Asset Bundle**: `assets/AgGridAsset.php` - подключение ресурсов

### API Endpoint:
- **URL**: `/index.php?r=tasks/get-grid-data`
- **Метод**: GET
- **Формат ответа**: JSON
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "description": "Описание заявки",
            "status_name": "Открыта",
            "user_name": "Иванов Иван Иванович",
            "executor_name": "Петров Петр Петрович",
            "date": "01.11.2025 10:30",
            "attachments": [...]
        }
    ],
    "total": 100
}
```

### Использование в представлениях:

**Представление**: `views/tasks/index.php`

```php
use app\assets\AgGridAsset;

AgGridAsset::register($this);
?>

<div id="agGridTasksContainer" class="ag-theme-quartz"></div>

<?php
$this->registerJs("
    window.isUserAdmin = " . (Yii::$app->user->identity->isAdministrator() ? 'true' : 'false') . ";
    window.allUsersList = " . json_encode($usersList) . ";
    window.allStatusList = " . json_encode($statusList) . ";
");
?>
```

## 📈 Статистика

Модуль статистики использует Highcharts для визуализации данных:

- Количество заявок по пользователям (горизонтальная столбчатая диаграмма)
- Количество выполненных заявок по исполнителям (горизонтальная столбчатая диаграмма)
- Статистика по статусам заявок
- Экспорт статистики в Excel

---

## 💾 БАЗА ДАННЫХ

### Структура таблиц

#### 1. Таблица `tasks` - Заявки

Основная таблица для хранения заявок Help Desk.

```sql
CREATE TABLE `tasks` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `id_status` INT(11) NOT NULL,
    `description` TEXT NOT NULL,
    `id_user` INT(11) NOT NULL,
    `date` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `last_time_update` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `comment` TEXT NULL,
    `executor_id` INT(11) NULL,
    `attachments` JSON NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_status` (`id_status`),
    INDEX `idx_user` (`id_user`),
    INDEX `idx_executor` (`executor_id`),
    FOREIGN KEY (`id_status`) REFERENCES `dic_task_status`(`id_status`),
    FOREIGN KEY (`id_user`) REFERENCES `users`(`id_user`),
    FOREIGN KEY (`executor_id`) REFERENCES `users`(`id_user`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Поля**:
- `id` - Уникальный идентификатор заявки (PRIMARY KEY)
- `id_status` - Ссылка на статус заявки (FOREIGN KEY → dic_task_status)
- `description` - Описание проблемы (обязательное)
- `id_user` - Автор заявки (FOREIGN KEY → users)
- `date` - Дата и время создания заявки
- `last_time_update` - Дата и время последнего обновления
- `comment` - Комментарий к заявке
- `executor_id` - Исполнитель заявки (FOREIGN KEY → users)
- `attachments` - JSON массив ID вложений

---

#### 2. Таблица `users` - Пользователи

Таблица пользователей системы с поддержкой авторизации.

```sql
CREATE TABLE `users` (
    `id_user` INT(11) NOT NULL AUTO_INCREMENT,
    `full_name` VARCHAR(200) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `id_role` INT(11) NULL,
    `password` VARCHAR(100) NULL,
    `auth_key` VARCHAR(32) NULL,
    `access_token` VARCHAR(100) NULL,
    `password_reset_token` VARCHAR(100) NULL,
    `position` VARCHAR(100) NULL,
    `department` VARCHAR(100) NULL,
    `phone` VARCHAR(50) NULL,
    PRIMARY KEY (`id_user`),
    UNIQUE KEY `email` (`email`),
    INDEX `idx_role` (`id_role`),
    FOREIGN KEY (`id_role`) REFERENCES `roles`(`id_role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Поля**:
- `id_user` - Уникальный идентификатор пользователя (PRIMARY KEY)
- `full_name` - ФИО пользователя (обязательное)
- `email` - Email адрес (обязательное, уникальное, используется как username)
- `id_role` - Роль пользователя (FOREIGN KEY → roles)
- `password` - Хеш пароля (MD5 для совместимости)
- `auth_key` - Ключ для функции "Запомнить меня"
- `access_token` - Токен доступа к API
- `password_reset_token` - Токен для сброса пароля
- `position` - Должность
- `department` - Отдел
- `phone` - Телефон

---

#### 3. Таблица `desk_attachments` - Вложения

Таблица для хранения информации о файлах, прикрепленных к заявкам.

```sql
CREATE TABLE `desk_attachments` (
    `attach_id` INT(11) NOT NULL AUTO_INCREMENT,
    `path` VARCHAR(500) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `extension` VARCHAR(10) NOT NULL,
    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`attach_id`),
    INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Поля**:
- `attach_id` - Уникальный идентификатор вложения (PRIMARY KEY)
- `path` - Относительный путь к файлу (например: `/uploads/tasks/file.pdf`)
- `name` - Оригинальное имя файла
- `extension` - Расширение файла (для определения типа и иконки)
- `created_at` - Дата и время загрузки файла

---

#### 4. Таблица `dic_task_status` - Справочник статусов

Справочник возможных статусов заявок.

```sql
CREATE TABLE `dic_task_status` (
    `id_status` INT(11) NOT NULL AUTO_INCREMENT,
    `status_name` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id_status`),
    UNIQUE KEY `status_name` (`status_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Статусы по умолчанию**:
- 1: "Открыта" - новая заявка
- 2: "В работе" - заявка назначена исполнителю
- 3: "Ожидание" - ожидание дополнительной информации
- 4: "Завершено" - работа выполнена
- 5: "Отменена" - заявка отменена

---

#### 5. Таблица `roles` - Роли пользователей

Справочник ролей пользователей системы.

```sql
CREATE TABLE `roles` (
    `id_role` INT(11) NOT NULL AUTO_INCREMENT,
    `role_name` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`id_role`),
    UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Роли по умолчанию**:
- 4: "пользователь" - обычный пользователь (может создавать и просматривать свои заявки)
- 5: "администратор" - администратор (полный доступ ко всем функциям)

---

### Связи между таблицами

```
┌──────────────┐
│    users     │
│              │
│ • id_user    │────┐
│ • full_name  │    │
│ • email      │    │
│ • id_role    │──┐ │
│ • password   │  │ │
└──────────────┘  │ │
                  │ │
       ┌──────────┘ │
       │            │
       │            │
       ▼            │
┌──────────────┐   │
│    roles     │   │
│              │   │
│ • id_role    │   │
│ • role_name  │   │
└──────────────┘   │
                   │
                   │
                   │
                   ▼
        ┌────────────────────┐
        │       tasks        │
        │                    │
        │ • id               │
        │ • id_status        │───┐
        │ • description      │   │
        │ • id_user         │◀──┘ (автор)
        │ • executor_id     │◀───┐ (исполнитель)
        │ • date            │    │
        │ • last_time_update│    │
        │ • comment         │    │
        │ • attachments     │────┐
        └────────────────────┘    │
                 │                │
                 │                │
                 ▼                │
     ┌──────────────────┐         │
     │ dic_task_status  │         │
     │                  │         │
     │ • id_status      │         │
     │ • status_name    │         │
     └──────────────────┘         │
                                  │
                                  ▼
                     ┌──────────────────────┐
                     │ desk_attachments     │
                     │                      │
                     │ • attach_id          │
                     │ • path               │
                     │ • name               │
                     │ • extension          │
                     │ • created_at         │
                     └──────────────────────┘
```

---

### Индексы для оптимизации

Для повышения производительности запросов созданы следующие индексы:

**Таблица tasks**:
- `PRIMARY KEY` на `id`
- `INDEX idx_status` на `id_status` - для быстрой фильтрации по статусам
- `INDEX idx_user` на `id_user` - для быстрого поиска заявок пользователя
- `INDEX idx_executor` на `executor_id` - для фильтрации по исполнителям

**Таблица users**:
- `PRIMARY KEY` на `id_user`
- `UNIQUE KEY` на `email` - гарантирует уникальность email
- `INDEX idx_role` на `id_role` - для фильтрации по ролям

**Таблица desk_attachments**:
- `PRIMARY KEY` на `attach_id`
- `INDEX idx_created` на `created_at` - для сортировки по дате

---

## 🔄 WORKFLOW ЗАЯВКИ

### Полный жизненный цикл заявки

```
┌─────────────────────────────────────────────────────────────┐
│                    СОЗДАНИЕ ЗАЯВКИ                           │
│  1. Пользователь заполняет форму с описанием проблемы        │
│  2. При необходимости прикрепляет файлы (скриншоты, документы)│
│  3. Нажимает кнопку "Создать"                                │
│  4. Система автоматически:                                    │
│     • Устанавливает автора (текущий пользователь)            │
│     • Устанавливает статус "Открыта"                         │
│     • Сохраняет дату создания                                │
│     • Загружает файлы на сервер                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                 ОБРАБОТКА АДМИНИСТРАТОРОМ                    │
│  1. Администратор видит новую заявку в общем списке          │
│  2. Просматривает детали и вложения                          │
│  3. Изменяет статус на "В работе"                           │
│  4. Назначает исполнителя из списка пользователей           │
│  5. При необходимости добавляет комментарий                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  РАБОТА ИСПОЛНИТЕЛЯ                          │
│  1. Исполнитель видит назначенные ему заявки                │
│  2. Работает над решением проблемы                          │
│  3. Может изменить статус на "Ожидание" (если нужна         │
│     дополнительная информация от автора)                    │
│  4. После выполнения меняет статус на "Завершено"           │
│  5. Добавляет комментарий о результатах работы              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      ЗАВЕРШЕНИЕ                              │
│  1. Автор заявки получает уведомление о завершении          │
│  2. Может просмотреть результаты и комментарии              │
│  3. Заявка остается в системе для истории и статистики      │
└─────────────────────────────────────────────────────────────┘

                    АЛЬТЕРНАТИВНЫЙ ПУТЬ
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                       ОТМЕНА                                 │
│  1. При необходимости заявка может быть отменена            │
│  2. Администратор меняет статус на "Отменена"               │
│  3. Добавляет причину отмены в комментарий                  │
└─────────────────────────────────────────────────────────────┘
```

### Матрица доступа по статусам

| Статус       | Создать | Просмотр | Изменить статус | Назначить исполнителя | Удалить |
|--------------|---------|----------|----------------|-----------------------|---------|
| **Открыта**  | Все     | Автор+Админ | Админ       | Админ                 | Админ   |
| **В работе** | -       | Автор+Админ+Исп | Админ+Исп | Админ               | Админ   |
| **Ожидание** | -       | Автор+Админ+Исп | Админ+Исп | Админ               | Админ   |
| **Завершено**| -       | Все      | Админ          | -                     | Админ   |
| **Отменена** | -       | Все      | Админ          | -                     | Админ   |

**Легенда**:
- Все - любой авторизованный пользователь
- Автор - автор заявки
- Админ - администратор
- Исп - исполнитель заявки

---

## 🔄 АРХИТЕКТУРА И ПАТТЕРНЫ

### MVC (Model-View-Controller)

Проект следует архитектурному паттерну MVC, который разделяет приложение на три компонента:

```
┌─────────────────────────────────────────────────────────────┐
│                        BROWSER                               │
│                    (Браузер пользователя)                    │
└──────────────────────────┬──────────────────────────────────┘
                           │ HTTP Request
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                     CONTROLLER LAYER                         │
│                    (Слой контроллеров)                       │
│                                                               │
│  • TasksController    - Обработка запросов к заявкам        │
│  • UsersController    - Обработка запросов к пользователям  │
│  • SiteController     - Обработка общих запросов            │
│                                                               │
│  Функции:                                                     │
│  • Получение данных из запроса                               │
│  • Валидация входных данных                                  │
│  • Вызов бизнес-логики (модели)                             │
│  • Подготовка данных для отображения                         │
│  • Рендеринг представлений                                   │
└──────────────────┬───────────────────┬──────────────────────┘
                   │                    │
                   ▼                    ▼
┌───────────────────────────┐  ┌──────────────────────────────┐
│      MODEL LAYER          │  │       VIEW LAYER             │
│    (Слой моделей)         │  │   (Слой представлений)       │
│                           │  │                               │
│ • Tasks.php               │  │ • views/tasks/               │
│ • Users.php               │  │   - index.php                │
│ • DeskAttachments.php     │  │   - view.php                 │
│ • DicTaskStatus.php       │  │   - create.php               │
│ • TasksSearch.php         │  │   - _form.php                │
│                           │  │                               │
│ Функции:                  │  │ • views/users/               │
│ • Работа с БД             │  │ • views/layouts/             │
│ • Бизнес-логика           │  │                               │
│ • Валидация данных        │  │ Функции:                     │
│ • Связи между таблицами   │  │ • HTML разметка              │
│ • Вычисляемые свойства    │  │ • Отображение данных         │
│                           │  │ • Формы ввода                │
└──────────┬────────────────┘  │ • CSS/JavaScript             │
           │                    └──────────────────────────────┘
           ▼
┌─────────────────────────────────────────────────────────────┐
│                     DATABASE LAYER                           │
│                      (База данных)                           │
│                                                               │
│  • tasks              - Таблица заявок                       │
│  • users              - Таблица пользователей                │
│  • desk_attachments   - Таблица вложений                     │
│  • dic_task_status    - Справочник статусов                  │
│  • roles              - Справочник ролей                     │
└─────────────────────────────────────────────────────────────┘
```

### Active Record Pattern

Модели в Yii2 используют паттерн Active Record, который предоставляет объектно-ориентированный интерфейс для работы с базой данных:

```php
// Создание новой записи
$task = new Tasks();
$task->description = 'Новая заявка';
$task->id_user = 1;
$task->save();

// Поиск записей
$tasks = Tasks::find()->where(['id_user' => 1])->all();
$task = Tasks::findOne(5);

// Обновление записи
$task = Tasks::findOne(5);
$task->status_id = 2;
$task->save();

// Удаление записи
$task = Tasks::findOne(5);
$task->delete();

// Связи между таблицами
$task = Tasks::findOne(5);
$author = $task->user;          // Автор заявки
$executor = $task->executor;    // Исполнитель
$status = $task->status;        // Статус
$attachments = $task->getAllAttachments();  // Вложения
```

### Asset Management Pattern

Проект использует систему Asset Bundles для управления CSS и JavaScript:

```php
// Определение Asset Bundle
class TasksAsset extends AssetBundle
{
    public $basePath = '@webroot';
    public $baseUrl = '@web';
    
    public $css = [
        'css/tasks/view.css',
    ];
    
    public $js = [
        'js/tasks/view.js',
    ];
    
    public $depends = [
        'yii\web\YiiAsset',
        'yii\bootstrap5\BootstrapAsset',
    ];
}

// Использование в представлении
TasksAsset::register($this);
```

---

## 🔄 WORKFLOW ЗАЯВКИ

Подробный жизненный цикл заявки:

### 1. Создание заявки

**Участник**: Пользователь

**Действия**:
1. Переход на страницу создания заявки
2. Заполнение описания проблемы
3. Прикрепление файлов (опционально)
4. Отправка формы

**Система**:
- Валидирует данные
- Устанавливает автора = текущий пользователь
- Устанавливает статус = "Открыта"
- Сохраняет заявку в БД
- Загружает файлы на сервер
- Создает записи вложений в БД
- Перенаправляет на список заявок

### 2. Обработка администратором

**Участник**: Администратор

**Действия**:
1. Просмотр списка всех заявок
2. Открытие детальной страницы заявки
3. Изменение статуса на "В работе"
4. Назначение исполнителя
5. Добавление комментария (опционально)

**Система**:
- Обновляет статус заявки
- Сохраняет ID исполнителя
- Обновляет дату последнего изменения
- Отправляет уведомление исполнителю (если настроено)

### 3. Выполнение работы

**Участник**: Исполнитель

**Действия**:
1. Просмотр назначенных заявок
2. Работа над решением проблемы
3. Обновление комментария с ходом работы
4. При завершении - изменение статуса на "Завершено"

**Система**:
- Обновляет комментарий
- Изменяет статус
- Обновляет дату последнего изменения
- Отправляет уведомление автору (если настроено)

### 4. Закрытие заявки

**Участник**: Автор/Администратор

**Действия**:
1. Просмотр результатов
2. Подтверждение завершения работы

**Система**:
- Заявка остается в системе для истории
- Учитывается в статистике
- Доступна для просмотра всем участникам

## 🛡️ Безопасность

- Все формы защищены CSRF-токенами
- Пароли хешируются с использованием bcrypt
- Разграничение прав доступа (RBAC может быть настроен дополнительно)
- Валидация и санитизация пользовательского ввода
- Защита от SQL-инъекций через использование prepared statements

## 🧪 Тестирование

Структура для тестирования подготовлена (Codeception):

```bash
# Запуск тестов
./vendor/bin/codecept run
```

## 📚 Дополнительная документация

### Внутренняя документация проекта:
- `УЧЕБНЫЙ_README.md` - Полная учебная документация (этот файл)
- `README.md` - Основная документация
- `QUICKSTART.md` - Быстрый старт для начинающих
- `STRUCTURE.md` - Описание структуры проекта
- `docs/AGGRID_DATE_FILTER_REPORT.md` - Отчет об исправлении фильтра дат в AG Grid
- `ОТЧЕТ_КОСМЕТИКА_ПРОЕКТА.md` - Отчет о косметических изменениях
- `ОТЧЕТ_РЕОРГАНИЗАЦИЯ_ASSETS.md` - Отчет о реорганизации Asset Bundles

### Официальная документация используемых технологий:
- [Документация Yii2 (рус)](https://www.yiiframework.com/doc/guide/2.0/ru)
- [AG Grid Community Documentation](https://www.ag-grid.com/documentation/)
- [Highcharts Documentation](https://www.highcharts.com/docs/)
- [Bootstrap 5 Documentation](https://getbootstrap.com/docs/5.0/)
- [jQuery API Documentation](https://api.jquery.com/)

## 🐛 Отладка

Включение режима отладки в `web/index.php`:

```php
defined('YII_DEBUG') or define('YII_DEBUG', true);
defined('YII_ENV') or define('YII_ENV', 'dev');
```

После включения отладки будет доступна Debug Toolbar внизу страницы.

## 📞 Поддержка

При возникновении вопросов или проблем:
1. Проверьте логи в директории `runtime/logs/`
2. Убедитесь, что все зависимости установлены
3. Проверьте права доступа к директориям
4. Убедитесь, что база данных настроена правильно

## 📋 Чеклист для развертывания

- [ ] Установлены все PHP зависимости (composer install)
- [ ] Установлены Node.js зависимости (npm install)
- [ ] Создана база данных
- [ ] Импортирована схема БД
- [ ] Настроен файл config/db.php
- [ ] Установлены права на директории web/assets, web/uploads, runtime
- [ ] Изменены пароли учетных записей по умолчанию
- [ ] Настроен веб-сервер (или запущен встроенный сервер)
- [ ] Проверена работа приложения

## 🔧 Полезные команды

```bash
# Очистка кэша
php yii cache/flush-all

# Очистка assets
rm -rf web/assets/*

# Просмотр маршрутов
php yii help

# Создание миграции
php yii migrate/create название_миграции

# Применение миграций
php yii migrate
```

## 📄 Лицензия

Проект разработан для внутреннего использования.

## 🎓 УЧЕБНЫЕ МАТЕРИАЛЫ И ПРИМЕРЫ

### Примеры кода

#### Создание новой заявки из кода:

```php
use app\models\entities\Tasks;
use app\models\dictionaries\DicTaskStatus;

// Создание новой заявки
$task = new Tasks();
$task->description = 'Не работает принтер в кабинете 205';
$task->id_user = Yii::$app->user->id;
$task->id_status = DicTaskStatus::getDefaultStatusId();
$task->comment = 'Срочно!';

if ($task->save()) {
    echo "Заявка создана с ID: " . $task->id;
} else {
    echo "Ошибки: " . print_r($task->errors, true);
}
```

#### Поиск заявок с фильтрацией:

```php
use app\models\entities\Tasks;

// Найти все открытые заявки текущего пользователя
$tasks = Tasks::find()
    ->where(['id_user' => Yii::$app->user->id])
    ->andWhere(['id_status' => 1])
    ->orderBy(['date' => SORT_DESC])
    ->all();

// Найти заявки с исполнителем и статусом
$tasks = Tasks::find()
    ->joinWith(['user', 'executor', 'status'])
    ->where(['executor_id' => 5])
    ->andWhere(['id_status' => [2, 3]]) // В работе или Ожидание
    ->all();
```

#### Работа с вложениями:

```php
use app\models\entities\Tasks;
use app\models\entities\DeskAttachments;

// Получить все вложения заявки
$task = Tasks::findOne(10);
$attachments = $task->getAllAttachments();

foreach ($attachments as $attachment) {
    echo "Файл: " . $attachment->name . "\n";
    echo "Размер: " . $attachment->getFormattedFileSize() . "\n";
    echo "Путь: " . $attachment->getFullPath() . "\n";
    echo "Иконка: " . $attachment->getFileIcon() . "\n";
    echo "Предпросмотр доступен: " . ($attachment->isImageOrScan() ? 'Да' : 'Нет') . "\n";
    echo "---\n";
}
```

#### AJAX запрос для изменения статуса:

```javascript
function changeStatus(taskId, newStatusId) {
    $.ajax({
        url: '/index.php?r=tasks/change-status&id=' + taskId,
        method: 'POST',
        data: {
            status_id: newStatusId,
            _csrf: $('meta[name="csrf-token"]').attr('content')
        },
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                alert('Статус изменен на: ' + response.status_name);
                location.reload();
            } else {
                alert('Ошибка: ' + response.message);
            }
        },
        error: function() {
            alert('Ошибка сервера');
        }
    });
}
```

---

## 🔧 GIT И GITHUB - Работа с репозиторием

### 📦 Информация о репозитории

**GitHub Repository**: [https://github.com/rrevva1/ias_uch_vnii.git](https://github.com/rrevva1/ias_uch_vnii.git)

**Текущие ветки**:
- `main` - основная ветка разработки ⭐
- `master` - стабильная ветка для production

---

### 🚀 Первоначальная настройка Git

#### Клонирование репозитория

```bash
# Клонирование проекта с GitHub
git clone https://github.com/rrevva1/ias_uch_vnii.git
cd ias_uch_vnii

# Просмотр информации о репозитории
git remote -v

# Просмотр текущей ветки
git branch

# Просмотр всех веток (включая удаленные)
git branch -a
```

#### Настройка пользователя

```bash
# Установка имени пользователя
git config user.name "Your Name"

# Установка email
git config user.email "your.email@example.com"

# Просмотр настроек
git config --list
```

---

### 📋 .gitignore - Игнорируемые файлы

**Путь**: `.gitignore`

**Содержимое**:
```gitignore
protected/runtime/*          # Временные файлы Yii
!protected/runtime/.gitignore
protected/data/*.db          # Базы данных SQLite
themes/classic/views/        # Старые представления
web/uploads/*                # Загруженные пользователями файлы
!web/uploads/.gitignore
```

**Дополнительно игнорируются** (должны быть в .gitignore):
```gitignore
# Yii2 runtime файлы
/runtime/
/web/assets/

# Composer зависимости
/vendor/

# NPM зависимости
/node_modules/

# Конфигурационные файлы (с секретами)
/config/db.php
/config/params-local.php

# IDE файлы
.idea/
.vscode/
*.swp
*.swo
*~

# Логи
*.log

# OS файлы
.DS_Store
Thumbs.db
```

---

### 🔄 Основной Workflow работы с Git

#### 1. Перед началом работы

```bash
# Переключиться на main ветку
git checkout main

# Получить последние изменения с GitHub
git pull origin main

# Проверить статус
git status
```

#### 2. Создание новой ветки для задачи

```bash
# Создать новую ветку и переключиться на неё
git checkout -b feature/add-new-functionality

# Или создать ветку для исправления бага
git checkout -b fix/bug-description
```

**Правила именования веток**:
- `feature/название` - новая функциональность
- `fix/название` - исправление бага
- `hotfix/название` - срочное исправление
- `refactor/название` - рефакторинг кода
- `docs/название` - обновление документации

#### 3. Внесение изменений

```bash
# Просмотр измененных файлов
git status

# Просмотр изменений
git diff

# Добавить конкретные файлы в staging
git add path/to/file.php

# Добавить все измененные файлы
git add .

# Добавить файлы по шаблону
git add web/js/tasks/*.js
```

#### 4. Создание коммита

```bash
# Создать коммит с сообщением
git commit -m "Добавлена новая функция X"

# Создать коммит с подробным описанием
git commit -m "Заголовок коммита" -m "Подробное описание изменений"

# Изменить последний коммит (если еще не запушен)
git commit --amend -m "Исправленное сообщение"
```

**Правила оформления коммитов**:
```
<тип>: <краткое описание>

<подробное описание (опционально)>

<ссылки на issue (опционально)>
```

**Типы коммитов**:
- `feat:` - новая функциональность
- `fix:` - исправление бага
- `docs:` - обновление документации
- `style:` - форматирование кода
- `refactor:` - рефакторинг
- `test:` - добавление тестов
- `chore:` - обновление зависимостей, конфигурации

**Примеры**:
```bash
git commit -m "feat: добавлена модальная форма создания заявки"
git commit -m "fix: исправлена ошибка загрузки файлов"
git commit -m "docs: обновлена документация по AG Grid"
git commit -m "refactor: переименованы классы TaskService"
```

#### 5. Отправка изменений на GitHub

```bash
# Отправить ветку на GitHub (первый раз)
git push -u origin feature/add-new-functionality

# Последующие отправки
git push

# Принудительная отправка (ОСТОРОЖНО!)
git push --force
```

#### 6. Создание Pull Request (PR)

1. Перейдите на GitHub: https://github.com/rrevva1/ias_uch_vnii
2. Нажмите "Compare & pull request"
3. Заполните описание PR:
   - Что изменено
   - Зачем изменено
   - Как протестировать
4. Запросите ревью у коллег
5. После одобрения - нажмите "Merge"

#### 7. Обновление ветки из main

```bash
# Переключиться на main
git checkout main

# Получить последние изменения
git pull origin main

# Переключиться обратно на рабочую ветку
git checkout feature/add-new-functionality

# Слить изменения из main (rebase - предпочтительно)
git rebase main

# Или слить изменения через merge
git merge main
```

---

### 🔍 Полезные команды Git

#### Просмотр истории

```bash
# История коммитов
git log

# История с графом веток
git log --graph --oneline --all

# История конкретного файла
git log -- path/to/file.php

# Последние 5 коммитов
git log -n 5

# История с изменениями
git log -p

# Красивый формат
git log --pretty=format:"%h - %an, %ar : %s"
```

#### Работа с ветками

```bash
# Список локальных веток
git branch

# Список всех веток (включая удаленные)
git branch -a

# Создать новую ветку
git branch feature/new-feature

# Переключиться на ветку
git checkout feature/new-feature

# Создать и переключиться (короткая форма)
git checkout -b feature/new-feature

# Удалить локальную ветку
git branch -d feature/old-feature

# Удалить удаленную ветку
git push origin --delete feature/old-feature

# Переименовать ветку
git branch -m old-name new-name
```

#### Отмена изменений

```bash
# Отменить изменения в файле (до staging)
git checkout -- path/to/file.php

# Убрать файл из staging
git reset HEAD path/to/file.php

# Отменить последний коммит (сохранив изменения)
git reset --soft HEAD~1

# Отменить последний коммит (удалив изменения)
git reset --hard HEAD~1

# Отменить коммит, создав новый коммит
git revert <commit-hash>

# Очистить все неотслеживаемые файлы
git clean -fd
```

#### Временное сохранение изменений (stash)

```bash
# Сохранить изменения в stash
git stash

# Сохранить с описанием
git stash save "Описание изменений"

# Список stash
git stash list

# Применить последний stash
git stash apply

# Применить и удалить stash
git stash pop

# Применить конкретный stash
git stash apply stash@{1}

# Удалить stash
git stash drop stash@{0}

# Очистить все stash
git stash clear
```

#### Работа с тегами

```bash
# Создать тег (легковесный)
git tag v1.0.0

# Создать аннотированный тег
git tag -a v1.0.0 -m "Версия 1.0.0"

# Список тегов
git tag

# Отправить тег на GitHub
git push origin v1.0.0

# Отправить все теги
git push origin --tags

# Удалить локальный тег
git tag -d v1.0.0

# Удалить удаленный тег
git push origin --delete v1.0.0
```

#### Поиск в истории

```bash
# Найти коммиты, содержащие текст
git log --all --grep='fix'

# Найти коммиты, изменяющие определенный код
git log -S "function name"

# Показать, кто изменял файл построчно
git blame path/to/file.php

# Найти, когда был введен баг (bisect)
git bisect start
git bisect bad  # текущая версия содержит баг
git bisect good v1.0.0  # эта версия работала
```

---

### 🔧 Сценарии решения проблем

#### Проблема: Конфликт при слиянии

```bash
# 1. Попытка слияния приводит к конфликту
git merge main
# Auto-merging file.php
# CONFLICT (content): Merge conflict in file.php

# 2. Просмотр файлов с конфликтами
git status

# 3. Открыть файл и разрешить конфликт вручную
# Найти маркеры конфликта:
# <<<<<<< HEAD
# ваш код
# =======
# код из другой ветки
# >>>>>>> main

# 4. После разрешения конфликта
git add file.php
git commit -m "Разрешен конфликт в file.php"
```

#### Проблема: Случайный коммит в main

```bash
# 1. Создать новую ветку из текущего состояния
git branch feature/accidental-commit

# 2. Вернуть main на 1 коммит назад
git reset --hard HEAD~1

# 3. Переключиться на новую ветку
git checkout feature/accidental-commit
```

#### Проблема: Нужно изменить последний коммит

```bash
# Изменить файлы
git add .

# Добавить к последнему коммиту (если еще не запушен)
git commit --amend --no-edit

# Или изменить сообщение коммита
git commit --amend -m "Новое сообщение"
```

#### Проблема: Нужно откатить файл к версии из другой ветки

```bash
# Получить файл из конкретной ветки
git checkout main -- path/to/file.php

# Получить файл из конкретного коммита
git checkout <commit-hash> -- path/to/file.php
```

---

### 📊 Git Workflow для команды

#### Gitflow модель

```
main (стабильная версия)
  │
  ├── develop (разработка)
  │     │
  │     ├── feature/new-feature-1
  │     ├── feature/new-feature-2
  │     └── feature/new-feature-3
  │
  └── hotfix/urgent-bug-fix
```

**Процесс разработки**:

1. **Новая функция**:
```bash
git checkout develop
git pull origin develop
git checkout -b feature/user-notifications
# ... работа ...
git push origin feature/user-notifications
# Создать PR в develop
```

2. **Исправление бага**:
```bash
git checkout develop
git checkout -b fix/file-upload-error
# ... исправление ...
git push origin fix/file-upload-error
# Создать PR в develop
```

3. **Срочное исправление (hotfix)**:
```bash
git checkout main
git checkout -b hotfix/critical-security-fix
# ... исправление ...
git push origin hotfix/critical-security-fix
# Создать PR в main И develop
```

4. **Релиз**:
```bash
# Слить develop в main
git checkout main
git merge --no-ff develop
git tag -a v1.2.0 -m "Release 1.2.0"
git push origin main --tags
```

---

### 🔐 Секреты и чувствительные данные

**НИКОГДА не коммитьте**:
- ❌ Пароли от БД (`config/db.php`)
- ❌ API ключи
- ❌ Секретные токены
- ❌ Приватные ключи
- ❌ Файлы с учетными данными

**Правильный подход**:
```bash
# Использовать файлы-примеры
config/db.php.example  # коммитится в Git
config/db.php          # в .gitignore, создается локально

# Использовать переменные окружения
.env.example           # коммитится в Git
.env                   # в .gitignore, создается локально
```

**Если случайно закоммитили секреты**:
```bash
# 1. Немедленно сменить все пароли/ключи!
# 2. Удалить из истории (ОПАСНО для публичных репозиториев)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch config/db.php" \
  --prune-empty --tag-name-filter cat -- --all

# 3. Принудительно запушить
git push origin --force --all
```

---

### 📚 Дополнительные ресурсы

**Официальная документация**:
- [Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)

**Полезные ссылки**:
- [Gitflow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow)

---

## 🔧 ПОЛЕЗНЫЕ КОМАНДЫ YII2

### Console команды

```bash
# Очистка всего кэша приложения
php yii cache/flush-all

# Очистка конкретного компонента кэша
php yii cache/flush cache

# Очистка скомпилированных assets
rm -rf web/assets/*

# Просмотр всех доступных команд
php yii help

# Просмотр справки по конкретной команде
php yii help migrate
```

### Работа с миграциями

```bash
# Создание новой миграции
php yii migrate/create create_tasks_table

# Применение всех новых миграций
php yii migrate

# Применение конкретной миграции
php yii migrate/up

# Откат последней миграции
php yii migrate/down

# Откат 3 последних миграций
php yii migrate/down 3

# Просмотр истории миграций
php yii migrate/history

# Пересоздание миграции (откат и применение заново)
php yii migrate/redo

# Применение миграций с автоматическим подтверждением
php yii migrate --interactive=0
```

### Работа с БД

```bash
# Подключение к PostgreSQL
psql -U postgres ias_vniic

# Резервная копия базы данных
pg_dump -U postgres ias_vniic > backup_$(date +%Y%m%d_%H%M%S).sql

# Восстановление из резервной копии
psql -U postgres ias_vniic < backup_20251103_120000.sql

# Экспорт только структуры
pg_dump -U postgres --schema-only ias_vniic > structure.sql

# Экспорт только данных
pg_dump -U postgres --data-only ias_vniic > data.sql
```

### Отладка и логирование

```bash
# Просмотр логов в реальном времени
tail -f runtime/logs/app.log

# Просмотр последних 100 строк лога
tail -n 100 runtime/logs/app.log

# Поиск ошибок в логах
grep -i "error" runtime/logs/app.log

# Очистка логов
> runtime/logs/app.log

# Просмотр логов по дате
grep "2025-11-03" runtime/logs/app.log
```

### Права доступа

```bash
# Установка прав на директории
chmod -R 775 web/assets
chmod -R 775 web/uploads
chmod -R 775 runtime

# Установка владельца (для веб-сервера)
chown -R www-data:www-data web/assets
chown -R www-data:www-data web/uploads
chown -R www-data:www-data runtime

# Проверка текущих прав
ls -la web/
```

### Composer команды

```bash
# Установка зависимостей
composer install

# Обновление зависимостей
composer update

# Обновление конкретного пакета
composer update yiisoft/yii2

# Установка нового пакета
composer require phpoffice/phpspreadsheet

# Удаление пакета
composer remove package-name

# Очистка кэша Composer
composer clear-cache

# Проверка устаревших пакетов
composer outdated
```

### NPM команды

```bash
# Установка зависимостей
npm install

# После установки копируем AG Grid в web
cp -r node_modules/ag-grid-community web/ag-grid-community

# Обновление зависимостей
npm update

# Установка нового пакета
npm install ag-grid-community --save

# Удаление пакета
npm uninstall package-name

# Проверка устаревших пакетов
npm outdated

# Аудит безопасности
npm audit

# Исправление уязвимостей
npm audit fix

# Просмотр установленной версии AG Grid
npm list ag-grid-community
```

---

## 🐛 TROUBLESHOOTING - Решение проблем

### Проблема: Не отображаются стили и скрипты

**Причина**: Не скомпилированы assets

**Решение**:
```bash
rm -rf web/assets/*
chmod -R 775 web/assets
```

---

### Проблема: Ошибка "Access denied" при подключении к БД

**Причина**: Неверные учетные данные в конфигурации

**Решение**:
1. Проверьте файл `config/db.php`
2. Убедитесь, что пользователь существует:
```bash
psql -U postgres
\du  # Список пользователей
```
3. Предоставьте права, если нужно:
```sql
GRANT ALL PRIVILEGES ON DATABASE ias_vniic TO your_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA tech_accounting TO your_user;
```

---

### Проблема: Не загружаются файлы

**Причины и решения**:

1. **Недостаточно прав на директорию**:
```bash
chmod -R 775 web/uploads
chown -R www-data:www-data web/uploads
```

2. **Превышен лимит размера файла**:
Отредактируйте `php.ini`:
```ini
upload_max_filesize = 10M
post_max_size = 10M
```

3. **Директория не существует**:
```bash
mkdir -p web/uploads/tasks
chmod 775 web/uploads/tasks
```

---

### Проблема: Ошибка 500 Internal Server Error

**Решение**:
1. Включите режим отладки в `web/index.php`:
```php
defined('YII_DEBUG') or define('YII_DEBUG', true);
defined('YII_ENV') or define('YII_ENV', 'dev');
```

2. Проверьте логи:
```bash
tail -f runtime/logs/app.log
```

3. Проверьте права на директорию runtime:
```bash
chmod -R 775 runtime
```

---

### Проблема: AG Grid не отображается

**Причины и решения**:

1. **Не установлены NPM зависимости**:
```bash
npm install
# После установки скопируйте файлы в web:
cp -r node_modules/ag-grid-community web/ag-grid-community
```

2. **Неверный путь к файлам AG Grid**:
Проверьте наличие файлов:
```bash
ls -la web/ag-grid-community/dist/
ls -la web/ag-grid-community/styles/
```

3. **Отсутствует директория ag-grid-community в web/**:
```bash
# Если директория отсутствует, скопируйте из node_modules:
cp -r node_modules/ag-grid-community web/ag-grid-community
```

4. **Проблема с Asset Bundle**:
```bash
rm -rf web/assets/*
```

---

### Проблема: Не работает авторизация

**Причины и решения**:

1. **Неверный хеш пароля**:
```php
// Сброс пароля через консоль
$user = \app\models\entities\Users::findByEmail('user@example.com');
$user->setPassword('newpassword');
$user->save(false);
```

2. **Не настроен компонент user**:
Проверьте `config/web.php`:
```php
'components' => [
    'user' => [
        'identityClass' => 'app\models\entities\Users',
        'enableAutoLogin' => true,
    ],
],
```

---

## 📚 ССЫЛКИ НА ДОКУМЕНТАЦИЮ

### Официальная документация Yii2

- [Руководство по Yii2 (рус)](https://www.yiiframework.com/doc/guide/2.0/ru)
- [API документация Yii2](https://www.yiiframework.com/doc/api/2.0)
- [Yii2 на GitHub](https://github.com/yiisoft/yii2)

### Используемые библиотеки

- [Bootstrap 5](https://getbootstrap.com/docs/5.0/)
- [jQuery](https://api.jquery.com/)
- [AG Grid Community](https://www.ag-grid.com/documentation/)
- [Highcharts](https://www.highcharts.com/docs/)
- [FontAwesome](https://fontawesome.com/docs)
- [PhpSpreadsheet](https://phpspreadsheet.readthedocs.io/)

### Полезные ресурсы

- [Yii2 Extensions](https://www.yiiframework.com/extensions)
- [Composer Packages](https://packagist.org/)
- [NPM Packages](https://www.npmjs.com/)

---

## 📞 КОНТАКТЫ И ПОДДЕРЖКА

### При возникновении вопросов или проблем:

1. **Проверьте логи**: `runtime/logs/app.log`
2. **Проверьте документацию**: Yii2 Guide
3. **Проверьте GitHub Issues**: Yii2 на GitHub
4. **Проверьте Stack Overflow**: тег [yii2]

### Системные требования

- **PHP**: 7.4 или выше (рекомендуется 8.0+)
- **PostgreSQL**: 12 или выше (рекомендуется 14+)
- **Composer**: последняя версия
- **Node.js**: 14.x или выше
- **NPM**: 6.x или выше

### Рекомендуемые расширения PHP

```bash
# Проверка установленных расширений
php -m

# Необходимые расширения:
- mbstring
- pdo_pgsql (для работы с PostgreSQL)
- gd или imagick (для работы с изображениями)
- zip
- intl
- curl
- openssl
```

---

## 📋 ЧЕКЛИСТ РАЗВЕРТЫВАНИЯ

### Первоначальная настройка

- [ ] Установлен PHP 7.4+
- [ ] Установлен PostgreSQL 12+
- [ ] Установлен Composer
- [ ] Установлен Node.js и NPM
- [ ] Клонирован репозиторий проекта
- [ ] Выполнена команда `composer install`
- [ ] Выполнена команда `npm install`
- [ ] Скопированы файлы AG Grid: `cp -r node_modules/ag-grid-community web/ag-grid-community`
- [ ] Создана база данных `ias_vniic`
- [ ] Импортирована схема БД из дампа
- [ ] Настроен файл `config/db.php`
- [ ] Установлены права на директории:
  - [ ] `web/assets` (775)
  - [ ] `web/uploads` (775)
  - [ ] `runtime` (775)
- [ ] Изменены пароли учетных записей по умолчанию
- [ ] Настроен веб-сервер (Apache/Nginx)
- [ ] Проверена работа приложения в браузере
- [ ] Проверена работа авторизации
- [ ] Проверена работа создания заявок
- [ ] Проверена работа загрузки файлов
- [ ] Проверена работа AG Grid
- [ ] Проверена работа статистики

### Production настройка (для боевого сервера)

- [ ] Отключен режим отладки (`YII_DEBUG = false`)
- [ ] Изменен environment на `prod` (`YII_ENV = 'prod'`)
- [ ] Настроен SSL сертификат (HTTPS)
- [ ] Настроен файрвол
- [ ] Настроено резервное копирование БД
- [ ] Настроен мониторинг сервера
- [ ] Настроена ротация логов
- [ ] Изменены все секретные ключи в `config/`
- [ ] Настроена отправка email уведомлений
- [ ] Проверена работа на боевом сервере

---

## 🎯 ROADMAP - Планы развития

### Версия 2.0 (планируется)

- [ ] REST API для мобильных приложений
- [ ] Email уведомления о новых заявках и изменениях
- [ ] Система приоритетов заявок
- [ ] Таймер отслеживания времени работы
- [ ] История изменений заявки
- [ ] Шаблоны часто используемых заявок
- [ ] Интеграция с внешними системами
- [ ] Расширенная система прав доступа (RBAC)
- [ ] Мобильное приложение
- [ ] Telegram бот для уведомлений

### Версия 1.3 (в планах)

- [ ] Поиск по содержимому файлов
- [ ] Массовый импорт пользователей из CSV
- [ ] Расширенная статистика (графики по времени)
- [ ] Экспорт отчетов в PDF
- [ ] Система оценки качества работы
- [ ] Уведомления по email
- [ ] История изменений заявок

---

## 📄 ЛИЦЕНЗИЯ

Проект разработан для внутреннего использования организации.

---

## 📝 ИСТОРИЯ ИЗМЕНЕНИЙ

### Версия 1.2.1 (03.11.2025)
- 🐛 Исправлена работа фильтра дат в AG Grid (добавлен parseRuDateTime)
- 🐛 Исправлена сортировка по датам в AG Grid
- 📚 Обновлена документация (AGGRID_DATE_FILTER_REPORT.md)

### Версия 1.2.0 (03.11.2025)
- ✨ Добавлена поддержка AG Grid для отображения заявок с темой Quartz
- ✨ Добавлено inline редактирование в AG Grid (для админов)
- ✨ Реализована модальная форма создания заявки
- ✨ Добавлена страница статистики с графиками Highcharts
- ✨ Реализован экспорт статистики в Excel
- 🐛 Исправлены ошибки загрузки множественных файлов
- 🐛 Исправлена работа с JSON массивом вложений
- 📦 Реорганизована структура Asset Bundles
- 📚 Обновлена документация

### Версия 1.1.0 (01.11.2025)
- ✨ Добавлена возможность множественной загрузки файлов
- ✨ Реализован предпросмотр изображений и PDF
- ✨ Добавлена поддержка различных типов файлов
- 🐛 Исправлены ошибки валидации форм
- 📚 Добавлена базовая документация

### Версия 1.0.0 (25.10.2025)
- 🎉 Первый релиз системы Help Desk
- ✨ Реализован базовый CRUD для заявок
- ✨ Реализован базовый CRUD для пользователей
- ✨ Добавлена система авторизации
- ✨ Реализована загрузка файлов
- ✨ Добавлена базовая статистика

---

**Версия документа**: 2.1  
**Дата обновления**: 03.11.2025  
**Автор**: Development Team

**Последние изменения документации (версия 2.1 - 03.11.2025)**:
- ✅ Удалена устаревшая информация об AgGridCoreAsset и AgGridThemeAsset
- ✅ Удалены ссылки на несуществующий ag-grid-custom.css и директорию web/css/vendors/
- ✅ Удалены упоминания несуществующей директории web/js/common/
- ✅ Обновлена информация о теме AG Grid (Quartz v34.3.1 вместо Alpine)
- ✅ Добавлена информация о функции parseRuDateTime() и исправлении фильтра дат
- ✅ Добавлена ссылка на docs/AGGRID_DATE_FILTER_REPORT.md
- ✅ Обновлены таблицы CSS/JS файлов (9 CSS, 9 JS)
- ✅ Актуализирована структура Asset Bundles (8 файлов)
- ✅ Актуализирована структура директорий проекта
- ✅ Добавлена информация о расположении AG Grid (web/ag-grid-community/)
- ✅ Добавлены инструкции по копированию AG Grid из node_modules
- ✅ Обновлен раздел "Технологический стек" (указана версия AG Grid 34.3.1)
- ✅ Добавлены ссылки на отчеты о косметических изменениях и реорганизации
- ✅ Обновлена история версий (добавлена версия 1.2.1)
- ✅ Расширен раздел Troubleshooting (добавлены решения проблем с AG Grid)

---

**🎓 Данный документ предназначен для обучения и содержит полное описание проекта Help Desk.**

**Для быстрого старта см. файл `QUICKSTART.md`**

