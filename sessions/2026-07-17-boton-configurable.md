---
date: 2026-07-17
tags:
  - nytrix
  - session
  - bot
  - configurable
  - limits
project: nytrix
---
# Sesión 17 Julio 2026 — Bot Configurable con Límites Diarios

## Objetivo
Sistema completo de bot configurable por admin: 1 bot = 1 cuenta = 1 banco, con límites diarios, balance protection, auto-pause, screenshot de comprobante, y alertas.

## Lo que se hizo

### FASE 1: Migration + Model
- Campo `config` JSON agregado a `WorkerPaymentAccounts` via `migrate.js` (idempotente)
- Model actualizado con `config: DataTypes.JSON`

### FASE 2: Backend API (6 endpoints nuevos en workers.js)
- `PATCH /:id/toggle` — pausa/activa bot
- `PATCH /:id/accounts/:accountId/toggle` — pausa/activa cuenta individual
- `PATCH /:id/accounts/:accountId/config` — admin asigna límites (startingBalance, pagoMovil, transferencia)
- `GET /:id/accounts/:accountId/status` — estado de uso completo
- `PATCH /:id/accounts/:accountId/usage` — bot reporta uso post-transferencia
- `GET /:id/alerts` — alertas activas del bot

### FASE 3: OrderRouter — Pre-filtro de límites
- Verifica: cuenta activa, monto >= min, monto <= max, volumen disponible, cantidad transacciones, balance restante
- `_detectMethod()` clasifica canonicalPayMethod como pagoMovil o transferencia
- Bots legacy sin config pasan sin restricciones

### FASE 4: bot.py — Métodos nuevos
- `_check_limits()`, `_update_usage()`, `_capture_comprobante()`, `_upload_comprobante()`, `_emit_alert()`, `_detect_method()`
- Flow: claim → limits check → screenshot → upload to chat → update usage → auto-pause si agotado

### FASE 5: Frontend
- `DailySetupModal.tsx` — formulario admin para límites diarios
- `FarmDashboard.tsx` — WorkerTile con toggle, cuentas expandibles, badges
- `workers.ts` — 6 métodos API nuevos + 8 tipos

### Bugs fixeados durante testing
1. Socket.IO event names (`connect`/`disconnect` functions)
2. `Op.iLike` → `Op.like` (SQLite)
3. Bot room join via `handshake.auth.workerId`
4. Config JSON string → `json.loads()`
5. Claim usa `orderNumber` (Binance ID) no UUID
6. Bot team membership `acceptedAt NOT NULL`
7. SPA catch-all interceptando rutas test

### Test exitoso
- 7 órdenes Pago Móvil Mercantil reclamadas y procesadas por el bot automáticamente

## Pendiente para mañana

### Crítico
1. Conectar teléfonos reales vía ADB para probar flujo completo de transferencia
2. Verificar que `_capture_comprobante()` funciona en hardware real (screenshot + crop del comprobante)
3. Verificar `_upload_comprobante()` sube la imagen correctamente al chat de la orden

### Importante
4. Conectar frontend alertas con Socket.IO events (`bot:alert`)
5. Implementar endpoint `mark-paid` real para completar el flujo de ejecución
6. AccountMovement registration desde bot post-transferencia

### Limpieza
7. Eliminar endpoint test `/api/test/emit-order` y datos de prueba (PaymentAccount Mercantil, WorkerPaymentAccount link)
8. Eliminar `bot` user de prueba si no se necesita

### Nice-to-have
9. Dashboard: gráfico de volumen por cuenta
10. Notificaciones push para admins cuando bot se auto-pausa
