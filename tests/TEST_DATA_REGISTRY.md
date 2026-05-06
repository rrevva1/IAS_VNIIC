# Реестр тестовых данных (созданных скриптом seed_test_data.sql)

Данный файл фиксирует все записи, добавленные в БД скриптом `tests/seed_test_data.sql`, и содержит готовый скрипт удаления. После проверки функционала выполните удаление в указанном порядке.

---

## 1. Идентификация тестовых записей

Все тестовые данные используют **фиксированный диапазон ID 900001 и выше** (по таблицам ниже). Дополнительные маркеры:

| Таблица | Диапазон ID | Маркеры (для ручной проверки) |
|---------|-------------|-------------------------------|
| **locations** | 900001–900015 | 15 записей, `name` начинается с «Тест. кабинет» / «Тест. склад» / «Тест. серверная» и т.п. |
| **users** | 900001–900015 | 15 записей, `username` = seed_user_01 … seed_user_15 |
| **user_roles** | — | Связи для user_id 900001–900015 (удалять по user_id) |
| **spr_parts** | 900001–900010 | 10 записей, `name` начинается с «SEED » |
| **spr_chars** | 900001–900010 | 10 записей, `name` начинается с «SEED » |
| **equipment** | 900001–900020 | 20 записей, `inventory_number` = SEED-INV-001 … SEED-INV-020 |
| **part_char_values** | — | Записи с `equipment_id` 900001–900020 (удалять по equipment_id) |
| **tasks** | 900001–900020 | 20 записей, `task_number` = SEED-T-001 … SEED-T-020 |
| **task_equipment** | — | Связи по `task_id` 900001–900020 и `equipment_id` 900001–900020 |
| **equip_history** | — | Записи с `equipment_id` 900001–900020 |
| **task_history** | — | Записи с `task_id` 900001–900020 |
| **desk_attachments** | 900001–900005 | 5 записей, заглушки для теста вложений |
| **task_attachments** | — | Связи по `task_id` 900001–900005 и `attachment_id` 900001–900005 |
| **software** | 900001–900010 | 10 записей (если таблица есть), `name` = SEED-SW-1 … SEED-SW-10 |
| **licenses** | — | Записи с `software_id` 900001–900010 |
| **equipment_software** | — | Записи по `equipment_id` и `software_id` в тестовых диапазонах |
| **audit_events** | 900001–900015 | 15 записей, `action_type` = seed_test_action |

---

## 2. Удаление тестовых данных

Удалять **строго в порядке** ниже (сначала зависимые таблицы, затем основные).

Готовый SQL-скрипт: **`tests/remove_test_data.sql`**. Запуск:

```bash
psql -U postgres -d ias_vniic -f tests/remove_test_data.sql
```

Либо выполните блоки из раздела 3 вручную в указанном порядке.

---

## 3. Порядок и команды удаления (для ручного выполнения)

Выполняйте в одной сессии (или в одной транзакции), схема: `tech_accounting`.

1. **task_attachments** — связи заявка–вложение  
   `DELETE FROM tech_accounting.task_attachments WHERE task_id BETWEEN 900001 AND 900020;`

2. **task_equipment** — связи заявка–оборудование  
   `DELETE FROM tech_accounting.task_equipment WHERE task_id BETWEEN 900001 AND 900020;`

3. **task_history** — история заявок  
   `DELETE FROM tech_accounting.task_history WHERE task_id BETWEEN 900001 AND 900020;`

4. **equip_history** — история оборудования  
   `DELETE FROM tech_accounting.equip_history WHERE equipment_id BETWEEN 900001 AND 900020;`

5. **part_char_values** — значения характеристик  
   `DELETE FROM tech_accounting.part_char_values WHERE equipment_id BETWEEN 900001 AND 900020;`

6. **equipment_software** (если таблица есть)  
   `DELETE FROM tech_accounting.equipment_software WHERE equipment_id BETWEEN 900001 AND 900020 OR software_id BETWEEN 900001 AND 900010;`

7. **licenses** (если таблица есть)  
   `DELETE FROM tech_accounting.licenses WHERE software_id BETWEEN 900001 AND 900010;`

8. **software** (если таблица есть)  
   `DELETE FROM tech_accounting.software WHERE id BETWEEN 900001 AND 900010;`

9. **desk_attachments**  
   `DELETE FROM tech_accounting.desk_attachments WHERE id BETWEEN 900001 AND 900005;`

10. **audit_events**  
    `DELETE FROM tech_accounting.audit_events WHERE id BETWEEN 900001 AND 900015;`

11. **tasks**  
    `DELETE FROM tech_accounting.tasks WHERE id BETWEEN 900001 AND 900020;`

12. **equipment**  
    `DELETE FROM tech_accounting.equipment WHERE id BETWEEN 900001 AND 900020;`

13. **user_roles**  
    `DELETE FROM tech_accounting.user_roles WHERE user_id BETWEEN 900001 AND 900015;`

14. **users**  
    `DELETE FROM tech_accounting.users WHERE id BETWEEN 900001 AND 900015;`

15. **locations**  
    `DELETE FROM tech_accounting.locations WHERE id BETWEEN 900001 AND 900015;`

16. **spr_parts**  
    `DELETE FROM tech_accounting.spr_parts WHERE id BETWEEN 900001 AND 900010;`

17. **spr_chars**  
    `DELETE FROM tech_accounting.spr_chars WHERE id BETWEEN 900001 AND 900010;`

После удаления при необходимости сбросьте последовательности до текущего максимума ID (скрипт `remove_test_data.sql` это делает автоматически).

---

## 4. Учётные данные для входа (тестовые пользователи)

| Логин | Пароль | Роль |
|-------|--------|------|
| seed_user_01 … seed_user_13 | test123 | Пользователь |
| seed_user_14 | test123 | Оператор |
| seed_user_15 | test123 | Администратор |

Используйте только в тестовой среде. После удаления тестовых данных эти учётки исчезнут.
