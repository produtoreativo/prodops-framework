#!/usr/bin/env bash
# derive-context.sh — Deriva e serializa o estado atual do produto em prodops-context.yaml.
#
# Lê artefatos canônicos do produto e produz um snapshot machine-readable
# do lifecycle state de cada capability e do estado global do produto.
#
# Saída padrão: prodops/artifacts/context/prodops-context.yaml
# (criada automaticamente se o diretório não existir)
#
# Uso:
#   derive-context.sh [--output <path>] [--format yaml|json]
#
# Flags:
#   --output <path>    Caminho de saída (default: prodops/artifacts/context/prodops-context.yaml)
#   --format yaml|json Formato de saída (default: yaml)
#   --quiet            Suprimir logs; apenas escrever o arquivo de saída
#
# Exit codes:
#   0  Sucesso
#   1  Erro (artefatos obrigatórios ausentes, permissão negada)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../../.." && pwd)"

OUTPUT_PATH="${REPO_ROOT}/prodops/artifacts/context/prodops-context.yaml"
FORMAT="yaml"
QUIET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output)  OUTPUT_PATH="$2"; shift 2 ;;
    --format)  FORMAT="$2"; shift 2 ;;
    --quiet)   QUIET=true; shift ;;
    -h|--help)
      sed -n '2,22p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *) echo "Opção desconhecida: $1" >&2; exit 1 ;;
  esac
done

log() { [[ "${QUIET}" == "true" ]] || echo "[derive-context] $*"; }
warn() { echo "[derive-context] WARNING: $*" >&2; }

OBCS_DIR="${REPO_ROOT}/prodops/artifacts/obcs"
EXPERIMENTS_DIR="${REPO_ROOT}/prodops/artifacts/experiments"
ITERATION_PLAN="${REPO_ROOT}/prodops/artifacts/plans/iteration-plan.md"
TRACKING_LIST="${REPO_ROOT}/prodops/artifacts/product/backlogs/tracking-list.md"
RISKS_FILE="${REPO_ROOT}/prodops/artifacts/risks/risks.md"
RUNTIME_YAML="${REPO_ROOT}/prodops/runtime/runtime.yaml"

mkdir -p "$(dirname "${OUTPUT_PATH}")"

log "Derivando contexto do produto..."
log "  OBCs: ${OBCS_DIR}"
log "  Experimentos: ${EXPERIMENTS_DIR}"
log "  Iteration Plan: ${ITERATION_PLAN}"

# ── Timestamp ─────────────────────────────────────────────────────────────────

DERIVED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ)"

# ── Framework version ─────────────────────────────────────────────────────────

FRAMEWORK_VERSION="unknown"
if [[ -f "${RUNTIME_YAML}" ]]; then
  FRAMEWORK_VERSION=$(grep "^framework-version:" "${RUNTIME_YAML}" | head -1 | grep -oP '"[^"]+"' | tr -d '"' || echo "unknown")
fi

# ── Active iteration ──────────────────────────────────────────────────────────

ACTIVE_ITERATION="none"
if [[ -f "${ITERATION_PLAN}" ]]; then
  ACTIVE_ITERATION=$(grep -oP 'v\d+\.\d+\.\d+' "${ITERATION_PLAN}" | head -1 || echo "none")
fi

# ── OBCs por estado ───────────────────────────────────────────────────────────

collect_obcs_by_state() {
  local state_pattern="$1"
  local state_key="$2"
  local result=""

  if [[ ! -d "${OBCS_DIR}" ]]; then
    echo "    ${state_key}: []"
    return
  fi

  while IFS= read -r obc_file; do
    if grep -qi "${state_pattern}" "${obc_file}"; then
      local slug
      slug="$(basename "${obc_file}" .md)"
      result="${result}      - ${slug}\n"
    fi
  done < <(find "${OBCS_DIR}" -maxdepth 1 -name "*.md" 2>/dev/null | LC_ALL=C sort)

  if [[ -z "${result}" ]]; then
    echo "    ${state_key}: []"
  else
    echo "    ${state_key}:"
    printf "${result}"
  fi
}

# ── Experimentos ativos ───────────────────────────────────────────────────────

collect_active_experiments() {
  if [[ ! -d "${EXPERIMENTS_DIR}" ]]; then
    echo "  active_experiments: []"
    return
  fi

  local count=0
  local lines=""

  while IFS= read -r exp_dir; do
    local slug
    slug="$(basename "${exp_dir}")"
    local exp_file="${exp_dir}/experiment.md"

    # Incluir apenas experimentos não-arquivados (sem "archived" no trail ou conclusão final)
    if [[ -f "${exp_file}" ]]; then
      if ! grep -qi "archived\|encerrado\|fechado\|discard" "${exp_file}" 2>/dev/null; then
        lines="${lines}    - slug: ${slug}\n"
        ((count++))
      fi
    fi
  done < <(find "${EXPERIMENTS_DIR}" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | LC_ALL=C sort)

  if [[ $count -eq 0 ]]; then
    echo "  active_experiments: []"
  else
    echo "  active_experiments:"
    printf "${lines}"
  fi
}

# ── Capabilities no Iteration Plan ───────────────────────────────────────────

collect_iteration_capabilities() {
  if [[ ! -f "${ITERATION_PLAN}" ]]; then
    echo "  iteration_capabilities: []"
    return
  fi

  local lines=""
  local count=0

  while IFS= read -r line; do
    if echo "${line}" | grep -qi "Entrou\|In Delivery\|Concluído"; then
      local capability
      capability=$(echo "${line}" | grep -oP '[a-z][a-z0-9-]+' | head -1 || true)
      if [[ -n "${capability}" ]]; then
        lines="${lines}    - ${capability}\n"
        ((count++))
      fi
    fi
  done < "${ITERATION_PLAN}"

  if [[ $count -eq 0 ]]; then
    echo "  iteration_capabilities: []"
  else
    echo "  iteration_capabilities:"
    printf "${lines}"
  fi
}

# ── Gerar output ──────────────────────────────────────────────────────────────

log "Escrevendo contexto em: ${OUTPUT_PATH}"

{
  echo "# prodops-context.yaml — Snapshot do lifecycle state do produto"
  echo "# Gerado por: derive-context.sh"
  echo "# NÃO edite manualmente — regenere com: bash prodops/runtime/tools/derive-context/scripts/derive-context.sh"
  echo ""
  echo "derived_at: \"${DERIVED_AT}\""
  echo "framework_version: \"${FRAMEWORK_VERSION}\""
  echo "active_iteration: \"${ACTIVE_ITERATION}\""
  echo ""
  echo "obcs:"
  collect_obcs_by_state "Draft" "draft"
  collect_obcs_by_state "Refining" "refining"
  collect_obcs_by_state "Committed" "committed"
  collect_obcs_by_state "In Delivery" "in_delivery"
  collect_obcs_by_state "Released" "released"
  echo ""
  collect_active_experiments
  echo ""
  collect_iteration_capabilities
} > "${OUTPUT_PATH}"

log "✅ prodops-context.yaml gerado com sucesso"
log "   → Usar como input para pce-agent ou produto-context skill"
