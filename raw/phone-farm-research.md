---
tags:
  - research
  - phone-farm
  - hardware
created: 2026-07-17
type: raw
---
# Phone Farm Hardware — Research (17 Jul 2026)

## Phone Farm Box: Qué es
Chasis industrial que aloja múltiples smartphones/motherboards con USB hub integrado, power delivery, Ethernet y mounting para disipación térmica.

## Límites de Hardware

### USB Controllers
- Consumer boards: cap ~30-45 phones (firmware/chipset limits)
- Server-grade boards (X79+): escalan mejor, más root host controllers
- **Límite real raro el OS — es el controller + board design**

### Topología Recomendada
| Vector | Recomendación | Notas |
|--------|--------------|-------|
| Hub tiers | ≤3 tiers deep | Too many cascades = timeouts |
| Hub choice | 7-10 port powered hubs | Separate PSU per hub bank |
| Cables | Short, shielded | Reemplazar cables flojos temprano |
| Ports | Rear I/O first | Front headers share paths |
| USB version | USB2 paths para phones | Reservar USB3 para storage |

### BIOS Settings (para máximo devices)
- **Disable XHCI** (USB3 controller)
- **Enable EHCI** (USB2 host paths)
- Esto fuerza paths estables que enumeran más dispositivos

### Power
- 200W 5V 40A adapter recomendado para 20 dispositivos
- Per-port power switching en hubs industriales

### Cooling
- Dual-fan systems, thermal throttling para farms grandes
- Room temp < 24°C (75°F)
- Overheating = primary cause of device failure

## Phone Farm Boxes en el Mercado

### Modelos Populares
- **S8+ 20-Node Cluster**: Para 20 dispositivos
- **N5+ Starter**: Entry level
- **20-port USB motherboard farm box**: Con OTG + Ethernet (estándar para 10-50 devices)

### Características Clave
- USB 3.0 hosts discretos per 8-10 ports
- Per-port power switching
- Firmware transparency (custom ROM, kernel sources)
- ADB persistence (reconocimiento estable durante sesiones largas)
- Dual-fan cooling

### Software de Gestión
- **GenFarmer**: Device tracking, automation, analytics
- **Xiaowei**: Real-time monitoring, process automation
- **Panda**: Mirror management, 40 phones free (Windows)
- **QtScrcpy**: Open source, Windows/Linux/Mac

## Costos Estimados (10-40 devices)
- Used Android phones: $30-60/device (Samsung Galaxy S7+)
- Industrial USB hub: $50-150
- Phone rack/chassis: $50-200
- Dedicated router: $100-300
- Cooling: $50-100
- Host computer: varies
- **Total hardware 20 devices: ~$1,000-2,500 upfront + $300-600/month operating**

## Anti-Detection (relevante para bancos)
- Dynamic device ID/IMEI modification
- Randomized task delays
- Unique SIM cards / IP rotation
- Custom ROMs with kernel patches
- Per-device proxy management

## Fuentes
- phonefarm.tech
- tikmatrix.com/blog/usb-phone-farm-limits
- accio.com/box-phone-farm-system
- conbersa.ai/how-to-build-a-phone-farm
- phonefarm.online/blog/scaling-beyond-100-devices
