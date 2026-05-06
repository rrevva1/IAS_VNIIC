# Запуск приложения IAS UCH VNII на встроенном PHP-сервере (Windows).
# Использование: из каталога ias_uch_vnii выполнить:
#   powershell -ExecutionPolicy Bypass -File scripts\serve-windows.ps1
# или из корня проекта:
#   powershell -ExecutionPolicy Bypass -File ias_uch_vnii\scripts\serve-windows.ps1

$phpPaths = @(
    "C:\xampp\php",
    "C:\laragon\bin\php\php-8.2.12-Win32-vs16-x64",
    "C:\php"
)
$phpExe = $null
foreach ($p in $phpPaths) {
    if (Test-Path "$p\php.exe") {
        $env:Path = "$p;" + $env:Path
        $phpExe = "$p\php.exe"
        break
    }
}
if (-not $phpExe) {
    Write-Host "PHP не найден. Установите XAMPP (C:\xampp\php) или добавьте PHP в PATH." -ForegroundColor Red
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
Set-Location $rootDir

$port = if ($env:PORT) { $env:PORT } else { "8888" }
Write-Host "Запуск сервера на http://localhost:$port (PHP: $phpExe)" -ForegroundColor Green
& $phpExe yii serve --port=$port
