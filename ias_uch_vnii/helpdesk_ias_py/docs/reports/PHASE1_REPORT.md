# Отчет: Фаза 1 (анализ и проектирование) — текущий прогресс

Дата: 2026-02-07

## Что сделано

- Подготовлена отдельная папка для Python‑переноса: `helpdesk_ias_py/` (не пересекается с текущим Yii2 проектом).
- Найден и проанализирован legacy дамп `ias_uch_vnii_public_dump.sql`.
- Дополнительно проверена локальная БД `ias_vnii` (действительно близкая по предметной области, но с более корректными именами полей/таблиц).
- Принято решение использовать **`ias_vnii` как baseline** для проектирования целевой схемы, а legacy дамп — как источник данных для будущей миграции.
- Зафиксированы артефакты Фазы 1:
  - baseline/маппинг имен,
  - ERD (Mermaid),
  - gaps (дамп ↔ миграции ↔ код),
  - контракт API под AG Grid,
  - RBAC матрица (as-is + target).

## Где смотреть артефакты

Индекс: `helpdesk_ias_py/docs/README.md`

Ключевые документы:
- `helpdesk_ias_py/docs/technical/PHASE1_DB_BASELINE.md`
- `helpdesk_ias_py/docs/technical/PHASE1_ERD.md`
- `helpdesk_ias_py/docs/technical/PHASE1_GAPS.md`
- `helpdesk_ias_py/docs/technical/PHASE1_AGGRID_API_CONTRACT.md`
- `helpdesk_ias_py/docs/technical/PHASE1_RBAC_MATRIX.md`

## Критичные находки (коротко)

- **Дрейф схемы**: миграции Yii2 создают `users.fio`, но фактические БД/код используют `users.full_name`.
- **Роли проверяются двумя способами** (по id и по role_name) — потенциальная рассинхронизация.
- **Статусы**: в коде есть “магические” id (например, 4 = “Завершено”), но в `ias_vnii` “Завершено” имеет id 6.
- **Пароли**: в Yii2 модель “обновляет” MD5, но `setPassword()` снова пишет MD5 — фактически MD5 сохраняется.
- **AG Grid API** сейчас отдает все задачи без пагинации; изменения выполняются без явного RBAC на сервере.
- **Inline preview SVG** потенциально опасен (XSS).

