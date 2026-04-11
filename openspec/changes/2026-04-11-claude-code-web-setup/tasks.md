# Implementation Tasks: Claude Code Web Setup

## 1. Foundation

- [ ] 1.1. Add `!/.claude/settings.json` negation rule to `.gitignore`

## 2. Implementation

- [ ] 2.1. [P] Create `.claude/settings.json` with `extraKnownMarketplaces`, `enabledPlugins`, and SessionStart hook
- [ ] 2.2. [P] Create `scripts/setup-remote.sh` — gated on `CLAUDE_CODE_REMOTE`, installs `gh` CLI, configures auth
- [ ] 2.3. [P] Make `scripts/setup-remote.sh` executable (`chmod +x`)
- [ ] 2.4. Update README.md with Claude Code Web section (setup docs, GH_TOKEN requirement, links)
- [ ] 2.5. Update `openspec/specs/project-init/spec.md` requirement reference in SKILL.md (add new requirement to init action's requirements list)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [ ] Plugin auto-installs in Claude Code Web session (`/opsx:workflow` responds) — requires manual test in Claude Code Web
  - [ ] `gh` CLI available after SessionStart hook (`gh --version`) — requires manual test
  - [ ] Script is a no-op locally (`CLAUDE_CODE_REMOTE` not set → exits 0)
  - [ ] `.claude/settings.json` is tracked by git (`git status` shows it)
- [ ] 3.2. Auto-Verify: generate review.md using the review template
- [ ] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix code OR update specs/design → re-verify.
- [ ] 3.5. Final Verify: regenerate review.md after all fixes. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Run `/opsx:workflow finalize` (generates changelog and updates docs)
- [ ] 4.2. Bump version
- [ ] 4.3. Commit and push to remote
- [ ] 4.4. Update PR: mark ready for review, update body with change summary and issue references if applicable (`gh pr ready && gh pr edit --body "... Closes #14"`)

## 5. Post-Merge Reminders

- Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
