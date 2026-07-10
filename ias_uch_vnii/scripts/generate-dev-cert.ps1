param(
    [switch]$Force
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$certDir = Join-Path $scriptDir "certs"
$certFile = Join-Path $certDir "dev-cert.pem"
$keyFile = Join-Path $certDir "dev-key.pem"

$opensslPaths = @(
    "C:\xampp\apache\bin\openssl.exe",
    "C:\laragon\bin\openssl\openssl.exe",
    "openssl"
)
$openssl = $null
foreach ($candidate in $opensslPaths) {
    if ($candidate -eq "openssl") {
        $cmd = Get-Command openssl -ErrorAction SilentlyContinue
        if ($cmd) {
            $openssl = $cmd.Source
            break
        }
        continue
    }
    if (Test-Path $candidate) {
        $openssl = $candidate
        break
    }
}
if (-not $openssl) {
    Write-Host "OpenSSL ne naiden. Ustanovite XAMPP ili dobavte openssl v PATH." -ForegroundColor Red
    exit 1
}

$opensslConfCandidates = @(
    "C:\xampp\apache\conf\openssl.cnf",
    "C:\xampp\php\extras\ssl\openssl.cnf",
    "C:\laragon\bin\apache\conf\openssl.cnf"
)
foreach ($conf in $opensslConfCandidates) {
    if (Test-Path $conf) {
        $env:OPENSSL_CONF = $conf
        break
    }
}

if ((Test-Path $certFile) -and (Test-Path $keyFile) -and -not $Force) {
    return
}

New-Item -ItemType Directory -Force -Path $certDir | Out-Null

$sanParts = @("DNS:localhost", "DNS:ias-vniic-dev", "IP:127.0.0.1")
$lanAddresses = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object {
        $_.IPAddress -notlike '127.*' -and
        $_.IPAddress -notlike '169.254.*'
    } |
    ForEach-Object { $_.IPAddress } |
    Select-Object -Unique)
foreach ($ip in $lanAddresses) {
    $sanParts += "IP:$ip"
}
$san = ($sanParts -join ",")

Write-Host "Generatsiya dev-sertifikata (SAN: $san)..." -ForegroundColor Yellow
$null = & $openssl req -x509 -nodes -days 825 -newkey rsa:2048 `
    -keyout $keyFile `
    -out $certFile `
    -subj "/CN=ias-vniic-dev/O=IAS Dev/C=RU" `
    -addext "subjectAltName=$san" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Oshibka generatsii sertifikata." -ForegroundColor Red
    exit 1
}
Write-Host "Sertifikat sozdan: $certFile" -ForegroundColor Green
