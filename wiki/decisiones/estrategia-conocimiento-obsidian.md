# Estrategia de Conocimiento — Obsidian + IA (Investigación 29 Ago 2026)

> Investigación profunda sobre cómo aprovechar al máximo el vault de conocimiento para potenciar a Enki y al estudio. Sintetizado de fuentes open source del ecosistema Obsidian/LLM-Wiki.

---

## 1. Diagnóstico del estado actual

- **Vault**: `~/enki-memory/` — 62 notas, 16 carpetas, ~155KB.
- **Estructura existente**: `adr/`, `capsules/`, `lessons/`, `raw/`, `sessions/`, `wiki/`, `workflows/`, `templates/`, `prompts/`.
- **Sin plugins de comunidad instalados** — solo core plugins.
- **Fortaleza**: la estructura ya sigue el patrón "LLM Wiki" (raw/ → wiki/ → AGENTS.md como schema), aunque sin automatizar.
- **Oportunidad**: el conocimiento está bien organizado pero es **estático** — se guarda pero no se consolida ni se reutiliza activamente entre sesiones.

## 2. El patrón clave: Karpathy LLM Wiki

**Fuente**: [gist karpathy/442a6bf](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)

La idea central: en vez de buscar en documentos crudos en cada consulta (RAG), el **LLM compila y mantiene un wiki persistente** — archivos markdown interconectados que crecen entre el agente y las fuentes.

**3 capas con dueño estricto:**
| Capa | Ubicación | Dueño | Qué contiene |
|------|-----------|-------|--------------|
| L1 Fuentes | `raw/` | Humano (escritura) / yo (lectura) | Artículos, papers, PDFs, transcripciones |
| L2 Wiki | `wiki/` | LLM (yo) | Resúmenes, entidades, conceptos, cruces, síntesis |
| L3 Schema | `AGENTS.md` | Humano + LLM (co-evolución) | Reglas, convenciones, workflows |

**3 operaciones:**
- **Ingest**: leer fuente, extraer, actualizar páginas conectadas (una fuente toca 10-15 páginas).
- **Query**: preguntar, responder con citas, y **archivar respuestas valiosas como nuevas páginas**.
- **Lint**: escanear duplicados, enlaces rotos, huérfanos, contradicciones → loop a Compile.

**Frase clave de Karpathy**: "Obsidian es el IDE; el LLM es el programador; el wiki es el codebase."

## 3. Plugin stack recomendado (todos open source)

### A. Búsqueda, datos y plantillas (base)
| Plugin | Función | Prioridad |
|--------|---------|-----------|
| **Dataview** | Query del vault como DB (DQL) sobre frontmatter | ⭐ Alta |
| **Templater** | Plantillas con JS, variables dinámicas | ⭐ Alta |
| **QuickAdd** | Captura rápida con macros a carpeta+plantilla | ⭐ Alta |
| **Omnisearch** | Búsqueda full-text avanzada | Alta |
| **Linter** | Formateo/limpieza automática de markdown | Media |

### B. IA / LLM dentro de Obsidian
| Plugin | Función | Nota |
|--------|---------|------|
| **obsidian-llm-wiki** (green-dalii) | LLM Wiki en un clic: entidades, conceptos, PPR graph retrieval | ⭐ El más alineado con nuestro patrón. Zero dependencias, 12+ providers |
| **obsidian-llm-hub** (takeshy) | Chat multi-provider + workflow builder + RAG local + MCP | Open source, muy completo |
| **Smart Connections** (petro) | Embeddings locales, notas relacionadas semánticas | Sin API key, gratuito |
| **HangarX** (3-Elements) | Grafo de conocimiento + MCP para agentes | Comparte memoria entre Claude/Cursor/opencode |
| **Local LLM Hub** (takeshy) | Todo local vía Ollama/LM Studio | Privacidad total |

