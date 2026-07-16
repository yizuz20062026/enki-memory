# NYTRIX

> Hub del proyecto NYTRIX — plataforma de trading P2P.

## Estado Actual
- **Fase**: Workers Fase 5 completa, Phase A-D completas, NYTX Audit completa
- **NYTX Score**: 73.5/100 (+11.5 vs baseline 62)
- **Pendiente**: Phase E (APK Worker Nativa), Phase F (SSL, cron backups, dominio), N10 (métricas usuario)

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

## NYTX Audit (13 Jul 2026)
- Score: 62 → 73.5/100 (+11.5)
- SQL injection fix, Helmet+CSP, N+1 queries eliminados, WAL mode
- CI pipeline (GitHub Actions), backup script, coverage thresholds
- Auth audit logging, per-user rate limiting, health endpoint
- Reportes: `nytx-report-nytrix-20260713-0528.md`
- [[../../sessions/2026-07-13-nytx-audit|Handoff sesión]]

## Decisiones Relacionadas
- [[../decisiones/seguridad-web\|Seguridad Web]]
