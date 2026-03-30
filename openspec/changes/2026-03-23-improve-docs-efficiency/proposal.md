## Why

The `/opsx:docs` command regenerates all documentation on every run — all 13 archives are read, all 49+ ADRs are rebuilt from scratch, and the README is fully regenerated — even when nothing changed. As the project grows, this creates unnecessary overhead and produces false `lastUpdated` timestamps (#42). Additionally, ADR generation produces excessively granular records for simple changes (#44) and lacks traceability back to source archives (#30).

## What Changes

- **Incremental capability doc generation**: Compare archive date prefixes against each doc's `lastUpdated` frontmatter. Skip capabilities with no newer archives. (#22)
- **Content-aware writes**: After generating a capability doc, compare output against existing file (excluding `lastUpdated`). Only write and bump timestamp if content actually differs. (#42)
- **Incremental ADR generation**: Count existing ADR files and only generate new ADRs from archives newer than the latest processed. Skip ADR step entirely when no new Decisions tables exist. (#22)
- **ADR consolidation heuristics**: When multiple decisions from the same archive share context and motivation, merge them into a single ADR with numbered sub-decisions. (#44)
- **ADR archive backlinks**: Add source archive directory link to each ADR's References section. (#30)
- **Conditional README regeneration**: Only regenerate `docs/README.md` when capability docs or ADRs were actually created/updated in the current run. (#22)

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `user-docs`: Add incremental generation requirement (stateless date comparison), content-aware timestamp updates, scoped archive reading in single-capability mode
- `decision-docs`: Replace "fully regenerated on each run" with incremental ADR generation, add consolidation heuristics for related decisions, add archive backlink requirement to References
- `architecture-docs`: Replace "regenerated fully on each run" with conditional README regeneration (only when capability docs or ADRs changed)

## Impact

- **`skills/docs/SKILL.md`**: Primary change target — modify Steps 1–6 to add change detection, content comparison, consolidation, and conditional regeneration logic
- **Three baseline specs**: `user-docs`, `decision-docs`, `architecture-docs` — update requirements to reflect incremental behavior
- **ADR numbering**: Consolidation changes ADR numbers. One-time full regeneration required on first run after this change to apply consistently.
- **No breaking changes**: Default behavior becomes incremental; full regeneration still happens on first run or when language changes.

## Scope & Boundaries

**In scope:**
- Stateless incremental generation for capabilities, ADRs, and README (#22)
- Content-aware timestamp updates (#42)
- ADR archive backlinks (#30)
- ADR consolidation heuristics (#44)
- Updating three specs to reflect new behavior

**Out of scope:**
- Manifest/state file (decided against in research)
- Design.md format changes for explicit grouping columns
- Preflight validation for granular decisions (could be a future enhancement)
- Detecting spec-only changes without new archives (acceptable gap — agent regenerates on next archive)
