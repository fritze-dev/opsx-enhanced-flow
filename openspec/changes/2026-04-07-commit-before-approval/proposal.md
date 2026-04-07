## Why

After completing implementation and running `/opsx:verify`, the agent pauses at the user testing step (3.3) to ask for approval — but has not committed or pushed the changes. The user cannot review a diff that hasn't been committed and pushed to the PR. This creates friction every time the QA loop is reached.

## What Changes

- Add a "Commit and push" step in the tasks template QA Loop between Auto-Verify (3.2) and User Testing (3.3)
- Update the human-approval-gate spec to require implementation changes be committed before the approval gate
- Update the task-implementation spec to document the WIP commit behavior during the QA loop

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `human-approval-gate`: Add requirement that implementation changes must be committed and pushed before the approval gate, so the user can review the PR diff
- `task-implementation`: Document the WIP commit step in the QA Loop and its relationship to the final commit in Standard Tasks

### Removed Capabilities

(none)

### Consolidation Check

N/A — no new specs proposed. Both modifications target existing specs that own the relevant behavior: `human-approval-gate` owns the QA loop approval flow, `task-implementation` owns the tasks template structure and standard tasks.

## Impact

- `openspec/templates/tasks.md` — QA Loop section gains a new step (renumbers 3.3–3.6 to 3.4–3.7)
- `openspec/specs/human-approval-gate/spec.md` — new requirement + scenario for commit-before-approval
- `openspec/specs/task-implementation/spec.md` — updated requirement to document WIP commit in QA loop
- All future `tasks.md` files generated from the template will include the new commit step

## Scope & Boundaries

**In scope:**
- Tasks template QA Loop modification
- Spec updates for human-approval-gate and task-implementation
- The commit step uses existing git/gh patterns (same as post_artifact hook)

**Out of scope:**
- Changes to the apply skill itself (it already processes QA Loop tasks sequentially)
- Changes to WORKFLOW.md apply.instruction (the template change is sufficient)
- Changes to the post_artifact hook
