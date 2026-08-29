---
tags:
  - session
  - nytrix
  - phone-farm
  - plan
  - scaling
date: 2026-07-17
duration: plan
version: 2
---
# Plan: NYTRIX Phone Farm Scale — 20-40 Bots
> Sesión 17 Julio 2026 — Plan reestructurado con modelo de capacidad por bot

## Modelo Operativo

### Cómo funciona
```
Phone Farm Box (20-40 slots USB)
├── Phone 001 → Bot "bot-001" → Daviplata #1234 (credenciales propias)
├── Phone 002 → Bot "bot-002" → Daviplata #5678 (credenciales propias)
├── Phone 003 → Bot "bot-003" → Bancolombia #9999 (credenciales propias)
├── ...
└── Phone 040 → Bot "bot-040" → Nequi #4444 (credenciales propias)
```

### Reglas clave
1. **Cada bot tiene cuentas y credenciales PROPIAS** — puede ser el mismo banco, diferente cuenta
2. **Cada bot hace claim de hasta 5 órdenes** — luego ejecuta las 5
3. **Al terminar, vuelve a claim 5 más** — ciclo continuo
4. **Mientras Bot A ejecuta, B/C/D hacen claim** — load balancing natural
5. **Las cards se crean al detectar device** — no hay slots fijos
6. **1 bot = 1 phone = 1 set de cuentas** — aislamiento total

### Throughput teórico
- 40 bots × 5 órdenes concurrentes = **200 operaciones simultáneas**
- Cada bot opera independientemente — no hay choque entre bots
- Si Bot A y Bot B ambos tienen Daviplata (diferentes números), cada uno opera la suya

---

## Arquitectura

```
                         ┌──────────────────┐
                         │  Binance P2P     │
                         │  (nuevas órdenes) │
                         └────────┬─────────┘
                                  │
                         ┌────────▼─────────┐
                         │   chatMonitor     │
                         │  (detecta orden)  │
                         └────────┬─────────┘
                                  │
                    ┌─────────────▼──────────────┐
                    │   orderRouter (NUEVO)       │
                    │                             │
                    │ 1. Extrae canonicalPayMethod │
                    │ 2. Query WorkerPaymentAcct   │
                    │    → ¿qué workers tienen     │
                    │      esa cuenta?             │
                    │ 3. Filtra: workers con        │
                    │    activeOrders < 5           │
                    │ 4. Emite SOLO al worker      │
                    │    seleccionado               │
                    └────┬───────┬───────┬────────┘
                         │       │       │
                    ┌────▼──┐ ┌──▼───┐ ┌─▼────┐
                    │Bot 001│ │Bot002│ │Bot003│
                    │3 active│ │0 free│ │5 busy│
                    └───────┘ └──────┘ └──────┘
```

### orderRouter — El componente clave
```javascript
// backend/src/websocket/orderRouter.js

class OrderRouter {
  constructor(io, db) {
    this.io = io;
    this.db = db;
  }

  async routeOrder(order) {
    const bank = (order.canonicalPayMethod || '').toLowerCase();
    if (!bank) return;

    // 1. ¿Qué workers tienen cuentas de este banco?
    const candidates = await this.db.WorkerPaymentAccount.findAll({
      include: [{
        model: this.db.PaymentAccount,
        where: { bank: { [Op.iLike]: `%${bank}%` }, is_active: true }
      }],
      include: [{
        model: this.db.Worker,
        where: { status: 'online' }
      }]
    });

    // 2. Filtrar: solo workers con capacidad (< 5 active)
    const available = candidates.filter(c =>
      (c.Worker.activeOrders || 0) < 5
    );

    if (available.length === 0) {
      // No hay bot libre — orden queda en cola para reintentar
      return { routed: false, reason: 'no_capacity' };
    }

    // 3. Round-robin o least-loaded
    const selected = available.sort(
      (a, b) => (a.Worker.activeOrders || 0) - (b.Worker.activeOrders || 0)
    )[0];

    // 4. Emitir SOLO al worker seleccionado
    this.io.to(`worker_${selected.workerId}`).emit('order:assigned', {
      orderId: order.id,
      accountId: selected.paymentAccountId,
      canonicalPayMethod: order.canonicalPayMethod,
      amount: order.amount,
      fiat: order.fiat,
      counterparty: order.counterparty,
    });

    // 5. Incrementar activeOrders del worker
    await this.db.Worker.update(
      { activeOrders: this.db.sequelize.literal('active_orders + 1') },
      { where: { id: selected.workerId } }
    );

    return { routed: true, workerId: selected.workerId };
  }
}
```

