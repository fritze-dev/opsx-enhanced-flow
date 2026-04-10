# ADR-048: Knowledge Management Directive Maps Types to Destinations

## Status
Accepted (2026-04-10)

## Context
The knowledge management directive needed to tell agents what to do instead of writing to auto-memory. A vague "don't use auto-memory" instruction would leave the agent without clear alternatives, likely resulting in either continued auto-memory use or lost knowledge. The project already has four established transparent knowledge mechanisms: constitution (for rules and conventions), specs (for requirements), ADRs (for decisions with rationale), and GitHub Issues (for friction and bugs). The directive needed to map knowledge types to these specific destinations.

## Decision
The Knowledge Management section in CLAUDE.md provides explicit type-to-destination routing -- rules and conventions route to constitution updates via `/opsx:workflow propose`, decisions with rationale emerge naturally as design.md artifacts and ADRs during the change flow, requirements route to spec updates via `/opsx:workflow propose`, and friction/bugs route to GitHub Issues. Auto-memory is explicitly scoped to user preferences and session-specific feedback that do not belong in project artifacts.

## Alternatives Considered
- **Generic "don't use auto-memory" without routing guidance**: Too vague -- the agent would not know where to put different types of knowledge, likely leading to knowledge loss or continued auto-memory use despite the directive.

## Consequences

### Positive
- Agent has clear, unambiguous instructions for each knowledge type
- Knowledge flows into existing transparent mechanisms that are already version-controlled and reviewable
- Auto-memory retains a legitimate scope (user preferences) rather than being completely prohibited

### Negative
- Routing rules are static -- new knowledge types that do not fit the four categories require updating the directive
- Convention-based enforcement means the agent may still occasionally use auto-memory for project knowledge (accepted limitation of the convention-based compliance model per ADR-004, ADR-006, ADR-015)

## References
- Change: openspec/changes/2026-04-10-transparent-knowledge-management/
- Spec: openspec/specs/project-init/spec.md
- Issue: #69
