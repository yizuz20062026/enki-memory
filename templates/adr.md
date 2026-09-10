---
carpeta: adr
fecha: <% tp.date.now("YYYY-MM-DD") %>
proyecto: 
tipo: adr
tags: 
  - adr
status: propuesto
agente: <% tp.system.suggester(["enki", "claude-code", "enki+claude-code"], ["enki", "claude-code", "enki+claude-code"]) %>
created: <% tp.date.now("YYYY-MM-DD HH:mm") %>
updated: <% tp.date.now("YYYY-MM-DD HH:mm") %>
---

# ADR-XXX: <% tp.system.prompt("Título de la decisión") %>

- **Estado**: Propuesto / Aceptado / Deprecado
- **Fecha**: <% tp.date.now("YYYY-MM-DD") %>
- **Decisores**: Yizuz, Enki / Claude Code

## Contexto y problema
- 

## Drivers de decisión
- 

## Opciones consideradas
- **Opción A**: 
- **Opción B**: 

## Decisión
- Elegimos **Opción A** porque...

## Consecuencias
- **Positivas**: 
- **Negativas / trade-offs**: 

## Alternativas descartadas y por qué
- 

## Wikilinks
- [[ ]] · [[ ]]
