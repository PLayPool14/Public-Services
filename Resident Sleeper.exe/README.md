# Resident Sleeper v2.0
A shutdown timer app with a terminal aesthetic, built with Electron.

![version](https://img.shields.io/badge/version-2.0.0-red)
![platform](https://img.shields.io/badge/platform-Windows-blue)
![made by](https://img.shields.io/badge/by-GlaSS%20Walker-darkred)
![license](https://img.shields.io/badge/license-MIT-green)
![electron](https://img.shields.io/badge/electron-28-47848F)

## Features
- Countdown timer with HH:MM:SS display
- Quick presets: 30 minutes, 1 hour, 2 hours
- Custom shutdown time with decimal support (e.g. 1.5h)
- Cancel shutdown at any time
- Session log with indexed entries (date, option, shutdown time)
- Log persists between sessions and loads last session on startup
- Frameless window with drag support and saved position

## Download

### Option 1: PowerShell one-liner (recommended)
Open PowerShell and run:
```powershell
iwr -useb https://raw.githubusercontent.com/PLayPool14/Public-Services/main/install.ps1 | iex
```
This downloads the latest release, extracts it to `%LOCALAPPDATA%\ResidentSleeper`, and optionally creates a desktop shortcut and launches the app for you.

### Option 2: Manual download
Grab the latest `.zip` from [Releases](../../releases), extract it anywhere, and run `ResidentSleeper.exe`. No install needed.

> Since the app isn't code-signed, Windows SmartScreen may flag it as unrecognized. Click **More info → Run anyway** to proceed.

## Build from source
**Requirements:** Node.js 18+
```bash
git clone https://github.com/PLayPool14/Public-Services
cd "Public-Services/Resident Sleeper pre (npm run build)"
npm install
npm start
```

To build the installer:
```bash
npm run build
```
Output will be in the `dist/` folder.

## Log file
`RS_LOG.txt` is saved next to the `.exe` file. Each entry contains:
- ID (indexed)
- Date and time of session start
- Option used (30m / 1h / 2h / custom / CANCEL)
- Scheduled shutdown time

## License
MIT — by Gla$$Walker/PLayPool14
