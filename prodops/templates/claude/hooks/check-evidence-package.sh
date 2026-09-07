#!/usr/bin/env bash
# check-evidence-package.sh — Valida o Evidence Package de um experimento Upstream.
#
# Verifica:
#   1. experiment.md existe e tem seções de hipótese, método e conclusão
#   2. Evidence Threshold declarado e verificado (se presente)
#   3. upstream-trail.md existe com status de Evidence Package
#   4. Pelo menos um artefato produzido (código, OBC, BDD, ou evidência)
#
# Uso:
#   check-evidence-package.sh <experiment-slug>
#   check-evidence-package.sh 042-payment-provider-x
#
# Saída:
#   0 — Evidence Package válido; CommitmentGate pode ser convocado
#   1 — Evidence Package incompleto; listar o que falta

set -euo pipefail

EXPERIMENT_SLUG="${1:-}"

if [[ -z "${EXPERIMENT_SLUG}" ]]; then
  echo "Uso: $0 <experiment-slug>" >&2
  exit 1
fi

EXPERIMENT_DIR="prodops/artifacts/experiments/${EXPERIMENT_SLUG}"

if [[ ! -d "${EXPERIMENT_DIR}" ]]; then
  echo "❌ Diretório do experimento não encontrado: ${EXPERIMENT_DIR}" >&2
  exit 1
fi

EXPERIMENT_FILE="${EXPERIMENT_DIR}/experiment.md"
TRAIL_FILE="${EXPERIMENT_DIR}/upstream-trail.md"
EVIDENCE_DIR="${EXPERIMENT_DIR}/evidence"

ISSUES=()

# 1. experiment.md com seções obrigatórias
if [[ ! -f "${EXPERIMENT_FILE}" ]]; then
  ISSUES+=("experiment.md ausente")
else
  # Verificar hipótese
  if ! grep -qi "hipótese\|hypothesis" "${EXPERIMENT_FILE}"; then
    ISSUES+=("experiment.md: seção de hipótese ausente")
  fi
  # Verificar resultado/descobertas
  if ! grep -qi "descobertas\|findings\|resultado\|result" "${EXPERIMENT_FILE}"; then
    ISSUES+=("experiment.md: seção de descobertas/resultado ausente")
  fi
  # Verificar conclusão/recomendação
  if ! grep -qi "conclus\|recomend\|recommend" "${EXPERIMENT_FILE}"; then
    ISSUES+=("experiment.md: seção de conclusão/recomendação ausente")
  fi

  # 2. Evidence Threshold (se declarado, verificar se há resultado de verificação)
  if grep -qi "Evidence Threshold\|evidence-threshold" "${EXPERIMENT_FILE}"; then
    if ! grep -qi "satisfeito\|satisfied\|verificado\|verified\|atingido" "${EXPERIMENT_FILE}"; then
      ISSUES+=("Evidence Threshold declarado mas não verificado no experiment.md")
    fi
  fi
fi

# 3. upstream-trail.md existe
if [[ ! -f "${TRAIL_FILE}" ]]; then
  ISSUES+=("upstream-trail.md ausente: ${TRAIL_FILE}")
fi

# 4. Pelo menos um artefato produzido
HAS_ARTIFACT=false

# Código no repositório
if git ls-files --others --cached --exclude-standard "${EXPERIMENT_DIR}/" 2>/dev/null | grep -v ".md" | head -1 | grep -q .; then
  HAS_ARTIFACT=true
fi

# OBC draft
if [[ -d "${EXPERIMENT_DIR}/obcs" ]] && [[ -n "$(find "${EXPERIMENT_DIR}/obcs" -name "*.md" 2>/dev/null | head -1)" ]]; then
  HAS_ARTIFACT=true
fi

# BDD draft
if [[ -d "${EXPERIMENT_DIR}/features" ]] && [[ -n "$(find "${EXPERIMENT_DIR}/features" -name "*.feature" 2>/dev/null | head -1)" ]]; then
  HAS_ARTIFACT=true
fi

# Material de suporte
if [[ -d "${EVIDENCE_DIR}" ]] && [[ -n "$(find "${EVIDENCE_DIR}" -type f 2>/dev/null | head -1)" ]]; then
  HAS_ARTIFACT=true
fi

if [[ "${HAS_ARTIFACT}" == "false" ]]; then
  ISSUES+=("Nenhum artefato produzido encontrado (código, OBC, BDD, ou evidence/)")
fi

# Resultado
if [[ ${#ISSUES[@]} -eq 0 ]]; then
  echo "✅ Evidence Package válido para ${EXPERIMENT_SLUG}"
  echo "   → CommitmentGate pode ser convocado."
  exit 0
else
  echo "⛔ Evidence Package incompleto para ${EXPERIMENT_SLUG}:"
  for issue in "${ISSUES[@]}"; do
    echo "   - ${issue}"
  done
  echo ""
  echo "   → Complete o Evidence Package antes de convocar o CommitmentGate."
  exit 1
fi
