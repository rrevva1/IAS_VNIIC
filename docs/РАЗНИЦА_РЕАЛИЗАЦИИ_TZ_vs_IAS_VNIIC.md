# Разница в реализации по коду: TZ (эта машина) и IAS_VNIIC (домашний Mac)

Два варианта одного проекта:
- **TZ** — `d:\Projects\TZ` (разработка на этой машине).
- **IAS_VNIIC** — `d:\Projects\IAS_VNIIC` (домашний Mac).

Ниже — отличия по контроллерам, моделям, миграциям, компонентам и представлениям.

---

## 1. Контроллеры

| Компонент | TZ (эта машина) | IAS_VNIIC (Mac) |
|-----------|------------------|------------------|
| **ReferencesController** | Есть. Модуль справочников (ТЗ 5.1.2): статусы заявок, статусы оборудования, локации. CRUD + архивация (task-status, equipment-status, locations). | Нет. |
| **AuditController** | Есть. Сырой `Query` по `audit_events`, limit 500, отдельный запрос по акторам (топ-100). Нет модели, нет пагинации. | Есть. Модель `AuditEvent`, `ActiveDataProvider`, пагинация 50, фильтры (дата, пользователь, тип действия, тип объекта), список пользователей для фильтра. |
| **SoftwareController** | Полный функционал: список, просмотр, создание/редактирование/удаление ПО; CRUD лицензий; CRUD установок (оборудование ↔ ПО). Фильтры: по имени, по истекающим лицензиям (`expiring_days`). Страница «нужна миграция» при отсутствии таблиц. | Только список: `actionIndex()` — вывод ПО и лицензий, без CRUD и без фильтров. |
| Остальные контроллеры | Site, HelpDesk, Users, Tasks, Arm, Import — есть в обоих. | Те же. |

---

## 2. Модели

| Модель | TZ | IAS_VNIIC |
|--------|-----|-----------|
| **AuditEvent** | Нет (используется сырой запрос). | Есть. ActiveRecord для чтения `audit_events`. |
| **SoftwareInstall** | Есть (таблица `software_installs`). | Нет. |
| **EquipmentSoftware** | Нет. | Есть (таблица `equipment_software`). |
| **ImportError, ImportRun** | Есть. | В списке моделей не фигурировали (могут быть в другом месте или не использоваться). |
| **DicEquipmentType** | Есть. | Нет. |
| **SprChars, SprParts** | Есть (entities). | Есть в структуре (spr_chars, spr_parts в БД); при необходимости проверить наличие классов. |
| Остальные сущности | Users, Tasks, Equipment, License, Software, Location, TaskHistory, EquipHistory, PartCharValues, DeskAttachments, TaskAttachments, TaskEquipment, UserRoles, Roles, Arm, DicTaskStatus, DicEquipmentStatus и т.д. | Аналогичный набор, с заменой SoftwareInstall → EquipmentSoftware и добавлением AuditEvent. |

---

## 3. Миграции

| Миграция | TZ | IAS_VNIIC |
|----------|-----|-----------|
| **m260212_100000_insert_initial_admin_user** | Есть. | Есть. |
| **m260213_120000** | `create_software_tables`: создаёт `software` (с полями license_keys, description, is_archived, updated_at), `licenses` (valid_from, valid_until NOT NULL, license_key, updated_at), `software_installs` (equipment_id, software_id, installed_at, notes, UNIQUE(equipment_id, software_id)). TIMESTAMPTZ для дат. | `add_software_licenses`: создаёт `software` (id, name, version, created_at), `licenses` (software_id, valid_until, notes, created_at), `equipment_software` (equipment_id, software_id, installed_at, created_at). Без valid_from, license_key, без таблицы software_installs. |
| **m260213_140000_create_task_history** | Есть. | Нет (таблица task_history, видимо, уже есть в общей схеме из скрипта). |
| **m260213_150000_create_import_tables** | Есть. | Нет. |
| **m260213_160000_equipment_types** | Есть. | Нет. |

Итог: в TZ схема «ПО и лицензии» и импорт/история/типы оборудования вынесены в отдельные миграции; в IAS_VNIIC база ближе к одному общему скрипту (например, create_ias_vniic.sql) + одна миграция только на software/licenses/equipment_software.

