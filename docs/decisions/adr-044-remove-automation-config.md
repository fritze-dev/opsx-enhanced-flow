# ADR-044: Remove Automation Config

## Status
Accepted (2026-04-10)

## Context
The `automation` section in WORKFLOW.md was designed for CI-triggered finalize via GitHub Actions. A dedicated workflow file (`.github/workflows/pipeline.yml`) would trigger finalize automatically when a PR received the approved label. In practice, finalize runs locally via `/opsx:workflow finalize` and works cleanly. The CI automation infrastructure was never adopted by consumers -- the consumer template shipped with the automation block commented out. Keeping the automation section increased the conceptual surface area of the plugin, required additional GitHub Actions infrastructure, and added a requirement to the workflow-contract spec that no one used.

## Decision
Remove all automation config cleanly without a deprecation period -- no consumers depend on it (the consumer template had it commented out), so a deprecation notice would add process overhead with no audience. Skip editing historical change artifacts (e.g., the skill-consolidation change that introduced CI automation) -- they document what was true at that time, and editing them would falsify the historical record. Remove the `automation` mention from CONSTITUTION.md's template sync convention -- the convention specifically listed `worktree` and `automation` as fields to sync, and with automation gone only `worktree` needs the convention note.

## Alternatives Considered
- **Add deprecation notice first, remove later**: Unnecessary since no consumers use the feature -- the commented-out template block confirms it was opt-in and unadopted.
- **Edit historical change artifacts for consistency**: Would falsify the historical record; those artifacts document what was true at the time they were created.
- **Leave stale reference in CONSTITUTION.md template sync convention**: Would create confusion about a config field that no longer exists.

## Consequences

### Positive
- Simpler WORKFLOW.md frontmatter (6 fewer lines)
- Cleaner consumer template (no commented-out block to confuse new users)
- One fewer requirement in the workflow-contract spec to maintain
- No CI workflow file to keep in sync with local finalize behavior
- Reduced conceptual surface area for plugin adopters

### Negative
- If CI-triggered finalize is desired in the future, it must be re-implemented from scratch
- Historical change artifacts reference automation config that no longer exists (accepted trade-off to preserve historical accuracy)

## References
- Change: openspec/changes/2026-04-10-remove-automation-config/
- Spec: openspec/specs/workflow-contract/spec.md
- Issue: #100
