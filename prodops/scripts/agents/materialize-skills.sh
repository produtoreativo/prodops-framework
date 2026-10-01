#!/usr/bin/env bash
# INTERNAL TOOL — framework development use only.
#
# Consumer repositories receive .claude/skills/, .claude/agents/ and
# .github/skills/ via install-prodops.sh, which copies the committed and
# versioned artefacts from the framework clone. Do NOT run this script in
# consumer repositories — it is only needed when creating or modifying a skill
# inside the prodops-framework repo itself to keep the pre-materialized copies
# in sync with prodops/skills/.
#
# Materialize canonical ProdOps skills into player-specific directories.
#
# Source:  prodops/skills/<skill>/SKILL.md
# Targets:
#   .claude/skills/<skill>/SKILL.md       (Claude Code)
#   .agents/skills/<skill>/SKILL.md       (Codex / OpenAI Agents)
#   .github/skills/<skill>/SKILL.md       (GitHub Copilot)
#
# Usage:
#   materialize-skills.sh [--skill <name>] [--check] [--force]
#
# Flags:
#   --skill <name>   Materialize only this skill (default: all in prodops/skills/)
#   --check          Report drift without writing; exits 1 if drift found
#   --force          Overwrite even if target has manual divergence
#
# Exit codes:
#   0   All targets up-to-date (or --check: no drift)
#   1   Drift detected (--check mode) or invalid args
#   2   Manual divergence detected (without --force)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/prodops/skills"

PLAYER_DIRS=(
  ".claude/skills"
  ".agents/skills"
  ".github/skills"
)

PLAYER_NAMES=(
  "claude"
  "codex"
  "copilot"
)

CHECK_ONLY="false"
FORCE="false"
TARGET_SKILL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)          CHECK_ONLY="true"; shift ;;
    --force)          FORCE="true"; shift ;;
    --skill)          TARGET_SKILL="$2"; shift 2 ;;
    --help|-h)
      sed -n '2,20p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

log()  { echo "[materialize-skills] $*"; }
warn() { echo "[materialize-skills] WARNING: $*" >&2; }
err()  { echo "[materialize-skills] ERROR: $*" >&2; }

DRIFT_COUNT=0
DIVERGENCE_COUNT=0
WRITTEN_COUNT=0
UP_TO_DATE_COUNT=0

provenance_header() {
  local skill="$1" player="$2"
  cat <<EOF
<!-- MATERIALIZED FILE — DO NOT EDIT MANUALLY
     Source:    prodops/skills/${skill}/SKILL.md
     Player:    ${player}
     Generator: prodops/scripts/agents/materialize-skills.sh
     Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
     To update: bash prodops/scripts/agents/materialize-skills.sh --skill ${skill}
-->
EOF
}

strip_header() {
  # Remove the provenance header (<!-- ... -->) from the start of a file
  sed '/^<!-- MATERIALIZED FILE/,/^-->/d'
}

rewrite_paths() {
  # Rewrite relative paths that escape the skills tree in materialized files.
  #
  # In the source (prodops/skills/<rel>), a path like "../../framework/" resolves
  # correctly to prodops/framework/. In a player target (.claude/skills/<rel>),
  # the identical path resolves to .claude/framework/ — which does not exist.
  # The player root (.claude/, .agents/, .github/) sits one level above
  # prodops/ in the repository, so crossing the skills root overshoots by one
  # level and lands inside the player directory instead of in prodops/.
  #
  # Fix: wherever a sequence of N "../"s would escape from the source file's
  # directory to prodops/, replace that sequence in the target content with
  # (N+1) "../"s followed by "prodops/". The extra level crosses the player
  # root and re-enters prodops/ from the repository root.
  #
  # The negative lookbehind (?<![./]) ensures we match exactly N "../"s and
  # not a sub-sequence buried inside a longer escape chain. A "/" immediately
  # before the N-level prefix means we are in the middle of a deeper chain
  # (e.g. "../" in "../../../") and must not touch it.
  #
  # $1 = content string
  # $2 = N = number of "../"s needed to escape to prodops/ from the source dir
  #       = depth of the file within <player>/skills/ (counting "skills/" as 1)
  local content="$1"
  local N="$2"
  local old_prefix="" new_prefix="" i
  for i in $(seq 1 "$N");         do old_prefix="${old_prefix}../"; done
  for i in $(seq 1 "$((N + 1))"); do new_prefix="${new_prefix}../"; done
  local new_full="${new_prefix}prodops/"
  # Use Perl for the negative lookbehind — sed BRE has no lookbehind support.
  # Values are passed via env so "/" in the path strings does not conflict with
  # any regex delimiter. \Q...\E quotes the prefix as literal (escapes dots so
  # they match a literal "." not any char). (?<![./]) rejects any match where
  # the immediately preceding character is "." or "/" (i.e. the matched escape
  # is a sub-segment of a longer "../../../..." chain). The /e modifier eval's
  # the replacement so $ENV{NEW}.$1 concatenates the new prefix + captured char.
  printf '%s' "$content" | \
    OLD="$old_prefix" NEW="$new_full" \
    perl -pe 's|(?<![./])\Q$ENV{OLD}\E([^.])|$ENV{NEW}.$1|ge'
}

