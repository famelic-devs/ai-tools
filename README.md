# 🤖 ai-tools

A shared toolkit of AI-powered tools, sub-agents, and skills for the **famelic-devs** organization.

## Purpose

This repository centralizes all AI tooling available to developers in the organization. The goal is to make it easy to adopt AI assistants that automate repetitive tasks, improve code quality, and accelerate development workflows.

Each tool or sub-agent lives in its own directory with clear documentation on what it does and how to use it.

## What's Inside (and What's Coming)

| Tool | Description | Status |
|------|-------------|--------|
| `code-reviewer` | Sub-agent that reviews PRs and enforces coding standards (e.g. Conventional Commits) | 🚧 Planned |
| `planner` | Sub-agent that helps break down features into Jira tickets and GitHub issues | 🚧 Planned |
| `test-writer` | Sub-agent that generates unit and integration tests for existing code | 🚧 Planned |
| `test-runner` | Sub-agent that executes tests and reports results | 🚧 Planned |
| `meeting-summarizer` | Sub-agent that processes meeting transcripts into action items and Jira tickets | 🚧 Planned |

## Skills

Reusable instruction sets injected into sub-agents at runtime.

| Skill | Description |
|-------|-------------|
| `planning-conventions` | Agile planning rules: story sizing, Epic definition, Jira field conventions, backlog refinement checklist |

## Getting Started

Each tool directory contains its own `README.md` with specific setup instructions.

To install all available tools on your machine, run the setup script:

```bash
./install.sh
```

> The install script will guide you through setting up each tool and its dependencies on your local environment.

## Standards

All code in this repository follows:

- **[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)** for commit messages and PR titles
- Tool configurations stored in `.env` files (never committed — see `.gitignore`)

## Contributing

1. Propose a new tool by opening an issue with the `tool-proposal` label
2. Discuss scope and design with the team
3. Create the tool directory following the existing structure
4. Submit a PR — the `code-reviewer` agent will validate it 🤖

## Organization

```
ai-tools/
├── README.md
├── install.sh
├── code-reviewer/
│   ├── README.md
│   └── ...
├── planner/
│   ├── README.md
│   └── ...
├── skills/
│   └── planning-conventions/
│       └── SKILL.md
└── ...
```

---

*Maintained by [FamelicBot](https://github.com/famelic-devs) on behalf of the famelic-devs team.*
