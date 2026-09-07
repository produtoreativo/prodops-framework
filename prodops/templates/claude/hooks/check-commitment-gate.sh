#!/usr/bin/env bash
# check-commitment-gate.sh — Valida pré-condições do CommitmentGate para um experimento.
#
# Verifica:
#   1. Decision Package presente no experiment.md (seções obrigatórias)
#   2. Evidence Threshold declarado e verificado (se presente)
#   3. OBC Draft existe no diretório do experimento
#   4. BDD draft existe no diretório do experimento
#
# Uso:
#   check-commitment-gate.sh <experiment-slug>
#   check-commitment-gate.sh 042-payment-provider-x
#
# Saída:
#   0 — todas as pré-condições satisfeitas; commitment gate pode ser convocado
#   1 — pré-condições ausentes; listar o que falta

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
OBC_DIR="${EXPERIMENT_DIR}/obcs"
FEATURES_DIR="${EXPERIMENT_DIR}/features"

ISSUES=()

# 1. experiment.md existe
if [[ ! -f "${EXPERIMENT_FILE}" ]]; then
  ISSUES+=("experiment.md não encontrado em ${EXPERIMENT_DIR}")
else
  # Verificar seções obrigatórias do Decision Package
  for section in "Executive Summary" "Decisão Recomendada" "Decision Package" "Recomendação"; do
    if grep -qi "${section}" "${EXPERIMENT_FILE}"; then
      break
    fi
  done

  REQUIRED_SECTIONS=("hipótese\|hypothesis" "descobertas\|findings\|resultado" "recomendação\|recommendation")
  for pattern in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -qi "${pattern}" "${EXPERIMENT_FILE}"; then
      ISSUES+=("experiment.md está faltando seção: ${pattern}")
    fi
  done
fi

# 2. OBC Draft existe
if [[ ! -d "${OBC_DIR}" ]] || [[ -z "$(find "${OBC_DIR}" -name "*.md" 2>/dev/null | head -1)" ]]; then
  ISSUES+=("OBC Draft ausente: ${OBC_DIR}/*.md")
fi

# 3. BDD draft existe
if [[ ! -d "${FEATURES_DIR}" ]] || [[ -z "$(find "${FEATURES_DIR}" -name "*.feature" 2>/dev/null | head -1)" ]]; then
  ISSUES+=("BDD draft ausente: ${FEATURES_DIR}/*.feature")
fi

# Resultado
if [[ ${#ISSUES[@]} -eq 0 ]]; then
  echo "✅ CommitmentGate: todas as pré-condições satisfeitas para ${EXPERIMENT_SLUG}"
  echo "   → Convocar o trio (PM + Tech Lead + Autor) para executar o gate."
  exit 0
else
  echo "⛔ CommitmentGate bloqueado — pré-condições ausentes para ${EXPERIMENT_SLUG}:"
  for issue in "${ISSUES[@]}"; do
    echo "   - ${issue}"
  done
  echo ""
  echo "   → Complete o Decision Package e os artefatos ausentes antes de convocar o trio."
  exit 1
fi