### Capacidad por Bot (en Worker model)
```javascript
// Agregar campo al modelo Worker
activeOrders: {
  type: DataTypes.INTEGER,
  defaultValue: 0,
  validate: { min: 0, max: 5 }
}
```

### Bot claim flow (simplificado)
```python
# bot.py — handler de order:assigned (ya NO chat:new global)

async def _handle_order_assigned(self, data):
    """Recibe solo órdenes que MATCHean mis cuentas y soy el bot seleccionado."""
    order_id = data['orderId']
    account_id = data['accountId']

    # 1. Ya tengo capacidad? (double-check local)
    if self._active_orders >= 5:
        log.warning("At capacity, rejecting order %s", order_id)
        return

    # 2. Claim (el endpoint atómico ya existe)
    result = await self._claim_order(order_id)
    if not result['success']:
        log.info("Order already claimed by another bot")
        return

    # 3. Ejecutar
    self._active_orders += 1
    try:
        await self._execute_order(data)
    finally:
        self._active_orders -= 1
        # Reportar capacidad actualizada
        await self.sio.emit('capacity_update', {
            'workerId': self.worker_id,
            'activeOrders': self._active_orders
        })
```

---

## FASE 0: Fundamentos (1 día)

### 0.1 — PostgreSQL + Pool
- **Archivo**: `backend/src/config/database.js`
- Pool: `{ max: 20, min: 5, idle: 10000 }`
- SQLite solo para dev local

### 0.2 — Redis
- `docker run -d --name nytrix-redis -p 6379:6379 redis:7-alpine`
- Solo para rate limiter distribuido (BullMQ es opcional)

### 0.3 — JWT por bot + Worker model update
- Script para crear users bot: `bot-001@nytrix.io` ... `bot-040@nytrix.io`
- Agregar `activeOrders` (INTEGER, default 0, max 5) al modelo Worker
- Cada bot recibe su propio `--token` al iniciar

### 0.4 — WorkerPaymentAccount como fuente de verdad
- **YA EXISTE** — solo hay que poblarlo correctamente
- Cada bot solo consulta SUS cuentas (no todas las del operador)
- Script de setup que vincula cada Worker con sus PaymentAccounts

---

## FASE 1: Backend — Order Router (2 días)

### 1.1 — OrderRouter (reemplaza broadcast global)
- **Archivo nuevo**: `backend/src/websocket/orderRouter.js`
- `chatMonitor.js` llama a `orderRouter.routeOrder(order)` en vez de `io.emit('chat:new')`
- El router consulta WorkerPaymentAccount, filtra por capacidad, emite solo al bot correcto
- Si no hay bot libre → orden queda en cola para reintento cada 10s

### 1.2 — Socket.IO Room Registration
- **Archivo**: `backend/src/websocket/socketServer.js`
- Al conectar, bot se une a `worker_${workerId}` automáticamente
- Dashboard se une a `room 'dashboard'`
- Ya NO existe `io.emit()` global — todo es room-scoped

### 1.3 — Socket.IO Config
```javascript
const io = new Server(server, {
  pingTimeout: 60000,
  pingInterval: 25000,
  maxHttpBufferSize: 5e6,
  transports: ['websocket'],
  connectTimeout: 10000,
});
```

### 1.4 — Rate Limiter por Bot
- Key: `bot:${workerId}` en vez de `userId`
- Límite: 200 req/min per bot
- Archivo: `backend/src/middleware/rateLimiter.js`

### 1.5 — DB Transactions para AccountJournal
```javascript
// paymentAccountService.js — recordMovement()
await db.sequelize.transaction(async (t) => {
  const journal = await AccountJournal.findByPk(journalId, {
    lock: true,  // SELECT FOR UPDATE
    transaction: t
  });
  // Check limits con valor fresco
  // Insert AccountMovement
  // Update journal counters
});
```

