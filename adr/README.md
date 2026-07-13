# Architecture Decision Records (ADR)

## Formato
Cada ADR sigue la plantilla MADR (Markdown Any Decision Records).

## Plantilla
```markdown
# ADR-NNN: [Título]

## Contexto
[Qué situación requiere una decisión]

## Problema
[Qué se está decidiendo exactamente]

## Alternativas
### Alternativa A: [Nombre]
- Pros: ...
- Contras: ...

### Alternativa B: [Nombre]
- Pros: ...
- Contras: ...

## Decisión
[Qué se decidió]

## Razón
[Por qué esta alternativa sobre las demás]

## Impacto
[Cómo afecta al proyecto]

## Notas futuras
[Qué observar o reconsiderar]

## Wikilinks
[[-links a notas relacionadas]]
```

## Convenciones
- Numeración secuencial: ADR-001, ADR-002...
- Una decisión por ADR
- Nunca se borran — solo se marcan como `obsoleto` si ya no aplica
- Todo ADR debe tener al menos 2 wikilinks
- Status: `aceptado` | `obsoleto` | `reemplazado por ADR-XXX`
