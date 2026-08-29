---
tags:
  - adr
  - nytrix
  - architecture
  - scaling
status: proposed
date: 2026-07-17
version: 2
deciders:
  - Yizuz
  - Enki
---
# ADR-004: Phone Farm Scaling Architecture

> Architecture Decision Record — Escalar NYTRIX Bot Worker de 5-10 a 20-40 dispositivos concurrentes.

## Estado
**Propuesto** — 17 Julio 2026 (v2 — reestructurado)

## Contexto
Un cliente pregunta si NYTRIX puede conectarse a una phone farm box de 20-40 slots. Cada bot tiene sus propias cuentas y credenciales (puede ser el mismo banco, diferente cuenta). Cada bot hace claim de hasta 5 órdenes, las ejecuta, y vuelve a claim. El sistema actual soporta ~5-10 bots.

## Modelo Operativo
- 1 bot = 1 phone = 1 set de cuentas y credenciales
- Cada bot opera independientemente (no hay choque entre bots)
- Capacidad: max 5 órdenes concurrentes por bot
- Throughput: 40 bots × 5 = 200 operaciones simultáneas
- Cards dinámicas: se crean al detectar device via ADB

## Decisión

### 1. OrderRouter (reemplaza broadcast global)
**Antes**: `io.emit('chat:new')` → 40 bots reciben → 39 fallan claim
**Después**: `orderRouter.routeOrder()` → consulta WorkerPaymentAccount → emite SOLO al bot seleccionado
- Query: ¿qué workers tienen cuenta de este banco?
- Filter: ¿cuáles tienen activeOrders < 5?
- Select: least-loaded worker
- Emit: `io.to('worker_${id}').emit('order:assigned', data)`

### 2. WorkerPaymentAccount como fuente de verdad
**Antes**: Bot fetch `/api/payment-accounts/` → todas las cuentas del operador
**Después**: Bot fetch `/api/workers/${id}/accounts` → solo sus cuentas vinculadas
- El modelo YA EXISTE, solo hay que poblarlo y conectarlo

### 3. Capacity Management (activeOrders en Worker)
**Antes**: Sin tracking de capacidad
**Después**: `Worker.activeOrders` (INTEGER, max 5)
- Bot incrementa al claim, decrementa al completar
- Backend filtra workers con activeOrders < 5 antes de routing
- Frontend muestra capacity en real-time

### 4. JWT por bot
**Antes**: 1 JWT compartido para todos los bots
**Después**: 1 user + 1 JWT por bot (`bot-001@nytrix.io` ... `bot-040@nytrix.io`)
- Rate limits separados
- Audit trail por bot
- WorkerPaymentAccount vincula bot → cuentas

### 5. ppadb Connection Pool
**Antes**: `subprocess.run(["adb", ...])` por cada comando
**Después**: ppadb TCP socket persistente via ADB server
- Elimina 99% subprocess overhead
- Latencia: 50-200ms → 5-20ms

### 6. Tesseract OCR
**Antes**: EasyOCR per-process (500MB RAM, 2.45s inference)
**Después**: pytesseract (10MB, 0.82s inference)
- Para UI screenshots (texto limpio) es suficiente

### 7. Socket.IO Room-Based Broadcasting
**Antes**: `this.io.emit()` global
**Después**: `this.io.to('worker_${id}').emit()` solo al bot asignado

### 8. Rate Limiter por Bot
**Antes**: Key por userId (mismo JWT = mismo rate limit)
**Después**: Key por `workerId`, 200 req/min per bot

### 9. DB Transactions en AccountJournal
**Antes**: Read-then-write sin transacción (race condition en limits)
**Después**: `Sequelize.transaction()` + `SELECT FOR UPDATE`
- Balance check y update en la misma transacción

### 10. Supervisord
**Antes**: `nohup python bot.py &` (crashea = slot perdido)
**Después**: Supervisord con `autorestart=true`, `numprocs=N`

## Consecuencias

### Positivas
- 40 bots × 5 = 200 operaciones concurrentes
- Cada bot es independiente — sin choque entre bots
- Cards dinámicas — se crean al detectar device
- Throughput escala linealmente con más phones
- Mejora el sistema even para 5-10 bots actuales

### Negativas
- Redis dependency (rate limiter)
- Más complejidad de deployment (supervisord + redis + tesseract)
- WorkerPaymentAccount necesita setup inicial por cada bot

### Riesgos
- ADB server single-process puede ser bottleneck a 40+ devices
- USB bandwidth compartido entre phones
- Phone farm box hardware limits (~40 consumer board)
- Bank rate limits (mismo banco, diferentes credenciales — el banco puede bloquear si recibe muchas operaciones desde IPs similares)

## Alternativas Consideradas
1. **Orchestrator centralizado**: Más complejo, single point of failure. El modelo de capacidad por bot es más resiliente.
2. **BullMQ para claim queue**: Útil si hay problemas de thundering herd, pero el OrderRouter ya resuelve el routing. BullMQ es opcional.
3. **Docker per bot**: Overkill para 40 bots en 1 server.
