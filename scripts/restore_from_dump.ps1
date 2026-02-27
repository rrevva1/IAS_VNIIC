# Restore DB from dump ias_vniic_mac_full_17_02_26.sql
# 1. Drops schema tech_accounting
# 2. Restores dump
# 3. Converts equipment_type to equipment_type_id for app compatibility

param(
    [string]$DbHost = "localhost",
    [string]$Port = "5432",
    [string]$DbName = "ias_vniic",
    [string]$User = "postgres",
    [string]$Password = "12345",
    [switch]$SkipMigration
)

if ($env:DB_HOST) { $DbHost = $env:DB_HOST }
if ($env:DB_PORT) { $Port = $env:DB_PORT }
if ($env:DB_NAME) { $DbName = $env:DB_NAME }
if ($env:DB_USER) { $User = $env:DB_USER }
if ($env:DB_PASSWORD) { $Password = $env:DB_PASSWORD }

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DumpPath = Join-Path $ProjectRoot "db\ias_vniic_mac_full_17_02_26.sql"
$IasDir = Join-Path $ProjectRoot "ias_uch_vnii"

if (-not (Test-Path $DumpPath)) {
    Write-Error "Dump not found: $DumpPath"
}

$TempDump = [System.IO.Path]::GetTempFileName()
Get-Content $DumpPath -Encoding UTF8 | Where-Object { $_ -notmatch '^\\restrict\s' } | Set-Content $TempDump -Encoding UTF8

$env:PGPASSWORD = $Password

try {
    Write-Host "1. Dropping schema tech_accounting..."
    psql -h $DbHost -p $Port -U $User -d $DbName -v ON_ERROR_STOP=1 -c "DROP SCHEMA IF EXISTS tech_accounting CASCADE;"

    Write-Host "2. Restoring dump..."
    psql -h $DbHost -p $Port -U $User -d $DbName -v ON_ERROR_STOP=1 -f $TempDump

    if (-not $SkipMigration) {
        Write-Host "3. Converting equipment_type -> equipment_type_id..."
        Push-Location $IasDir
        try {
            php scripts/convert_equipment_type_to_id.php
        }
        finally {
            Pop-Location
        }
    }
    else {
        Write-Host "3. Skipping conversion (-SkipMigration)"
    }

    Write-Host "Done. DB restored. Admin: admin (password from dump)"
}
finally {
    Remove-Item -Path $TempDump -ErrorAction SilentlyContinue
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
}
