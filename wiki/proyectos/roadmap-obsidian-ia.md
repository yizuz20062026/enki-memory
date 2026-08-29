# Roadmap de Implementación — Obsidian + IA (Estrategia de Conocimiento)

> **Fuente de verdad**: este documento. Define la ruta completa para actualizar el vault y potenciar el conocimiento del estudio. Cada fase tiene `DONE when` verificable. NO pasar a la siguiente sin cumplir.
> **Estrategia padre**: [[estrategia-conocimiento-obsidian]]
> **Fecha**: 29 Ago 2026 · **Estado**: En progreso

## ✅ Progreso (29 Ago 2026)
- **FASE 0** Parcial (falta: dedup entre memory blocks y vault, esquema de tags formal)
- **FASE 1** ✅ Plugins instalados (Dataview, Templater, QuickAdd, Linter, Omnisearch) — ver [[2026-08-29-roadmap-obsidian-implementacion]]
- **FASE 2** Plantillas creadas (6) — falta configurar Templater/QuickAdd en Obsidian
- **FASE 3-7** Pendiente
- **Nota**: `.obsidian` NO se versiona (gitignore), folder de plugins es local.

---

## Estado Base del Vault (diagnóstico 29 Ago 2026)
- **66 notas**, 16 carpetas, ~172KB.
- Git `master` ✅ (remote: `github.com/yizuz20062026/enki-memory`) — ya hay versionado.
- Sin plugins de comunidad instalados (solo core).
- `_tools/lint.sh` ya existe (health check del vault — links rotos, wikilinks).
- `workflows/workflow-sesion.md` ya define el flujo de inicio/cierre.
- `templates/` y `prompts/` vacíos.
- Memoria en memory blocks de Enki DESCONECTADA del vault (infos duplicadas, sin MCP de memoria).

---

## FASE 0 — Preparación y Limpieza del Vault (fundamento)
> Objetivo: base limpia y consistente antes de cualquier plugin.

- [ ] **0.1** Ejecutar `_tools/lint.sh` y corregir TODOS los links rotos y notas sin wikilinks.
- [ ] **0.2** Depurar duplicados entre `memory blocks` de Enki y vault — elegir 1 fuente de verdad por tema (regla: vault gana si hay conflicto con memory blocks; repo gana si hay conflicto con vault).
- [ ] **0.3** Decidir y documentar el **esquema de tags** del vault (ver `_tools/lint`). Crear lista maestra en `wiki/conocimiento/catalogo-obsidian-tools.md` o nota de tags.
- [ ] **0.4** Definir la **convención de frontmatter** (campos mínimos: `tags`, `created`, `updated`, `proyecto`, `tipo`).
- [ ] **0.5** Commit inicial limpio + push a GitHub (punto de restauración).

**DONE when**: lint 0 errores, sin duplicados críticos, frontmatter consistente, git limpio.

---

## FASE 1 — Plugins Core (rápido, alto impacto)
> **Nota**: requiere Yizuz habilitando "Community Plugins" en Obsidian (Settings → Community plugins → Turn on). Yo (Enki) no puedo hacer clic en la UI.

- [ ] **1.1** Yizuz: habilitar Community Plugins en Obsidian.
- [ ] **1.2** Instalar desde Community Plugins:
  - [ ] **Dataview** — query del vault como DB.
  - [ ] **Templater** — plantillas con variables/JS.
  - [ ] **QuickAdd** — captura rápida con macros.
  - [ ] **Linter** — formateo/limpieza automática.
  - [ ] **Omnisearch** — búsqueda full-text.
- [ ] **1.3** Configurar **Templater**: definir la carpeta de templates (usar `templates/`) y activar "Trigger on new file".
- [ ] **1.4** Configurar **Linter**: reglas para frontmatter (fechas `created`/`updated`), heading levels, espacios, links. Guardar reglas en `templates/linter-config.md` (backup).
- [ ] **1.5** Configurar **Dataview**: crear 2-3 vistas raíz en `_INDEX.md` (ej. "últimas sesiones", "ADR por estado", "proyectos por estado").
- [ ] **1.6** Configurar **Omnisearch**: indexar todo el vault, activar búsqueda por wikilinks.

