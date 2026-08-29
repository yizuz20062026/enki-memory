---
etiquetas:
  - remoto
  - rdp
  - windows
  - tails
fecha_actualizacion: 2026-08-28
proyecto: infra
---
# Escritorio Remoto — PC Windows (N7VIMVR)

## Trigger
Cuando Yizuz diga **"abre el escritorio del pc"** (o `winen`) → abrir el escritorio de Windows vía RDP en la pantalla del ThinkCentre:
```bash
DISPLAY=:1 nohup xfreerdp3 /v:100.125.98.111 /u:usuario /p:12345 /cert:ignore /dynamic-resolution /f &
```

## Máquina remota
- Hostname Tailscale: `desktop-n7vimvr` · IP Tailscale: `100.125.98.111`
- Windows 11 Pro · placa `9051-900-0025` · CPU AMD Zen 4
- Usuario: `usuario` / pass: `12345` (pendiente de cambiar)
- NOTA: Yizuz la llama "thinkcentre" aunque es distinta de miarch (Arch).

## Comandos locales (miarch)
- `winen` (escritorio completo), `winsh` (terminal), `winfiles` (monta C: en ~/win), `winumount`

## Reglas duras
- Usar **`xfreerdp3`** (binario real en Arch; `xfreerdp` no existe).
- SMB requiere `LocalAccountTokenFilterPolicy=1` ya aplicado en el Windows.
- Autostart remoto: tarea `EnkiRuntime` (ONSTART) en MÁQUINA Windows mantiene Tailscale+RDP+no-sleep al encender.

## Docs relacionados
- [[sessions/2026-08-28-wsl-fix-rdp]] · [[travel-home]]
