---
name: planning-conventions
description: >
  General agile planning conventions for story sizing, Epic definition, and backlog refinement.
  Trigger: When doing project planning, estimating, creating Jira tickets, refining a backlog, or defining Epics and stories.
license: Apache-2.0
metadata:
  author: famelic-devs
  version: "1.0"
---

## When to Use

Use this skill when:
- Estimating or sizing stories in a backlog
- Deciding whether a ticket should be a Story or an Epic
- Refining a backlog sprint by sprint
- Creating or updating Jira tickets with story points
- Reviewing existing tickets for scope problems

---

## Critical Rules

### Story Points

| Rule | Detail |
|------|--------|
| **Max 8 SP per story** | Any story exceeding 8 SP is not sufficiently refined — split it |
| **SP goes in the native field** | In Jira: `customfield_10016` via `additional_fields`. Never put SP only in the description text |
| **SP in description is decoration** | Text like `**SP:** 5` in the description does NOT feed burndown charts or velocity — it's invisible to Jira |

### Epic vs Story Decision

A ticket should be converted to an **Epic** when:

- It has **more than 8 SP** — signals the scope is too broad
- It acts as a **module index** — groups or describes a set of related stories
- It represents an **entire feature area** rather than a single deliverable
- Breaking it into smaller stories still leaves each story meaningful and independently deliverable

Epic definition is **continuous** — it happens every time a large story is found, not only at project kickoff.

### Dependency Links

- Always link dependencies using Jira's native **"Blocks"** link type
- Do NOT rely on text fields like "Dependencias:" in the description — they don't generate real visibility in the dependency graph

### Backlog Refinement Checklist

Before marking any story as refined:
- [ ] SP ≤ 8
- [ ] SP set in the native Jira field (not only in description)
- [ ] Story represents a single deliverable, not a group of them
- [ ] If it's an index or module overview → convert to Epic
- [ ] Dependencies linked with "Blocks" in Jira

---

## Decision Tree: Story or Epic?

```
Is SP > 8?                          → Epic (refine and split into child stories)
Does it describe a module or area?  → Epic
Does it group other related items?  → Epic
Is it a single deliverable ≤ 8 SP?  → Story
```

---

## Jira Field Reference

| Purpose | Correct field | Wrong approach |
|---------|--------------|----------------|
| Story Points | `customfield_10016` in `additional_fields` | `story_points` key / text in description |
| Issue type change | `fields: '{"issuetype": {"name": "Epic"}}'` | — |
| Reassign parent | `fields: '{"parent": {"key": "PROJ-XX"}}'` | — |
| Dependency link | Link type `"Blocks"` via `jira_create_issue_link` | Text in description |
