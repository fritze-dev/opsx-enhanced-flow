# ADR-012: Incremental Docs Generation

## Status

Accepted — 2026-03-23

## Context

The `/opsx:docs` command regenerates all documentation artifacts on every run — reading all 13 archives, rebuilding 49+ ADRs from scratch, and rewriting the README — even when nothing has changed. As the project grows, this creates unnecessary overhead and produces false `lastUpdated` timestamps when regenerated content is identical to the existing file. Additionally, ADR generation produces excessively granular records for simple changes (e.g., a pure rename generating 5 separate ADRs) and lacks traceability back to source archives. Because the entire generation logic lives in `skills/docs/SKILL.md` as LLM agent instructions rather than traditional code, change detection must rely on file metadata the agent can read: date prefixes in archive directory names, `lastUpdated` YAML frontmatter in capability docs, and direct content comparison. Four GitHub Issues drove this change: incremental generation (#22), false timestamp bumps (#42), missing archive backlinks in ADRs (#30), and excessive ADR granularity (#44).

## Decision

1. **Stateless date comparison for change detection** — Compares archive date prefixes against each capability doc's `lastUpdated` frontmatter. No new state file to maintain, no drift risk, and always reflects the true file system state.
2. **Content comparison before write for timestamp accuracy** — After generating a capability doc, the agent compares the output against the existing file (excluding the `lastUpdated` field). Only writes and bumps the timestamp if content actually differs, preventing false timestamp bumps.
3. **Agent-side consolidation heuristics for ADR grouping** — When multiple decisions from the same archive share context and motivation, they are merged into a single ADR with numbered sub-decisions. Works retroactively with all existing archives without requiring design.md format changes. Conservative rules (3+ rows AND single-topic archive) minimize false consolidation.
4. **Archive backlink as first reference in each ADR** — Adds a source archive directory link to each ADR's References section, improving traceability from decision records back to the original research and design artifacts.
5. **One-time full ADR regeneration when consolidation is introduced** — Consolidation changes ADR numbering, so all ADRs must be regenerated once to apply the new grouping consistently. The README Key Design Decisions table is regenerated in the same run, keeping references aligned.
6. **Conditional README regeneration based on this-run writes and constitution drift** — The README is only regenerated when capability docs or ADRs were actually created or updated in the current run, or when constitution content has drifted from what is reflected in the README.

## Alternatives Considered

- Manifest file tracking processed archives (rejected: adds complexity and drift risk; requires `--force` escape hatch; more complex agent instructions)
- Git-based detection using `git log` for changed archives (rejected: requires git access, does not work on first clone, brittle with rebases and squashes)
- Skip write entirely when no new archives exist (rejected: less precise, misses cases where archive touches capability but output is unchanged)
- Design.md grouping column for explicit ADR grouping (rejected: requires format change and retroactive archive edits, breaks existing table format)
- Preflight validation to flag excessive fine-grained decisions (rejected: only prevents future occurrences, does not fix existing archives)
- Incremental-only ADR generation without one-time full regeneration (rejected: would leave inconsistent numbering between old granular and new consolidated ADRs)
- Always regenerate README regardless of changes (rejected: wastes effort when no docs or ADRs have changed)
- Timestamp comparison against README (rejected: less precise because the README has no frontmatter date)

## Consequences

### Positive

- Running `/opsx:docs` with no new archives completes without writing any files, significantly reducing overhead
- Capability doc `lastUpdated` timestamps accurately reflect when content actually changed
- ADR consolidation reduces noise by merging related decisions into coherent single records
- Archive backlinks in ADRs improve traceability from decisions to source research and design
- Conditional README regeneration avoids unnecessary rewrites of the main entry-point document

### Negative

- Agent may misinterpret date comparison logic (mitigated: explicit step-by-step instructions with concrete examples; worst case is unnecessary regeneration, which is a safe failure mode)
- Consolidation heuristics may misjudge grouping in edge cases (mitigated: conservative rules only auto-consolidate when 3+ rows AND single-topic archive; worst case is one over-consolidated ADR that can be split later)
- ADR numbering shift from consolidation invalidates existing ADR references temporarily (mitigated: one-time full regeneration and README rebuild in the same run keeps references consistent)
- Constitution drift detection is imperfect — subtle changes may be missed (mitigated: agent compares key sections from constitution against README; user can force regeneration with `/opsx:docs <any-capability>`)
- Spec-only changes without new archives are not detected (accepted gap: user can run `/opsx:docs <capability>` to force regeneration)

## References

- [Change: improve-docs-efficiency](../../openspec/changes/2026-03-23-improve-docs-efficiency/)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [Spec: architecture-docs](../../openspec/specs/architecture-docs/spec.md)
- [ADR-003: Documentation Ecosystem](adr-003-documentation-ecosystem.md)
- [ADR-009: Improve Docs Output Quality](adr-009-improve-docs-output-quality.md)
- [ADR-010: Improve Docs Sections](adr-010-improve-docs-sections.md)
