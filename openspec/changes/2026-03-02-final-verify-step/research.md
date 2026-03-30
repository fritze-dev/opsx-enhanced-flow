# Research: Final Verify Step in QA Loop

## 1. Current State

The QA Loop is defined in the tasks.md template at `openspec/schemas/opsx-enhanced/templates/tasks.md` (lines 12-17):

```
## 3. QA Loop & Human Approval
- [ ] 3.1. Metric Check
- [ ] 3.2. Auto-Verify: Run /opsx:verify
- [ ] 3.3. User Testing: Stop here! Ask the user for manual approval.
- [ ] 3.4. Fix Loop: fix code OR update specs/design → re-verify
- [ ] 3.5. Approval: Only finish on explicit "Approved"
```

**Problem:** Verification runs once at 3.2, but the Fix Loop (3.4) may modify code, specs, or design. After the Fix Loop, the user goes directly to Approval (3.5) without a final verification pass. Post-fix edits go unverified.

**Observed in practice:** During the `fix-workflow-friction` change, we naturally ran verify → fix → verify → approve. The template doesn't formalize this second verify.

Related specs:
- `quality-gates/spec.md` — defines `/opsx:verify` behavior
- `human-approval-gate/spec.md` — defines QA loop, fix loop, approval
- `task-implementation/spec.md` — defines task checklist format and progress tracking

The human-approval-gate spec already describes iterative fix-verify cycles (Scenario: "Multiple fix-verify iterations") but the template doesn't have a dedicated checkpoint for the final verify.

## 2. External Research

N/A — this is an internal template change.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Add explicit 3.5 "Final Verify" step, renumber Approval to 3.6 | Clear checkpoint; formalizes what already happens in practice; no ambiguity about when to re-verify | One more checkbox; slightly longer template |
| B: Modify Fix Loop text to say "must end with clean verify" | No renumbering needed | Easy to overlook; no separate checkbox to track |
| C: Make Apply skill auto-run verify after fix loop | Fully automated | Over-engineered; removes user control over when to verify |

**Recommendation:** Approach A — explicit step, matches observed practice.

## 4. Risks & Constraints

- Renumbering 3.5 → 3.6 affects the tasks template only (not generated tasks, which are change-specific)
- Existing archived changes keep their old numbering (no migration needed)
- The human-approval-gate spec mentions "fix-verify cycles" but doesn't specify a mandatory final verify — spec needs a small addition

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | One template file + spec updates |
| Behavior | Clear | Add checkpoint between fix loop and approval |
| Data Model | Clear | No data model changes |
| UX | Clear | One additional checkbox in tasks.md |
| Integration | Clear | No skill changes needed — verify skill already exists |
| Edge Cases | Clear | Fix loop may be skipped if first verify is clean |
| Constraints | Clear | Template change only affects new changes |
| Terminology | Clear | "Final Verify" is self-explanatory |
| Non-Functional | Clear | No performance impact |

All categories Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Approach A: explicit 3.5 step | Matches observed practice, provides clear checkpoint | B (text-only), C (auto-verify) |
