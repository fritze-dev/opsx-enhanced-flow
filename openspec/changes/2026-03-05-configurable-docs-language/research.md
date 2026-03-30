# Research: Configurable Documentation Language

## 1. Current State

Three plugin skills produce user-facing documentation, all currently English-only:

| Skill | Output | Relevant Spec |
|-------|--------|---------------|
| `skills/docs/SKILL.md` | `docs/capabilities/*.md`, `docs/decisions/adr-*.md`, `docs/README.md` | user-docs, architecture-docs, decision-docs |
| `skills/changelog/SKILL.md` | `CHANGELOG.md` | release-workflow |
| `skills/init/SKILL.md` | `openspec/config.yaml` (template) | project-setup |

**Configuration surface:** `openspec/config.yaml` contains `schema` and `context` fields. The `context` field is passed to all skills as project-level instructions. No language setting exists today.

**Workflow artifacts** (research.md, proposal.md, specs, design.md, preflight.md, tasks.md) are internal and must remain English — they feed into the artifact pipeline and are consumed by other skills.

**Doc templates** at `openspec/schemas/opsx-enhanced/templates/docs/` are structural guides consumed by the docs skill. They remain English regardless of output language.

## 2. External Research

Not applicable — this is a configuration/skill change with no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: `docs_language` in config.yaml + Step 0 in docs/changelog skills | Minimal change, central config, all skills already read config | Skills need explicit translation reminders at each generation step |
| B: Language setting in constitution.md | Already read by skills via context | Constitution is project-specific rules, not configuration; mixes concerns |
| C: Per-skill language parameter | Fine-grained control | Duplicates config, user must set in multiple places |

**Selected: Approach A** — single `docs_language` field in `openspec/config.yaml`, read by docs and changelog skills.

## 4. Risks & Constraints

- **No runtime validation**: `docs_language` is a free-text string interpreted by the LLM. Misspellings produce unpredictable results. Acceptable because LLMs handle fuzzy language names well.
- **Language change mid-project**: Existing CHANGELOG entries stay in the previous language. New entries use the new language. Acceptable — documented as edge case.
- **Template language mismatch**: Doc templates remain English structural guides. The skill translates headings/content during generation, not in templates.
- **YAML frontmatter**: Keys stay English (machine-readable). Only `title` and `description` values get translated.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 3 files: docs skill, changelog skill, init skill |
| Behavior | Clear | Step 0 reads config, translation applies to all generated content |
| Data Model | Clear | Single `docs_language` field in config.yaml |
| UX | Clear | Commented-out field in init template for discoverability |
| Integration | Clear | Skills already read config.yaml; no new integration needed |
| Edge Cases | Clear | Mid-project language change, missing field defaults to English |
| Constraints | Clear | Workflow artifacts always English, enforced via config context |
| Terminology | Clear | "docs_language" field name, language values in English (e.g., "German") |
| Non-Functional | Clear | No performance impact — purely generation-time behavior |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Add `docs_language` field to config.yaml via init skill template | Central config, backward-compatible (missing = English), all skills already read config | Per-skill parameter (rejected: duplication), constitution entry (rejected: mixes concerns) |
| 2 | Enforce English for internal artifacts via config `context` field | Context is passed to all skills automatically — single enforcement point | Per-skill instruction (rejected: duplication), schema-level rule (rejected: language is not a pipeline concern) |
| 3 | Keep doc templates in English | Templates are structural guides, not translated content. Skills translate during generation. | Translated templates per language (rejected: template proliferation) |
| 4 | YAML frontmatter keys stay English, values get translated | Keys are machine-readable identifiers. Only `title`/`description` values are user-facing. | Full translation including keys (rejected: breaks tooling) |