materialize_steps() {
  # A skill may be multi-file: finish/steps/<step>/SKILL.md, but also
  # diligence/diligence-sync/... or ship/references/workflow.md. The parent
  # SKILL.md links to those with source-relative paths, so the whole sub-tree
  # must be materialized alongside it or the links dangle for the player.
  # Everything under the skill dir except the top-level SKILL.md is copied
  # with path rewriting applied — only the parent carries the provenance header.
  local skill="$1" target_dir="$2"
  local skill_src="$SKILLS_SRC/$skill"
  [[ -d "$skill_src" ]] || return 0

  local sub_src sub_rel sub_target
  while IFS= read -r sub_src; do
    sub_rel="${sub_src#"$skill_src/"}"
    [[ "$sub_rel" == "SKILL.md" ]] && continue
    sub_target="$target_dir/$sub_rel"

    # Compute N for this sub-file's location in the player tree.
    # The file sits at <player>/skills/<skill>/<sub_rel>.
    # Depth from player root = 1 (skills/) + 1 (skill name) + depth(sub_dir).
    local sub_dir sub_depth N_sub
    sub_dir=$(dirname "$sub_rel")
    if [[ "$sub_dir" == "." ]]; then
      sub_depth=0
    else
      sub_depth=$(echo "$sub_dir" | tr '/' '\n' | grep -c .)
    fi
    N_sub=$((2 + sub_depth))

    # Read source, apply path rewriting, then check against target.
    local sub_content transformed_content
    sub_content=$(cat "$sub_src")
    transformed_content=$(rewrite_paths "$sub_content" "$N_sub")

    if [[ -f "$sub_target" ]]; then
      local current_content
      current_content=$(cat "$sub_target")
      if [[ "$current_content" == "$transformed_content" ]]; then
        continue
      fi
    fi

    if [[ "$CHECK_ONLY" == "true" ]]; then
      log "↻ sub drift   [$skill] $sub_rel"
      DRIFT_COUNT=$((DRIFT_COUNT + 1))
      continue
    fi
    mkdir -p "$(dirname "$sub_target")"
    printf '%s\n' "$transformed_content" > "$sub_target"
    log "  → written: $sub_target"
    WRITTEN_COUNT=$((WRITTEN_COUNT + 1))
  done < <(find "$skill_src" -type f -name '*.md' | sort)
}

