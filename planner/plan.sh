#!/usr/bin/env bash
set -euo pipefail

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${TOOL_DIR}/.env"
PROFILE_FILE="${TOOL_DIR}/profile.md"

# ─── Load env ─────────────────────────────────────────────────────────────────
if [[ ! -f "$ENV_FILE" ]]; then
  echo "✗ .env not found. Run install.sh first." >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$ENV_FILE"

if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "✗ ANTHROPIC_API_KEY is not set in .env" >&2
  exit 1
fi

# ─── Args ─────────────────────────────────────────────────────────────────────
INPUT_FILE=""
DESCRIPTION=""

usage() {
  echo "Usage:"
  echo "  plan.sh \"Feature description\""
  echo "  plan.sh --input requirements.md"
  exit 1
}

if [[ $# -eq 0 ]]; then
  usage
fi

if [[ "$1" == "--input" ]]; then
  INPUT_FILE="${2:-}"
  [[ -z "$INPUT_FILE" ]] && { echo "✗ --input requires a file path" >&2; exit 1; }
  [[ ! -f "$INPUT_FILE" ]] && { echo "✗ File not found: $INPUT_FILE" >&2; exit 1; }
  DESCRIPTION="$(cat "$INPUT_FILE")"
else
  DESCRIPTION="$1"
fi

# ─── Build prompt ─────────────────────────────────────────────────────────────
PROFILE=$(cat "$PROFILE_FILE")

JIRA_CONTEXT=""
if [[ -n "${JIRA_PROJECT_KEY:-}" ]]; then
  JIRA_CONTEXT="Target Jira project: ${JIRA_PROJECT_KEY}"
  [[ -n "${JIRA_BASE_URL:-}" ]] && JIRA_CONTEXT="${JIRA_CONTEXT} (${JIRA_BASE_URL})"
fi

PROMPT="$(cat <<EOF
${PROFILE}

---

## Feature to Plan

${JIRA_CONTEXT:+${JIRA_CONTEXT}
}
${DESCRIPTION}

Break this down into Epics and Stories following your methodology.
Apply the Epic vs Story decision tree. Ensure all stories are ≤ 8 SP.
Output each ticket in the defined format.
EOF
)"

# ─── Run planner ──────────────────────────────────────────────────────────────
echo "→ Planning feature..."
echo ""

ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" claude -p "$PROMPT"
