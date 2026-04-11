# OPSX Enhanced Flow

Your AI coding tool writes the code — this workflow makes sure it writes the documentation too.

---

## The Problem

AI coding tools like Claude Code, Cursor, or Copilot build features fast — but they leave nothing behind. No specs, no architecture decisions, no changelogs, no user docs. After a few weeks of AI-assisted development, you have a working product and zero documentation. New team members can't onboard, past decisions are lost, nobody knows why things were built the way they are, and without acceptance criteria there's no way to tell if a feature is actually finished.

## The Solution

OPSX Enhanced Flow turns your AI tool into a documenting machine. Every feature automatically produces:

- **Research notes** — what was investigated, what alternatives were considered
- **Specifications** — what the feature does, described in precise, testable scenarios
- **Architecture decisions** — how it's built and why, including success metrics
- **Quality checks** — gaps, side effects, and risks caught before a single line of code is written
- **Changelogs & user docs** — generated automatically after each feature ships

The AI follows a structured process (research, plan, review, build, QA, document) and a human stays in control at every stage. The result: your project stays documented from day one. The structured artifacts also produce better, more reliable code. And because they're verifiable, the documentation naturally doubles as your Definition of Done: you always know when a feature is truly complete.

```
Research → Plan → Review → Build → QA → Document
```

