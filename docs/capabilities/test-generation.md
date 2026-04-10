---
title: "Test Generation"
capability: "test-generation"
description: "Automated test stub and manual test plan generation from Gherkin scenarios before implementation"
lastUpdated: "2026-04-10"
---

# Test Generation

Generates test stubs and manual test plans from Gherkin scenarios in specs before implementation begins, enabling test-first development. The `tests` pipeline stage sits between `preflight` and `tasks`, producing a `tests.md` artifact with dual-mode output: automated test files when a framework is configured in the constitution, and a manual verification checklist always.

## Purpose

Gherkin scenarios in specs define testable behavior, but without a dedicated pipeline stage they are only used for manual verification during review. This leaves a gap between specification and implementation where test-first development cannot occur. Test Generation bridges that gap by translating scenarios into concrete test artifacts before any code is written, so developers can follow a TDD workflow where implementation makes tests green.

## Rationale

The tests stage is a separate pipeline stage rather than a sub-step of tasks because clean TDD flow requires tests to exist as artifacts before tasks are created -- separate stage means separate dependency tracking. Framework configuration lives in the constitution's `## Testing` section because it fits the three-layer architecture: project-specific config belongs in Layer 1 (constitution), following the precedent set by Tech Stack. A manual checklist is always generated because every project benefits from structured verification, even those with automated tests -- non-automatable scenarios (visual verification, user judgment, multi-system E2E) need manual coverage. Test stubs are LLM-generated rather than template-based because unbounded framework diversity makes per-framework templates infeasible, and the LLM already knows mainstream frameworks.

## Features

- **Dual-mode output**: Automated test stubs when a framework is configured, plus a manual verification checklist always
- **Constitution-based framework configuration**: Test framework, directory, file naming pattern, import style, and conventions read from the constitution's `## Testing` section
- **Scenario parsing**: Extracts GIVEN/WHEN/THEN clauses from all `#### Scenario:` blocks in spec files, plus edge cases
- **TDD red-phase stubs**: Generated tests are initially pending/failing (e.g., `test.todo()` for Vitest, `pytest.mark.skip` for pytest)
- **Traceability comments**: Every test case includes a reference linking back to its source scenario (`// Spec: <capability> > Requirement: <name> > Scenario: <scenario-name>`)
- **Manual test plan**: Checkbox items with Setup/Action/Verify sub-items derived from GIVEN/WHEN/THEN clauses
- **Manual edit preservation**: Test cases marked with `@manual` are preserved during regeneration
- **Test manifest artifact**: `tests.md` in the change workspace with configuration table, file traceability, manual checklist, and summary counts

## Behavior

### Framework Configuration via Constitution

When the constitution has a `## Testing` section specifying a framework (e.g., `vitest`, `pytest`), the tests stage generates automated test stubs in the configured test directory using the specified file naming pattern. When the section is absent, the stage operates in manual-only mode. Partial configuration (only framework and directory) is supported -- missing values are inferred from framework conventions.

### Scenario Parsing from Specs

The tests stage parses all `#### Scenario:` blocks from spec files listed in the proposal's capabilities. For each scenario, GIVEN clauses become preconditions, WHEN clauses become actions, and THEN/AND clauses become assertions. The `## Edge Cases` section is also parsed to generate additional test cases for boundary conditions, error states, and empty states.

### Automated Test Stub Generation

When a framework is configured, test stub files are generated in the project's test directory. Each stub maps GIVEN to test setup (arrange), WHEN to test action (act), and THEN/AND to assertions (assert). Tests are grouped by capability and requirement. All stubs initially fail or are marked as pending to support TDD red-phase workflow.

### Manual Test Plan Generation

A manual test plan is always generated in `tests.md`. Without a framework, all scenarios become manual checkbox items. With a framework, only non-automatable scenarios (user judgment, visual verification, multi-system E2E) appear in the manual plan. Each item follows the format: checkbox with scenario name, then Setup/Action/Verify sub-items.

### Manual Edit Preservation

When regenerating tests for a change that modifies existing scenarios, test cases marked with `@manual` (using language-appropriate comment syntax) are preserved unchanged. The manifest reports which tests were preserved versus regenerated.

## Known Limitations

- Test stubs are generated, not executed -- the tests stage does not run any test suite
- The distinction between automatable and non-automatable scenarios relies on LLM heuristics from scenario content
- Regeneration replaces all unmarked tests -- only `@manual`-marked tests are preserved

## Edge Cases

- If a requirement has no scenarios, the system skips it and notes a warning in tests.md
- If two scenarios across different requirements share the same name, the system disambiguates by prefixing with the requirement name
- If the test directory does not exist, the system creates it
- If the proposal lists no capabilities, the tests stage produces a minimal tests.md noting "No capabilities to test"
- If the constitution specifies an unknown framework, the system falls back to generic test stubs with comments indicating the intended framework
