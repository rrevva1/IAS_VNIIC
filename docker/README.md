# Запуск проекта ИАС УТС ВНИИЦ в Docker

Вся конфигурация Docker сосредоточена в этой папке. Запуск даёт одинаковое окружение на любой ОС (Windows, macOS, Linux).

**К какой БД подключается приложение:** при запуске `docker compose up -d` поднимается **своя** PostgreSQL в контейнере. Приложение подключается к этой БД (данные при первом запуске берутся из дампа `../db/ias_vniic_mac_15_02_26.sql`). Это **не** та PostgreSQL, что может быть установлена на машине отдельно — в Docker используется отдельная БД «внутри» Docker. Если нужно использовать уже существующую БД на рабочем компе — см. раздел «Использование своей БД на хосте» в конце.

---

## После git pull на рабочей машине

**На Windows:** установите [Docker Desktop для Windows](https://www.docker.com/products/docker-desktop/), перезагрузите ПК при запросе, затем запустите Docker Desktop (иконка в трее). Команды ниже выполняйте в **PowerShell** или **CMD** — они одинаковые. Копирование `.env`: в CMD — `copy .env.example .env`, в PowerShell — `Copy-Item .env.example .env`.

1. **Установить Docker** (если ещё нет): [Docker Desktop](https://www.docker.com/products/docker-desktop/) — установить и запустить (на Windows после установки Docker Desktop должен быть запущен и в трее отображаться «Docker is running»).

2. **Открыть терминал** в корне проекта (там, где папки `ias_uch_vnii`, `db`, `docker`). В Windows: правый клик по папке проекта → «Открыть в терминале» или в проводнике в адресной строке ввести `cmd` / `powershell` и Enter.

3. **Перейти в папку docker и запустить:**
   ```bash
   cd docker
   docker compose up -d
   ```
   Подождать 1–2 минуты при первом запуске (инициализация БД из дампа).

4. **Один раз установить зависимости приложения:**
   ```bash
   docker compose exec php composer install --no-interaction -d /app
   ```

5. **Открыть в браузере:** http://localhost:8000  
   Войти можно под **admin / admin123** — этот пользователь уже есть в дампе БД, отдельно создавать его не нужно. Миграции (`yii migrate`) запускайте только если в проекте появились новые миграции и их нужно применить.

Дальше при каждом включении рабочего компа достаточно: `cd docker` → `docker compose up -d`. Файлы проекта лежат в репозитории как обычно; Docker только поднимает БД и веб-сервер — код вы правите в папке `ias_uch_vnii` на диске, изменения сразу видны в браузере.

---

## Требования

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows/macOS) или Docker Engine + Docker Compose (Linux)
- Клонированный репозиторий с каталогами `ias_uch_vnii` и `db` на уровень выше этой папки

## Первый запуск на новой машине

1. Перейдите в папку **docker** (от корня проекта: `cd docker`).

2. При необходимости задайте свои параметры (пароль БД, порты):
   ```bash
   cp .env.example .env
   # Отредактируйте .env при необходимости
   ```

3. Запустите контейнеры:
   ```bash
   docker compose up -d
   ```
   При первом запуске БД инициализируется из дампа `../db/ias_vniic_mac_15_02_26.sql` (1–2 минуты).

4. Установите зависимости PHP (один раз на новой машине):
   ```bash
   docker compose exec php composer install --no-interaction -d /app
   ```

5. Пользователь **admin / admin123** уже есть в дампе БД — создавать его не нужно. Миграции выполняйте только при появлении новых миграций в проекте.

6. При необходимости скопируйте AG Grid в веб-каталог (если в проекте используется):
   ```bash
   docker compose exec php sh -c 'cd /app && npm install && cp -r node_modules/ag-grid-community web/ag-grid-community' 2>/dev/null || true
   ```
   Если Node.js в образе нет — выполните `npm install` и `cp -r node_modules/ag-grid-community web/ag-grid-community` на хосте в каталоге `ias_uch_vnii`.

7. Откройте в браузере: **http://localhost:8000** (или другой порт из `APP_PORT` в `.env`).

## Обычный запуск (уже настроено)

```bash
cd docker
docker compose up -d
```

Приложение: **http://localhost:8000**

## Остановка

```bash
cd docker
docker compose down
```

Данные БД хранятся в томе Docker и сохраняются между запусками.

## Полезные команды

| Действие              | Команда |
|-----------------------|--------|
| Логи                  | `docker compose logs -f` |
| Логи только БД        | `docker compose logs -f db` |
| Войти в контейнер PHP | `docker compose exec php bash` |
| Миграции              | `docker compose exec php php /app/yii migrate --migrationPath=@app/migrations` |

## Структура папки docker

- `docker-compose.yml` — описание сервисов (БД, приложение)
- `.env.example` — пример переменных окружения (скопировать в `.env`)
- `init/01-init.sh` — скрипт инициализации БД из дампа
- `README.md` — эта инструкция

Переменные окружения (в т.ч. из `.env`) передаются в контейнеры; приложение читает их в `ias_uch_vnii/config/db.php` и подключается к контейнеру БД по имени сервиса `db`.

---

## Использование своей БД на хосте (без контейнера db)

Если на рабочей машине уже установлена PostgreSQL с нужной БД (ias_vniic, схема tech_accounting) и вы хотите, чтобы приложение в Docker подключалось именно к ней:

1. В папке `docker` создайте файл `docker-compose.override.yml`:
   ```yaml
   version: '3.8'
   services:
     db:
       profiles: ['never']
     php:
       environment:
         DB_HOST: host.docker.internal
         DB_NAME: ias_vniic
         DB_USER: postgres
         DB_PASSWORD: "ваш_пароль_от_PostgreSQL_на_хосте"
   ```
   Укажите реальные имя БД, пользователя и пароль от вашей PostgreSQL на хосте.

2. Запуск: `docker compose up -d`. Контейнер БД не поднимется, приложение подключится к БД на хосте по `host.docker.internal:5432`. На Windows и macOS этот адрес указывает на саму машину с контейнера.
