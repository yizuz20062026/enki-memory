# Workflow de Sesión

> Ciclo de consolidación basado en patrón **Karpathy LLM Wiki** (Ingest / Query / Lint).
> Ruta completa de mejora: [[wiki/proyectos/roadmap-obsidian-ia|Roadmap Obsidian + IA]].

## Al INICIAR sesión
1. Leer `~/enki-memory/AGENTS.md` (si no está en contexto)
2. Leer `~/enki-memory/wiki/_INDEX.md`
3. Leer cápsulas relevantes al proyecto del día
4. Verificar sesiones pendientes en `sessions/`
5. **Consultar `lessons/ + LESSONS.md`** del proyecto → no repetir errores ya documentados

## Durante la sesión
- Seguir workflow de 10 pasos para cada tarea
- Usar skills apropiadas según el dominio
- Guardar hallazgos en `raw/` si son nuevos (datos crudos, sin sintetizar)
- Documentar errores en la plantilla `templates/lesson.md` en el MOMENTO (no al final)

## Al CERRAR sesión (ciclo de consolidación)
1. **Handoff**: actualizar `sessions/YYYY-MM-DD-tema.md` con plantilla `templates/sesion.md`
2. **Ingest**: sintetizar `raw/` nuevos → `wiki/` (entidades/conceptos interconectados)
3. **Query**: archivar respuestas valiosas de la sesión como nuevas páginas wiki
4. **Actualizar** `_INDEX.md` si hay notas nuevas (o confiar en vista Dataview)
5. **Cápsulas**: actualizar `capsules/` si hubo cambios importantes en un proyecto
6. **Lint**: correr `_tools/lint.sh` → corregir links rotos/sin wikilinks
7. **Dedup/contradicciones**: revisar si algo duplica o contradice notas existentes
8. **Push a GitHub** si hay cambios en vault

## Wikilinks
- [[ADR-002-memoria-agente]]
- [[workflow-auditoria]]
- [[wiki/proyectos/roadmap-obsidian-ia|Roadmap Obsidian + IA]]
