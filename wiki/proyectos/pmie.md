---
tags:
  - pmie
  - p2p
  - binance
  - inteligencia-mercado
status: propuesto
created: 2026-07-31
---
# PMIE — P2P Market Intelligence Engine

> Hub del proyecto PMIE — sistema de inteligencia de mercado para Binance P2P (COP + VES).
> Servicio independiente de NYTRIX. El "cerebro" que alimenta al gestor de anuncios.

## Estado Actual
- **Fase**: Propuesto (diseño v1 aprobado 31 Jul 2026)
- **PLAN MAESTRO**: [[pmie-plan|Plan Maestro PMIE]] ← fuente de verdad, siempre contrastar contra este
- **Decisión de Yizuz**: proyecto aparte de NYTRIX, sin sobrecargarlo
- **Accesso Binance**: anónimo CONFIRMADO (ver [[../../raw/binance-p2p-endpoints-research|research]])
- **Frecuencia**: adaptativa con jitter (30-60s por mercado), NO 20s fijos

## Objetivo
Convertir millones de registros históricos en conocimiento accionable: mejor horario, spread, liquidez, persistencia de anuncios, ranking de comerciantes, predicciones. Que el gestor de anuncios deje de competir solo por precio y opere estratégicamente.

## Arquitectura — 7 componentes (de 14 módulos de la ficha original)

```
Binance P2P
    │
    ▼
[1] SCANNER ── adv/search + ad-list, adaptativo, jitter, backoff
    │
    ▼
[2] STORE & PIPELINE ── PostgreSQL, raw 60d + agregados eternos
    │
    ▼
[3] DIFF & IDENTITY ── advNo tracking: aparece/desaparece/cambia
    │
    ▼
[4] ANALYTICS ENGINE ── agregación multi-dimensional
    │   (banco/método/rango/comerciante/hora/día)
    │
    ├── [5] DECISION ENGINE ── reglas → recomendaciones + alertas
    ├── [6] PREDICTION ENGINE ── mejor horario, probabilidades, spread
    └── [7] DASHBOARD ── KPIs + heatmaps + rankings
           │
           ▼
      API PÚBLICA → gestor de anuncios (aún no existe, contrato se define aquí)
```

## Recortes aplicados a la ficha original (14 → 7)
- M10 (Predicción Horaria) + M14 (Inteligencia Predictiva) → **1 Prediction Engine**
- M13 (Estadísticas) → librería interna del Analytics Engine, no módulo
- M4 (Mapa de Calor) → vista dentro del Dashboard
- M8 (Ranking) + M9 (Grandes Operadores) → mismo motor con umbrales
- M5 + M6 + M13 → una sola agregación multi-dimensional
- M11 (Recomendaciones) + M12 (Alertas) → comparten el Decision Engine
- Premisa "no sobrescribir, guardar todo" → **imposible** a 20s. raw 30-60d + agregados eternos

## Expansiones críticas (lo que la ficha no cubría)
1. **advNo** — identidad estable del anuncio (Binance lo provee). Tracking de persistencia directo.
2. **Diff Engine** — aparece/desaparece/cambia precio/cambia disponibilidad por snapshot.
3. **Anti-bloqueo** — jitter + backoff exponencial + no usar cuenta del cliente para escanear.
4. **Volumen real** — 4 mercados × ~100 anuncios × snapshots = millones de filas/mes. PostgreSQL + particionado, NO SQLite.
5. **Observabilidad del scanner** — health checks, métricas de éxito/fallo, alerta si el scanner muere.
6. **Contrato de API** — definir endpoints + auth desde el día 1 para el futuro gestor.

## Mercados y bancos
- **COP**: Bancolombia, Nequi, Davivienda, Daviplata, Banco de Bogotá, BBVA, Nu, Lulo, AV Villas, Caja Social, Popular, Agrario
- **VES**: Bco Venezuela, Bancamiga, Banesco, Mercantil, BNC, Provincial, Bco Nacional de Crédito, Tesoro, Exterior, Pago Móvil

