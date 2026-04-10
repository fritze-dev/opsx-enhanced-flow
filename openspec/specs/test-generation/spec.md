---
order: 9
category: development
status: stable
version: 1
lastModified: 2026-04-10
---
## Purpose

Generates test stubs and manual test plans from Gherkin scenarios in specs before implementation begins, enabling test-first development. Supports dual-mode output: automated test files when a framework is configured, and a manual verification checklist always.

## Requirements

### Requirement: Framework Configuration via Constitution

The system SHALL read test framework configuration from the project constitution's `## Testing` section. The configuration SHALL include: framework name, test directory path, file naming pattern, import style, and conventions. If the `## Testing` section is absent, the system SHALL treat the project as having no automated test framework.

**User Story:** As a project maintainer I want to declare my test framework once in the constitution, so that test generation adapts to my project's tooling without per-change configuration.

#### Scenario: Constitution has Testing section
- **GIVEN** a constitution with a `## Testing` section specifying `vitest` as framework and `src/__tests__` as test directory
- **WHEN** the tests pipeline stage reads the constitution
- **THEN** the system SHALL use `vitest` as the target framework
- **AND** SHALL write generated test files to `src/__tests__/`

#### Scenario: Constitution has no Testing section
- **GIVEN** a constitution without a `## Testing` section
- **WHEN** the tests pipeline stage reads the constitution
- **THEN** the system SHALL operate in manual-only mode
- **AND** SHALL NOT attempt to generate automated test files

#### Scenario: Testing section with partial configuration
- **GIVEN** a constitution with `## Testing` specifying only framework name and test directory
- **WHEN** the tests pipeline stage reads the constitution
- **THEN** the system SHALL use the provided values and infer missing values (file pattern, import style) from the framework's conventions

### Requirement: Scenario Parsing from Specs

The system SHALL parse all `#### Scenario:` blocks from spec files listed in the proposal's capabilities. For each scenario, the system SHALL extract the GIVEN clause (preconditions), WHEN clause (trigger/action), and THEN/AND clauses (expected outcomes). The system SHALL also parse the `## Edge Cases` section and generate additional test cases for documented boundary conditions, error states, and empty states.

**User Story:** As a developer I want all my Gherkin scenarios automatically translated into test cases, so that no specified behavior is left untested.

#### Scenario: Parse standard Gherkin scenario
- **GIVEN** a spec with a scenario containing GIVEN, WHEN, and THEN clauses
- **WHEN** the tests stage parses the spec
- **THEN** the system SHALL extract the precondition from GIVEN, the action from WHEN, and the assertion from THEN

#### Scenario: Parse scenario with AND clause
- **GIVEN** a spec with a scenario containing GIVEN, WHEN, THEN, and AND clauses
- **WHEN** the tests stage parses the spec
- **THEN** the system SHALL extract the AND clause as an additional assertion alongside THEN

#### Scenario: Parse Edge Cases section
- **GIVEN** a spec with an Edge Cases section listing 3 boundary conditions
- **WHEN** the tests stage parses the spec
- **THEN** the system SHALL generate additional test cases for each documented edge case

#### Scenario: Multiple capabilities in proposal
- **GIVEN** a proposal listing 2 new capabilities and 1 modified capability
- **WHEN** the tests stage runs
- **THEN** the system SHALL parse scenarios from all 3 capability specs

### Requirement: Automated Test Stub Generation

When a test framework is configured in the constitution, the system SHALL generate test stub files in the project's test directory. Each test stub SHALL map GIVEN to test setup (arrange), WHEN to test action (act), and THEN/AND to assertions (assert). Generated tests SHALL initially fail or be marked as pending (TDD red phase) using the framework's convention (e.g., `test.todo()` for Vitest, `pytest.mark.skip` for pytest). The system SHALL group tests by capability and requirement.

**User Story:** As a developer I want failing test stubs generated before I write code, so that I can follow a test-first workflow where implementation makes tests green.

