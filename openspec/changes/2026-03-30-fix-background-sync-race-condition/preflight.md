# Pre-Flight Check: Fix Background Sync Race Condition

## A. Traceability Matrix

- [x] "Archive Completed Change" (modified) → Scenario: Auto-sync before archiving → `src/skills/archive/SKILL.md` step 4 (subagent prompt)
- [x] "Archive Completed Change" (modified) → Scenario: State-based validation prevents premature archive → `src/skills/archive/SKILL.md` step 4 (baseline spec existence check)
- [x] "Archive Completed Change" (modified) → Scenario: Baseline spec missing after sync → `src/skills/archive/SKILL.md` step 4 (failure path)
- [x] Edge case: Baseline spec already existed before sync → validation still passes (existence check, not content check)

## B. Gap Analysis

No gaps identified. The change is narrow:
- Subagent prompt rewrite: single bullet point in step 4
- State-based validation: new bullet point between existing lines 60-61 (baseline spec existence check)
- All failure paths (sync fails, missing baseline spec) converge to "stop and report"

## C. Side-Effect Analysis

- **Sync skill**: Not modified. Validation is state-based (file existence), not coupled to sync output format.
- **Other archive steps**: Steps 1-3 and 5-7 are untouched. Only step 4 changes.
- **Other skills invoking sync**: `/opsx:sync` standalone is unaffected — the fix is only in the archive skill's invocation path.
- **Regression risk**: Minimal. The prompt change improves context; the validation follows the same pattern as steps 2-3 (check state before proceeding).

## D. Constitution Check

No constitution changes needed. The skill immutability rule is respected — this is a bug fix to the archive skill, not a project-specific behavior.

## E. Duplication & Consistency

- The delta spec's "Auto-sync before archiving" scenario is consistent with the existing baseline scenario but adds the subagent prompt and validation requirements.
- The new "State-based validation prevents premature archive" scenario does not overlap with the existing "Sync failure" edge case — it covers the file existence gate, while the edge case covers the sync agent failure response.
- No contradictions with `spec-sync` spec — its assumption about sequential execution is reinforced by this fix.

## F. Assumption Audit

No assumptions found in spec.md or design.md — the previous sync output format assumption was eliminated by switching to state-based validation.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifacts.
