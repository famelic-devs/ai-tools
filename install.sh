#!/usr/bin/env bash
set -euo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SKILLS_DIR="${HOME}/.claude/skills"
LOCAL_BIN_DIR="${HOME}/.local/bin"

# ─── Helpers ──────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}→${RESET} $*"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $*"; }
error()   { echo -e "${RED}✗${RESET} $*"; }
header()  { echo -e "\n${BOLD}$*${RESET}"; }

prompt_value() {
  local var_name="$1"
  local description="$2"
  local default="${3:-}"
  local value

  if [[ -n "$default" ]]; then
    read -rp "  ${description} [${default}]: " value
    echo "${value:-$default}"
  else
    read -rp "  ${description}: " value
    echo "$value"
  fi
}

# ─── Prerequisites ────────────────────────────────────────────────────────────
check_prerequisites() {
  header "Checking prerequisites"

  local missing=()

  if command -v claude &>/dev/null; then
    success "claude CLI found ($(claude --version 2>/dev/null | head -1))"
  else
    warn "claude CLI not found — install it from https://claude.ai/code"
    missing+=("claude")
  fi

  if command -v gh &>/dev/null; then
    success "gh CLI found ($(gh --version | head -1))"
  else
    warn "gh CLI not found — some tools won't work without it"
    missing+=("gh")
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo ""
    warn "Missing tools: ${missing[*]}. You can continue, but some features may not work."
    read -rp "  Continue anyway? [y/N]: " cont
    [[ "${cont,,}" == "y" ]] || { error "Aborted."; exit 1; }
  fi
}

# ─── Skills ───────────────────────────────────────────────────────────────────
install_skills() {
  header "Installing skills → ${CLAUDE_SKILLS_DIR}"

  local skills_src="${REPO_DIR}/skills"

  if [[ ! -d "$skills_src" ]]; then
    warn "No skills/ directory found — skipping"
    return
  fi

  mkdir -p "$CLAUDE_SKILLS_DIR"

  for skill_dir in "${skills_src}"/*/; do
    local skill_name
    skill_name="$(basename "$skill_dir")"
    local target="${CLAUDE_SKILLS_DIR}/${skill_name}"

    if [[ -L "$target" ]]; then
      success "skill '${skill_name}' already linked"
    elif [[ -d "$target" ]]; then
      warn "skill '${skill_name}' already exists at ${target} (not a symlink — skipping)"
    else
      ln -s "${skill_dir}" "${target}"
      success "skill '${skill_name}' linked"
    fi
  done
}

# ─── Tool setup ───────────────────────────────────────────────────────────────
setup_env() {
  local tool_dir="$1"
  local tool_name="$2"
  shift 2
  local env_vars=("$@")

  local env_example="${tool_dir}/.env.example"
  local env_file="${tool_dir}/.env"

  if [[ -f "$env_file" ]]; then
    success ".env already exists — skipping (delete it to reconfigure)"
    return
  fi

  if [[ ! -f "$env_example" ]]; then
    warn "No .env.example found for ${tool_name} — skipping env setup"
    return
  fi

  info "Configuring ${tool_name}..."
  echo ""

  # Copy template first
  cp "$env_example" "$env_file"

  # Prompt for each variable
  for entry in "${env_vars[@]}"; do
    local var="${entry%%:*}"
    local desc="${entry#*:}"
    local value
    value="$(prompt_value "$var" "$desc")"
    if [[ -n "$value" ]]; then
      sed -i "s|^${var}=.*|${var}=${value}|" "$env_file"
    fi
  done

  success ".env created for ${tool_name}"
}

# ─── Script linking ───────────────────────────────────────────────────────────
link_script() {
  local script_path="$1"
  local script_name
  script_name="$(basename "$script_path" .sh)"

  mkdir -p "$LOCAL_BIN_DIR"
  chmod +x "$script_path"

  local target="${LOCAL_BIN_DIR}/${script_name}"

  if [[ -L "$target" ]]; then
    success "command '${script_name}' already linked"
  elif [[ -f "$target" ]]; then
    warn "command '${script_name}' already exists at ${target} (not a symlink — skipping)"
  else
    ln -s "$script_path" "$target"
    success "command '${script_name}' linked → ${target}"
  fi
}

install_code_reviewer() {
  header "Tool: code-reviewer"
  setup_env "${REPO_DIR}/code-reviewer" "code-reviewer" \
    "ANTHROPIC_API_KEY:Anthropic API key" \
    "GITHUB_TOKEN:GitHub token (pull_requests: read/write)" \
    "REVIEW_STRICTNESS:Review strictness (strict|balanced|lenient):balanced"
  link_script "${REPO_DIR}/code-reviewer/review.sh"
}

install_planner() {
  header "Tool: planner"
  setup_env "${REPO_DIR}/planner" "planner" \
    "ANTHROPIC_API_KEY:Anthropic API key" \
    "JIRA_BASE_URL:Jira base URL (e.g. https://your-org.atlassian.net)" \
    "JIRA_API_TOKEN:Jira API token" \
    "JIRA_USER_EMAIL:Jira user email" \
    "JIRA_PROJECT_KEY:Default Jira project key (e.g. SCRUM)"
  link_script "${REPO_DIR}/planner/plan.sh"
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
  echo -e "${BOLD}famelic-devs / ai-tools installer${RESET}"
  echo "────────────────────────────────────"

  check_prerequisites
  install_skills
  install_code_reviewer
  install_planner

  header "Done"
  echo ""
  echo -e "  Skills linked to ${BLUE}${CLAUDE_SKILLS_DIR}${RESET}"
  echo -e "  Commands linked to ${BLUE}${LOCAL_BIN_DIR}${RESET}"
  echo -e "  Tools configured in their respective ${BLUE}.env${RESET} files"
  echo ""
  if [[ ":$PATH:" != *":${LOCAL_BIN_DIR}:"* ]]; then
    warn "${LOCAL_BIN_DIR} is not in your PATH. Add this to your shell profile:"
    echo -e "       ${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
    echo ""
  fi
  echo -e "  ${BOLD}Next steps:${RESET}"
  echo -e "  • code-reviewer: run ${BLUE}review <PR_number>${RESET}"
  echo -e "  • planner:       run ${BLUE}plan \"feature description\"${RESET}"
  echo ""
}

main "$@"
