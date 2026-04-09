# Pre-Flight Check: Diff-Based Verification

## A. Traceability Matrix

| Capability | Spec Updated | Scenarios | Design Components |
|------------|-------------|-----------|-------------------|
| quality-gates (Modified) | Yes — 3 new requirement paragraphs added to Post-Implementation Verification | 7 new scenarios (diff scope traceable, diff scope untraced, task-diff no match, task-diff match, multiple untraced grouped, no merge base, all-pass already covers combined) | `openspec/specs/quality-gates/spec.md`, `src/skills/verify/SKILL.md` |

- Proposal lists 1 modified capability: `quality-gates` → spec updated with diff-based verification requirements and scenarios. **Traced.**
- Design lists 2 components: quality-gates spec and verify SKILL.md. Both are covered by proposal scope. **Traced.**

**Result: PASS** — all capabilities and components fully traced.

## B. Gap Analysis

- **Graceful degradation for diff checks**: Covered — scenario for no merge base, edge case for orphan/detached HEAD. Existing graceful degradation scenarios cover missing artifacts (tasks.md, design.md).
- **Task-diff mapping when tasks.md missing**: Covered by existing edge case "Verify on change with no tasks" — verify reports missing artifact.
- **Design.md missing for diff scope check**: The spec says files are checked against tasks.md OR design.md. If design.md is missing, tasks.md alone is used. Existing graceful degradation scenario covers this.
- **Empty diff (no changes on branch)**: Not explicitly covered as a scenario, but logically handled — diff scope check finds no files, task-diff mapping flags all completed tasks. Minor gap, not blocking.

**Result: PASS** — no significant gaps.

## C. Side-Effect Analysis

| Area | Risk | Assessment |
|------|------|------------|
| Existing verify dimensions (Completeness, Correctness, Coherence) | New step 4 changes step numbering in SKILL.md | LOW — design explicitly addresses insertion point and step renumbering |
| Verify report format | New "Diff Scope" row in scorecard | NONE — additive; existing rows unchanged |
| Other skills (preflight, docs-verify, apply) | No changes to other skills | NONE |
| Existing quality-gates spec scenarios | Existing scenarios unchanged | NONE — new scenarios are additive |

**Result: PASS** — no actionable side-effects.

## D. Constitution Check

| Rule | Status |
|------|--------|
| Skill immutability (skills are generic, shared across consumers) | PASS — diff checks use git (universally available) and OpenSpec artifacts (framework-standard). No project-specific logic. |
| Three-layer architecture | PASS — spec defines requirements, SKILL.md defines implementation instructions. Layers respected. |
| No ADR references in specs | PASS — no ADR references in new spec text. |
| Template synchronization (WORKFLOW.md ↔ src/templates/workflow.md) | N/A — no WORKFLOW.md changes in this change. |

**Result: PASS** — no constitution conflicts.

## E. Duplication & Consistency

- ~~**Diff Scope Check vs Unintended Change Detection**: paragraph overlap~~ — **RESOLVED**: Paragraphs consolidated into a single "Diff Scope Check" paragraph during implementation. No longer overlapping.
- **No contradictions with existing specs**: The new requirements are additive to the existing Post-Implementation Verification requirement. Severity classification (SUGGESTION for untraced files, WARNING for task-diff mismatch) is consistent with the existing "err on lower severity" principle.
- **No cross-spec overlaps**: No other spec (task-implementation, human-approval-gate) covers diff-based verification.

**Result: PASS** — no remaining issues.

## F. Assumption Audit

### Spec Assumptions (quality-gates/spec.md)

| Assumption | Tag | Visible Text | Rating |
|------------|-----|-------------|--------|
| Git availability | `<!-- ASSUMPTION: Git availability -->` | Yes | Acceptable Risk — git is a prerequisite for worktrees and the plugin system |
| Task description quality | `<!-- ASSUMPTION: Task description quality -->` | Yes | Acceptable Risk — consistent with existing keyword heuristic assumptions; inconclusive matches are skipped |

### Design Assumptions (design.md)

| Assumption | Tag | Visible Text | Rating |
|------------|-----|-------------|--------|
| Git availability | `<!-- ASSUMPTION: Git availability -->` | Yes | Acceptable Risk |
| Task description quality | `<!-- ASSUMPTION: Task description quality -->` | Yes | Acceptable Risk |

**Result: PASS** — all assumptions have visible text and are rated Acceptable Risk.

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any change artifact or modified spec.

**Result: PASS**

---

## Pre-Flight Complete

**Change**: diff-based-verify
**Output**: preflight.md

### Findings
- Blockers: 0
- Warnings: 0
- Info: 0

### Assumptions Audited
- Acceptable Risk: 4
- Needs Clarification: 0
- Blocking: 0

**Verdict: PASS**
