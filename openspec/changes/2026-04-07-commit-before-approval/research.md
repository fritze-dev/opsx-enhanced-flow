# Research: Commit Before Approval

## 1. Current State

The QA Loop in the tasks template (`openspec/templates/tasks.md`) defines this sequence:

```
3.1. Metric Check
3.2. Auto-Verify: Run /opsx:verify
3.3. User Testing: Stop here! Ask the user for manual approval.
3.4. Fix Loop
3.5. Final Verify
3.6. Approval
```

Implementation code changes are committed only in the Standard Tasks section (step 4.4 "Commit and push to remote"), which runs **after** approval. The `post_artifact` hook in WORKFLOW.md commits after each planning artifact (research, proposal, etc.) but does **not** apply to implementation code changes during `/opsx:apply`.

**Affected files:**
- `openspec/templates/tasks.md` — QA Loop section (lines 53-58)
- `openspec/specs/human-approval-gate/spec.md` — QA Loop requirement
- `openspec/specs/task-implementation/spec.md` — Standard Tasks exclusion requirement
- `src/skills/apply/SKILL.md` — apply skill instructions

The apply skill (`src/skills/apply/SKILL.md`) implements tasks sequentially and pauses at 3.3 for user testing. At that point, changes exist only in the local worktree — they are not committed or pushed to the PR branch.

## 2. External Research

Not applicable — this is an internal workflow issue.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A. Add commit+push step between 3.2 and 3.3 in tasks template | Explicit, visible in tasks.md; agent commits before pausing; user sees diff on PR | Adds a step to every change's QA loop; slightly more complex template |
| B. Add guidance in apply skill instruction | No template change needed | Easy to miss; not visible in the generated tasks.md; soft enforcement only |
| C. Add guidance in WORKFLOW.md apply.instruction | Central location for apply behavior | Not visible in tasks.md; agent may skip it |

**Recommended: Approach A** — Adding an explicit step in the tasks template is the most reliable. The agent already processes QA Loop steps sequentially, so a commit+push step between verify and user testing will be executed before the pause. This is also visible and auditable in every tasks.md.

## 4. Risks & Constraints

- The commit at this stage is a WIP implementation commit, not the final commit (which includes changelog, docs, version bump in step 4.4). The commit message should reflect this.
- The step must handle the case where `gh` CLI is unavailable (degrade gracefully).
- The step should use the same branch that was created by `post_artifact` during artifact creation.
- No risk of duplicate commits: step 4.4 will be a separate commit with post-apply changes.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Add commit+push step between verify and user testing |
| Behavior | Clear | Commit implementation changes, push to remote, so PR diff is available |
| Data Model | Clear | No data model changes — only markdown template and spec updates |
| UX | Clear | User sees the diff on the PR before being asked to approve |
| Integration | Clear | Uses existing git/gh patterns from post_artifact hook |
| Edge Cases | Clear | gh unavailable, no remote, already committed |
| Constraints | Clear | Must not interfere with final commit in step 4.4 |
| Terminology | Clear | "WIP commit" vs "final commit" distinction is straightforward |
| Non-Functional | Clear | No performance or security implications |
