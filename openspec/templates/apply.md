---
id: apply
type: action
template-version: 1
description: Implement tasks from the change's tasks.md
requires: [tasks]
instruction: |
  Read context files, work through pending tasks, mark complete as you go.
  Pause if you hit blockers or need clarification.

  Standard Tasks (post-implementation section) are NOT part of apply.
  They are tracked in tasks.md for auditability but executed separately
  after apply completes.

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

  Constitution standard tasks are split into pre-merge and post-merge.
  Only pre-merge tasks are executed during post-apply workflow.
  Post-merge tasks remain as unchecked reminders in tasks.md —
  they are executed manually after the PR is merged.

  Before committing, mark all standard task checkboxes in tasks.md
  as complete — including the commit step itself — EXCEPT post-merge
  tasks, which remain unchecked. No extra follow-up commit should be
  needed for pre-merge standard task checkboxes.
---
