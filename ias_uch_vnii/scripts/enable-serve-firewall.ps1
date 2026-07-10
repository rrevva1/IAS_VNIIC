# Открыть порт dev-сервера в брандмауэре Windows. Запускать от имени администратора:
#   powershell -ExecutionPolicy Bypass -File scripts\enable-serve-firewall.ps1

$port = if ($env:PORT) { $env:PORT } else { "8888" }
$ruleName = "IAS PHP Dev Server TCP $port"

$null = & netsh advfirewall firewall show rule name="$ruleName" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Правило уже существует: $ruleName" -ForegroundColor Green
    exit 0
}

$null = & netsh advfirewall firewall add rule name="$ruleName" dir=in action=allow protocol=TCP localport=$port
if ($LASTEXITCODE -ne 0) {
    Write-Host "Ошибка: требуется запуск от имени администратора." -ForegroundColor Red
    exit 1
}

Write-Host "Правило создано: входящие TCP на порт $port разрешены." -ForegroundColor Green
