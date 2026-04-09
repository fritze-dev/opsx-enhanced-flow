---
template-version: 3
templates_dir: openspec/templates
pipeline: [research, proposal, specs, design, preflight, tasks, review]

actions:
  init:
    specs:
      - project-init:
        - Install OpenSpec Workflow
        - Template Merge on Re-Init
        - First-Run Codebase Scan
        - Constitution Generation
        - Documentation Drift Verification
      - constitution-management:
        - Constitution Lifecycle
      - quality-gates:
        - Pre-Implementation Quality Checks
    instruction: |
      Project initialization and health check.
      Mode detection:
      - Fresh (no WORKFLOW.md): install templates, scan codebase, generate constitution
      - Update (templates outdated): merge plugin template updates with local customizations
      - Re-sync (all installed): detect spec drift (code vs specs) + docs drift (docs vs specs)
      Report findings, suggest /opsx:propose for changes needed.

  apply:
    specs:
      - task-implementation:
        - Implement Tasks from Task List
        - Progress Tracking
        - Standard Tasks Exclusion from Apply Scope
        - Spec Edits During Implementation
      - quality-gates:
        - Post-Implementation Verification
    instruction: |
      Implement tasks from tasks.md, then generate review.md.
      QA loop: implement → generate review.md → fix if FAIL → regenerate review.md → until PASS.
      Delete existing review.md before starting implementation.
      Pause only at user testing gate.
      Fix loop: after any fix, regenerate review.md before presenting to user.
      Artifact freshness: update preflight/design if fix resolves flagged issues.
      Standard Tasks (post-implementation section) are NOT part of apply.
      Constitution standard tasks: pre-merge executed during post-apply, post-merge remain as reminders.
      Before committing, mark all standard task checkboxes as complete except post-merge.
      After review.md PASS, commit and push implementation before pausing for user approval.

  finalize:
    specs:
      - release-workflow:
        - Changelog Generation
        - Version Bump Convention
      - documentation:
        - Generate Enriched Capability Documentation
        - Incremental Generation
        - Generate Architecture Overview
        - ADR Generation
    instruction: |
      Post-approval finalization, executed sequentially:
      1. Changelog: incremental entries from completed change
      2. Docs: regenerate affected capability docs, ADRs, README
      3. Version-bump: increment patch in src/.claude-plugin/plugin.json, sync .claude-plugin/marketplace.json
      On error in one step: continue with next, report failures at end.
      Check review.md exists with verdict PASS before proceeding.

worktree:
  enabled: true
  path_pattern: .claude/worktrees/{change}
  auto_cleanup: true

# auto_approve: true

automation:
  post_approval:
    action: finalize
    labels:
      running: automation/running
      complete: automation/complete
      failed: automation/failed

# docs_language: English
---

# Workflow

Research → Propose → Specs → Design → Pre-Flight → Tasks → Apply → Review → Finalize

## Context

Always read and follow openspec/CONSTITUTION.md before proceeding.
All workflow artifacts (research, proposal, specs, design, preflight, tasks, review)
must be written in English regardless of docs_language.

## Post-Artifact Hook

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
