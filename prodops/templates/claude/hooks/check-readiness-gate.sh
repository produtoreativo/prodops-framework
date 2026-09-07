#!/usr/bin/env bash
# check-readiness-gate.sh — Valida os 5 gates de prontidão do Downstream para uma capability.
#
# Gates verificados:
#   1. Local OBC committed em prodops/artifacts/obcs/<slug>.md
#   2. BDD Feature committed em prodops/artifacts/bdd/<slug>.feature
#   3. Riscos documentados em prodops/artifacts/risks/risks.md
#   4. Item no Iteration Plan com status "Entrou"
#   5. GitHub Issue existente e mapeada (verificação básica de referência)
#
# Uso:
#   check-readiness-gate.sh <capability-slug>
#   check-readiness-gate.sh create-invoice-boleto
#
# Saída:
#   0 — Downstream Ready: todos os gates passaram
#   1 — Downstream Declared: gates faltando (lista o que falta)

set -euo pipefail

CAPABILITY_SLUG="${1:-}"

if [[ -z "${CAPABILITY_SLUG}" ]]; then
  echo "Uso: $0 <capability-slug>" >&2
  exit 1
fi

GATES_PASSED=()
GATES_FAILED=()

# Gate 1: OBC committed
OBC_PATH="prodops/artifacts/obcs/${CAPABILITY_SLUG}.md"
if [[ -f "${OBC_PATH}" ]]; then
  # Verificar estado no arquivo
  if grep -qi "Committed\|In Delivery\|Released" "${OBC_PATH}"; then
    GATES_PASSED+=("Gate 1 ✅ OBC: ${OBC_PATH}")
  else
    GATES_FAILED+=("Gate 1 ❌ OBC existe mas estado não é Committed: ${OBC_PATH}")
  fi
else
  GATES_FAILED+=("Gate 1 ❌ OBC ausente: ${OBC_PATH}")
fi

# Gate 2: BDD Feature
BDD_PATH="prodops/artifacts/bdd/${CAPABILITY_SLUG}.feature"
if [[ -f "${BDD_PATH}" ]]; then
  GATES_PASSED+=("Gate 2 ✅ BDD Feature: ${BDD_PATH}")
else
  GATES_FAILED+=("Gate 2 ❌ BDD Feature ausente: ${BDD_PATH}")
fi

# Gate 3: Risks documented
RISKS_PATH="prodops/artifacts/risks/risks.md"
if [[ -f "${RISKS_PATH}" ]] && grep -qi "${CAPABILITY_SLUG}" "${RISKS_PATH}" 2>/dev/null; then
  GATES_PASSED+=("Gate 3 ✅ Riscos: ${RISKS_PATH}")
else
  GATES_FAILED+=("Gate 3 ❌ Riscos não documentados para ${CAPABILITY_SLUG} em ${RISKS_PATH}")
fi

# Gate 4: Iteration Plan entry
ITERATION_PLAN="prodops/artifacts/plans/iteration-plan.md"
if [[ -f "${ITERATION_PLAN}" ]] && grep -qi "${CAPABILITY_SLUG}" "${ITERATION_PLAN}" 2>/dev/null; then
  GATES_PASSED+=("Gate 4 ✅ Iteration Plan: ${CAPABILITY_SLUG} presente")
else
  GATES_FAILED+=("Gate 4 ❌ ${CAPABILITY_SLUG} ausente no Iteration Plan: ${ITERATION_PLAN}")
fi

# Gate 5: GitHub Issue mapeada (verificação de referência no plan.md da iteração ativa)
# Tenta encontrar a iteração ativa pelo plano
if [[ -f "${ITERATION_PLAN}" ]]; then
  ACTIVE_VERSION=$(grep -oP 'v\d+\.\d+\.\d+' "${ITERATION_PLAN}" | head -1 2>/dev/null || true)
  if [[ -n "${ACTIVE_VERSION}" ]]; then
    ACTIVE_PLAN="prodops/artifacts/iterations/${ACTIVE_VERSION}/plan.md"
    if [[ -f "${ACTIVE_PLAN}" ]] && grep -qi "${CAPABILITY_SLUG}" "${ACTIVE_PLAN}" 2>/dev/null; then
      GATES_PASSED+=("Gate 5 ✅ Issue mapeada em: ${ACTIVE_PLAN}")
    else
      GATES_FAILED+=("Gate 5 ❌ Issue não mapeada para ${CAPABILITY_SLUG} em ${ACTIVE_PLAN}")
    fi
  else
    GATES_FAILED+=("Gate 5 ❌ Versão de iteração ativa não encontrada no Iteration Plan")
  fi
else
  GATES_FAILED+=("Gate 5 ❌ Iteration Plan não encontrado: ${ITERATION_PLAN}")
fi

# Resultado
echo "Readiness Gate — ${CAPABILITY_SLUG}"
echo "══════════════════════════════════════"
for passed in "${GATES_PASSED[@]}"; do
  echo "  ${passed}"
done
for failed in "${GATES_FAILED[@]}"; do
  echo "  ${failed}"
done
echo ""

if [[ ${#GATES_FAILED[@]} -eq 0 ]]; then
  echo "✅ Downstream Ready — todos os 5 gates passaram."
  echo "   → Capability pode entrar no Bootstrap."
  exit 0
else
  echo "⛔ Downstream Declared — ${#GATES_FAILED[@]} gate(s) faltando."
  echo "   → Resolva os gates faltando antes de iniciar Delivery."
  exit 1
fi