**Inspired by:** [OpenSpec](https://github.com/Fission-AI/OpenSpec) (a spec management framework) and [Spec-Kit](https://github.com/github/spec-kit) (GitHub's specification methodology).

---

## Core Principles

| # | Principle | What it means |
|---|-----------|---------------|
| 1 | **Living Documentation** | Docs, specs, and changelogs grow automatically as features are built — no separate documentation effort. |
| 2 | **Intent-Driven Development** | Every artifact captures the "why" (intent), not just the "what" — so future readers understand past decisions. |
| 3 | **Human-in-the-Loop** | A human reviews artifacts and tests the result before anything gets finalized. No blind automation. |
| 4 | **Product-Centricity** | Requirements use normative descriptions (SHALL/MUST) with optional user stories to capture intent — combining precision with plain-language motivation. |
| 5 | **Engineering Rigor** | Implementation follows structured test scenarios (Given/When/Then) so behavior is unambiguous and testable. |
| 6 | **Continuous Refinement** | Specs evolve iteratively. Small updates over full rewrites. |
| 7 | **Bidirectional Feedback** | Implementation insights feed back into specs. Code informs spec updates. |
| 8 | **Definition of Done (DoD)** | Structured artifacts double as acceptance criteria — Gherkin scenarios define when behavior is complete, success metrics define when quality is met, and preflight findings define what must be resolved. No separate DoD process needed. |

---

## Quick Start

### Install the Plugin

```bash
# 1. Add the marketplace (one-time)
claude plugin marketplace add fritze-dev/opsx-enhanced-flow

# 2. Install the plugin
claude plugin install opsx@opsx-enhanced-flow
```

Or use the chat slash commands: `/plugin marketplace add` and `/plugin install`.

### Use the Workflow

```bash
# 1. Initialize project (one-time)
/opsx:workflow init              # Installs schema, config, templates; scans codebase → constitution + specs

# 2. Build a feature (repeat for each feature)
/opsx:workflow propose feature-x # Create workspace + generate artifacts (research → specs → design → preflight → tasks), pauses for review
# → You review specs + design, confirm alignment
/opsx:workflow apply             # AI implements according to the plan + generates review.md
# → You test the result, approve
/opsx:workflow finalize          # Changelog + docs + version bump
```

---

## Detailed Documentation

For full documentation — architecture overview, capability docs, and architecture decision records — see [docs/README.md](docs/README.md).

The sections below cover workflow mechanics, configuration, and project structure.

### Table of Contents

- [Quality Gems](#quality-gems)
- [Definition of Done](#definition-of-done)
- [Three-Layer Architecture](#three-layer-architecture)
- [Workflow](#workflow)
- [Plugin Structure](#plugin-structure)
- [Target Project Structure](#target-project-structure)
- [Reference Files](#reference-files)
- [Commands](#commands)
- [Setup](#setup)
- [Roadmap](#roadmap)

---

### Quality Gems

Quality practices baked into the workflow. Each "gem" is a specific artifact or check that ensures quality at a different stage. The gems are extensible — new ones can be added as the workflow evolves.

| Gem | Stored In | Purpose |
|-----|-----------|---------|
| **Constitution** | `CONSTITUTION.md` | Living project rules (tech stack, architecture, conventions) — created by init, auto-updated when features introduce changes, validated in pre-flight. |
| **Discovery** | `research.md` | Research documentation & targeted clarification questions — prevents the AI from making assumptions or hallucinating solutions. |
| **Intent Contract** | `proposal.md` | Captures why a change is needed and which capabilities it affects — creates the binding contract between planning and spec phases. Each capability maps to a spec file. |
| **BDD / Gherkin** | `spec.md` | Normative requirements (SHALL/MUST) with structured Gherkin scenarios (Given/When/Then) and optional user stories — makes expected behavior precise and directly testable. |
| **Success Metrics** | `design.md` | Hard, measurable success criteria — verified as PASS/FAIL in the QA loop before proceeding. |
| **Pre-Flight Check** | `preflight.md` | Quality review before implementation: traceability, gap analysis, side effects, duplication & consistency checks, assumption audit. |
| **Review** | `review.md` | PR-visible verification artifact generated after implementation — replaces transient verify checks with a persistent, non-skippable review record. |
| **Changelog** | `CHANGELOG.md` | Auto-generated release notes from completed changes — tracks what changed, when, and why. Follows [Keep a Changelog](https://keepachangelog.com/) format. |
| **User Docs** | `docs/capabilities/*.md` | Auto-generated end-user documentation from merged specs — always reflects the full current state of the project. |
| **Decision Records** | `docs/decisions/adr-*.md` | Auto-generated Architecture Decision Records from completed changes' design decisions — preserves the "why" behind every architectural choice. |
| **Architecture Overview** | `docs/README.md` | Auto-generated consolidated documentation entry point — architecture, tech stack, key design decisions, and capability index. |

---

### Definition of Done

Because every artifact is structured and verifiable, the documentation naturally doubles as a Definition of Done (DoD). Most teams maintain their DoD as a separate checklist that's easy to forget or ignore. Here, the **documentation artifacts themselves are the DoD** — no extra process needed.

Every artifact in the pipeline carries built-in completion criteria in a structured, verifiable format:

| Artifact | DoD Aspect | How It's Verified |
|----------|-----------|-------------------|
| `spec.md` — Gherkin Scenarios | **Functional completeness** — behavior is done when all scenarios pass | Each scenario is a discrete Given/When/Then check — pass or fail, no ambiguity |
| `design.md` — Success Metrics | **Quality targets** — the feature meets its measurable goals | Each metric has a concrete threshold — verified as PASS/FAIL during QA |
| `preflight.md` — Findings | **Risk resolution** — all identified gaps and side effects are addressed | Each finding is a checklist item — "Verify findings are binding" means unresolved items block the workflow |
| `review.md` — Verification | **Implementation completeness** — all planned work is executed and verified | PR-visible artifact with explicit approval gate — no silent completion without human sign-off |

Because these criteria live inside the artifacts — not in a separate checklist — they can't drift out of sync with the actual work. When the spec changes, the DoD changes with it.

**Why this matters for multi-agent workflows:** Autonomous agents need unambiguous termination criteria. Vague definitions like "feature works correctly" cause agents to either loop forever or stop too early. Structured artifacts solve this — Gherkin scenarios are parseable, success metrics are measurable, and preflight findings are enumerable. An agent can programmatically verify "all 12 scenarios pass, 3/3 metrics met, 0 unresolved findings" and know with certainty that the work is done.

---

### Three-Layer Architecture

The system separates concerns into three layers: **CONSTITUTION.md** (project rules — the "How"), **WORKFLOW.md + Smart Templates** (artifact pipeline — the "What/When"), and **Router + Actions (4 commands)** (user interaction — the "How to interact"). A single SKILL.md file routes all commands, with `## Action: <name>` sections in WORKFLOW.md defining each action's behavior. This separation ensures the AI always has access to project rules during implementation, not just during planning. See [docs/README.md](docs/README.md) for a detailed breakdown.

---

### Workflow

**Prerequisite:** Run `/opsx:workflow init` once per project to install the schema, templates, and generate the constitution + initial specs.

#### Workflow Principles

These design principles are enforced across the three-layer architecture — each rule lives at its authoritative source (schema, constitution, or workflow actions) rather than being duplicated:

- **User Stories encouraged** — Requirements SHOULD include User Stories to capture intent and user value. Stories are the bridge between stakeholders and engineers. Omit for purely technical or non-functional requirements. *(Schema: spec template)*
- **Gherkin mandatory** — Strict Given/When/Then scenarios make behavior unambiguous and directly testable. No "the system should work well" hand-waving. *(Schema: spec template)*
- **Preflight mandatory** — The pre-flight check catches gaps, side effects, and inconsistencies before implementation begins. Skipping it means discovering problems during coding. *(Schema: artifact dependency chain)*
- **No silent completion** — The AI must wait for explicit "Approved" because only a human can verify that the implementation actually works as intended. This prevents premature completion. *(Action: apply → review.md)*
- **Constitution always loaded** — The constitution defines project-wide rules that must inform every AI action — not just artifact generation but also implementation and verification. *(Config: context pointer)*
- **Review is persistent** — The `review.md` artifact is committed to the change workspace and visible in PRs. Unlike transient verification, it cannot be skipped or lost. *(Action: apply)*
- **Bidirectional feedback** — When implementation reveals new edge cases or design flaws, specs and design are updated (not just the code). The QA fix loop is the enforcement point. *(Schema: tasks template)*
- **Definition of Done is emergent** — Gherkin scenarios define functional completeness, success metrics define quality targets, preflight findings define risk resolution, and explicit approval gates implementation completeness. No separate DoD checklist needed. *(Schema: tasks instruction)*
- **Design review mandatory** — The design phase is the mandatory review checkpoint in every workflow. `propose` pauses after design for user alignment before generating preflight and tasks. This ensures the human reviews approach and architecture before the system proceeds to quality checks and implementation planning. *(Constitution: convention)*

#### Bootstrap

| Step | Command | What Happens |
|------|---------|--------------|
| 1. Init | `/opsx:workflow init` | Installs workflow + templates, scans codebase → generates `CONSTITUTION.md` + initial specs. |
| 2. Review | *Manual* | Review constitution and generated specs for correctness. |
| 3. Docs | `/opsx:workflow finalize` | Generate initial changelog + documentation. |

#### Feature Cycle

| Step | Command | What Happens |
|------|---------|--------------|
| 1. Plan | `/opsx:workflow propose feature-x` | Create workspace, generate 7-stage pipeline artifacts (research → proposal → specs → design → preflight → tasks). Pauses for review. |
| 2. Review | *Manual* | Review specs + design, confirm alignment. |
| 3. Execute | `/opsx:workflow apply` | AI implements according to `tasks.md`, generates `review.md`. |
| 4. QA | *Manual* | User tests → approves (review.md is PR-visible). |
| 5. Finalize | `/opsx:workflow finalize` | Changelog + docs + version bump. |

#### Recovery Path

When code changes happen outside the spec process (hotfixes, dependency updates, external contributions):

- **Small drift:** `/opsx:workflow propose hotfix-xyz` → derive specs from existing code → `/opsx:workflow finalize`
- **Large drift:** Re-run `/opsx:workflow init` — it detects existing specs and runs in recovery mode (drift detection + consistency passes)

> The spec process assumes specs come before code. When reality diverges, use these paths to re-sync.

---

### Plugin Structure

This repo contains both the Claude Code plugin source (in `src/`) and the project management files. Consumer plugin caches contain only the `src/` directory — docs, CI, and OpenSpec project files are not downloaded.

```
opsx-enhanced-flow/
├── .claude-plugin/
│   └── marketplace.json                   # Marketplace definition (source: "./src")
│
├── src/                                   # Plugin source (what consumers get)
│   ├── .claude-plugin/
│   │   └── plugin.json                    # Plugin manifest (name: "opsx")
│   ├── skills/                            # Single skill with action routing
│   │   └── workflow/SKILL.md              # Router: dispatches to WORKFLOW.md actions
│   └── templates/                         # Smart Templates (copied by /opsx:workflow init)
│       ├── research.md                    # Research artifact template
│       ├── proposal.md                    # Proposal artifact template
│       ├── design.md                      # Design artifact template
│       ├── preflight.md                   # Pre-flight check template
│       ├── tasks.md                       # Implementation tasks template
│       ├── review.md                      # Review artifact template
│       ├── constitution.md                # Constitution scaffold template
│       ├── specs/spec.md                  # Spec template
│       └── docs/                          # Documentation output templates
│
├── openspec/                              # Project's own OpenSpec (dogfooding)
│   ├── WORKFLOW.md                        # Pipeline orchestration + action definitions
│   ├── CONSTITUTION.md                    # Project constitution
│   ├── templates/                         # Project's copy of Smart Templates
│   ├── specs/                             # Specs (one per capability, edited directly)
│   └── changes/                           # Feature workspaces (YYYY-MM-DD-<name>/)
│
├── .github/workflows/                     # CI/CD
│   ├── release.yml                        # Auto tag + release on version change
│   ├── claude.yml                         # @claude mention handler
│   └── claude-code-review.yml             # Auto code review on PRs
│
└── README.md                              # This file
```

### Target Project Structure (after init)

```
your-project/
├── openspec/
│   ├── WORKFLOW.md                        # Pipeline orchestration + actions (generated by init)
│   ├── CONSTITUTION.md                    # Project rules (generated by init)
│   ├── templates/                         # Smart Templates (copied by init)
│   ├── specs/                             # Specs (edited directly during specs stage)
│   └── changes/                           # Feature workspaces
│       └── YYYY-MM-DD-<feature-name>/     # Date-prefixed at creation
│
├── docs/                                  # End-user documentation (auto-generated)
│   ├── README.md                          # Architecture overview + capabilities + ADR index
│   ├── capabilities/
│   │   └── <capability>.md                # One document per capability
│   └── decisions/
│       └── adr-NNN-<slug>.md              # Architecture Decision Records
├── CHANGELOG.md                           # Project history (auto-generated)
└── ...
```

> **Change naming:** Change workspaces use the format `YYYY-MM-DD-<feature-name>/` — date-prefixed at creation. The `finalize` action relies on this date prefix for chronological ordering.

---

### Reference Files

| File | Purpose |
|------|---------|
| [WORKFLOW.md](openspec/WORKFLOW.md) | Pipeline orchestration: artifact order, apply gate, context pointer, and `## Action: <name>` sections with inline `### Instruction` blocks |
| [CONSTITUTION.md](openspec/CONSTITUTION.md) | Living project rules (created by init, auto-updated in design step) |
| [templates/](openspec/templates/) | Smart Templates with YAML frontmatter (instruction, generates, requires) + output structure |

---

### Commands

All 4 commands are available via `/opsx:workflow <action>` when the plugin is installed. A single `src/skills/workflow/SKILL.md` routes to the appropriate action defined in WORKFLOW.md. See [docs/README.md](docs/README.md) for detailed capability documentation.

| Command | Purpose |
|---------|---------|
| `/opsx:workflow init` | Initialize project or run health check (replaces setup + bootstrap) |
| `/opsx:workflow propose` | Create change workspace + generate 7-stage artifacts (replaces new + discover + ff) |
| `/opsx:workflow apply` | Implement tasks + generate review.md (replaces apply + verify) |
| `/opsx:workflow finalize` | Changelog + docs + version bump (replaces changelog + docs) |

---

### Setup

#### Claude Code Plugin

```bash
# Add the marketplace (one-time)
claude plugin marketplace add fritze-dev/opsx-enhanced-flow

# Install the plugin
claude plugin install opsx@opsx-enhanced-flow
```

After installing the plugin, run `/opsx:workflow init` in your project to install the workflow, templates, and generate the constitution + initial specs.

#### Claude Code Web

The plugin works in [Claude Code Web](https://claude.ai/code) (cloud sessions):

- **Plugin auto-installs** via `.claude/settings.json` — declares the marketplace and enables the plugin declaratively at session start.
- **Git operations work automatically** — Claude Code Web provides a GitHub Proxy, so `git push`, `git pull`, and branch operations work out of the box.

**Optional: `gh` CLI for full GitHub integration**

The `gh` CLI is not pre-installed in cloud sessions. Without it, the plugin skips draft PR creation gracefully. To enable `gh pr create`, `gh issue create`, and `gh release`, configure your [Claude Code Web environment](https://claude.ai/settings/code):

1. **Setup script** — add to your environment settings:
   ```bash
   apt update && apt install -y gh
   ```
2. **Environment variable** — add `GH_TOKEN` with a GitHub personal access token. The `gh` CLI reads it automatically.

> For consumer projects, copy `.claude/settings.json` from this repo and update the marketplace `repo` field if needed. Make sure `.gitignore` does not block `.claude/settings.json` (use `/.claude/*` with `!/.claude/settings.json`).

#### Updating the Plugin

Patch versions are bumped automatically during the finalize action. To update as a consumer:

```bash
# 1. Refresh the marketplace listing
claude plugin marketplace update opsx-enhanced-flow

# 2. Update the plugin
claude plugin update opsx@opsx-enhanced-flow

# 3. Restart Claude Code for changes to take effect
```

If the update isn't detected, uninstall and reinstall as fallback:

```bash
claude plugin uninstall opsx@opsx-enhanced-flow
claude plugin install opsx@opsx-enhanced-flow
```

> **Versioning:** Patch versions auto-increment during the finalize action. A GitHub Action automatically creates a git tag and GitHub Release when the version change is pushed to `main`. For minor/major releases, manually set the version and push — the Action handles the rest.

> **Version pinning:** To pin to a specific version, add the marketplace with a tag reference:
> ```bash
> claude plugin marketplace add fritze-dev/opsx-enhanced-flow#v1.0.30
> ```

#### Development & Testing

**Local marketplace (recommended, works in VS Code and CLI):**

```bash
# One-time: register local repo as marketplace
claude plugin marketplace add /path/to/opsx-enhanced-flow --scope user

# Install the plugin
claude plugin install opsx@opsx-enhanced-flow
```

Skill changes (SKILL.md edits) reload instantly via `/reload-plugins`.
After version changes in `src/.claude-plugin/plugin.json`, run `claude plugin update opsx@opsx-enhanced-flow`.

**CLI alternative (terminal only, does not work in VS Code extension):**

```bash
claude --plugin-dir src
```

---

### Roadmap

Planned improvements are tracked as [GitHub Issues](https://github.com/fritze-dev/opsx-enhanced-flow/issues?q=is:issue+label:roadmap).

---

## Credits

Built on [OpenSpec](https://github.com/Fission-AI/OpenSpec) (a spec management framework for AI-assisted development) and inspired by [Spec-Kit](https://github.com/github/spec-kit) (GitHub's methodology for writing rigorous software specifications).
