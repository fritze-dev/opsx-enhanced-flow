# Technical Design: Fix Stale Spec References

## Context

PR #77 eliminated `config.yaml`, `schema.yaml`, and `openspec/schemas/` but left ~57 stale references in 8 spec files. These references are text-level inconsistencies in spec prose and scenarios — no behavioral or code changes are involved.

## Architecture & Components

All changes are within `openspec/specs/*/spec.md` files. No skill, template, or code files are affected.

**Files to edit:**
1. `openspec/specs/decision-docs/spec.md` — 3 replacements
2. `openspec/specs/user-docs/spec.md` — 7 replacements
3. `openspec/specs/release-workflow/spec.md` — 6 replacements
4. `openspec/specs/constitution-management/spec.md` — 18 replacements (most complex)
5. `openspec/specs/interactive-discovery/spec.md` — 3 replacements
6. `openspec/specs/architecture-docs/spec.md` — 11 replacements
7. `openspec/specs/task-implementation/spec.md` — 1 replacement
8. `openspec/specs/project-bootstrap/spec.md` — 3 replacements

**Files explicitly NOT edited (intentional legacy context):**
- `openspec/specs/workflow-contract/spec.md`
- `openspec/specs/artifact-pipeline/spec.md`
- `openspec/specs/project-setup/spec.md`

## Goals & Success Metrics

- `grep -r 'config\.yaml' openspec/specs/` returns only intentional legacy references (workflow-contract, artifact-pipeline, project-setup) — PASS if ≤6 hits, all in excluded files
- `grep -r 'openspec/schemas/' openspec/specs/` returns only intentional legacy references (project-setup, workflow-contract) — PASS if ≤4 hits, all in excluded files
- `grep -r 'openspec/constitution\.md' openspec/specs/` returns 0 hits — PASS if 0 hits (all should be CONSTITUTION.md now, except project-setup migration edge case which uses both)
- `grep -r '\.claude-plugin/plugin\.json' openspec/specs/release-workflow/` — all occurrences use `src/.claude-plugin/plugin.json` — PASS if 0 bare `.claude-plugin/plugin.json` without `src/` prefix
- No intentional legacy references in excluded files are accidentally changed — PASS via diff review

## Non-Goals

- Gap 4 (plugin template workflow.md divergence) — separate concern
- Behavioral changes to any skill or workflow
- Docs regeneration (handled by post-apply `/opsx:docs`)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Group edits by replacement category, not by file | Reduces risk of inconsistent replacements — all `config.yaml→WORKFLOW.md` done together | Per-file editing (harder to verify completeness) |
| Semantic rewrite for constitution-management "config.yaml workflow rules" | The concept changed (config.yaml workflow rules → WORKFLOW.md context field), not just the path | Simple path swap (semantically wrong) |
| Change auto-bump from `.claude-plugin/plugin.json` to `src/.claude-plugin/plugin.json` | The file doesn't exist at `.claude-plugin/plugin.json` — only marketplace.json lives there | Leave as-is (would reference nonexistent file) |

## Risks & Trade-offs

- [Accidental change to migration context] → Mitigated by explicit exclusion list (workflow-contract, artifact-pipeline, project-setup)
- [Missed reference] → Mitigated by post-edit grep verification against success metrics

## Open Questions

No open questions.

## Assumptions

- All stale references identified in Issue #79 and verified by grep are exhaustive. <!-- ASSUMPTION: grep coverage -->
