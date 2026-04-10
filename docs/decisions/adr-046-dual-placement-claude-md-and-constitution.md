# ADR-046: CLAUDE.md Directive + Constitution Convention (Dual Placement)

## Status
Accepted (2026-04-10)

## Context
The project needed a mechanism to direct agents away from auto-memory and toward transparent knowledge artifacts (constitution, specs, ADRs, issues). The question was where to place this directive. CLAUDE.md is loaded in every Claude Code session (including non-workflow conversations), making it the most reliable location for agent instructions. However, CLAUDE.md is an agent-facing file -- project conventions belong in the constitution, which is the documented source of truth for project rules. The ADR-039 scoping rule establishes that CLAUDE.md owns agent instructions while the constitution owns project conventions.

## Decision
Place the knowledge management directive in both CLAUDE.md (as an agent instruction under `## Knowledge Management`) and CONSTITUTION.md (as a `Knowledge transparency` convention entry) -- following the ADR-039 scoping rule that separates agent instructions from project conventions. CLAUDE.md catches memory writes even outside workflow actions because it is loaded in every session. The constitution documents the project rule so it is visible in specs, design reviews, and any governance context.

## Alternatives Considered
- **CLAUDE.md only (no documented convention)**: Agent instruction would work but the project rule would be invisible in the constitution, making it harder to reference in reviews and onboarding.
- **Constitution only (not loaded during normal chat)**: The constitution is only loaded via WORKFLOW.md's `context` field during workflow actions. Non-workflow conversations (casual questions, ad-hoc edits) would not see the directive, allowing auto-memory writes to continue.
- **WORKFLOW.md only (not loaded outside workflow actions)**: Same coverage gap as constitution-only, plus WORKFLOW.md is for pipeline configuration, not project conventions.

## Consequences

### Positive
- Agent sees the directive in every session, regardless of whether a workflow action is active
- Project rule is documented in the constitution alongside other conventions
- Follows the established ADR-039 scoping model, maintaining consistency

### Negative
- Two locations to maintain (CLAUDE.md and CONSTITUTION.md) if the directive changes
- Slight duplication of intent between the agent instruction and the convention entry

## References
- Change: openspec/changes/2026-04-10-transparent-knowledge-management/
- Spec: openspec/specs/project-init/spec.md
- Issue: #69
