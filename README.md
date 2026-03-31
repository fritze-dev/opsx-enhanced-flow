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
# 1. Set up OpenSpec in your project (one-time)
/opsx:setup                     # Installs schema, config, and skills into the project
# → Restart your IDE for skills to take effect

# 2. Bootstrap your project (one-time)
/opsx:bootstrap                 # AI scans your codebase → generates project rules + initial specs
# → You review what the AI found

# 3. Build a feature (repeat for each feature)
/opsx:new feature-x             # Create a workspace for the new feature
/opsx:ff                        # AI generates planning artifacts (specs edited directly), pauses for review after design, then generates pre-flight + tasks
# → You review specs + design, confirm alignment
/opsx:apply                     # AI implements according to the plan
# → You test the result
/opsx:verify                    # Automated checks → you confirm "Approved"
/opsx:changelog                 # Generate release notes
/opsx:docs                      # Generate user documentation

# Optional: For complex features, run discovery first
/opsx:new feature-y             # Create workspace
/opsx:discover                  # AI researches + asks you clarifying questions
# → You answer the questions
/opsx:ff                        # AI generates remaining artifacts based on your answers
# → ...continue as above
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
- [Skills](#skills)
- [Setup](#setup)
- [Roadmap](#roadmap)

---

### Quality Gems

Quality practices baked into the workflow. Each "gem" is a specific artifact or check that ensures quality at a different stage. The gems are extensible — new ones can be added as the workflow evolves.

| Gem | Stored In | Purpose |
|-----|-----------|---------|
| **Constitution** | `CONSTITUTION.md` | Living project rules (tech stack, architecture, conventions) — created by bootstrap, auto-updated when features introduce changes, validated in pre-flight. |
| **Discovery** | `research.md` | Research documentation & targeted clarification questions — prevents the AI from making assumptions or hallucinating solutions. |
| **Intent Contract** | `proposal.md` | Captures why a change is needed and which capabilities it affects — creates the binding contract between planning and spec phases. Each capability maps to a spec file. |
| **BDD / Gherkin** | `spec.md` | Normative requirements (SHALL/MUST) with structured Gherkin scenarios (Given/When/Then) and optional user stories — makes expected behavior precise and directly testable. |
| **Success Metrics** | `design.md` | Hard, measurable success criteria — verified as PASS/FAIL in the QA loop before proceeding. |
| **Pre-Flight Check** | `preflight.md` | Quality review before implementation: traceability, gap analysis, side effects, duplication & consistency checks, assumption audit. |
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
| `tasks.md` — QA Loop | **Implementation completeness** — all planned work is executed and tested | Explicit "Approved" gate — no silent completion without human sign-off |

Because these criteria live inside the artifacts — not in a separate checklist — they can't drift out of sync with the actual work. When the spec changes, the DoD changes with it.

**Why this matters for multi-agent workflows:** Autonomous agents need unambiguous termination criteria. Vague definitions like "feature works correctly" cause agents to either loop forever or stop too early. Structured artifacts solve this — Gherkin scenarios are parseable, success metrics are measurable, and preflight findings are enumerable. An agent can programmatically verify "all 12 scenarios pass, 3/3 metrics met, 0 unresolved findings" and know with certainty that the work is done.

---

### Three-Layer Architecture

The system separates concerns into three layers: **CONSTITUTION.md** (project rules — the "How"), **WORKFLOW.md + Smart Templates** (artifact pipeline — the "What/When"), and **Skills** (user commands — the "How to interact"). This separation ensures the AI always has access to project rules during implementation, not just during planning. See [docs/README.md](docs/README.md) for a detailed breakdown.

---

### Workflow

**Prerequisite:** Run `/opsx:setup` once per project to install the schema and configure OpenSpec.

#### Workflow Principles

These design principles are enforced across the three-layer architecture — each rule lives at its authoritative source (schema, constitution, or skills) rather than being duplicated:

- **User Stories encouraged** — Requirements SHOULD include User Stories to capture intent and user value. Stories are the bridge between stakeholders and engineers. Omit for purely technical or non-functional requirements. *(Schema: spec template)*
- **Gherkin mandatory** — Strict Given/When/Then scenarios make behavior unambiguous and directly testable. No "the system should work well" hand-waving. *(Schema: spec template)*
- **Preflight mandatory** — The pre-flight check catches gaps, side effects, and inconsistencies before implementation begins. Skipping it means discovering problems during coding. *(Schema: artifact dependency chain)*
- **No silent completion** — The AI must wait for explicit "Approved" because only a human can verify that the implementation actually works as intended. This prevents premature completion. *(Skill: verify)*
- **Constitution always loaded** — The constitution defines project-wide rules that must inform every AI action — not just artifact generation but also implementation and verification. *(Config: context pointer)*
- **Verify findings are binding** — All critical/warning issues from verification must be resolved (code fix or spec update) before proceeding. Findings are not optional suggestions. *(Skill: verify)*
- **Bidirectional feedback** — When implementation reveals new edge cases or design flaws, specs and design are updated (not just the code). The QA fix loop is the enforcement point. *(Schema: tasks template)*
- **Definition of Done is emergent** — Gherkin scenarios define functional completeness, success metrics define quality targets, preflight findings define risk resolution, and explicit approval gates implementation completeness. No separate DoD checklist needed. *(Schema: tasks instruction)*
- **Design review mandatory** — The design phase is the mandatory review checkpoint in every workflow. `/opsx:ff` pauses after design for user alignment before generating preflight and tasks. This ensures the human reviews approach and architecture before the system proceeds to quality checks and implementation planning. *(Constitution: convention)*

#### Bootstrap

| Step | Command | What Happens |
|------|---------|--------------|
| 1. Setup | `/opsx:setup` | Installs workflow + templates into the project. |
| 2. Bootstrap | `/opsx:bootstrap` | Scans codebase → generates `CONSTITUTION.md` + initial specs. |
| 3. Review | *Manual* | Review constitution and generated specs for correctness. |
| 4. Docs | `/opsx:changelog` + `/opsx:docs` | Generate initial documentation. |

#### Feature Cycle

| Step | Command | What Happens |
|------|---------|--------------|
| 1. Plan | `/opsx:new feature-x` + `/opsx:ff` | Create workspace, generate planning artifacts (research through design). ff pauses for review. |
| 2. Review | *Manual* | Review specs + design, confirm alignment. ff continues with pre-flight + tasks. |
| 3. Execute | `/opsx:apply` | AI implements according to `tasks.md`, stops at QA gate. |
| 4. QA | *Manual + `/opsx:verify`* | User tests → Fix Loop → explicit "Approved". |
| 5. Docs | `/opsx:changelog` + `/opsx:docs` | Generate release notes & user documentation. |

#### Discovery Step (Optional)

For complex features, run discovery separately before fast-forward:

1. `/opsx:discover` → generates only `research.md`, stops for Q&A
2. User answers open questions
3. `/opsx:ff` → generates remaining artifacts based on research + answers

**When to use discover:** 3+ coverage categories are Partial/Missing, external APIs involved, architectural impact unclear, or multiple viable approaches need trade-off analysis.

**When to skip:** All categories are Clear, the feature is well-understood, or it's a small change with obvious implementation.

#### Recovery Path

When code changes happen outside the spec process (hotfixes, dependency updates, external contributions):

- **Small drift:** `/opsx:new hotfix-xyz` → `/opsx:ff` → derive specs from existing code → `/opsx:changelog` → `/opsx:docs`
- **Large drift:** Re-run `/opsx:bootstrap` — it detects existing specs and runs in recovery mode (drift detection + consistency passes)

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
│   ├── skills/                            # All plugin skills
│   │   ├── new/SKILL.md                   # Start a new change
│   │   ├── ff/SKILL.md                    # Fast-forward all artifacts
│   │   ├── apply/SKILL.md                 # Implement tasks
│   │   ├── verify/SKILL.md               # Verify implementation
│   │   ├── docs-verify/SKILL.md            # Verify docs vs specs
│   │   ├── setup/SKILL.md                 # Install workflow + templates
│   │   ├── bootstrap/SKILL.md             # Codebase scan → constitution + specs
│   │   ├── discover/SKILL.md              # Interactive research with Q&A
│   │   ├── preflight/SKILL.md             # Standalone quality check
│   │   ├── changelog/SKILL.md             # Generate release notes
│   │   └── docs/SKILL.md                  # Generate user documentation
│   └── templates/                         # Smart Templates (copied by /opsx:setup)
│       ├── research.md                    # Research artifact template
│       ├── proposal.md                    # Proposal artifact template
│       ├── design.md                      # Design artifact template
│       ├── preflight.md                   # Pre-flight check template
│       ├── tasks.md                       # Implementation tasks template
│       ├── constitution.md                # Constitution scaffold template
│       ├── specs/spec.md                  # Spec template
│       └── docs/                          # Documentation output templates
│
├── openspec/                              # Project's own OpenSpec (dogfooding)
│   ├── WORKFLOW.md                        # Pipeline orchestration
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

### Target Project Structure (after setup)

```
your-project/
├── openspec/
│   ├── WORKFLOW.md                        # Pipeline orchestration (generated by /opsx:setup)
│   ├── CONSTITUTION.md                    # Project rules (generated by /opsx:bootstrap)
│   ├── templates/                         # Smart Templates (copied by /opsx:setup)
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

> **Change naming:** Change workspaces use the format `YYYY-MM-DD-<feature-name>/` — date-prefixed at creation. The `/opsx:changelog` skill relies on this date prefix for chronological ordering.

---

### Reference Files

| File | Purpose |
|------|---------|
| [WORKFLOW.md](openspec/WORKFLOW.md) | Pipeline orchestration: artifact order, apply gate, post-artifact hook, context pointer |
| [CONSTITUTION.md](openspec/CONSTITUTION.md) | Living project rules (created by bootstrap, auto-updated in design step) |
| [templates/](openspec/templates/) | Smart Templates with YAML frontmatter (instruction, generates, requires) + output structure |

---

### Skills

All 10 skills are available as `/opsx:*` commands when the plugin is installed. See [docs/README.md](docs/README.md) for detailed capability documentation.

| Command | Purpose |
|---------|---------|
| `/opsx:setup` | Install workflow + templates into project (one-time setup) |
| `/opsx:bootstrap` | Full codebase scan → constitution + initial specs |
| `/opsx:new` | Create a new change workspace (date-prefixed, with lazy worktree cleanup) |
| `/opsx:discover` | Interactive research with Q&A for complex features |
| `/opsx:ff` | Generate all remaining artifacts, edit specs directly (pauses at design review + preflight warnings) |
| `/opsx:apply` | Implement according to `tasks.md` |
| `/opsx:verify` | Automated verification checks |
| `/opsx:preflight` | Standalone pre-flight quality check |
| `/opsx:changelog` | Generate release notes from completed changes |
| `/opsx:docs` | Generate user documentation from specs |

---

### Setup

#### Claude Code Plugin

```bash
# Add the marketplace (one-time)
claude plugin marketplace add fritze-dev/opsx-enhanced-flow

# Install the plugin
claude plugin install opsx@opsx-enhanced-flow
```

After installing the plugin, run `/opsx:setup` in your project to install the workflow and templates. Then run `/opsx:bootstrap` to scan your codebase and generate the constitution + initial specs.


#### Updating the Plugin

Patch versions are bumped automatically during the post-apply workflow. To update as a consumer:

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

> **Versioning:** Patch versions auto-increment during the post-apply workflow. A GitHub Action automatically creates a git tag and GitHub Release when the version change is pushed to `main`. For minor/major releases, manually set the version and push — the Action handles the rest.

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
