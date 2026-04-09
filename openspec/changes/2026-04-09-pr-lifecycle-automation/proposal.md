---
status: active
branch: pr-lifecycle-automation
worktree: .claude/worktrees/pr-lifecycle-automation
capabilities:
  new: [ci-automation, autonomous-flow]
  modified: []
  removed: []
---
## Why

All post-implementation steps (changelog, docs, version-bump) are manual, creating friction and delay in the review-to-merge cycle. There is no way to run the full OpenSpec pipeline hands-off, and no CI automation reacts to PR lifecycle events beyond code review. Automating both the CI and local development paths eliminates manual steps while preserving quality gates.

## What Changes

- **New GitHub Action**: post-approval pipeline that runs changelog → docs → version-bump → commit → push automatically when a PR receives all required review approvals
- **Label-based state machine**: `automation/running`, `automation/complete`, `automation/failed` labels track pipeline progress on PRs
- **Opt-out/opt-in labels**: `skip-docs` to skip docs generation, `auto-merge` for automatic merge after successful pipeline
- **New `/opsx:auto` skill**: orchestrator that runs the full OpenSpec pipeline (research → ... → tasks → apply → verify → finalize) as a single command
- **Sub-agent architecture**: each pipeline step runs as an isolated sub-agent (via Agent tool) with only the relevant artifacts as input, solving context window exhaustion
- **Handoff protocol**: artifact existence + frontmatter validation serve as gates between agents; failed gates trigger rollback + error report

## Capabilities

### New Capabilities
- `ci-automation`: Post-approval pipeline automation via GitHub Actions — triggers on PR review approval, runs changelog/docs/version-bump, manages labels, supports opt-out and auto-merge
- `autonomous-flow`: End-to-end pipeline orchestrator (`/opsx:auto`) using sub-agents with artifact-based handoff protocol — each step reads predecessor artifacts and writes its own, enabling checkpoint/resume and bounded context per agent

### Modified Capabilities
None. Existing skills (verify, changelog, docs) are invoked as-is — no spec-level behavior changes needed.

### Removed Capabilities
None.

### Consolidation Check
1. Existing specs reviewed: `workflow-contract`, `quality-gates`, `release-workflow`, `human-approval-gate`, `task-implementation`, `artifact-pipeline`, `artifact-generation`
2. Overlap assessment:
   - `ci-automation` vs `release-workflow`: release-workflow defines version conventions, changelog format, and the release GitHub Action. ci-automation defines a NEW action triggered by PR approval events with label management — different actor (CI runner vs developer), different trigger (PR approval vs version push). Distinct.
   - `ci-automation` vs `quality-gates`: quality-gates defines verify/preflight behavior. ci-automation does NOT run verify in CI (decided: verify stays local). No overlap.
   - `autonomous-flow` vs `artifact-pipeline`: artifact-pipeline defines the artifact format and dependency chain. autonomous-flow defines an orchestrator that USES the pipeline via sub-agents. Different layer (orchestration vs format). Distinct.
   - `autonomous-flow` vs `task-implementation`: task-implementation defines the apply phase. autonomous-flow orchestrates apply as one step among many. Distinct.
3. Merge assessment: `ci-automation` and `autonomous-flow` share no actor (CI runner vs local agent), no trigger (PR event vs user command), and no data model (labels/status-checks vs Agent tool/artifacts). Keep separate.

## Impact

- **New files**: `.github/workflows/opsx-pipeline.yml`, `src/skills/auto/SKILL.md`
- **Modified files**: `openspec/CONSTITUTION.md` (add CI automation conventions)
- **Dependencies**: `claude-code-action@v1` (already used), `gh` CLI (already used)
- **No changes to existing skills**: verify, changelog, docs, ff, apply remain immutable

## Scope & Boundaries

**In scope:**
- Post-approval GitHub Action (one action)
- `/opsx:auto` orchestrator skill with sub-agent architecture
- Handoff protocol (artifact gates between agents)
- Label management for pipeline state tracking
- Auto-merge opt-in via label

**Out of scope:**
- CI-based verify (decided: verify stays local only)
- Pre-review automation (existing code-review action is sufficient)
- Changes to existing skills (skill immutability rule)
- Remote agent triggers (RemoteTrigger API — premature for MVP)
- Multi-project orchestration
