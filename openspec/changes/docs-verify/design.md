# Technical Design: /opsx:docs-verify

## Context

The opsx-enhanced plugin generates three categories of documentation via `/opsx:docs`: capability docs (`docs/capabilities/*.md`), ADRs (`docs/decisions/adr-*.md`), and a consolidated README (`docs/README.md`). These are derived from baseline specs and archived change artifacts.

After manual spec edits, multiple archive cycles, or hotfixes outside the spec process, the generated docs can drift from their source specs. Currently, `/opsx:preflight` checks specs/design consistency pre-implementation, and `/opsx:verify` checks code against specs post-implementation — but neither verifies that documentation reflects the current spec state.

The new `/opsx:docs-verify` skill fills this gap as a third quality gate in the `quality-gates` capability family.

## Architecture & Components

### New File

- `skills/docs-verify/SKILL.md` — model-invocable skill following the same pattern as `skills/verify/SKILL.md`

### Runtime Reads (no writes)

| Source | Purpose |
|--------|---------|
| `openspec/WORKFLOW.md` | Prerequisite check (setup validation) |
| `openspec/specs/*/spec.md` | Source of truth for capability coverage |
| `openspec/CONSTITUTION.md` | Source of truth for README architecture sections |
| `docs/capabilities/*.md` | Verification targets (capability docs) |
| `docs/decisions/adr-*.md` | Verification targets (ADRs) |
| `docs/README.md` | Verification target (consolidated README) |
| `openspec/changes/archive/*/design.md` | Source of truth for ADR completeness (Decisions tables) |

### Skill Structure (step-based, matching verify pattern)

1. **Prerequisite check** — verify `openspec/WORKFLOW.md` exists
2. **Discovery** — glob all specs, docs, ADRs, and archives
3. **Dimension A: Capability Docs vs Specs** — for each spec, check corresponding doc exists and covers requirements
4. **Dimension B: ADRs vs Design Decisions** — for each archived Decisions table, check corresponding ADR exists
5. **Dimension C: README vs Current State** — check capabilities table, Key Design Decisions table, and architecture overview
6. **Generate Report** — structured output with summary, grouped findings, and verdict

## Goals & Success Metrics

- `/opsx:docs-verify` on a fully in-sync project produces a CLEAN verdict with 0 issues (PASS/FAIL)
- `/opsx:docs-verify` after adding a new spec without regenerating docs produces at least one CRITICAL finding (PASS/FAIL)
- Report includes file references for every finding (PASS/FAIL)
- Skill completes without error when `docs/` directory is empty or missing (PASS/FAIL)

## Non-Goals

- **Auto-fixing drifted docs** — this skill only detects and reports; `/opsx:docs` handles regeneration
- **Deep content comparison** — the skill checks structural alignment (presence of requirements, capabilities, ADRs), not prose-level semantic equivalence
- **Checking docs language consistency** — already handled by `/opsx:docs` generation logic
- **Verifying archive integrity** — covered by the archive workflow itself
- **Checking spec format** — covered by `/opsx:preflight`

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Semantic checks rather than diff-based regeneration | Comparing key structural elements (Purpose, requirement names, capability listings) is cheaper and produces more actionable output than regenerating docs in memory and diffing. Diffs would flag every prose variation as drift. | Diff-based: regenerate docs in memory and compare (too noisy, expensive). Checksum-based: hash spec+doc pairs (too coarse, no actionable detail). |
| Three severity levels: CRITICAL/WARNING/INFO | Matches the existing `/opsx:verify` pattern (CRITICAL/WARNING/SUGGESTION) but uses INFO instead of SUGGESTION since docs drift is observational, not prescriptive. | Two levels only (PASS/FAIL per dimension) — too coarse. Four+ levels — unnecessary complexity. |
| Three verdicts: CLEAN/DRIFTED/OUT OF SYNC | Maps naturally to severity thresholds. CLEAN = no issues. DRIFTED = warnings only (docs exist but are stale). OUT OF SYNC = criticals (docs fundamentally missing). Distinct from verify's free-form assessment. | PASS/FAIL binary — loses the useful middle state where docs exist but are outdated. |
| Requirement matching by header text, not content hash | Checking for `### Requirement: <name>` headers in specs and matching them against feature/behavior sections in capability docs is robust and transparent. Content hashing would break on any prose change. | Fuzzy text matching — unpredictable results. LLM semantic comparison — too expensive for a verification tool. |
| Skip manual ADRs (adr-MNNN prefix) in ADR cross-check | Manual ADRs have no corresponding design.md entry by definition. Flagging them as missing would be a false positive. | Check all ADRs uniformly — produces false positives for every manual ADR. |

## Risks & Trade-offs

- **False positives from capability doc restructuring** — If a capability doc intentionally organizes content differently from the spec (e.g., merging two requirements into one behavior section), the check may flag missing requirements. → Mitigation: Use WARNING severity for content-level drift (not CRITICAL), and include clear recommendations.

- **Archive discovery for ADR checks** — The ADR dimension requires globbing all archives for design.md Decisions tables, which grows with project history. → Mitigation: This is a read-only operation on small Markdown files; performance impact is negligible for realistic project sizes.

- **README format assumptions** — The README check assumes a parseable Markdown table for capabilities and Key Design Decisions. If the README format changes, the check may produce false negatives. → Mitigation: The README is generated by `/opsx:docs` using a template, so format is predictable.

## Open Questions

No open questions.

## Assumptions

- Capability docs in `docs/capabilities/` use the naming convention `<capability-name>.md` matching the spec directory name. <!-- ASSUMPTION: Naming convention -->
- The README capabilities table and Key Design Decisions table use parseable Markdown table format as generated by `/opsx:docs`. <!-- ASSUMPTION: README format -->
- Archived `design.md` Decisions tables use a consistent Markdown table format with "Decision" and "Rationale" columns. <!-- ASSUMPTION: Design decisions format -->
