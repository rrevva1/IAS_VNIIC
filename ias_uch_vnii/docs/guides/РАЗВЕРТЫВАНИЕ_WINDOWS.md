# Развёртывание ias_uch_vnii на Windows

Инструкция по развёртыванию проекта ИАС (Help Desk) на Windows без виртуальной машины.

## 1. Требования

- **PHP** 7.4 или выше (расширения: pdo_pgsql, mbstring, openssl, json, fileinfo)
- **PostgreSQL** 12 или выше
- **Composer** ([getcomposer.org](https://getcomposer.org/))
- **Node.js** и **npm** (для AG Grid; LTS достаточно)

Проверка в PowerShell или CMD:

```cmd
php -v
psql --version
composer --version
node -v
npm -v
```

## 2. Подготовка базы данных

### 2.1. Запуск PostgreSQL

Убедитесь, что служба PostgreSQL запущена (служба «postgresql-x64-*» в `services.msc` или через pg_ctl).

### 2.2. Создание БД и применение схемы

**БД ias_vniic (рекомендуется):**

Имя БД в нижнем регистре — одинаково на Mac и Windows, в `config/db.php` везде `dbname=ias_vniic`. Восстановление из дампа. Из корня репозитория TZ в cmd/PowerShell:

```cmd
set PGPASSWORD=12345
psql -h localhost -U postgres -d postgres -c "CREATE DATABASE ias_vniic WITH ENCODING 'UTF8' TEMPLATE template0;"
psql -h localhost -U postgres -d ias_vniic -f "db\IAS_VNIIC_dump.sql"
```

(Путь к дампу замените на свой, например `d:\Projects\TZ\db\IAS_VNIIC_dump.sql`.) Приложение настроено на эту БД в `config/db.php` (dbname=ias_vniic, search_path=tech_accounting).

**Создание ias_vniic из DDL-схемы (без дампа):**

```cmd
set PGPASSWORD=12345
psql -h localhost -U postgres -d postgres -c "CREATE DATABASE ias_vniic WITH ENCODING 'UTF8' TEMPLATE template0;"
psql -h localhost -U postgres -d ias_vniic -f "scripts\create_ias_vniic.sql"
```

## 3. Настройка приложения

### 3.1. Конфигурация БД

Файл `config/db.php` настроен на целевую БД:

- `dsn`: `pgsql:host=localhost;dbname=ias_vniic`
- `username`: `postgres`
- `password`: `12345`
- при открытии соединения устанавливается `search_path=tech_accounting`

При других учётных данных или другом хосте измените эти значения в `config/db.php`.

### 3.2. Установка зависимостей

В каталоге **ias_uch_vnii** (не в TZ):

```cmd
cd d:\Projects\TZ\ias_uch_vnii

composer install
npm install
xcopy /E /I /Y node_modules\ag-grid-community web\ag-grid-community
```

Или выполнить один скрипт из корня TZ:

```cmd
scripts\setup_ias_uch_vnii_app.cmd
```

### 3.3. Каталоги runtime и загрузок

Убедитесь, что существуют и доступны для записи:

- `runtime` (и при необходимости `runtime/logs`)
- `web/assets`
- `web/uploads`

На Windows обычно достаточно, чтобы папки существовали; при необходимости создайте их вручную.

## 4. Запуск

### 4.1. Встроенный PHP-сервер (для разработки)

В каталоге **ias_uch_vnii**:

```cmd
php yii serve --port=8080
```

Откройте в браузере: **http://localhost:8080**

Корень сайта должен указывать на каталог `web` (в Yii basic template `php yii serve` это делает автоматически).

### 4.2. Через IIS или Apache (опционально)

- **IIS:** укажите корень сайта на каталог `ias_uch_vnii/web`, настройте URL Rewrite по образцу `web/.htaccess` (или аналог для IIS).
- **Apache:** DocumentRoot — `ias_uch_vnii/web`, включите mod_rewrite и учтите настройки из `web/.htaccess`.

## 5. Учётные записи по умолчанию

После восстановления дампа:

| Роль         | Логин  | Пароль   |
|-------------|--------|----------|
| Администратор | admin  | admin123 |
| Пользователь  | user   | user123  |

Рекомендуется сменить пароли после первого входа.

## 6. Дополнительно

- **Экспорт в Excel:** для работы PHPSpreadsheet нужна PHP-расширение **gd**. В XAMPP раскомментируйте в `php.ini`: `extension=gd`.
- **Запуск сервера одним скриптом:** из корня TZ выполните `scripts\run_ias_uch_vnii.cmd` (в скрипте по умолчанию используется `C:\xampp\php\php.exe`).

## 7. Проверка

1. Открыть http://localhost:8080 (или ваш хост/порт).
2. Войти под `admin` / `admin123`.
3. Проверить разделы: заявки, пользователи, активы (АРМ).

При ошибках смотреть логи: `ias_uch_vnii/runtime/logs/app.log`.

## 8. Два окружения (ПК + ВМ)

Если проект ранее был развёрнут на виртуальной машине и вы подключаетесь к ней:

- **Локально (Windows):** разверните по этой инструкции в `d:\Projects\TZ\ias_uch_vnii`.
- **На ВМ:** оставьте существующее окружение (Linux, например /var/www/ias_uch_vnii).

Общие моменты для обоих окружений:

- Один и тот же репозиторий (код синхронизируется через git или копирование).
- Одинаковые учётные данные БД в `config/db.php` (на ВМ — свои host/пароль при удалённой БД).
- Дамп БД: один и тот же файл `db/IAS_VNIIC_dump.sql` для первоначальной инициализации (или DDL `scripts/create_ias_vniic.sql`).

При необходимости можно вынести общие шаги (создание БД, composer, npm) в скрипты с параметрами (путь к проекту, хост/пароль БД) и использовать их и на Windows, и на ВМ.
