# Implementation Tasks: Remove OpenSpec CLI Dependency

## 1. Foundation

- [x] 1.1. Update `openspec/constitution.md`: remove CLI from Tech Stack (lines 8-9, 11), update "skills depend on schema via CLI" to "skills depend on schema via direct file reads" (line 16)
- [x] 1.2. Update `openspec/schemas/opsx-enhanced/README.md`: remove Requirements section referencing CLI, update Installation text

## 2. Implementation

### Setup Skill (Major Rework)
- [x] 2.1. Rewrite `skills/setup/SKILL.md`: remove CLI installation steps (1, 2, 6), keep schema copy (3), config creation (4), constitution placeholder (5), add file-readability validation step, update description and output summary, remove `compatibility`/`generatedBy` frontmatter

### Core Workflow Skills
- [x] 2.2. [P] Update `skills/new/SKILL.md`: replace `openspec new` with `mkdir -p`, replace status/instructions calls with schema.yaml reads and file-existence checks, remove multi-schema selection logic, remove `compatibility`/`generatedBy`
- [x] 2.3. [P] Update `skills/continue/SKILL.md`: replace `openspec list` with directory listing, replace status with file-existence checks, replace instructions with schema.yaml + template reads, remove `compatibility`/`generatedBy`
- [x] 2.4. [P] Update `skills/ff/SKILL.md`: replace `openspec new` with `mkdir -p`, replace status with file-existence checks, replace instructions loop with schema.yaml + template reads, remove `compatibility`/`generatedBy`
- [x] 2.5. [P] Update `skills/apply/SKILL.md`: replace `openspec list` with directory listing, replace status with file-existence checks, replace instructions with schema.yaml reads, remove `compatibility`/`generatedBy`
- [x] 2.6. [P] Update `skills/verify/SKILL.md`: replace `openspec list` with directory listing, replace status with file-existence checks, replace instructions with schema.yaml reads, remove `compatibility`/`generatedBy`
- [x] 2.7. [P] Update `skills/archive/SKILL.md`: replace `openspec list` with directory listing, replace status with file-existence checks, remove `compatibility`/`generatedBy`
- [x] 2.8. [P] Update `skills/discover/SKILL.md`: replace schema-which with setup check, replace list with directory listing, replace instructions with schema.yaml + template reads
- [x] 2.9. [P] Update `skills/preflight/SKILL.md`: replace schema-which with setup check, replace list with directory listing, replace instructions with schema.yaml + template reads

### Minimal-Change Skills
- [x] 2.10. [P] Update `skills/bootstrap/SKILL.md`: replace schema-which with setup check, replace `openspec new` with `mkdir -p`
- [x] 2.11. [P] Update `skills/changelog/SKILL.md`: replace schema-which with setup check
- [x] 2.12. [P] Update `skills/docs/SKILL.md`: replace schema-which with setup check
- [x] 2.13. [P] Update `skills/sync/SKILL.md`: replace `openspec list` with directory listing, remove `compatibility`/`generatedBy`

### Documentation & Config
- [x] 2.14. Update `README.md`: remove CLI prerequisite (line 50), update "Built on" to "Inspired by" (line 27), update setup instructions
- [x] 2.15. Update `.devcontainer/devcontainer.json`: remove `openspec` postCreateCommand, remove `node` feature
- [x] 2.16. Clean up `.claude/settings.local.json`: remove all `openspec`-prefixed and `npm`/`npx openspec` Bash permissions

## 3. QA Loop & Human Approval
- [x] 3.1. Metric Check: grep skills for CLI command patterns — verify zero matches
- [x] 3.2. Metric Check: verify README has no CLI/npm prerequisites
- [x] 3.3. Metric Check: verify devcontainer has no Node.js or openspec references
- [x] 3.4. Auto-Verify: Run `/opsx:verify` (metric checks passed: zero CLI refs in skills, no CLI prereqs in README, no Node.js in devcontainer)
- [x] 3.5. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.6. Fix Loop: Added 3 additional delta specs (change-workspace, task-implementation, interactive-discovery) per user feedback.
- [x] 3.7. Final Verify: `/opsx:verify` passed — zero critical/warning/suggestion issues.
- [x] 3.8. Approval: User approved ("weiter").

## 4. Standard Tasks (Post-Implementation)
- [x] 4.1. Archive change (`/opsx:archive`)
- [x] 4.2. Generate changelog (`/opsx:changelog`)
- [x] 4.3. Generate/update docs (`/opsx:docs`)
- [x] 4.4. Commit and push to remote
- [x] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
- [ ] 4.6. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
