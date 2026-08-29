---
tags: [pmie, session, auditoria, datos]
fecha: 2026-07-31
proyecto: pmie
estado: AUDITORÍA COMPLETA + FIX PAY_METHOD + MONTOS
commit: 69b25cb
---

# Sesión 31 Jul 2026 — PMIE: Auditoría de métodos, fix "BANK", montos mín/máx

## Qué se hizo
1. **Auditoría de datos Binance vs BD** (script `/tmp/opencode/audit-binance.py` + `compare-volume.py`):
   - Se scrapeó Binance P2P VES en vivo (4 páginas × BUY/SELL) y se comparó contra `ad_snapshots` y `ad_aggregates_1h`.
   - **Hallazgo clave**: el `identifier` de Binance es una CATEGORÍA INTERNA, NO el nombre visible. El nombre real viene en `tradeMethodName`.
   - Ejemplos: `BANK`→"Bank Transfer", `BBVABank`→"BBVA", `PagoMovil`→"Pago Movil", `ScotiabankColpatria`→"DAVIbank", `BancolombiaSA`→"Bancolombia S.A".
   - El volumen NO tenía métodos fantasma — las jerarquías coincidían. El problema era solo de NOMBRES.
2. **Fix `extractPayMethods`** (`apps/worker/src/scan.ts`): ahora usa `tradeMethodName ?? identifier`.
3. **Gap de montos**: `normalize.ts` ya calculaba `minTransAmountUsdt`/`maxTransAmountUsdt` pero NO se persistían. Se agregaron columnas (`migración 0005`), persistencia en `scan.ts`, y conversión correcta a USDT (Binance manda fiat local → dividir por price).
4. **Migración de datos históricos**: renombrado `pay_method` en 8 tablas (snapshots, state, events, agg1h/1d, alerts, decision_state, merchant_profiles) vía temp table `method_map` con merge de duplicados. ~127k snapshots + ~660k events renombrados.
5. **API `/api/analysis/methods`**: ahora lee de `ad_snapshots` y expone `buy/sell_min_txn/max_txn`.
6. **Dashboard**: columnas "mín/máx" en la tabla comparativa de Overview (`fmtTxn` helper).

## Errores que se fueron resolviendo en el camino
- `psql` heredoc: `ON COMMIT DROP` con autocommit borraba la temp table entre statements → usar `BEGIN/COMMIT` explícito.
- Colisión en `merchant_profiles`/`decision_state` durante UPDATE → estas tablas son DERIVADAS: se borran las filas con identifier viejo y el worker las regenera solas (15-45s).
- Columnas DB de alerts/decision/profiles se llaman `pay_method` (no `method`).
- `/api/analysis/methods` original leía `price_top1` de `ad_aggregates_1h` → al cambiar a `ad_snapshots` la columna correcta es `price` (min/max/avg según lado).
- Snapshots del worker seguían con `minTransAmountUsdt` en fiat local (sin dividir) → fix en `normalize.ts` + re-backfill.

## Verificación
- `tsc --noEmit` limpio en db/scanner/worker/api/dashboard.
- `vite build` OK. Tests: 13/13 decision, 8/8 scanner (no tocados), API 4 (no cubren /methods).
- Endpoint `/api/analysis/methods?fiat=VES` devuelve nombres visibles + montos en USDT correctos.
- Cero `identifier` restantes en snapshots. Worker/API/dash corriendo.

## Pendiente / Próxima sesión
1. **Commit 69b25cb es el último** — ya pusheado a GitHub.
2. Verificar visualmente el dashboard (F12) con los nuevos nombres y montos mín/máx.
3. **F5 — Prediction Engine** (del plan): distribución por hora, medias móviles, probabilidad de venta, backtest ≥60%. Dashboard "mejor horario hoy".
4. Consumidor API (gestor de anuncios): definir contrato primero.
5. Infra: decidir VPS vs NYTRIX.
6. Actualizar `wiki/proyectos/pmie.md` y `wiki/proyectos/pmie-plan.md` con lo implementado hoy si hace falta.

## Handoff
Servicios vivos: worker (nohup), API 3008 (nohup), dash 5174 (nohup). Logs en /tmp/opencode/{pmie-worker,pmie-api,pmie-dash}.log. Reiniciar con fuser -k 3007/tcp 3008/tcp + nohup. NUNCA `pkill -f "tsx src"`.
