# Ciberseguridad — Checklists

> Por plataforma. Consultar ANTES de planificar proyectos.

## Regla de Oro
Defensa en profundidad: proxy → Server Actions → DB (RLS).

## Web (Next.js 16)
- CSP nonce-based, auth en CADA Server Action, rate limiting, Zod validation
- CVEs: CVE-2025-29927 (CVSS 9.1), CVE-2025-55182 (CVSS 10.0)

## Móvil (Expo)
- SecureStore para tokens, SSL pinning SPKI, biometrics, `__DEV__` = false

## Desktop (Electron)
- contextIsolation: true, nodeIntegration: false, sandbox: true
- Preload con contextBridge, IPC validado, CSP restrictivo

## Ver También
- [[../decisiones/seguridad-web\|Decisión: Seguridad]]
- [[../conocimiento/nextjs16\|Next.js 16]] — CVEs
