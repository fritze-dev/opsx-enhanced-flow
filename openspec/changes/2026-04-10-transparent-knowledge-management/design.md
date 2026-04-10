---
has_decisions: true
---
# Technical Design: Transparent Project Knowledge Management

## Context

Claude Code auto-memory saves project knowledge to opaque, machine-local files at `~/.claude/projects/*/memory/`. The opsx-enhanced workflow already captures knowledge transparently via constitution, specs, ADRs, and issues — but nothing instructs the agent to prefer these mechanisms. The existing memory file (`project_skill_consolidation.md`) duplicates ADR and change artifact content, confirming the problem. Consumer projects initialized via `/opsx:workflow init` receive no CLAUDE.md and therefore no agent-level directives at all.

## Architecture & Components

Five files affected across two architectural layers:

**Layer 1 — Agent instructions (CLAUDE.md):**
- `CLAUDE.md` — add `## Knowledge Management` section with directive to use transparent artifacts

**Layer 1 — Project conventions (CONSTITUTION.md):**
- `openspec/CONSTITUTION.md` — add `Knowledge transparency` entry in Conventions section

**Layer 2 — Templates & workflow (plugin source):**
- `src/templates/claude.md` — new bootstrap template for CLAUDE.md generation (follows `constitution.md` template pattern)
- `openspec/WORKFLOW.md` — update init instruction to include CLAUDE.md generation
- `src/templates/workflow.md` — sync init instruction change (template synchronization convention)

No interaction changes between layers. Each file is independently editable with no coupling beyond the template sync convention.

## Goals & Success Metrics

* CLAUDE.md contains `## Workflow` and `## Knowledge Management` sections — PASS/FAIL by file inspection
* CONSTITUTION.md Conventions section contains `Knowledge transparency` entry — PASS/FAIL by grep
* `src/templates/claude.md` exists with correct frontmatter (`id: claude`, `generates: CLAUDE.md`) — PASS/FAIL by file inspection
* WORKFLOW.md init instruction mentions CLAUDE.md generation — PASS/FAIL by grep
* `src/templates/workflow.md` init instruction matches WORKFLOW.md — PASS/FAIL by diff

## Non-Goals

- `/opsx:learn` skill (Approach A from issue #69 — future work)
- Hook-based memory redirect (Approach B — requires hook API support)
- Hard enforcement of auto-memory disabling (convention-based compliance is the established model)
- Cleanup of existing memory files (outside repo, manual post-merge step)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| CLAUDE.md directive + constitution convention (dual placement) | ADR-039 scoping rule: CLAUDE.md for agent instructions, constitution for project conventions. CLAUDE.md is loaded in every session (catches memory writes outside workflow); constitution documents the project rule. | CLAUDE.md only (no documented convention), Constitution only (not loaded during normal chat), WORKFLOW.md only (not loaded outside workflow actions) |
| New `src/templates/claude.md` bootstrap template | Follows established template pattern (`constitution.md` template). Ensures consumer projects get CLAUDE.md via init. Template `id: claude` matches artifact name convention. | Inline generation in init instruction (inconsistent with template pattern), No template (consumers never get CLAUDE.md) |
| Knowledge management directive maps types to destinations | Specific routing (rules→constitution, decisions→ADRs, requirements→specs, friction→issues) prevents ambiguity about where knowledge goes. | Generic "don't use auto-memory" without routing guidance (too vague, agent won't know what to do instead) |

## Risks & Trade-offs

- **Soft enforcement** — Agent may still write to auto-memory despite the directive. This is the known limitation of convention-based compliance, accepted by the project (ADR-004, ADR-006, ADR-015, ADR-039). Mitigation: clear, specific directive text with explicit routing; future `/opsx:learn` skill could provide a structured alternative.
- **CLAUDE.md template maintenance** — Adding a new template creates a maintenance surface. Mitigation: the template is small (~20 lines of content) and changes rarely since the directives are stable.

## Open Questions

No open questions.

## Assumptions

- Convention-based enforcement via CLAUDE.md directives is sufficient to redirect agent behavior for the majority of cases. <!-- ASSUMPTION: Agent compliance sufficient -->
No further assumptions beyond those marked above.
