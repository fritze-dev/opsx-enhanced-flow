# Pre-Flight Check: Commit Before Approval

## A. Traceability Matrix

- [x] Story: "As a developer I want implementation changes committed and pushed before I'm asked for approval" → Scenario: WIP commit before user testing, Commit step with no remote access → Component: `openspec/templates/tasks.md` (QA Loop section)
- [x] Story: "As a developer I want a mandatory human approval step before finalizing" → Scenario: Commit and push before user testing, Approval after clean verification → Component: `openspec/specs/human-approval-gate/spec.md`
- [x] Story: "As a developer I want implementation changes committed and pushed before approval" → Scenario: WIP commit does not replace final commit → Component: `openspec/specs/task-implementation/spec.md`

## B. Gap Analysis

No gaps identified:
- Commit failure is handled (graceful degradation to local commit)
- Push failure is handled (continue with local commit, note for user)
- Relationship between WIP commit (3.3) and final commit (4.4) is documented
- Step renumbering is consistent across template and both specs

## C. Side-Effect Analysis

- **Existing tasks.md files**: Previously generated tasks.md files are unaffected — only newly generated ones will include step 3.3. No migration needed.
- **Step number references in other files**: The apply skill (`src/skills/apply/SKILL.md`) does not reference QA Loop step numbers directly — it processes tasks sequentially by checkbox. No impact.
- **WORKFLOW.md apply.instruction**: References "post-apply workflow" generically, not by step number. No impact.
- **Verify skill**: The verify skill (`src/skills/verify/SKILL.md`) is invoked by step description, not step number. No impact.

## D. Constitution Check

No constitution changes needed. The commit message format (`WIP: <change-name> — implementation`) follows the existing convention pattern (`WIP: <change-name> — <artifact-id>`) from the post_artifact hook. The imperative present tense convention in the constitution applies to final commits, not WIP commits.

## E. Duplication & Consistency

- No overlap between the new requirement in `task-implementation` ("WIP Commit in QA Loop") and the existing "Standard Tasks Exclusion" requirement — they address different commits (WIP vs final).
- The new requirement in `human-approval-gate` is additive to the existing "QA Loop with Mandatory Approval" requirement — it adds a precondition (changes committed) before the approval gate.
- Step numbers are consistent between specs and template after renumbering.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | Git access during QA — agent has git write access | design.md | Acceptable Risk — agent already has git access for post_artifact hook |
| 2 | Branch persistence — branch from post_artifact still exists at QA time | design.md | Acceptable Risk — worktree isolation ensures branch persists throughout the change lifecycle |
| 3 | Checkbox format stability | task-implementation spec | Acceptable Risk — pre-existing assumption, unchanged |
| 4 | Ordering is recommended not enforced | task-implementation spec | Acceptable Risk — pre-existing assumption, unchanged |
| 5 | Skill file access | task-implementation spec | Acceptable Risk — pre-existing assumption, unchanged |
| 6 | Constitution task format | task-implementation spec | Acceptable Risk — pre-existing assumption, unchanged |
| 7 | Section heading parsing | task-implementation spec | Acceptable Risk — pre-existing assumption, unchanged |
| 8 | User availability | human-approval-gate spec | Acceptable Risk — pre-existing assumption, unchanged |
| 9 | No auto-retrigger | human-approval-gate spec | Acceptable Risk — pre-existing assumption, unchanged |
| 10 | Reviewer context | human-approval-gate spec | Acceptable Risk — pre-existing assumption, unchanged |
| 11 | Approval token | human-approval-gate spec | Acceptable Risk — pre-existing assumption, unchanged |
| 12 | Unbounded fix loop | human-approval-gate spec | Acceptable Risk — pre-existing assumption, unchanged |

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any artifacts or specs.

---

**Verdict: PASS**
