# Pre-Flight Check: SpecShift Beta Restructure

## A. Traceability Matrix

- [x] Repo duplication (Fork & Rewrite) → Design Phase 0 → release-workflow spec
- [x] File moves (git mv) → Design Phase 1 → change-workspace spec, project-init spec
- [x] Spec flattening → Design Phase 1 → spec-format spec, documentation spec
- [x] SKILL.md path updates → Design Phase 2 → workflow-contract spec, artifact-pipeline spec
- [x] Template path updates → Design Phase 2 → workflow-contract spec
- [x] WORKFLOW.md updates → Design Phase 2 → workflow-contract spec
- [x] CONSTITUTION.md updates → Design Phase 2 → constitution-management spec
- [x] Plugin manifest updates → Design Phase 2 → release-workflow spec
- [x] CLAUDE.md generation → Design Phase 2 → project-init spec (CLAUDE.md Bootstrap)
- [x] Per-change snapshot flattening → Design Phase 3 → change-workspace spec
- [x] Branding removal → All specs → generic language throughout

## B. Gap Analysis

No gaps identified. The change is purely structural (paths, naming, branding). No new behavior, no new edge cases beyond what's already specified in the 14 existing specs.

## C. Side-Effect Analysis

| Affected File | Status | Action Required |
|---------------|--------|-----------------|
| `.devcontainer/devcontainer.json` | Stale `opsx` references | Update plugin name and repo references |
| `.claude/settings.json` | Stale `opsx-enhanced-flow` marketplace + plugin references | Update to `specshift` |
| `.claude/settings.local.json` | Stale dev paths to `openspec/` | Clear or update (dev-only file) |
| `.claude-plugin/marketplace.json` | Listed in design Phase 2 | Already covered |
| `src/.claude-plugin/plugin.json` | Listed in design Phase 2 | Already covered |
| `.github/copilot-setup-steps.yml` | May reference old plugin name | Check and update if needed |
| `.gitignore` | No update needed | `.specshift/` is version-controlled, no ignore rule needed |

**Action**: Add `.devcontainer/devcontainer.json`, `.claude/settings.json`, and `.github/copilot-setup-steps.yml` to the design's Phase 2 content updates table.

## D. Constitution Check

`.specshift/CONSTITUTION.md` (currently `openspec/CONSTITUTION.md`) requires 14+ updates:
- All `openspec/` paths → `.specshift/` and `docs/specs/`
- Plugin name `opsx` → `specshift`
- Repo name `opsx-enhanced-flow` → `specshift`
- Remove `.agents/` symlink convention (no longer applicable)
- Remove `AGENTS.md` + `CLAUDE.md` symlink convention → single `CLAUDE.md`
- Skill path `skills/workflow/` → `skills/specshift/`
- Post-merge plugin update commands → `specshift`

**Status**: Not yet updated — must be done during Phase 2 content edits.

## E. Duplication & Consistency

No duplications or contradictions found between specs after path updates. All 14 specs consistently use:
- `.specshift/WORKFLOW.md`
- `.specshift/CONSTITUTION.md`
- `.specshift/templates/`
- `.specshift/changes/`
- `docs/specs/<name>.md`
- `specshift init/propose/apply/finalize`

## F. Assumption Audit

| # | Assumption | Tag | Rating |
|---|-----------|-----|--------|
| 1 | No active consumers depend on the current `opsx` plugin or `openspec/` structure. | no-consumers | Acceptable Risk — plugin is pre-release |
| 2 | GitHub bare clone + mirror push preserves all branch history and tags. | mirror-preserves-history | Acceptable Risk — well-documented git behavior |
| 3 | git mv with subsequent content edits in separate commits preserves blame tracking. | separate-commits-preserve-blame | Acceptable Risk — standard git practice, verified with `git log --follow` |

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in active artifacts. Clean.

## H. Blocking Issues

| Issue | Status | Resolution |
|-------|--------|------------|
| ~~project-init spec contradicts design on AGENTS.md vs CLAUDE.md~~ | **RESOLVED** | Spec updated: AGENTS.md Bootstrap → CLAUDE.md Bootstrap. Template reference `agents.md` → `claude.md`. Symlink removed. |

## Verdict: PASS

All blocking issues resolved. 2 WARNINGs on side-effect files (devcontainer, settings.json) — add to task list during implementation.
