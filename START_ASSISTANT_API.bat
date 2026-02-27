@echo off
cd /d "%~dp0assistant_api"
echo ============================================
echo   ИИ-помощник (Assistant API) - порт 8000
echo ============================================
echo.
echo Проверка: http://127.0.0.1:8000/health
echo Остановка: Ctrl+C
echo.

REM Сначала пробуем python из PATH
python -m uvicorn main:app --host 127.0.0.1 --port 8000 2>nul
if %ERRORLEVEL% equ 0 goto :eof

py -3 -m uvicorn main:app --host 127.0.0.1 --port 8000 2>nul
if %ERRORLEVEL% equ 0 goto :eof

REM Путь к Python из Microsoft Store (подставьте свой путь при необходимости)
set PYEXE=%LOCALAPPDATA%\Microsoft\WindowsApps\PythonSoftwareFoundation.Python.3.13_qbz5n2kfra8p0\python.exe
if exist "%PYEXE%" (
  "%PYEXE%" -m uvicorn main:app --host 127.0.0.1 --port 8000
  goto :eof
)

echo Ошибка: не найден Python или uvicorn. Установите: pip install -r requirements.txt
pause