**DONE when**: 5 plugins instalados y funcionales, `_INDEX.md` con vistas Dataview, templater crea notas con frontmatter estándar.

---

## FASE 2 — Plantillas y Automatización de Captura (consistencia)
> Objetivo: que guardar conocimiento sea barato y estandarizado.

- [ ] **2.1** Crear plantillas en `templates/` (Templater):
  - [ ] `sesion.md` — para `sessions/YYYY-MM-DD-tema.md` (frontmatter: fecha, proyecto, resumen, decisiones, enlaces).
  - [ ] `adr.md` — para `adr/` (formato MADR).
  - [ ] `lesson.md` — para `lessons/` (formato: error, causa raíz, fix, cómo evitarlo).
  - [ ] `wiki-concepto.md` — para `wiki/conocimiento/`.
  - [ ] `proyecto.md` — para `wiki/proyectos/` (estado, stack, pendientes, enlaces).
  - [ ] `capsula.md` — para `capsules/` (contexto rápido ~60 líneas).
- [ ] **2.2** Configurar **QuickAdd** con macros que apunten a plantillas + carpeta correcta (Capture → Task/Note).
- [ ] **2.3** (Opcional) **obsidian-git**: activar auto-commit/auto-push del vault (o mantener git manual — ya existe).

**DONE when**: cada carpeta tiene su plantilla, crear nota desde QuickAdd usa la plantilla correcta con frontmatter estándar.

---

## FASE 3 — Integración IA: LLM Wiki real (el núcleo)
> Objetivo: automatizar la compilación raw/ → wiki/ (patrón Karpathy: Ingest/Query/Lint).

- [ ] **3.1** Elegir implementación:
  - Opción A: plugin **obsidian-llm-wiki** (green-dalii) — UI nativa Obsidian, entidades/conceptos, PPR graph retrieval. Proveedores: Anthropic/OpenAI/Gemini/DeepSeek/Ollama (compatibles con nuestro stack).
  - Opción B: **obsidian-llm-wiki-local** (kytmanov) — 100% local con Ollama, CLI `olw watch`.
  - **Recomendación**: A (más productivo, reutiliza DeepSeek/Groq). Probar B si queremos privacidad total.
- [ ] **3.2** Instalar y configurar el elegido con nuestro provider (DeepSeek API key desde env `DEEPSEEK_API_KEY`).
- [ ] **3.3** Ejecutar **primera compilación**: migrar `raw/` existentes (6 notas) a entidades/páginas wiki conectadas.
- [ ] **3.4** Configurar **Lint automático** (Linter + revisión) del wiki compilado.
- [ ] **3.5** Establecer el **ciclo de consolidación**: al cerrar sesión (ver Fase 5) → Ingest (raw→wiki) + Query (archivar respuestas valiosas) + Lint.

**DONE when**: raw/ compilado al wiki, entidades/conceptos interconectados, ciclo de consolidación documentado y funcionando.

---

## FASE 4 — MCP servers para Enki (memoria persistente real entre agentes)
> Objetivo: conectar la memoria del agente con el vault para que "aprenda de errores" y no repita work.

- [ ] **4.1** Evaluar e instalar **honam867/obsidian-memory-layer-mcp** (memoria persistente: `session_start` carga contexto, `memory_save`/`recall` para learnings). Es el que mejor encaja con el patrón actual.
  - [ ] Verificar si es compatible con la config MCP actual de `opencode.json` (ya hay MCPVault filesystem).
  - [ ] NO duplicar: que el MCP de memoria delegue al vault en vez de crear otra capa paralela.
