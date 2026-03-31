# ADR-032: Documentation Drift Verification

## Status

Accepted (2026-03-26)

## Context

The opsx-enhanced plugin generates three categories of documentation via `/opsx:docs`: capability docs, ADRs, and a consolidated README. These are derived from baseline specs and archived change artifacts. After manual spec edits, multiple archive cycles, or hotfixes outside the spec process, the generated docs can drift from their source specs without any mechanism to detect it.

The existing quality gates covered pre-implementation checks (`/opsx:preflight` on specs and design) and post-implementation checks (`/opsx:verify` on code against specs), but neither verified that documentation reflected the current spec state. Three approaches were evaluated: a structured matrix check (like preflight), a diff-based comparison (regenerate docs in memory and compare), and semantic checks with a structured report. The diff-based approach was rejected as too noisy and expensive — it would flag every prose variation as drift. The matrix approach was too rigid for nuanced drift detection. Semantic checks offered the best balance of accuracy, cost, and actionable output.

The new `/opsx:docs-verify` skill fills this gap as a third quality gate, checking structural alignment between specs and docs without requiring full regeneration.

## Decision

1. **Semantic checks rather than diff-based regeneration** — comparing key structural elements (Purpose, requirement names, capability listings) is cheaper and produces more actionable output than regenerating docs in memory and diffing, which would flag every prose variation as drift
2. **Three severity levels: CRITICAL/WARNING/INFO** — matches the existing `/opsx:verify` pattern but uses INFO instead of SUGGESTION since docs drift is observational, not prescriptive
3. **Three verdicts: CLEAN/DRIFTED/OUT OF SYNC** — maps naturally to severity thresholds (CLEAN = no issues, DRIFTED = warnings only, OUT OF SYNC = criticals), providing a useful middle state where docs exist but are outdated
4. **Requirement matching by header text, not content hash** — checking for requirement header names in specs and matching them against feature/behavior sections in capability docs is robust and transparent, while content hashing would break on any prose change
5. **Skip manual ADRs (adr-MNNN prefix) in ADR cross-check** — manual ADRs have no corresponding design.md entry by definition, so checking them would produce false positives

## Alternatives Considered

- **Diff-based regeneration**: Regenerate docs in memory and compare against existing files. Most accurate but too noisy and expensive — flags every prose variation as drift, making it hard to distinguish intentional edits from actual drift.
- **Checksum-based comparison**: Hash spec+doc pairs and compare. Too coarse — provides no actionable detail about what specifically drifted.
- **PASS/FAIL binary verdicts**: Simpler but loses the useful middle state where docs exist but are outdated. The three-tier verdict (CLEAN/DRIFTED/OUT OF SYNC) provides better prioritization guidance.
- **Fuzzy text matching for requirements**: Unpredictable results across different content structures.
- **LLM semantic comparison**: Too expensive for a verification tool that should be quick and repeatable.
- **Uniform ADR checking (including manual ADRs)**: Would produce false positives for every manual ADR, since they have no corresponding design.md entry by design.

## Consequences

### Positive

- Documentation drift is now detectable before it causes confusion or misinformation
- The three-tier severity and verdict system provides clear prioritization for resolving drift
- Semantic checks are fast and produce actionable output with specific file references and recommended commands
- Manual ADRs are preserved and recognized, avoiding false positives
- The skill complements the existing quality gate family (preflight → verify → docs-verify) with a consistent pattern

### Negative

- Structural checks may miss subtle content drift where the requirement name is present but the documented behavior has drifted from the spec's intent
- False positives are possible when capability docs intentionally restructure content differently from the spec (e.g., merging two requirements into one behavior section)

## References

- [Change: docs-verify](../../openspec/changes/2026-03-26-docs-verify/)
- [Spec: quality-gates](../../openspec/specs/quality-gates/spec.md)
- [ADR-030: Verify Preflight Side-Effect Cross-Check](adr-030-verify-preflight-side-effect-cross-check.md)
