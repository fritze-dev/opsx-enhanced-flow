---
status: active
branch: pr-lifecycle-automation
worktree: .claude/worktrees/pr-lifecycle-automation
capabilities:
  new: []
  modified: [workflow-contract, release-workflow]
  removed: []
---
## Why

All post-implementation steps (changelog, docs, version-bump) are manual, creating friction and delay in the review-to-merge cycle. There is no way to run the full OpenSpec pipeline hands-off, and no CI automation reacts to PR lifecycle events beyond code review. Automating both the CI and local development paths eliminates manual steps while preserving quality gates.

## What Changes

- **WORKFLOW.md restructuring**: Clean separation — structured config in YAML frontmatter (~20 lines), prose instructions in markdown body sections. `apply.instruction` (~50 lines) eliminated, distributed across action templates. `post_artifact` and `context` move from frontmatter to body sections.
- **WORKFLOW.md `automation` block**: new frontmatter section defining CI trigger behavior (post-approval pipeline steps, labels). WORKFLOW.md defines WHAT to do; a thin GitHub Action YAML defines WHEN to trigger.
- **Thin trigger YAML** (`.github/workflows/pipeline.yml`): minimal workflow triggered by PR approval, reads WORKFLOW.md `automation` config, delegates to `claude-code-action`. No pipeline logic in the YAML itself.
- **Label-based state machine**: `automation/running`, `automation/complete`, `automation/failed` labels track pipeline progress on PRs
- **Extended `/opsx:ff`**: ff reads the full pipeline (including action steps like apply, verify, changelog, docs, version-bump) and executes everything. Optional `--auto-approve` flag for fully autonomous execution.
- **Sub-agent architecture**: each pipeline step runs as an isolated sub-agent (via Agent tool) with only the relevant artifacts as input, solving context window exhaustion
- **Action templates**: new `type: action` templates for non-artifact pipeline steps (actions handle their own idempotency, no status tracking needed)
- **Post-approval pipeline automation**: changelog → docs → version-bump → commit → push runs automatically on PR review approval

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `workflow-contract`: Add `automation` section to WORKFLOW.md frontmatter for CI trigger configuration. Extend Smart Template format with `type: action`. Extend Skill Reading Pattern with sub-agent execution for action steps. Extend ff to execute full pipeline including action steps.
- `release-workflow`: Add post-approval CI pipeline requirement — automated execution of changelog → docs → version-bump on PR review approval, with label state tracking.

### Removed Capabilities
None.

### Consolidation Check
1. Existing specs reviewed: `workflow-contract`, `quality-gates`, `release-workflow`, `human-approval-gate`, `task-implementation`, `artifact-pipeline`, `artifact-generation`
2. Overlap assessment:
   - CI automation config naturally belongs in `workflow-contract` — WORKFLOW.md is already the pipeline orchestration contract, adding an `automation` block extends it without creating a new concept
   - Post-approval pipeline steps (changelog, docs, version-bump) are already defined as conventions in `release-workflow` — automating their CI execution is a requirement extension, not a new capability
   - Full pipeline orchestration extends `/opsx:ff` with sub-agent execution for action steps — same skill reading pattern, no new skill needed
   - Handoff protocol is already implicit in the pipeline contract (artifact existence + frontmatter = dependency gates)
3. Merge assessment: N/A — no new specs proposed

## Impact

- **New files**: `.github/workflows/pipeline.yml` (thin trigger YAML), action templates in `openspec/templates/` (apply.md, verify.md, changelog.md, docs.md, version-bump.md) and consumer copies in `src/templates/`
- **Modified files**: `openspec/WORKFLOW.md` (restructure frontmatter/body, extend `pipeline`, add `automation`), `src/templates/workflow.md` (consumer template sync, bump template-version to 2), `src/skills/ff/SKILL.md` (action-type templates + sub-agents + body section reading), `src/skills/apply/SKILL.md` (read instruction from template instead of WORKFLOW.md), `openspec/CONSTITUTION.md` (add CI automation conventions, worktree lifecycle section)
- **Dependencies**: `claude-code-action@v1` (already used), `gh` CLI (already used)
- **No new skills**: ff extended to handle action steps (plugin-level enhancement, not project-specific — allowed per immutability rule)

## Scope & Boundaries

**In scope:**
- Post-approval GitHub Action (thin trigger YAML + WORKFLOW.md config)
- Extended ff with sub-agent architecture for action steps
- Action template format (`type: action`)
- Handoff protocol (artifact gates between agents)
- Label management for pipeline state tracking

**Out of scope:**
- CI-based verify (decided: verify stays local only)
- Pre-review automation (existing code-review action is sufficient)
- New skills (ff extended instead)
- Remote agent triggers (RemoteTrigger API — premature for MVP)
- Multi-project orchestration
