@echo off
cd /d "%~dp0"
echo Starting Assistant API on http://127.0.0.1:8000
echo Ensure DB_HOST, DB_NAME, DB_USER, DB_PASSWORD are set (or use defaults).
python -m uvicorn main:app --host 0.0.0.0 --port 8000 2>nul || py -3 -m uvicorn main:app --host 0.0.0.0 --port 8000
pause