### C. Rituales de aprendizaje de errores (crítico para "aprender de errores")
| Mecanismo | Qué hace |
|-----------|----------|
| **Lessons/LESSONS.md** (¡ya existe!) | Registro de errores → evitar repetirlos |
| **brainstack** (criptogus) | Ciclo nocturno "dream": dedupe, backlinks, contradicciones, prioridades del día | 
| **CortexGraph** (prefrontal-systems) | Memoria temporal con curva de olvido Ebbinghaus + agentes de consolidación |
| **obsidian-memory-layer-mcp** (honam867) | Guarda decisiones/learnings/sesiones como markdown; session_start carga contexto |

## 4. MCP servers open source para Obsidian (lo que nos conecta DIRECTAMENTE)

Ya usamos **MCPVault** (filesystem). Otras opciones para potenciar a Enki:

| Repo | Qué aporta |
|------|-----------|
| **honam867/obsidian-memory-layer-mcp** | Memoria persistente para opencode/Claude/Cursor: `session_start`, `memory_save`, `memory_recall` |
| **igorilic/obsidian-mcp** | CRUD notas, búsqueda, TODO, backlinks, session reports |
| **maxkuminov/obsidian-mcp** | Server real con Postgres+vector: semántica + wikilink graph, OAuth |
| **neverprepared/mcp-obsidian-second-brain** | Vault PARA (Projects/Areas/Resources/Archives) + memoria semántica |

## 5. Herramientas open source complementarias (fuera de Obsidian)

| Herramienta | Tipo | Para qué |
|-------------|------|----------|
| **qmd** (tobi) | Buscador local markdown | Hybrid BM25/vector + MCP/Llama, recomendado por Karpathy para escalar wiki |
| **Stoa** | Knowledge graph + wiki citado | Entity-resolved, MCP integrado, exportable a Obsidian (OKF) |
| **Knowledge Loom** | Second brain con FSRS spaced repetition | Convertir notas en flashcards/quizzes |
| **BerryBrain** | Grafo + RAG + insights | Autopilot de conocimiento, gaps de conocimiento |
| **KnoArbor** | Wiki local con trazas | Compila docs/conversaciones en wiki consultable |
| **obsidian-git** | Versionado + backup | Git para el vault — historia y rollback gratis |

## 6. Recomendaciones priorizadas para Enki + Yizuz

### Fase 1 (rápido, alto impacto) — esta semana
1. **Instalar plugins**: Dataview, Templater, QuickAdd, Linter, Omnisearch.
2. **Adoptar operación de reflexión**: al cerrar sesión, ejecutar el ciclo "dream/consolidación" manual: dedup, backlinks, contradicciones, prioridades — aprovechando que ya guardamos sessions/.
3. **Reforzar LESSONS.md por proyecto** — cada error documentado con su causa raíz (ya lo hacemos en memory blocks; pasarlo a vault).

### Fase 2 (medio plazo) — próximo mes
4. **Implementar LLM Wiki real**: los `raw/` ya existen; hacer el paso de compilación a `wiki/` con páginas de entidades/conceptos interconectadas. Opción: plugin `obsidian-llm-wiki` o pipeline CLI (kytmanov/obsidian-llm-wiki-local usa Ollama, gratuito y local).
5. **Integrar obsidian-memory-layer-mcp** como MCP adicional para Enki: carga contexto de proyecto automáticamente al iniciar, guarda learnings/errores reutilizables.
6. **Git para el vault** (obsidian-git o git crudo): versionado + rollback + sincronización GitHub.

### Fase 3 (avanzado)
7. **Búsqueda semántica** qmd cuando el vault crezca >200 notas.
8. **CortexGraph / spaced repetition** si queremos retención activa del conocimiento.
9. Alinear el vault con el patrón 00-inbox → 10-raw → 20-wiki para captura de fuentes web (Web Clipper).

## 7. Métricas de éxito
- % de sesiones que reutilizan conocimiento previo (no empezar de cero).
- Número de errores no repetidos (LESSONS consultado antes de re-debuggear).
- Consolidación semanal real (dedup + contradicciones).
- Crecimiento del wiki compilado (páginas interconectadas), no solo sessions/.

---

## Docs relacionados
- [[obsidian-mcp]] · [[adr-system]] · [[workflow-sesion]] · [[memory-obsidian]]
