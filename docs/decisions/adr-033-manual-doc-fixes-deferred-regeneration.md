# ADR-033: Manual doc fixes + deferred regeneration

## Status
Accepted (2026-03-05)

## Context
After identifying heading inconsistencies and content regressions across the 18 capability docs, the fix could be applied via manual edits to existing docs or by regenerating all docs with the updated SKILL.md. Regeneration would test the fix end-to-end but risked introducing new regressions — the exact problem being solved. Manual fixes are safer because they preserve the established quality baseline while applying targeted corrections (heading renames, new sections). Research showed that a deferred regeneration pass (tracked as friction issue #18) could validate the guardrails separately after they are proven effective. This approach prioritizes safety over automation.

## Decision
Apply manual doc fixes immediately and defer full regeneration to a separate friction issue (#18).

## Rationale
Safer: preserves established quality and validates guardrails separately. Manual fixes address the immediate problem without risking new regressions.

## Alternatives Considered
- Regenerate now — risks new regressions before guardrails are proven effective

## Consequences

### Positive
- Immediate quality improvement without regression risk
- Guardrails can be validated independently during deferred regeneration

### Negative
- Current docs are manually curated rather than generated; friction issue #18 tracks the deferred regeneration
- Manual fixes may miss edge cases; mitigated by systematic diff review of all 18 docs

## References
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
