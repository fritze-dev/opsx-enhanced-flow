# Pre-Flight Check: Improve Docs Efficiency

## A. Traceability Matrix

### user-docs spec

- [x] **Story: Incremental Capability Documentation Generation** (ADDED)
  - → Scenario: Capability skipped when no newer archives → SKILL.md Step 1 date comparison
  - → Scenario: Capability regenerated when newer archive → SKILL.md Step 1 date comparison
  - → Scenario: First run generates all → SKILL.md Step 1 fallback (no existing docs)
  - → Scenario: Content-aware write prevents false timestamp → SKILL.md Step 3 content comparison
  - → Scenario: Single-capability mode scopes archive reading → SKILL.md Step 2 scoped glob
  - → Scenario: Output summary shows skipped/unchanged → SKILL.md Step 6 enhanced output
- [x] **Story: Generate Enriched Capability Documentation** (MODIFIED)
  - → Added "Incremental generation" paragraph referencing the new requirement
  - → All 16 existing scenarios preserved unchanged
  - → Components: SKILL.md Steps 1-3

### decision-docs spec

- [x] **Story: ADR Archive Backlinks** (ADDED)
  - → Scenario: ADR includes archive backlink → SKILL.md Step 4 References generation
  - → Scenario: Archive backlink uses short name → SKILL.md Step 4 slug extraction
- [x] **Story: ADR Consolidation for Related Decisions** (ADDED)
  - → Scenario: Single-topic archive consolidated → SKILL.md Step 4 consolidation heuristics
  - → Scenario: Mixed-concern archive keeps separate → SKILL.md Step 4 heuristic rules
  - → Scenario: 2-row archive unconsolidated → SKILL.md Step 4 threshold check
- [x] **Story: Generate Architecture Decision Records** (MODIFIED)
  - → Added incremental generation logic (7-step detection algorithm)
  - → Scenario: Incremental ADR generation for new archive → SKILL.md Step 4 incremental path
  - → Scenario: No new archives skips ADR generation → SKILL.md Step 4 skip path
  - → Updated slug derivation for consolidated ADRs
  - → All 15 existing scenarios preserved

### architecture-docs spec

- [x] **Story: Generate Architecture Overview** (MODIFIED)
  - → Added conditional regeneration with 4 conditions (docs, ADRs, first run, constitution drift)
  - → Scenario: README skipped when no changes → SKILL.md Step 5 conditional check
  - → Scenario: README regenerated when new capability doc → SKILL.md Step 5 write tracking
  - → Scenario: README regenerated on first run → SKILL.md Step 5 file existence check
  - → Scenario: README regenerated when constitution drifted → SKILL.md Step 5 drift detection
- [x] **Story: Generate Documentation Table of Contents** (MODIFIED)
  - → Changed "always regenerated" to conditional regeneration reference
  - → All 7 existing scenarios preserved

## B. Gap Analysis

- **Spec-only changes without new archive**: If a spec is modified via `/opsx:sync` without creating a new archive, the capability doc won't be regenerated until the next archive touches it. Documented as accepted Non-Goal in design.md. User can force with `/opsx:docs <capability>`.
- **Constitution changes without archive**: Covered by Step 5 drift detection — agent compares constitution content (Tech Stack, Architecture Rules, Conventions) against README sections and regenerates if they diverge. No gap.
- **Concurrent runs**: Not applicable — `/opsx:docs` is run manually by one user at a time.
- **Empty archives**: An archive directory with no `specs/` subdirectory and no `design.md` won't trigger any regeneration. Correct behavior.
- **ADR incremental detection on legacy files**: Existing ADR files lack archive backlinks. The decision-docs edge case covers this: "If the agent cannot determine which archives produced existing ADRs, it SHALL fall back to full ADR regeneration." This handles the transition correctly.

No critical gaps found.

## C. Side-Effect Analysis

