# Enki Portable — Capsule

> Servicios, puertos, dispositivos. Contexto rápido.

## Servicios
| Servicio | Puerto | Stack |
|----------|--------|-------|
| Remote Agent | 4000 | Node.js + Express |
| Web UI (Taberna) | 3445 | Node.js + Express |
| Auth | Bearer | Token: `20062026` |
| LLM | Cloud | Groq (llama-3.3-70b) + DeepSeek V4 (fallback) |

## Dispositivos
| Nombre | IP Tailscale | OS | Estado |
|--------|-------------|-----|--------|
| escritorio | 100.125.98.111 | WSL | Activo |
| thinkcentre | 100.96.174.70 | Arch Linux | Activo |
| celular | — | Termux | Pendiente |

## Memoria Compartida
- Syncthing: `~/.config/opencode/memory/` cada 60s
- 17 archivos, ~38KB
- Start: `~/.local/bin/start-syncthing.sh` (crontab @reboot)

## Scripts Clave
- `enki-status.sh` — estado servicios
- `enki-push.sh` — push GitHub + sync
- `setup-new-machine.sh` — setup nueva máquina via Tailscale
- `install-opencode.sh` — instalación ligera

## GitHub
`github.com/Yizuz20062026/enki-portable`

## Ver También
- [[../wiki/proyectos/enki-portable|Enki Portable]] — hub completo
- [[../wiki/hardware/thinkcentre|ThinkCentre]]
- [[../wiki/hardware/escritorio|Escritorio]]
