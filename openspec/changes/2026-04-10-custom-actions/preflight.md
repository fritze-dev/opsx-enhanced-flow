# Pre-Flight Check: Custom Actions

## A. Traceability Matrix

- [x] Custom action validation (Inline Action Definitions requirement) → Scenario: Router executes custom action as sub-agent, Scenario: Actions are not pipeline steps → SKILL.md Step 1
- [x] Custom action dispatch (Router Dispatch Pattern requirement) → Scenario: Router dispatches custom action via generic fallback, Scenario: Router rejects action not in actions array → SKILL.md Step 5
- [x] Custom action extensibility (Router + Actions Layer requirement) → Scenario: Router dispatches to custom actions, Scenario: Adding a custom action does not require router changes → SKILL.md Step 5, WORKFLOW.md body sections
- [x] Layer separation preserved (Layer Separation requirement) → Scenario: Adding a custom action does not require router changes → WORKFLOW.md only

## B. Gap Analysis

No gaps identified. The change is additive — all edge cases (missing instruction section, action not in array, WORKFLOW.md fallback) are covered in the updated specs.

## C. Side-Effect Analysis

| System | Risk | Assessment |
|--------|------|------------|
| Built-in actions (init, propose, apply, finalize) | Regression from Step 1 validation change | Low — built-in actions are always in the `actions` array. The fallback to hardcoded list when WORKFLOW.md is missing preserves init behavior. |
| Pipeline traversal (propose) | Custom actions accidentally entering pipeline | None — actions and pipeline are explicitly separate concepts in specs and router. |
| Change context detection (Step 3) | Custom actions going through detection unnecessarily | Acceptable — detection is lightweight, and most custom actions benefit from it. |
| Consumer template (`src/templates/workflow.md`) | Template sync with project WORKFLOW.md | Low — only a comment is added to the consumer template. |

## D. Constitution Check

- [x] Constitution mentions "Router immutability: MUST NOT be modified for project-specific behavior." The change is generic (enables any consumer to define any action), not project-specific. No constitution update needed.
- [x] Architecture Rules reference "4 actions: init, propose, apply, finalize." This line in the constitution should be updated to reflect "4 built-in actions + custom actions."

## E. Duplication & Consistency

- [x] The custom action dispatch is described in both `workflow-contract` and `three-layer-architecture` specs — no contradiction, each at the appropriate abstraction level.
- [x] Edge cases in `workflow-contract` spec are consistent with the new scenarios.

## F. Assumption Audit

No ASSUMPTION markers found in the updated spec sections or design.md. The existing assumptions in the unchanged parts of the specs remain valid.

## G. Review Marker Audit

No REVIEW markers found in any artifacts.

---

**Verdict: PASS**

One action item: Update CONSTITUTION.md Architecture Rules line referencing "4 actions" during implementation.
