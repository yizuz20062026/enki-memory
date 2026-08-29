---
tags:
  - research
  - binance
  - p2p
  - strategies
  - merchants
created: 2026-07-31
type: raw
status: synthesized
---
# P2P Merchant Strategies & Market Analysis — Research (31 Jul 2026)

> Cómo los merchants de Binance P2P (y sus herramientas de automatización) analizan el mercado. Para PMIE.

## Veredicto WebSocket
**NO existe WebSocket público para Binance P2P.** Los streams WS (`stream.binance.com`) son SOLO para spot/futures. Todos los agregadores profesionales (P2P Companion, P2P.Army, OpenRate, pilotbot, AutoP2P) usan **polling REST**. Nuestro diseño con jitter 30-60s es el estándar de la industria. El "tiempo real" en P2P se logra con polling agresivo, no WS.

## Estrategias de pricing (fuente: pilotbot, AutoP2P)
| Estrategia | Qué hace | Cuándo |
|-----------|----------|--------|
| `be_leader` | Poner mejor precio, ser #1 en página | Merchant nuevo, construir volumen |
| `follow_pack` | Seguir precio promedio, no al mejor | Merchant establecido, flujo constante |
| `fortress` | Precio fijo, solo ajusta si competencia se mueve >X% | Alta reputación, posición estable |
| `humanize` | Evitar patrones bot-detectables | Entornos que vigilan bots |
| **Spread guard** | Pausar si spread < margen mínimo (>3 lecturas seguidas) | SIEMPRE como capa de seguridad |

**Corrección clave para PMIE**: el motor de recomendaciones NO debe recomendar "siempre ser #1". `be_leader` es caro (margen mínimo). `fortress` + spread guard es más rentable para un merchant establecido. El recomendador debe saber qué tipo de merchant es Yizuz.

## Motor de decisión 12-fase (AutoP2P)
Fases secuenciales por ciclo de repricing:
1. Identificación de competidores activos
2. Análisis de profundidad del order book
3. Posición ponderada por volumen (volume-weighted position scoring)
4. Detección de tendencia (subiendo/bajando)
5. Enforcement de rango de seguridad
6. Validación de scheduler
7. Filtro de competidores (ignorar merchants malos)
8. Optimización de spread
9. Anti-oscilación (evitar repricing en loop)
10. Resolución de conflicto multi-anuncio
11. Circuit breaker
12. Chequeo final de límites de precio

**Qué tomar**: fases 2, 3, 4, 8, 9, 11 son directamente implementables en nuestro Decision Engine.
**Qué corregir**: las fases asumen acceso a la API autenticada del merchant (SAPI). PMIE es read-only público. Nuestras recomendaciones se basan en el order book público (estado del mercado), no en el estado del ad del cliente.

## Índices de mercado observados
### Activity 24H (P2P.Army)
`Activity = nº de ads + nº de cambios de volumen por método`
- 1 ad con volumen cambiado 5 veces = 6 puntos
- Sirve para rankear demanda de métodos de pago
- **Nuestro Índice de Persistencia es el complemento inverso**: un ad que persiste mucho = poca rotación; desaparece rápido = alta rotación.

### Volumen real del mercado (P2P.Army, datos públicos)
- ~45,768 ads totales en Binance P2P (todos los mercados)
- ~2.4M de cambios de volumen en 24h = ~27 cambios/segundo en toda la plataforma
- Confirma: los datos cambian rápido, necesitamos snapshots frecuentes + agregados.

### Ad Bidding (nuevo, Binance 2025)
- Merchants verificados pueden PUJAR por posición en la lista
- Los ads con bid más alto aparecen arriba
- **Implicación**: la "posición #1" ya no es solo por precio — hay ads pagados por visibilidad. El motor de recomendaciones debe distinguir entre ads con bid (imposibles de superar por precio) y ads normales.

## Señales de predicción de precio P2P (lo que realmente funciona)
1. **P2P vs Spot gap**: si P2P COP está 0.5% por encima del spot, presión bajista esperable (arbitraje).
2. **Spread P2P (buy-sell)**: spread comprimido = mercado eficiente/competido. Spread amplio = oportunidad.
3. **Spread por método de pago**: métodos premium (pago móvil) = mayor spread que bancos. Dato accionable.
4. **Tendencia del reference rate**: Binance actualiza reference price (endpoint quote-price). Desviación del P2P respecto al reference = presión.
5. **Oferta visible**: surgeAmount / tradableQuantity total por mercado = liquidez. Bajada de liquidez = probable subida de precio.
6. **Rotación (nuestro Índice de Persistencia)**: ads que rotan rápido en un método = demanda real.
7. **Eventos macro VES**: en junio 2026 el bolívar cayó 16% vs USDT en 30 días por expansión monetaria. El precio VES P2P es muy sensible a noticias monetarias. **Cuidado**: las predicciones para VES deben incluir señal de macro-riesgo (exceso de liquidez, tasa oficial vs P2P), no solo histórico.