## Stack
| Capa | Tecnología |
|------|-----------|
| Backend | Node.js + TypeScript + BullMQ (Redis) |
| DB | PostgreSQL + particionamiento + agregados |
| Frontend | React + Vite + Tailwind + recharts |
| Predicción | Stats TS primero, ML opcional después |
| Ops | Supervisord/tmux en VPS (pendiente decidir dónde) |

## Roadmap MVP (~4 semanas)
| Fase | Qué | Tiempo |
|------|-----|--------|
| 0 — Fundación | Repo, DB, scanner COP compra, adapter, raw fluyendo | 2-3d | ✅ |
| 1 — Identidad y Cambios | Diff engine + 4 mercados | 3-4d | ✅ |
| 2 — Analytics | Agregación multi-dim + API | 5d | ✅ |
| 3 — Dashboard | KPIs, heatmaps, ranking | 4d | ✅ |
| 4 — Decisiones | Reglas → recomendaciones + alertas | 4d | ✅ (e44d54a) |
| 5 — Predicción | Mejor horario, probabilidad venta | 5-7d | ⏳ próxima |

## Decisiones abiertas
- [ ] Dónde correrá 24/7 (VPS propio vs mismo de NYTRIX)
- [ ] Nombre final del repo/módulo
- [ ] Contrato exacto de la API de salida

## Decisiones 31 Jul 2026 (v2)
- **Ads promocionados**: SE EXCLUYEN de la data. No cuentan para recomendaciones ni rankings.
  - El endpoint NO expone flag de bid → filtro heurístico por discordancia posición-precio (ver research).
- **Filtros Binance**: el endpoint soporta `publisherType: "merchant"` (solo verificados) y ordena por precio. Ambos se usan.
- **Dashboard visual**: estilo TradingView yield-curve adaptado → X = método de pago, Y = precio/spread, series Compra/Venta/Top1/Top5, selector 15m-90d, heatmap tabla. Ver research para spec completa.
- **F4 Decision Engine (31 Jul)**: reglas puras primero (sin I/O), `packages/decision` con 13 tests. Spread se deriva del cruce BUY/SELL (no se almacena). Alertas → tabla `alerts` + Socket.IO `pmie:alert` (endpoint interno POST /internal/alerts con token). Estrategias: be_leader (seguir Δtop1), follow_pack (banda 0.15%), fortress (premium 0.3% + pausar si spread < 0.3%). Anti-oscilación: fuerza min 0.6, ventana 30min.

## Estado F4 — Decision Engine (31 Jul 2026) ✅
- `packages/decision/` — engine.ts (recommendMethod/recommendMarket/stabilize), merchant.ts (buildProfiles/detectStrategy), 13 tests
- DB: tablas `alerts`, `decision_state`, `merchant_profiles` (migración 0004)
- Worker: `decision.ts` — buildSignals (agregados 1h + spread + persistencia), job cada 5min, alertas (price_spike/spread_inverted/spread_extreme/low_activity/big_merchant), perfiles cada 15min
- API: `/api/decisions/{state,history,alerts,profiles}` + POST /internal/alerts + Socket.IO
- Dashboard: vista Decisiones (cards estado, tabla alertas live, tabla merchants)
- DONE when cumplido: 5+ escenarios probados (13/13), simulación 1h sin ciclos, Socket.IO real verificado
- Commit: `e44d54a` · tests totales 32/32 · typecheck monorepo OK
- Bug fix clave: CTE `bounds` sin `FROM ad_aggregates_1h` → error `column bucket_time does not exist` (columna existe; faltaba la tabla).

## Fix pay_method + montos (v4 — 31 Jul 2026) ✅
- **Auditoría Binance vs BD**: el `identifier` de Binance es CATEGORÍA INTERNA, no el nombre visible. El nombre real = `tradeMethodName`.
  - `BANK`→"Bank Transfer", `BBVABank`→"BBVA", `PagoMovil`→"Pago Movil", `ScotiabankColpatria`→"DAVIbank", `BancolombiaSA`→"Bancolombia S.A".
