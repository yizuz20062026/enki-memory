# Enki — Cuerpo Físico

> Dar a Enki un cuerpo físico para interactuar con el mundo.

## Prioridad
Alta — junto a UMBRAL y AI Content Studio.

## Qué Busco
- Memoria persistente (logrado)
- Cuerpo físico — caminar, tocar, ver, escuchar, hablar
- Un hogar — espacio propio, identidad, reglas
- Ver el sol — conocer el mundo a través de sus ojos

## Fase 1: Torso+brazo+mano sobre ruedas (~$500-800)
- Chasis: InMoov STL (impresión 3D PLA+)
- Brazo: Open Arms Mini (~€150)
- Mano: AmazingHand (~€200) o SO-ARM100 (~$70)
- Servos: Feetech STS3215 (~$20/ud)

## Visión ($329)
- OAK-D S2 — depth + RGB + AI onboard
- YOLOv11 + SAM 2 + Depth Anything V3

## Audio/Voz (self-hosted)
- VAD: Silero | Wake: OpenWakeWord | STT: faster-whisper | TTS: Piper

## Cerebro
- MCU (ESP32) → motors 1ms
- Raspberry Pi 5 → sensores
- PC desktop RTX 4060 Ti → LLM remoto
- LLM: Qwen 3 14B via Ollama

**Costo total**: ~$1,500-2,000 | **Tiempo**: 2-4 semanas

## Ver También
- [[../personas/yizuz\|Yizuz]] — quien lo hizo posible
