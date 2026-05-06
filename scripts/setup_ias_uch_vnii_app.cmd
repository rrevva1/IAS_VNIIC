@echo off
chcp 65001 >nul
setlocal

set "TZ_ROOT=%~dp0.."
set "PROJECT=%TZ_ROOT%\ias_uch_vnii"

if not exist "%PROJECT%\composer.json" (
  echo Ошибка: каталог проекта не найден или в нём нет composer.json: %PROJECT%
  exit /b 1
)

echo Рабочий каталог: %PROJECT%
cd /d "%PROJECT%"

echo [1/4] Composer install...
call composer install --no-interaction
if %ERRORLEVEL% neq 0 (
  echo Ошибка composer install.
  exit /b 1
)

echo [2/4] npm install...
call npm install
if %ERRORLEVEL% neq 0 (
  echo Ошибка npm install.
  exit /b 1
)

echo [3/4] Копирование ag-grid-community в web...
if not exist "web" mkdir web
xcopy /E /I /Y node_modules\ag-grid-community web\ag-grid-community >nul 2>&1
if %ERRORLEVEL% neq 0 (
  echo Предупреждение: не удалось скопировать ag-grid-community. Проверьте наличие node_modules\ag-grid-community.
) else (
  echo ag-grid-community скопирован.
)

echo [4/4] Проверка каталогов runtime, web\assets, web\uploads...
if not exist "runtime" mkdir runtime
if not exist "runtime\logs" mkdir runtime\logs
if not exist "web\assets" mkdir web\assets
if not exist "web\uploads" mkdir web\uploads
echo Каталоги готовы.

echo.
echo Установка зависимостей завершена.
echo Запуск (из каталога ias_uch_vnii): php yii serve --port=8080
echo Документация: ias_uch_vnii\docs\guides\РАЗВЕРТЫВАНИЕ_WINDOWS.md
endlocal
