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

## Invalidadas
(_Ninguna aún_)
