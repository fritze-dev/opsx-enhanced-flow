---
id: tests
template-version: 1
description: Test generation from Gherkin scenarios — automated stubs and manual test plan
generates: tests.md
requires: [preflight]
instruction: |
  Generate test artifacts from Gherkin scenarios in specs before implementation.

  1. Parse all `#### Scenario:` blocks from spec files listed in the proposal's
     capabilities. For each scenario extract GIVEN (preconditions), WHEN
     (trigger/action), and THEN/AND (expected outcomes). Also parse the
     `## Edge Cases` section and generate additional test cases for documented
     boundary conditions, error states, and empty states.

  2. Read the project constitution's `## Testing` section for framework
     configuration (framework name, test directory, file pattern, import style,
     conventions). If the section is absent or empty, operate in manual-only
     mode.

  3. Dual-mode output:
     - WITH framework configured: generate automated test stub files in the
       project's test directory. Map GIVEN to test setup (arrange), WHEN to
       test action (act), THEN/AND to assertions (assert). Tests MUST initially
       fail or be marked pending (TDD red phase) using the framework's
       convention (e.g., `test.todo()` for Vitest, `pytest.mark.skip` for
       pytest). Group tests by capability and requirement.
     - WITHOUT framework (or in addition to automated tests): generate a
       manual test plan section with ALL scenarios (no framework) or only
       non-automatable scenarios (with framework). Non-automatable scenarios
       are those involving user judgment, visual verification, or multi-system
       E2E workflows.

  4. Manual checklist format — each scenario becomes:
     - `- [ ] **Scenario: <name>**`
     -   `- Setup: <GIVEN clause>`
     -   `- Action: <WHEN clause>`
     -   `- Verify: <THEN/AND clauses>`

  5. Traceability comments: every generated test case (automated or manual)
     MUST include a traceability reference. For automated tests use a code
     comment: `// Spec: <capability> > Requirement: <name> > Scenario: <scenario-name>`
     (or the language's comment syntax equivalent). For manual test items the
     traceability is implicit in the hierarchical grouping by capability and
     requirement.

  6. @manual preservation: when regenerating tests for a change that modifies
     existing scenarios, check existing test files for `@manual` markers
     (language-appropriate: `// @manual`, `# @manual`). Test cases marked with
     `@manual` MUST be preserved as-is. Report preserved tests in tests.md.

  7. Edge case tests: generate additional test cases for items in the spec's
     `## Edge Cases` section. If a spec has no scenarios (format violation),
     skip that requirement and note a warning in tests.md.

  Fill the template body below with actual content based on the parsed
  scenarios and constitution configuration.
---
# Tests: [Change Name]

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only / Dual (automated + manual) |
| Framework | (none) / framework name |
| Test directory | (none) / path |
| File pattern | (none) / pattern |

## Automated Tests
<!-- Include this section only when a framework is configured.
     List generated test files with scenario mappings. -->

| File | Scenarios | Status |
|------|-----------|--------|
| (path) | Scenario A, Scenario B | Generated / Preserved (@manual) |

## Manual Test Plan
<!-- Always include this section. When a framework is configured, include
     only non-automatable scenarios. Without a framework, include all. -->

### [Capability Name]

#### [Requirement Name]

- [ ] **Scenario: [name]**
  - Setup: [GIVEN clause]
  - Action: [WHEN clause]
  - Verify: [THEN/AND clauses]

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | N |
| Automated tests | N |
| Manual test items | N |
| Preserved (@manual) | N |
| Edge case tests | N |
| Warnings | N |
