## Why

Generated documentation (capability docs, ADRs, README) can silently drift from specs after manual spec edits, multiple archive cycles, or hotfixes outside the spec process. No existing skill detects this — `/opsx:preflight` checks specs/design, `/opsx:verify` checks code, but docs go unchecked.

## What Changes

- New `/opsx:docs-verify` command that reads current specs and generated docs, compares them semantically, and outputs a drift report
- Three check dimensions: capability docs vs specs, ADRs vs design decisions, README vs constitution + capability listing
- Issue classification using CRITICAL/WARNING/INFO severity levels
- Detection and reporting only — no automatic fixes

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `quality-gates`: Add a third quality gate — documentation drift verification via `/opsx:docs-verify`. This extends the existing preflight (pre-impl) and verify (post-impl) gates with a post-docs-generation gate.

### Consolidation Check

1. **Existing specs reviewed:** quality-gates, user-docs, architecture-docs, decision-docs, workflow-contract, release-workflow
2. **Overlap assessment:**
   - `quality-gates` (closest match): Already owns `/opsx:preflight` and `/opsx:verify`. Adding `/opsx:docs-verify` as a third gate keeps all verification commands in one spec. The spec is currently ~190 lines; adding the new requirement stays within the 250-350 target.
   - `user-docs`, `architecture-docs`, `decision-docs`: These define doc *generation* behavior. docs-verify *checks* generated output — different concern, wrong home.
3. **Merge assessment:** N/A — no new capabilities proposed.

## Impact

- **Skills layer:** New `skills/docs-verify/SKILL.md` file
- **Specs:** Delta spec modifying `quality-gates` with one new requirement
- **Runtime reads:** `openspec/specs/*/spec.md`, `docs/capabilities/*.md`, `docs/decisions/adr-*.md`, `docs/README.md`, `openspec/CONSTITUTION.md`
- **No breaking changes** — purely additive

## Scope & Boundaries

**In scope:**
- Capability docs checked against spec Purpose + Requirements (completeness, accuracy)
- ADRs checked for completeness (all archived design decisions have corresponding ADRs)
- README checked against constitution and current capability listing
- Structured drift report with severity levels and file references

**Out of scope:**
- Automatic fixing of drifted docs (use `/opsx:docs` to regenerate)
- Checking docs language consistency (already handled by `/opsx:docs` generation)
- Verifying archive integrity or spec format (covered by `/opsx:preflight`)
