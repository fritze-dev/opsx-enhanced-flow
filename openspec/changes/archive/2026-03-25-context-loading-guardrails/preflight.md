# Pre-Flight Check: Context Loading Guardrails

## A. Traceability Matrix

| Change | Component | Verification |
|--------|-----------|-------------|
| Add context-loading guardrails to research instruction | `schema.yaml` lines 10-27 (research instruction block) | grep for "Context loading guardrails" |

No spec-level requirements — this is a schema instruction enrichment only.

## B. Gap Analysis

No gaps found. The change is a single text insertion into an existing instruction block.

**Minor artifact inconsistency (Info):** `research.md` references the constitution approach (Approach A) and lists `openspec/constitution.md` as an affected file (line 18-19). The final decision narrowed scope to schema-only. This does not affect implementation since proposal and design are authoritative and consistent.

## C. Side-Effect Analysis

- **All future research artifacts** will include context-loading guidance in their instructions. Intended effect, no regression risk.
- **Existing artifacts** are unaffected — instruction changes apply only to new `openspec instructions` calls.
- **No skill modifications** — skill immutability respected.

## D. Constitution Check

No constitution update needed. This change does not introduce new technologies, patterns, or architectural conventions — it adds guidance text to an existing schema instruction.

## E. Duplication & Consistency

- No duplication with existing specs or constitution rules.
- The guardrails concept is new — no existing instruction or rule covers "what to read."
- The proposed text is consistent with the project's convention-based enforcement pattern (ADR-004, ADR-006).

## F. Assumption Audit

| # | Assumption | Source | Visible Text | Rating |
|---|-----------|--------|-------------|--------|
| 1 | Research as entry point | design.md:53 | "The research phase is the primary context-loading entry point for all workflows." | Acceptable Risk — downstream artifacts build on research context; `/opsx:discover` also reads the research instruction |
| 2 | README decisions table current | design.md:54 | "The docs/README.md Key Design Decisions table is kept current by `/opsx:docs`." | Acceptable Risk — `/opsx:docs` regenerates after each archive; verified by existing docs skill spec |

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any change artifact.

---

## Pre-Flight Complete

**Change**: context-loading-guardrails
**Output**: preflight.md

### Findings
- Blockers: 0
- Warnings: 0
- Info: 1 (research.md references earlier constitution approach — cosmetic, does not affect implementation)

### Assumptions Audited
- Acceptable Risk: 2
- Needs Clarification: 0
- Blocking: 0

Verdict: **PASS**
