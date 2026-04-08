---
has_decisions: true
---
# Technical Design: Spec Frontmatter Tracking

## Context

With delta-specs eliminated (ADR-037), the codebase relies on fragile markdown-section parsing across 6+ skills to identify affected capabilities, detect active/completed changes, and determine incremental doc regeneration targets. Setup overwrites user-customized templates on every re-run. This change introduces structured YAML frontmatter across specs, proposals, designs, and templates to make all detection patterns machine-readable.

Current state:
- 18 specs with only `order`/`category` frontmatter
- 11 templates with no version tracking
- 6+ skills parsing `## Capabilities` sections in proposals
- Active/completed detection via tasks.md checkbox parsing
- Setup uses `cp -r` (overwrite) for templates and skip-if-exists for WORKFLOW.md/CONSTITUTION.md

## Architecture & Components

### Layer 1: Spec Frontmatter (persistent, in `openspec/specs/*/spec.md`)
```yaml
---
order: 8
category: development
status: stable          # stable | draft
change: 2026-04-08-x   # only when draft
version: 3
lastModified: 2026-04-08
---
```
**Written by**: FF skill (specs stage), verify skill (completion)
**Read by**: docs, changelog, preflight, verify, FF (collision detection)

### Layer 2: Proposal Frontmatter (per-change, in `openspec/changes/*/proposal.md`)
```yaml
---
status: active          # active | completed
branch: feature-x
worktree: .claude/worktrees/feature-x  # optional
capabilities:
  new: [user-auth]
  modified: [quality-gates]
  removed: []
---
```
**Written by**: FF/new skill (proposal stage)
**Read by**: verify, preflight, changelog, docs, apply, docs-verify, change detection, lazy cleanup

### Layer 3: Design Frontmatter (per-change, in `openspec/changes/*/design.md`)
```yaml
---
has_decisions: true
---
```
**Written by**: FF skill (design stage)
**Read by**: docs, docs-verify (ADR generation skip)

### Layer 4: Template Versioning (plugin source, in `src/templates/*.md` + `src/templates/workflow.md`)
```yaml
---
id: research
template-version: 1
# ... existing fields ...
---
```
**Written by**: Plugin maintainer (manual bump on template changes)
**Read by**: Setup skill (merge detection)

### Affected Files

| File | Change |
|---|---|
| `src/templates/specs/spec.md` | Add tracking fields to output template |
| `src/templates/proposal.md` | Add frontmatter block to output template |
| `src/templates/design.md` | Add `has_decisions` to output template |
| `src/templates/*.md` (all 10) | Add `template-version: 1` to frontmatter |
| `src/templates/workflow.md` | Add `template-version: 1` to frontmatter |
| `src/templates/constitution.md` | Add `template-version: 1` to frontmatter |
| `openspec/templates/*.md` (all 10) | Mirror `src/templates/` changes |
| `openspec/templates/specs/spec.md` | Mirror spec template changes |
| `openspec/WORKFLOW.md` | Add `template-version: 1` to frontmatter |
| `openspec/CONSTITUTION.md` | Add `template-version: 1` to frontmatter |
| `openspec/specs/*/spec.md` (18 files) | Add `status: stable`, `version: 1`, `lastModified: 2026-04-08` |
| `src/skills/ff/SKILL.md` | Set spec draft status + collision detection; set proposal/design frontmatter |
| `src/skills/new/SKILL.md` | Set proposal frontmatter at change creation |
| `src/skills/verify/SKILL.md` | Draft gate + completion flip (spec + proposal); read capabilities from frontmatter |
| `src/skills/changelog/SKILL.md` | Read proposal status + capabilities from frontmatter |
| `src/skills/docs/SKILL.md` | Read spec lastModified + proposal capabilities from frontmatter; design has_decisions |
| `src/skills/setup/SKILL.md` | Template merge detection via template-version |
| `src/skills/preflight/SKILL.md` | Draft spec validation + read capabilities from frontmatter |
| `src/skills/apply/SKILL.md` | Read capabilities from proposal frontmatter |
| `src/skills/docs-verify/SKILL.md` | Read proposal status + capabilities; design has_decisions |
| `src/skills/discover/SKILL.md` | Read proposal status for active change detection |

