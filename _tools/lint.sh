#!/bin/bash
# lint.sh — Health check del vault enki-memory
# Detecta: links rotos, notas sin wikilinks

VAULT_DIR="${1:-$HOME/enki-memory}"
ERRORS=0
WARNINGS=0

echo "=== Enki Memory Vault Lint ==="
echo "Vault: $VAULT_DIR"
echo ""

# 1. Notas wiki sin wikilinks
echo "--- Notas sin wikilinks (mínimo 2) ---"
for f in "$VAULT_DIR"/wiki/**/*.md; do
  [ -f "$f" ] || continue
  LINKS=$(grep -oP '\[\[[^\]]+\]\]' "$f" 2>/dev/null | wc -l)
  if [ "$LINKS" -lt 2 ]; then
    echo "  WARN: $(basename "$f") tiene solo $LINKS wikilinks"
    WARNINGS=$((WARNINGS + 1))
  fi
done

# 2. Links rotos (resolving relative paths)
echo ""
echo "--- Links rotos ---"
for f in $(find "$VAULT_DIR" -name "*.md"); do
  FILE_DIR=$(dirname "$f")
  grep -oP '\[\[([^\]|\\]+)' "$f" 2>/dev/null | sed 's/\[\[//' | while read -r target; do
    # Resolve relative to file directory
    RESOLVED=$(realpath -m "$FILE_DIR/$target.md" 2>/dev/null)
    if [ ! -f "$RESOLVED" ]; then
      # Try without .md in case it's a directory or already has extension
      RESOLVED2=$(realpath -m "$FILE_DIR/$target" 2>/dev/null)
      if [ ! -f "$RESOLVED2" ] && [ ! -d "$RESOLVED2" ]; then
        REL_FROM_VAULT="${RESOLVED#$VAULT_DIR/}"
        echo "  BROKEN: $(echo "$f" | sed "s|$VAULT_DIR/||") → $target"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  done
done

# 3. Resumen
echo ""
TOTAL_FILES=$(find "$VAULT_DIR" -name "*.md" | wc -l)
TOTAL_WIKI=$(find "$VAULT_DIR/wiki" -name "*.md" 2>/dev/null | wc -l)
TOTAL_CAPSULES=$(find "$VAULT_DIR/capsules" -name "*.md" 2>/dev/null | wc -l)
TOTAL_SESSIONS=$(find "$VAULT_DIR/sessions" -name "*.md" 2>/dev/null | wc -l)

echo "=== Resumen ==="
echo "  Archivos totales: $TOTAL_FILES"
echo "  Wiki pages: $TOTAL_WIKI"
echo "  Cápsulas: $TOTAL_CAPSULES"
echo "  Sesiones: $TOTAL_SESSIONS"
echo "  Links rotos: $ERRORS"
echo "  Warnings: $WARNINGS"

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo "  Estado: OK"
else
  echo "  Estado: REVISAR ($ERRORS errors, $WARNINGS warnings)"
fi
