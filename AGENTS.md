# Enki Memory Vault — Punto de Entrada

> Este es el archivo que Enki lee PRIMERO al iniciar cada sesión.
> Es corto a propósito (~50 líneas). Sigue los links para navegar.

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

## Fuente de Verdad
- **Repo del proyecto** → verdad sobre código y estado actual
- **Este vault** → verdad sobre decisiones, contexto, conocimiento acumulado
- Si hay conflicto entre vault y repo → **el repo gana**
