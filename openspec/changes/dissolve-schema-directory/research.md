# Research: Dissolve Schema Directory Structure

## 1. Current State

### Architecture
The plugin uses a three-layer architecture: Constitution → Schema → Skills. The schema layer (`openspec/schemas/opsx-enhanced/`) contains:
- `schema.yaml` (15KB) — 6-stage artifact pipeline with instructions, templates, dependencies, post_artifact hook, apply config
- `README.md` — schema documentation
- `templates/` — 10 template files for artifact generation

This structure is a leftover from the OpenSpec CLI (`@fission-ai/openspec`) which was removed in commit `c5f03c5`. The CLI required a specific directory layout; without it, the schema directory is unnecessary indirection.

### Related Prior Work
- **PR #27** (`symphony-workflow-md`): Proposed a WORKFLOW.md with YAML frontmatter replacing `config.yaml` + `constitution.md`, inspired by OpenAI Symphony. Full 6-artifact pipeline completed but never implemented. Key ideas: single authoritative file, YAML frontmatter for config, template variables, backward-compatible fallback.
- **`smart-workflow-checkpoints`** (2026-03-23): Introduced checkpoint model — auto-continue at routine transitions, mandatory pause at design review and preflight warnings. Already in both `continue` and `ff` skills.
- **`remove-cli-dependency`** (2026-03-25): Removed OpenSpec CLI dependency, but left schema directory structure intact.

### Affected Code
- 13 SKILL.md files all reference `openspec/schemas/opsx-enhanced/schema.yaml`
- `openspec/config.yaml` references `opsx-enhanced` schema by name
- `openspec/constitution.md` references three-layer architecture with schema paths
- 5 baseline specs reference schema.yaml paths
- README.md documents schema directory structure

### Existing Specs
All specs under `openspec/specs/` verified against current codebase:
- `three-layer-architecture` — describes current Constitution → Schema → Skills layers (will need modification)
- `artifact-pipeline` — references schema.yaml throughout (will need modification)
- `artifact-generation` — defines continue + ff as separate skills (will need modification)
- `project-setup` — defines setup copying schema directory (will need modification)
- All other specs are current and unaffected.

## 2. External Research

### OpenAI Symphony WORKFLOW.md
Symphony uses a `WORKFLOW.md` at the repository root with:
- YAML frontmatter for structured machine-readable config (tracker, polling, agent settings, hooks)
- Markdown body as a Liquid-compatible prompt template with `{{ variable }}` substitution
- Repository-owned, version-controlled

### Smart Templates Pattern
Several frameworks (Jekyll, Hugo, Astro) use markdown files with YAML frontmatter as self-describing content units. Applying this pattern to artifact templates: each template carries its own metadata (what it generates, what it requires, instructions for the AI) in frontmatter, with the output structure as the markdown body.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: WORKFLOW.md + Smart Templates** — Replace schema.yaml with a slim WORKFLOW.md (pipeline orchestration) + self-describing templates (instruction + metadata in frontmatter) | Clean separation: orchestration vs artifact definition. Templates are self-contained. Familiar frontmatter pattern. | Two concepts to learn (WORKFLOW.md + Smart Templates). |
| **B: WORKFLOW.md only (fat)** — Put everything in WORKFLOW.md (pipeline + all instructions + template refs) | Single file. Simple mental model. | WORKFLOW.md becomes 300+ lines. Instructions buried in one large file. |
| **C: Inline in skills** — Move instructions and template refs directly into SKILL.md files | No central config needed. Each skill is fully self-contained. | Heavy duplication (ff, discover, preflight all need research template). Violates DRY. |

**Recommended: Approach A** — WORKFLOW.md for orchestration + Smart Templates for artifact definitions.

## 4. Risks & Constraints

- **Breaking all consumer projects**: Mitigated by migration logic in `/opsx:setup` that detects old layout and converts.
- **Large number of files changing simultaneously**: 13 skills, 5 specs, constitution, README, templates. All tightly coupled — must change together.
- **Instruction parsing from template frontmatter**: Skills need to reliably parse YAML frontmatter from markdown. Claude handles this natively.
- **Continue skill removal**: Users calling `/opsx:continue` will get an error. Must update all references and documentation.
- **Skill immutability constraint**: Skills are generic plugin code. The WORKFLOW.md approach maintains this — skills read WORKFLOW.md dynamically, not hardcoded behavior.

## 5. Coverage Assessment

| Category | Rating | Notes |
|----------|--------|-------|
| Scope | Clear | Dissolve schema directory, introduce WORKFLOW.md + Smart Templates, merge continue→ff |
| Behavior | Clear | Skills read WORKFLOW.md + templates instead of schema.yaml. Same pipeline, different source. |
| Data Model | Clear | YAML frontmatter in templates + WORKFLOW.md. No new data structures. |
| UX | Clear | `/opsx:continue` removed, `/opsx:ff` becomes sole generation command. |
| Integration | Clear | All 13 skills need path updates. Setup needs rewrite. |
| Edge Cases | Clear | Migration, backward compat, existing changes mid-pipeline. |
| Constraints | Clear | Skill immutability maintained. Constitution stays separate. |
| Terminology | Clear | Smart Template, WORKFLOW.md, CONSTITUTION.md (caps). |
| Non-Functional | Clear | No performance impact — same number of file reads. |

All categories are Clear. No questions needed.

## 6. Open Questions

All categories are Clear — no questions.

## 7. Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | WORKFLOW.md + Smart Templates (Approach A) | Clean separation of orchestration (WORKFLOW.md) and artifact definition (Smart Templates). Templates are self-contained. |
| 2 | Smart Templates for ALL templates (pipeline + docs + constitution) | Uniform format, no special cases. Even docs templates benefit from `instruction` field. |
| 3 | CONSTITUTION.md (caps) as filename | Parallel to WORKFLOW.md. Signals important project-level file. |
| 4 | Both files stay in `openspec/` for now | Root migration is a separate follow-up change. Reduces scope of this change. |
| 5 | Continue merges into FF | FF already has all checkpoint logic. Continue's only unique feature (change selection) is easily added to FF. |
| 6 | Template variables (`{{ change.name }}` etc.) included | Simple string substitution, no template engine. Useful in template headings immediately. |
| 7 | `pipeline:` array in WORKFLOW.md for explicit ordering | Simpler than topological sort from `requires:` fields. Redundant but less error-prone. |
| 8 | Incorporate PR #27 ideas, close PR | PR #27's WORKFLOW.md concept is the foundation, but we go further (dissolving schema.yaml entirely). |
