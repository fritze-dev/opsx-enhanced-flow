## Why

A full docs regeneration test revealed 9 actionable regressions in `/opsx:docs` output quality. The skill's SKILL.md, templates, and specs have edge-case gaps that cause phantom ADRs, lost manual ADRs, non-deterministic slugs, and various content quality issues. Fixing these ensures docs regeneration is idempotent and high-quality.

## What Changes

- **SKILL.md Step 4**: Add skip rule for archives whose design.md has no valid Decisions table (R1); add manual ADR preservation via `adr-MNNN` naming convention (R2); replace slug algorithm with deterministic 6-step version (R4)
- **SKILL.md Step 5**: Include manual ADRs (`adr-M*.md`) in README Key Design Decisions table (R2)
- **SKILL.md Step 6**: Preserve manual ADR files during cleanup (R2)
- **SKILL.md Step 2**: Refine initial-spec fallback to derive Rationale from spec requirements (R11)
- **Capability template**: Add Rationale guardrail against change-history narration (R10); add behavior header guidance for command references (R9)
- **ADR template**: Fix References section to require semantic link text (R5)
- **README template**: Add description length limit of 80 chars / 15 words (R6); strengthen trade-offs completeness guidance (R8)
- **Specs**: Update `decision-docs`, `user-docs`, and `architecture-docs` to match all above changes
- **New file**: Restore `docs/decisions/adr-M001-init-model-invocable.md` from git history (R2)

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `decision-docs`: Add skip rule for prose-only Decisions sections (R1); add manual ADR concept with `adr-MNNN` naming (R2); specify deterministic slug algorithm (R4)
- `user-docs`: Add Rationale present-tense guardrail (R10); add behavior header command reference guidance (R9); refine initial-spec Rationale fallback (R11)
- `architecture-docs`: Add manual ADR inclusion in README table (R2); add description length constraint (R6); strengthen trade-offs guidance (R8)

## Impact

- **skills/docs/SKILL.md**: 4 insertions/replacements across Steps 2, 4, 5, 6
- **3 template files**: Small additions (comments, constraints)
- **3 spec files**: Edge cases, requirements, and scenario updates
- **1 new file**: `docs/decisions/adr-M001-init-model-invocable.md`
- **No breaking changes**: All fixes are additive guardrails and clarifications

## Scope & Boundaries

**In scope:**
- Fix all 9 actionable regressions (R1, R2, R4, R5, R6, R8, R9, R10, R11)
- Update specs to match SKILL.md/template changes
- Restore lost manual ADR from git history

**Out of scope:**
- R7 (Future Enhancements lost on full regeneration) — expected behavior, no fix needed
- R3 (ADR numbering shifted) — auto-fixed by R1
- Changes to other skills or schema artifacts
- Any runtime code changes
