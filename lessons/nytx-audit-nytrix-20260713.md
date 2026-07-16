# Lección: Auditoría NYTX en NYTRIX

**Fecha**: 13 Julio 2026
**Proyecto**: [[../../wiki/proyectos/nytrix|NYTRIX]]
**Resultado**: Score 62 → 73.5/100 (+11.5)

## Qué funcionó
- Evaluación manual + automática complementaria (scanner no detecta configuraciones en código)
- Fixes quirúrgicos: sin romper funcionalidad existente, todos los tests pasan
- `Promise.all` con queries Sequelize como patrón anti-N+1 confiable
- Helmet CSP con `ws:/wss:` para WebSocket — defense-in-depth con nginx

## Qué no funcionó
- Scanner automático NYTX: no detecta helmet, CORS, Sequelize, rate limiting (regex limitada)
- Zod `RegisterSchema` incompleta causaba bugs sutiles en tests (strippaba campos del body)
- Git push sin scope `workflow` en PAT — GitHub lo requiere para `.github/workflows/`

## Patrón reutilizable
```
Promise.all([
  Model.findAll({ where, attributes: ['status', fn('COUNT', '*')], group: ['status'], raw: true }),
  Model.findAll({ where: alt, attributes: ['status', fn('COUNT', '*')], group: ['status'], raw: true }),
  Model.findOne({ where, attributes: [[fn('SUM', cast('amount', 'FLOAT')), 'total']], raw: true }),
])
```
Reemplaza `findAll().filter()` para métricas agregadas.

## Referencia
- [[../../sessions/2026-07-13-nytx-audit|Handoff sesión]]
- `nytx-report-nytrix-20260713-0528.md`
