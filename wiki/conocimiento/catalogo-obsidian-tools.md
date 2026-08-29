# Catálogo Plugins & Herramientas Open Source (Obsidian + Conocimiento)

> Catálogo accionable de herramientas open source investigadas (29 Ago 2026). Ver también [[estrategia-conocimiento-obsidian]] para la estrategia completa.

## Plugins Obsidian (todos open source, Community Plugins)
| Nombre | Repo / Autor | Para qué sirve | Estado |
|--------|--------------|----------------|--------|
| Dataview | blacksmithgu | Query del vault como DB (DQL) | Activo |
| Templater | SilentVoid13 | Plantillas con JS/variables | Activo |
| QuickAdd | chhoumann | Captura rápida con macros + plantillas | Activo |
| Omnisearch | scambier | Búsqueda full-text avanzada | Activo |
| Linter | platers | Formateo/limpieza markdown automático | Activo |
| Excalidraw | zsviczian | Dibujo/diagramas/tableros | Activo |
| Tasks | obsidian-tasks-group | Gestión de tareas en todo el vault | Activo |
| Periodic Notes | liamcain | Notas diarias/semanales/mensuales | Activo |
| Calendar | liamcain | Navegación de daily notes por calendario | Activo |
| obsidian-git | Vinzent03 | Versionado + backup Git del vault | Activo |
| Folder Note | lostpaul | Notas por carpeta | Activo |
| Metadata Menu | mdelobelle | Gestión de metadata con menús | Activo |

## Plugins IA / LLM
| Nombre | Repo / Autor | Nota clave |
|--------|--------------|-----------|
| **obsidian-llm-wiki** | green-dalii | LLM Wiki 1-clic: entidades, conceptos, PPR graph retrieval. Zero deps, 12+ providers, local-first. EL más alineado |
| **obsidian-llm-wiki-local** | kytmanov | LLM Wiki 100% local con Ollama, CLI `olw`, file watcher, multi-lang |
| obsidian-llm-hub | takeshy | Chat multi-provider + workflow builder + RAG + MCP + agent skills |
| obsidian-local-llm-hub | takeshy | Versión local (Ollama/LM Studio/vLLM) del anterior |
| Smart Connections | brianpetro | Embeddings locales, notas relacionadas |
| Smart Composer | glowingjade | Escritura tipo Cursor con contexto del vault |
| Copilot for Obsidian | logancyang | Chat con el vault, maduro |
| Text Generator | nhaouari | Generación con plantillas + frontmatter |
| Lumina | lumina-apps | Todo-en-uno: RAG + MCP + agentes autónomos |
| HangarX | 3-Elements-Design | Grafo de conocimiento + MCP para agentes (Claude/Cursor/opencode) |

## Plugins Karpathy LLM Wiki (implementaciones del patrón)
| Repo | Tipo | Notas |
|------|------|-------|
| green-dalii/obsidian-llm-wiki | Plugin Obsidian | 1-clic, UI nativa, Graph View integrado (recomendado) |
| clonn/obsidian_plugin_LLM-Wiki | Plugin + Python CLI | Raw→wiki, herramientas uv, Claude Code |
| kytmanov/obsidian-llm-wiki-local | CLI (Ollama) | 100% local, `olw watch`, revisiones con feedback |
| AgriciDaniel/claude-obsidian | Agent Skills (Claude) | 14k stars, 15 skills, ciclo retain/ground/connect/use |
| ScrapingArt/Karpathy-LLM-Wiki-Stack | Referencia build | Guía completa + hot.md, index.md, overview.md |

## MCP Servers para Obsidian (conexión directa agentes)
| Repo | Aporta | Transporte |
|------|--------|-----------|
| **honam867/obsidian-memory-layer-mcp** | Memoria persistente: session_start/end, memory_save/recall, project_status | stdio |
| igorilic/obsidian-mcp | CRUD, búsqueda, TODO, backlinks, session reports | stdio + HTTP |
| maxkuminov/obsidian-mcp | Server real: semántica + wikilink graph, OAuth, admin UI | HTTP |
| neverprepared/mcp-obsidian-second-brain | Vault PARA + memoria semántica (FTS5+vector) | stdio |
| MaybeLOL/memory-mcp-server | Captura live cada 5 prompts + recall semántico (Voyage+LanceDB) | stdio |

## Herramientas knowledge management fuera de Obsidian
| Herramienta | Licencia | Para qué |
|-------------|----------|----------|
| qmd (tobi) | open | Buscador local markdown BM25/vector, MCP + CLI. Recomendado por Karpathy para escalar |
| stoa-wiki/stoa | Apache-2.0 | Grafo + wiki citado, MCP, exporta a Obsidian (OKF) |
| Knowledge Loom | AGPL-3.0 | Second brain + FSRS spaced repetition (flashcards/quizzes) |
| BerryBrain | source-available | Grafo + RAG + insights, autopilot, gaps de conocimiento |
| KnoArbor | MIT | Wiki local trazable desde docs/conversaciones |
| CortexGraph | MIT | Memoria temporal con curva Ebbinghaus + agentes consolidación, MCP |
| brainstack | MIT | Second brain para Hermes Agent: 14 skills, ciclo nocturno dream |
| Project Nexus | MIT | Knowledge tracker BYOK, spaced repetition SuperMemo-2 |
| Wellspring / SiYuan | specific | PKM self-hosted con spaced repetition, OCR, PDF |

## Proveedores LLM soportados (para plugins)
Obsidian-LLM-Wiki soporta: Anthropic, OpenAI, Bedrock, Gemini, DeepSeek, Kimi, GLM, MiniMax, **Ollama**, LM Studio, OpenRouter, Codex OAuth.
obsidian-llm-wiki-local soporta: **Ollama** (default), Groq, LM Studio, vLLM, Azure, OpenRouter, DeepSeek, xAI.

> Nota: Ya usamos Groq y DeepSeek en nuestro stack → compatibles sin costo extra en la mayoría.

---

## Docs relacionados
- [[estrategia-conocimiento-obsidian]] · [[obsidian-mcp]] · [[ciberseguridad]]
