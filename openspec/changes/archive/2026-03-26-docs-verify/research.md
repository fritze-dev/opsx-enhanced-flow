# Research: /opsx:docs-verify — Documentation Drift Detection

## 1. Current State

### Documentation Generation (`/opsx:docs`)
The existing `/opsx:docs` skill generates three categories of documentation from specs and archives:

1. **Capability Docs** (`docs/capabilities/<capability>.md`) — enriched from `openspec/specs/<capability>/spec.md` plus archive data (proposal Why, research Approaches, design Non-Goals/Risks/Decisions, preflight Assumptions). Sections: Purpose, Rationale, Features, Behavior, Known Limitations, Future Enhancements, Edge Cases.

2. **ADRs** (`docs/decisions/adr-NNN-*.md`) — generated from `design.md` Decisions tables in archives. Consolidation heuristics apply (3+ rows + single-topic → 1 ADR). Manual ADRs use `adr-MNNN` prefix.

3. **README** (`docs/README.md`) — synthesized from constitution, three-layer-architecture spec, and all ADRs. Contains architecture overview, Key Design Decisions table, Notable Trade-offs, and categorized capability listing.

### Quality Gates (existing)
- `/opsx:preflight` — pre-implementation check on specs/design (traceability, gaps, side-effects, constitution, duplication, assumptions). Does **not** touch docs.
- `/opsx:verify` — post-implementation check (completeness, correctness, coherence, side-effect cross-check). Validates code against specs/tasks, does **not** verify docs.

### Current Coverage Gap
No existing skill verifies that generated docs accurately reflect the current state of specs. After manual spec edits, multiple archive cycles, or hotfixes outside the spec process, docs can silently drift from specs. This is the gap `/opsx:docs-verify` fills.

### Affected Files
- Skills layer: new `skills/docs-verify/SKILL.md`
- Specs: new capability spec under `openspec/specs/docs-verification/spec.md`
- Reads at runtime: `openspec/specs/*/spec.md`, `docs/capabilities/*.md`, `docs/decisions/adr-*.md`, `docs/README.md`, `openspec/CONSTITUTION.md`, `openspec/WORKFLOW.md`

## 2. External Research

No external dependencies needed. The skill operates entirely within the existing Markdown/YAML ecosystem and follows the same three-layer architecture pattern as all other skills.

Relevant patterns from existing skills:
- `/opsx:preflight` uses a matrix format (traceability, gaps, side-effects) with a PASS/WARN/BLOCKED verdict — proven and familiar to users
- `/opsx:verify` uses issue classification (CRITICAL/WARNING/SUGGESTION) with file references — good for actionable output
- `/opsx:docs` uses date-based change detection (`lastUpdated` frontmatter) — could be reused for staleness detection

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A. Structured matrix check** (like preflight) — check each dimension (capability docs, ADRs, README) with a traceability matrix | Familiar format, systematic, produces clear PASS/WARN/BLOCKED verdict | More rigid, may miss nuanced drift |
| **B. Diff-based comparison** — regenerate docs in memory and compare against existing files | Most accurate drift detection, catches every difference | Expensive (full regeneration), hard to distinguish intentional edits from drift |
| **C. Semantic check with report** — read specs and docs, verify key facts match (purpose, requirements, decisions, capabilities list) without regeneration | Balanced accuracy and cost, can explain *what* drifted, not just *that* it drifted | Requires well-defined check dimensions |

**Recommendation:** Approach C — semantic checks with a structured report. It avoids the cost of full regeneration while being more nuanced than a rigid matrix. The report format can borrow the issue classification from `/opsx:verify` (CRITICAL/WARNING/SUGGESTION) for actionable output.

## 4. Risks & Constraints

- **False positives from intentional divergence:** Manual ADRs (`adr-MNNN`) or hand-edited README sections may intentionally differ from specs. The skill should flag these as INFO, not CRITICAL.
- **Spec coverage completeness:** If specs themselves are incomplete (e.g., after hotfixes), docs may correctly reflect the old spec state. The skill should note when specs appear stale (e.g., code changed outside spec process) but not block.
- **No auto-fix scope:** Per issue #32, this is detection and reporting only — no automatic corrections.
- **Skill immutability:** Per constitution, the new skill must be generic plugin code, not project-specific.
- **Performance:** With 19 capabilities, 31 ADRs, and a README, the check involves significant file reads. Should be manageable since all files are small Markdown.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Three doc types (capability docs, ADRs, README) checked against specs |
| Behavior | Clear | Read specs + docs, compare semantically, output report |
| Data Model | Clear | No new data model — reads existing Markdown files |
| UX | Clear | CLI command `/opsx:docs-verify`, outputs report to stdout |
| Integration | Clear | Complements `/opsx:docs` (generation) and `/opsx:preflight` (spec check) |
| Edge Cases | Clear | Manual ADRs, missing specs, partial docs, empty docs dir |
| Constraints | Clear | Detection only, no auto-fix, skill immutability |
| Terminology | Clear | "Drift" = divergence between docs and specs |
| Non-Functional | Clear | Must handle 19+ capabilities without timeout |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

No user feedback required — proceeding to next artifact.
