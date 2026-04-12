# Research: SpecShift Beta Restructure

## 1. Current State

The project is an OpenSpec/OPSX workflow plugin for Claude Code with the following architecture:

**Plugin distribution:**
- `src/.claude-plugin/plugin.json` — plugin manifest (name: "opsx", version: 2.0.13)
- `.claude-plugin/marketplace.json` — marketplace entry (source: "./src")
- `src/skills/workflow/SKILL.md` — single router skill with 4 actions (will become `src/skills/specshift/SKILL.md`)
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
- `.specshift/` follows this established pattern for workflow infrastructure

## 3. Approaches

### Repo Strategy

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Clean Slate (new repo)** | Fresh history, no legacy baggage | Loses git blame, copy-paste statt git mv |
| **B: In-place migration** | Preserves history, single repo | Old repo name stuck, messy history |
| **C: Fork & Rewrite (Duplicate)** | Preserves full git blame, git mv tracks renames, evolution visible | .git etwas größer durch alte Objekte |

**Selected: Approach C (Fork & Rewrite)** — Duplicate repo as `specshift`, restructure via `git mv`/`git rm`. Full git blame preserved — the evolution of prompts, SKILL.md, and specs remains traceable. Standard pattern for major OSS rewrites.

### Release Strategy

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Ship v1.0 in one shot** | Clean release, everything polished | Premature polish — templates/workflow may still change, wasted effort on docs consolidation |
| **B: Beta first, v1.0 later** | Validate mechanics before polishing, avoid rework on docs/ADRs, agile skateboard→car pattern | Two-phase effort, beta has rough edges |

**Selected: Approach B (Beta → v1.0)** — Beta focuses on mechanics & structure (the code works in the new folders, the commands work). Existing docs/ADRs/specs stay as-is or move unsorted into `docs/`. v1.0 later: template freeze, ADR consolidation into clean specs, final README/CHANGELOG. No point polishing documentation that may change during beta usage.

### Templates Location

| Approach | Pro | Contra |
|----------|-----|--------|
| **Templates at `src/templates/`** | Plugin-level resource, matches Claude Code conventions | Not co-located with SKILL.md |
| **Templates at `src/skills/specshift/templates/`** | Self-contained skill | Couples templates to single skill, deeper nesting |

**Selected: `src/templates/`** — Plugin-level resource, not skill-specific.

### Specs Location

| Approach | Pro | Contra |
|----------|-----|--------|
| **Specs at `docs/specs/`** | All knowledge in one place, clean root | Mixes source-of-truth with generated content |
| **Specs at root `specs/`** | Clear separation from generated docs | One more root-level directory |

**Selected: `docs/specs/`** — All project knowledge (specs = input, capabilities/ADRs = output) unified under `docs/`.

## 4. Risks & Constraints

| Risk | Severity | Mitigation |
|------|----------|------------|
| Consumer projects break after plugin update | HIGH | No consumers yet (plugin is pre-release). Old repo archived with migration note. |
| Premature docs polishing wastes effort | MEDIUM | Beta phase defers doc consolidation. Only restructure mechanics now, polish at v1.0. |
| git mv loses blame for heavily rewritten files | LOW | git mv preserves blame for renames/moves. Content edits create new blame entries — correct behavior. |
| Template-version reset to 1 | LOW | No existing consumers with template-version 4. Reset is clean. |
| Missing spec cross-references after flatten | MEDIUM | All `openspec/specs/<name>/spec.md` → `docs/specs/<name>.md` — anchors stay the same. |

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Beta: mechanics & structure. v1.0: polish & consolidation. |
| Behavior | Clear | 4 actions (init, propose, apply, finalize), same pipeline, new paths |
| Data Model | Clear | .specshift/ for infrastructure, docs/ for knowledge, src/ for upstream |
| UX | Clear | Simpler root (CLAUDE.md + docs/ + src/), hidden infrastructure |
| Integration | Clear | Plugin system unchanged (marketplace.json + plugin.json + skills/) |
| Edge Cases | Clear | No active consumers, no migration needed |
| Constraints | Clear | Plugin manifest 2-level split, skill discovery conventions |
| Terminology | Clear | SpecShift replaces OpenSpec/OPSX, skill renamed from `workflow` to `specshift` → commands become `specshift init`, `specshift propose`, etc. |
| Non-Functional | Clear | No performance/security impact — pure structural change |

All categories Clear — no open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Fork & Rewrite (Duplicate repo) | Preserves git blame for all prompts/specs/skill evolution, git mv tracks renames | Clean Slate (rejected: loses git blame), In-place migration (rejected: old repo name stuck) |
| 2 | Beta → v1.0 phased release | Beta validates mechanics before polishing. Avoids wasted effort on docs/ADRs that may change during beta. | Ship v1.0 directly (rejected: premature polish, likely rework) |
| 3 | Templates at `src/templates/` (plugin level) | Claude Code convention, plugin-level resource | `src/skills/specshift/templates/` (rejected: unnecessary coupling) |
| 4 | Specs at `docs/specs/<name>.md` (flat) | All project knowledge under docs/, eliminates directory nesting | Root-level `specs/` (rejected: adds root clutter) |
| 5 | `.specshift/` as infrastructure dir | Hidden = clean root, established pattern (.git/, .claude/) | Visible root-level files (rejected: clutters root) |
| 6 | Plugin + skill name "specshift" | Clean product name, matches repo name, commands become `specshift init` etc. | Generic "workflow" (rejected: weak branding) |
| 7 | No migrate/update actions in beta | init already handles template sync, no active consumers | Separate actions (rejected: unnecessary complexity) |
| 8 | Dogfooding setup 1:1 like client | Tests real user flow, no symlinks that break | Symlinks to src/ (rejected: already proven unreliable) |
| 9 | Keep existing ADRs/specs unsorted in beta | No point consolidating docs that may still change. Move into docs/ as-is, polish at v1.0. | Delete via git rm (rejected: premature), Consolidate now (rejected: wasted effort) |
