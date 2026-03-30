# Technical Design: Verify Preflight Side-Effect Cross-Check

## Context

The verify skill (`skills/verify/SKILL.md`) reads five artifacts but not `preflight.md`. Side-effects identified in preflight Section C can slip through if they were never captured as tasks. This change adds `preflight.md` to verify's artifact loading and introduces a cross-check sub-step after the existing three dimensions.

## Architecture & Components

**Modified files:**

1. **`skills/verify/SKILL.md`** — The verify skill definition
   - Step 3 (Load artifacts): add `preflight.md` to the read set
   - New step between current step 7 (Coherence) and step 8 (Report): "Verify Preflight Side-Effects"
   - Step 8 (Report): add side-effect findings to the summary scorecard

2. **`openspec/specs/quality-gates/spec.md`** — Updated via delta spec (already drafted)

**New sub-step logic (pseudo):**

1. Read `preflight.md`, extract Section C (Side-Effect Analysis)
2. Parse side-effect entries — look for table rows or list items with risk descriptions
3. Filter out entries assessed as "NONE" or "Zero" (no actual risk)
4. For each remaining side-effect:
   a. Search `tasks.md` for keyword match against the side-effect description
   b. If no task match: search codebase for keyword evidence
   c. If neither found: emit WARNING with recommendation

## Goals & Success Metrics

- Verify reads `preflight.md` and extracts side-effects from Section C: PASS/FAIL
- Unaddressed side-effects produce WARNING issues in the report: PASS/FAIL
- Side-effects matched by task or code evidence produce no issue: PASS/FAIL
- Empty/NONE Section C entries are skipped without false warnings: PASS/FAIL

## Non-Goals

- Changing the preflight skill or template
- Enforcing side-effect → task mapping at the tasks-creation boundary
- Modifying existing Completeness/Correctness/Coherence dimensions
- Structured/machine-readable preflight format (free-form markdown parsing is sufficient)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Add as a sub-step after Coherence (new step 8), before Report (becomes step 9) | Side-effects are a cross-cutting concern separate from the three core dimensions; placing it after keeps the existing structure clean | Fold into Completeness (muddies the definition); add as a fourth dimension (over-engineering for a safety net) |
| WARNING severity for unmatched side-effects | Consistent with verify's heuristic philosophy — keyword search can miss valid implementations | CRITICAL (too aggressive for heuristic matching) |
| Parse Section C by looking for table rows and list items, filtering out NONE/Zero assessments | Handles both table and list formats seen in existing preflights; NONE entries are non-risks | Require structured format (over-constraining; would need preflight template changes) |
| Two-pass matching: tasks.md first, then codebase | Task match is cheaper and more reliable; codebase search is the fallback heuristic | Codebase only (misses explicit task coverage); tasks only (misses code-addressed side-effects) |

## Risks & Trade-offs

- **Free-form parsing fragility** → Mitigation: use flexible keyword extraction (split on common delimiters, ignore assessment columns); skip entries that can't be meaningfully parsed rather than raising false warnings.
- **Generic side-effect descriptions** → Mitigation: skip entries too vague for keyword matching (e.g., "general performance impact") and note as inconclusive.

## Open Questions

No open questions.

## Assumptions

- Preflight Section C uses a recognizable structure (table with risk/assessment columns, or bulleted list) across all changes. <!-- ASSUMPTION: Section C format -->
