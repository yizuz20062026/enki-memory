---
tags:
  - research
  - ocr
  - tesseract
  - easyocr
  - optimization
created: 2026-07-17
type: raw
---
# OCR Optimization — Research (17 Jul 2026)

## Problema Actual
- Cada bot carga EasyOCR instance independiente
- CPU-only inference: 1-3 segundos por OCR call
- 40 bots x 5-10MB RAM = 200-400MB solo para modelos OCR
- Bloquea event loop executor thread pool

## Comparación de Motores OCR

| Dimensión | Tesseract 5.5 | EasyOCR |
|-----------|---------------|---------|
| Core tech | LSTM neural net | PyTorch (CRAFT + CRNN) |
| Tiempo/página (CPU) | ~0.82s | ~2.45s |
| Tiempo/página (GPU) | N/A (CPU only) | ~0.85s |
| Precisión (texto limpio) | ~89.3% | ~96.8% |
| Install size | ~10MB | ~500MB (PyTorch) |
| GPU support | No | Yes (CUDA) |
| Idiomas | 100+ | 80+ |

### Para NYTRIX
- Screenshots de UI bancaria = texto limpio, fondo uniforme
- **Tesseract es suficiente**: 3x más rápido en CPU, 10MB vs 500MB
- EasyOCR overkill para classify_screen() con firmas de texto conocidas

## Solución 1: OCR Microservicio (FastAPI + Tesseract)

### Arquitectura
```
Bot processes → HTTP POST /ocr → FastAPI OCR Service → Tesseract → Response
                                    ↓
                              Single EasyOCR/Tesseract instance
                              Shared across all bots
```

### Código Base
```python
# ocr_service.py
from fastapi import FastAPI, File
import pytesseract
from PIL import Image
import io

app = FastAPI()

@app.post("/ocr")
async def ocr(image: bytes = File(...), lang: str = "eng"):
    img = Image.open(io.BytesIO(image))
    text = pytesseract.image_to_string(img, lang=lang, config='--psm 11')
    return {"text": text}

@app.post("/classify")
async def classify(image: bytes = File(...)):
    img = Image.open(io.BytesIO(image))
    text = pytesseract.image_to_string(img, config='--psm 11')
    # classify_screen logic here
    screen_type = classify_from_text(text)
    return {"type": screen_type, "text": text}
```

### Ventajas
- 1 sola instancia OCR compartida por todos los bots
- RAM: 10MB (Tesseract) vs 200-400MB (40x EasyOCR)
- CPU: 1 proceso OCR centralizado con worker pool
- Upgradeable sin cambiar bots

## Solución 2: Tesseract como systemd service

```ini
# /etc/systemd/system/ocr-service.service
[Unit]
Description=NYTRIX OCR Service
After=network.target

[Service]
Type=simple
User=nytrix
ExecStart=/usr/bin/python3 /opt/nytrix/ocr-service/ocr_service.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## Solución 3: Batch Processing
- EasyOCR batch: procesar múltiples imágenes de una vez
- Reduce overhead per-image significativamente
- Solo viable con GPU compartida

## Recomendación para NYTRIX
1. **Migrar de EasyOCR a Tesseract** para classify_screen() — 3x más rápido en CPU
2. **OCR microservicio FastAPI** como servicio centralizado
3. **Puerto dedicado** (ej: 8081) con health check endpoint
4. **systemd unit** para auto-restart
5. Bots llaman HTTP en vez de load model local

## Fuentes
- github.com/LATIS-DocumentAI-Team/ocr-microservice
- imagetotable.ai/blog/tesseract-vs-easyocr-2026
- markaicode.com/architecture/scalable-tesseract-architecture-production
- easyocr.org/en/help/batch-processing
