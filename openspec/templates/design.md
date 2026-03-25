---
id: design
description: Architecture, success metrics, and non-goals
generates: design.md
requires: [specs]
instruction: |
  Create the design document that explains HOW to implement the change.

  When to include design.md (create only if any apply):
  - Cross-cutting change (multiple services/modules) or new architectural pattern
  - New external dependency or significant data model changes
  - Security, performance, or migration complexity
  - Ambiguity that benefits from technical decisions before coding

  Sections:
  - **Context**: Background, current state, constraints, stakeholders
  - **Architecture & Components**: Specific modules/files affected and interactions
  - **Goals & Success Metrics**: Hard, measurable criteria verified as PASS/FAIL during QA. Every metric needs a concrete threshold.
  - **Non-Goals**: What is explicitly out of scope
  - **Decisions**: Key technical choices with rationale (why X over Y?). Include alternatives considered for each decision.
  - **Risks & Trade-offs**: Known limitations, things that could go wrong. Format: [Risk] → Mitigation
  - **Migration Plan**: Steps to deploy, rollback strategy (if applicable). Remove section if not needed.
  - **Open Questions**: Outstanding decisions or unknowns to resolve
  - **Assumptions**: Format: `- Visible assumption text. <!-- ASSUMPTION: short tag -->`. If none: "No assumptions made."

  If this feature introduces new technologies, patterns, or architectural
  changes, update openspec/CONSTITUTION.md accordingly.

  Focus on architecture and approach, not line-by-line implementation.
  Reference the proposal for motivation and specs for requirements.
---
# Technical Design: {{ change.name }}

## Context
<!-- Summary of the feature, current state of affected systems, relevant constraints -->

## Architecture & Components
<!-- Which modules/files are affected? How do they interact? -->

## Goals & Success Metrics
<!-- Hard, measurable criteria. Each verified as PASS/FAIL in QA. -->
* [Metric, e.g. "API response < 200ms"]

## Non-Goals
<!-- What explicitly will NOT be built -->

## Decisions
<!-- Key technical choices with rationale. Include alternatives considered. -->
| Decision | Rationale | Alternatives |
|----------|-----------|--------------|

## Risks & Trade-offs
<!-- Known risks with mitigation. Format: [Risk] → Mitigation -->

## Migration Plan
<!-- Steps to deploy, rollback strategy. Remove section if not applicable. -->

## Open Questions
<!-- Unresolved design questions — if none, state "No open questions." -->

## Assumptions
<!-- Format: "- Visible assumption text. <!-- ASSUMPTION: short tag -->"
     If none: state "No assumptions made." -->