### 1.6 — Worker Capacity Endpoints
```
PATCH /api/workers/:id/capacity    — actualizar activeOrders manualmente
GET   /api/farm/status             — status de todos los workers (online/busy/capacity)
```

---

## FASE 2: Bot Runtime (2 días)

### 2.1 — Account Filtering por WorkerPaymentAccount
- **Archivo**: `worker-bot/bot.py` — `_fetch_accounts()`
```python
# ANTES: fetch todas las cuentas del operador
GET /api/payment-accounts/

# DESPUÉS: fetch solo las cuentas de ESTE worker
GET /api/workers/{worker_id}/accounts
```
- El backend retorna solo las cuentas vinculadas vía WorkerPaymentAccount
- Cada bot solo ve y opera sus propias cuentas

### 2.2 — Capacity Management Local
```python
class NytrixBot:
    MAX_CONCURRENT_ORDERS = 5

    async def _handle_order_assigned(self, data):
        if self._active_orders >= self.MAX_CONCURRENT_ORDERS:
            return  # Rechazar — sin capacidad

        self._active_orders += 1
        try:
            await self._execute_order(data)
        finally:
            self._active_orders -= 1
            await self._report_capacity()
```

### 2.3 — ppadb Connection Pool
```python
from ppadb.client import Client as AdbClient

class ADBPool:
    _client = None
    @classmethod
    def get_device(cls, serial):
        if cls._client is None:
            cls._client = AdbClient(host='127.0.0.1', port=5037)
        return cls._client.device(serial)
```
- Dep: `pip install ppadb-reborn`
- Elimina subprocess overhead (50-200ms → 5-20ms)

### 2.4 — Tesseract OCR
```python
def ocr_text(self, image_bytes):
    import pytesseract
    from PIL import Image
    import io
    img = Image.open(io.BytesIO(image_bytes))
    return pytesseract.image_to_string(img, config='--psm 11')
```
- Dep: `pip install pytesseract` + `apt install tesseract-ocr tesseract-ocr-spa`
- 3x más rápido que EasyOCR en CPU, 10MB vs 500MB

### 2.5 — Heartbeat + Status Reporting
```python
async def _heartbeat_loop(self):
    while self.running:
        await self.sio.emit('heartbeat', {
            'workerId': self.worker_id,
            'status': self.status,
            'activeOrders': self._active_orders,
            'maxOrders': self.MAX_CONCURRENT_ORDERS,
            'deviceId': self.device_id,
        })
        await asyncio.sleep(30)
```

---

## FASE 3: Operations (1 día)

### 3.1 — Phone Farm Setup Script
```bash
#!/bin/bash
# setup-farm.sh — Setup automático para phone farm box

# 1. Detectar todos los phones conectados
DEVICES=$(adb devices | grep -w "device" | awk '{print $1}')
COUNT=0

for SERIAL in $DEVICES; do
    echo "Configurando device: $SERIAL"

    # 2. Instalar APK
    adb -s $SERIAL install nytrix-worker.apk

    # 3. Autorizar permisos
    adb -s $SERIAL shell pm grant com.nytrix.worker android.permission.SYSTEM_ALERT_WINDOW

    # 4. Crear Worker en DB
    curl -s -X POST http://localhost:3006/api/farm/register-device \
      -H "Content-Type: application/json" \
      -d "{\"serial\": \"$SERIAL\", \"index\": $COUNT}"

    COUNT=$((COUNT + 1))
done

echo "Farm setup completo: $COUNT devices configurados"
```

### 3.2 — Device Auto-Discovery Endpoint
```javascript
// backend/src/api/routes/farm.js
router.post('/register-device', async (req, res) => {
  const { serial, index } = req.body;

  // 1. Crear Worker
  const worker = await Worker.create({
    orchestratorDeviceId: serial,
    name: `bot-${String(index).padStart(3, '0')}`,
    status: 'online',
    activeOrders: 0,
    config: { maxDailyTasks: 50 }
  });

  // 2. Crear User bot
  const botUser = await User.create({
    email: `bot-${String(index).padStart(3, '0')}@nytrix.io`,
    password: hashedPassword(`BotPass${index}!`),
    is_bot: true,
    name: `Bot ${String(index).padStart(3, '0')}`
  });

  // 3. TeamMembership como operator
  await TeamMembership.create({
    ownerId: TEAM_OWNER_ID,
    operatorId: botUser.id,
    role: 'operator'
  });

  // 4. JWT para este bot
  const token = generateToken(botUser);

  res.json({ workerId: worker.id, userId: botUser.id, token });
});
```

