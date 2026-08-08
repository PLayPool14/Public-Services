# Resident Sleeper — instalator (iwr -useb ... | iex)
# Repo: PLayPool14/Public-Services, tag release'u: ResidentSleeper

$ErrorActionPreference = "Stop"

$repo        = "PLayPool14/Public-Services"
$releaseTag  = "ResidentSleeper"
$installDir  = "$env:LOCALAPPDATA\ResidentSleeper"

Write-Host ""
Write-Host "=== Resident Sleeper — instalator ===" -ForegroundColor Cyan
Write-Host ""

# 1. Pobranie informacji o release z GitHub API
Write-Host "Sprawdzam najnowszy release..." -ForegroundColor Yellow
try {
    $release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$repo/releases/tags/$releaseTag" `
        -Headers @{ "User-Agent" = "ResidentSleeper-Installer" }
}
catch {
    Write-Host "Nie udało się pobrać danych o release z GitHub API." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# 2. Znalezienie assetu .exe (pomijamy automatyczne "Source code" zip/tar.gz)
$asset = $release.assets | Where-Object { $_.name -like "*.exe" } | Select-Object -First 1

if (-not $asset) {
    Write-Host "Nie znaleziono pliku .exe w releasie '$releaseTag'." -ForegroundColor Red
    exit 1
}

# 3. Przygotowanie folderu docelowego
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}
$exePath = Join-Path $installDir $asset.name

# 4. Pobieranie
Write-Host "Pobieram $($asset.name) ($([math]::Round($asset.size / 1MB, 1)) MB)..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $exePath -UseBasicParsing

Write-Host ""
Write-Host "Gotowe! Zapisano w: $exePath" -ForegroundColor Green
Write-Host ""

# 5. Opcjonalne uruchomienie
$run = Read-Host "Uruchomic Resident Sleeper teraz? (t/n)"
if ($run -eq "t" -or $run -eq "T") {
    Start-Process $exePath
}
