---
tags:
  - research
  - binance
  - p2p
  - endpoints
created: 2026-07-31
type: raw
status: validated-live
---
# Binance P2P Endpoints — Research Validado en Vivo (31 Jul 2026)

> Probado directamente con curl desde el entorno. Resultados reales.

## Veredicto
**Acceso anónimo a Binance P2P: CONFIRMADO.** No requiere cookies ni auth.

## Endpoint legacy — MUERTO
- `POST /bapi/c2c/v2/friendly/c2c/ad/search` → **HTTP 404**
- `POST /bapi/c2c/v2/friendly/c2c/ad/search` (www) → **404**
- El endpoint clásico de la era 2021-2023 ya no existe.

## Endpoints VIVOS (validados 2026-07-31)

### 1. `POST https://p2p.binance.com/bapi/c2c/v2/friendly/c2c/adv/search`
**HTTP 200 — sin auth.** Endpoint rico, el principal para el scanner.
Body:
```json
{"asset":"USDT","fiat":"COP","merchantCheck":false,"page":1,"rows":3,"payTypes":[],"publisherType":null,"tradeType":"BUY"}
```
Respuesta `data[]` con campo `adv`:
- `advNo` — **ID estable del anuncio** (clave para tracking de persistencia)
- `classify` (mass), `tradeType` (BUY/SELL), `asset`, `fiatUnit`
- `price`, `initAmount`, `surplusAmount`, `tradableQuantity`
- `maxSingleTransAmount`, `minSingleTransAmount`
- `payTimeLimit` (15), `tradeMethods[]`
- Advertiser: nickname, merchantId, monthOrderCount, monthFinishRate, positiveRate

### 2. `GET https://www.binance.com/bapi/c2c/v1/public/c2c/agent/ad-list`
**HTTP 200 — sin auth.** Más liviano, forma limpia.
`?fiat=COP&asset=USDT&tradeType=BUY&limit=5`
- `adNo`, `price`, `fiat`, `minTransAmount`, `maxTransAmount`, `tradableAmount`, `payTimeLimit`
- `tradeMethods[]`, `advertiser{nickName, monthOrderCount, monthFinishRate, positiveRate, merchantGroupMember}`
- `tradeType`: BUY = anuncios de SELLERS (se compra), SELL = anuncios de BUYERS. Vista del buscador.

### 3. `GET .../public/c2c/agent/quote-price`
`?fiat=COP&asset=USDT&tradeType=BUY` → precio instantáneo, para widgets/KPI rápidos.

### 4. `GET .../public/c2c/agent/trade-methods`
`?fiat=COP` → lista de métodos de pago con `identifier` (BancolombiaSA, Nequi, DaviviendaSA...).
**Nota**: `identifier` debe pasarse como string plano en `tradeMethodIdentifiers`, NO como JSON array.

## Implicaciones de diseño
1. **`advNo` elimina la necesidad de fingerprinting heurístico** — identidad de anuncio viene dada. Tracking de persistencia directo por advNo.
2. **No hay que pelear con cookies** — scanner anónimo viable para MVP.
3. **Rate limiting aún necesario** — Binance bloquea IPs por volumen. Jitter + backoff siguen vigentes.
4. Endpoint 1 (adv/search) para snapshots profundos; endpoint 2 (ad-list) para frecuencia alta y liviana.

## Notas
- `publisherType: "merchant"` es un truco no documentado que algunos mercados requieren.
- Riesgo: Binance cambia endpoints sin aviso → adapter versionado + alerta de schema drift.
