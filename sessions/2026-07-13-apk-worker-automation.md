# Sesión 12-13 Jul 2026 — APK Worker Automatización

## Resumen Ejecutivo
Sesión intensiva de investigación + implementación sobre automatización bancaria, WebSocket robusto, y conexión real phone↔backend.

## Investigación Completada (6 temas)
1. **Banking Detection Bypass** — bancos usan `getEnabledAccessibilityServiceList()`, no hay bypass sin root. Solución: StealthModeManager
2. **Automation Strategies** — FjordPhantom (virtualization+hooking), MediaProjection+OCR alternativa, ADB shell fallback
3. **WebSocket Best Practices** — 25s ping interval, exponential backoff 500ms-30s con jitter, state machine CONNECTING/CONNECTED/BACKING_OFF
4. **APK Release Signing** — keystore JKS, v1+v2+v3, Gradle signingConfigs
5. **dataSync Compliance** — `onTimeout()` obligatorio Android 15, 6h max, `BOOT_COMPLETED` restriction
6. **Remote Debugging** — RemoteLogger via WebSocket, logcat filtering, endpoint `/workers/:id/logs`

## Implementaciones Nuevas
- **StealthModeManager.kt** — detecta bancos por package name, suprime watchers
- **RemoteLogger.kt** — logcat remoto via WebSocket, buffer 500, auto-reconnect
- **WebSocketClient.kt reescrito** — state machine + exponential backoff + jitter + ping 25s
- **OrchestratorService.kt** — onTimeout() para dataSync, health reporting 60s, stealth+logger
- **Release keystore** — `keystore/nytrix-worker.jks`, alias nytrix, validity 10000 days
- **DeviceCard.tsx** — card estilo phone con detalles del dispositivo

## Bug Crítico Resuelto
- **Cleartext Traffic**: Android 9+ bloquea HTTP/WS sin TLS. Fix: `android:usesCleartextTraffic="true"` en manifest
- Sin esto, OkHttp no podía conectarse a `ws://` y fallaba silenciosamente
- La notificación mostraba "Reconectando..." indefinidamente

## Estado Phone
- Dispositivo: `sapphire` (Xiaomi 23129RA5FL / Redmi Note 13)
- ID interno: `android_unknown_M0oWGg` (Build.SERIAL retorna "unknown" en Android 15)
- Tailscale: 100.89.27.44 (activo)
- WorkerId: `16b73cd3-ba5a-478d-819f-4a519de23f79`
- Backend: online, heartbeat cada 30s, health reporting cada 60s
- AccessibilityService: activo, Remote Logger: activo, Stealth Mode: inactivo

## Backend Updates
- rawDeviceSocket.js: reescrito con noServer, /log routing, handleDeviceConnection/handleLogConnection
- workers.js routes: GET /realtime merge DeviceManager+DB, GET / sin filtro orgId, GET /:id/logs
- Debug logging: incoming WS connections con path, clientIp, query

## Frontend Updates
- DeviceCard.tsx: card estilo phone con nombre, modelo, uptime, feature pills
- WorkerDashboardTab.tsx: usa DeviceCard para realtime devices
- RealtimeDevice interface: agregado workerId y name

## Metodología de Mapeo (vía ADB + scrcpy)
- El mapeo del flujo bancario se hizo con el teléfono conectado a la PC por USB
- **ADB + uiautomator dump**: extracción del árbol de nodos de UI para identificar selectores
- **scrcpy**: Yizuz lo detectó en pantalla de la PC, control del dispositivo en vivo mientras se mapeaba
- A partir de ese dump se construyeron los selectores `anyOfTexts` y `WaitForText` del BDVFlow
- El APK worker luego ejecuta esos mismos selectores vía AccessibilityService (sin necesidad de ADB)

## Pendiente
1. Probar stealth mode abriendo app bancaria (BDV)
2. Probar `saldo bdv` — ver si abre BDV con stealth
3. Build release APK con keystore
4. Phase F: signing release, package name limpio
5. Considerar MediaProjection + OCR como alternativa a A11y
6. Fix Build.SERIAL "unknown" — usar Build.FINGERPRINT o Settings.Secure.ANDROID_ID

## Archivos Clave
- `workers/android-worker/app/src/main/AndroidManifest.xml` — usesCleartextTraffic fix
- `workers/android-worker/app/src/main/java/com/nytrix/worker/service/StealthModeManager.kt`
- `workers/android-worker/app/src/main/java/com/nytrix/worker/logging/RemoteLogger.kt`
- `workers/android-worker/app/src/main/java/com/nytrix/worker/network/WebSocketClient.kt`
- `workers/android-worker/app/src/main/java/com/nytrix/worker/service/OrchestratorService.kt`
- `workers/android-worker/keystore/nytrix-worker.jks`
- `backend/src/websocket/rawDeviceSocket.js`
- `frontend/src/components/workers/DeviceCard.tsx`
