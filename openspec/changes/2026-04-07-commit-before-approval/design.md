# Technical Design: Commit Before Approval

## Context

The QA Loop in the tasks template currently goes directly from Auto-Verify (3.2) to User Testing (3.3), where the agent pauses for approval. At this point, implementation changes exist only in the local worktree — they are not committed or pushed. The user cannot review a PR diff because no commit exists on the remote branch.

The post_artifact hook in WORKFLOW.md already commits after each planning artifact, and the Standard Tasks section (4.4) commits the final post-apply changes. This change adds a WIP commit between these two, capturing the implementation state.

## Architecture & Components

**Files to modify:**

1. **`openspec/templates/tasks.md`** (lines 53-58) — Add step 3.3 "Commit and push implementation changes for review" between Auto-Verify and User Testing. Renumber subsequent steps (3.3→3.4, 3.4→3.5, 3.5→3.6, 3.6→3.7).

2. **`openspec/specs/artifact-pipeline/spec.md`** — New "Post-Implementation Commit Before Approval" requirement extending the post_artifact pattern to the implementation phase.

3. **`openspec/specs/human-approval-gate/spec.md`** — Remove hardcoded step numbers (3.1–3.7), reference QA Loop steps by semantic name instead. Step numbering is a template concern.

No changes needed to:
- `openspec/specs/task-implementation/spec.md` — No changes; the commit behavior lives in artifact-pipeline.
- `src/skills/apply/SKILL.md` — The apply skill already processes QA Loop tasks sequentially. The new step will be executed like any other task.
- `openspec/WORKFLOW.md` — The apply.instruction and post_artifact hook remain unchanged.

## Goals & Success Metrics

* Generated tasks.md files include step 3.3 "Commit and push implementation changes for review" in the QA Loop — PASS/FAIL
* Step numbering in QA Loop is consistent (3.1 through 3.7) — PASS/FAIL
* human-approval-gate spec uses semantic step names instead of numbers — PASS/FAIL

## Non-Goals

- Modifying the apply skill behavior (it already handles QA tasks sequentially)
- Changing the post_artifact hook or WORKFLOW.md apply.instruction
- Automating the commit step (it's a task description the agent follows, not a hook)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Add explicit task step in template rather than apply skill guidance | Visible in every tasks.md; agent processes it like any other task; auditable | Add guidance in WORKFLOW.md apply.instruction (soft enforcement, not visible in tasks.md) |
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
