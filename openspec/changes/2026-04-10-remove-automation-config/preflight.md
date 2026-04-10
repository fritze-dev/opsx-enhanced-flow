# Pre-Flight Check: Remove Automation Config

## A. Traceability Matrix

- [x] Automation Configuration requirement removal → Scenario: "WORKFLOW.md contains automation configuration" + Scenario: "Automation section is optional" → `openspec/specs/workflow-contract/spec.md` (already removed in specs stage)
- [x] WORKFLOW.md frontmatter cleanup → `openspec/WORKFLOW.md` lines 17-23
- [x] Consumer template cleanup → `src/templates/workflow.md` lines 17-23
- [x] Router skill extraction list → `src/skills/workflow/SKILL.md` line 22
- [x] CI workflow deletion → `.github/workflows/pipeline.yml`
- [x] Docs cleanup → `docs/capabilities/workflow-contract.md`, `docs/README.md`, `README.md`
- [x] Constitution convention update → `openspec/CONSTITUTION.md` line 42

## B. Gap Analysis

No gaps identified. All locations mapped in research and confirmed in design. The change is purely subtractive — removing references to a feature that was never actively used by consumers.

## C. Side-Effect Analysis

- **Other CI workflows unaffected**: `release.yml`, `claude.yml`, `claude-code-review.yml` are independent of `pipeline.yml`
- **Local finalize unchanged**: `/opsx:workflow finalize` works the same — only the CI trigger path is removed
- **Spec requirement count**: workflow-contract drops from 5 to 4 requirements — still substantial
- **SKILL.md Step 2**: After removing `automation` from the extraction list, all remaining fields are still valid

No regression risks identified.

## D. Constitution Check

Yes — `openspec/CONSTITUTION.md` needs a minor update: the template sync convention on line 42 mentions `automation` alongside `worktree`. After removal, the convention should only reference `worktree` as the field that may differ between project and consumer template.

## E. Duplication & Consistency

No overlapping stories. Single capability (`workflow-contract`) modified. All changes are consistent removals of the same feature across different layers (spec, config, template, skill, CI, docs).

## F. Assumption Audit

No `<!-- ASSUMPTION -->` markers in the design document. No assumptions made.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifacts.

---

**Verdict: PASS** — all checks clear, no blockers.
