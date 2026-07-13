# ADR-002: Sistema de memoria del agente

**Status**: aceptado
**Fecha**: 2026-07-12
**Creado por**: Enki + Yizuz

## Contexto
El agente necesita memoria persistente entre sesiones que sea portable, versionable y extensible.

## Problema
Cómo almacenar conocimiento acumulado sin depender de un servicio externo y manteniendo portabilidad.

## Alternativas
### A: Obsidian vault + filesystem (seleccionado)
- Pros: Portátil (archivos .md), versionable (Git), visible en Obsidian, sin dependencias
- Contras: Sin semantic search nativo

### B: Neo4j knowledge graph
- Pros: Relaciones ricas, traversal eficiente
- Contras: Servidor pesado, no portátil, overkill para 2 personas

### C: Vector DB (LanceDB/Qdrant)
- Pros: Semantic search, embeddings
- Contras: Infraestructura extra, embedding generation

## Decisión
Vault Obsidian en `~/enki-memory/` con MCPVault para acceso MCP. Patrón LLM Wiki.

## Razón
Portable, zero-dependency, Git-versible, compatible con Obsidian como GUI. MCPVault agrega acceso programático sin perder simplicidad.

## Impacto
- Vault: ~/enki-memory/ con estructura wiki
- MCP: MCPVault (filesystem MCP server)
- Sync: Syncthing entre dispositivos + GitHub backup
- AGENTS.md: Punto de entrada al iniciar sesión

## Wikilinks
- [[memoria-obsidian]]
- [[enki-portable]]
