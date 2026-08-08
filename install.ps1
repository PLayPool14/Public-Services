# Resident Sleeper installer (iwr -useb ... | iex)
# Repo: PLayPool14/Public-Services, release tag: ResidentSleeper

$ErrorActionPreference = "Stop"

$repo        = "PLayPool14/Public-Services"
$releaseTag  = "ResidentSleeper"
$installDir  = "$env:LOCALAPPDATA\ResidentSleeper"
$tempDir     = Join-Path $env:TEMP "ResidentSleeper_install"

function Write-Banner
{
    Write-Host ""
    Write-Host " +-------------------------------------+" -ForegroundColor Cyan
    Write-Host " |                                       |" -ForegroundColor Cyan
    Write-Host " |    RESIDENT  SLEEPER  INSTALLER      |" -ForegroundColor Cyan
    Write-Host " |  Zzz... shutdown timer for Windows   |" -ForegroundColor DarkCyan
    Write-Host " |                                       |" -ForegroundColor Cyan
    Write-Host " +-------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
}

function Write-ProgressBar
{
    param(
        [string]$Label,
        [int]$PercentComplete,
        [int]$Width = 40
    )

    $filled = [math]::Round(($PercentComplete / 100) * $Width)
    $empty  = $Width - $filled
    $bar = ("#" * $filled) + ("-" * $empty)
    Write-Host -NoNewline ("`r  [{0}] {1,3}%  {2}" -f $bar, $PercentComplete, $Label)
}

Write-Banner

Write-Host " >> Checking latest release..." -ForegroundColor Yellow
try
{
    $release = Invoke-RestMethod `
        -Uri "https://api.github.com/repos/$repo/releases/tags/$releaseTag" `
        -Headers @{ "User-Agent" = "ResidentSleeper-Installer" }
}
catch
{
    Write-Host " [x] Failed to fetch release info from GitHub API." -ForegroundColor Red
    Write-Host "     $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$asset = $release.assets |
    Where-Object { $_.name -like "*.zip" -and $_.name -notmatch "^(Source[-_]?code|.*\.tar\.gz)$" } |
    Sort-Object size -Descending |
    Select-Object -First 1

if (-not $asset)
{
    Write-Host " [x] No app .zip found in release '$releaseTag'." -ForegroundColor Red
    Write-Host "     Available assets:" -ForegroundColor Yellow
    $release.assets | ForEach-Object { Write-Host "       - $($_.name)" }
    exit 1
}

if (Test-Path $tempDir)
{
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null
if (-not (Test-Path $installDir))
{
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

$zipPath = Join-Path $tempDir $asset.name
$sizeMB = [math]::Round($asset.size / 1MB, 1)

Write-Host " >> Downloading $($asset.name) ($sizeMB MB)..." -ForegroundColor Yellow
Write-Host ""

Add-Type -AssemblyName System.Net.Http
$httpClient = New-Object System.Net.Http.HttpClient
$httpClient.DefaultRequestHeaders.UserAgent.ParseAdd("ResidentSleeper-Installer")

$response = $httpClient.GetAsync($asset.browser_download_url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
$totalBytes = $response.Content.Headers.ContentLength
$stream = $response.Content.ReadAsStreamAsync().Result
$fileStream = [System.IO.File]::Create($zipPath)

$buffer = New-Object byte[] 65536
$totalRead = 0
do
{
    $read = $stream.Read($buffer, 0, $buffer.Length)
    if ($read -gt 0)
    {
        $fileStream.Write($buffer, 0, $read)
        $totalRead += $read
        $pct = [math]::Min(100, [math]::Round(($totalRead / $totalBytes) * 100))
        Write-ProgressBar -Label "$([math]::Round($totalRead/1MB,1)) / $sizeMB MB" -PercentComplete $pct
    }
}
while ($read -gt 0)

$fileStream.Close()
$stream.Close()
$httpClient.Dispose()
Write-Host ""
Write-Host ""
Write-Host " [OK] Download complete." -ForegroundColor Green

Write-Host " >> Extracting..." -ForegroundColor Yellow
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

$exeFile = Get-ChildItem -Path $tempDir -Recurse -Filter "*.exe" | Select-Object -First 1

if (-not $exeFile)
{
    Write-Host " [x] No .exe found after extraction." -ForegroundColor Red
    exit 1
}

Write-Host " >> Installing to $installDir ..." -ForegroundColor Yellow
Get-ChildItem -Path $exeFile.Directory -Recurse | ForEach-Object {
    $dest = $_.FullName.Replace($exeFile.Directory.FullName, $installDir)
    if ($_.PSIsContainer)
    {
        if (-not (Test-Path $dest))
        {
            New-Item -ItemType Directory -Path $dest | Out-Null
        }
    }
    else
    {
        Copy-Item $_.FullName -Destination $dest -Force
    }
}

$finalExePath = Join-Path $installDir $exeFile.Name

Remove-Item $tempDir -Recurse -Force

Write-Host ""
Write-Host " =====================================" -ForegroundColor DarkGray
Write-Host "   DONE! Installed to:" -ForegroundColor Green
Write-Host "   $installDir" -ForegroundColor White
Write-Host " =====================================" -ForegroundColor DarkGray
Write-Host ""

$shortcutAnswer = Read-Host " Create a desktop shortcut? (y/n)"
if ($shortcutAnswer -eq "y" -or $shortcutAnswer -eq "Y")
{
    $desktop = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktop "Resident Sleeper.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $finalExePath
    $shortcut.WorkingDirectory = $installDir
    $shortcut.Description = "Resident Sleeper - shutdown timer"
    $shortcut.Save()
    Write-Host " [OK] Shortcut created on Desktop." -ForegroundColor Green
}

$run = Read-Host " Launch Resident Sleeper now? (y/n)"
if ($run -eq "y" -or $run -eq "Y")
{
    Start-Process $finalExePath
}
