# Zapusk prilozheniya IAS UCH VNII (HTTPS dev-server, Windows).
# Ispolzovanie:
#   powershell -ExecutionPolicy Bypass -File scripts\serve-windows.ps1
#
# Peremennye okruzheniya:
#   PORT               - vneshniy HTTPS-port (po umolchaniyu 8888)
#   HTTP_REDIRECT_PORT - HTTP-port s redirect na HTTPS (po umolchaniyu 8880)
#   BACKEND_PORT       - vnutrenniy HTTP-port PHP (po umolchaniyu 8889, tolko localhost)
#   HOST               - adres privyazki (po umolchaniyu 0.0.0.0)

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
    Write-Host "PHP ne naiden. Ustanovite XAMPP (C:\xampp\php) ili dobavte PHP v PATH." -ForegroundColor Red
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
Set-Location $rootDir

$port = if ($env:PORT) { $env:PORT } else { "8888" }
$httpRedirectPort = if ($env:HTTP_REDIRECT_PORT) { $env:HTTP_REDIRECT_PORT } else { "8880" }
$backendPort = if ($env:BACKEND_PORT) { $env:BACKEND_PORT } else { "8889" }
$bindHost = if ($env:HOST) { $env:HOST } else { "0.0.0.0" }
$certFile = Join-Path $scriptDir "certs\dev-cert.pem"
$keyFile = Join-Path $scriptDir "certs\dev-key.pem"

function Ensure-FirewallRule {
    param([string]$RulePort)
    $ruleName = "IAS PHP Dev Server TCP $RulePort"
    $null = & netsh advfirewall firewall show rule name="$ruleName" 2>&1
    if ($LASTEXITCODE -eq 0) {
        return
    }
    Write-Host "Dobavlenie pravila brandmauera dlya porta $RulePort..." -ForegroundColor Yellow
    $null = & netsh advfirewall firewall add rule name="$ruleName" dir=in action=allow protocol=TCP localport=$RulePort
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Pravilo brandmauera sozdano." -ForegroundColor Green
        return
    }
    Write-Host "Ne udalos sozdat pravilo brandmauera. Zapustite scripts\enable-serve-firewall.ps1 ot imeni administratora." -ForegroundColor Yellow
}

function Wait-BackendReady {
    param([int]$RulePort)
    for ($i = 0; $i -lt 40; $i++) {
        $conn = Get-NetTCPConnection -LocalPort $RulePort -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($conn) {
            return $true
        }
        Start-Sleep -Milliseconds 250
    }
    return $false
}

& "$scriptDir\generate-dev-cert.ps1"

if ($bindHost -eq "0.0.0.0") {
    Ensure-FirewallRule -RulePort $port
    Ensure-FirewallRule -RulePort $httpRedirectPort
}

$lanAddresses = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
        $_.IPAddress -notlike '127.*' -and
        $_.IPAddress -notlike '169.254.*'
    } |
    ForEach-Object { $_.IPAddress } |
    Select-Object -Unique)

Write-Host "Zapusk servera (PHP: $phpExe)" -ForegroundColor Green
Write-Host "  HTTPS local: https://localhost:$port" -ForegroundColor Green
Write-Host "  HTTP redirect local: http://localhost:$httpRedirectPort -> https://localhost:$port" -ForegroundColor Cyan
foreach ($ip in $lanAddresses) {
    Write-Host ('  HTTPS LAN:   https://' + $ip + ':' + $port) -ForegroundColor Green
    Write-Host ('  HTTP LAN:    http://' + $ip + ':' + $httpRedirectPort + ' -> https://' + $ip + ':' + $port) -ForegroundColor Cyan
}
Write-Host "  Vazhno: port $port tolko HTTPS (ne http://...:$port)" -ForegroundColor Yellow
Write-Host "  Backend HTTP: 127.0.0.1:$backendPort (tolko dlya proksi)" -ForegroundColor DarkGray
Write-Host "  Brauzer predupredit o samopodpisannom sertifikate - eto normalno dlya dev." -ForegroundColor Yellow

$backendProc = Start-Process -FilePath $phpExe -ArgumentList @(
    "yii",
    "serve",
    "127.0.0.1",
    "--port=$backendPort",
    "--router=web/router.php"
) -WorkingDirectory $rootDir -PassThru -WindowStyle Hidden

$httpRedirectProc = Start-Process -FilePath $phpExe -ArgumentList @(
    "$scriptDir\http-redirect.php",
    "--listen=$bindHost",
    "--port=$httpRedirectPort",
    "--https-port=$port"
) -WorkingDirectory $rootDir -PassThru -WindowStyle Hidden

try {
    if (-not (Wait-BackendReady -RulePort ([int]$backendPort))) {
        throw "Backend HTTP-server ne zapustilsya na portu $backendPort"
    }

    & $phpExe "$scriptDir\https-proxy.php" `
        --listen=$bindHost `
        --port=$port `
        --backend="127.0.0.1:$backendPort" `
        --cert="$certFile" `
        --key="$keyFile"
}
finally {
    if ($httpRedirectProc -and -not $httpRedirectProc.HasExited) {
        Stop-Process -Id $httpRedirectProc.Id -Force -ErrorAction SilentlyContinue
    }
    if ($backendProc -and -not $backendProc.HasExited) {
        Stop-Process -Id $backendProc.Id -Force -ErrorAction SilentlyContinue
    }
}
