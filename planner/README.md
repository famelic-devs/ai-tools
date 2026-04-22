# 📋 planner

An AI sub-agent that acts as an experienced **Senior Project Planner** for the famelic-devs organization. It turns feature descriptions and product requirements into well-structured, actionable Jira backlogs.

## Profile

The planner embodies a pragmatic Senior Planner with 12+ years in agile delivery. It structures work the way a great product-engineering team would: clear Epics, right-sized stories, explicit dependencies, and Story Points that actually mean something.

**Expertise:**
- Identifying Epic vs Story boundaries
- Sizing stories correctly (max 8 SP — anything larger gets split)
- Writing acceptance criteria that define a real definition of done
- Detecting and promoting oversized stories to Epics — continuously, not just at kickoff
- Linking dependencies natively in Jira (never in description text)
- Setting Story Points in the correct Jira field (`customfield_10016`)

**Communication style:**
- Structured output: titles, types, SP, acceptance criteria, dependencies
- Asks before assuming when scope is ambiguous
- Pushes back on oversized stories with clear reasoning

## What It Produces

For a given feature or requirement:

- ✅ Epic breakdown by module or feature area
- ✅ Stories with titles, SP, and acceptance criteria
- ✅ Dependency mapping (Blocks / Blocked by)
- ✅ Jira-ready field values (`customfield_10016` for SP, parent keys, issue types)
- ✅ Flags for stories that need further refinement

## Setup

```bash
cd planner
cp .env.example .env
# Fill in your API keys in .env
```

## Usage

### Interactive planning session
```bash
./plan.sh "Feature description or requirements document path"
# Example: ./plan.sh "Users need to reset their password via email"
```

### From a file
```bash
./plan.sh --input requirements.md
```

## Configuration

Edit `config.yml` to customize behavior:

```yaml
planning:
  max_sp_per_story: 8         # Max SP before promoting to Epic
  sp_scale: [1, 2, 3, 5, 8]  # Fibonacci scale
  jira_sp_field: customfield_10016
  jira_dependency_link_type: Blocks
```

## Skills

This agent loads the following shared skills at runtime:

| Skill | Purpose |
|-------|---------|
| [`planning-conventions`](../skills/planning-conventions/SKILL.md) | Story sizing rules, Epic definition, Jira field conventions, backlog refinement checklist |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | Claude API key for the planning engine |
| `JIRA_BASE_URL` | Your Jira instance URL (e.g. `https://your-org.atlassian.net`) |
| `JIRA_API_TOKEN` | Jira API token with project read/write permissions |
| `JIRA_USER_EMAIL` | Email associated with the Jira API token |
| `JIRA_PROJECT_KEY` | Default project key (e.g. `SCRUM`) |
