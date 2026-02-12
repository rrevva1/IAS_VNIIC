# Фаза 1 — Расхождения (gaps): дамп ↔ миграции ↔ код

Цель: зафиксировать несоответствия между:
- **legacy дампом** `ias_uch_vnii_public_dump.sql`,
- **baseline БД** `ias_vnii` (более корректная схема/имена),
- **Yii2 миграциями** из `migrations/`,
- **Yii2 кодом** (models/controllers/views/js).

## 1) Схема БД: именование и структура

### 1.1. `arm` vs `equipment`

- В legacy дампе есть `public.arm` / `arm_history`.
- В baseline БД вместо этого `public.equipment` / `equip_history`.

**Решение для проекта переноса**:
- В целевой модели Django используем доменное имя **Asset/Equipment** (например, `Equipment`/`Asset`), а legacy `arm` считаем историческим названием.

### 1.2. Имена PK/FK: `id_user`/`id_role`/`id_status` vs `id`/`role_id`/`status_id`

Legacy дамп и часть Yii2 кода используют:
- `users.id_user`, `users.id_role`
- `roles.id_role`
- `tasks.id_status`, `dic_task_status.id_status`

Baseline БД `ias_vnii` использует более современный стиль:
- `users.id`, `users.role_id`
- `roles.id`
- `tasks.status_id`, `dic_task_status.id`

**Решение**:
- Для проектирования и целевой схемы принимаем baseline (`ias_vnii`), а в миграции данных делаем маппинг.

## 2) FK/индексы/constraints

### 2.1. FK на `tasks.executor_id`

Наблюдение:
- В Yii2 миграции `m251023_104012_update_tasks_table_add_executor_and_attachments.php` добавляется FK `tasks.executor_id -> users.id`.
- В baseline схеме (снятая через `pg_dump -s`) FK на `executor_id` **отсутствует**, есть только индекс `idx_tasks_executor_id`.

Риски:
- Возможны “битые” executor_id (не существующие пользователи).

Решение:
- В целевой Django схеме делаем FK `executor -> users` (nullable) и в миграции данных валидируем ссылки.

### 2.2. Уникальность статусов

Baseline:
- `dic_task_status.status_name` — UNIQUE.

Legacy и код:
- Код местами опирается на фиксированные id статусов (см. ниже), что небезопасно.

Решение:
- В переносе использовать **словарь статусов** с устойчивыми ключами (например, `code`), либо миграцию статусов с фиксированными id и документировать их.

## 3) Миграции Yii2 vs фактическая схема/код

### 3.1. Миграция users: поле `fio` vs код `full_name`

`m251022_193201_create_users_table.php` создаёт:
- `users.fio`

Фактические БД и код используют:
- `users.full_name`

Решение:
- В Python-переносе фиксируем: имя поля **`full_name`** (как в baseline/legacy).
- Миграции Yii2 считаем “дрейфующими” и не используем как эталон.

### 3.2. Миграция roles/users: `id`/`role_id` vs код `id_role`

Миграции создают `roles.id`, `users.role_id`, но код активно использует `id_role`.

Решение:
- В переносе принять baseline (role_id), а в legacy-части учитывать маппинг.

### 3.3. Таблица `task_attachments`

В `models/entities/Tasks.php` есть связь через `viaTable('task_attachments', ...)`, но:
- в legacy схеме attachments хранятся JSON-строкой в `tasks.attachments`.
- в списке миграций нет явного создания `task_attachments` (по текущему анализу).

Решение:
- В Django-схеме сразу проектируем нормализованную связь `TaskAttachment` и мигрируем из JSON.

## 4) Код и безопасность (важное для переноса)

### 4.1. Пароли: “обновление” vs фактический MD5

`Users::validatePassword()`:
- поддерживает старый MD5 и пытается “обновить” хеш при логине.

Но `Users::setPassword()`:
- устанавливает **MD5** (`$this->password = md5($password);`).

Итого:
- даже при “обновлении” остаётся MD5.

Решение:
- В Django: хеширование только стандартными hasher’ами (argon2/bcrypt).
- Legacy MD5: прозрачный апгрейд при логине (как описано в `ПЛАН.md`), но сохранять MD5 в новой системе нельзя.

### 4.2. Тестовые/опасные эндпоинты

`UsersController` содержит:
- `actionTestPasswords()` — выводит информацию о хешах
- `actionResetPassword()` — устанавливает фиксированный пароль `password123` и показывает его

Решение:
- В переносе такие эндпоинты **не переносить** (либо строго dev-only с отключением в prod).

### 4.3. Предпросмотр SVG inline

`TasksController::actionPreview()` отдаёт `Content-Disposition: inline` и разрешает `svg`.

Риск:
- XSS через SVG.

Решение:
- В переносе запретить inline для SVG (или хранить/отдавать как attachment) и добавить `X-Content-Type-Options: nosniff`.

## 5) Логика ролей: id vs name

В коде используются оба подхода:
- `Users::isAdmin()` проверяет `id_role == 5`
- `Users::isAdministrator()` проверяет `role_name === 'администратор'`

Риск:
- рассинхронизация (если id не совпадёт, либо появится новая роль/локализация).

Решение:
- В переносе единый подход: Django Groups + permissions, а роль “администратор” — группа.

## 6) Статусы: несовпадение id между БД и кодом

В `TasksController::actionStatistics()` используется:
- `where(['id_status' => 4]) // Статус "Завершено"`

Но в baseline `ias_vnii` “Завершено” имеет id `6` (по данным `dic_task_status`).

Решение:
- Перепроверить источники данных и уйти от “магических чисел” статусов.

