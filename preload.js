const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
    close:        ()           => ipcRenderer.send('close-window'),
    drag:         (dx, dy)    => ipcRenderer.send('drag-window', { dx, dy }),
    resize:       (w, h)      => ipcRenderer.send('resize-window', { w, h }),
    savePosition: ()           => ipcRenderer.send('save-position'),
    shutdown:     (sec)       => ipcRenderer.send('shutdown', sec),
    abort:        ()           => ipcRenderer.send('shutdown-abort'),
    readLog:      (p)         => ipcRenderer.send('read-log', p),
    writeLog:     (p, line)   => ipcRenderer.send('write-log', { logPath: p, line }),
    deleteLog:    (p)         => ipcRenderer.send('delete-log', p),
    getAppPath:   ()           => ipcRenderer.send('get-app-path'),
    onLogData:    (cb) => ipcRenderer.on('log-data',    (e, d) => cb(d)),
    onWriteDone:  (cb) => ipcRenderer.on('write-done',  (e, d) => cb(d)),
    onDeleteDone: (cb) => ipcRenderer.on('delete-done', (e, d) => cb(d)),
    onAppPath:    (cb) => ipcRenderer.on('app-path',    (e, d) => cb(d)),
});
