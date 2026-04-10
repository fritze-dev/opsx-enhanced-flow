# Research: Auto-Approve Full Flow

## 1. Current State

`auto_approve: true` in WORKFLOW.md currently controls only limited checkpoint behavior:
- Preflight warnings acknowledgment (auto-continue on PASS)
- Post-apply PASS (auto-continue)

It does NOT control:
- Design review checkpoint (hardcoded as "always pauses" in constitution + propose instruction)
- Propose → Apply transition (propose always stops and suggests `/opsx:workflow apply`)
- User Testing Gate in QA loop (always requires explicit "Approved")
- Apply → Finalize transition (no auto-dispatch exists)

**Files that enforce pauses:**

| File | Pause point | Current behavior |
|------|------------|------------------|
| `openspec/WORKFLOW.md` propose instruction | Design checkpoint | "pause after design for user alignment (constitutional requirement)" |
| `openspec/WORKFLOW.md` propose instruction | Review artifact | "stop before review and suggest /opsx:workflow apply" |
| `openspec/WORKFLOW.md` apply instruction | User testing | "Pause only at user testing gate" |
| `openspec/WORKFLOW.md` apply instruction | Post-PASS | "commit and push implementation before pausing for user approval" |
| `openspec/CONSTITUTION.md` line 40 | Design checkpoint | "always pause for user alignment" |
| `openspec/specs/human-approval-gate/spec.md` | QA loop | "SHALL require explicit human approval" / "SHALL NOT proceed without" |
| `openspec/specs/workflow-contract/spec.md` | auto_approve | Only describes checkpoint behavior, not cross-action dispatch |
| `src/skills/workflow/SKILL.md` | Router dispatch | No auto-dispatch logic between propose→apply→finalize |
| `docs/capabilities/workflow-contract.md` | Feature docs | Documents current limited auto_approve behavior |

## 2. External Research

No external dependencies. This is an internal behavior change to the workflow orchestration.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Instruction + spec changes only | Minimal change surface; router skill stays generic | Sub-agent boundaries still require manual continuation |
| B: Instruction + spec + router SKILL.md changes | Full end-to-end flow; router auto-dispatches apply→finalize | Modifies plugin source (SKILL.md) |
| C: Instruction changes only, rely on agent behavior | No spec changes needed | Soft enforcement, inconsistent behavior |

**Recommendation: Approach B** — the router needs to know about auto_approve to auto-dispatch propose→apply→finalize. The instruction changes tell sub-agents to skip pauses; the router change tells the orchestrator to chain actions.

## 4. Risks & Constraints

- **Router immutability**: Constitution says SKILL.md "MUST NOT be modified for project-specific behavior." But this is a generic plugin feature (auto_approve), not project-specific. The change belongs in the router.
- **FAIL safety**: Auto-approve must NOT skip pauses when review.md verdict is FAIL or preflight is BLOCKED. Only success paths are auto-continued.
- **Breaking change**: Users with `auto_approve: false` (or absent, which now defaults to true) are unaffected — the change only adds behavior when true.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Issue #105 lists exact pain points |
| Behavior | Clear | Skip pauses on success paths when auto_approve is true |
| Data Model | Clear | No new fields — extends existing auto_approve semantics |
| UX | Clear | Fewer interruptions for the user |
| Integration | Clear | Router + instructions + specs |
| Edge Cases | Clear | FAIL/BLOCKED always stops regardless |
| Constraints | Clear | Router change is generic, not project-specific |
| Terminology | Clear | "auto_approve" already established |
| Non-Functional | Clear | Faster workflow execution |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Approach B: instruction + spec + router | Full end-to-end flow requires router awareness | Instruction-only (incomplete) |
| 2 | FAIL/BLOCKED always stops | Safety net for genuine issues | Allow override |
