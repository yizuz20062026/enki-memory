# Sesión: 16 Julio 2026 — Bot como Operador

## Logros
1. **Backend**: `is_bot` field en User model, `userId` en Worker model
2. **Auto-seed**: bot@nytrix.io se crea automáticamente al iniciar el backend
3. **API endpoints**: `/api/workers/bot/user`, `/bot/link-worker`, `/bot/assign-account`
4. **Auth normalization**: middleware normaliza `id` → `userId` en el JWT para que bot tokens funcionen con endpoints regulares
5. **Bot**: dual WS (legacy `/bot` para frames+comandos + Socket.IO para `chat:new` como operador)
6. **Bot**: auto-claim de órdenes P2P cuando `canonicalPayMethod` coincide con un PaymentAccount del bot
7. **Bot**: mark-paid automático después de ejecutar transferencia

## Comandos para iniciar bot en modo operador
```bash
# Obtener JWT del bot
BOT_JWT=$(curl -s -X POST http://localhost:3006/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"bot@nytrix.io","password":"NytrixBot2026!"}' | \
  python3 -c "import sys,json; print(json.load(sys.stdin).get('token',''))")

# Iniciar bot con Socket.IO
cd ~/nytrix/worker-bot
nohup .venv/bin/python3 bot.py \
  --ws-url ws://localhost:3006/bot \
  --sio \
  --token "$BOT_JWT" \
  --worker-id c7e30a4f-937f-4b57-910c-cc8cc361f739 \
  > /tmp/nytrix-bot-sio.log 2>&1 &
```

## Cambios clave en backend
- `backend/src/database/models/User.js`: +`is_bot` BOOLEAN
- `backend/src/database/models/Worker.js`: +`userId` UUID FK→Users
- `backend/src/database/migrate.js`: columnas `userId`(Workers) e `is_bot`(Users)
- `backend/src/server.js`: seed de bot user + TeamMembership
- `backend/src/auth/authMiddleware.js`: normalización `id`→`userId`
- `backend/src/websocket/socketServer.js`: normalización `id`→`userId`
- `backend/src/api/routes/workers.js`: 3 endpoints nuevos para bot config

## Cambios clave en bot
- `worker-bot/bot.py`: +socketio.AsyncClient, +requests, +connect_socketio(), +_fetch_accounts(), +_handle_chat_new(), +_execute_order()
- `worker-bot/bot.py`: --sio flag, dual connection legacy WS + Socket.IO

## Pendiente
1. **Transfer flow real**: `_execute_order()` tiene stub — hay que implementar la interacción ADB real para hacer la transferencia bancaria
2. **Account movements**: registrar AccountMovement desde el bot en cada operación
3. **Complete order**: después de mark-paid, implementar `POST /api/orders/:id/complete`
4. **Más drivers**: Nequi, Bancolombia — actualmente solo Daviplata
5. **Frontend BotConsole**: agregar indicador de modo operador + órdenes activas

## Credenciales bot
- Email: bot@nytrix.io
- Password: NytrixBot2026!
- Worker ID: c7e30a4f-937f-4b57-910c-cc8cc361f739
- Daviplata Account: dfe4d996-7e04-471a-80dc-9f6173d62b6c
