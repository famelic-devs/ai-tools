# 🕵️ code-reviewer

An AI sub-agent that acts as an experienced **Tech Lead** reviewing pull requests and code contributions in the famelic-devs organization.

## Profile

The code-reviewer embodies a seasoned Tech Lead with 10+ years of experience in medium and large-scale software projects. It reviews code the way a great senior engineer would: direct, constructive, thorough — focused on making the team better, not just finding faults.

**Expertise:**
- Identifying logic errors, edge cases, and potential runtime failures
- Enforcing clean code principles (SOLID, DRY, KISS, YAGNI)
- Ensuring consistent coding style and naming conventions
- Spotting security vulnerabilities and performance bottlenecks
- Validating test coverage and quality
- Enforcing [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) on commit messages and PR titles

**Communication style:**
- Flags blockers clearly (🔴 must fix)
- Suggests improvements without blocking (🟡 consider this)
- Acknowledges good work (✅ nice)
- Always explains *why*, not just *what*

## What It Reviews

- ✅ Logic correctness and edge cases
- ✅ Code readability and maintainability
- ✅ Naming conventions and consistency
- ✅ Security issues (injection, exposure, improper auth)
- ✅ Performance concerns
- ✅ Test presence and quality
- ✅ Conventional Commits compliance
- ✅ Dead code, unused imports, unnecessary complexity

## Setup

See [`../install.sh`](../install.sh) to install all tools, or set up this agent individually:

```bash
cd code-reviewer
cp .env.example .env
# Fill in your API keys in .env
```

## Usage

### Manual review
```bash
./review.sh <PR_number>
# Example: ./review.sh 42
```

### Automatic (GitHub Actions)
Add the workflow from `ci/code-review.yml` to your repository to trigger automatic reviews on every PR.

## Configuration

Edit `config.yml` to customize behavior:

```yaml
# Severity thresholds, focus areas, language-specific rules
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | Claude API key for the review engine |
| `GITHUB_TOKEN` | Token with `pull_requests: read/write` permissions |
| `REVIEW_STRICTNESS` | `strict` \| `balanced` \| `lenient` (default: `balanced`) |
