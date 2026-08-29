---
tags:
  - pmie
  - plan
  - roadmap
  - arquitectura
status: activo
created: 2026-07-31
version: 1
---
# PMIE — PLAN MAESTRO (Fuente de Verdad)

> Documento fijo de PMIE. Todo el desarrollo se contrasta contra este plan.
> Si algo cambia → se actualiza AQUÍ primero, y se versiona.

## 0. Visión
Sistema de inteligencia de mercado para Binance P2P (COP + VES) que captura, organiza y analiza los anuncios públicos para convertir millones de registros en decisiones estratégicas: mejor horario, spread, liquidez, persistencia de anuncios, ranking de comerciantes y predicciones. Independiente de NYTRIX.

## 1. Alcance (qué SÍ / qué NO)

### SÍ
- Escaneo continuo de anuncios P2P públicos (COP/VES, compra/venta, USDT)
- Clasificación por: método de pago, rango de monto, verificado/todos, tiempo
- Almacenamiento histórico + agregados eternos
- Dashboard analítico (heatmap, yield-curve, screener, multi-timeframe)
- Motor de reglas → recomendaciones + alertas
- Predicción estadística (mejor horario, probabilidad de venta, spread)
- API de salida para el futuro gestor de anuncios

### NO (por ahora)
- Ejecutar órdenes ni operar cuentas (eso es NYTRIX)
- Conectarse al gestor de anuncios (no existe aún)
- ML/LSTM pesado (solo stats hasta tener 30-90d de datos)
- Otros mercados fuera de COP/VES
- WebSocket a Binance (no existe para P2P — polling es el estándar)

## 2. Reglas FIJAS (no negociables)
1. PMIE es proyecto aparte — no sobrecarga NYTRIX
2. SQLite NO sirve → PostgreSQL + particionado por tiempo
3. Frecuencia adaptativa con jitter 30-60s (NUNCA 20s fijos)
4. 1 scan sin filtro de monto → clasificación local por bucket (NO 7 escaneos)
5. Guardar `raw_json` completo de cada ad — ningún dato se pierde
6. Ads promocionados se EXCLUYEN (heurística discordancia posición-precio)
7. No exponer secrets; API de salida con API keys
8. `tsc --noEmit` + tests antes de considerar una fase completa
9. **Cada país (fiat) es un SILO independiente** — no se mezclan métodos de pago ni se comparan precios entre COP y VES. No hay conversión de fiat. Métodos, métricas, dashboards y análisis se organizan SIEMPRE por país.

## 3. Matriz de datos maestra (el corazón)

```
Celda = [País/Mercado] × [Método pago] × [Rango monto] × [Compra/Venta] × [Verificado/Todos] × [Buckets de tiempo]
```

- **País (raíz, silo independiente)**: COP (Colombia), VES (Venezuela). NUNCA se cruzan.
- Métodos COP: Nequi, BancolombiaSA, BreBKeys, DaviviendaSA, Daviplata, BancodeBogota, BBVABank, BancoSocialColombia, CashDeposit, ScotiabankColpatria, BancoPopular
- Métodos VES: BancoDeVenezuela, BANK, Banesco, Mercantil, Provincial, PagoMovil, BBVABank, BNCBancoNacional, Bancamiga, RecargaPines, BancoVeneCredit, Banplus, BancoDelTesoro, Bancaribe, R4
- Rangos monto (USDT): 0-50, 50-100, 100-300, 300-500, 500-1000, 1000-5000, 5000+
- Lado: BUY (comprar USDT), SELL (vender USDT)
- Publicador: verified (publisherType=merchant), all
- Tiempo: 1m, 15m, 1h, 1d, 1s, 1M (agregados)

### Métricas por celda
- precio_top1, precio_top5, precio_promedio, precio_min, precio_max
- spread (buy-sell), spread_por_metodo
- ads_count, merchants_count
- liquidez_visible (sum tradableQuantity USDT)
- persistencia (tiempo visible promedio de ads) — Índice de Persistencia
- rotación (ads que aparecen/desaparecen por hora) — Activity 24H
- verificado_vs_total (señal de confianza)

