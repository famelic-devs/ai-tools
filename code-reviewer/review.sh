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
PR_NUMBER="${1:-}"
if [[ -z "$PR_NUMBER" ]]; then
  echo "Usage: review.sh <PR_number>" >&2
  exit 1
fi

# ─── Fetch PR context ─────────────────────────────────────────────────────────
echo "→ Fetching PR #${PR_NUMBER}..."

PR_TITLE=$(gh pr view "$PR_NUMBER" --json title --jq '.title')
PR_BODY=$(gh pr view "$PR_NUMBER" --json body --jq '.body // ""')
PR_DIFF=$(gh pr diff "$PR_NUMBER")

# ─── Build prompt ─────────────────────────────────────────────────────────────
PROFILE=$(cat "$PROFILE_FILE")

PROMPT="$(cat <<EOF
${PROFILE}

---

## PR to Review

**Title:** ${PR_TITLE}

**Description:**
${PR_BODY}

**Diff:**
\`\`\`diff
${PR_DIFF}
\`\`\`

Review this PR following your methodology and output format.
EOF
)"

# ─── Run review ───────────────────────────────────────────────────────────────
echo "→ Reviewing PR #${PR_NUMBER}: ${PR_TITLE}"
echo ""

ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" claude -p "$PROMPT"
