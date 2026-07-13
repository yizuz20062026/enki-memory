# NYTRIX Workers — Capsule

> Fases completadas, WebSocket protocol, ADB+Python. Contexto rápido.

## Fases Completadas
- **Fase 1**: Dashboard y Control — stats, health, filtros, device grid
- **Fase 2**: Configuración Avanzada — templates, wallet linking, notes
- **Fase 3**: Monitoreo y Métricas — gráficos, top workers, activity feed
- **Fase 4**: Pooling y Equipos — WorkerGroup + drag & drop
- **Fase 5**: Automatización y Lifecycle — states, auto-sync, health check, export

## Phase A — Mock → Live API ✅
- 25 endpoints en `workers.ts`
- Stats, métricas, top workers, actividad, export CSV desde API real

## Phase B — Task & Idempotency ✅
- Modelo TaskExecution con idempotencyKey UNIQUE
- 10 endpoints con state machine + validación de transiciones
- Frontend: stats cards, lista filtrada, búsqueda

## Phase C — Orchestrator WebSocket ✅
- Namespace `/orchestrator`
- Protocolo: register → heartbeat (15s) → task:assigned → progress → complete|fail
- deviceManager.js: registro, heartbeat, capacidades
- taskDispatcher.js: cola, dispatch cada 5s, auto-retry 3x

## Phase D — ADB+Python ✅
- `workers/python-worker/` con uiautomator2 + PaddleOCR
- Flujos: Banesco/Mercantil/Provincial (send, verify, capture, balance)
- Dry-run mode para testing sin dispositivo
- Uso: `python main.py --device-id <ADB> [--dry-run]`

## Pendiente
- **Phase E**: APK Worker Nativa
- **Phase F**: Production Lockdown

## Ver También
- [[../wiki/proyectos/nytrix|NYTRIX]] — hub
- [[./nytrix-backend|NYTRIX Backend]] — stack general
