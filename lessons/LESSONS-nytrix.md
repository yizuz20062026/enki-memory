# LESSONS — NYTRIX

## Activas

### [L1-004] FinancialMovement profit calculator hardcodea rates
**Fecha**: 2026-07-11
**Proyecto**: NYTRIX
**Severidad**: media
**Estado**: active

**Trigger**: Cuando se calcula profit entre monedas fiat
**Acción**: Los exchange rates están hardcodeados (VES=0.018, COP=0.00023, etc.). En producción, usar API de tasas de cambio.
**Verificación**: Profit calculado coincide con cálculo manual.

---

### [L1-005] Task idempotency key previene duplicados
**Fecha**: 2026-07-11
**Proyecto**: NYTRIX
**Severidad**: alta
**Estado**: active

**Trigger**: Cuando se crea una tarea que podría reintentarse
**Acción**: Siempre generar idempotencyKey único. El sistema retorna 409 si la key ya existe con estado completado.
**Verificación**: Reenviar la misma request retorna 409, no crea tarea duplicada.

---

## Invalidadas
(_Ninguna aún_)
