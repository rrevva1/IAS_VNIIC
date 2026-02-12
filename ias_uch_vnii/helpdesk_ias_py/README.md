# IAS (перенос на Python/Django)

Эта папка содержит **новый проект переноса** IAS на Python/Django и **артефакты миграции**.

Важно:
- Исходный PHP/Yii2 проект **не трогаем и не удаляем**.
- Здесь ведём отдельную документацию и подготовку переноса.

## Документация
- `docs/README.md` — индекс документации.

## Django-проект (Фаза 2)

Код Django расположен в: `helpdesk_ias_py/helpdesk_ias/`

### Быстрый старт (dev)

1) Активировать виртуальное окружение:

```bash
source helpdesk_ias_py/.venv/bin/activate
```

2) Подготовить переменные окружения:

```bash
cp helpdesk_ias_py/helpdesk_ias/.env.example helpdesk_ias_py/helpdesk_ias/.env
```

3) Запустить проверки/сервер:

```bash
cd helpdesk_ias_py/helpdesk_ias
python manage.py check
python manage.py runserver
```

### Логи

Файлы логов пишутся в `helpdesk_ias_py/helpdesk_ias/logs/`:
- `app.log`
- `security.log`
- `audit.log`

## Фаза 1 (анализ и проектирование)
Артефакты Фазы 1 складываем в:
- `docs/technical/`
- `docs/reports/`
- `artifacts/phase1/`
