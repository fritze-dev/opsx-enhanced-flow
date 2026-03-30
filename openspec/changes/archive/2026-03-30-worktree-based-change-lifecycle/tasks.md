# Implementation Tasks: Worktree-Based Change Lifecycle

## 1. Foundation

- [x] 1.1. Create `src/templates/workflow.md` — extract current WORKFLOW.md content from `src/skills/setup/SKILL.md` into a template file, add commented-out `worktree:` section with `enabled`, `path_pattern`, `auto_cleanup` fields
- [x] 1.2. Update `openspec/WORKFLOW.md` — add commented-out `worktree:` section, update `post_artifact` to be worktree-aware (skip branch creation when already on feature branch)
- [x] 1.3. Update `src/skills/setup/SKILL.md` — replace inline WORKFLOW.md generation (Step 2) with copy from `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`; add environment checks step (gh CLI, git version, .gitignore); add worktree opt-in question; add merge strategy configuration

## 2. Implementation

- [x] 2.1. Update `src/skills/new/SKILL.md` — add worktree creation step after "Verify setup" (step 2): read `worktree.enabled` from WORKFLOW.md, if true run `git worktree add`, create change directory inside worktree, report path
- [x] 2.2. [P] Update `src/skills/ff/SKILL.md` — add worktree context detection preamble before "If no clear input provided"
- [x] 2.3. [P] Update `src/skills/apply/SKILL.md` — add worktree context detection preamble before "If a name is provided"
- [x] 2.4. [P] Update `src/skills/verify/SKILL.md` — add worktree context detection preamble before "If no change name provided"; update "Do NOT auto-select" guardrail to allow worktree detection
- [x] 2.5. [P] Update `src/skills/archive/SKILL.md` — add worktree context detection preamble before "If no change name provided"; update "Do NOT auto-select" guardrail; add worktree cleanup step after archive (step 5b)
- [x] 2.6. [P] Update `src/skills/sync/SKILL.md` — add worktree context detection preamble; update "Do NOT auto-select" guardrail
- [x] 2.7. [P] Update `src/skills/discover/SKILL.md` — add worktree context detection preamble
- [x] 2.8. [P] Update `src/skills/preflight/SKILL.md` — add worktree context detection preamble

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md — all 7 metrics PASS.
- [x] 3.2. Auto-Verify: Run `/opsx:verify` — 0 critical, 2 warnings fixed.
- [x] 3.3. User Testing: User reviewed all changes.
- [x] 3.4. Fix Loop: 2 verify warnings fixed, worktree enabled, auto_cleanup set to true.
- [x] 3.5. Final Verify: All 4 checks PASS.
- [x] 3.6. Approval: User approved.

## 4. Standard Tasks (Post-Implementation)

- [ ] 4.1. Archive change (`/opsx:archive`)
- [ ] 4.2. Generate changelog (`/opsx:changelog`)
- [ ] 4.3. Generate/update docs (`/opsx:docs`)
- [ ] 4.4. Commit and push to remote

### Pre-Merge
- [ ] 4.5. Update PR: mark ready for review, update body with change summary (`gh pr ready && gh pr edit --body "..."`)

### Post-Merge
- [ ] 4.6. Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
