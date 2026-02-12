@echo off
chcp 65001 >nul
setlocal

:: Настройки БД (при необходимости измените)
set PGPASSWORD=12345
set PGHOST=localhost
set PGUSER=postgres
set DBNAME=ias_uch_vnii

:: Путь к дампу: скрипт лежит в scripts\, корень репозитория — на уровень выше
set "TZ_ROOT=%~dp0.."
set "DUMPFILE=%TZ_ROOT%\ias_uch_vnii\ias_uch_vnii_public_dump.sql"

echo [1/3] Проверка дампа: %DUMPFILE%
if not exist "%DUMPFILE%" (
  echo Ошибка: файл дампа не найден.
  echo Убедитесь, что запускаете скрипт из корня TZ: scripts\setup_ias_uch_vnii_db.cmd
  exit /b 1
)
echo Дамп найден.

echo [2/3] Создание базы данных %DBNAME%...
psql -h %PGHOST% -U %PGUSER% -t -c "SELECT 1 FROM pg_database WHERE datname='%DBNAME%'" 2>nul | findstr /q 1
if %ERRORLEVEL% equ 0 (
  echo База %DBNAME% уже существует. Восстановление перезапишет данные.
  set "RECREATE="
) else (
  psql -h %PGHOST% -U %PGUSER% -c "CREATE DATABASE %DBNAME% ENCODING 'UTF8';"
  if %ERRORLEVEL% neq 0 (
    echo Ошибка создания базы. Проверьте, что PostgreSQL запущен и пользователь postgres имеет права.
    exit /b 1
  )
  echo База %DBNAME% создана.
)

echo [3/3] Восстановление дампа в %DBNAME%...
psql -h %PGHOST% -U %PGUSER% -d %DBNAME% -f "%DUMPFILE%"
if %ERRORLEVEL% neq 0 (
  echo Ошибка восстановления дампа.
  exit /b 1
)

echo.
echo Готово. БД %DBNAME% развёрнута (хост: %PGHOST%, пользователь: %PGUSER%).
echo Для приложения используйте config/db.php: dbname=%DBNAME%
endlocal