---

## 4. Компонент AuditLog

| Аспект | TZ | IAS_VNIIC |
|--------|-----|-----------|
| Сигнатура | `log($actionType, $objectType, $objectId, $payload = null, $resultStatus = 'success', $errorMessage = null)` — payload перед resultStatus. | `log($actionType, $objectType, $objectId, $resultStatus = 'success', $payload = null, $errorMessage = null)` — resultStatus перед payload. |
| Возврат | `bool` (успех/неуспех). | `void`. |
| Валидация resultStatus | Проверка success/error/denied. | Нет явной проверки. |
| user_agent length | До 1000 символов. | До 500 символов. |

Вызовы в коде из-за разного порядка параметров несовместимы между версиями: в TZ передаётся payload четвёртым аргументом, в IAS_VNIIC — пятым (после resultStatus).

Где вызывается AuditLog:

| Действие | TZ | IAS_VNIIC |
|----------|-----|-----------|
| task.create / update / delete | Да. | Да. |
| attachment.delete | Да. | Да. |
| task.change_status, task.assign_executor, task.update_comment | Да. | Нет. |
| software.create / update / delete | Да. | Нет. |
| license.create / update / delete | Да. | Нет. |
| equipment.create / update | Да. | Да. |
| equipment.delete | Да. | Нет. |
| user.password_reset | Да. | Да. |

---

## 5. Представления (views)

| Раздел | TZ | IAS_VNIIC |
|--------|-----|-----------|
| **Меню (layouts/main)** | Пункты: Аудит, ПО и лицензии, Справочники (references). | Пункты: Аудит, ПО и лицензии. Нет пункта «Справочники». |
| **audit** | Один view (index) — вывод строк и списка акторов. | Один view (index) — список с фильтрами и пагинацией. |
| **software** | index, view, form, license-form, migrate-required. | Только index. |
| **references** | index, task-status, task-status-form, equipment-status, equipment-status-form, locations, location-form. | Нет каталога/модуля references. |

---

## 6. Конфигурация (config)

| Параметр | TZ | IAS_VNIIC |
|----------|-----|-----------|
| session.name | Стандартный. | `PHPSESSID_<port>` — разная сессия по порту (удобно для двух учёток на 8080/8081). |
| user.identityCookie | Стандартный. | Разный по порту. |
| assetManager.appendTimestamp | Не проверялся. | Включён (версионирование JS/CSS). |

Остальная конфигурация (db, urlManager, модули) в целом совпадает.

---

## 7. Сводная таблица: что есть только в одной из версий

| Только в TZ (эта машина) | Только в IAS_VNIIC (Mac) |
|--------------------------|---------------------------|
| ReferencesController и весь модуль справочников (статусы заявок/оборудования, локации). | Модель AuditEvent. |
| Полный CRUD по ПО и лицензиям, установкам (SoftwareInstall / software_installs). | Модель EquipmentSoftware (вместо SoftwareInstall). |
| Таблица и модель software_installs; расширенные software/licenses (valid_from, license_key, is_archived, updated_at и т.д.). | Упрощённая схема software/licenses и equipment_software. |
| Миграции: create_task_history, create_import_tables, equipment_types. | — |
| Модели ImportError, ImportRun, DicEquipmentType. | — |
| AuditLog с расширенным покрытием (смена статуса заявки, назначение исполнителя, комментарий, все операции ПО/лицензий, удаление оборудования). | AuditLog с меньшим набором событий. |
| Разный порядок параметров в AuditLog::log и возврат bool. | Разный порядок параметров, возврат void. |

---

## 8. Рекомендации при сведении веток

