---
fecha: 2026-08-28
tipo: session
maquina: desktop-n7vimvr
tags:
  - wsl
  - bios
  - rdp
  - tailscale
  - remoto
---
# Sesión 28 Ago 2026 — Fix WSL + Acceso Remoto a PC Windows

## Contexto
Yizuz reportó que en su PC Windows ("thinkcentre" para él, hostname tailscale **desktop-n7vimvr**, 100.125.98.111) no abría la terminal de Linux (WSL).

## Diagnóstico
- WSL y VirtualMachinePlatform = **Enabled**, CPU AMD Zen 4 soporta virtualización.
- **Causa raíz**: `Se habilitó la virtualización en el firmware: NO` → SVM (AMD-V) apagada en BIOS.
- Error de WSL: `HCS_E_HYPERV_NOT_INSTALLED`.

## Fix
1. Yizuz activó **SVM Mode = Enabled** en la BIOS (AMI, tecla Supr/F2, Advanced → CPU Configuration).
2. WSL2 vuelve a arrancar. ✅

## Setup Acceso Remoto (para viaje)
- **Autostart**: tarea programada `EnkiRuntime` (ONSTART, SYSTEM) → `C:\scripts\enki-runtime.cmd` → `enki-runtime.ps1`. Verifica Tailscale + RDP + no-sleep al encender. Log en `C:\scripts\enki-runtime.log`.
- **RDP habilitado**: `reg add HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server /v fDenyTSConnections /t REG_DWORD /d 0 /f` + servicio TermService AUTO + firewall enable.
- **No-sleep**: `powercfg /change standby-timeout-ac 0`, `hibernate-timeout-ac 0`, monitor 30 min.
- Cliente en miarch: `xfreerdp3` (freerdp 3.27.1; el alias `xfreerdp` NO existe en Arch — usar `xfreerdp3`).
- Script de conexión: `~/scripts/conectar-windows.sh` (pide password, fullscreen, /cert:ignore, /dynamic-resolution). OK tras fix de binario.

## Comandos de acceso (aliases en ~/.zshrc y ~/.bashrc)
- `winen` → `~/scripts/conectar-windows.sh` → `xfreerdp3 /v:100.125.98.111 /u:usuario /p:<pass> /cert:ignore /dynamic-resolution /f` (escritorio completo).
- `winsh` → `sshpass -p '12345' ssh usuario@100.125.98.111` (terminal).
- `winfiles` → monta `//100.125.98.111/C$` en `~/win` con `credentials=/root/.smbcreds-windows,domain=DESKTOP-N7VIMVR,sec=ntlmssp,vers=3.0`. 
- `winumount` → `sudo umount ~/win`.
- Todos probados OK 28 Ago 2026. Para abrirla directamente en pantalla: `DISPLAY=:1 nohup xfreerdp3 /v:100.125.98.111 /u:usuario /p:12345 /cert:ignore /dynamic-resolution /f &`.
- SMB: requiere `LocalAccountTokenFilterPolicy=1` (ya aplicado) en HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System.

## Pendiente
- Cambiar password `12345` lo antes posible (seguridad) y actualizar script/creds.
- Confirmar acceso RDP/SSH/SMB durante viaje (distancia real, LTE).
- Decidir si sincronizar el vault `~/enki-memory` por Syncthing (hoy solo memory blocks).
- Anotar que "thinkcentre" para Yizuz = desktop-n7vimvr (Windows), distinto de miarch (Arch).

## Docs relacionados
- [[nytrix]] · [[travel-home]]
