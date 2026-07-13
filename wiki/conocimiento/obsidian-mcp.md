# Obsidian MCP — Integración Enki ↔ Vault

## Qué es
MCPVault permite a Enki leer y escribir en el vault Obsidian via Model Context Protocol (MCP), sin depender de que Obsidian esté abierto.

## Instalación
```bash
# En opencode.json, agregar:
"mcp": {
  "obsidian": {
    "type": "local",
    "command": ["npx", "@bitbonsai/mcpvault@latest", "/home/tu_usuario/enki-memory"],
    "enabled": true
  }
}
```

## Herramientas MCP disponibles
- `list_notes` — listar notas del vault
- `read_note` — leer contenido de una nota
- `write_note` — crear o sobrescribir nota
- `search_notes` — buscar por contenido (BM25)
- `delete_note` — eliminar nota
- `move_note` — mover/renombrar nota
- `list_folders` — listar carpetas
- `create_folder` — crear carpeta

## Ventajas sobre filesystem directo
- Search BM25 integrado
- Estructura de carpetas como API
- Compatible con Obsidian GUI (mismo vault)
- Sin plugin requerido

## Regla de uso
- **Leer vault** al inicio de cada sesión
- **Escribir** solo conocimiento nuevo o actualizado
- **NUNCA** borrar sin confirmar
- Usar wikilinks en todas las notas

## Wikilinks
- [[memoria-obsidian]]
- [[ADR-002-memoria-agente]]
