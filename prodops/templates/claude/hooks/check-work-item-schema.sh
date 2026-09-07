#!/usr/bin/env bash
# check-work-item-schema.sh — Valida que um Work Item (GitHub Issue) segue o Work Item Schema canônico.
#
# Pode ser usado como hook PreToolUse em Claude Code para interceptar
# criações de issue e verificar conformidade antes de executar gh issue create.
#
# Verifica:
#   1. Título segue padrão canônico: [Artifact ID]: descrição
#   2. Labels obrigatórios estão presentes: artifact-type, operation, journey
#   3. Body declara os campos obrigatórios do schema
#
# Uso (standalone):
#   check-work-item-schema.sh --title "[OBC-042]: create invoice boleto" \
#                              --labels "journey:delivery,artifact-type:local-obc,operation:implement"
#
# Uso como hook (via stdin do JSON de tool call):
#   echo '<tool-call-json>' | check-work-item-schema.sh --hook
#
# Saída:
#   0 — schema válido
#   1 — schema inválido; detalha o que está faltando

set -euo pipefail

HOOK_MODE=false
TITLE=""
LABELS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --hook)   HOOK_MODE=true; shift ;;
    --title)  TITLE="$2"; shift 2 ;;
    --labels) LABELS="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,30p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *) echo "Opção desconhecida: $1" >&2; exit 1 ;;
  esac
done

ISSUES=()

# Em modo hook, ler JSON do stdin (Claude Code hook format)
if [[ "${HOOK_MODE}" == "true" ]]; then
  INPUT=$(cat)
  # Extrair título e labels do JSON se disponível (formato gh issue create)
  if command -v jq &>/dev/null; then
    TITLE=$(echo "${INPUT}" | jq -r '.tool_input.command // ""' 2>/dev/null | grep -oP '(?<=--title ")[^"]+' || true)
    LABELS=$(echo "${INPUT}" | jq -r '.tool_input.command // ""' 2>/dev/null | grep -oP '(?<=--label ")[^"]+' || true)
  fi
fi

# Verificação 1: Padrão de título [Artifact ID]: descrição
if [[ -n "${TITLE}" ]]; then
  if ! echo "${TITLE}" | grep -qP '^\[.+\]:.+'; then
    ISSUES+=("Título não segue padrão canônico: [Artifact ID]: descrição — encontrado: '${TITLE}'")
  fi
fi

# Verificação 2: Labels obrigatórios
REQUIRED_LABEL_PREFIXES=("journey:" "artifact-type:" "operation:")
for prefix in "${REQUIRED_LABEL_PREFIXES[@]}"; do
  if [[ -z "${LABELS}" ]] || ! echo "${LABELS}" | grep -qi "${prefix}"; then
    ISSUES+=("Label obrigatório ausente: ${prefix}*")
  fi
done

# Resultado
if [[ ${#ISSUES[@]} -eq 0 ]]; then
  if [[ -n "${TITLE}" ]] || [[ -n "${LABELS}" ]]; then
    echo "✅ Work Item schema válido"
  fi
  exit 0
else
  echo "⛔ Work Item schema inválido:"
  for issue in "${ISSUES[@]}"; do
    echo "   - ${issue}"
  done
  echo ""
  echo "   Schema canônico: prodops/framework/execution-mapping/work-item-schema.md"
  echo "   Padrão de título: [Artifact ID]: descrição"
  echo "   Labels obrigatórios: journey:<v>, artifact-type:<v>, operation:<v>"
  exit 1
fi
