# ADR-007: Fix Docs Regeneration Quality

## Status

Accepted — 2026-03-05

## Context

A full QA cycle (delete all docs, regenerate via `/opsx:docs`, diff) revealed two quality regressions in the generated documentation output. First, ADR Context sections lost approximately 50% of their length because Step 4 only read the Decisions table from `design.md`, implicitly depending on Step 2's loaded data for enrichment context — when Step 4 ran in a subagent, the research.md, proposal.md, and full design.md data was missing (GitHub Issue #28). Second, 9 of 18 capability docs dropped their Known Limitations sections and 6 dropped Future Enhancements because a "space-constrained" priority rule in SKILL.md line 82 marked these sections as `(optional)`, giving the agent permission to drop them even though no capability doc exceeded 1.3 pages (GitHub Issue #29). The specs already described the correct behavior — `decision-docs/spec.md` specified Context enrichment from `design.md Context` and `research.md Approaches`, and `user-docs/spec.md` specified Known Limitations and Future Enhancements derivation rules without marking them optional — but SKILL.md contradicted or underspecified these requirements. Three approaches were considered: fixing SKILL.md only, fixing SKILL.md with spec reinforcement, and a full per-step restructure into self-contained subagent instructions. The full restructure was deferred as a future enhancement since only Step 4 currently suffered from the implicit dependency problem.

## Decision

1. **Replace priority rule with section-completeness rule** — Positive guidance ("include when data exists") prevents section dropping without removing conciseness guards. Per-section maximum limits remain as sufficient conciseness controls. Removing the priority line entirely was rejected because it would leave no guidance at all.

2. **Add enrichment reads only to Step 4, not all steps** — Only Step 4 has the implicit dependency problem; Step 3's regression has a different root cause (the priority rule). A step independence guardrail covers the general case. Full per-step restructure was deferred as a future enhancement for autonomous agent readiness.

3. **Add step independence as a guardrail, not a structural change** — A guardrail rule is simpler and matches the existing SKILL.md structure. If insufficient, the per-step restructure into self-contained subagent instructions is the documented fallback aligned with the planned autonomous agent transition.

4. **Reinforce specs with step independence language** — Explicit spec language prevents future drift between spec and skill. Although the specs already described the correct behavior, adding step independence requirements keeps them explicitly aligned with the SKILL.md changes.

## Alternatives Considered

- Remove the priority rule line entirely — rejected because it leaves no guidance for section inclusion
- Full per-step restructure into self-contained subagent instructions — deferred as future enhancement; only Step 4 currently has the implicit dependency, and the restructure adds unnecessary scope
- Fix SKILL.md only without spec reinforcement — rejected because convention requires spec changes to go through the flow, and specs should stay aligned with implementation
- Handle the two issues as separate changes — rejected because both modify SKILL.md, share the step independence guardrail, and are the same class of bug (implicit step dependencies), creating merge conflicts if separated
- ADR template comment changes — rejected as cosmetic; template comments are format guidance and not the root cause of thin ADR contexts

## Consequences

### Positive

- All capability docs include Known Limitations and Future Enhancements when source data exists, restoring previously dropped sections
- ADR Context sections are enriched from the full design.md, research.md, and proposal.md, restoring lost depth
- ADR References sections are populated with relevant spec links, related ADRs, and GitHub Issues
- Step independence guardrail prevents future regressions if other steps develop similar subagent issues
- Specs and SKILL.md remain explicitly aligned, preventing future drift

### Negative

- Agent may still drop sections despite the rule change — mitigated by imperative language ("SHALL include ALL sections") and per-section max limits as a secondary guard. If the agent still drops sections, the fallback is restructuring the QA flow to use sequential per-change regeneration.
- Enrichment reads add minor overhead to Step 4 — negligible impact of less than 1 second per archive for reading 2-3 additional markdown files
- Step independence guardrail is advisory, not enforced — mitigated by explicit read instructions in Step 4. If insufficient, Approach C (per-step restructure) is the documented escalation path.

## References

- [Archive: fix-docs-regeneration-quality](../../openspec/changes/archive/2026-03-05-fix-docs-regeneration-quality/)
- [Spec: user-docs](../../openspec/specs/user-docs/spec.md)
- [Spec: decision-docs](../../openspec/specs/decision-docs/spec.md)
- [GitHub Issue #28](https://github.com/fritze-dev/opsx-enhanced-flow/issues/28)
- [GitHub Issue #29](https://github.com/fritze-dev/opsx-enhanced-flow/issues/29)
- [ADR-003: Documentation Ecosystem](adr-003-documentation-ecosystem.md)
- [ADR-008: Fix Docs Skill Regressions](adr-008-fix-docs-skill-regressions.md)
