# Implementation Tasks: SpecShift Beta Restructure

## 1. Foundation (Repo Duplication)

- [ ] 1.1. Create empty `specshift` repo on GitHub (fritze-dev/specshift)
- [ ] 1.2. Bare clone current repo: `git clone --bare git@github.com:fritze-dev/opsx-enhanced-flow.git`
- [ ] 1.3. Change remote URL to new repo: `git remote set-url origin git@github.com:fritze-dev/specshift.git`
- [ ] 1.4. Mirror push: `git push --mirror`
- [ ] 1.5. Clone new repo locally, create branch `feat/specshift-beta`

## 2. Implementation

### Commit 1: File Moves (git mv only, no content edits)

- [ ] 2.1. Create `.specshift/` directory
- [ ] 2.2. `git mv openspec/WORKFLOW.md .specshift/WORKFLOW.md`
- [ ] 2.3. `git mv openspec/CONSTITUTION.md .specshift/CONSTITUTION.md`
- [ ] 2.4. `git mv openspec/templates .specshift/templates`
- [ ] 2.5. `git mv openspec/changes .specshift/changes`
- [ ] 2.6. Create `docs/specs/` directory, flatten specs: `git mv openspec/specs/<name>/spec.md docs/specs/<name>.md` for all 14 specs
- [ ] 2.7. `git mv src/skills/workflow src/skills/specshift`
- [ ] 2.8. `git rm -r .agents/` (broken symlinks)
- [ ] 2.9. `git rm -r .claude/skills/` (workaround symlinks)
- [ ] 2.10. `git rm AGENTS.md` (replaced by CLAUDE.md)
- [ ] 2.11. Remove empty `openspec/` directory
- [ ] 2.12. Commit: "Restructure: git mv to SpecShift layout"

### Commit 2: Content Edits (paths, branding, commands)

- [ ] 2.13. [P] Update `src/skills/specshift/SKILL.md` — all `openspec/` paths → `.specshift/` and `docs/specs/`, all `workflow` commands → `specshift`, all requirement anchor links updated for flat filenames
- [ ] 2.14. [P] Update all templates in `src/templates/` (14 files) — `openspec/` paths → `.specshift/` and `docs/specs/`, `workflow` commands → `specshift`, debrand
- [ ] 2.15. [P] Update `.specshift/WORKFLOW.md` — `templates_dir: .specshift/templates`, context path to `.specshift/CONSTITUTION.md`, all `workflow` → `specshift` in action instructions
- [ ] 2.16. [P] Update `.specshift/CONSTITUTION.md` — all self-referential paths, plugin name `opsx` → `specshift`, repo name, skill path `skills/specshift/`, remove `.agents/` and `AGENTS.md` conventions, update standard tasks commands
- [ ] 2.17. [P] Update `src/.claude-plugin/plugin.json` — `"name": "specshift"`, `"version": "0.1.0-beta"`, repo URL
- [ ] 2.18. [P] Update `.claude-plugin/marketplace.json` — plugin name → `specshift`, version → `0.1.0-beta`
- [ ] 2.19. [P] Update `.devcontainer/devcontainer.json` — `opsx` references → `specshift`
- [ ] 2.20. [P] Update `.claude/settings.json` — marketplace and plugin references → `specshift`
- [ ] 2.21. Commit: "Update: paths, branding, and commands to SpecShift"

### Commit 3: New Files

- [ ] 2.22. Create `CLAUDE.md` — ultra-lean agent entry point (from template)
- [ ] 2.23. Rename `src/templates/agents.md` → `src/templates/claude.md` (template for CLAUDE.md generation)
- [ ] 2.24. Write `README.md` — SpecShift branding, new install flow (`claude plugin install specshift` / `specshift init` / `specshift propose`)
- [ ] 2.25. Write `CHANGELOG.md` — fresh start with v0.1.0-beta entry
- [ ] 2.26. Write `docs/decisions/adr-001-specshift-v1-architecture.md` — documents the restructuring decision
- [ ] 2.27. Commit: "Add: CLAUDE.md, README, CHANGELOG, ADR-001"

### Commit 4: Historical Cleanup

- [ ] 2.28. Flatten per-change spec snapshots in `.specshift/changes/*/specs/` — `spec.md` → `<name>.md`
- [ ] 2.29. `git rm` old ADRs in `docs/decisions/` (except adr-001)
- [ ] 2.30. `git rm` old capability docs in `docs/capabilities/` (regenerated at v1.0)
- [ ] 2.31. `git rm` old `docs/README.md` (regenerated at v1.0)
- [ ] 2.32. Check `.github/copilot-setup-steps.yml` for stale references, update if needed
- [ ] 2.33. Commit: "Cleanup: flatten snapshots, remove stale docs"

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric: `grep -r "openspec/" --include="*.md" --include="*.json" . | grep -v ".specshift/changes/"` returns 0 results
- [ ] 3.2. Metric: `specshift init` in a fresh test project creates correct `.specshift/` structure
- [ ] 3.3. Metric: `specshift propose test-feature` creates `.specshift/changes/YYYY-MM-DD-test-feature/` and traverses pipeline
- [ ] 3.4. Metric: All 14 spec files at `docs/specs/<name>.md` (flat, no directories)
- [ ] 3.5. Metric: `git log --follow docs/specs/artifact-pipeline.md` shows history from before rename
- [ ] 3.6. Metric: Plugin installs as `specshift` via `claude plugin install specshift`
- [ ] 3.7. Auto-Verify: generate review.md using the review template
- [ ] 3.8. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.9. Fix Loop: On verify issues or bug reports → fix → re-verify.
- [ ] 3.10. Final Verify: regenerate review.md after all fixes. Skip if 3.9 was not entered.
- [ ] 3.11. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `specshift finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update specshift && claude plugin update specshift`)
- Archive old repo `opsx-enhanced-flow` on GitHub (set read-only, add redirect note in README)
- Tag `v0.1.0-beta` on new repo
