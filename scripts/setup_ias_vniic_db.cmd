@echo off
chcp 65001 >nul
setlocal

:: Настройки подключения (те же, что для других скриптов — при необходимости измените)
set PGPASSWORD=12345
set PGHOST=localhost
set PGUSER=postgres
set DBNAME=IAS_VNIIC

:: Корень репозитория: скрипт в scripts\, схема — рядом
set "SCRIPTS_DIR=%~dp0"
set "SCHEMA_FILE=%SCRIPTS_DIR%create_ias_uch_db_test.sql"

echo [1/2] Создание базы данных "%DBNAME%"...
psql -h %PGHOST% -U %PGUSER% -d postgres -t -c "SELECT 1 FROM pg_database WHERE datname='%DBNAME%'" 2>nul | findstr /q 1
if %ERRORLEVEL% equ 0 (
  echo База "%DBNAME%" уже существует. Схема будет применена поверх (IF NOT EXISTS).
) else (
  psql -h %PGHOST% -U %PGUSER% -d postgres -c "CREATE DATABASE \"%DBNAME%\" WITH ENCODING 'UTF8' TEMPLATE template0;"
  if %ERRORLEVEL% neq 0 (
    echo Ошибка создания базы. Проверьте, что PostgreSQL запущен и пользователь postgres имеет права.
    exit /b 1
  )
  echo База "%DBNAME%" создана.
)

echo [2/2] Применение схемы tech_accounting в "%DBNAME%"...
psql -h %PGHOST% -U %PGUSER% -d "%DBNAME%" -f "%SCHEMA_FILE%"
if %ERRORLEVEL% neq 0 (
  echo Ошибка применения схемы.
  exit /b 1
)

echo.
echo Готово. БД "%DBNAME%" развёрнута (хост: %PGHOST%, пользователь: %PGUSER%, схема: tech_accounting).
echo Для приложения: dbname=%DBNAME%, search_path=tech_accounting
endlocal
