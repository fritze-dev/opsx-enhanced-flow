# ADR-030: Verify Preflight Side-Effect Cross-Check

## Status

Accepted (2026-03-26)

## Context

The `/opsx:verify` command checks three dimensions (Completeness, Correctness, Coherence) after implementation but does not read `preflight.md`. The preflight's Section C (Side-Effect Analysis) identifies potential regression risks and impacts on existing systems. These side-effects are expected to flow into `tasks.md` as implementation items, but this mapping is implicit — if a side-effect is documented in the preflight but never captured as a task, it silently falls through verification.

The research phase evaluated three approaches: adding the cross-check to verify only, enforcing side-effect-to-task mapping at the tasks-creation boundary, or both. The verify-only approach was chosen as the lightest touch, since the tasks template already implicitly covers side-effects and verify is the right place for a post-implementation safety net. The side-effect cross-check uses the same keyword-based heuristic approach already proven in verify's existing requirement and scenario checks, keeping the implementation consistent with the tool's existing philosophy.

## Decision

1. **Add the cross-check as a new step after Coherence (step 8), before the Report (step 9)** — side-effects are a cross-cutting concern separate from the three core dimensions; placing the check after them keeps the existing structure clean.
2. **Use WARNING severity for unmatched side-effects** — consistent with verify's heuristic philosophy, since keyword search can miss valid implementations.
3. **Parse Section C by looking for table rows and list items, filtering out NONE/Zero assessments** — handles both table and list formats seen in existing preflights; NONE entries represent non-risks and should not trigger warnings.
4. **Two-pass matching: search tasks.md first, then fall back to codebase keyword search** — task matching is cheaper and more reliable; codebase search serves as a fallback heuristic for side-effects addressed in code without an explicit task.

## Alternatives Considered

- Fold the cross-check into the Completeness dimension (rejected: muddies the definition of completeness, which focuses on tasks and spec coverage)
- Add side-effects as a fourth verification dimension (rejected: over-engineering for what is a safety net)
- Use CRITICAL severity for unmatched side-effects (rejected: too aggressive given the heuristic nature of keyword matching)
- Require a structured, machine-readable preflight format (rejected: over-constraining and would require changes to the preflight template)
- Search codebase only without task matching (rejected: misses explicit task coverage)
- Search tasks only without codebase fallback (rejected: misses side-effects addressed directly in code)

## Consequences

### Positive

- Side-effects documented in preflight can no longer silently fall through verification
- Purely additive change — existing verify behavior for Completeness, Correctness, and Coherence is unchanged
- Consistent with verify's existing heuristic philosophy and severity model
- No changes needed to the preflight skill or template

### Negative

- Free-form parsing of Section C is inherently fragile — mitigation is to skip unparseable entries rather than raising false warnings
- Generic side-effect descriptions (e.g., "general performance impact") cannot produce meaningful keyword matches and are marked as inconclusive

## References

- [Archive: verify-preflight-side-effects](../../openspec/changes/archive/2026-03-26-verify-preflight-side-effects/)
- [Spec: quality-gates](../../openspec/specs/quality-gates/spec.md)
