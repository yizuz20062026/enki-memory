# Workflow de Auditoría

## Pre-auditoría
1. Cargar skill `nytx-standard`
2. Identificar nivel del proyecto (N1-N10)
3. Ejecutar `nytx-check ./proyecto`

## Auditoría por nivel
- **N1 Arquitectura**: revisar diseño, dependencias, patrones
- **N2 Seguridad**: vulnerabilidades, auth, input validation
- **N3 Calidad**: code smells, testing, documentation
- **N4 Performance**: profiling, indexes, caching
- **N5 DevOps**: CI/CD, Docker, deployment
- **N6 Monitoring**: logging, metrics, alerting
- **N7 Compliance**: licencias, GDPR, datos sensibles
- **N8 Testing**: coverage, E2E, regression
- **N9 Deployment**: rollback, blue-green, canary
- **N10 Post-lanzamiento**: monitoring, alertas, retrospectives

## Post-auditoría
- Generar reporte con `nytx-check ./proyecto full`
- Comparar resultado vs estándar
- Crear ADR si hay decisiones pendientes
- Guardar lecciones en `lessons/`

## Pre-lanzamiento
- Ejecutar `pre-launch-audit` (scan.sh)
- Todos los issues deben estar resueltos
- ADR actualizado
- Handoff documentado

## Wikilinks
- [[nytrix]]
- [[titan-mode]]
- [[adr-system]]
