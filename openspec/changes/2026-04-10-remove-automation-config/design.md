<!--
---
has_decisions: true
---
-->
# Technical Design: Remove Automation Config

## Context

The `automation` section in WORKFLOW.md frontmatter was introduced during the skill consolidation change (2026-04-09) to support CI-triggered finalize via GitHub Actions. The feature is fully implemented with a pipeline.yml workflow, spec requirement, and documentation. However, finalize runs locally in practice, and no consumer has activated the CI automation path. This change removes the entire automation surface.

## Architecture & Components

**Files to modify (removals):**

| File | Change |
|------|--------|
| `openspec/WORKFLOW.md` | Remove `automation:` block (lines 17-23) |
| `src/templates/workflow.md` | Remove commented-out `# automation:` block |
| `openspec/specs/workflow-contract/spec.md` | Already done in specs stage — removed Automation Configuration requirement |
| `src/skills/workflow/SKILL.md` | Remove `, automation` from frontmatter extraction list |
| `.github/workflows/pipeline.yml` | Delete entire file |
| `docs/capabilities/workflow-contract.md` | Remove automation feature + behavior sections |
| `docs/README.md` | Remove "automation config" from architecture description |
| `README.md` | Remove CI automation references (3 locations) |
| `openspec/CONSTITUTION.md` | Remove `and \`automation\`` from template sync convention |

**Files NOT modified:**
- `openspec/changes/2026-04-09-skill-consolidation/` — historical artifacts, left as-is
- Other GitHub Action workflows (`release.yml`, `claude.yml`, `claude-code-review.yml`) — unrelated

## Goals & Success Metrics

* Zero references to `automation` config in active source files (WORKFLOW.md, templates, specs, skills, docs, README) — verified by grep
* `.github/workflows/pipeline.yml` deleted
* All remaining GitHub Action workflows (`release.yml`, `claude.yml`, `claude-code-review.yml`) still present and unchanged
* Spec version bumped in workflow-contract

## Non-Goals

- Removing other GitHub Action workflows (release, code review, mentions)
- Changing the local finalize workflow
- Editing historical change artifacts

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Clean removal, no deprecation | No consumers depend on it; commented-out template confirms it was opt-in | Add deprecation notice first, remove later |
| Skip historical change artifacts | They document what was true at that time; editing them would falsify history | Edit for consistency |
| Remove from CONSTITUTION.md template sync convention | The convention specifically mentioned `automation` alongside `worktree`; with automation gone, only `worktree` needs the convention note | Leave stale reference |

## Risks & Trade-offs

- **[Future CI automation need]** → If CI-triggered finalize is wanted later, it can be re-added. The GitHub Actions pattern is documented in git history.
- **[Stale historical references]** → Old change artifacts will still mention automation. This is acceptable as they're historical records.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
