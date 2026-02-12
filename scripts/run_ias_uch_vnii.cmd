@echo off
:: Запуск встроенного PHP-сервера для ias_uch_vnii
:: Требуется: PHP в PATH или изменить путь ниже
set "PHP=C:\xampp\php\php.exe"
set "PROJECT=%~dp0..\ias_uch_vnii"
if not exist "%PHP%" set "PHP=php"
cd /d "%PROJECT%"
echo Starting server at http://localhost:8080
"%PHP%" yii serve --port=8080
