---
tags:
  - research
  - adb
  - pooling
  - python
created: 2026-07-17
type: raw
---
# ADB Connection Pooling — Research (17 Jul 2026)

## Problema Actual
Cada llamada ADB en `bot.py` spawnea un subprocess:
```python
def adb(self, *args):
    r = subprocess.run([self._adb_path] + list(args), capture_output=True, text=True, timeout=30)
```
- 1 bot = 30-60 subprocesses por flow bancario
- 40 bots = 1200-2400 subprocesses concurrentes
- Overhead: fork + exec + ADB protocol negotiation por cada llamada

## Solución: ppadb (Pure Python ADB)

### ppadb (original)
- `pip install pure-python-adb`
- Comunicación directa con ADB server via TCP socket
- Soporta: devices(), shell(), forward(), pull/push(), install/uninstall(), screencap()
- Requiere: ADB server corriendo (no lo reemplaza)

### ppadb-reborn (maintained fork)
- `pip install ppadb-reborn`
- Python 3.12+ compatible
- Índica funcionalidad, mejor mantenimiento

### AgentBox SDK Pattern
- Connection pooling para ADB connections
- Persistent TCP connections a Android sandboxes
- Reduce connection overhead significativamente

## Cómo funciona ppadb
```
Python bot → ppadb socket → ADB server (TCP 5037) → USB → Phone
```
vs actual:
```
Python bot → subprocess("adb shell ...") → fork+exec → ADB CLI → USB → Phone
```

### Ventajas
- **Sin subprocess overhead**: conexión TCP persistente
- **Connection reuse**: un socket por device, no uno por comando
- **Async compatible**: ppadb funciona con asyncio via run_in_executor
- **Control total**: forward, shell, screencap, push/pull

## Pool Pattern Recomendado
```python
class ADBPool:
    def __init__(self):
        self.client = AdbClient(host='127.0.0.1', port=5037)
        self.devices = {}  # serial -> Device
    
    def get_device(self, serial):
        if serial not in self.devices:
            self.devices[serial] = self.client.device(serial)
        return self.devices[serial]
    
    def screencap(self, serial):
        device = self.get_device(serial)
        return device.screencap()  # Returns PNG bytes directly
    
    def shell(self, serial, command):
        device = self.get_device(serial)
        return device.shell(command)
```

## Impacto Estimado
| Métrica | Antes (subprocess) | Después (ppadb pool) |
|---------|-------------------|---------------------|
| Latencia por comando | 50-200ms (fork+exec) | 5-20ms (socket write) |
| RAM por connection | ~5MB (proceso OS) | ~1KB (socket) |
| 40 bots subprocesses | 1200-2400 concurrentes | 40 sockets persistentes |
| CPU overhead | Alto (context switching) | Bajo (I/O only) |

## Limitaciones
- ADB server sigue siendo single-process
- USB bandwidth compartido entre todos los devices
- Phone farm box con USB hub: ADB server ve todos los devices
- Si ADB server crashean, todos los bots pierden conexión

## Fuentes
- github.com/Swind/pure-python-adb (602 stars)
- pypi.org/project/pure-python-adb-reborn
- deepwiki.com/agentbox-cloud/agentbox/12.3-connection-pooling
