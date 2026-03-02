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

**Built on:** [OpenSpec](https://github.com/Fission-AI/OpenSpec) (a spec management framework) and inspired by [Spec-Kit](https://github.com/github/spec-kit) (GitHub's specification methodology).

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
/plugin marketplace add fritze-dev/opsx-enhanced-flow

# 2. Install the plugin
/plugin install opsx@opsx-enhanced-flow
```

**Prerequisite:** OpenSpec CLI must be installed (`npm install -g @fission-ai/openspec`).

### Use the Workflow

```bash
# 1. Set up OpenSpec in your project (one-time)
/opsx:init                     # Installs schema, config, and skills into the project
# → Restart your IDE for skills to take effect

# 2. Bootstrap your project (one-time)
/opsx:bootstrap                 # AI scans your codebase → generates project rules + initial specs
# → You review what the AI found

# 3. Archive the baseline
/opsx:archive                   # Saves initial specs as your project's baseline

# 4. Build a feature (repeat for each feature)
/opsx:new feature-x             # Create a workspace for the new feature
/opsx:ff                        # AI generates all planning artifacts (research, proposal, specs, design, pre-flight, tasks)
# → You review the plan
/opsx:apply                     # AI implements according to the plan
# → You test the result
/opsx:verify                    # Automated checks → you confirm "Approved"
/opsx:archive                   # Specs get merged, workspace gets archived
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

The sections below dive deeper into the architecture, workflow mechanics, and configuration details.

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
| **Constitution** | `constitution.md` | Living project rules (tech stack, architecture, conventions) — created by bootstrap, auto-updated when features introduce changes, validated in pre-flight. |
| **Discovery** | `research.md` | Research documentation & targeted clarification questions — prevents the AI from making assumptions or hallucinating solutions. |
| **Intent Contract** | `proposal.md` | Captures why a change is needed and which capabilities it affects — creates the binding contract between planning and spec phases. Each capability maps to a spec file. |
| **BDD / Gherkin** | `spec.md` | Normative requirements (SHALL/MUST) with structured Gherkin scenarios (Given/When/Then) and optional user stories — makes expected behavior precise and directly testable. |
| **Success Metrics** | `design.md` | Hard, measurable success criteria — verified as PASS/FAIL in the QA loop before archiving. |
| **Pre-Flight Check** | `preflight.md` | Quality review before implementation: traceability, gap analysis, side effects, duplication & consistency checks, assumption audit. |
| **Changelog** | `CHANGELOG.md` | Auto-generated release notes from archived specs — tracks what changed, when, and why. Follows [Keep a Changelog](https://keepachangelog.com/) format. |
| **User Docs** | `docs/capabilities/*.md` | Auto-generated end-user documentation from merged specs — always reflects the full current state of the project. |

---

### Definition of Done

Because every artifact is structured and verifiable, the documentation naturally doubles as a Definition of Done (DoD). Most teams maintain their DoD as a separate checklist that's easy to forget or ignore. Here, the **documentation artifacts themselves are the DoD** — no extra process needed.

Every artifact in the pipeline carries built-in completion criteria in a structured, verifiable format:

| Artifact | DoD Aspect | How It's Verified |
|----------|-----------|-------------------|
| `spec.md` — Gherkin Scenarios | **Functional completeness** — behavior is done when all scenarios pass | Each scenario is a discrete Given/When/Then check — pass or fail, no ambiguity |
| `design.md` — Success Metrics | **Quality targets** — the feature meets its measurable goals | Each metric has a concrete threshold — verified as PASS/FAIL during QA |
| `preflight.md` — Findings | **Risk resolution** — all identified gaps and side effects are addressed | Each finding is a checklist item — "Verify findings are binding" means unresolved items block archiving |
| `tasks.md` — QA Loop | **Implementation completeness** — all planned work is executed and tested | Explicit "Approved" gate — no silent archiving without human sign-off |

Because these criteria live inside the artifacts — not in a separate checklist — they can't drift out of sync with the actual work. When the spec changes, the DoD changes with it.

**Why this matters for multi-agent workflows:** Autonomous agents need unambiguous termination criteria. Vague definitions like "feature works correctly" cause agents to either loop forever or stop too early. Structured artifacts solve this — Gherkin scenarios are parseable, success metrics are measurable, and preflight findings are enumerable. An agent can programmatically verify "all 12 scenarios pass, 3/3 metrics met, 0 unresolved findings" and know with certainty that the work is done.

---

### Three-Layer Architecture

The system consists of three strictly separated layers:

| Layer | Files | Responsibility |
|-------|-------|----------------|
| **Constitution** | `openspec/constitution.md` | Global project rules (tech stack, code style, architecture). Created by bootstrap, auto-updated in the design step when features introduce changes. Referenced by every AI prompt via config. Defines the **"How"**. |
| **Schema** | `openspec/schemas/opsx-enhanced/schema.yaml` | Defines the process: which artifacts are generated in which order. Defines the **"What"** and **"When"**. |
| **Skills** | `skills/*/SKILL.md` | All 12 user-facing commands: workflow skills drive the artifact pipeline (new, continue, ff, apply, verify, archive), supporting skills handle setup, discovery, governance, and documentation (init, bootstrap, discover, preflight, changelog, docs). Defines the **"How to interact"**. |

> **Why separated?** If the constitution lives in the schema, the AI loses the rules during coding (`/opsx:apply`), because the schema only controls artifact generation. The constitution is referenced in the `config.yaml` workflow rules, instructing AI to read and follow it at every step.

---

### Workflow

**Prerequisite:** Run `/opsx:init` once per project to install the schema and configure OpenSpec.

#### Commands Overview

| Command | Description |
|---------|-------------|
| **Workflow** | |
| `/opsx:new` | Create a new change workspace. |
| `/opsx:continue` | Generate the next missing artifact and stop. |
| `/opsx:ff` | Generate all remaining artifacts in one pass. |
| `/opsx:apply` | Implement according to `tasks.md`. |
| `/opsx:verify` | Automated verification checks. |
| `/opsx:archive` | Merge specs & archive workspace. |
| **Setup & Discovery** | |
| `/opsx:init` | Install OpenSpec + schema into project. |
| `/opsx:bootstrap` | Full codebase scan → constitution + initial specs. |
| `/opsx:discover` | Research + interactive Q&A → `research.md`. |
| `/opsx:preflight` | Standalone pre-flight quality check. |
| **Documentation** | |
| `/opsx:changelog` | Generate release notes from archived specs. |
| `/opsx:docs` | Generate user documentation. |

#### Workflow Principles

The rules in `config.yaml` encode these design decisions:

- **User Stories encouraged** — Requirements SHOULD include User Stories to capture intent and user value. Stories are the bridge between stakeholders and engineers. Omit for purely technical or non-functional requirements.
- **Gherkin mandatory** — Strict Given/When/Then scenarios make behavior unambiguous and directly testable. No "the system should work well" hand-waving.
- **Preflight mandatory** — The pre-flight check catches gaps, side effects, and inconsistencies before implementation begins. Skipping it means discovering problems during coding.
- **No silent archiving** — The AI must wait for explicit "Approved" because only a human can verify that the implementation actually works as intended. This prevents premature spec merges.
- **Constitution always loaded** — The constitution defines project-wide rules that must inform every AI action — not just artifact generation but also implementation and verification. Referenced in workflow rules, instructing AI to read it before proceeding.
- **Verify findings are binding** — All critical/warning issues from verification must be resolved (code fix or spec update) before archiving. Findings are not optional suggestions.
- **Bidirectional feedback** — When implementation reveals new edge cases or design flaws, specs and design are updated (not just the code). The QA fix loop is the enforcement point.
- **Definition of Done is emergent** — Gherkin scenarios define functional completeness, success metrics define quality targets, preflight findings define risk resolution, and explicit approval gates implementation completeness. No separate DoD checklist needed.

#### Bootstrap

| Step | Command | What Happens |
|------|---------|--------------|
| 1. Setup | `/opsx:init` | Installs OpenSpec schema + config into the project. |
| 2. Bootstrap | `/opsx:bootstrap` | Scans codebase → generates `constitution.md` + initial specs. |
| 3. Review | *Manual* | Review constitution and generated specs for correctness. |
| 4. Archive | `/opsx:archive` | Initial specs land in `openspec/specs/` as baseline. |

#### Feature Cycle

| Step | Command | What Happens |
|------|---------|--------------|
| 1. Plan | `/opsx:new feature-x` + `/opsx:ff` | Create workspace, generate all artifacts (research through tasks). |
| 2. Review | *Manual* | Review all artifacts — especially `preflight.md` for gaps and side effects. |
| 3. Execute | `/opsx:apply` | AI implements according to `tasks.md`, stops at QA gate. |
| 4. QA | *Manual + `/opsx:verify`* | User tests → Fix Loop → explicit "Approved". |
| 5. Archive | `/opsx:archive` | Merge specs into `openspec/specs/`, move workspace to `archive/`. |
| 6. Docs | `/opsx:changelog` + `/opsx:docs` | Generate release notes & user documentation. |

#### Discovery Step (Optional)

For complex features, run discovery separately before fast-forward:

1. `/opsx:discover` → generates only `research.md`, stops for Q&A
2. User answers open questions
3. `/opsx:ff` → generates remaining artifacts based on research + answers

**When to use discover:** 3+ coverage categories are Partial/Missing, external APIs involved, architectural impact unclear, or multiple viable approaches need trade-off analysis.

**When to skip:** All categories are Clear, the feature is well-understood, or it's a small change with obvious implementation.

#### Thorough Path (Alternative)

Instead of `/opsx:ff`, each artifact can be generated and reviewed individually via `/opsx:continue`:

```
/opsx:continue → research.md  → Review / Answer questions
/opsx:continue → proposal.md → Review
/opsx:continue → spec.md     → Review
/opsx:continue → design.md   → Review
/opsx:continue → preflight.md → Review (Gate!)
/opsx:continue → tasks.md    → Review
/opsx:apply
```

#### Why Docs After Archive?

The Docs skills are intentionally **post-archive**, because:
- `/opsx:changelog` reads from the **archived** `proposal.md` and `spec.md`
- `/opsx:docs` reads from the **merged** specs in `openspec/specs/` — the holistic single source of truth, not just the delta of the current feature

#### Recovery Path

When code changes happen outside the spec process (hotfixes, dependency updates, external contributions):

- **Small drift:** `/opsx:new hotfix-xyz` → `/opsx:ff` → derive specs from existing code → `/opsx:archive`
- **Large drift:** Re-run `/opsx:bootstrap` — it detects existing specs and runs in recovery mode (drift detection + consistency passes)

> The spec process assumes specs come before code. When reality diverges, use these paths to re-sync.

---

### Plugin Structure

This repo **is** the Claude Code plugin. The `.claude-plugin/plugin.json` manifest defines the plugin identity, and all skills and templates are organized at the plugin root.

```
opsx-enhanced-flow/
├── .claude-plugin/
│   ├── plugin.json                        # Plugin manifest (name: "opsx")
│   └── marketplace.json                   # Self-hosted marketplace definition
│
├── openspec/                              # Canonical source + project specs (dogfooding)
│   ├── config.yaml                        # Workflow rules & context (copied to consumer projects)
│   ├── constitution.md                    # Project constitution (generated by bootstrap)
│   ├── schemas/
│   │   └── opsx-enhanced/                 # Schema source of truth (copied to consumer projects)
│   │       ├── schema.yaml                # Artifact pipeline definition
│   │       ├── README.md                  # Schema documentation
│   │       └── templates/                 # Artifact templates
│   ├── specs/                             # Merged specs (one per capability)
│   └── changes/archive/                   # Archived feature workspaces
│
├── skills/                                # All plugin skills — workflow + utility
│   ├── new/SKILL.md                       # Start a new change
│   ├── continue/SKILL.md                  # Create next artifact
│   ├── ff/SKILL.md                        # Fast-forward all artifacts
│   ├── apply/SKILL.md                     # Implement tasks
│   ├── verify/SKILL.md                    # Verify implementation
│   ├── archive/SKILL.md                   # Archive completed change
│   ├── init/SKILL.md                      # Install OpenSpec + schema
│   ├── bootstrap/SKILL.md                 # Codebase scan → constitution + specs
│   ├── discover/SKILL.md                  # Interactive research with Q&A
│   ├── preflight/SKILL.md                 # Standalone quality check
│   ├── changelog/SKILL.md                 # Generate release notes
│   └── docs/SKILL.md                      # Generate user documentation
│
└── README.md                              # This file
```

### Target Project Structure (after setup)

```
your-project/
├── openspec/
│   ├── config.yaml                        # Copied from plugin template
│   ├── constitution.md                    # Generated by /opsx:bootstrap
│   ├── specs/                             # Single source of truth (merged specs)
│   ├── schemas/
│   │   └── opsx-enhanced/
│   │       ├── schema.yaml
│   │       └── templates/...
│   └── changes/                           # Active feature development
│       ├── <feature-name>/                # Current workspace (temporary)
│       └── archive/                       # History: YYYY-MM-DD-<feature-name>/
│
├── docs/                                  # End-user documentation (auto-generated)
│   ├── README.md                          # Table of contents (auto-updated)
│   └── capabilities/
│       └── <capability>.md                # One document per capability
├── CHANGELOG.md                           # Project history (auto-generated)
└── ...
```

> **Archive naming:** Archived workspaces use the format `YYYY-MM-DD-<feature-name>/` (OpenSpec convention). The `/opsx:changelog` skill relies on this date prefix to identify the most recent archive.

---

### Reference Files

| File | Purpose |
|------|---------|
| [config.yaml](openspec/config.yaml) | Workflow rules injected into every artifact prompt |
| [schema.yaml](openspec/schemas/opsx-enhanced/schema.yaml) | Artifact pipeline: `research → proposal → specs → design → preflight → tasks → [apply]` |
| [constitution.md](openspec/constitution.md) | Living project rules (created by bootstrap, auto-updated in design step) |
| [templates/](openspec/schemas/opsx-enhanced/templates/) | Artifact templates (`research.md`, `proposal.md`, `spec.md`, `design.md`, `preflight.md`, `tasks.md`) |

---

### Skills

Skills are provided by the plugin and available as `/opsx:*` commands when the plugin is installed. All skills are model-invocable (`disable-model-invocation: false`), except `/opsx:init` which is user-only because it's a one-time project setup action.

#### `/opsx:init` — Project Setup

Installs OpenSpec and the opsx-enhanced schema into the current project. Idempotent — safe to run multiple times.

- **Installs:** Schema, config.yaml, constitution.md placeholder
- **When:** Once per project, before any other `/opsx:*` command

#### `/opsx:bootstrap` — Bootstrap & Recovery

Full codebase scan to generate the project constitution and initial specs. Detects first run vs. re-run and adapts accordingly.

- **First Run:** Scan codebase → Generate constitution → Create initial specs via pipeline
- **Re-Run (Recovery):** Drift detection → Update constitution → Consistency passes (terminology, boundaries, dependencies)
- **When:** First run after setup, or re-run for recovery/consistency

#### `/opsx:discover` — Research & Discovery

Interactive research with Q&A for complex features. Generates only `research.md`, pauses for targeted clarification questions, records decisions, then stops.

- **Flow:** Read context → Generate research → Pause for Q&A → Record decisions
- **When:** Complex features with partial/missing coverage, external APIs, or multiple viable approaches

#### `/opsx:preflight` — Standalone Quality Check

Pre-flight quality review after manual spec edits. Covers traceability, gaps, side effects, constitution check, duplication, and assumption audit.

- **Verdict:** PASS / PASS WITH WARNINGS / BLOCKED
- **When:** After manual changes to specs or design artifacts

#### `/opsx:changelog` — Generate Release Notes

Incrementally generates changelog entries from archived specs. Only adds new entries — existing entries are never modified.

- **Source:** Archived `proposal.md` + `spec.md`
- **Target:** `CHANGELOG.md` (Keep a Changelog format)
- **When:** After `/opsx:archive`

#### `/opsx:docs` — Generate User Documentation

Generates user-facing documentation from merged specs. Supports full regeneration or single-capability updates.

- **Source:** Merged specs in `openspec/specs/`
- **Target:** `docs/capabilities/<capability>.md` + `docs/README.md`
- **When:** After `/opsx:archive`

---

### Setup

#### Claude Code (Plugin — Recommended)

```bash
# Add the marketplace (one-time)
/plugin marketplace add fritze-dev/opsx-enhanced-flow

# Install the plugin
/plugin install opsx@opsx-enhanced-flow
```

After installing the plugin, run `/opsx:init` in your project to install the schema and configure OpenSpec. Then run `/opsx:bootstrap` to scan your codebase and generate the constitution + initial specs.

#### Other AI Tools (Manual)

For tools other than Claude Code, set up manually:

1. Initialize OpenSpec and register the schema:
   ```bash
   openspec init --tools claude
   openspec schema init opsx-enhanced --force
   ```
2. Copy schema and config from this repo:
   ```bash
   cp -r openspec/schemas/opsx-enhanced/ <your-project>/openspec/schemas/opsx-enhanced/
   cp openspec/config.yaml <your-project>/openspec/config.yaml
   ```
3. Verify the schema is available:
   ```bash
   openspec schema which opsx-enhanced
   ```
4. Copy the skill contents from `skills/*/SKILL.md` into your tool's commands directory:

   | Tool | Copy to |
   |------|---------|
   | Cursor | `.cursor/commands/opsx-<name>.md` |
   | Windsurf | `.windsurf/workflows/opsx-<name>.md` |
   | GitHub Copilot | `.github/prompts/opsx-<name>.prompt.md` |
   | Roo Code | `.roo/commands/opsx-<name>.md` |
   | Cline | `.clinerules/workflows/opsx-<name>.md` |

5. Run your tool's equivalent of `/opsx:bootstrap` to scan your codebase and generate the constitution + initial specs.

#### Development & Testing

```bash
# Load the plugin locally for testing
claude --plugin-dir .

# Test skills
/opsx:init
/opsx:bootstrap
/opsx:discover
/opsx:preflight
/opsx:changelog
/opsx:docs
```

---

### Roadmap

Concrete improvements are tracked as [GitHub Issues](https://github.com/fritze-dev/opsx-enhanced-flow/issues?q=is:issue+label:roadmap).

Ideas for future versions:

- [ ] **Auto-Test Generation** — Automatically generate test cases (unit, integration, E2E) from Gherkin scenarios during the planning phase, before implementation begins.
- [ ] **Schema-bundled Skills** — Propose upstream feature to OpenSpec: allow `schema.yaml` to declare custom skills that get auto-installed during schema setup.
- [ ] **Checklist Gem (Definition of Done)** — A consolidated, machine-readable DoD checklist auto-generated from existing artifacts: Gherkin scenarios (functional criteria), success metrics (quality targets), and preflight findings (risk items). Includes per-artifact acceptance criteria — explicit rules for when each artifact (research, spec, design, etc.) is considered complete.
- [ ] **Autonomous Agent Flow** — Fully automated pipeline run via specialized sub-agents: a Reviewer agent reviews artifacts, a Q&A agent answers discovery questions, a Test agent validates implementation, and an Approval agent gates quality checks — replacing all manual user steps with domain-specific agents orchestrated by a single `/opsx:auto` command.
- [ ] **Agent Handoff Protocol** — Explicit handoff criteria between agents in the Autonomous Agent Flow. Each agent validates its output against the Checklist Gem's per-artifact acceptance criteria before passing to the next agent. Includes rollback rules.
- [ ] **ADR Generation** — Auto-generate Architecture Decision Records from `design.md` artifacts after archive (`/opsx:adr`).
- [ ] **Auto GitHub Releases** — Automatically create GitHub Releases from changelog entries after `/opsx:changelog`.
- [ ] **Multi-Tool Plugin Support** — Package as plugins for Cursor, Windsurf, and other AI tools as they add plugin support.

---

## Credits

Built on [OpenSpec](https://github.com/Fission-AI/OpenSpec) (a spec management framework for AI-assisted development) and inspired by [Spec-Kit](https://github.com/github/spec-kit) (GitHub's methodology for writing rigorous software specifications).
