# ADR System

## Qué es
Architecture Decision Records (ADRs) son documentos que capturan decisiones arquitectónicas importantes del proyecto.

## Dónde
- ADRs: `~/enki-memory/adr/`
- Formato: MADR (Markdown Any Decision Records)
- Plantilla: ver `~/enki-memory/adr/README.md`

## Cuándo crear un ADR
- Cambio de framework/librería principal
- Decisión de arquitectura (monorepo vs polyrepo, DB choice, etc.)
- Regla de seguridad nueva
- Cambio de patrón de diseño
- Cualquier decisión que queramos recordar en 6 meses

## Flujo
1. Detectar decisión significativa
2. Crear `ADR-NNN-nombre.md` en `adr/`
3. Documentar: contexto, alternativas, decisión, razón
4. Agregar wikilinks a notas relacionadas
5. Actualizar `_INDEX.md` si es necesario

## Convenciones
- Numeración secuencial desde ADR-001
- Nunca borrar ADRs — marcar como `obsoleto` si aplica
- Status: `aceptado` | `obsoleto` | `reemplazado por ADR-XXX`

## Wikilinks
- [[workflow-sesion]]
- [[memoria-obsidian]]
