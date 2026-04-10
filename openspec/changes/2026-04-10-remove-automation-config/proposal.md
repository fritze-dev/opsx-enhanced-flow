<!--
---
status: active
branch: worktree-remove-automation-config
capabilities:
  new: []
  modified: [workflow-contract]
  removed: []
---
-->
## Why

The `automation` section in WORKFLOW.md was designed for CI-triggered finalize via GitHub Actions. In practice, finalize runs locally and works cleanly. The CI automation adds unnecessary complexity, requires additional infrastructure (GitHub Actions, labels) that most consumers won't set up, and increases the conceptual surface area of the plugin. Closes #100.

## What Changes

- Remove `automation` frontmatter block from `openspec/WORKFLOW.md`
- Remove commented-out `automation` block from `src/templates/workflow.md` (consumer template)
- Remove "Automation Configuration" requirement from `workflow-contract` spec
- Remove `automation` from router frontmatter extraction list in `src/skills/workflow/SKILL.md`
- Delete `.github/workflows/pipeline.yml` (CI finalize workflow)
- Remove automation references from docs (`docs/capabilities/workflow-contract.md`, `docs/README.md`, `README.md`)
- Remove `automation` mention from template sync convention in `openspec/CONSTITUTION.md`

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `workflow-contract`: Remove "Automation Configuration" requirement and its two scenarios. Remove automation references from feature list and behavior sections.

### Removed Capabilities

(none)

### Consolidation Check

N/A — no new specs proposed. The only change is removing a requirement from the existing `workflow-contract` spec.

Existing specs reviewed: workflow-contract (directly affected), release-workflow (references CI automation convention but not automation config itself), project-init, artifact-pipeline, three-layer-architecture.

## Impact

- **WORKFLOW.md**: Frontmatter becomes simpler (6 fewer lines)
- **Consumer template**: Commented-out automation block removed (cleaner template)
- **CI**: `.github/workflows/pipeline.yml` deleted — no more CI-triggered finalize
- **Spec**: One requirement removed from workflow-contract
- **Docs**: Automation references cleaned from capability docs, architecture overview, and README
- **Router skill**: One fewer field extracted from frontmatter

No breaking change for consumers — the automation section was commented out in the consumer template.

## Scope & Boundaries

**In scope:**
- All automation config references listed in issue #100
- Spec, docs, template, and CI workflow updates

**Out of scope:**
- Historical change artifacts (e.g., `openspec/changes/2026-04-09-skill-consolidation/`) — these document what was true at the time
- Local finalize workflow — unchanged
- GitHub Actions for releases (`release.yml`), code review (`claude-code-review.yml`), or mentions (`claude.yml`) — unrelated
