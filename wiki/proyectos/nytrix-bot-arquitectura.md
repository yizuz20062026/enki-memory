# NYTRIX Bot — Arquitectura Completa

tags: #nytrix #bot #arquitectura #adr
fecha: 2026-07-16

## Visión

NYTRIX Bot es un **operador automatizado** que reemplaza a un humano en el flujo
P2P. Se conecta a la plataforma como cualquier operador via Socket.IO, recibe
órdenes, ejecuta automatización bancaria vía ADB+OCR, y reporta resultados.

Ver documento completo en: [[proyectos/nytrix|NYTRIX]]
Archivo fuente: `~/nytrix/worker-bot/ARQUITECTURA.md`

## Componentes Clave

1. **Bot como Operador** — User con `is_bot=true`, TeamMembership, PaymentAccounts
2. **Screen Analyzer** — clasifica pantallas en ScreenState (LOGIN/PIN/HOME/ERROR)
3. **State Machine** — flujo estado-driven (no pasos fijos)
4. **Dual WS** — Socket.IO (órdenes) + /bot (streaming)
5. **Auto-claim** — matching orden→cuenta→claim

## Decisiones Arquitectónicas

- El bot NO es un worker APK — es un operador más en la plataforma
- El claim existente (`UPDATE ... WHERE claimedBy IS NULL`) es la barrera anti-doble-pago
- Cada operación bancaria se registra en AccountMovement para trazabilidad
- El admin conversa con el bot desde el chat del módulo Workers

## Próximos Pasos

1. Crear User bot + asignar cuentas
2. Conectar bot a Socket.IO
3. Pipeline claim → ejecutar → completar
4. Rediseñar frontend Workers

Relacionado: [[proyectos/nytrix|NYTRIX]], [[decisiones/bot-como-operador]]
