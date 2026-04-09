---
id: tasks
template-version: 1
description: Implementation checklist with QA loop
generates: tasks.md
requires: [preflight]
instruction: |
  Create a clean implementation checklist based on design and pre-flight.
  Use `- [ ]` checkbox format — the apply phase parses these for tracking.
  Group tasks under ## numbered headings by dependency: foundational/shared work first, then features.
  Tasks should be small enough to complete in one session.
  Mark parallelizable tasks with `[P]`.
  Where applicable, place test tasks before their implementation tasks.
  Carry over every Success Metric from design.md as a PASS/FAIL checkbox
  in the QA Loop (before Auto-Verify).
  Add the QA loop with an explicit human approval gate.

  Definition of Done is emergent from artifacts — there is no
  separate DoD checklist. Gherkin scenarios define functional
  completeness, success metrics define quality targets, preflight
  findings define risk resolution, and explicit user approval
  gates implementation completeness.

  The apply phase covers implementation and QA (sections 1-3).
  For documentation-only changes (no code), implementation sections may
  be empty — the QA loop alone is sufficient.

  Standard Tasks: The template includes a section 4 with universal
  post-implementation steps (changelog, docs, version bump, push).
  Always include this section as-is. If the project constitution defines
  a "## Standard Tasks" section with a "### Pre-Merge" subsection,
  append those pre-merge items (as `- [ ]` checkboxes) after the
  universal steps in section 4.

  Post-Merge Reminders: If the constitution's Standard Tasks has a
  "### Post-Merge" subsection, add a separate section 5 titled
  "Post-Merge Reminders". Copy post-merge items as plain `- ` bullets
  (no checkbox, no numbering). These are not tracked tasks — just
  reminders for manual execution after the PR is merged. If no
  Post-Merge subsection exists, omit section 5 entirely.
---
# Implementation Tasks: [Feature Name]

## 1. Foundation
<!-- Shared infrastructure, setup, dependencies — must complete first -->
- [ ] 1.1. [Task description]

## 2. Implementation
<!-- Group by feature/story. Mark independent tasks with [P]. -->
- [ ] 2.1. [P] [Task description]
- [ ] 2.2. [Task description]

## 3. QA Loop & Human Approval
- [ ] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL.
- [ ] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command).
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify. Specs must match code before proceeding.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)
<!-- Universal post-implementation steps. Always include this section.
     If the constitution defines ## Standard Tasks > ### Pre-Merge, append those items after these. -->
- [ ] 4.1. Generate changelog (`/opsx:changelog`)
- [ ] 4.2. Generate/update docs (`/opsx:docs`)
- [ ] 4.3. Bump version
- [ ] 4.4. Commit and push to remote

## 5. Post-Merge Reminders
<!-- Not tracked as tasks. Executed manually after the PR is merged.
     If the constitution defines ## Standard Tasks > ### Post-Merge, copy those items here as plain bullets.
     Omit this section entirely if no post-merge items exist. -->