1. **AuditLog** — привести к одной сигнатуре (например, как в TZ: payload перед resultStatus) и одному месту вызова; при слиянии кода обновить все вызовы под выбранный вариант.
2. **Справочники** — при переносе функционала с TZ в IAS_VNIIC скопировать ReferencesController и views/references, добавить пункт меню.
3. **ПО и лицензии** — при переносе с TZ: учесть разницу таблиц (software_installs vs equipment_software, расширенные поля software/licenses); либо привести БД к одному варианту и один раз переименовать модель SoftwareInstall ↔ EquipmentSoftware и представления.
4. **Аудит** — в IAS_VNIIC уже удобнее (модель + пагинация + фильтры); при слиянии оставить реализацию аудита из IAS_VNIIC, при необходимости добавить из TZ дополнительные вызовы AuditLog (смена статуса, назначение исполнителя, комментарий, удаление оборудования, операции по ПО/лицензиям).
5. **Миграции** — не смешивать порядок; решить, какая схема БД эталонная (TZ с software_installs и расширенными полями или IAS_VNIIC с equipment_software и минимальными полями), и довести вторую ветку до неё через отдельные миграции.

Документ подготовлен по состоянию кода в каталогах `d:\Projects\TZ\ias_uch_vnii` и `d:\Projects\IAS_VNIIC\ias_uch_vnii`.

---

## 9. Рекомендация: не сливать ветки, а взять одну базу и доработать

**Не рекомендую** делать полное слияние двух репозиториев (git merge или копирование всего кода из одного в другой): разная схема БД (software_installs vs equipment_software, разные поля), разная сигнатура AuditLog и разный набор миграций дадут массу конфликтов и риски поломать уже работающую версию.

**Рекомендую:** считать основной кодовой базой **IAS_VNIIC** (как ту, что уже с дампом и данными с Mac) и **точечно переносить** в неё только нужный функционал из TZ. Так вы сохраняете одну историю, одну схему БД и контролируете, что именно попадает в проект.

### Шаги

1. **Зафиксировать эталон БД**  
   Оставить текущую схему IAS_VNIIC (таблицы `software`, `licenses`, `equipment_software` без расширений). Не вводить таблицу `software_installs` и не менять названия — меньше миграций и путаницы.

2. **Перенести модуль «Справочники» из TZ**  
   - Скопировать `ReferencesController` и папку `views/references` из TZ в IAS_VNIIC.  
   - Добавить пункт меню «Справочники» в `views/layouts/main.php`.  
   - Проверить, что в IAS_VNIIC есть модели/таблицы, которые использует ReferencesController (DicTaskStatus, DicEquipmentStatus, Location и т.д.) — они уже есть из общей схемы.

3. **Расширить ПО и лицензии в IAS_VNIIC без смены таблиц**  
   Не переходить на схему TZ (software_installs, valid_from, license_key и т.д.). В текущих таблицах `software`, `licenses`, `equipment_software`:  
   - Добавить в IAS_VNIIC недостающие экшены: создание/редактирование/удаление ПО, CRUD лицензий, привязка ПО к оборудованию (через `equipment_software`).  
   - Взять логику и формы из TZ (SoftwareController, views/software), но адаптировать под модели `Software`, `License`, `EquipmentSoftware` и текущие поля БД. При необходимости добавить в БД отдельные поля (например `valid_from`, `notes`) через одну новую миграцию, не переименовывая таблицы.

4. **Оставить аудит и AuditLog как в IAS_VNIIC**  
   Не менять реализацию AuditController (модель AuditEvent, пагинация, фильтры).  
   Расширить только **вызовы** AuditLog в контроллерах: добавить логирование смены статуса заявки, назначения исполнителя, комментария, удаления оборудования, операций по ПО/лицензиям — по образцу TZ, но с **текущей** сигнатурой в IAS_VNIIC:  
   `AuditLog::log($actionType, $objectType, $objectId, $resultStatus, $payload, $errorMessage)`.

5. **Не трогать миграции TZ**  
   В IAS_VNIIC не подмешивать миграции из TZ (import, task_history, equipment_types, create_software_tables). Если нужны таблицы импорта или типы оборудования — добавить новые миграции в IAS_VNIIC, при необходимости опираясь на логику TZ, но с именами и порядком, принятыми в IAS_VNIIC.

6. **TZ держать как референс**  
   Репозиторий TZ не удалять: использовать его как образец логики и представлений при переносе. После переноса нужных фич разработку вести только в IAS_VNIIC.

Итог: **не сливать**, а **доработать IAS_VNIIC**, перенося из TZ только выбранный функционал (справочники, расширенный CRUD по ПО/лицензиям, дополнительные события аудита) с явной адаптацией под текущую схему и API.
