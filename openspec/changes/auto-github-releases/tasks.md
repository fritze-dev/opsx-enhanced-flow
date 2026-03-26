# Implementation Tasks: Auto GitHub Releases + Plugin Source Restructuring

## 1. Foundation

- [x] 1.1. Smoke-test `source: "./src"`: Create minimal `src/` structure (mkdir `src/.claude-plugin`, `src/skills`, `src/templates`), move `plugin.json` to `src/.claude-plugin/`, copy one skill, update `marketplace.json` source to `"./src"`. Run `claude plugin update`, verify `claude plugin list` shows correct version. Check `CLAUDE_PLUGIN_ROOT` resolves to `src/`. **If this fails, STOP and reassess before continuing.**
- [x] 1.2. Verify agents discovery: Check if agents in the repo are still discovered after the `src/` restructuring. Run `/reload-plugins` and confirm "5 agents" still loads.

## 2. Implementation

### 2.1 Repository Restructuring

- [x] 2.1.1. Create `src/.claude-plugin/` directory
- [x] 2.1.2. Move `.claude-plugin/plugin.json` → `src/.claude-plugin/plugin.json`
- [x] 2.1.3. Move `skills/` → `src/skills/`
- [x] 2.1.4. Move `openspec/templates/` → `src/templates/` (project keeps its own copy at `openspec/templates/`)
- [x] 2.1.5. Update `.claude-plugin/marketplace.json`: change `source` from `"./"` to `"./src"`
- [x] 2.1.6. Remove old `.claude-plugin/plugin.json` (now in `src/`)

### 2.2 Reference Updates

- [x] 2.2.1. Update `src/skills/setup/SKILL.md`: change template copy path from `${CLAUDE_PLUGIN_ROOT}/openspec/templates/` to `${CLAUDE_PLUGIN_ROOT}/templates/`
- [x] 2.2.2. Update `openspec/CONSTITUTION.md`: version bump path to `src/.claude-plugin/plugin.json`, add auto-release convention, mention local marketplace for development
- [ ] 2.2.3. Update `.claude/settings.local.json`: add `Bash(git tag:*)` permission — BLOCKED: settings file edit rejected by stream, user must add manually
- [x] 2.2.4. [P] Update `CLAUDE.md` if it references skill paths or plugin structure — no changes needed

### 2.3 GitHub Action

- [x] 2.3.1. Create `.github/workflows/release.yml` with version-change trigger on `src/.claude-plugin/plugin.json`, tag creation, and GitHub Release with CHANGELOG.md extract

### 2.4 DevContainer

- [x] 2.4.1. Update `.devcontainer/devcontainer.json`: change postCreateCommand from `claude plugin marketplace add fritze-dev/opsx-enhanced-flow` to `claude plugin marketplace add . --scope user`

### 2.5 README

- [x] 2.5.1. Update "Development & Testing" section: replace `--plugin-dir .` with local marketplace workflow
- [x] 2.5.2. Update "Updating the Plugin" section: mention auto-releases and consumer version pinning via `#ref`
- [x] 2.5.3. Add `src/` structure explanation to project overview or architecture section
- [x] 2.5.4. Update consumer install notes if they reference the old structure

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] `claude plugin list` shows correct version from `src/` after local marketplace update — PASS / FAIL
  - [ ] Consumer cache at `~/.claude/plugins/cache/opsx-enhanced-flow/opsx/<version>/` contains only `src/` contents — PASS / FAIL
  - [ ] `/opsx:setup` in a test project copies templates from `${CLAUDE_PLUGIN_ROOT}/templates/` — PASS / FAIL
  - [ ] `/reload-plugins` picks up SKILL.md changes from `src/skills/` — PASS / FAIL
  - [ ] GitHub Action creates tag + release on simulated version change (verify after merge) — PASS / FAIL
- [ ] 3.2. Auto-Verify: Run `/opsx:verify`
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote
- [ ] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)
