# Technical Design: Commit Before Approval

## Context

The QA Loop in the tasks template currently goes directly from Auto-Verify (3.2) to User Testing (3.3), where the agent pauses for approval. At this point, implementation changes exist only in the local worktree — they are not committed or pushed. The user cannot review a PR diff because no commit exists on the remote branch.

The post_artifact hook in WORKFLOW.md already commits after each planning artifact, and the Standard Tasks section (4.4) commits the final post-apply changes. This change adds a WIP commit between these two, capturing the implementation state.

## Architecture & Components

**Files to modify:**

1. **`openspec/WORKFLOW.md`** (`apply.instruction`) — Add commit+push instruction after `/opsx:verify` passes and before user approval pause. Analogous to `post_artifact` but for the implementation phase.

2. **`openspec/specs/artifact-pipeline/spec.md`** — New "Post-Implementation Commit Before Approval" requirement, specifying the behavior lives in `apply.instruction`.

3. **`openspec/specs/human-approval-gate/spec.md`** — Remove hardcoded step numbers, reference QA Loop steps by semantic name. Note that commit happens via `apply.instruction`, not as a template step.

No changes needed to:
- `openspec/templates/tasks.md` — Template stays unchanged; commit is a WORKFLOW.md concern, not a template step.
- `openspec/specs/task-implementation/spec.md` — No changes; the commit behavior lives in artifact-pipeline.
- `src/skills/apply/SKILL.md` — The apply skill reads `apply.instruction` from WORKFLOW.md at runtime.

## Goals & Success Metrics

* WORKFLOW.md apply.instruction includes commit+push after verify, before user approval — PASS/FAIL
* artifact-pipeline spec references apply.instruction for commit behavior — PASS/FAIL
* human-approval-gate spec uses semantic step names instead of numbers — PASS/FAIL

## Non-Goals

- Modifying the apply skill behavior (it already handles QA tasks sequentially)
- Changing the post_artifact hook or WORKFLOW.md apply.instruction
- Automating the commit step (it's a task description the agent follows, not a hook)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Add commit instruction to WORKFLOW.md apply.instruction rather than tasks template | Consistent with post_artifact pattern (WORKFLOW.md owns commit behavior); template stays clean; no renumbering needed | Add as template task step (visible but couples template to git concerns) |
| Use `WIP: <change-name> — implementation` commit message format | Consistent with post_artifact hook pattern (`WIP: <change-name> — <artifact-id>`); clearly marks as non-final | Use generic "checkpoint" message (less informative); use final commit format (confusing) |
| Place commit step after verify, before user testing | User needs the diff to review; verify should pass before committing | Place after user testing (defeats purpose); place before verify (commits potentially broken code) |

## Risks & Trade-offs

- **Extra commit in git history** → Acceptable; consistent with post_artifact pattern that already creates one commit per artifact. The WIP commit is a useful checkpoint.
- **Push failure blocks user testing** → Mitigated by graceful degradation: if push fails, create local commit and note that user should review locally.

## Open Questions

No open questions.

## Assumptions

- The agent executing the QA Loop tasks has git write access to the repository. <!-- ASSUMPTION: Git access during QA -->
- The branch created by post_artifact during artifact creation still exists when the QA loop is reached. <!-- ASSUMPTION: Branch persistence -->
