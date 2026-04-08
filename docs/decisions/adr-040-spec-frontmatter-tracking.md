# ADR-040: Spec Frontmatter Tracking

## Status

Accepted (2026-04-08)

## Context

With delta specs eliminated (ADR-037), the codebase relies on fragile markdown-section parsing across 6+ skills to identify affected capabilities, detect active/completed changes, and determine incremental doc regeneration targets. Skills like verify, changelog, docs, and preflight parse the proposal's `## Capabilities` section to identify affected specs — a pattern that breaks silently on older changes and triggers overly broad fallbacks. Setup overwrites user-customized templates via `cp -r` on every re-run, silently destroying customizations (#67). Active/completed change detection relies on parsing tasks.md checkboxes, which is slow and fragile. Worktree context detection relies on naming conventions (branch name matching directory glob) rather than structured metadata. The investigation identified four layers of frontmatter needed: spec tracking (status/version/lastModified), proposal metadata (status/branch/capabilities), design metadata (has_decisions), and template versioning (template-version).

## Decision

1. **Spec `version` is content-version (integer bumped per change), template `template-version` is source-version (integer bumped per plugin release)** — Different semantics need different names to avoid confusion. Using `version` for both would be ambiguous: spec version tracks content changes by the change workflow, while template-version tracks plugin source changes by the maintainer.

2. **Proposal frontmatter is set at proposal generation, not at change creation** — The proposal is the first artifact with enough context (branch, capabilities); research.md does not know capabilities yet. Setting it at `/opsx:new` is too early (no capabilities known); setting it at the specs stage is too late (other skills already need branch info).

3. **Fallback to markdown parsing when frontmatter absent** — Backward compatibility with existing 40+ changes that have no frontmatter. Requiring migration of all existing proposals would be disruptive; ignoring old changes would cause data loss.

4. **`has_decisions` boolean in design.md rather than `decisions_count` integer** — Binary check is all docs/docs-verify need — "skip or scan." Count adds no value for this use case and would require maintaining accuracy on every edit.

5. **CONSTITUTION.md uses section-level merge, not full-body merge** — Constitution content is user-generated (via bootstrap); only structural additions from template updates are mergeable. Full overwrite destroys user content; skipping entirely means users miss new sections.

6. **WORKFLOW.md included in template-version merge (replaces skip-if-exists)** — Skip-if-exists means consumers never get plugin updates to `apply.instruction`, `post_artifact`, etc. — the most common source of workflow bugs. Version-based merge preserves user-specific fields (`worktree`, `docs_language`) while delivering behavioral updates.

## Alternatives Considered

- Same field name `version` for both spec and template versions — rejected because the different semantics (content vs. source) would confuse skills and maintainers
- Semver for specs — rejected as overkill; an integer is sufficient for monotonic tracking
- Set proposal frontmatter at `/opsx:new` — rejected because no capabilities are known yet at workspace creation time
- Set proposal frontmatter at specs stage — rejected because other skills need branch info before specs are generated
- Require migration of all existing proposals — rejected as too disruptive for 40+ existing changes
- `decisions_count` integer in design.md — rejected because the count adds no value when a boolean suffices
- Full-body overwrite for CONSTITUTION.md — rejected because it destroys user-generated content
- Skip CONSTITUTION.md entirely during template updates — rejected because users miss structural additions from newer templates
- Keep skip-if-exists for WORKFLOW.md — rejected because it leaves consumers with stale behavioral fields
- Always overwrite WORKFLOW.md — rejected because it destroys user-specific configuration (worktree, docs_language)

## Consequences

### Positive

- Skills identify affected capabilities via frontmatter field lookup instead of parsing markdown sections, eliminating fragile text parsing
- Spec collision detection prevents two changes from silently editing the same spec simultaneously
- Incremental doc generation uses spec `lastModified` for direct comparison, removing the need for change directory scanning
- Template merge on re-setup preserves user customizations while delivering plugin updates
- Active/completed change detection is instant via proposal `status` field instead of parsing tasks.md checkboxes
- Draft spec gate in verify prevents unfinished specs from reaching the main branch

### Negative

- Plugin maintainers must remember to bump `template-version` when changing template content; if forgotten, consumers receive no update
- Proposal frontmatter `capabilities` field is set once at generation and not maintained on body edits — if the user manually edits the Capabilities section, skills use stale frontmatter. Mitigated by preflight cross-checking.
- Template-version merge adds complexity to the setup skill, though the heuristic (version match + content hash) keeps it manageable
- Stale draft specs on abandoned branches are harmless (only exist on PR branches, verify gate prevents merge) but may cause confusion if inspected directly

## References

- [Change: spec-frontmatter-tracking](../../openspec/changes/2026-04-08-spec-frontmatter-tracking/)
- [Spec: spec-format](../../openspec/specs/spec-format/spec.md)
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [Spec: quality-gates](../../openspec/specs/quality-gates/spec.md)
- [Spec: workflow-contract](../../openspec/specs/workflow-contract/spec.md)
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [Spec: change-workspace](../../openspec/specs/change-workspace/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [ADR-037: Eliminate Delta Specs](adr-037-eliminate-delta-specs-sync-and-archive.md)
