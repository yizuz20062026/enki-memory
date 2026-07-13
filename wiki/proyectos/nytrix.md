# NYTRIX

> Hub del proyecto NYTRIX — plataforma de trading P2P.

## Estado Actual
- **Fase**: Workers Fase 5 completa, Phase A-D completas
- **Pendiente**: Phase E (APK Worker Nativa), Phase F (Production Lockdown)

## Stack
| Capa | Tecnología |
|------|-----------|
| Backend | Express + Sequelize + SQLite/PostgreSQL |
| Frontend | React + Vite + Tailwind + react-query + recharts |
| Landing | [[../conocimiento/nextjs16\|Next.js 16]] |
| Auth | JWT |
| Workers | WebSocket orchestrator + ADB+Python |

## Servicios
| Servicio | Puerto |
|----------|--------|
| Backend API | 3006 |
| Frontend | 5173 |
| Landing | 3447 |

## Modelos de Usuario
- **Owner**: Primer usuario que crea el equipo (`ownerId === operatorId` en TeamMembership)
- **Admin**: `TeamMembership.role = 'admin'`
- **Operador**: `TeamMembership.role = 'operator'`
- **REGLA**: "NYTRIX app" = modelo User. NO confundir con Staff model.

## Módulos Principales
- [[../../capsules/nytrix-workers\|Workers]] — Dashboard, config, monitoreo, grupos, health, tasks
- Payment Accounts — Pago móvil y transferencia, 28 bancos Venezuela
- Financial Movements — BUY/SELL con profit calculator
- Employee Metrics — métricas por operador, ranking

## API Endpoints Clave
- `GET /api/workers/stats` — estadísticas workers
- `GET /api/tasks/stats` — estadísticas tareas
- `POST /api/tasks` — crear tarea con idempotencyKey
- `GET /api/employee/metrics` — métricas operador
- `GET /api/admin/finance/trading-dashboard` — dashboard financiero

## Credenciales (Dev)
- App: yizuz@nytrix.io / Admin123!
- Admin: admin@nytrix.io / Admin123!

## GitHub
- Repo: `github.com/yizuz20062026/nytrix`

## Decisiones Relacionadas
- [[../decisiones/seguridad-web\|Seguridad Web]]