## 4. Arquitectura — 7 componentes

```
Binance P2P
   │
   ▼
[1] SCANNER (4 workers COP/VES × compra/venta)
   │  jitter 30-60s · páginas 1..N · clasificación bucket monto · raw_json
   ▼
[2] STORE & PIPELINE (PostgreSQL+TimescaleDB · BullMQ)
   │  raw 60d → diff engine → agregados 1h/1d eternos
   ▼
[3] DIFF & IDENTITY (advNo)
   │  aparece / desaparece / cambia precio / cambia disponibilidad
   ▼
[4] ANALYTICS ENGINE (agregación multi-dimensional)
   │  → vistas: heatmap, yield-curve, screener, multi-timeframe
   │
   ├── [5] DECISION ENGINE (reglas → recomendaciones + alertas)
   │        spread guard · anti-oscilación · circuit breaker · tipo merchant
   ├── [6] PREDICTION ENGINE (stats: percentiles, medias móviles, distribución por hora)
   └── [7] DASHBOARD (React + Vite + recharts)
          │
          ▼
     API PÚBLICA (Fastify + API keys) → futuro gestor de anuncios
```

## 5. Stack tecnológico — decidido y POR QUÉ

| Capa | Tecnología | Por qué (decisión) |
|------|-----------|--------------------|
| Lenguaje | TypeScript (strict) | Estándar del ecosistema, type safety para contratos de Binance |
| Monorepo | pnpm + Turborepo | Consistente con alterego-home; paquetes compartidos |
| Scanner | Node.js workers + `node-cron` | Proceso liviano, schedule configurable con jitter |
| Pipeline | BullMQ + Redis | Cola para normalizar/clasificar/agregar en background sin bloquear |
| DB | PostgreSQL 16 + **TimescaleDB** | Time-series nativo, particionado automático por tiempo |
| ORM | Drizzle ORM + `pg` | TS-first, soporta queries raw y particionado |
| API | Fastify + Zod | Rápido para APIs de datos, validación nativa |
| Dashboard | React + Vite + Tailwind + recharts + TanStack Query | Consistente con NYTRIX; heatmaps y multi-línea |
| Predicción | TS stats (`simple-statistics`) | Sin over-engineering en v1; ML opcional después |
| Observabilidad | pino + prom-client + /health | El scanner 24/7 debe verse a sí mismo |
| Auth API | API keys (rotables) | Contrato para el gestor futuro |
| Ops | Docker Compose (dev) → Supervisord/tmux (prod) | Mismo patrón que NYTRIX |

## 6. Modelo de datos (tablas núcleo)

| Tabla | Propósito | Retención |
|-------|-----------|-----------|
| `ad_snapshots` | Raw por snapshot — incluye `raw_json` | 60 días |
| `ad_state` | Estado actual por advNo (upsert) | permanente |
| `ad_events` | Diff: apareció/desapareció/cambió | 6 meses |
| `ad_aggregates_1h` | Métricas por hora (matriz completa) | **eterna** |
| `ad_aggregates_1d` | Métricas por día | **eterna** |
| `merchants` | Perfil estadístico por comerciante | permanente |
| `scan_runs` | Salud del scanner (éxito/fallo/latencia) | 30 días |

Índices clave (Fase 2): `(fiat, method, amount_bucket, side, bucket_time)` compuesto + BRIN por tiempo en snapshots.

## 7. Fases de desarrollo

> Cada fase tiene: objetivo, entregables, criterios de aceptación (DONE when).
> Regla: NO pasar a la siguiente fase sin criterios cumplidos.

### FASE 0 — Fundación (2-3 días)
**Objetivo**: repo en pie + datos reales fluyendo de 1 mercado.

**Entregables**
- [x] Monorepo pnpm+Turborepo (`pmie/`)
- [x] Docker Compose: PostgreSQL+TimescaleDB+Redis
- [x] Schema DB inicial + migraciones (Drizzle)
- [x] Adapter Binance (`adv/search` + `ad-list`) con Zod validation
- [x] Scanner W1: COP compra, jitter 30-60s, páginas 1-3
- [x] `/health` + pino logging + scan_runs
- [x] Repo GitHub (privado) — github.com/Yizuz202530/pmie