#### Scenario: Generate Vitest test stubs
- **GIVEN** a constitution with framework `vitest` and file pattern `{name}.test.ts`
- **AND** a spec with 3 scenarios for capability `user-auth`
- **WHEN** the tests stage generates automated tests
- **THEN** the system SHALL create `user-auth.test.ts` in the configured test directory
- **AND** the file SHALL contain 3 test stubs using `test.todo()` or equivalent
- **AND** each test SHALL map GIVEN to setup, WHEN to action, THEN to assertion comments

#### Scenario: Generate pytest test stubs
- **GIVEN** a constitution with framework `pytest` and file pattern `test_{name}.py`
- **AND** a spec with 2 scenarios for capability `data-export`
- **WHEN** the tests stage generates automated tests
- **THEN** the system SHALL create `test_data_export.py` in the configured test directory
- **AND** the file SHALL contain 2 test stubs using `pytest.mark.skip` or equivalent

#### Scenario: Tests initially fail (TDD red phase)
- **GIVEN** generated test stubs for a new capability
- **WHEN** the test suite is executed before any implementation
- **THEN** all generated tests SHALL be in a pending/skipped/failing state

### Requirement: Traceability Comments

Every generated test case (automated or manual) SHALL include a traceability reference linking it back to its source scenario. For automated tests, this SHALL be a code comment in the format `// Spec: <capability> > Requirement: <name> > Scenario: <scenario-name>` (or the language's comment syntax equivalent). For manual test items, the traceability SHALL be implicit in the hierarchical structure (grouped by capability and requirement).

#### Scenario: Automated test includes traceability comment
- **GIVEN** a scenario "Valid credentials succeed" under requirement "Login Validation" in capability `user-auth`
- **WHEN** the system generates an automated test stub
- **THEN** the test SHALL include a comment: `// Spec: user-auth > Requirement: Login Validation > Scenario: Valid credentials succeed`

#### Scenario: Python test uses correct comment syntax
- **GIVEN** a pytest project with a scenario from capability `data-export`
- **WHEN** the system generates a Python test stub
- **THEN** the traceability comment SHALL use `#` prefix instead of `//`

### Requirement: Manual Test Plan Generation

The system SHALL ALWAYS generate a manual test plan section in `tests.md`, regardless of whether a test framework is configured. Each applicable scenario SHALL be converted to a checkbox item with Setup (from GIVEN), Action (from WHEN), and Verify (from THEN/AND) sub-items. When a framework IS configured, the manual test plan SHALL include only scenarios that cannot be automated (user judgment, visual verification, multi-system E2E workflows). When no framework is configured, the manual test plan SHALL include ALL scenarios.

**User Story:** As a developer without an automated test framework I want a structured verification checklist derived from my specs, so that I can systematically verify each scenario during implementation.

#### Scenario: Manual plan without framework (all scenarios)
- **GIVEN** a project with no test framework configured
- **AND** a spec with 5 scenarios across 2 requirements
- **WHEN** the tests stage generates the manual test plan
- **THEN** `tests.md` SHALL contain 5 checkbox items with Setup/Action/Verify sub-items
- **AND** no automated test files SHALL be generated

#### Scenario: Manual plan with framework (non-automatable only)
- **GIVEN** a project with Vitest configured
- **AND** a spec with 5 scenarios, 2 of which involve visual verification
- **WHEN** the tests stage generates the manual test plan
- **THEN** `tests.md` SHALL contain 2 manual checkbox items for the visual scenarios
- **AND** 3 automated test stubs SHALL be generated in test files

#### Scenario: Manual checklist item format
- **GIVEN** a scenario with GIVEN "a user on the login page", WHEN "the user submits valid credentials", THEN "the dashboard loads"
- **WHEN** the system generates a manual test item
- **THEN** the checkbox item SHALL follow the format:
  - `- [ ] **Scenario: <name>**`
  - `  - Setup: a user on the login page`
  - `  - Action: the user submits valid credentials`
  - `  - Verify: the dashboard loads`

### Requirement: Test Manifest Artifact

The system SHALL produce a `tests.md` artifact in the change workspace containing: a configuration table (mode, framework), an automated tests section with a file traceability table (when applicable), a manual test plan section with checkbox items (always), and a traceability summary with counts of automated and manual test items. The `tests.md` artifact SHALL serve as the pipeline artifact tracked by the dependency chain.

#### Scenario: Manifest with framework configured
- **GIVEN** a project with Vitest configured and a change with 8 scenarios
- **WHEN** the tests stage completes
- **THEN** `tests.md` SHALL contain a configuration table showing mode "Dual (automated + manual)"
- **AND** an automated tests section listing generated files with scenario mappings
- **AND** a manual test plan section with non-automatable scenarios
- **AND** a summary showing total, automated, and manual counts

#### Scenario: Manifest without framework
- **GIVEN** a project with no test framework
- **AND** a change with 5 scenarios
- **WHEN** the tests stage completes
- **THEN** `tests.md` SHALL contain a configuration table showing mode "Manual only"
- **AND** no automated tests section
- **AND** a manual test plan section with all 5 scenarios as checkbox items
- **AND** a summary showing 0 automated, 5 manual

### Requirement: Manual Edit Preservation

When regenerating tests for a change that modifies existing scenarios, the system SHALL check existing test files for an `@manual` marker (language-appropriate: `// @manual`, `# @manual`). Test cases marked with `@manual` SHALL be preserved as-is during regeneration. The tests.md manifest SHALL report which tests were preserved versus regenerated.

#### Scenario: Preserve manually edited test
- **GIVEN** an existing test file with a test case containing `// @manual` at the top of the test block
- **WHEN** the tests stage regenerates tests for the same capability
- **THEN** the marked test case SHALL be preserved unchanged
- **AND** the tests.md manifest SHALL note it as "Preserved (@manual)"

#### Scenario: Regenerate unmarked test
- **GIVEN** an existing test file with a test case that has no `@manual` marker
- **WHEN** the tests stage regenerates tests for the same capability
- **THEN** the test case SHALL be regenerated from the current scenario

## Edge Cases

- **Spec with no scenarios**: If a requirement has no scenarios (spec format violation), the system SHALL skip that requirement and note it as a warning in tests.md.
- **Empty Edge Cases section**: If a spec's Edge Cases section contains no items, no additional edge case tests are generated.
- **Duplicate scenario names**: If two scenarios across different requirements have the same name, the system SHALL disambiguate by prefixing with the requirement name in the test function name.
- **Very long scenario names**: Test function names derived from scenario names SHALL be truncated or abbreviated to fit language conventions (e.g., max identifier length).
- **Test directory does not exist**: The system SHALL create the test directory if it does not exist.
- **Existing test file with unrelated tests**: When writing to an existing test file, the system SHALL append new tests without modifying existing unrelated test cases.
- **No capabilities in proposal**: If the proposal lists no capabilities, the tests stage SHALL produce a minimal tests.md noting "No capabilities to test."
- **Framework not recognized**: If the constitution specifies an unknown framework name, the system SHALL fall back to generating generic test stubs with comments indicating the intended framework.

## Assumptions

- Gherkin scenarios in specs follow the format defined in the spec-format spec (#### Scenario: heading with GIVEN/WHEN/THEN clauses). <!-- ASSUMPTION: Gherkin format compliance -->
- The LLM generating test stubs has sufficient knowledge of mainstream test frameworks to produce syntactically correct stubs. <!-- ASSUMPTION: LLM framework knowledge -->
- The distinction between automatable and non-automatable scenarios can be determined by the LLM from scenario content (user judgment, visual verification, multi-system interaction). <!-- ASSUMPTION: Automatable vs manual classification -->
