## Review: Auto-Approve Full Flow

### Summary
| Dimension | Status |
|-----------|--------|
| Tasks | 8/8 complete |
| Requirements | 6/6 verified |
| Scenarios | 4/4 covered |
| Scope | Clean / 0 untraced files |

### Requirements Verification

| # | Requirement | Status |
|---|-------------|--------|
| 1 | WORKFLOW.md propose instruction includes auto_approve design checkpoint skip | PASS |
| 2 | WORKFLOW.md apply instruction includes auto_approve user testing skip | PASS |
| 3 | SKILL.md router has auto-dispatch logic: propose->apply, apply->finalize | PASS |
| 4 | CONSTITUTION.md design checkpoint convention respects auto_approve | PASS |
| 5 | Consumer template synced with WORKFLOW.md instructions | PASS |
| 6 | FAIL/BLOCKED paths still stop regardless of auto_approve | PASS |

### Scenario Coverage

| # | Scenario | Spec | Status |
|---|----------|------|--------|
| 1 | Auto-approve bypasses user testing when PASS and auto_approve true | human-approval-gate v3 | Covered: apply instruction skips pause on PASS, SKILL.md auto-dispatches finalize |
| 2 | Auto-approve does NOT bypass when warnings present | human-approval-gate v3 | Covered: "PASS WITH WARNINGS still pauses for acknowledgment" in docs |
| 3 | Auto-dispatch propose->apply on success | workflow-contract v5 | Covered: SKILL.md Step 5 propose adds auto-dispatch step |
| 4 | Auto-dispatch apply->finalize on clean PASS | workflow-contract v5 | Covered: SKILL.md Step 5 apply adds auto-dispatch step |

### Files Changed

| File | Change |
|------|--------|
| `openspec/WORKFLOW.md` | Propose: conditional design checkpoint. Apply: conditional user testing pause, conditional post-PASS approval. |
| `src/skills/workflow/SKILL.md` | Step 5: auto-dispatch propose->apply (step 5), auto-dispatch apply->finalize (step 3) |
| `openspec/CONSTITUTION.md` | Design checkpoint convention now respects auto_approve |
| `src/templates/workflow.md` | Synced with WORKFLOW.md propose + apply instruction changes |
| `docs/capabilities/workflow-contract.md` | Updated auto-approve feature bullet and behavior section |
| `docs/capabilities/human-approval-gate.md` | Updated Auto-Approve Skips Human Gate section |
| `openspec/changes/.../tasks.md` | All standard task checkboxes marked complete |

### Findings
#### CRITICAL
(none)

#### WARNING
(none)

#### SUGGESTION
(none)

### Verdict
PASS