**DONE when**
- [x] Primer snapshot almacenado con raw_json completo
- [x] `tsc --noEmit` pasa · test unitario del adapter (8/8)
- [x] Scanner sobrevive 1h sin baneo — successRate24h 99.6%, 284 scans, 4 mercados OK (verificado en /health)

### FASE 1 — Captura completa + Identidad y Cambios (3-4 días)
**Objetivo**: 4 mercados + diff engine con advNo.

**Entregables**
- [x] Workers W1-W4 (COP/VES × compra/venta) — loop multi-mercado secuencial
- [x] Clasificación local por bucket de monto (min/max del ad) — hecho en Fase 0
- [x] Diff engine: aparece/desaparece/cambia → `ad_events` (packages/diff, tests 7/7)
- [x] `ad_state` upsert por advNo (firstSeen/lastSeen/appearances)
- [x] Índice de Persistencia (tiempo visible por advNo/método) — /health/persistence
- [x] Filtro ads promocionados (heurística discordancia) — hecho en Fase 0

**DONE when**
- [x] 4 mercados capturando en paralelo estable (COP/VES × BUY/SELL, 60 ads c/u)
- [x] Diff detecta y registra eventos correctos (tests 7/7 + datos reales: appeared/disappeared/price_changed/amount_changed)
- [x] Persistencia calculada por método de pago

### FASE 2 — Analytics Engine (5 días)
**Objetivo**: matriz maestra consultable + agregados eternos.

**Entregables**
- [x] Agregación por hora y día a la matriz completa (apps/worker/src/aggregate.ts — SQL idempotente ON CONFLICT, backfill 24h + jobs cada 15min/6h)
- [x] Métricas por celda (top1/5/prom, spread, liquidez, ads, verificado%) — tablas ad_aggregates_1h/1d
- [x] Índices (compuesto + BRIN) validados con EXPLAIN — Index Scan 0.25ms con agg1h_cell_idx
- [x] API analítica (Fastify, apps/api, puerto 3008): `GET /analysis/summary`, `/method/:m`, `/heatmap`, `/spread`
- [x] Purga raw > 60d (job drop_chunks) + retención agregados eterna

**DONE when**
- [x] `EXPLAIN` muestra Index Scan en consultas de la matriz — Index Scan agg1h_cell_idx, 0.246ms
- [x] API responde < 300ms — todos los endpoints < 40ms con data real
- [x] Agregados diarios cerrados sin huecos (job verificado) — backfill OK, horas completas cubiertas, jobs programados

### FASE 3 — Dashboard (4 días)
**Objetivo**: ver el mercado en 2 segundos.

**Entregables**
- [x] Layout dashboard: selector mercado/lado/rango/tiempo — apps/dashboard (React+Vite, puerto 5174, proxy /api→3008)
- [x] Heatmap (tiles: tamaño=liquidez, color=spread) — views/Heatmap.tsx
- [x] Curva yield (X=método, Y=precio, líneas Compra/Venta) — views/YieldCurve.tsx
- [x] Multi-timeframe (filas=método, cols=1m/15m/1h/1d/1s/1M, dots) — views/Timeframes.tsx (filas=método × horas, máximo 48 cols)
- [x] Screener (columnas configurables, orden por columna) — views/Screener.tsx
- [x] Detalle por método (gráfico por hora, ranking de ads) — views/MethodDetail.tsx + endpoint /api/analysis/ads

**DONE when**
- [x] Todas las vistas renderizan con datos reales — 6 vistas implementadas, endpoints 200 con data real vía proxy
- [x] Timeframe switch funciona sin recargar (TanStack Query) — selectores país/lado/rango con queryKey, refetch automático cada 60s
- [x] Uso en físico (Yizuz): 3 vistas útiles confirmadas — Yizuz revisó en físico y validó; pidió verificar PagoMovil VES (capturado en BUY, sin ads en SELL — ausencia real de mercado)

### FASE 4 — Decision Engine (4 días)
**Objetivo**: recomendaciones + alertas basadas en reglas.

