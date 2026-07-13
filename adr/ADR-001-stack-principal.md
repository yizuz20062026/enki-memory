# ADR-001: Stack tecnológico principal

**Status**: aceptado
**Fecha**: 2026-05-23
**Creado por**: Enki + Yizuz

## Contexto
Se necesita definir el stack tecnológico para todos los proyectos del estudio.

## Problema
Elegir tecnologías que maximicen productividad, mantengan consistencia y permitan iteración rápida.

## Alternativas
### A: Next.js + Expo + Electron
- Pros: Web, móvil, desktop con un solo lenguaje (TypeScript)
- Consas: Aprendizaje de 3 frameworks

### B: Solo web (Next.js)
- Pros: Simple, un solo deployment
- Contras: Sin app móvil nativa ni desktop

### C: Stack separado por plataforma
- Pros: Lo mejor para cada plataforma
- Contras: Mantenimiento 3x, sin code sharing

## Decisión
Next.js 16 (web/API) + Expo (móvil) + Electron (desktop)

## Razón
TypeScript compartido, React como base, ecosistema robusto. El estudio se beneficia de un solo lenguaje para todo.

## Impacto
- Backend: Next.js 16 API Routes + better-sqlite3
- Frontend Web: Next.js 16 App Router
- Móvil: Expo SDK 56
- Desktop: Electron 35+
- DB: SQLite (dev) → PostgreSQL (prod)

## Wikilinks
- [[nextjs16]]
- [[react-native-expo]]
- [[electron]]
