# Микросервис ИИ-помощника (Python)

Обработка запросов диалогового помощника ИАС УТС: парсинг интентов и выборка данных из PostgreSQL с учётом прав (RBAC).

## Зависимости

- Python 3.9+
- PostgreSQL (та же БД, что и у основного приложения Yii2)

## Установка

```bash
cd assistant_api
pip install -r requirements.txt
```

## Переменные окружения

| Переменная    | Описание           | По умолчанию   |
|---------------|--------------------|----------------|
| DB_HOST       | Хост PostgreSQL    | localhost      |
| DB_PORT       | Порт               | 5432           |
| DB_NAME       | Имя БД             | ias_vniic      |
| DB_USER       | Пользователь       | postgres       |
| DB_PASSWORD   | Пароль             | 12345          |
| DB_SCHEMA     | Схема (таблицы)    | tech_accounting |

В основном приложении (PHP) в `config/params.php` задаётся `assistantApiUrl` (по умолчанию `http://127.0.0.1:8000`). Можно переопределить через переменную окружения `ASSISTANT_API_URL`.

## Запуск

Из каталога `assistant_api`:

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

Или на Windows двойной клик по `run.bat` (если Python в PATH, иначе выполнить в терминале: `python -m uvicorn main:app --host 0.0.0.0 --port 8000`).

Проверка: `GET http://127.0.0.1:8000/health` → `{"status":"ok"}`.

## API

- **POST /query** — тело JSON: `{ "message": "текст запроса", "user_id": 1, "is_admin": false, "is_operator": false }`. Ответ: `success`, `interpretation`, `data`, `total`, `link` (path + params; PHP собирает полный URL), при необходимости `hints`, `helpText`, `summary`.

Логика прав: при `is_admin` или `is_operator` отдаются все заявки; иначе только заявки, где пользователь автор или исполнитель.