**Entregables**
- [x] Perfil de merchant (estrategia: be_leader/follow_pack/fortress + margen min)
- [x] Motor de reglas: subir/bajar/esperar/activar/pausar/cambiar método/rango/horario
- [x] Spread guard (pausar si spread < margen mínimo 3 lecturas)
- [x] Anti-oscilación (no contradecir recomendaciones en bucle)
- [x] Circuit breaker (pausar ante datos anómalos)
- [x] Alertas: subida/caída brusca, grandes comerciantes, spread extremo

**DONE when**
- [x] 5 escenarios de reglas probados con datos históricos
- [x] No hay ciclos de recomendación contradictoria en 1h de simulación
- [x] Alertas emiten evento real (Socket.IO interno)

### FASE 5 — Prediction Engine (5-7 días)
**Objetivo**: anticipar con estadística.

**Entregables**
- [ ] Distribución por hora (mejor/peor horario comprar y vender)
- [ ] Medias móviles + percentiles por método/monto
- [ ] Probabilidad de venta en próxima hora (rotación histórica)
- [ ] Spread esperado por hora/día
- [ ] Señal VES de macro-riesgo (expansión monetaria, gap con tasa oficial)
- [ ] Comparación modelo vs realidad (backtest simple)

**DONE when**
- [ ] Predicciones de horario con backtest ≥ 60% acierto vs realidad
- [ ] Dashboard muestra "mejor horario hoy" por método

## 8. Contrato de API de salida (diseñado, para el gestor futuro)

```
GET /v1/market/summary            → estado general mercado (COP/VES)
GET /v1/market/:fiat/method/:m    → métricas por método
GET /v1/market/:fiat/amount/:r    → métricas por rango de monto
GET /v1/analysis/best-time        → mejor horario comprar/vender
GET /v1/analysis/spread           → spread por método/hora
GET /v1/analysis/persistence      → Índice de Persistencia
GET /v1/recommendations           → recomendación actual del Decision Engine
GET /v1/alerts                    → alertas activas
Auth: `Authorization: Bearer <api_key>` · Rate limit por key
```

## 9. Checklist de chequeo por sesión
Antes de dar una fase por completa, verificar:
- [ ] ¿Contrastado contra el plan? (¿qué fase toca?)
- [ ] `tsc --noEmit` sin errores
- [ ] Tests relevantes pasan
- [ ] No rompimos una regla fija (sección 2)
- [ ] Datos reales verificados (no mocks)
- [ ] Vault actualizado con decisiones nuevas

## 10. Log de decisiones (append-only)
- 31 Jul 2026 · v1 · Plan maestro creado
- 31 Jul 2026 · V2 decisiones: ads promocionados fuera, montos como dimensión, estilo TradingView
- 31 Jul 2026 · v1 · Fase 0 arrancada y completada (funcional). Datos reales COP/BUY fluyendo.
  - Schema Zod ajustado a la estructura REAL del endpoint v2 (`availableAmount`→`tradableQuantity`/`surplusAmount`, `averagePayTime`→`activeTimeInSecond`, userNo 33 chars)
  - ad_snapshots sin PK (requisito TimescaleDB hypertable: índices únicos deben incluir columna de partición)
  - `merchant_user_no` varchar(64) (userNo real mide 33 chars, no 32)
  - Puertos: DB 5433, Redis 6379, /health 3007
  - Worker en tmux `pmie-worker` · Stack: pnpm+Turborepo+Fastify+pino+Drizzle+TimescaleDB
- 31 Jul 2026 · v1 · Fase 1 completada (funcional). 4 mercados + diff + persistencia.
  - Loop multi-mercado secuencial (W1-W4), 60 ads/mercado (rows=20 × 3 páginas)
  - packages/diff lógica pura (7 tests), persist.ts: ad_state upsert (onConflictDoUpdate) + ad_events
  - `disappeared` = salió del top visible escaneado (rotación del top es la señal, no retiro confirmado)
  - /health/stats con adState + events · /health/persistence por método
  - Data real: 303 ads únicos, ~5.6k snapshots, 1.5k eventos, persistencia media ~2 min en COP
