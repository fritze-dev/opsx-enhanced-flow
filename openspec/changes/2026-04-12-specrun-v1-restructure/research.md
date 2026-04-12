# Research: SpecRun v1.0 Restructure

## 1. Current State

The project is an OpenSpec/OPSX workflow plugin for Claude Code with the following architecture:

**Plugin distribution:**
- `src/.claude-plugin/plugin.json` — plugin manifest (name: "opsx", version: 2.0.13)
- `.claude-plugin/marketplace.json` — marketplace entry (source: "./src")
- `src/skills/workflow/SKILL.md` — single router skill with 4 actions
- `src/templates/` — 14 Smart Templates for artifact generation

**Project artifacts (dogfooding):**
- `openspec/WORKFLOW.md` — pipeline config + action instructions
- `openspec/CONSTITUTION.md` — project governance rules
- `openspec/specs/` — 14 capability specs (each in own directory with spec.md)
- `openspec/changes/` — 58+ completed change workspaces
- `openspec/templates/` — local copy of plugin templates (duplicated from src/templates/)
- `docs/` — generated capabilities (14), ADRs (54), README

**Cross-client discovery:**
- `.agents/skills/workflow/SKILL.md` — symlink to src (not working reliably)
- `.claude/skills/workflow/` — symlink to src (workaround)
- `AGENTS.md` + `CLAUDE.md` symlink — project instructions

**Key metrics:**
- 14 specs with ~280+ internal `openspec/` path references
- 39 `openspec` references in SKILL.md alone
- 56 `openspec` references across 9 files in `src/`
- 54 ADRs documenting historical decisions
- 58 completed changes with historical artifacts

## 2. External Research

**Claude Code Plugin System:**
- Plugin discovery: `marketplace.json` → `source` → `plugin.json` + `skills/` directory
- Skills auto-discovered from `src/skills/<name>/SKILL.md` when plugin installed
- No `entrypoint` field in plugin.json — skill discovery is convention-based
- `${CLAUDE_PLUGIN_ROOT}` resolves to plugin source directory at runtime
- Templates accessible via `${CLAUDE_PLUGIN_ROOT}/templates/` during init

**Agent Skills Standard (agentskills.io):**
- `.agents/skills/<name>/SKILL.md` for cross-client discovery
- Not reliably followed by Claude Code (symlinks not resolved)
- Claude Code uses `.claude/skills/` for local skill discovery

**Hidden infrastructure directories (precedent):**
- `.git/` — version control infrastructure
- `.claude/` — Claude Code config
- `.specrun/` follows this established pattern for workflow infrastructure

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Clean Slate (new repo, v1.0)** | Fresh history, no legacy baggage, clean naming from start | Loses git history, requires archiving old repo |
| **B: In-place migration (v3.0)** | Preserves history, single repo | 58 changes + 54 ADRs as dead weight, messy history |
| **C: Fork + rewrite** | Keeps history but starts fresh branch | Confusing dual history |

**Selected: Approach A (Clean Slate)** — New repo `specrun`, version 1.0.0. Transfer only current specs as baseline. Old repo archived with migration prompt in README.

| Approach | Pro | Contra |
|----------|-----|--------|
| **Templates at `src/templates/`** | Plugin-level resource, matches Claude Code conventions | Not co-located with SKILL.md |
| **Templates at `src/skills/workflow/templates/`** | Self-contained skill | Couples templates to single skill, deeper nesting |

**Selected: `src/templates/`** — Plugin-level resource, not skill-specific.

| Approach | Pro | Contra |
|----------|-----|--------|
| **Specs at `docs/specs/`** | All knowledge in one place, clean root | Mixes source-of-truth with generated content |
| **Specs at root `specs/`** | Clear separation from generated docs | One more root-level directory |

**Selected: `docs/specs/`** — All project knowledge (specs = input, capabilities/ADRs = output) unified under `docs/`.

## 4. Risks & Constraints

| Risk | Severity | Mitigation |
|------|----------|------------|
| Consumer projects break after plugin update | HIGH | No consumers yet (plugin is pre-release). Migration prompt in old repo README. |
| Lost institutional knowledge from ADRs | MEDIUM | ADR decisions are already baked into current specs. New ADR-001 documents the architecture. |
| Template-version reset to 1 | LOW | Clean slate — no existing consumers with template-version 4 to conflict with. |
| Spec content drift during transfer | LOW | Transfer specs verbatim, only update paths and naming. |
| Missing spec cross-references after flatten | MEDIUM | All `openspec/specs/<name>/spec.md` → `docs/specs/<name>.md` — anchors stay the same. |

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Clean slate repo, transfer 14 specs, new folder structure, rename namespace |
| Behavior | Clear | 4 actions (init, propose, apply, finalize), same pipeline, new paths |
| Data Model | Clear | .specrun/ for infrastructure, docs/ for knowledge, src/ for upstream |
| UX | Clear | Simpler root (CLAUDE.md + docs/ + src/), hidden infrastructure |
| Integration | Clear | Plugin system unchanged (marketplace.json + plugin.json + skills/) |
| Edge Cases | Clear | No active consumers, no migration needed in v1 |
| Constraints | Clear | Plugin manifest 2-level split, skill discovery conventions |
| Terminology | Clear | SpecRun replaces OpenSpec/OPSX, "specrun" as plugin name |
| Non-Functional | Clear | No performance/security impact — pure structural change |

All categories Clear — no open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Clean Slate v1.0 in new repo | No legacy baggage, clean git history, proper naming from start | In-place migration v3.0 (rejected: 58 changes + 54 ADRs as dead weight) |
| 2 | Templates at `src/templates/` (plugin level) | Claude Code convention, plugin-level resource shared across potential future skills | `src/skills/workflow/templates/` (rejected: unnecessary coupling) |
| 3 | Specs at `docs/specs/<name>.md` (flat) | All project knowledge under docs/, eliminates unnecessary directory nesting | Root-level `specs/` (rejected: adds root clutter) |
| 4 | `.specrun/` as infrastructure dir | Hidden = clean root, established pattern (.git/, .claude/), holds WORKFLOW.md + CONSTITUTION.md + templates + changes | Visible root-level files (rejected: clutters root) |
| 5 | Plugin name "specrun" | Clean product name, matches repo name, owner stays "fritze.dev" | "fritze" (rejected: too personal for a product name) |
| 6 | No migrate/update actions in v1 | init already handles template sync, no active consumers to migrate | Separate migrate + update actions (rejected: unnecessary complexity for v1) |
| 7 | Dogfooding setup 1:1 like client | Tests real user flow, no symlinks that break, validates init/update paths | Symlinks to src/ (rejected: already proven unreliable) |
| 8 | Transfer only specs, not ADRs/changes | ADR decisions are embedded in specs, old changes reference obsolete paths | Full transfer (rejected: dead weight with wrong paths) |
