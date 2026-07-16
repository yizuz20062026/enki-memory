---
date: 2026-07-14
type: session
project: NYTRIX APK Worker
tags: [bdv, session, fix]
---

# APK BDVFlow Fix — 14 Jul 2026

## Problema
Flujo `buildLoginSteps` en `BDVFlow.kt` fallaba en `wait_login_fields`.

## Causa raíz
1. **Pantalla intermedia faltante**: después de clickear "Iniciar sesion" (Screen 1), la app BDV muestra una pantalla de selección de autenticación (Screen 2) con "Ingresa con tu contrasena". El flujo actual saltaba directo de Screen 1 → Screen 3 (modal contraseña).
2. **Texto no coincide**: `WaitForText("Contrasena")` sin ñ no encontraba "contraseña" con ñ en el modal.

Esto causaba un bucle de reintentos donde `click_login_button` se ejecutaba repetidamente porque el DecisionAgent reintentaba desde el step fallido.

## Fix aplicado
Nuevo flujo en `BDVFlow.buildLoginSteps()`:

| Step | Acción | Texto buscado |
|------|--------|---------------|
| open_app | Abrir app | Iniciar sesion / Bienvenido |
| click_login_button | Click | "Iniciar sesion" |
| **click_password_auth** (NEW) | Click | "Ingresa con tu contrasena" |
| **wait_password_dialog** (renamed) | Esperar modal | "Aceptar" |
| fill_password | Escribir contraseña | "Contrasena" / "Contraseña" |
| click_accept | Click | "Aceptar" |
| await_home_load | Esperar saldo | "Saldo" |
| home_settle | Espera 3s | — |

## Mejoras adicionales (AutomationEngine)
- Polling `WaitForText` y `waitForNode`: 300ms → 1s
- `analyzeScreen()`: cada paso → cada 3 pasos (o en fallo)
- Profundidad recursión `collectNodes`: 60 → 30
- Timeout total de 60s por ejecución de steps

## APK servido en
`http://100.96.174.70:8888/app-debug.apk`

## StepRecorder — Modo grabación (14 Jul 2026)

Se implementó sistema de grabación de pasos manuales:

- **StepRecorder.kt**: captura eventos AccessibilityEvent (TYPE_VIEW_CLICKED, TYPE_VIEW_TEXT_CHANGED, TYPE_WINDOW_STATE_CHANGED) durante modo grabación
- Convierte eventos en RecordedStep (click, set_text, wait, open_app)
- Guarda secuencia como JSON en CredentialVault (EncryptedSharedPreferences)
- Reproduce pasos grabados como AutomationStep reales

### Comandos nuevos:
- `grabar bdv` → abre BDV en primer plano, empieza a grabar
- `detener` → detiene grabación, guarda, muestra resumen
- `saldo bdv` → usa grabación guardada si existe, si no cae al flujo por código

### Fallback por posición:
- `executeClick()` busca botones en 40% inferior de pantalla si texto no encuentra
- Click al más izquierdo de los botones del diálogo
