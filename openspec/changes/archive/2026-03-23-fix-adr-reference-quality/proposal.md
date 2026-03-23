## Why

ADR generation produces broken spec links (referencing renamed/deleted specs), external GitHub URLs that are error-prone (wrong org name), and missing cross-references between related ADRs. These were found during a manual audit after the first consolidated ADR generation run. The root cause for the URL problem is that external links don't belong in ADR References at all — the archive backlink already provides traceability to GitHub issues via the archive's proposal.md.

## What Changes

- **References are internal-only** — ADR References SHALL only contain internal relative links (archive backlinks, spec links, other ADR links). No external URLs (GitHub issues, external docs). The archive backlink provides the traceability chain to issues: ADR → Archive → proposal.md → Issue.
- Add a **reference validation** sub-step to Step 4 in `skills/docs/SKILL.md` — after generating each ADR, verify every `[Spec: ...]` and `[Archive: ...]` link points to an existing path
- Add **cross-reference guidance** — when generating an ADR for a change that modifies a system established by an earlier ADR, the agent adds a back-reference to that earlier ADR

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `decision-docs`: References restricted to internal links only, reference validation requirement, cross-reference heuristic for related ADRs

## Impact

- `skills/docs/SKILL.md` — Step 4 References instructions updated
- `openspec/specs/decision-docs/spec.md` — References determination requirement updated

## Scope & Boundaries

**In scope:**
- Restrict ADR References to internal links only (no external URLs)
- Spec link existence validation (glob to verify spec exists)
- Archive link existence validation (glob to verify archive exists)
- Cross-reference guidance for thematically related ADRs

**Out of scope:**
- Automated dependency graph between ADRs (too complex — heuristic guidance is sufficient)
- Fixing existing ADR content (already fixed manually in the previous commit)