## Modelos ML observados
- LSTM/Keras para series de precios spot (kiddojazz, kaushik-yadav) — mediocre para P2P por ruido humano.
- **Recomendación PMIE**: NO empezar con ML. Comenzar con estadística (percentiles, medias móviles, distribución por hora) + reglas. ML solo cuando haya 30-90 días de datos y con features del order book (no solo precio).

## Implicaciones de diseño finales
1. Polling REST + jitter es el estándar. WS no aplica.
2. Motor de recomendaciones = reglas con estados de mercado, no solo precio.
3. Distinguir ads con bid pagado vs normales.
4. Índice de Persistencia + Activity = par de métricas complementarias.
5. VES necesita señal macro-extra.
6. Features de predicción: spread, liquidez visible, rotación, reference gap, método.

## ACTUALIZACIÓN 31 Jul 2026 — Anuncios promocionados (decisión de Yizuz)
- **DECISIÓN**: los ads con bid promocionado se EXCLUYEN de la data de PMIE. No cuentan para recomendaciones.
- **Problema**: el endpoint público NO expone flag de promoción (verificado en vivo, 60+ campos, ninguno de bid).
- **Solución heurística**: detección de discordancia posición-precio. Un ad promocionado tiene precio PEOR que la posición que ocupa (el bid lo sostiene arriba).
  - Regla: si un ad está en posición top N y su precio es peor que los N+1, N+2... siguientes → marca `probable_promoted` → excluir del cálculo de "precio para ser #1".
  - Configurable por umbral de discordancia.
- **Nota**: apip2p.top usa "auto bidding" con polling 3s y 20 threads para mantener #1 — confirma que el bidding real existe y no es raro. El filtro heurístico es necesario.

## Vista visual tipo TradingView yield-curve (requisito Yizuz)
- Referencia: es.tradingview.com/markets/bonds/yield-curve-all
- **Adaptación**: X = método de pago, Y = precio/spread %, series = Compra/Venta/Top1/Top5.
- Selector temporal: 15m, 1h, 6h, 24h, 7d, 30d, 90d + granularidad (min/hora/día/semana/mes).
- Heatmap en tabla: filas = métodos, col = hora/día, color = spread/liquidez/actividad.
- Selector de país/mercado arriba (COP/VES), toggle heatmap, tabla de datos abajo.
- Stack: recharts (LineChart + puntos + RangePicker) — consistente con ecosistema.

## Filtro por MONTOS (dimensión crítica) — validado en vivo 31 Jul 2026
**El `transAmount` del endpoint funciona y cambia el mercado radicalmente**:
| transAmount (COP) | total ads | interpretación |
|---|---|---|
| 50 (~$0.01) | **0** | sin mercado |
| 1.000 | **0** | sin mercado |
| 20.000 (~$5) | 58 | mercado pequeño |
| 200.000 (~$50) | 189 | mercado medio — mayoría |
| sin filtro | 268 | todo |

**OPTIMIZACIÓN CLAVE**: NO escanear cada rango por separado (multiplicaría peticiones ×5). 
Cada ad ya trae `minSingleTransAmount`/`maxSingleTransAmount` → **clasificar localmente por rango** desde 1 scan sin filtro. El filtro solo se usa para validación puntual.
- Buckets de monto (COP/VES→USDT): 0-50, 50-100, 100-300, 300-500, 500-1000, 1000-5000, 5000+
- Un ad califica al bucket M si su rango [min,max] incluye M.
- Precio/liquidez/competencia por bucket = mercado realmente ejecutable para ese tamaño.

## Organización de datos tipo TradingView (hallazgos aplicados)
TradingView usa 3 herramientas que replicamos:
1. **Heatmap**: cell size = importancia (volumen/liquidez), cell color = performance (cambio %). Agrupado por sector. Click → detalle.
2. **Screener**: tabla densa, columnas configurables, filtros combinables, orden por columna.
3. **Multi-timeframe dashboard**: filas = símbolos, cols = timeframes, dots verdes/rojos por condición, scoring agregado.

**Adaptación PMIE**:
- Heatmap: tiles = métodos de pago, size = liquidez USDT total, color = spread o cambio %. Grupo = familia (bancos tradicionales / neobancos / wallets).
- Screener: filas = métodos (o ads), cols = top1 precio, spread, ads, liquidez, persistencia, rotación, cambio 1h/24h.
- Multi-timeframe: filas = métodos, cols = 1m/15m/1h/1d/1s/1M con dots por condición (precio subiendo, spread amplio, liquidez alta).
- Curva yield: X = método, Y = precio/spread, series compra/venta.

## "No perder ningún dato" — retención total
- Guardar el **payload JSON completo** de cada ad en la snapshot (`raw_json` columna), no solo campos extraídos. Si Binance agrega campo, ya lo tenemos.
- Normalizar para consultas, pero conservar el original intacto.
