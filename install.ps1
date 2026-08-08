# Resident Sleeper — instalator (iwr -useb ... | iex)
# Repo: PLayPool14/Public-Services, tag release'u: ResidentSleeper

$ErrorActionPreference = "Stop"

$repo        = "PLayPool14/Public-Services"
$releaseTag  = "ResidentSleeper"
$installDir  = "$env:LOCALAPPDATA\ResidentSleeper"
$tempDir     = Join-Path $env:TEMP "ResidentSleeper_install"

Write-Host ""
Write-Host "=== Resident Sleeper - instalator ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Sprawdzam najnowszy release..." -ForegroundColor Yellow
try {
    $release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$repo/releases/tags/$releaseTag" `
        -Headers @{ "User-Agent" = "ResidentSleeper-Installer" }
}
catch {
    Write-Host "Nie udalo sie pobrac danych o release z GitHub API." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

$asset = $release.assets |
    Where-Object { $_.name -like "*.zip" -and $_.name -notmatch "^(Source[-_]?code|.*\.tar\.gz)$" } |
    Sort-Object size -Descending |
    Select-Object -First 1

if (-not $asset) {
    Write-Host "Nie znaleziono pliku .zip z appka w releasie '$releaseTag'." -ForegroundColor Red
    Write-Host "Dostepne assety:" -ForegroundColor Yellow
    $release.assets | ForEach-Object { Write-Host " - $($_.name)" }
    exit 1
}

if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir | Out-Null
if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }

$zipPath = Join-Path $tempDir $asset.name

Write-Host "Pobieram $($asset.name) ($([math]::Round($asset.size / 1MB, 1)) MB)..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -UseBasicParsing

Write-Host "Rozpakowuje..." -ForegroundColor Yellow
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

$exeFile = Get-ChildItem -Path $tempDir -Recurse -Filter "*.exe" | Select-Object -First 1

if (-not $exeFile) {
    Write-Host "Nie znaleziono pliku .exe po rozpakowaniu." -ForegroundColor Red
    exit 1
}

Get-ChildItem -Path $exeFile.Directory -Recurse | ForEach-Object {
    $dest = $_.FullName.Replace($exeFile.Directory.FullName, $installDir)
    if ($_.PSIsContainer) {
        if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Path $dest | Out-Null }
    } else {
        Copy-Item $_.FullName -Destination $dest -Force
    }
}

$finalExePath = Join-Path $installDir $exeFile.Name

Remove-Item $tempDir -Recurse -Force

Write-Host ""
Write-Host "Gotowe! Zainstalowano w: $installDir" -ForegroundColor Green
Write-Host ""

$shortcutAnswer = Read-Host "Dodac skrot na pulpicie? (t/n)"
if ($shortcutAnswer -eq "t" -or $shortcutAnswer -eq "T") {
    $desktop = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktop "Resident Sleeper.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $finalExePath
    $shortcut.WorkingDirectory = $installDir
    $shortcut.Description = "Resident Sleeper - shutdown timer"
    $shortcut.Save()
    Write-Host "Skrot dodany na pulpicie." -ForegroundColor Green
}

$run = Read-Host "Uruchomic Resident Sleeper teraz? (t/n)"
if ($run -eq "t" -or $run -eq "T") {
    Start-Process $finalExePath
}