## Goals & Success Metrics

* All 18 existing specs have `status: stable`, `version: 1`, `lastModified: 2026-04-08` in frontmatter — PASS/FAIL
* All 11 templates + workflow.md have `template-version: 1` in frontmatter — PASS/FAIL
* FF skill sets `status: draft`, `change`, `lastModified` when editing specs — PASS/FAIL via manual test
* Verify completion flips `draft → stable`, bumps `version`, sets `lastModified`, sets proposal `status: completed` — PASS/FAIL via scenario walkthrough
* No skill parses `## Capabilities` section as primary detection (all use frontmatter with fallback) — PASS/FAIL via grep for "Capabilities section" in skills without "fallback" context
* Setup detects user-customized templates via `template-version` comparison — PASS/FAIL via scenario walkthrough
* Verify blocks merge when specs have `status: draft` — PASS/FAIL via scenario walkthrough

## Non-Goals

- Automated migration of existing change proposals (they remain without frontmatter; skills fall back gracefully)
- Create date tracking in specs (can be added later)
- Task-level frontmatter (tasks.md changes too frequently)
- Proposal `capabilities` field auto-sync with body (set once at generation, not maintained on body edits)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Spec `version` is content-version (bumped per change), template `template-version` is source-version (bumped per plugin release) | Different semantics need different names to avoid confusion | Same field name `version` for both (confusing); semver for specs (overkill — integer is sufficient) |
| Proposal frontmatter is set at proposal generation, not at change creation | Proposal is the first artifact with enough context (branch, capabilities); research.md doesn't know capabilities yet | Set at `/opsx:new` (too early — no capabilities known); set at specs stage (too late — other skills already need branch info) |
| Fallback to markdown parsing when frontmatter absent | Backward compatibility with existing 40+ changes that have no frontmatter | Require migration of all existing proposals (disruptive); ignore old changes (data loss) |
| `has_decisions` boolean in design.md rather than `decisions_count` integer | Binary check is all docs/docs-verify need — "skip or scan". Count adds no value for this use case. | `decisions_count` (more data but unused); parse table every time (current fragile approach) |
| CONSTITUTION.md uses section-level merge, not full-body merge | Constitution content is user-generated (bootstrap); only structural additions from template updates are mergeable | Full overwrite (destroys user content); skip entirely (users miss new sections) |
| WORKFLOW.md included in template-version merge (replaces skip-if-exists) | Skip-if-exists means consumers never get plugin updates to apply.instruction, post_artifact, etc. — the most common source of workflow bugs | Keep skip-if-exists (safe but stale); always overwrite (destroys user worktree/docs_language config) |

## Risks & Trade-offs

- [Frontmatter/body desync in proposals] → Mitigation: `capabilities` field is set once at generation alongside the body. If the user manually edits the Capabilities section without updating frontmatter, skills use stale frontmatter. Acceptable because manual proposal edits are rare and preflight can cross-check.
- [18-spec migration could introduce errors] → Mitigation: Bulk edit with consistent values (`status: stable`, `version: 1`, `lastModified: 2026-04-08`). Verify after migration.
- [Template-version merge complexity in setup] → Mitigation: Start with simple heuristic (version match + content hash). Interactive merge only when both sides changed. Users can always force-overwrite.
- [Stale draft specs on abandoned branches] → Mitigation: Verify gate prevents merge to main. Stale drafts only exist on abandoned PR branches — harmless. Preflight warns about orphaned drafts.

## Open Questions

No open questions.

## Assumptions

- Plugin maintainers will remember to bump `template-version` when changing template content. <!-- ASSUMPTION: Manual version bump discipline -->
- YAML frontmatter in proposal.md and design.md does not interfere with skills that read the markdown body. <!-- ASSUMPTION: Frontmatter-body independence -->
No further assumptions beyond those marked above.