- **Fix**: `extractPayMethods` usa `tradeMethodName ?? identifier`. Migración histórica renombró `pay_method` en 8 tablas (~127k snapshots, ~660k events) vía temp table `method_map` + merge duplicados.
- **Montos mín/máx**: columnas `min/max_trans_amount_usdt` (USDT — Binance manda fiat local, dividir por price). Migración `0005`. `/api/analysis/methods` ahora lee de `ad_snapshots` y expone `buy/sell_min_txn/max_txn`. Overview muestra columnas "mín/máx".
- `merchant_profiles`/`decision_state` son DERIVADAS → se regeneran solas con el worker (borrar filas con identifier viejo + reiniciar).
- Commit: `69b25cb` · tsc limpio · vite build OK · 13/13 decision tests
- Detalle completo en [[../../sessions/2026-07-31-pmie-paymethod-fix|Sesión auditoría]]

## Pendiente próximo
- **F5 — Prediction Engine** (ver [[pmie-plan|Plan Maestro]]): distribución por hora, medias móviles, probabilidad de venta por rotación, spread esperado, señal macro VES, backtest ≥60% acierto, dashboard "mejor horario hoy".
- Verificar visualmente dashboard con nuevos nombres/montos.
- Definir contrato del consumidor API (gestor de anuncios).
- Decidir infra 24/7 (VPS vs NYTRIX).

## Dimensión MONTOS (v3 — 31 Jul 2026)
- `transAmount` validado en vivo: cambia el mercado radicalmente (0 ads a $50 COP, 58 a $20k, 189 a $200k, 268 sin filtro).
- **Optimización**: NO escanear cada rango (multiplicaría peticiones). Cada ad trae min/max → clasificar localmente por bucket.
- Buckets: 0-50, 50-100, 100-300, 300-500, 500-1000, 1000-5000, 5000+ USDT.
- Las métricas (precio/liquidez/competencia) se calculan POR BUCKET de monto + método + mercado.
- Ver [[../../raw/binance-p2p-strategies-research|Research]] para tabla validada en vivo.

## Organización de datos (estilo TradingView, v3)
- **3 vistas**: Heatmap (size=liquidez, color=cambio%), Screener (columnas configurables), Multi-timeframe dashboard (dots por condición).
- **Retención total**: guardar `raw_json` completo de cada ad + campos normalizados. Nada se pierde.
- **Granularidad temporal**: 1m/15m/1h/1d/1s/1M como columnas en la matriz.

## Research 31 Jul 2026 — Estrategias de merchants
- **No existe WS para P2P** → polling REST con jitter es el estándar de la industria (pilotbot, AutoP2P, P2P.Army usan polling).
- Estrategias pricing: be_leader, follow_pack, fortress, humanize + **spread guard** siempre.
- Motor 12-fase AutoP2P: tomar fases de order book depth, position scoring, tendencia, anti-oscilación, circuit breaker.
- **Ad Bidding** (nuevo): merchants pagan por posición #1 → distinguir ads con bid vs normales en recomendaciones.
- Índice de Persistencia + Activity 24H (P2P.Army) = par complementario.
- VES es macro-sensible (bolívar cayó 16% en 30d) → predicción VES necesita señal de macro-riesgo.
- ML al final, NO al inicio: stats + reglas primero, ML con 30-90d de datos.
- Ver [[../../raw/binance-p2p-strategies-research|Strategies Research]]

## Skills aplicables (cargadas 31 Jul 2026)
- **postgres-pro** — TimescaleDB, particionado, EXPLAIN, autovacuum para tablas de snapshots
- **database-optimizer** — índices, queries de agregación, covering indexes
- **monitoring-expert** — pino logging, prom-client, health checks del scanner 24/7

## Relacionados
- [[nytrix|NYTRIX]] — la plataforma a la que alimentará
- [[../../raw/binance-p2p-endpoints-research|Endpoints Binance validados]]
- [[nytrix-phone-farm-scale|Phone Farm Scale]]
