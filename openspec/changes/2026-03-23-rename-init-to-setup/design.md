# Technical Design: Rename init skill to setup

## Context

The `init` skill name conflicts with Claude Code's built-in `/init` command, making `/opsx:init` unavailable to users. This is a pure rename — no logic, behavior, or schema changes. The skill directory moves from `skills/init/` to `skills/setup/`, and all active references are updated.

## Architecture & Components

| Component | Action | Files |
|-----------|--------|-------|
| Skill directory | Rename `skills/init/` → `skills/setup/` | `skills/setup/SKILL.md` (frontmatter + heading + self-refs) |
| README | Text replace | `README.md` |
| Baseline specs | Text replace | 8 specs under `openspec/specs/` |
| Schema docs | Text replace | `openspec/schemas/opsx-enhanced/README.md` |
| User docs | Text replace | `docs/README.md`, 5 files under `docs/capabilities/` |
| Other skills | Text replace | `skills/{bootstrap,docs,discover,preflight,changelog}/SKILL.md` |

**Unchanged (historical records):** `openspec/changes/archive/*`, `CHANGELOG.md`, `docs/decisions/adr-*.md`

## Goals & Success Metrics

* **No stale references**: `grep -r '/opsx:init' --include='*.md'` returns zero matches outside archives, CHANGELOG, and ADRs — PASS/FAIL
* **No stale paths**: `grep -r 'skills/init' --include='*.md'` returns zero matches outside archives, CHANGELOG, and ADRs — PASS/FAIL
* **Skill directory exists**: `skills/setup/SKILL.md` exists with `name: setup` in frontmatter — PASS/FAIL
* **Old directory removed**: `skills/init/` does not exist — PASS/FAIL
* **Archives untouched**: `git diff openspec/changes/archive/` shows no changes — PASS/FAIL

## Non-Goals

- No behavior changes to the setup skill itself
- No schema or pipeline changes
- No changes to archived changes, CHANGELOG, or ADRs
- No constitution updates (no new tech, patterns, or conventions introduced)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Use `setup` as new name | Descriptive, avoids conflict, proposed in issue #31 | `install` (too narrow), keep `init` (conflict remains) |
| Leave archives unchanged | Historical records should reflect state at time of creation | Update everything (rewrites history) |
| Leave CHANGELOG unchanged | Entries describe what happened at the time | Rewrite entries (misleading) |
| Leave ADRs unchanged | Decision records are point-in-time documents | Update ADRs (loses historical context) |
| `git mv` for directory rename | Preserves git history for the skill file | `rm` + `mkdir` + `cp` (loses history) |

## Risks & Trade-offs

- **Breaking change for existing users** → Documented in README; `/opsx:setup` is discoverable via plugin system. Low impact since most users follow docs.
- **Missed reference** → Mitigated by grep-based success metrics that catch any remaining `/opsx:init` or `skills/init` references.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
