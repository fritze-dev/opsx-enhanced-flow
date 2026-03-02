# Technical Design: Fix Workflow Friction

## Context

The first dogfooding run revealed that workflow rules were scattered across config.yaml, constitution, and schema with heavy redundancy. A rule ownership audit (Issue #1) combined with friction point fixes (Issue #6) led to a clear separation: schema owns universal workflow rules, constitution owns project-specific rules, config.yaml is just bootstrap.

## Architecture & Components

| File | Change Type | Description |
|------|-------------|-------------|
| `openspec/config.yaml` | Simplify | Reduce to bootstrap-only: schema ref + constitution pointer |
| `openspec/constitution.md` | Clean up | Remove 12 redundancies, add friction convention |
| `openspec/schemas/opsx-enhanced/schema.yaml` | Enhance | Add DoD rule to tasks.instruction, post-apply workflow to apply.instruction |
| `README.md` | Update | Simplify Development & Testing section |
| `.claude-plugin/plugin.json` | Update | Bump version `1.0.1` → `1.0.2` |
| `skills/init/SKILL.md` | Update | Generate minimal config template instead of copying project config |

## Goals & Success Metrics

- **M1**: config.yaml contains only schema reference + constitution pointer — PASS/FAIL
- **M2**: Constitution contains no rules duplicated by schema instructions or templates — PASS/FAIL
- **M3**: schema.yaml `tasks.instruction` contains DoD-emergent rule — PASS/FAIL
- **M4**: schema.yaml `apply.instruction` contains post-apply workflow sequence — PASS/FAIL
- **M5**: Constitution contains "Workflow friction" convention entry — PASS/FAIL
- **M6**: README Development & Testing section is updated — PASS/FAIL
- **M7**: Init skill generates minimal config template (not a copy of project config) — PASS/FAIL

## Non-Goals

- No new skills
- No changes to OpenSpec CLI itself
- No changes to baseline spec format
- No skill modifications beyond init (project-specific behavior stays in constitution)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Schema owns workflow rules | DoD and post-apply sequence apply to ALL projects using opsx-enhanced — they belong in the shared schema, not per-project config | config.yaml rules (per-project duplication), constitution (also per-project) |
| Config as bootstrap-only | config.yaml's purpose is per-project customization. With rules in schema and project rules in constitution, config just needs to point to the constitution | Keep rules in config (redundancy), no config at all (no constitution pointer) |
| Remove constitution redundancies | 12 rules duplicated schema instructions/templates. Single source of truth prevents drift and reduces constitution noise | Keep redundancies as "defense in depth" (causes maintenance burden and drift) |
| Init generates minimal config template | Prevents project-specific rules from leaking into consumer projects. Init should provide a clean starting point. | Copy full project config (leaks project-specific content) |

## Risks & Trade-offs

- **[Reduced defense-in-depth]** → Accepted: rules now live in one place instead of being duplicated. Schema enforcement + skill guardrails are sufficient.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
