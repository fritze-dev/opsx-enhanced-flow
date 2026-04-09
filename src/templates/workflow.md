---
template-version: 2
templates_dir: openspec/templates
pipeline: [research, proposal, specs, design, preflight, tasks, apply, verify, changelog, docs, version-bump]

apply:
  requires: [tasks]
  tracks: tasks.md

# worktree:
#   enabled: false
#   path_pattern: .claude/worktrees/{change}
#   auto_cleanup: false

# automation:
#   post_approval:
#     steps: [changelog, docs, version-bump]
#     labels:
#       running: automation/running
#       complete: automation/complete
#       failed: automation/failed

# docs_language: English
---

# Workflow

Research → Propose → Specs → Design → Pre-Flight → Tasks → Apply → Verify → Changelog → Docs → Version Bump

## Context

Always read and follow openspec/CONSTITUTION.md before proceeding.
All workflow artifacts (research, proposal, specs, design, preflight, tasks)
must be written in English regardless of docs_language.

## Post-Artifact Hook

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
