# Titan Mode

> Hub del proyecto Titan Mode — app de bienestar con IA.

## Estado Actual
- **Fase**: Pre-lanzamiento, auditoría completa
- **Pendiente**: Railway deploy, migración middleware→proxy, splash screen, Build 9 en físico

## Stack
| Capa | Tecnología |
|------|-----------|
| Backend | [[../conocimiento/nextjs16\|Next.js 16]] + better-sqlite3 |
| Frontend | Expo SDK 56 (React Native) |
| API URL | `http://192.168.1.6:3005/api` |
| DB | SQLite (WAL mode) |

## Servicios
| Servicio | Puerto | Terminal |
|----------|--------|----------|
| Backend API | 3005 | tmux `titan-api` |
| Frontend Expo | 8082 | tmux `titan-expo` |

## Build Standalone
- Último build: 23 Mayo 2026
- Build ID: `85304318-d2d6-440c-b0c1-04b48c5d84c6`
- Cuenta Expo: gilaryt

## Funcionalidades Implementadas
- Safe Area Fix: 17 pantallas con `useSafeAreaInsets()`
- IA Mentor: Chat History en DB, tools
- Modo Fin de Semana, Biblioteca de Rutinas/Hábitos
- Modo Offline: NetInfo + NetworkContext
- Backup Automático: SQLite WAL checkpoint cada 24h
- Reporte con IA: Resumen semanal Groq

## Auditoría Pre-lanzamiento
- Backend: 12 issues fixeados
- Frontend: 11 issues fixeados

## GitHub
- Repo: `github.com/Yizuz20062026/titan-mode`

## Ver También
- [[../conocimiento/sqlite\|SQLite]] — DB usage
- [[../conocimiento/react-native-expo\|React Native / Expo]] — frontend
