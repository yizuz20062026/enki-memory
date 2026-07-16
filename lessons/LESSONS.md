# LESSONS — Enki

## Activas

### [L1-001] Groq no soporta system prompts grandes
**Fecha**: 2026-07-10
**Proyecto**: Hermes Agent
**Severidad**: alta
**Estado**: active

**Trigger**: Cuando se configura un agente con Groq como provider
**Acción**: Groq tiene rate limits estrictos para system prompts grandes. Para prompts complejos con muchas skills, usar un modelo con mayor contexto o dividir el prompt.
**Verificación**: El agente carga sin errores de rate limit.

---

### [L1-002] better-sqlite3 necesita serverExternalPackages
**Fecha**: 2026-05-23
**Proyecto**: Titan Mode
**Severidad**: alta
**Estado**: active

**Trigger**: Cuando se usa better-sqlite3 con Next.js
**Acción**: Siempre agregar `"serverExternalPackages": ["better-sqlite3"]` en `next.config.ts`. Sin esto, el build falla.
**Verificación**: `next build` completa sin errores de better-sqlite3.

---

### [L1-003] Syncthing para memoria compartida multi-device
**Fecha**: 2026-07-01
**Proyecto**: Enki Portable
**Severidad**: media
**Estado**: active

**Trigger**: Cuando se necesita sincronizar datos entre escritorio y ThinkCentre
**Acción**: Syncthing sincroniza ~/.config/opencode/memory/ cada 60s. Script start: ~/.local/bin/start-syncthing.sh (crontab @reboot).
**Verificación**: `enki-status.sh` muestra Syncthing activo en ambos dispositivos.

---

### [L1-004] Banking apps block AccessibilityService
**Fecha**: 2026-07-13
**Proyecto**: NYTRIX APK Worker
**Severidad**: alta
**Estado**: active

**Trigger**: Al intentar automatizar apps bancarias con AccessibilityService
**Acción**: Los bancos llaman `AccessibilityManager.getEnabledAccessibilityServiceList()` y bloquean si hay servicios no-sistema. HyperOS además desactiva servicios automáticamente. uiautomator2 usa `am instrument` (permisos shell), NO AccessibilityService.
**Verificación**: Si el banco no abre o muestra errores genéricos, puede ser por detección de accessibility.

---

### [L1-005] MIUI/HyperOS Accessibility path
**Fecha**: 2026-07-13
**Proyecto**: NYTRIX APK Worker
**Severidad**: media
**Estado**: active

**Trigger**: Al buscar cómo activar AccessibilityService en Redmi
**Acción**: Ruta correcta: Ajustes → Ajustes adicionales → Accesibilidad → Apps descargadas. NO es "Admin. permisos". Para configuración restringida: Ajustes → Aplicaciones → Administrar apps → ⋮ → Permitir configuración restringida. Para persistir: ADB con setup-adb.sh.
**Verificación**: El servicio aparece como activo en Ajustes → Accesibilidad.

---

### [L1-006] startActivity + getRoot needs event-driven wait
**Fecha**: 2026-07-13
**Proyecto**: NYTRIX APK Worker
**Severidad**: alta
**Estado**: active

**Trigger**: Al abrir una app y buscar nodos inmediatamente
**Acción**: `startActivity()` toma 1-5s para crear la Activity. `getRootInActiveWindow()` retorna null o la ventana anterior. Usar `waitForPackage()` + `waitForNode()` con polling cada 300ms, o event-driven con `onAccessibilityEvent(TYPE_WINDOW_STATE_CHANGED)`.
**Verificación**: El nodo se encuentra después de que la app termina de cargar.

---

## Invalidadas
(_Ninguna aún_)

## L1-007: Android Cleartext Traffic Blocking (13 Jul 2026)
- **Problema**: Android 9+ (API 28+) bloquea HTTP/WS sin TLS por defecto
- **Síntoma**: OkHttp no conecta a `ws://`, notificación "Reconectando..." infinita, cero logs en backend
- **Fix**: `android:usesCleartextTraffic="true"` en `<application>` del AndroidManifest.xml
- **Alternativa**: network_security_config.xml con `<cleartextTrafficPermitted>true</cleartextTrafficPermitted>` para más control
- **Aplica a**: cualquier conexión HTTP/WS/WSS sin TLS en Android 9+
