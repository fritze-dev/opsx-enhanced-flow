# Pre-Flight Check: Standard-Tasks

## A. Traceability Matrix

- [x] **Standard Tasks Exclusion from Apply Scope** (task-implementation)
  - → Scenario: Apply skips standard tasks section → schema.yaml apply instruction
  - → Scenario: Progress count includes standard tasks → existing progress tracking (no code change needed)
  - → Scenario: Archive warns on unchecked standard tasks → existing archive incomplete-task check (no code change needed)

- [x] **Baseline Spec Exclusion (MODIFIED)** (task-implementation)
  - → Scenario: Task generation excludes baseline spec edits → schema.yaml tasks instruction (existing, clarified)
  - → Scenario: Apply skips baseline spec edits → schema.yaml apply instruction (existing, unchanged)
  - → Scenario: Implementation tasks exclude post-apply workflow steps → schema.yaml tasks instruction (clarified rule)

- [x] **Standard Tasks Directive in Task Generation** (artifact-pipeline)
  - → Scenario: Standard tasks included from constitution → schema.yaml tasks instruction + constitution.md
  - → Scenario: No standard tasks in constitution → schema.yaml tasks instruction (omit directive)
  - → Scenario: Template includes standard tasks placeholder → templates/tasks.md

- [x] **Schema Owns Workflow Rules (MODIFIED)** (artifact-pipeline)
  - → Scenario: Tasks instruction includes DoD rule → schema.yaml (existing, unchanged)
  - → Scenario: Tasks instruction includes standard tasks directive → schema.yaml tasks instruction
  - → Scenario: Apply instruction includes post-apply workflow → schema.yaml (existing, unchanged)
  - → Scenario: Apply instruction clarifies standard tasks scope → schema.yaml apply instruction

## B. Gap Analysis

No gaps identified:
- **Error handling**: If constitution has no `## Standard Tasks` section → section omitted (covered in edge cases)
- **Empty states**: Empty standard tasks section in constitution → treated as not defined (covered in edge cases)
- **Edge cases for apply**: Standard tasks manually checked before archive → counted as complete (covered)
- **Re-invocation**: Apply after all tasks complete → reports "All tasks complete" (covered)

## C. Side-Effect Analysis

- **Existing archived changes**: Unaffected — historical `tasks.md` files have no section 4, archive reads them as-is
- **In-progress changes**: Any change currently at the tasks stage was generated with the old instruction. It will not have a section 4. No regression.
- **Progress counting**: Standard tasks add to the total count. After apply completes, progress will show e.g. "5/10 complete" instead of "5/5 complete". This is intentional and documented as a design decision.
- **Archive behavior**: The existing incomplete-task warning will naturally detect unchecked standard tasks. No archive code change needed — this is a positive side effect.
- **Preflight/Verify**: These tools check spec/design consistency, not tasks.md structure. No side effect.

## D. Constitution Check

Yes — the constitution needs updating as part of this change:
- **Add** `## Standard Tasks` section with literal checkbox items
- **Trim** the "Post-archive version bump" convention prose (remove next-steps workflow, keep auto-bump mechanism)
- No new architectural patterns introduced that require other constitution updates

## E. Duplication & Consistency

- **No duplication**: The next-steps workflow currently exists in two places (constitution convention prose + schema apply instruction guidance). After this change, the workflow steps live in one place (constitution Standard Tasks) and the schema instruction references that source. This reduces duplication.
- **Consistency with existing specs**: The "Baseline Spec Exclusion" requirement in task-implementation already establishes the pattern of scope exclusion from apply. The new "Standard Tasks Exclusion" follows the same pattern.
- **No contradictions**: The modified "Baseline Spec Exclusion" adds a sentence about standard tasks that is consistent with the new requirement.

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | Standard tasks in the constitution use the same markdown checkbox format (`- [ ]`) as implementation tasks | task-implementation spec | Acceptable Risk | We control the constitution content — we define them in this format |
| 2 | The agent can distinguish task sections by their `##` heading numbers/titles | task-implementation spec | Acceptable Risk | Consistent with how the agent already processes sections 1-3; instruction-based guidance is the established enforcement pattern |
| 3 | The constitution is read during task generation via the config.yaml context directive | artifact-pipeline spec | Acceptable Risk | Verified: config.yaml context points to constitution, and skills like preflight/discover already read it successfully |
| 4 | Verbatim copy means the agent transfers the exact markdown text without rewriting | artifact-pipeline spec | Acceptable Risk | The instruction explicitly says "copy verbatim" — agent compliance is the established enforcement model |

**Verdict: PASS** — All assumptions are Acceptable Risk, no gaps or blocking issues found.
