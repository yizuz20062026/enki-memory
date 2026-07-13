# Electron

> Seguridad y arquitectura para desktop apps.

## Reglas Fijas
1. contextIsolation: true, nodeIntegration: false, sandbox: true
2. Preload con contextBridge — solo funciones nombradas
3. Todo IPC validado con schema
4. CSP: `script-src 'self'`
5. shell.openExternal solo URLs hardcodeadas
6. Auto-updater con Ed25519 signing

## Ver También
- [[../conocimiento/ciberseguridad\|Ciberseguridad]] — checklist desktop
