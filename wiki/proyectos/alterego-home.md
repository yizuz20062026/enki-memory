# Alterego Home

> Hub del proyecto Alterego Home — monorepo de e-commerce.

## Estado Actual
- **FASE 0**: Fundación completada
- **FASE 1**: Dropi Core en progreso

## Stack
| Capa | Tecnología |
|------|-----------|
| Monorepo | pnpm + Turborepo |
| DB Backend | PostgreSQL 16 + Redis 7 (Docker) |
| Frontend | [[../conocimiento/nextjs16\|Next.js 16]] |
| Dev Server | `npx next --turbopack -p 3445` en `packages/web` |

## Contenedores Docker
- `alterego-postgres` — PostgreSQL 16
- `alterego-redis` — Redis 7

## FASE 1 — Dropi Core
- Cliente Dropi + sync engine + webhooks creados
- Token API pendiente desde app.dropi.co → Mis Tiendas
- Ver [[../conocimiento/dropi-colombia\|Dropi Colombia API]] para detalles

## Ubicación
- `~/alterego-home/`
