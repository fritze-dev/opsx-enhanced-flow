<!--
---
has_decisions: true
---
-->
# Technical Design: Auto-Approve as Default

## Context

`auto_approve` controls whether the pipeline pauses at checkpoints (preflight warnings, post-apply PASS). Currently commented out in WORKFLOW.md and the consumer template — the effective default is `false` (pause at every checkpoint). This change flips the default to `true`.

The design review checkpoint after the design artifact is a constitutional requirement and is **not** controlled by `auto_approve`. It always pauses regardless.

## Architecture & Components

Two files change:
1. **`openspec/WORKFLOW.md:15`** — uncomment `auto_approve: true`
2. **`src/templates/workflow.md:15`** — uncomment `auto_approve: true`

Two specs updated (already done in specs artifact):
1. **`openspec/specs/workflow-contract/spec.md`** — `auto_approve` field description updated to reflect default-true
2. **`openspec/specs/artifact-pipeline/spec.md`** — "Propose as Single Entry Point" requirement updated

## Goals & Success Metrics

* `auto_approve: true` is uncommented and active in WORKFLOW.md
* `auto_approve: true` is uncommented and active in consumer template
* Spec language reflects "defaults to true" semantics
* WORKFLOW.md and template remain in sync per constitution

## Non-Goals

- Changing design review checkpoint behavior (constitutional, independent)
- Adding per-action auto_approve granularity
- Changing FAIL behavior (always stops, unchanged)
- Modifying QA loop / human-approval-gate spec

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Uncomment in both WORKFLOW.md and template | Consistency between project and consumers per constitution's template sync rule | Only project (inconsistent), only template (project still paused) |
| Update spec default language, not add new scenarios | Behavioral contract is the same — only the default flips | Add new scenarios for "absent defaults to true" (unnecessary, existing scenarios cover the behavior) |

## Risks & Trade-offs

- **Consumer behavior change**: Consumers who run `init` will get auto-approve. → Mitigation: Opt-out is trivial (`auto_approve: false`), and the template has a comment showing the field name.
- **Users who relied on inline checkpoints**: They lose the pause-by-default safety. → Mitigation: FAIL always stops, design checkpoint is constitutional, and opt-out is documented.

## Open Questions

No open questions.

## Assumptions

- Consumers who update their workflow via init will accept the new default or explicitly opt out. <!-- ASSUMPTION: Consumer opt-out awareness -->
