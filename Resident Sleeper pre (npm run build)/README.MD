# Resident Sleeper v2.0 — Source
 
Source code for Resident Sleeper. Built with Electron.
 
![version](https://img.shields.io/badge/version-2.0.0-red)
![electron](https://img.shields.io/badge/electron-28-47848F)
![made by](https://img.shields.io/badge/by-GlaSS%20Walker-darkred)
![license](https://img.shields.io/badge/license-MIT-green)
 
## Requirements
 
- Node.js 18+
- npm
## Run
 
```bash
npm install
npm start
```
 
## Build
 
```bash
npm run build
```
 
Output `.exe` will be in the `dist/` folder.
 
## Files
 
- `index.html` — UI
- `main.js` — Electron main process, IPC handlers, shutdown logic
- `preload.js` — context bridge between main and renderer
- `package.json` — dependencies and build config
- `icon.ico` — app icon
## License
 
MIT — Gla$$Walker/PLayPool14
 
