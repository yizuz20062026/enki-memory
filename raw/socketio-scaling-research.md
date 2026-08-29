---
tags:
  - research
  - socketio
  - scaling
  - redis
created: 2026-07-17
type: raw
---
# Socket.IO Scaling — Research (17 Jul 2026)

## Límites Conocidos
- Single Node.js process: ~30-40k conexiones WebSocket
- Sin Redis adapter: rooms son locales al proceso
- `io.emit()` broadcasting: O(n) por mensaje, O(n²) si todos emiten

## Solución: Redis Adapter

### Cómo funciona
- Cada `io.to("room").emit()` se convierte en Redis publish
- Cada Socket.IO process se suscribe y hace fan-out local
- Sin adapter: funciona en dev, falla silenciosamente en prod

### Sharded Redis Adapter (2026 best practice)
- Usa Redis 7 sharded pub/sub
- Particiona channels por hash slot
- Cada Redis shard solo carries traffic for its rooms
- **Linear scaling to 500k+ connections across 8-shard cluster**

### Configuración Típica
```javascript
const io = new Server(server, {
  cors: { origin: '...', methods: ['GET', 'POST'] },
  pingTimeout: 60000,
  pingInterval: 25000,
  maxHttpBufferSize: 5e6, // 5MB para frames
  transports: ['websocket'], // Solo WS, no polling
});
// Con Redis adapter:
const { createAdapter } = require('@socket.io/redis-adapter');
const { createClient } = require('redis');
io.adapter(createAdapter(pubClient, subClient));
```

## Room-Based Broadcasting (nuestro caso)

### Antes (global broadcast)
```javascript
this.io.emit('chat:new', data); // A TODOS los 40 bots
```

### Después (room-scoped)
```javascript
this.io.to(`team_${ownerId}`).emit('chat:new', data); // Solo al equipo
this.io.to(`worker_${workerId}`).emit('bot:log', data); // Solo a 1 bot
```

## Namespace Partitioning
- Namespace = canal aislado de eventos
- Dashboard namespace en un fleet de pods
- Bot streaming namespace en otro
- Redis clusters separados si es necesario

## Rate Limiting Multi-Tenant

### Problema actual
- 40 bots → mismo JWT → misma key de rate limiter
- Límite 60 req/min P2P se alcanza rápido

### Solución
- Rate limiter separado para bots
- Key por `workerId` en vez de `userId`
- Límites diferentes: humanos 60/min, bots 200/min per worker
- Redis-backed para distribuido

## Sticky Sessions (si escalamos a múltiples servers)
- Load balancer debe mantener same backend per client
- IP hash o connection cookie
- Sin sticky sessions: Socket.IO handshake falla

## Fuentes
- callsphere.ai/blog/scaling-socket-io-past-100k-connections
- medium.com/@connect.hashblock/scaling-socket-io
- oneuptime.com/blog/nodejs-websocket-socketio-scaling
- armanhazrati.dev/blog/scaling-websocket-infrastructure
- socket.io/docs/v4/redis-adapter
