# Pre-Flight Check: Configurable Documentation Language

## A. Traceability Matrix

- [x] Language-Aware Documentation Generation (user-docs) → 6 scenarios → `skills/docs/SKILL.md`
- [x] Language-Aware Architecture Overview (architecture-docs) → 2 scenarios → `skills/docs/SKILL.md` (Step 5)
- [x] Language-Aware ADR Generation (decision-docs) → 2 scenarios → `skills/docs/SKILL.md` (Step 4)
- [x] Language-Aware Changelog Generation (release-workflow) → 3 scenarios → `skills/changelog/SKILL.md`
- [x] Install OpenSpec and Schema — config template update (project-setup) → 2 new scenarios → `skills/init/SKILL.md`

## B. Gap Analysis

- **No gaps identified.** All scenarios cover the core behavior (language detection, translation, defaults, edge cases). The fallback to English on missing/unrecognizable language is specified. Mixed-language changelog after language change is documented as expected behavior.

## C. Side-Effect Analysis

- **Init skill**: Existing projects are unaffected — config.yaml is only created if it doesn't exist. The commented-out field and expanded context are additive.
- **Docs skill**: Adding Step 0 before Step 1 has no side effects on the existing pipeline. When `docs_language` is missing, behavior is identical to current.
- **Changelog skill**: Same pattern as docs skill — Step 0 is a no-op when field is missing.
- **No regression risk**: All changes are additive and backward-compatible.

## D. Constitution Check

- **No constitution update needed.** The English enforcement for workflow artifacts is handled via the config `context` field (design decision #3). The constitution describes project-level conventions; the language setting is a config concern.

## E. Duplication & Consistency

- **Step 0 pattern is consistent** across docs and changelog skills — same config reading logic, same fallback behavior.
- **Translation rules are consistent** across all specs: YAML keys English, values translated, product names English, dates ISO format.
- **No contradictions** with existing specs in `openspec/specs/`. The new requirements are purely additive.
- **No overlap** between the 5 delta specs — each addresses a distinct capability's language behavior.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | LLMs reliably interpret full English language names without ISO codes | user-docs spec, design | Acceptable Risk — major languages are well-supported; exotic languages may need manual review |
| 2 | npm global install is the correct installation method for OpenSpec CLI | project-setup spec (existing) | Acceptable Risk — unchanged from baseline |
| 3 | `^1.2.0` version constraint enforced via npm semver | project-setup spec (existing) | Acceptable Risk — unchanged from baseline |
| 4 | `openspec schema init` works independently without prior `openspec init` | project-setup spec (existing) | Acceptable Risk — unchanged from baseline |
| 5 | Config.yaml `context` field is read and applied by all skills | design | Acceptable Risk — verified by existing skill behavior; all skills receive context via `openspec instructions` |
| 6 | Keep a Changelog section headers have well-known translations | release-workflow spec | Acceptable Risk — standard format with established translations in major languages |
