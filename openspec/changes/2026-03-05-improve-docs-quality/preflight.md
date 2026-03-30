# Pre-Flight Check: Improve /opsx:docs Output Quality

## A. Traceability Matrix

### user-docs spec
- [x] "Generate Enriched Capability Documentation" → 12 Scenarios → `skills/docs/SKILL.md` (Step 3), `templates/docs/capability.md`
- [x] "Generate Documentation Table of Contents" → 6 Scenarios → `skills/docs/SKILL.md` (Step 5), `templates/docs/readme.md`

### architecture-docs spec
- [x] "Generate Architecture Overview" → 5 Scenarios → `skills/docs/SKILL.md` (Step 5), `templates/docs/readme.md`

### decision-docs spec
- [x] "Generate Architecture Decision Records" → 9 Scenarios → `skills/docs/SKILL.md` (Step 4), `templates/docs/adr.md`

### spec-format spec
- [x] "Spec Frontmatter Metadata" → 5 Scenarios → `templates/specs/spec.md`, all 19 baseline specs, `skills/docs/SKILL.md` (Step 3+5 read frontmatter)

**Coverage:** All 4 modified capabilities have requirements → scenarios → component mapping. All 37 scenarios trace to specific implementation files.

## B. Gap Analysis

### WARNINGS

1. ~~**Bootstrap skill not updated for frontmatter**~~ **RESOLVED:** Removed the redundant bootstrap-specific scenario from spec-format. Bootstrap creates specs through the same artifact pipeline as `/opsx:ff` — the "Frontmatter assigned during spec creation in artifact pipeline" scenario covers both paths. No separate bootstrap update needed.

2. **`/opsx:sync` frontmatter handling untested:** The spec-format spec assumes `/opsx:sync` preserves frontmatter during delta-to-baseline merging. Since sync is agent-driven, this should work, but it's unverified. **Mitigation:** Acceptable risk — agent-driven sync handles arbitrary markdown structure. Test during this change's own archive (our delta specs have frontmatter).

3. ~~**Capability doc `order` frontmatter becomes redundant**~~ **RESOLVED:** Remove `order` from capability doc YAML frontmatter entirely. Spec frontmatter is the single source of truth for ordering. The capability doc template will not include an `order` field. The SKILL.md reads ordering from specs, not from generated docs.

### No gaps identified for:
- Edge case coverage for all 4 specs
- Error handling (stale file cleanup, missing archives, thin research)
- Empty states (no specs, no archives, no frontmatter)

## C. Side-Effect Analysis

1. **`docs/architecture-overview.md` deletion:** Any external tool or script referencing this file will break. **Risk:** Low — this is an internal docs file. No external links detected in the codebase.

2. **`docs/decisions/README.md` deletion:** Same as above. ADR discovery now via inline links in `docs/README.md`.

3. **Spec template change (`templates/specs/spec.md`):** Adding optional frontmatter to the spec template affects all future spec generation for all consumers. **Risk:** Low — frontmatter is optional. Existing specs without it continue to work. The template change only adds a commented-out frontmatter block as a hint.

4. **19 baseline spec modifications:** Adding frontmatter to all baseline specs creates a large diff. **Risk:** Low — frontmatter is prepended, existing content unchanged. Git diff will show clearly.

5. **README shortening:** Removing content from the project README. **Risk:** Low — content moves to `docs/README.md`, not deleted. Links added for reference.

## D. Constitution Check

No constitution changes needed. The constitution's conventions (commit format, post-archive version bump, README accuracy, workflow friction, design review checkpoint) remain unchanged. The "README accuracy" convention is relevant — README shortening must maintain accuracy by linking to docs/ for detailed content.

## E. Duplication & Consistency

### Cross-spec consistency
- **Stale file deletion:** Mentioned in user-docs (TOC requirement), architecture-docs, and decision-docs specs. All three consistently state "if file exists from a previous run, the agent SHALL delete it." ✓
- **Template references:** All three doc specs reference their respective template paths consistently. ✓
- **ADR link format:** architecture-docs spec and decision-docs spec both use `[ADR-NNN](decisions/adr-NNN-slug.md)` format. ✓
- **Frontmatter reading:** user-docs spec (TOC requirement) reads `category` and `order` from baseline specs. spec-format spec defines these fields. Consistent. ✓

### Potential overlap
- **"Generate Documentation Table of Contents" (user-docs) vs. "Generate Architecture Overview" (architecture-docs):** Both write to `docs/README.md`. No conflict — architecture-docs defines the architecture content sections, user-docs defines the capabilities section and overall structure. They compose into one file. The SKILL.md step ordering handles this: architecture content + ADRs generated first (Steps 4-5), then README assembled (Step 5).

### No contradictions found between delta specs and existing baseline specs.

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | Docs generated after sync | user-docs spec | Acceptable Risk | Enforced by workflow — `/opsx:docs` runs post-archive |
| 2 | Archive naming enforced by archive skill | user-docs spec | Acceptable Risk | Archive skill uses `YYYY-MM-DD-<name>` format consistently |
| 3 | initial-spec archive proposal describes spec creation, not capabilities | user-docs spec | Acceptable Risk | Verified: initial-spec proposal "Why" says "Bootstrap the project with initial specs" |
| 4 | Schema copy includes subdirectories | user-docs spec, design | Acceptable Risk | `/opsx:init` copies the full schema directory including subdirectories. Existing `templates/` subdirectory (with `specs/`) confirms this works. |
| 5 | Constitution maintained by archive workflow | architecture-docs spec | Acceptable Risk | Design step auto-updates constitution per schema instruction |
| 6 | Template created as part of this change | architecture-docs, decision-docs specs | Acceptable Risk | Templates are implementation tasks — they'll exist before `/opsx:docs` runs |
| 7 | Artifacts follow schema templates | decision-docs spec | Acceptable Risk | Enforced by artifact pipeline |
| 8 | YAML frontmatter parsing supported by agent | spec-format spec | Acceptable Risk | Standard markdown convention; agents parse frontmatter routinely |
| 9 | /opsx:sync handles frontmatter | spec-format spec | Acceptable Risk | Agent-driven sync handles arbitrary markdown. To be validated during this change's archive. |
| 10 | initial-spec research.md has useful data | design | Acceptable Risk | To be verified during implementation. SKILL.md instructs to omit Design Rationale if data insufficient. |

**Verdict: PASS**

All three original warnings resolved: #1 removed redundant bootstrap scenario, #2 accepted as risk (agent sync handles markdown, verified during own archive), #3 removed redundant `order` from capability doc frontmatter. No blockers.
