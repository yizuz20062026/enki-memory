# Titan Mode API — Capsule

> Rutas, DB, features. Contexto rápido para trabajar.

## Stack
Next.js 16 (backend) + Expo SDK 56 (frontend) | SQLite + better-sqlite3 | Puerto 3005

## API Routes
| Ruta | Método | Descripción |
|------|--------|-------------|
| /api/routines | GET/POST | Rutinas del usuario |
| /api/routines/log | POST | Log de rutina completada |
| /api/clients | GET/POST | Clientes (si aplica) |
| /api/finance | GET/POST | Datos financieros |
| /api/health | GET | Health check |
| /api/health/settings | GET/PUT | Configuración de salud |
| /api/focus | GET/POST | Modo focus |
| /api/agenda | GET/POST | Agenda/daily |

## DB
- SQLite con better-sqlite3
- WAL mode activado
- serverExternalPackages en next.config.ts
- Backup automático cada 24h, rotación 14

## Features Implementadas
- IA Mentor con tool calling (parcial)
- Modo Fin de Semana (weekend_mode)
- Biblioteca de Rutinas/Hábitos
- Modo Offline (NetInfo + AsyncStorage cache)
- Reporte semanal con IA (Groq)
- Safe Area en 17 pantallas

## Pendientes
1. IA Mentor: tool calling no ejecuta realmente
2. Railway deploy
3. Migrar middleware → proxy.ts
4. Splash screen JS
5. Build 9 en físico

## Ver También
- [[../wiki/proyectos/titan-mode|Titan Mode]] — hub completo
