---
status: active
branch: tool-agnostic-github-ops
worktree: .claude/worktrees/tool-agnostic-github-ops
capabilities:
  new: []
  modified: [artifact-pipeline, change-workspace]
  removed: []
---
## Why

Claude Code Web ships with built-in GitHub MCP tools — no `gh` CLI needed. Our specs, skills, and docs hardcode `gh` CLI commands where intent-based language would make the plugin work seamlessly across all environments (Web MCP, Desktop gh CLI, or no GitHub tooling at all).

## What Changes

- Replace hardcoded `gh` CLI commands with intent-based descriptions ("create a draft PR" instead of `gh pr create --draft`) in specs, skill, constitution, and README
- Update scenario wording from "gh CLI is installed" to "GitHub tooling is available"
- Update README to reflect that Claude Code Web has built-in GitHub tools and `gh` CLI is optional
- Update assumption in artifact-pipeline spec

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `artifact-pipeline`: Update "Post-Artifact Commit and PR Integration" requirement and scenarios to use tool-agnostic language; update assumption
- `change-workspace`: Update "Lazy Worktree Cleanup" and "Post-Merge Worktree Cleanup" requirements and scenarios to use tool-agnostic language

### Removed Capabilities
(none)

### Consolidation Check
N/A — no new specs proposed.

Existing specs reviewed: artifact-pipeline, change-workspace, task-implementation, quality-gates, human-approval-gate, release-workflow, documentation, project-init, constitution-management. Only artifact-pipeline and change-workspace contain `gh` CLI references in their requirements.

## Impact

- **Specs**: `artifact-pipeline/spec.md`, `change-workspace/spec.md` — requirement text and scenario wording changes
- **Skill**: `src/skills/workflow/SKILL.md` — one line change in propose dispatch
- **Constitution**: `openspec/CONSTITUTION.md` — pre-merge standard task wording
- **Docs**: `README.md` — setup section rewrite
- No behavioral changes — runtime is already tool-agnostic (Claude picks the tool)

## Scope & Boundaries

**In scope:**
- Spec requirements and scenarios in artifact-pipeline and change-workspace
- SKILL.md propose dispatch instructions
- CONSTITUTION.md standard tasks
- README.md setup documentation

**Out of scope:**
- ADRs (historical documents, stay as-is)
- `.github/workflows/release.yml` (CI correctly uses `gh` on Actions runners)
- CHANGELOG.md (historical entries)
- Test artifacts from prior changes
- Edge cases section wording in specs (already uses "gh CLI unavailable" which maps to the broader "no GitHub tooling" concept)
