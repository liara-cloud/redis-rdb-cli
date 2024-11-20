if (-not (Get-Command Invoke-WebRequest -ErrorAction SilentlyContinue) -or `
    -not (Get-Command Expand-Archive -ErrorAction SilentlyContinue)) {
    Write-Host "Prerequisites not found. Please ensure PowerShell supports Invoke-WebRequest and Expand-Archive." -ForegroundColor Red
    exit 1
} else {
    Write-Host "Prerequisites already available." -ForegroundColor Green
}

if (-not (Test-Path -Path "redis-rdb-cli-release.zip")) {
    Write-Host "Downloading redis-rdb-cli..."
    Invoke-WebRequest -Uri "https://github.com/leonchen83/redis-rdb-cli/releases/download/v0.9.6/redis-rdb-cli-release.zip" `
        -OutFile "redis-rdb-cli-release.zip"
} else {
    Write-Host "redis-rdb-cli-release.zip already downloaded."
}

if (-not (Test-Path -Path ".\redis-rdb-cli")) {
    Write-Host "Extracting redis-rdb-cli..."
    Expand-Archive -Path "redis-rdb-cli-release.zip" -DestinationPath "redis-rdb-cli"
} else {
    Write-Host "redis-rdb-cli already extracted."
}

$redis_uri = Read-Host -Prompt "Enter Redis URI"

$dump_file = Get-ChildItem -Path . -Filter "*.dump" -File | Select-Object -First 1
if (-not $dump_file) {
    Write-Host "No .dump file found. Looking for .rdb files..."
    $dump_file = Get-ChildItem -Path . -Filter "*.rdb" -File | Select-Object -First 1
}

if ($dump_file) {
    Write-Host "Using file: $($dump_file.FullName)"
    Copy-Item -Path $dump_file.FullName -Destination "dump.rdb" -Force
} else {
    Write-Host "No valid .dump or .rdb file found." -ForegroundColor Red
    exit 1
}

Start-Process -FilePath ".\redis-rdb-cli\redis-rdb-cli\bin\rmt" `
    -ArgumentList "-s dump.rdb -m $redis_uri" -Wait
