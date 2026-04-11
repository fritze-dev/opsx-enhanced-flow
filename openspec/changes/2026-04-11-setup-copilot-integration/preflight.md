# Pre-Flight Check: GitHub Copilot Coding Agent Setup

## A. Traceability Matrix

No spec-level requirements for this change (infrastructure/config only). Traceability is to the proposal and Issue #15.

- [x] copilot-instructions.md -> Proposal "What Changes" item 1 -> `.github/copilot-instructions.md`
- [x] copilot-setup-steps.yml -> Proposal "What Changes" item 2 -> `.github/copilot-setup-steps.yml`
- [x] skills symlink -> Proposal "What Changes" item 3 -> `.github/skills/workflow/SKILL.md`
- [x] constitution convention -> Proposal "What Changes" item 4 -> `openspec/CONSTITUTION.md`

## B. Gap Analysis

- **No gaps identified.** All four deliverables are clearly defined in the proposal.
- Edge case: symlink pointing to a renamed or moved skill file. Mitigated by the constitution's router immutability rule — `src/skills/workflow/SKILL.md` path is stable.

## C. Side-Effect Analysis

- **`.github/` directory**: Adding files to `.github/` does not affect existing workflows (`claude.yml`, `claude-code-review.yml`, `release.yml`).
- **CONSTITUTION.md**: Adding one convention line does not alter existing rules. No behavioral side effects.
- **Git symlinks**: Adding a symlink does not affect `git status` or `git diff` behavior for existing files.
- **Plugin source layout**: The symlink lives outside `src/`, so consumers' plugin caches are unaffected.

## D. Constitution Check

One constitution update needed: add sync convention for `copilot-instructions.md`. This is captured as a task and does not require changes to global architecture rules.

## E. Duplication & Consistency

- **copilot-instructions.md vs CLAUDE.md**: These serve different agents and will have different content. The constitution convention ensures they don't drift silently. Not a duplication concern — they're platform-specific entrypoints to the same project rules.
- **Skill symlink vs source**: By design — symlink ensures zero duplication.

## F. Assumption Audit

| Assumption | Source | Rating |
|-----------|--------|--------|
| Copilot resolves symlinks | design.md | Acceptable Risk — GitHub resolves symlinks in repo content; standard git behavior |
| Setup steps use Actions format | design.md | Acceptable Risk — documented in GitHub Copilot docs |

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifact for this change.

**Verdict: PASS** — No gaps, no blocking assumptions, no side effects on existing functionality.
