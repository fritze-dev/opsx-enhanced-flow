## Why

The v1.0.7 docs regeneration introduced content regressions: 11 Rationale sections replaced design reasoning with change-event descriptions, 4 Purpose sections were weakened, and heading inconsistency ("Why This Exists"/"Background"/"Design Rationale") confused readers. The root cause was SKILL.md instructing agents to derive Purpose from archive proposal "Why" sections instead of the spec's Purpose section.

## What Changes

- **Rename doc headings**: "Why This Exists" → "Purpose", "Background"/"Design Rationale" → unified "Rationale" across all 18 capability docs
- **Add "Future Enhancements" section**: New section in capability docs for deferred Non-Goals and tracked GitHub Issues, separate from Known Limitations
- **Fix SKILL.md root cause**: Add "CRITICAL — Purpose section source" guidance, Non-Goals classification rules, and "read before write" guardrail
- **Update capability template**: Reflect new headings, add Future Enhancements section with guidance, add Purpose BAD/GOOD examples
- **Update user-docs spec**: Align spec with new section names, add Future Enhancements requirement and scenarios

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `user-docs`: Add Future Enhancements enrichment requirement, update section names (Purpose/Rationale), add read-before-write guardrail, add scenarios for Purpose problem-framing and Future Enhancements

## Impact

- `skills/docs/SKILL.md` — enrichment guidance and guardrails
- `openspec/schemas/opsx-enhanced/templates/docs/capability.md` — structural template
- `openspec/specs/user-docs/spec.md` — baseline spec
- `docs/capabilities/*.md` — all 18 capability docs (heading renames + new sections where applicable)

## Scope & Boundaries

**In scope:**
- Heading renames across all 18 capability docs
- Future Enhancements section in 6 docs that have actionable deferred items
- Known Limitations section in 3 docs that have relevant constraints
- SKILL.md root cause fix (Purpose source, Non-Goals classification, read-before-write)
- Template and spec updates

**Out of scope:**
- Full docs regeneration (deferred to friction issue #18)
- Changes to ADR generation or README generation
- Changes to other skills or specs beyond user-docs
