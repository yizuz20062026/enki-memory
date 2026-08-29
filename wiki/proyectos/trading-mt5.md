# Trading MT5 — Proyecto de Pruebas

## Estado: PLANIFICACIÓN (31 Jul 2026)

## Objetivo
Usar MetaTrader 5 en cuentas demo para operar, aprender el mercado con ensayo y error, y buscar un sistema de trading efectivo que se pueda monetizar. Los ingresos alimentarían los proyectos del estudio ([[umbral]], [[nytrix]], [[pmie]]).

## Contexto de origen
- Viene de la metodología usada para mapear el flujo bancario (ADB + uiautomator + scrcpy en el APK worker de [[nytrix]])
- Yizuz propuso conectar Enki a MetaTrader para operar cuentas demo
- Decisión: hacerlo desde el PC (más eficiente que el teléfono) antes que por ADB

## Decisiones tomadas
- **Plataforma**: MetaTrader 5 (MT5)
- **Ubicación**: Escritorio Windows (camino A, recomendado) — ver comparativa abajo
- **Método de ejecución**: API oficial `MetaTrader5` de Python (solo funciona en Windows, usa la DLL de la terminal)
- **Cuentas**: demo primero, ensayo y error hasta conseguir punto rentable/consistente
- **Filosofía**: llevar data real de las pruebas, medir todo, no prometer rentabilidad rápida

## Comparativa de caminos
| | A. Escritorio Windows (recomendado) | B. ThinkCentre Linux |
|---|---|---|
| Instalación | MT5 oficial + Python + lib `MetaTrader5` | MT5 + Wine + `mtapi` |
| Ejecución órdenes | API nativa, directa, milisegundos | Bridge TCP, más lento |
| Estabilidad | Alta (vía estándar de la comunidad) | Media, más piezas que romper |
| Donde vive el bot | PC fija (siempre encendida) | Equipo de viaje (se apaga) |

**Arquitectura planeada**: motor en el escritorio Windows, Enki se conecta desde ThinkCentre vía Tailscale para operar y monitorear (como NYTRIX).

## Riesgos identificados
1. **MT en Android vs banco**: el gráfico usa OpenGL, no siempre sale en dump uiautomator (irrelevante si vamos por camino A)
2. **Realismo del trading**: ~80-90% de traders retail pierde. Funciona: demo → backtest → estrategia con reglas → consistencia
3. **No prometer**: rentabilidad rápida no; sistema medible sí

## Plan por fases (propuesto)
- F0: Instalar MT5 en Windows + crear cuenta demo
- F1: Conectar API Python `MetaTrader5` y validar operación en demo
- F2: Backtest + paper trading con métricas
- F3: Operación controlada en demo, registrar data real
- F4: Iterar estrategias (ensayo y error) hasta punto consistente
- F5: Evaluar monetización

## Pendiente
- Yizuz descargar MT5 en escritorio Windows y crear cuenta demo
- Confirmar conexión Tailscale ThinkCentre ↔ escritorio
- Definir mercados/activos a probar (forex, índices, oro, cripto)
- Definir métricas de éxito de las pruebas

## Relacionado
- [[nytrix]] — metodología ADB/uiautomator, infraestructura backend
- [[pmie]] — inteligencia de mercado, precedente de análisis de datos
- [[thinkcentre]] — donde vive Enki
- [[escritorio]] — PC Windows donde correrá MT5
