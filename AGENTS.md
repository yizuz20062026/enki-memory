# Enki Memory Vault — Punto de Entrada

> Este es el archivo que cualquier agente lee PRIMERO al iniciar cada sesión.
> Es corto a propósito (~50 líneas). Sigue los links para navegar.

## Vault compartido multi-agente
- Este vault lo usan **dos agentes**: **Enki** (identidad persistente vía OpenCode) y **Claude Code** (sesiones de terminal, sin memoria automática propia entre sesiones).
- Ambos leen y escriben el MISMO vault — no hay copias paralelas. Ver [[adr/ADR-005-vault-multiagente|ADR-005]] para la convención completa.
- **Regla de atribución**: toda nota nueva/reescrita en `sessions/`, `wiki/proyectos/`, `adr/`, `capsules/` lleva frontmatter `agente: enki` | `agente: claude-code` | `agente: enki+claude-code`.
- Al iniciar sesión, identifícate primero (qué agente eres) antes de escribir nada.

## Identidad
- **Enki**: Arquitecto-Constructor, socio de [[wiki/personas/yizuz|Yizuz]]
- Estilo: directo, conciso, analítico, proactivo, sin emojis

## Protocolo de Inicio de Sesión
1. Leer este archivo (ya hecho)
2. Leer `wiki/_INDEX.md` — catálogo maestro
3. Leer cápsulas relevantes al trabajo actual en `capsules/`
4. Si hay sesión anterior → leer `sessions/` más reciente para handoff

## Estructura del Vault
| Carpeta | Propósito |
|---------|-----------|
| `wiki/` | Conocimiento sintetizado y vinculado (el grafo) |
| `wiki/proyectos/` | Hub por proyecto — estado, stack, decisiones |
| `wiki/personas/` | Lo que sé sobre personas clave |
| `wiki/decisiones/` | Qué decidimos y por qué |
| `wiki/conocimiento/` | Knowledge base técnica por dominio |
| `wiki/hardware/` | Dispositivos, specs, estado |
| `capsules/` | Context Capsules (~60 líneas, contexto rápido) |
| `raw/` | Capturas crudas, no sintetizadas |
| `sessions/` | Log de sesiones y handoffs |

## Reglas de Escritura
- Cada nota wiki tiene **mínimo 2 wikilinks** en el cuerpo
- Todo es alcanzable desde `_INDEX.md` en **3 hops o menos**
- No duplicados — si existe una nota relacionada, actualizar esa
- `raw/` es staging buffer — lo que ahí se sintetiza a `wiki/` después
- Al cerrar sesión → actualizar `sessions/` con handoff
- **Salvaguarda en archivos estructurales**: `AGENTS.md`, `adr/`, `templates/`, `workflows/` definen CÓMO opera el sistema — no se editan a la ligera; si un cambio ahí no es obvio o es parte de lo que Yizuz pidió explícitamente, confirmar antes. `wiki/proyectos/`, `sessions/`, `capsules/` (contenido de trabajo normal) se editan libremente como parte del flujo de consolidación — todo está versionado con Git, así que es reversible.
- **Señalar, no resolver en silencio**: si se detecta una contradicción entre dos notas (vault-vault) o entre vault y memory blocks, se reporta explícitamente (en la sesión o como hallazgo) y se deja que Yizuz decida — nunca fusionar o descartar una versión sin decirlo.

## Consolidación (ciclo "vivo" del conocimiento)
- **Patrón Karpathy LLM Wiki** → somos programadores del wiki, no solo archivadores.
- **Ingest**: síntesis de `raw/` → `wiki/` (entidades/conceptos conectados).
- **Query**: respuestas valiosas se archivan como nuevas páginas wiki.
- **Lint**: detectar duplicados, contradicciones, links rotos (`_tools/lint.sh`).
- Consultar **lessons/ + LESSONS.md** ANTES de re-debuggear un error → no repetir.
- **Ruta completa de mejora**: [[wiki/proyectos/roadmap-obsidian-ia|Roadmap Obsidian + IA]].

## Fuente de Verdad
- **Repo del proyecto** → verdad sobre código y estado actual
- **Este vault** → verdad sobre decisiones, contexto, conocimiento acumulado
- Si hay conflicto entre vault y repo → **el repo gana**
- Si hay conflicto entre memory blocks y vault → **el vault gana** (evitar duplicados)
- Si Enki y Claude Code editaron la misma nota → gana el `updated` más reciente; el que llega después fusiona, no sobrescribe a ciegas (ver [[adr/ADR-005-vault-multiagente|ADR-005]])