- **ADR numbering changes from consolidation**: Consolidation will change ADR numbers for all existing ADRs. Design mandates one-time full regeneration. README Key Design Decisions table regenerated in same run — all references stay consistent. External links to specific ADR files (e.g., in GitHub Issues) will break. **Risk: Low** — ADRs are internal docs, rarely deep-linked externally.
- **Existing ADR file deletion**: Full regeneration on first run deletes old granular ADR files and creates new consolidated ones. Manual ADRs (`adr-M*.md`) preserved per existing spec.
- **No regression to existing capability docs**: Content comparison ensures existing docs only modified when content actually changes. The "read before write" guardrail still applies.
- **SKILL.md prompt size increase**: Adding change detection, content comparison, consolidation, and drift detection logic. Current: 227 lines. Estimated: ~310 lines. Within acceptable bounds for agent prompt complexity.
- **Success metric reference in design.md**: "README is only regenerated when capability docs or ADRs change" — now also includes constitution drift as a trigger. Metric wording is slightly imprecise but the intent (conditional, not unconditional) is clear.

## D. Constitution Check

No constitution changes needed. This change:
- Does not introduce new technologies or patterns
- Does not change the three-layer architecture
- Does not modify code style or conventions
- Only modifies an existing skill's behavior within its current scope

## E. Duplication & Consistency

- **Incremental generation across two specs**: `user-docs` (capability docs) and `decision-docs` (ADRs) define incremental logic independently. Correct — they use different detection mechanisms (date comparison vs. archive backlink matching) appropriate to their different output structures.
- **Conditional README regeneration**: Defined in `architecture-docs` spec with 4 conditions. Design.md Step 5 lists matching conditions. Consistent.
- **"Fully regenerated on each run" removal**: Currently stated in existing `decision-docs` spec (line 12) and `architecture-docs` spec (lines 12, 52). Both modified specs replace this with incremental/conditional behavior. No stale references will remain after sync.
- **Consolidation and numbering**: `decision-docs` spec defines consolidation rules and their impact on numbering. Design.md Decision #5 handles the transition (one-time full regen). Edge case in `decision-docs` spec covers first-run detection. Consistent.
- **Archive backlink requirement**: Defined as ADDED in `decision-docs`, referenced in MODIFIED "Generate Architecture Decision Records" requirement ("The first reference SHALL be the source archive backlink"). Cross-reference is consistent.
- **Constitution drift condition**: Condition 4 in `architecture-docs` spec matches design.md Step 5 description. New scenario "README regenerated when constitution content drifted" covers this. Consistent.

No contradictions or duplications found.

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | Archives are immutable after archiving | design.md, decision-docs spec | Acceptable Risk | Core architectural guarantee enforced by `/opsx:archive`. If violated, stateless detection still works — may trigger unnecessary regeneration (safe failure). |
| 2 | `lastUpdated` frontmatter only written by `/opsx:docs` | design.md, user-docs spec | Acceptable Risk | Convention-based. Manual edits cause incorrect skip decisions, but failure mode is benign (stale doc, fixable by forcing). |
| 3 | Archive date prefixes accurately reflect creation date | design.md, user-docs spec | Acceptable Risk | Enforced by archive skill naming. Wrong date → unnecessary regeneration (safe failure). |
| 4 | Agent can reliably compare text blocks for equality | design.md | Acceptable Risk | LLM agents can compare text with clear instructions. Imperfect comparison → false write (safe), not missed update. |
| 5 | Constitution maintained by archive workflow | architecture-docs spec | Acceptable Risk | Standard convention. Now mitigated by drift detection — even out-of-workflow constitution changes trigger README regeneration. |
| 6 | Templates exist after `/opsx:setup` | architecture-docs spec, decision-docs spec | Acceptable Risk | Existing assumption from prior specs — unchanged by this change. |
| 7 | Archive artifacts follow schema templates | decision-docs spec | Acceptable Risk | Existing assumption — artifacts created by schema-driven workflow. |

All assumptions rated **Acceptable Risk**. No blockers or clarifications needed.
