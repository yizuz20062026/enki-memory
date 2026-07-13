# Decisión: Memoria en Obsidian

> Fecha: 12 Julio 2026

## Qué
Vault `~/enki-memory/` como memoria persistente de largo plazo de Enki.

## Por qué
- bloques `memory_set` limitados a 5000 chars
- Se perdía info entre sesiones
- Yizuz quería poder ver/editar la memoria

## Arquitectura
- 3 zonas: raw/ → wiki/ → AGENTS.md
- Context Capsules (~60 líneas)
- Hub-first traversal
- Mínimo 2 wikilinks por nota

## Alternativas Rechazadas
- Solo memory_set: insuficiente
- RAG: similarity ≠ relevance
- SQLite: overengineering
- Basic Memory MCP: menos control

## Ver También
- [[../_INDEX\|Índice Maestro]]
