# NYTRIX Backend — Capsule

> Stack, endpoints clave, auth flow. ~60 líneas para arrancar rápido.

## Stack
Express + Sequelize + SQLite/PostgreSQL | JWT auth | Puerto 3006

## Auth Flow
- Login: POST /api/auth/login → JWT token
- Register: POST /api/auth/register
- Admin: admin@nytrix.io / Admin123!
- App: yizuz@nytrix.io / Admin123!

## Endpoints Críticos
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | /api/auth/login | Login |
| GET | /api/workers/stats | Stats workers |
| GET | /api/tasks/stats | Stats tareas |
| POST | /api/tasks | Crear tarea (idempotencyKey auto) |
| GET | /api/employee/metrics | Métricas operador |
| GET | /api/admin/finance/trading-dashboard | Dashboard financiero |
| GET | /api/payment-accounts/banks | 28 bancos Venezuela |
| GET | /api/admin/employee/ranking | Ranking empleados |

## Modelos Clave
- **User**: modelo principal de usuarios
- **TeamMembership**: `ownerId`, `operatorId`, `role` (admin|operator)
- **Worker**: dispositivos Android conectados
- **TaskExecution**: state machine con idempotencyKey UNIQUE
- **FinancialMovement**: BUY/SELL con profit calculator
- **PaymentAccount**: pago móvil y transferencia

## State Machine Tasks
pending → assigned → in_flight → done | failed | needs_review
failed → pending (retry)
needs_review → done | failed

## Workers (Phase A-D completas)
- Dashboard, config, monitoreo, grupos, health ✅
- Task + idempotency system ✅
- WebSocket orchestrator ✅
- ADB+Python prototype ✅

## Ver También
- [[../wiki/proyectos/nytrix|NYTRIX]] — hub completo
- [[./nytrix-workers|NYTRIX Workers]] — detalle de workers
