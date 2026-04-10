---
template-version: 3
templates_dir: openspec/templates
pipeline: [research, proposal, specs, design, preflight, tasks, review]

actions: [init, propose, apply, finalize]
# Add custom actions here (e.g. qa-review) and define matching
# ## Action: <name> sections in the body below.

worktree:
  enabled: true
  path_pattern: .claude/worktrees/{change}
  auto_cleanup: true

auto_approve: true

# docs_language: English
---

# Workflow

Research → Propose → Specs → Design → Pre-Flight → Tasks → Apply → Review → Finalize

## Context

Always read and follow openspec/CONSTITUTION.md before proceeding.
All workflow artifacts (research, proposal, specs, design, preflight, tasks, review)
must be written in English regardless of docs_language.

## Action: propose

### Instruction

Create change workspace if needed, then traverse the pipeline generating artifacts.
If no change exists: ask user what to build, derive kebab-case name, create workspace (with worktree if enabled).
Lazy worktree cleanup: before creating, check for stale worktrees (completed proposals or merged PRs) and clean up.
Checkpoint/resume: skip completed artifacts, resume from first incomplete step.
Design review checkpoint: when auto_approve is false, pause after design for user alignment. When auto_approve is true, skip the design checkpoint and continue.
Preflight checkpoint: PASS → continue, PASS WITH WARNINGS → pause for acknowledgment, BLOCKED → stop.
review artifact: when auto_approve is false, stop before review and suggest /opsx:workflow apply. When auto_approve is true, do not stop — auto-continue to apply.

## Action: init

### Instruction

Project initialization and health check.
Mode detection:
- Fresh (no WORKFLOW.md): install templates, scan codebase, generate constitution and CLAUDE.md
- Update (templates outdated): merge plugin template updates with local customizations
- Re-sync (all installed): detect spec drift (code vs specs) + docs drift (docs vs specs)
Report findings, suggest /opsx:workflow propose for changes needed.

## Action: apply

### Instruction

Implement tasks from tasks.md, then generate review.md.
QA loop: implement → generate review.md → fix if FAIL → regenerate review.md → until PASS.
Delete existing review.md before starting implementation.
When auto_approve is false, pause at user testing gate. When auto_approve is true and review.md verdict is PASS, skip user testing pause and auto-continue to finalize.
Fix loop: after any fix, regenerate review.md before presenting to user.
Artifact freshness: update preflight/design if fix resolves flagged issues.
Standard Tasks (post-implementation section) are NOT part of apply.
Constitution standard tasks: pre-merge executed during post-apply, post-merge remain as reminders.
Before committing, mark all standard task checkboxes as complete except post-merge.
After review.md PASS, commit and push implementation. When auto_approve is false, pause for user approval. When auto_approve is true, auto-continue to finalize.

## Action: finalize

### Instruction

Post-approval finalization, executed sequentially:
1. Changelog: incremental entries from completed change
2. Docs: regenerate affected capability docs, ADRs, README
3. Version-bump: increment patch in src/.claude-plugin/plugin.json, sync .claude-plugin/marketplace.json
On error in one step: continue with next, report failures at end.
Check review.md exists with verdict PASS before proceeding.
