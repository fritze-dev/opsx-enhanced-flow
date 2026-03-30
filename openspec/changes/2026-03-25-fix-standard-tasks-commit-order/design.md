# Technical Design: Fix Standard Tasks Commit Order

## Context

The post-apply workflow runs: `/opsx:archive` → `/opsx:changelog` → `/opsx:docs` → commit. Each step corresponds to a standard task checkbox (4.1-4.4) in `tasks.md`. Currently the `apply.instruction` in `schema.yaml` does not instruct the agent to mark these checkboxes before committing. Agents mark them after the commit, requiring an extra follow-up commit.

## Architecture & Components

Two files are affected:

1. **`openspec/schemas/opsx-enhanced/schema.yaml`** — `apply.instruction` field (lines 231-242). Add a directive: before committing, mark all standard task checkboxes (including the commit step) as complete in `tasks.md`.

2. **`openspec/specs/task-implementation/spec.md`** — Merged via `/opsx:sync` from the delta spec. The new scenario formalizes the marking-before-commit requirement.

No skills, templates, CLI, or constitution changes needed.

## Goals & Success Metrics

* After running the post-apply workflow (archive → changelog → docs → commit), the committed `tasks.md` SHALL show all standard tasks (4.1-4.4) as `- [x]` — PASS/FAIL by inspecting the commit contents.
* No extra follow-up commit needed for standard task checkboxes — PASS/FAIL by checking git log for checkbox-only commits.

## Non-Goals

- Changing the post-apply step order (archive → changelog → docs → commit stays the same)
- Auto-marking constitution extras (4.5+) — those remain manual
- Modifying any skill files (archive, changelog, docs)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| General rule ("ensure all checked before commit") rather than per-step marking | Simpler, less prescriptive; agent decides exact timing; accurate because all steps have run by commit time | Per-step mark-as-you-go (more verbose, over-prescriptive) |
| Add directive to `apply.instruction` only | The apply instruction is where the post-apply workflow is defined; no other location needed | Could also add to each skill (archive, changelog, docs) but that scatters the logic |

## Risks & Trade-offs

- [Agent ignores instruction] → Low risk; the directive is explicit and testable via `/opsx:verify`. Spec scenario provides formal backup.
- [Partial workflow failure] → If a post-apply step fails before commit, only completed steps should be marked. This is natural behavior — the agent won't commit if a step fails.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
