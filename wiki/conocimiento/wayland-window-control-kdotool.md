---
etiquetas:
  - wayland
  - kde
  - kdotool
  - ventanas
  - automation
fecha_actualizacion: 2026-08-29
proyecto: infra
---
# Control de Ventanas Wayland — kdotool

## Contexto
En el ThinkCentre (KWin Wayland, KDE Plasma 6) `xdotool`/`wmctrl` NO funcionan sobre ventanas Wayland. Para automatizar el control de ventanas se usa **kdotool** (clon de xdotool para KDE Wayland).

## Instalación (AUR, 29 Ago 2026)
- Paquete: `kdotool` v0.2.3-1 (AUR) → instalado con `paru -S --noconfirm kdotool`
- Binario: `/usr/bin/kdotool` (se compila con cargo al instalar)
- Dependencias: dbus, glibc, libgcc (runtime) · cargo (build)

## Uso (sintaxis encadenada)
Los comandos se **encadenan en una sola invocación**. `%1` = primer resultado del query de búsqueda anterior.

```bash
# Activar/traer al frente una ventana por su clase
kdotool search --class obsidian windowactivate %1

# Traer al frente y maximizar
kdotool search --class obsidian windowactivate %1 windowstate --add MAXIMIZED %1

# Cerrar
kdotool search --class obsidian windowclose %1

# Ver ventana activa (esa misma sintaxis de query)
kdotool getactivewindow getwindowname

# Ver nombre de ventana del stack
kdotool search --class obsidian getwindowname %1
```

## Comandos de acción principales
- `windowactivate [WINDOW]` — activa y trae al frente (cambia de escritorio si hace falta)
- `windowraise [WINDOW]` — solo subir en el stack (KDE 6)
- `windowminimize` / `windowclose` / `windowmove` / `windowsize` / `windowstate`
- `windowstate --add MAXIMIZED` — maximizar (combina MAXIMIZED_HORZ/MAXIMIZED_VERT)

## Errores comunes
- ❌ `Unknown command: {id...}` — kdotool NO acepta `{id}` como primer arg suelto; usar `%1` (resultado del query previo) en la misma invocación.
- ❌ `activatewindow` no existe → el comando es `windowactivate`.
- `kdotool help` / `kdotool --help` → muestran error; usar `kdotool` solo para ver el usage, o `kdotool search --help` no funciona → leer el usage completo de `kdotool`.

## Notas
- La búsqueda por defecto usa `--title --class --classname --role` (cualquiera = OR). Con `-a` exiges todas, con `-p PID` filtras por proceso.
- También permite registrar atajos de teclado globales (`--shortcut`), aún no usado.

## Docs relacionados
- [[escritorio-remoto-windows]] · [[thinkcentre]] · [[obsidian-mcp]]
