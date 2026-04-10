# Pre-Flight Check: Auto-Approve Full Flow

## A. Traceability Matrix

- [x] Auto-dispatch propose→apply→finalize → Scenario: "Router auto-dispatches" → SKILL.md Step 5
- [x] Design checkpoint skip → propose instruction → WORKFLOW.md + CONSTITUTION.md
- [x] User testing skip on PASS → apply instruction → WORKFLOW.md + human-approval-gate spec
- [x] FAIL/BLOCKED safety → All instructions include guard conditions
- [x] Template sync → `src/templates/workflow.md`
- [x] Docs update → `docs/capabilities/workflow-contract.md`, `docs/capabilities/human-approval-gate.md`

## B. Gap Analysis

No gaps. All pause points identified in issue #105 are addressed. FAIL/BLOCKED safety explicitly maintained in all instructions.

## C. Side-Effect Analysis

- **`auto_approve: false` users unaffected**: All changes are gated by `auto_approve: true` conditions
- **Existing propose/apply/finalize behavior**: Preserved when auto_approve is false
- **Sub-agent boundaries**: Router handles cross-action dispatch; sub-agents don't need to know about chaining

## D. Constitution Check

Yes — CONSTITUTION.md line 40 needs updating. The design checkpoint convention currently says "always pause." It should say "pause unless auto_approve is true."

## E. Duplication & Consistency

No overlapping stories. workflow-contract and human-approval-gate changes are complementary (one handles router dispatch, the other handles QA loop behavior).

## F. Assumption Audit

No `<!-- ASSUMPTION -->` markers in design.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found.

---

**Verdict: PASS**
