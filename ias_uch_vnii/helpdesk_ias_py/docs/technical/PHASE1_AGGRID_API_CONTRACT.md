# Фаза 1 — Контракт API под AG Grid (как есть в Yii2)

Цель документа: зафиксировать **фактический** контракт (эндпоинты/форматы), который сейчас использует фронтенд `web/js/tasks/ag-grid.js`, чтобы на Django/DRF воспроизвести совместимое поведение.

Важно:
- Сейчас грид работает в режиме **клиентской фильтрации**: API отдает **все** записи (`pagination=false` на сервере).
- Для enterprise-варианта это будет переработано на **server-side pagination/filter/sort**, но это уже целевое улучшение (после фиксации контракта).

## 1) Данные для грида заявок

### 1.1. Endpoint

`GET /index.php?r=tasks/get-grid-data`

Источник: `controllers/TasksController.php::actionGetGridData()` и `views/tasks/index-aggrid.php` (передача `window.agGridDataUrl`).

### 1.2. Query params (поддерживаются бэкендом через `TasksSearch`)

Формально принимает `$_GET` и прогоняет через `TasksSearch::search($this->request->queryParams)`.

Из `models/search/TasksSearch.php` следуют поддерживаемые поля (примерно):
- `TasksSearch[id]` (int)
- `TasksSearch[id_status]` (int)
- `TasksSearch[id_user]` (int)
- `TasksSearch[executor_id]` (int)
- `TasksSearch[description]` (string, like)
- `TasksSearch[comment]` (string, like)
- `TasksSearch[date_from]` / `TasksSearch[date_to]` (yyyy-MM-dd)
- `TasksSearch[user_name]` (string, like по `users.full_name`)
- `TasksSearch[executor_name]` (string, like по `executor.full_name`)

Примечание: текущий `web/js/tasks/ag-grid.js` эти параметры **не отправляет** — фильтрация выполняется на клиенте.

### 1.3. Ответ (JSON)

```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "description": "…",
      "status_id": 1,
      "status_name": "Открыта",
      "user_id": 301,
      "user_name": "Иванов И.И.",
      "executor_id": 302,
      "executor_name": "Петров П.П.",
      "date": "27.10.2025 11:44",
      "last_time_update": "28.10.2025 09:10",
      "comment": "…",
      "attachments": [
        {
          "id": 55,
          "name": "scan.pdf",
          "icon": "fa-file-pdf",
          "is_previewable": true,
          "preview_url": "/index.php?r=tasks/preview&id=55",
          "download_url": "/index.php?r=tasks/download&id=55"
        }
      ]
    }
  ],
  "total": 1
}
```

### 1.4. Правила видимости данных (фактические)

`TasksSearch`:
- **Администратор** (`Yii::$app->user->identity->isAdministrator() == true`) видит все заявки.
- Иначе видит только свои (`WHERE tasks.id_user = current_user_id`).

## 2) Изменение статуса заявки (AJAX)

`POST /index.php?r=tasks/change-status&id={task_id}`

Body (FormData):
- `status_id` (int)
- `_csrf` (string)

Ответ:

```json
{ "success": true, "message": "…", "status_name": "…" }
```

## 3) Назначение исполнителя (AJAX)

`POST /index.php?r=tasks/assign-executor&id={task_id}`

Body:
- `executor_id` (int|string; пустое значение трактуется как null)
- `_csrf`

Ответ:

```json
{ "success": true, "message": "…", "executor_name": "…" }
```

## 4) Обновление комментария (AJAX)

`POST /index.php?r=tasks/update-comment&id={task_id}`

Body:
- `comment` (string)
- `_csrf`

Ответ:

```json
{ "success": true, "message": "…" }
```

## 5) Данные по технике пользователя (Detail panel в гриде)

`GET /index.php?r=tasks/get-user-equipment&userId={user_id}`

Ответ:

```json
{
  "success": true,
  "data": [
    {
      "id": 103,
      "name": "АРМ-301",
      "location": "Каб. 101",
      "description": "…",
      "created_at": "2025-10-27 11:44:19"
    }
  ],
  "total": 1
}
```

## 6) Вложения: скачивание и предпросмотр

### 6.1. Скачивание

`GET /index.php?r=tasks/download&id={attachment_id}`

### 6.2. Предпросмотр (inline)

`GET /index.php?r=tasks/preview&id={attachment_id}`

Типы предпросмотра на фронте:
- `pdf` → iframe
- `png/jpg/jpeg/gif/bmp/svg` → img

## 7) Замечания для переноса (что важно сохранить/улучшить)

- В текущем API **нет серверной пагинации** (отдается всё). Для Django целевой вариант: поддержать server-side режим AG Grid, но на первом шаге можно воспроизвести контракт как есть.
- Эндпоинты изменения статуса/исполнителя/комментария **не содержат явной проверки роли** (ограничение сейчас в основном на уровне UI). В переносе это нужно закрыть RBAC.
- `preview` отдаёт SVG inline → потенциальный XSS. В переносе лучше запретить inline для SVG и опасных типов (или строгая санитизация).

