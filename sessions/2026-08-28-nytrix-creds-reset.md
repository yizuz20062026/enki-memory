---
fecha: 2026-08-28
tipo: handoff
proyecto: nytrix
---
# Sesión 28 Ago 2026 — Reset de credenciales + limpieza DBs

## Contexto
Yizuz no podía entrar con `admin@nytrix.io / Admin123!` (inválida). Al investigar se descubrió:
- Los usuarios **SÍ existen** en la DB real (`data/nytrix.db`).
- Las passwords documentadas eran erróneas para el admin.

## Diagnóstico
- 4 archivos `.db` en el repo (residuos de evolución):
  - `data/nytrix.db` (1.1MB) — ÚNICA real y activa (via `DATABASE_URL`)
  - `db.sqlite3`, `src/database/nytrix.db`, `data/database.sqlite` — todas 0 bytes (fantasma)
- Los hashes reales en DB (cost 10) NO coincidían con `Admin123!` ni `admin123`. El admin fue creado por un seed local cuya password nunca se documentó.

## Acciones ejecutadas
1. Backup DB → `backend/data/nytrix.db.bak-20260828-163549`
2. Reset passwords:
   - **Staff** `admin@nytrix.io` → `admin123` (la del seeder oficial)
   - **App** `yizuz@nytrix.io` → `Admin123!`
3. Eliminadas las 3 DBs fantasma (todas vacías).
4. **Login verificado por API**:
   - Admin login → token superadmin ✅
   - App login → "Login exitoso" ✅

## Segunda parte — UX de login (28 Ago)
- **Problema**: el panel admin tenía credenciales precargadas (`AdminLogin.jsx`): email `admin@nytrix.io` + password `Admin123!`. Eso causaba "credenciales inválidas" porque la password real es `admin123` (minúsculas). El login de la app (Login.jsx) ya estaba vacío.
- **Decisión de Yizuz**: NADA debe ir precargado a menos que él fije un "recordar". Con copiar/pegar debe poder entrar.
- **Fix**: `frontend/src/admin/AdminLogin.jsx:7-8` — email y password ahora inician vacíos (`useState('')`).
- **2FA**: desactivado por defecto en Staff (`twoFactorEnabled=0` en admin y enki) y se mantiene así. No era el bloqueo.
- **Regla establecida**: los formularios de login nunca deben precargar credenciales reales.

## Credenciales finales
| Cuenta | Email | Password | Login |
|--------|-------|----------|-------|
| Admin Staff | admin@nytrix.io | admin123 | ✅ |
| App | yizuz@nytrix.io | Admin123! | ✅ |
| Staff | enki@nytrix.io | (propia) | — |

## Lección
- Nunca dejar DBs `.db` huérfanas en el repo → confunden qué fuente está viva.
- Documentar SIEMPRE la password real usada (de seed) tras crearla, y verificarla contra la DB, no contra lo que "creemos" que pusimos.
- Única fuente de verdad DB: `backend/data/nytrix.db` definida en `.env` `DATABASE_URL`.
