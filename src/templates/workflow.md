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

    Post-apply workflow: /opsx:verify → /opsx:archive →
    /opsx:changelog → /opsx:docs → commit → execute constitution
    pre-merge standard tasks. Never skip steps.
    IMPORTANT: /opsx:verify MUST run before /opsx:sync or /opsx:archive.
    Never sync baseline specs before implementation is verified.

    Constitution standard tasks are split into pre-merge and post-merge.
    Only pre-merge tasks are executed during post-apply workflow.
    Post-merge tasks remain as unchecked reminders in tasks.md —
    they are executed manually after the PR is merged.

    Before committing, mark all standard task checkboxes in tasks.md
    as complete — including the commit step itself — EXCEPT post-merge
    tasks, which remain unchecked.

post_artifact: |
  After creating any artifact, commit and push the change:
  1. Check current branch: `git rev-parse --abbrev-ref HEAD`
     - If already on `<change-name>` branch (e.g., in a worktree): skip branch creation
     - If on main: `git checkout -b <change-name>`
     - If on another branch: `git checkout <change-name>`
  2. Stage change artifacts: `git add openspec/changes/<change-name>/`
  3. Commit: `git commit -m "WIP: <change-name> — <artifact-id>"`
  4. Push: `git push -u origin <change-name>`
  5. On FIRST push only (no existing PR for this branch):
     `gh pr create --draft --title "<Change Name>" --body "WIP: <change-name>"`

  If `gh` CLI is unavailable or not authenticated, skip PR creation.
  If push fails, continue with local commit — do not block the pipeline.

# worktree:
#   enabled: false
#   path_pattern: .claude/worktrees/{change}
#   auto_cleanup: false

context: |
  Always read and follow openspec/CONSTITUTION.md before proceeding.
  All workflow artifacts (research, proposal, specs, design, preflight, tasks)
  must be written in English regardless of docs_language.

# docs_language: English
---

# Workflow

Research → Propose → Specs → Design → Pre-Flight → Tasks → Apply → QA → Sync → Archive
