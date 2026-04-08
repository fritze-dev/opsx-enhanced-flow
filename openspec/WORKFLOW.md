---
templates_dir: openspec/templates
pipeline: [research, proposal, specs, design, preflight, tasks]

apply:
  requires: [tasks]
  tracks: tasks.md
  instruction: |
    Read context files, work through pending tasks, mark complete as you go.
    Pause if you hit blockers or need clarification.

    Standard Tasks (post-implementation section) are NOT part of apply.
    They are tracked in tasks.md for auditability but executed separately
    after apply completes.

    Post-apply workflow: /opsx:verify → commit and push implementation
    changes for review → pause for user approval →
    /opsx:changelog → /opsx:docs → version bump → commit → execute constitution
    pre-merge standard tasks. Never skip steps.

    QA Loop automated steps: Metric Check and Auto-Verify are automated
    steps — execute them without pausing for user confirmation. Do NOT
    ask for permission before running /opsx:verify. The first human gate
    is User Testing — only pause there.

    Fix loop discipline: After ANY fix-loop change (code, specs, or
    artifacts), always re-run /opsx:verify before presenting to the user.
    Never skip step 3.5 (Final Verify) when the fix loop was entered.

    Artifact freshness: When a fix resolves an issue flagged in
    preflight.md or design.md, update the affected artifact to reflect
    the resolution. Stale verdicts must not persist (e.g., preflight
    showing "PASS WITH WARNINGS" after the warning is fixed).

    Docs terminology check: Before user testing (step 3.3), check
    whether docs/capabilities/ and docs/README.md reference terminology
    that was changed in specs during this change. Flag stale references
    early — /opsx:docs in standard tasks handles regeneration, but the
    agent should identify drift before asking for approval.

    After /opsx:verify passes, commit and push all implementation changes
    before pausing for user approval:
    1. Stage all changed files: `git add -A`
    2. Commit: `git commit -m "WIP: <change-name> — implementation"`
    3. Push: `git push`
    If push fails, continue with local commit — do not block the workflow.

    Constitution standard tasks are split into pre-merge and post-merge.
    Only pre-merge tasks are executed during post-apply workflow.
    Post-merge tasks remain as unchecked reminders in tasks.md —
    they are executed manually after the PR is merged.

    Before committing, mark all standard task checkboxes in tasks.md
    as complete — including the commit step itself — EXCEPT post-merge
    tasks, which remain unchecked. No extra follow-up commit should be
    needed for pre-merge standard task checkboxes.

    Post-merge worktree cleanup: After a successful `gh pr merge` from
    within a worktree, clean up immediately:
    1. Switch working directory to the main worktree
    2. Run `git worktree remove <worktree-path>`
    3. Run `git branch -D <branch-name>`
    4. Run `git push origin --delete <branch-name>`
    If worktree remove fails (e.g., dirty state), report the error and
    suggest manual cleanup — do not block the workflow.

post_artifact: |
  After creating any artifact, commit and push the change:
  1. Check current branch: `git rev-parse --abbrev-ref HEAD`
     - If already on `<change-name>` branch (e.g., in a worktree): skip branch creation
     - If on main: `git checkout -b <change-name>`
     - If on another branch: `git checkout <change-name>`
  2. Stage change artifacts: `git add openspec/changes/<change-dir>/`
  3. Stage spec edits (if specs stage): `git add openspec/specs/`
  4. Commit: `git commit -m "WIP: <change-name> — <artifact-id>"`
  5. Push: `git push -u origin <change-name>`
  6. On FIRST push only (no existing PR for this branch):
     `gh pr create --draft --title "<Change Name>" --body "WIP: <change-name>"`

  If `gh` CLI is unavailable or not authenticated, skip PR creation.
  If push fails, continue with local commit — do not block the pipeline.

worktree:
  enabled: true
  path_pattern: .claude/worktrees/{change}
  auto_cleanup: true

context: |
  Always read and follow openspec/CONSTITUTION.md before proceeding.
  All workflow artifacts (research, proposal, specs, design, preflight, tasks)
  must be written in English regardless of docs_language.

# docs_language: English
---

# Workflow

Research → Propose → Specs → Design → Pre-Flight → Tasks → Apply → QA → Changelog → Docs
