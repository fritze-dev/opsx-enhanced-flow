---
id: research
description: Discovery research, coverage assessment, and clarification questions
generates: research.md
requires: []
instruction: |
  If existing specs are present in openspec/specs/, first check whether
  they still reflect the current codebase. Note any stale-spec risks
  from code changed outside the spec process.

  Context loading guardrails:
  - Always read: openspec/specs/*/spec.md (source of truth),
    docs/README.md (architecture overview and Key Design Decisions index)
  - When relevant: docs/decisions/adr-*.md — use the Key Design
    Decisions table in docs/README.md as index; deep-dive into
    specific ADRs only when the proposed change touches an area
    with a prior decision
  - Do not read: openspec/changes/archive/ (historical),
    docs/capabilities/*.md (derived from specs, redundant)

  Document your research findings for this feature request.
  Capture what you learned: affected code, external dependencies,
  possible approaches with trade-offs, and risks.

  Before proceeding, rate each category as Clear/Partial/Missing:
  Scope, Behavior, Data Model, UX, Integration, Edge Cases,
  Constraints, Terminology, Non-Functional Requirements.

  Only ask questions for Partial/Missing categories.
  Max 5 questions, prioritized by Impact × Uncertainty.
  If everything is Clear — state that and move on.

  After the user responds, record decisions with rationale
  in the Decisions section before proceeding.
---
# Research: [Feature Name]

## 1. Current State
<!-- Affected code, modules, architecture, relevant patterns -->

## 2. External Research
<!-- API docs, libraries, patterns, reference implementations (if applicable) -->

## 3. Approaches
<!-- Possible solutions with trade-offs -->

| Approach | Pro | Contra |
|----------|-----|--------|

## 4. Risks & Constraints
<!-- Technical limits, breaking changes, dependencies, performance -->

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear / Partial / Missing | |
| Behavior | Clear / Partial / Missing | |
| Data Model | Clear / Partial / Missing | |
| UX | Clear / Partial / Missing | |
| Integration | Clear / Partial / Missing | |
| Edge Cases | Clear / Partial / Missing | |
| Constraints | Clear / Partial / Missing | |
| Terminology | Clear / Partial / Missing | |
| Non-Functional | Clear / Partial / Missing | |

## 6. Open Questions
<!-- Only for Partial/Missing categories. Max 5, prioritized by Impact × Uncertainty. -->
<!-- If all Clear — skip this section. -->

| # | Question | Category | Impact |
|---|----------|----------|--------|

## 7. Decisions
<!-- Filled after user feedback. -->

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
