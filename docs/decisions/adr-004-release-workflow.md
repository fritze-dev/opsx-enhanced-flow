# ADR-004: Release Workflow

## Status

Accepted — 2026-03-04

## Context

The plugin's update mechanism requires a version bump in `plugin.json` for the `/plugin update` command to detect changes in consumer projects. This version bump was a manual convention that was regularly forgotten, causing consumers to silently miss updates. Additionally, `marketplace.json` was out of sync at version 1.0.0 while `plugin.json` was at 1.0.3, creating further inconsistency. The project had no git tags, no CI/CD, no git hooks, and no documented release process. The research phase evaluated three approaches: auto-bump in archive only (prevents forgetting but offers no version control), a separate `/opsx:release` skill (full control but adds a manual step that can be forgotten — the same root problem), and a hybrid approach combining auto-bump for patches with manual process for minor/major releases (chosen). A key architectural constraint shaped the solution: skills are generic shared plugin code and must not contain project-specific behavior. Therefore, the auto-bump mechanism is implemented as a constitution convention rather than a skill modification, ensuring the archive skill remains generic while the project-specific behavior is defined where it belongs.

## Decision

1. **Convention in constitution, not skill modification** — Skills are shared across consumers and must remain generic. Project-specific behavior like version bumping belongs in the constitution, which the agent reads before executing any skill. This preserves skill immutability (GitHub Issue #10) while still achieving automated behavior.

2. **Patch-only auto-bump on archive** — Over 95% of changes are backwards-compatible patches. Auto-incrementing the patch version on every `/opsx:archive` run prevents the root cause of forgotten bumps. Minor and major version bumps are rare and intentional, requiring human decision.

3. **Sync marketplace.json in the same convention step** — When the auto-bump updates `plugin.json`, it also syncs `marketplace.json` to the same version in one operation. A separate sync convention was rejected as unnecessary complexity that could itself fall out of sync.

4. **Document manual minor/major process in docs page** — Minor and major releases are rare enough that a documentation page with clear instructions suffices. A dedicated `/opsx:release` skill was rejected as over-engineering for current needs.

## Alternatives Considered

- Modify archive skill directly with version bump logic — violates skill immutability principle; leaks project-specific behavior into shared code
- Separate `/opsx:release` skill — too much overhead for current needs; the manual step could be forgotten (same root problem as before)
- Manual-only version bumps (current broken state) — the root cause of the problem; regularly forgotten
- Auto-detect version bump type from changelog — complex and unreliable for determining patch vs. minor vs. major
- Separate convention for marketplace.json sync — unnecessary complexity; one operation prevents drift
- Dedicated skill for minor/major releases — over-engineering given how rare these are
- Bash test script for E2E testing — out of pattern for the project; a markdown checklist fits better given no existing test infrastructure
- CI/CD automation — out of scope; no infrastructure exists
- `/opsx:status` skill — separate feature, would add scope creep to this change

## Consequences

### Positive

- Version bumps can no longer be forgotten — every archive automatically increments the patch version
- `plugin.json` and `marketplace.json` stay permanently in sync via the same convention step
- Consumer projects reliably detect updates through `/plugin update`
- Skill immutability is preserved — archive skill remains generic shared code
- Constitution-based approach is extensible; consumer projects can customize or override the convention

### Negative

- Convention compliance depends on the agent reading and following the constitution; mitigated by constitution being read at the start of every skill execution as standard behavior
- Version inflation from many small patches is an accepted trade-off versus forgotten bumps that silently break the update flow
- No rollback mechanism for a bad version — consumers must wait for the next patch; acceptable at current project scale

## References

- [Change: release-workflow](../../openspec/changes/2026-03-04-release-workflow/)
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [ADR-002: Workflow Rule Ownership](adr-002-workflow-rule-ownership.md)
