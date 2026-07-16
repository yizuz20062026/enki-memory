# Sesión 15 Jul 2026 — Arquitectura Worker Bot

## Tags: #session #nytrix #worker-bot #architecture

## Resumen
Planificación formal del sistema NYTRIX Worker Bot: OCR + ADB automation desde ThinkCentre, controlado desde NYTRIX web.

## Investigación
- **EasyOCR** con GPU > Tesseract con CPU para banking OCR (fuentes digitales, layouts complejos)
- **OpenCV template matching** complementa OCR para botones predecibles
- **ADB exec-out screencap -p** para captura — estándar, funciona en toda versión Android
- **Pattern State Machine** (ya existe BDVFlow como referencia) para flujos bancarios

## Decisiones
- Bot en Python server-side (ThinkCentre), no en APK
- Config system: WorkerConfig model con JSON schema para phone/app/creds/tasks
- OCR: EasyOCR + OpenCV template matching combinados
- Control: NYTRIX frontend ScreenTab + comandos
- Reports: resultados se guardan como ejecuciones en DB

## Próximo paso
Diseñar e implementar el sistema completo de configuración y ejecución del bot.

---

**Actualizado**: 15 Jul 2026
