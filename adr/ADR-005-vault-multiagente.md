---
carpeta: adr
fecha: 2026-09-10
proyecto: enki-memory
tipo: adr
tags:
  - adr
  - multi-agente
status: aceptado
created: 2026-09-10 00:00
updated: 2026-09-10 00:00
---

# ADR-005: Vault compartido multi-agente (Enki + Claude Code)

- **Estado**: Aceptado
- **Fecha**: 2026-09-10
- **Decisores**: Yizuz, Enki, Claude Code

## Contexto y problema
Yizuz trabaja con dos agentes distintos sobre el mismo trabajo: **Enki** (identidad persistente vía OpenCode, memoria propia en `~/.config/opencode/memory/`) y **Claude Code** (sesiones de terminal, sin memoria automática entre sesiones salvo su propio sistema de memoria en `~/.claude/`). Ambos necesitan operar sobre los mismos proyectos (NYTRIX, PMIE, Titan Mode, etc.) sin duplicar ni contradecir conocimiento, y sin que quede ambiguo qué agente hizo qué cambio.

## Drivers de decisión
- Evitar una segunda fuente de verdad paralela (regla ya fijada: "si hay conflicto entre memory blocks y vault → el vault gana").
- Poder distinguir, al leer una nota o un commit, si el cambio vino de Enki o de Claude Code — sin necesitar preguntar.
- No romper la estructura ya existente del vault (wiki/, sessions/, adr/, capsules/, templates/).
- Bajo costo de mantenimiento: la convención debe ser fácil de seguir en cada sesión, de cualquiera de los dos agentes.

## Opciones consideradas
- **Opción A**: Campo `agente` en el frontmatter (sessions, proyectos, ADRs) + trailer `Co-Authored-By` en commits de Claude Code.
- **Opción B**: Vaults separados por agente, sincronizados después. Descartada: reintroduce el problema de duplicación que motivó ADR-002.
- **Opción C**: Solo usar `git blame`/autor de commit para atribuir, sin tocar frontmatter. Descartada: no cubre ediciones no commiteadas todavía ni da contexto rápido al leer una nota suelta en Obsidian.

## Decisión
Elegimos **Opción A**: `~/enki-memory` sigue siendo el único vault (ninguno nuevo), y se añade una convención ligera de atribución:

1. **Frontmatter**: toda nota nueva o reescrita en `sessions/`, `wiki/proyectos/`, `adr/` y `capsules/` incluye el campo `agente:` con uno de estos valores:
   - `enki` — trabajado desde OpenCode/Enki.
   - `claude-code` — trabajado desde una sesión de Claude Code.
   - `enki+claude-code` — sesión conjunta o traspaso entre ambos.
2. **Sesiones (`sessions/*.md`)**: cada archivo de sesión ya es 1:1 con una sesión de trabajo, así que el campo `agente` en su frontmatter basta — no hace falta separar carpetas.
3. **Notas hub de proyecto (`wiki/proyectos/*.md`)**: se sobrescriben con el estado más reciente (no son append-only), así que el campo `agente` + `updated` en el frontmatter indica quién tocó la nota por última vez. El detalle de qué cambió específicamente vive en la sesión correspondiente (wikilink).
4. **ADRs y decisiones**: campo `Decisores` ya existente se usa también para indicar qué agente participó (ej. "Yizuz, Claude Code").
5. **Commits al repo del vault**: Claude Code no cambia la configuración git global (sigue firmando como `Yizuz` por defecto), pero añade el trailer `Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>` en el mensaje de commit cuando el cambio se originó en una sesión de Claude Code. Enki puede seguir usando su propio git author (`Enki <enki@opencode.ai>`) cuando aplique.
6. **Regla de conflicto sin cambios**: vault > memory blocks; repo de código > vault. Se añade: **si ambos agentes editaron la misma nota en la misma ventana de tiempo, gana la versión con `updated` más reciente, y el agente que llega después debe fusionar (no sobrescribir a ciegas) usando el wikilink a la sesión anterior.**

## Consecuencias
- **Positivas**: trazabilidad de quién escribió qué sin overhead de infraestructura nueva; compatible con Dataview (se puede filtrar por `agente` en `_INDEX.md`); no rompe nada de lo ya construido en FASE 0-1 del roadmap Obsidian+IA.
- **Negativas / trade-offs**: requiere disciplina de ambos agentes para no olvidar el campo; no resuelve merges automáticos si dos agentes editan la misma nota en paralelo en tiempo real (poco probable dado que Yizuz opera con uno a la vez).

## Alternativas descartadas y por qué
- Vaults separados (Opción B): reintroduce duplicación, exactamente lo que ADR-002 buscaba evitar.
- Solo git blame (Opción C): insuficiente para lectura humana rápida dentro de Obsidian sin abrir terminal.

## Wikilinks
- [[ADR-002-memoria-agente]] · [[../wiki/decisiones/memoria-obsidian|Memoria Obsidian]] · [[../workflows/workflow-sesion|Workflow de Sesión]]
