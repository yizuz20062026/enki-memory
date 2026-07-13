# SQLite + better-sqlite3

> Patrones y reglas para SQLite en los proyectos.

## Configuración
- WAL mode: `PRAGMA journal_mode=WAL`
- better-sqlite3 es síncrono
- Next.js 16: `serverExternalPackages: ['better-sqlite3']`

## Reglas
1. Prepared statements siempre
2. Transacciones para multi-tabla
3. Backups periódicos con checkpoint WAL

## Ver También
- [[../proyectos/titan-mode\|Titan Mode]] — uso principal
- [[../proyectos/nytrix\|NYTRIX]] — fallback alongside PostgreSQL
