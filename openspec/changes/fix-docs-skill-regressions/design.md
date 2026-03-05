# Technical Design: Fix Docs Skill Quality Regressions

## Context

A full docs regeneration test (delete all docs → `/opsx:docs` → `git diff`) revealed 9 actionable regressions in the generated output. The root causes are edge-case gaps in `skills/docs/SKILL.md`, the three doc templates, and the three meta specs (`decision-docs`, `user-docs`, `architecture-docs`). All fixes are additive guardrails and clarifications to markdown files — no runtime code changes.

## Architecture & Components

| File | Regressions | Type of Change |
|------|-------------|----------------|
| `skills/docs/SKILL.md` | R1, R2, R4, R11 | Insert skip rule, manual ADR preservation, deterministic slug algorithm, refined initial-spec fallback |
| `openspec/schemas/opsx-enhanced/templates/docs/capability.md` | R9, R10 | Insert comment blocks (behavior header guidance, Rationale guardrail) |
| `openspec/schemas/opsx-enhanced/templates/docs/adr.md` | R5 | Replace References section with semantic link examples |
| `openspec/schemas/opsx-enhanced/templates/docs/readme.md` | R6, R8 | Add length constraint, strengthen trade-offs guidance |
| `docs/decisions/adr-M001-init-model-invocable.md` | R2 | New file — restore from git history (commit `3689c3e`) |

No new modules, no cross-cutting architectural changes. All edits are to existing markdown files within the skill/template/spec layers.

## Goals & Success Metrics

| # | Metric | Target |
|---|--------|--------|
| 1 | No phantom ADR from `final-verify-step` archive | Zero ADRs generated from archives with prose-only Decisions sections |
| 2 | Manual ADR `adr-M001-init-model-invocable.md` survives regeneration | File exists after `/opsx:docs` run |
| 3 | Manual ADR appears in README Key Design Decisions table | Row with ADR-M001 link present |
| 4 | ADR slugs are deterministic | Same slug output on repeated runs for same input |
| 5 | ADR References use semantic link text | `[Spec: name](path)` format, not `[path](path)` |
| 6 | README capability descriptions ≤ 80 chars / 15 words | All descriptions in capabilities table pass constraint |
| 7 | Rationale sections use present tense | No "was later added", "initially... then..." patterns |
| 8 | Initial-spec-only capabilities have Rationale when derivable | Rationale section present for capabilities with spec-level design reasoning |
| 9 | Behavior headers include command names for multi-command capabilities | Headers like `### Step-by-Step Generation (/opsx:continue)` |

## Non-Goals

- Fixing R7 (Future Enhancements lost on full regeneration) — expected behavior when docs are deleted before regeneration
- Fixing R3 (ADR numbering shifted) — auto-fixed by R1
- Changing the docs skill's overall architecture or step ordering
- Adding automated tests for docs output quality (manual regeneration cycle is the QA method)

## Architecture Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Manual ADRs use `adr-MNNN-slug.md` naming in `docs/decisions/` (same directory) | No extra directory needed; M prefix unambiguously distinguishes from generated `adr-NNN`; single glob location for README discovery | Separate `manual/` subdirectory (unnecessary complexity); preservation rule for unmatched ADRs (fuzzy matching, numbering conflicts) |
| 2 | Deterministic slug: replace non-`[a-z0-9]` with hyphen | Handles all special chars uniformly; no ambiguity about dots, parens, slashes; produces consistent results across runs | Keep current underspecified rule (non-deterministic); add special-case rules per char type (complex, still ambiguous) |
| 3 | Fix both specs AND SKILL.md/templates | Specs define requirements; SKILL.md defines execution; both must agree to prevent future drift | SKILL.md-only (specs drift from implementation); specs-only (agent reads SKILL.md at runtime, not specs) |

## Risks & Trade-offs

- **Slug change causes ADR file renames**: The new deterministic algorithm produces different filenames for some existing ADRs (e.g., `opsxsync` → `opsx-sync`). All README links regenerate to match → no broken links, but git shows renames. Acceptable churn for determinism.
- **Template comments increase file size**: Adding guardrail comments to templates makes them longer. Templates are only read by the agent at generation time → no user impact.
- **Regeneration QA depends on agent behavior**: The only reliable test is delete → regenerate → diff. No automated assertion possible since output is LLM-generated. Mitigation: clear, specific SKILL.md instructions reduce variance.

## Open Questions

No open questions.

## Assumptions

- The lost ADR content is fully recoverable from git history at commit `3689c3e`. <!-- ASSUMPTION: Verified — content retrieved successfully -->
- SKILL.md is the primary instruction source the agent reads at `/opsx:docs` runtime — spec changes alone do not change agent behavior. <!-- ASSUMPTION: Based on observed skill execution pattern -->
