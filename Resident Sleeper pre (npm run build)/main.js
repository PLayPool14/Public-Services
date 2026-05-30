const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');

let win;
const configPath = path.join(app.getPath('userData'), 'rs-window-pos.json');

function loadPosition() {
    try {
        if (fs.existsSync(configPath))
            return JSON.parse(fs.readFileSync(configPath, 'utf8'));
    } catch(e) {}
    return null;
}

function savePosition() {
    try {
        const [x, y] = win.getPosition();
        fs.writeFileSync(configPath, JSON.stringify({ x, y }), 'utf8');
    } catch(e) {}
}

function createWindow() {
    const pos = loadPosition();
    win = new BrowserWindow({
        width: 364,
        height: 702,
        x: pos ? pos.x : undefined,
        y: pos ? pos.y : undefined,
        center: pos ? false : true,
        frame: false,
        resizable: false,
        backgroundColor: '#000000',
        icon: path.join(__dirname, 'icon.ico'),
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js')
        }
    });
    win.loadFile('index.html');
}

app.whenReady().then(createWindow);
app.on('window-all-closed', () => app.quit());

ipcMain.on('close-window',  () => win.close());
ipcMain.on('save-position', () => savePosition());

ipcMain.on('drag-window', (event, { dx, dy }) => {
    const [x, y] = win.getPosition();
    win.setPosition(x + dx, y + dy);
});

ipcMain.on('resize-window', (event, { w, h }) => {
    win.setSize(w, h);
});

ipcMain.on('shutdown', (event, sec) => {
    exec('shutdown -s -t ' + sec);
});

ipcMain.on('shutdown-abort', () => {
    exec('shutdown -a');
});

ipcMain.on('read-log', (event, logPath) => {
    try {
        const data = fs.existsSync(logPath) ? fs.readFileSync(logPath, 'utf8') : '';
        event.reply('log-data', { ok: true, data });
    } catch(e) {
        event.reply('log-data', { ok: false, data: '' });
    }
});

ipcMain.on('write-log', (event, { logPath, line }) => {
    try {
        fs.appendFileSync(logPath, line + '\n', 'utf8');
        event.reply('write-done', { ok: true });
    } catch(e) {
        event.reply('write-done', { ok: false });
    }
});

ipcMain.on('delete-log', (event, logPath) => {
    try {
        if (fs.existsSync(logPath)) fs.unlinkSync(logPath);
        event.reply('delete-done', { ok: true });
    } catch(e) {
        event.reply('delete-done', { ok: false });
    }
});

ipcMain.on('get-app-path', (event) => {
    const logPath = path.join(path.dirname(app.getPath('exe')), 'RS_LOG.txt');
    event.reply('app-path', logPath);
});