materialize_skill() {
  local skill="$1"
  local src="$SKILLS_SRC/$skill/SKILL.md"

  if [[ ! -f "$src" ]]; then
    warn "Skill source not found: $src — skipping"
    return
  fi

  local src_content
  src_content=$(cat "$src")

  # N=2 for top-level SKILL.md: <player>/skills/<skill>/SKILL.md
  # (1 for "skills/" + 1 for the skill name = 2 levels to escape player root)
  local rewritten_src
  rewritten_src=$(rewrite_paths "$src_content" 2)

  for i in "${!PLAYER_DIRS[@]}"; do
    local player_dir="${PLAYER_DIRS[$i]}"
    local player="${PLAYER_NAMES[$i]}"
    local target_dir="$REPO_ROOT/$player_dir/$skill"
    local target="$target_dir/SKILL.md"

    local generated_content
    # Tools like Codex CLI require YAML frontmatter on the very first line.
    # If the source starts with ---, inject the provenance comment after the
    # closing --- so the frontmatter block remains at line 1.
    if [[ "$rewritten_src" == ---* ]]; then
      local fm_end_line
      fm_end_line=$(printf '%s\n' "$rewritten_src" | awk 'NR==1{next} /^---/{print NR; exit}')
      if [[ -n "$fm_end_line" ]]; then
        local frontmatter body
        # Split without pipes: `head` closes the pipe before `printf` finishes
        # writing a large skill, and under `set -o pipefail` that SIGPIPE (141)
        # aborts the whole run. mapfile keeps the split in-process and preserves
        # blank lines and glob characters verbatim.
        local -a src_lines
        mapfile -t src_lines <<< "$rewritten_src"
        frontmatter=$(printf '%s\n' "${src_lines[@]:0:fm_end_line}")
        body=$(printf '%s\n' "${src_lines[@]:fm_end_line}")
        generated_content="${frontmatter}
$(provenance_header "$skill" "$player")
${body}"
      else
        generated_content="$(provenance_header "$skill" "$player")
${rewritten_src}"
      fi
    else
      generated_content="$(provenance_header "$skill" "$player")
${rewritten_src}"
    fi

    if [[ -f "$target" ]]; then
      local target_body target_first_line
      target_body=$(strip_header < "$target")
      target_first_line=$(head -1 "$target")

      # Check drift: compare canonical body AND verify structural correctness.
      # If the source has frontmatter, the target must also start with ---
      # (not with a provenance comment) — otherwise tools like Codex CLI fail.
      local structure_ok=true
      if [[ "$src_content" == ---* && "$target_first_line" != "---" ]]; then
        structure_ok=false
      fi

      if [[ "$target_body" == "$rewritten_src" && "$structure_ok" == "true" ]]; then
        log "✓ up-to-date  [$player] $skill"
        UP_TO_DATE_COUNT=$((UP_TO_DATE_COUNT + 1))
        # The parent being current says nothing about the sub-steps — check them
        # before skipping, or a multi-file skill never gets its sub-tree.
        materialize_steps "$skill" "$target_dir"
        continue
      fi

      # Drift detected — check if it's just a stale header or a manual edit
      local target_no_header
      target_no_header=$(strip_header < "$target")

      if [[ "$target_no_header" == "$rewritten_src" ]]; then
        # Only header differs (e.g. timestamp) — safe to update
        log "↻ refresh     [$player] $skill (header only)"
        DRIFT_COUNT=$((DRIFT_COUNT + 1))
      else
        # Body differs from canonical — potential manual edit
        if [[ "$FORCE" == "false" ]]; then
          warn "Manual divergence in [$player] $skill — use --force to overwrite"
          warn "  Target: $target"
          DIVERGENCE_COUNT=$((DIVERGENCE_COUNT + 1))
          if [[ "$CHECK_ONLY" == "false" ]]; then
            continue
          fi
        else
          warn "Overwriting manual divergence in [$player] $skill (--force)"
          DRIFT_COUNT=$((DRIFT_COUNT + 1))
        fi
      fi
    else
      log "✚ new         [$player] $skill"
      DRIFT_COUNT=$((DRIFT_COUNT + 1))
    fi

    if [[ "$CHECK_ONLY" == "true" ]]; then
      continue
    fi

    mkdir -p "$target_dir"
    printf '%s\n' "$generated_content" > "$target"
    log "  → written: $target"
    WRITTEN_COUNT=$((WRITTEN_COUNT + 1))

    materialize_steps "$skill" "$target_dir"
  done
}

# Discover skills
if [[ -n "$TARGET_SKILL" ]]; then
  SKILLS=("$TARGET_SKILL")
else
  mapfile -t SKILLS < <(find "$SKILLS_SRC" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort)
fi

log "Mode: $([ "$CHECK_ONLY" == "true" ] && echo "CHECK" || echo "WRITE")  Force: $FORCE"
log "Skills to process: ${SKILLS[*]}"
echo ""

for skill in "${SKILLS[@]}"; do
  materialize_skill "$skill"
done

echo ""
log "Summary:"
log "  Up-to-date:   $UP_TO_DATE_COUNT"
log "  Written:      $WRITTEN_COUNT"
log "  Drift:        $DRIFT_COUNT"
log "  Divergence:   $DIVERGENCE_COUNT (manual edits — use --force to overwrite)"

if [[ "$CHECK_ONLY" == "true" && $((DRIFT_COUNT + DIVERGENCE_COUNT)) -gt 0 ]]; then
  log "CHECK FAILED — run without --check to update"
  exit 1
fi

if [[ "$DIVERGENCE_COUNT" -gt 0 && "$FORCE" == "false" && "$CHECK_ONLY" == "false" ]]; then
  exit 2
fi

exit 0
