---
id: verify
type: action
template-version: 1
description: Verify implementation matches change artifacts
requires: [apply]
instruction: |
  Run /opsx:verify for the current change.

  After /opsx:verify passes, commit and push all implementation changes
  before pausing for user approval:
  1. Stage all changed files: `git add -A`
  2. Commit: `git commit -m "WIP: <change-name> — implementation"`
  3. Push: `git push`
  If push fails, continue with local commit — do not block the workflow.
---
