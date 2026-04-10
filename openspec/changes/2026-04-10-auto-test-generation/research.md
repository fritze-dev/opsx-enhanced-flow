# Research: Auto-Test Generation from Gherkin Scenarios

## Context

GitHub Issue: fritze-dev/opsx-enhanced-flow#34 — "Auto-Test Generation"

The OpenSpec workflow produces specs with structured Gherkin scenarios (GIVEN/WHEN/THEN) that currently serve only as manual verification guides during the review phase. The goal is to automatically generate test artifacts from these scenarios before implementation begins, enabling a test-first development approach.

## Key Findings

### 1. Existing Testable Content in Specs

Each spec contains machine-parseable test cases:
- `#### Scenario:` headings with GIVEN/WHEN/THEN clauses
- `## Edge Cases` sections with boundary conditions
- Normative requirement descriptions using RFC 2119 keywords (SHALL, MUST)

Across 13 capability specs, there are approximately 108 requirement definitions with 150+ scenarios. Every requirement must have at least one scenario per the spec-format spec.

### 2. Framework Diversity Challenge

The plugin is consumed by projects using different tech stacks:
- JavaScript/TypeScript: Jest, Vitest, Mocha
- Python: pytest, unittest
- Go: go test
- And others

No single test output format can serve all consumers. The generation must be framework-agnostic at its core and adapt output to the consumer's configured framework.

### 3. Existing Pipeline Structure

The 7-stage pipeline (`research → proposal → specs → design → preflight → tasks → review`) uses Smart Templates with dependency chains. Each template declares `requires: [...]` and `generates: <pattern>`. Adding a new stage requires:
- A Smart Template with `id`, `requires`, `generates`
- Updating the `pipeline` array in WORKFLOW.md
- Updating the `requires` field of the next stage (tasks)

### 4. Constitution as Configuration Home

The constitution already owns project-specific configuration (Tech Stack section). A `## Testing` section fits naturally into the three-layer architecture: project-specific test config lives in Layer 1 (CONSTITUTION.md), generation logic lives in Layer 2 (Smart Template), and the router orchestrates via Layer 3.

### 5. Projects Without Test Frameworks

Not all consumer projects have automated testing infrastructure. Even these projects benefit from structured test plans derived from Gherkin scenarios — as manual verification checklists with Setup/Action/Verify items that can be checked off during implementation.

## Targeted Clarifications

### Q: Should the tests stage be skippable?
A: No skip — the stage always produces a `tests.md` manifest. Without a framework, it contains a complete manual test checklist. With a framework, it contains both automated test stubs and a manual checklist for non-automatable scenarios.

### Q: Where do generated test files go?
A: Automated test files go into the project's test directory (configured in constitution). The `tests.md` manifest stays in the change workspace as the pipeline artifact.

### Q: How to handle updates to scenarios?
A: For v1, regenerate tests for all scenarios in the current change's capabilities. The `@manual` marker convention preserves human edits to specific test cases.
