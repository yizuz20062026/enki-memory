---
tags:
  - nytrix
  - phone-farm
  - scalability
  - architecture
status: completed
created: 2026-07-17
version: 2
---
# NYTRIX Phone Farm Scale — Plan de Escalabilidad

> Proyecto de escalabilidad del bot worker para phone farm box de 20-40 dispositivos simultáneos.

## Estado
- **Estado**: COMPLETADO (17 Julio 2026)
- **Fecha inicio**: 17 Julio 2026
- **Auditoría**: Backend 7/7 OK, bot.py 1875 lines OK, frontend 0 new errors

## Modelo Operativo (v2)
- 1 bot = 1 phone = 1 set de cuentas y credenciales PROPIAS
- Cada bot hace claim de max 5 órdenes → ejecuta → vuelve a claim
- 40 bots × 5 = 200 operaciones simultáneas
- Cards dinámicas: se crean al detectar device via ADB
- Sin choque entre bots: cada uno opera sus propias cuentas

## Implementado

### Backend (6 archivos modificados/creados)
- `src/database/models/Worker.js` — campo `activeOrders` (INTEGER, default 0)
- `src/database/migrate.js` — ALTER TABLE ADD COLUMN activeOrders
- `src/websocket/orderRouter.js` — OrderRouter class: routeOrder(), releaseCapacity(), getStatus(), retry queue
- `src/websocket/socketServer.js` — auto-join room `worker_${workerId}` para bots
- `src/jobs/chatMonitor.js` — 3 emit points ahora llaman orderRouter.routeOrder()
- `src/api/middleware/rateLimiter.js` — key by `bot:${workerId}`, 500 req/min per bot
- `src/services/paymentAccountService.js` — recordMovement() en transaction con SELECT FOR UPDATE
- `src/api/routes/workers.js` — 4 endpoints nuevos: farm/status, worker/accounts, worker/capacity, register-device

### Bot (1 archivo, 1875 lines)
- `worker-bot/bot.py` — capacity tracking (MAX=5), order:assigned handler, heartbeat loop 30s, _claim_and_execute atomic, _release_capacity, pytesseract OCR (3x faster)

### Frontend (2 archivos)
- `frontend/src/services/workers.ts` — getFarmStatus(), updateWorkerCapacity(), registerDevice()
- `frontend/src/components/workers/FarmDashboard.tsx` — stats cards, worker tiles con capacity bar, auto-refresh 5s

### Ops (3 archivos)
- `setup/setup-farm.sh` — instala deps, redis, adb, supervisord
- `setup/start-farm.sh` — detecta devices ADB, crea bot users, inicia processes
- `setup/supervisord.conf` — process management para bots

## Documentos
| Documento | Ruta |
|-----------|------|
| Plan detallado | [[../../sessions/2026-07-17-phone-farm-scale-plan\|Plan v2]] |
| ADR-004 | [[../../adr/004-phone-farm-scaling\|ADR-004]] |
| Research: Hardware | [[../../raw/phone-farm-research\|Phone Farm HW]] |
| Research: Socket.IO | [[../../raw/socketio-scaling-research\|Socket.IO Scaling]] |
| Research: ADB | [[../../raw/adb-pooling-research\|ADB Pooling]] |
| Research: OCR | [[../../raw/ocr-optimization-research\|OCR Optimization]] |
| Lessons | [[../../lessons/LESSONS\|L1-008 a L1-012]] |

## Fases
| Fase | Estado | Qué |
|------|--------|-----|
| 0: Fundamentos | ✅ | Migration activeOrders, create-bot-users.js, Redis |
| 1: Order Router | ✅ | OrderRouter, rooms, rate limit, DB transactions, 3 endpoints |
| 2: Bot Runtime | ✅ | capacity MAX=5, order:assigned, heartbeat, pytesseract OCR |
| 3: Operations | ✅ | setup-farm.sh, register-device, supervisord |
| 4: Frontend | ✅ | FarmDashboard.tsx, workersApi farm endpoints |
| **Total** | **✅** | **5-7 días → completado en 1 sesión** |