- 31 Jul 2026 · v1 · Fase 2 completada (Analytics Engine). Agregados + API analítica.
  - Tablas ad_aggregates_1h/1d (hypertables sobre bucket_time) + índices únicos por celda
  - price_top1 = mejor precio del lado (BUY→min, SELL→max) · price_top5 = percentil p10/p90 (zona competitiva)
  - spread NO se almacena: se deriva en la API cruzando BUY/SELL por método/hora (mejor compra − mejor venta); spread negativo = oportunidad de arbitraje (visto en Bancolombia COP)
  - Agregación SQL idempotente (ON CONFLICT DO UPDATE) + backfill 24h al arrancar (evita huecos tras reinicios)
  - Jobs: cerrar hora cada 15min, cerrar día cada 6h, purga raw >60d diaria (drop_chunks); agregados eternos
  - API en apps/api puerto 3008 (Fastify): /api/analysis/{summary,method/:m,heatmap,spread} + /api/health; tiempos 0.2-40ms
  - EXPLAIN validado: Index Scan agg1h_cell_idx (0.246ms) en consultas de la matriz
  - Tests API 4/4 (tsx --test) · typecheck worker+api OK
- 31 Jul 2026 · v1 · Fase 3 completada (Dashboard). 6 vistas + selectores globales.
  - apps/dashboard (React 19 + Vite 6 + TanStack Query + recharts), puerto 5174, proxy /api → 3008
  - Vistas: Resumen (cards+top métodos), Heatmap (método×monto, tamaño=liquidez, color=spread), Curva (Compra/Venta por método), Timeframes (método×hora), Screener (ordenable), Método (gráfico + ads vivos)
  - Endpoint nuevo /api/analysis/ads (ad_state, últimos 15 min, orden por precio según lado) para ranking de ads
  - parseRange acepta `hours=N` relativo (además de from/to ISO) — el front envía hours
  - Timeframe switch sin recargar: queryKey reactiva en TanStack Query, refetch 60s
  - Pendiente: confirmación visual de Yizuz (DONE when #3)
- 31 Jul 2026 · v1 · Auditoría F0-F3 + cierre de gaps (revisión Yizuz).
  - BRIN snap_brin_time_idx sobre seen_at (pages_per_range=32) aplicado en bootstrap
  - ad_events: retención corregida a 6 meses (raw sigue 60d)
  - Rotación (appeared+disappeared) como métrica de celda: columna rotation en ad_aggregates_1h/1d, calculada desde ad_events (propagada por método/hora — eventos sin amount_bucket)
  - Persistencia en vivo por método: avg(lastSeen-firstSeen) min → /api/analysis/method/:m (live.persistence_min, active_ads)
  - Endpoint /api/analysis/series con granularidad 1m/15m/1h desde snapshots (date_bin)
  - MethodDetail: selector de granularidad (1m/15m/1h) + cards de persistencia/rotación/ads activos
  - apps/web (directorio huérfano vacío) eliminado
  - Métodos VES descubiertos de data real añadidos al plan: BancoDelTesoro, Bancaribe, R4
  - F0 DONE when "1h sin baneo" cumplido: successRate24h 99.6%, 284 scans
  - PagoMovil VES: presente en BUY (61 ads, 5 celdas, rotación 465), sin ads en SELL — ausencia real de mercado, no bug
- _(aquí se anota cada cambio futuro con fecha)_

## 11. Decisiones abiertas
- [ ] Dónde correrá 24/7 (VPS propio vs mismo de NYTRIX)
- [ ] Nombre definitivo del repo/módulo
- [ ] API keys: quién las genera y gestión
- [ ] Umbral de discordancia para detectar ads promocionados (default 0.3%?)
- [ ] Profundidad de páginas por mercado (default 1-3)

## Relacionados
- [[pmie|Hub PMIE]]
- [[../../raw/binance-p2p-endpoints-research|Endpoints Binance]]
- [[../../raw/binance-p2p-strategies-research|Strategies Research]]
- [[nytrix|NYTRIX]]