- [ ] **4.2** (Evaluar, si hace falta) **igorilic/obsidian-mcp** (CRUD notas, búsqueda, TODO, backlinks) o **maxkuminov/obsidian-mcp** (semántica + graph, OAuth).
- [ ] **4.3** Definir el flujo: `session_start` → cargar contexto proyecto → al terminar, `memory_save` de learnings/decisiones al vault (sessions/ + lessons/).
- [ ] **4.4** Testear: en una sesión real, que Enki recuerde errores previos (ej. alias zsh, login NYTRIX) SIN re-descubrirlos.

**DONE when**: Enki arranca sesiones con contexto del vault y guarda learnings; no repite errores documentados en LESSONS.

---

## FASE 5 — Ritual de Consolidación (habitual, lo que hace el sistema "vivo")
> Objetivo: convertir el vault en un sistema que se consolida, no solo que se llena.

- [ ] **5.1** Definir el **ciclo nocturno/semanal de consolidación** (dedup, backlinks, contradicciones, prioridades) — inspirado en brainstack/CortexGraph.
- [ ] **5.2** Actualizar `workflows/workflow-sesion.md` para que el cierre de sesión incluya:
  1. Handoff en `sessions/`.
  2. Sintetizar `raw/` → `wiki/`.
  3. Actualizar `_INDEX.md` (o vista Dataview).
  4. Actualizar cápsulas si aplica.
  5. Correr `_tools/lint.sh`.
  6. (Opcional) Push a GitHub.
- [ ] **5.3** (Opcional) Evaluar **CortexGraph** para retención activa (curva de olvido, refuerzo por uso) si el conocimiento crece >200 notas.

**DONE when**: cierre de sesión sigue el ciclo completo verificable (checklist en workflow-sesion.md).

---

## FASE 6 — Escalado y Búsqueda Semántica (cuando el vault crezca)
> Objetivo: mantener la búsqueda óptima a escala.

- [ ] **6.1** Cuando el vault pase ~200 notas: evaluar **qmd** (buscador local BM25/vector + MCP) para búsqueda semántica.
- [ ] **6.2** Evaluar **Stoa** (knowledge graph + wiki citado, exportable a Obsidian) solo si necesitamos entidades a gran escala.
- [ ] **6.3** Evaluar integración con el stack del estudio (NYTRIX/PMIE/Titan) para que el conocimiento alimente proyectos.

**DONE when**: búsqueda sigue siendo efectiva a escala; documentar decisión tomada y por qué.

---

## FASE 7 — Cierre y Verificación Global
- [ ] **7.1** `_tools/lint.sh` → 0 errores.
- [ ] **7.2** Revisar que NO haya duplicados en memory blocks vs vault.
- [ ] **7.3** Git commit + push del estado final.
- [ ] **7.4** Actualizar `sessions/` con handoff de esta implementación.
- [ ] **7.5** Actualizar memoria de Enki (memory blocks) solo con lo que NO está en vault.

**DONE when**: vault consolidado, plugins activos, MCP conectado, ciclo de consolidación rutinario, todo versionado.

---

## Matriz de Responsabilidades
| Tarea | Quién |
|-------|-------|
| Habilitar Community Plugins | Yizuz (UI) |
| Instalar plugins | Yizuz (UI) / Enki (config) |
| Crear plantillas | Enki |
| Configurar LLM Wiki | Enki + Yizuz (API key) |
| Configurar MCP servers | Enki |
| Correr lint / consolidación | Enki |
| Definir decisions (plugin vs local, MCP) | Enki recomienda, Yizuz aprueba |

## Métricas de Éxito del Programa
- [ ] Sesiones que reutilizan conocimiento previo (no partir de cero).
- [ ] Errores documentados NO repetidos (LESSONS consultado antes de re-debuggear).
- [ ] Consolidación real semanal (dedup, contradicciones).
- [ ] Crecimiento de wiki compilado (no solo sessions/).

---

## Docs relacionados
- [[estrategia-conocimiento-obsidian]] · [[catalogo-obsidian-tools]] · [[workflow-sesion]] · [[adr-system]]
