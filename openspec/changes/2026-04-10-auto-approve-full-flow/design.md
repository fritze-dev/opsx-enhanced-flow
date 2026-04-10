<!--
---
has_decisions: true
---
-->
# Technical Design: Auto-Approve Full Flow

## Context

`auto_approve: true` currently only controls limited checkpoints (preflight warnings, post-apply PASS). The user expects it to mean "run the entire propose→apply→finalize flow without stopping unless something genuinely fails." Three layers need changes: action instructions (what sub-agents do), specs (behavioral contracts), and the router (cross-action dispatch).

## Architecture & Components

**Layer 1 — Action instructions (WORKFLOW.md):**

| Section | Change |
|---------|--------|
| `## Action: propose` | Add: "When auto_approve is true: skip design review checkpoint, and after pipeline completes auto-continue to apply" |
| `## Action: apply` | Change: "Pause only at user testing gate" → "When auto_approve is true and review.md verdict is PASS: skip user testing pause and auto-continue to finalize" |

**Layer 2 — Specs:**

| Spec | Change |
|------|--------|
| `workflow-contract` | Expand auto_approve description; add auto-dispatch scenarios |
| `human-approval-gate` | Add auto_approve bypass scenarios (already done in specs stage) |

**Layer 3 — Router (SKILL.md):**

| Section | Change |
|---------|--------|
| Step 5 `propose` dispatch | Add: after propose completes, if auto_approve is true, auto-dispatch apply |
| Step 5 `apply` dispatch | Add: after apply sub-agent returns with PASS, if auto_approve is true, auto-dispatch finalize |

**Layer 4 — Constitution + template sync:**

| File | Change |
|------|--------|
| `openspec/CONSTITUTION.md` | Update design checkpoint convention to respect auto_approve |
| `src/templates/workflow.md` | Sync propose + apply instructions |

**Layer 5 — Docs:**

| File | Change |
|------|--------|
| `docs/capabilities/workflow-contract.md` | Update auto-approve feature + behavior sections |
| `docs/capabilities/human-approval-gate.md` | Update to mention auto_approve bypass |
| `README.md` | No change needed — CLI examples already show the flow |

## Goals & Success Metrics

* WORKFLOW.md propose instruction includes auto_approve condition for design checkpoint skip
* WORKFLOW.md apply instruction includes auto_approve condition for user testing skip
* SKILL.md router has auto-dispatch logic: propose→apply when auto_approve true, apply→finalize when auto_approve true and PASS
* CONSTITUTION.md design checkpoint convention respects auto_approve
* Consumer template (`src/templates/workflow.md`) synced with WORKFLOW.md instructions
* FAIL/BLOCKED paths still stop regardless of auto_approve

## Non-Goals

- Adding new WORKFLOW.md fields
- Changing behavior when `auto_approve: false`
- Removing the QA loop — it still runs, just auto-approves on PASS

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Auto-dispatch in router SKILL.md, not just instructions | Instructions control sub-agent behavior within an action; cross-action chaining requires router-level logic | Instruction-only (can't chain across actions) |
| Auto-approve only on clean PASS (no CRITICAL, no WARNING) | Warnings may indicate genuine issues worth reviewing | Auto-approve on PASS WITH WARNINGS too |
| Keep design checkpoint as default pause when auto_approve is false | Design review is the highest-value checkpoint; opt-out, not opt-in | Remove design checkpoint entirely |

## Risks & Trade-offs

- **[Missed review opportunity]** → When auto_approve is true, the user won't see intermediate artifacts. Mitigated by: review.md still generated and visible in PR, user can set `auto_approve: false` for critical changes.
- **[Router modification]** → Constitution says SKILL.md is immutable for project-specific behavior. This is generic plugin behavior, not project-specific. Acceptable.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
