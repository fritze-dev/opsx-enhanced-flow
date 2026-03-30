# Research: Rename init skill to setup

## 1. Current State

The init skill lives at `skills/init/SKILL.md` with frontmatter `name: init`. It is invoked as `/opsx:init`. The problem: `init` conflicts with Claude Code's built-in `/init` command (which creates CLAUDE.md), making `/opsx:init` unavailable.

**Affected files (active — excluding archives):**

| Category | Files | Reference count |
|----------|-------|-----------------|
| Skill itself | `skills/init/SKILL.md` | dir rename + frontmatter + 2 internal refs |
| README | `README.md` | 6 references |
| Baseline specs | `project-setup`, `constitution-management`, `interactive-discovery`, `change-workspace`, `project-bootstrap`, `release-workflow`, `user-docs`, `three-layer-architecture` | ~20 references |
| Schema docs | `openspec/schemas/opsx-enhanced/README.md` | 1 reference |
| User docs | `docs/README.md`, `docs/capabilities/project-setup.md`, `project-bootstrap.md`, `release-workflow.md`, `constitution-management.md`, `interactive-discovery.md` | ~15 references |
| Other skills | `bootstrap`, `docs`, `discover`, `preflight`, `changelog` | 5 references (1 each) |

**Files to leave unchanged (historical records):**
- `openspec/changes/archive/*` — archived change artifacts
- `CHANGELOG.md` — historical release notes
- `docs/decisions/adr-*.md` — architectural decision records

## 2. External Research

Not applicable — this is a pure rename with no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Rename `init` → `setup` | Avoids conflict with built-in `/init`; clear naming; minimal change | Requires updating many files |
| Rename `init` → `install` | Also avoids conflict | Less accurate — it does more than install |
| Keep `init`, request upstream fix | No file changes needed | Depends on Claude Code team; indefinite timeline |

**Recommended:** `setup` — it's descriptive, avoids the conflict, and was proposed in the issue.

## 4. Risks & Constraints

- **Low risk:** Pure text rename — no logic changes, no schema changes, no config changes.
- **Breaking change for existing users:** Anyone who has memorized `/opsx:init` will need to use `/opsx:setup`. The README and docs will guide them.
- **Archive integrity:** Archives must not be modified — they are historical records.
- **CHANGELOG as history:** CHANGELOG entries document what happened at the time and should not be rewritten.
- **ADRs as history:** ADR documents record decisions made at the time and should not be rewritten.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Rename dir + update all active references |
| Behavior | Clear | No behavior change — only the name changes |
| Data Model | Clear | No data model — just markdown files |
| UX | Clear | `/opsx:setup` replaces `/opsx:init` |
| Integration | Clear | Other skills reference the command name in error messages |
| Edge Cases | Clear | Archives/CHANGELOG/ADRs left unchanged |
| Constraints | Clear | Must not modify historical records |
| Terminology | Clear | `setup` is the new name |
| Non-Functional | Clear | No performance or security implications |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Rename to `setup` | Avoids built-in `/init` conflict; descriptive name | `install`, keep `init` |
| 2 | Leave archives, CHANGELOG, ADRs unchanged | Historical records should reflect what was true at the time | Update everything |
