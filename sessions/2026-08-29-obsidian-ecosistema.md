# Session — 29 Ago 2026 — Investigación Ecosistema Obsidian + IA

**Meta**: investigación profunda sobre cómo maximizar el aprovechamiento del vault de conocimiento para potenciar a Enki/estudio.

## Qué se investigó
- Ecosistema Obsidian: core plugins, community plugins open source, plugins IA/LLM.
- Patrón **Karpathy LLM Wiki** (raw/ → wiki/ → AGENTS.md).
- Sistemas de memoria con aprendizaje de errores (LESSONS, brainstack, CortexGraph).
- MCP servers para Obsidian que conectan agentes (honam867/memory-layer, igorilic, maxkuminov).
- Herramientas knowledge management open source (qmd, Stoa, Knowledge Loom, BerryBrain).

## Hallazgos clave
1. **Ya seguimos el patrón LLM Wiki**: la estructura actual (raw/ → wiki/ → AGENTS.md) es exactamente Karpathy. Diferencia: nos falta automatizar la compilación a wiki (no solo guardar sesiones).
2. **Obsidian está sin plugins de comunidad** — espacio de mejora inmediato.
3. **Mejor implementación LLM Wiki 1-clic**: `green-dalii/obsidian-llm-wiki` (entidades, conceptos, PPR graph retrieval, 12+ providers incl. Groq/DeepSeek/Ollama que ya usamos).
4. **obsidian-memory-layer-mcp** (honam867) — memoria persistente real para opencode: session_start carga contexto, guards learnings/errores reutilizables.
5. **Estructura actual ya es la correcta** — solo falta activar la operación de "llm-wiki compile" + plugins + Linter para normalización.

## Docs creados
- `wiki/decisiones/estrategia-conocimiento-obsidian.md` — estrategia completa + fases (1: plugins; 2: LLM Wiki real + MCP; 3: búsqueda semántica).
- `wiki/conocimiento/catalogo-obsidian-tools.md` — catálogo accionable de plugins/MCP/herramientas.
- `wiki/_INDEX.md` — actualizado con ambos.

## Próximos pasos (para Yizuz)
1. Habilitar Community Plugins en Obsidian UI (requiere clic en setup).
2. Instalar: Dataview, Templater, QuickAdd, Linter, Omnisearch.
3. Opcional: evaluar plugin `obsidian-llm-wiki` (green-dalii) con DeepSeek/Groq/Ollama.
4. Evaluar `honam867/obsidian-memory-layer-mcp` como MCP adicional para Enki.
5. Adoptar ciclo de consolidación al cerrar sesión (dedup/backlinks/contradicciones).

## Enlaces
- [[estrategia-conocimiento-obsidian]] · [[catalogo-obsidian-tools]] · [[workflow-sesion]]