### 3.3 — Supervisord Config
```ini
[program:nytrix-bot-%(process_num)s]
command=python3 bot.py --token %(ENV_BOT_TOKEN_%(process_num)s)s --worker-id %(ENV_WORKER_ID_%(process_num)s)s --device-id %(ENV_DEVICE_%(process_num)s)s --sio --ws-url ws://BACKEND:3006/bot
numprocs=40
autostart=true
autorestart=true
startsecs=5
stopwaitsecs=30
killasgroup=true
stdout_logfile=/var/log/nytrix/bot-%(process_num)s.log
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=5
```

### 3.4 — Monitoring Endpoints
```
GET /api/farm/status       — todos los workers: online/offline/capacity
GET /api/farm/accounts     — WorkerPaymentAccount assignments
GET /api/farm/metrics      — throughput, success rate, avg time per bank
POST /api/farm/bot/:id/restart
```

---

## FASE 4: Frontend (1 día)

### 4.1 — Farm Dashboard (cards dinámicas)
- **Archivo nuevo**: `frontend/src/components/farm/FarmDashboard.tsx`
- Cards se crean al registrar device (no hay slots fijos)
- Cada card muestra:
  - Device serial + model
  - Status: online / busy (X/5 orders) / offline / error
  - Cuentas asignadas (bank + last4)
  - Uptime
  - Acciones: restart, pause, view screen
- Socket.IO subscription a `room 'dashboard'` para updates real-time

### 4.2 — useFarmStatus Hook
```typescript
function useFarmStatus() {
  // Socket.IO → room 'dashboard'
  // Recibe: worker:status_update, worker:capacity_update
  return { workers, metrics, refresh };
}
```

### 4.3 — Bot Screen Viewer
- Click en card → modal con screenshot live del phone
- WebSocket frame stream (ya existe en bot.py `_send_frames`)
- Auto-refresh cada 1s

---

## Dependencias Nuevas

| Capa | Paquete | Para qué |
|------|---------|----------|
| Python | `ppadb-reborn` | ADB connection pooling |
| Python | `pytesseract` | OCR ligero |
| Node.js | `ioredis` | Rate limiter distribuido |
| System | `redis-server` | Rate limiter |
| System | `tesseract-ocr` + `tesseract-ocr-spa` | OCR engine |
| System | `supervisord` | Process manager |

---

## Estimación de Tiempo

| Fase | Días | Qué se hace |
|------|------|-------------|
| FASE 0: Fundamentos | 1 | PostgreSQL pool, Redis, JWT por bot, Worker model update |
| FASE 1: Order Router | 2 | OrderRouter, rooms, rate limit, DB transactions, capacity endpoints |
| FASE 2: Bot Runtime | 2 | Account filtering, capacity management, ppadb, tesseract, heartbeat |
| FASE 3: Operations | 1 | Setup script, device registration, supervisord, monitoring |
| FASE 4: Frontend | 1 | Farm dashboard dinámico, screen viewer |
| **Total** | **~5-7 días** | |

## Criterios de Éxito
- [ ] Devices detectados dinámicamente → cards creadas automáticamente
- [ ] Cada bot opera solo sus cuentas (WorkerPaymentAccount)
- [ ] Cada bot hace claim de max 5 órdenes, ejecuta, vuelve a claim
- [ ] 40 bots × 5 = 200 operaciones concurrentes posibles
- [ ] Sin choques entre bots (cada uno tiene credenciales propias)
- [ ] Socket.IO envía orders solo al bot correcto (room-scoped)
- [ ] Rate limiter separado por bot
- [ ] DB transactions en AccountJournal (sin race conditions)
- [ ] OCR <1s, ADB <20ms
- [ ] Supervisord auto-restart en crash
- [ ] Frontend muestra capacity de cada bot en real-time
