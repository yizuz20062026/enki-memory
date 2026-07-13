# Stack Next.js 16

> Por qué elegimos Next.js 16 y qué cambia.

## Versión: 16.2.4 (Mayo 2026)

## Cambios Principales
1. Turbopack default (12x cold start, 13x HMR)
2. middleware.ts → proxy.ts (BREAKING)
3. Async Request APIs (params, searchParams, cookies)
4. Cache Components con `"use cache"`
5. React 19.2 + React Compiler stable
6. PPR por defecto
7. `after()` para tareas post-response

## Errores Conocidos
| Error | Fix |
|-------|-----|
| `params` sync | `await params` |
| `cookies()` sync | `await cookies()` |
| better-sqlite3 import | `serverExternalPackages` en config |
| images.domains | Usar `remotePatterns` |

## Ver También
- [[../decisiones/stack-nextjs16\|Decisión: Stack Next.js 16]]
- [[../proyectos/titan-mode\|Titan Mode]] — lo usa
- [[../proyectos/alterego-home\|Alterego Home]] — lo usa
