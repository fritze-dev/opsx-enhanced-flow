# Research: Transparent Project Knowledge Management

## 1. Current State

**Auto-memory system:** Claude Code saves project knowledge to `~/.claude/projects/*/memory/` files. These are machine-local, opaque, and not version-controlled. The current project has 2 memory files:
- `MEMORY.md` — index file
- `project_skill_consolidation.md` — architectural decision about skill consolidation (duplicates ADR-041 and change artifacts)

**Existing transparent knowledge mechanisms:**
- `openspec/CONSTITUTION.md` — project rules and conventions (Conventions section has 10 entries)
- `openspec/specs/*/spec.md` — requirements with Gherkin scenarios (13 capabilities)
- `docs/decisions/adr-*.md` — architecture decision records (43+ ADRs, auto-generated from design.md)
- `openspec/changes/*/research.md` — investigation notes per change
- `openspec/changes/*/design.md` — decisions with rationale per change
- GitHub Issues with `friction` label — workflow problems

**CLAUDE.md** (`CLAUDE.md`): Minimal — 1 rule (workflow mandate). No directives about memory behavior.

**Init action** (`openspec/WORKFLOW.md` line 42-51): Generates constitution and installs templates on fresh projects, but does not create or configure CLAUDE.md. Consumer projects never receive agent-level directives.

**Scoping rule** (ADR-039): "CLAUDE.md is for agent instructions, not project conventions." This establishes that agent behavioral directives belong in CLAUDE.md, while project-wide conventions belong in the constitution.

## 2. External Research

**Claude Code auto-memory capabilities:**
- Stores to `~/.claude/projects/<project-hash>/memory/` directory
- No plugin/hook API to intercept memory writes (no `PreMemoryWrite` event)
- `autoMemoryDirectory` user-level setting can redirect storage location (but still internal)
- CLAUDE.md `@import` can pull external files into context
- Convention-based enforcement (prompt compliance) is the established approach in this project (ADR-004, ADR-006, ADR-015)

**Bootstrap template pattern:**
- `src/templates/constitution.md` — template with frontmatter (`id`, `generates`, `requires`, `instruction`) used by init to generate CONSTITUTION.md
- No equivalent template exists for CLAUDE.md

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: CLAUDE.md directive + constitution convention (Approach C from issue) | Zero infrastructure, uses existing enforcement model, CLAUDE.md loaded in every session | Relies on prompt compliance, no hard enforcement |
| B: `/opsx:learn` skill (Approach A from issue) | Explicit invocation, transparent, version-controlled | Not automatic, requires user to invoke manually |
| C: Hook-based memory redirect (Approach B from issue) | Automatic detection of memory writes | Post-hoc (memory already written), requires external script, fragile |
| D: Disable auto-memory entirely | Hard enforcement | Loses valid use cases (user preferences, session feedback) |

**Selected: Approach A** — CLAUDE.md directive + constitution convention + init bootstrap template. This is consistent with the project's convention-based enforcement philosophy (ADR-004, ADR-006, ADR-015, ADR-039) and requires no new infrastructure.

## 4. Risks & Constraints

- **Soft enforcement:** Convention-based compliance is not guaranteed — the agent may still write memories. This is the known trade-off accepted by the project (ADR-039 "Consequences: Negative").
- **Consumer adoption:** Without the init template change, consumer projects won't get the directive. The CLAUDE.md bootstrap template closes this gap.
- **No existing CLAUDE.md template:** Adding `src/templates/claude.md` is a new pattern. It follows the established template convention but init's instruction must be updated to reference it.
- **Template sync convention:** Changes to WORKFLOW.md init instruction must be synced to `src/templates/workflow.md` per the constitution's "Template synchronization" convention.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 3 files to edit, 1 new template, well-defined boundaries |
| Behavior | Clear | Directive text defined in plan, follows ADR-039 scoping |
| Data Model | Clear | No data model changes — pure text/directive additions |
| UX | Clear | No user-facing UX changes beyond init generating CLAUDE.md |
| Integration | Clear | Integrates with init action and template system |
| Edge Cases | Clear | Soft enforcement limitation acknowledged and accepted |
| Constraints | Clear | Must go through OpenSpec flow, must follow template sync convention |
| Terminology | Clear | "Knowledge transparency" term used consistently |
| Non-Functional | Clear | No performance impact — text-only changes |
