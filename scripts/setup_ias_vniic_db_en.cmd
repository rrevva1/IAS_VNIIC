@echo off
setlocal
set PGPASSWORD=12345
set PGHOST=localhost
set PGUSER=postgres
set DBNAME=IAS_VNIIC
set "SCRIPTS_DIR=%~dp0"
set "SCHEMA_FILE=%SCRIPTS_DIR%create_ias_uch_db_test.sql"

psql -h %PGHOST% -U %PGUSER% -d postgres -t -c "SELECT 1 FROM pg_database WHERE datname='%DBNAME%'" 2>nul | findstr /q 1
if %ERRORLEVEL% neq 0 (
  psql -h %PGHOST% -U %PGUSER% -d postgres -c "CREATE DATABASE \"%DBNAME%\" WITH ENCODING 'UTF8' TEMPLATE template0;"
)

psql -h %PGHOST% -U %PGUSER% -d "%DBNAME%" -f "%SCHEMA_FILE%"
endlocal
