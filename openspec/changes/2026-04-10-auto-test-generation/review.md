## Review: Auto-Test Generation

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 11/11 complete (sections 1-2 + 3.1) |
| Requirements | 10/10 verified |
| Scenarios | 25/25 covered |
| Tests | N/A (no tests pipeline stage existed prior to this change) |
| Scope | Clean — 0 untraced files |

### Requirements Verification

#### test-generation spec (NEW — 7 requirements)

| Requirement | Evidence | Status |
|---|---|---|
| Framework Configuration via Constitution | `openspec/templates/tests.md` instruction step 2 reads `## Testing` section; handles absent section as manual-only mode | Verified |
| Scenario Parsing from Specs | Instruction step 1 parses `#### Scenario:` blocks, extracts GIVEN/WHEN/THEN/AND, parses `## Edge Cases` | Verified |
| Automated Test Stub Generation | Instruction step 3 (WITH framework): generates stubs with arrange/act/assert mapping, TDD red phase (test.todo/pytest.mark.skip) | Verified |
| Traceability Comments | Instruction step 5: code comment format `// Spec: <cap> > Requirement: <name> > Scenario: <name>`, hierarchical grouping for manual | Verified |
| Manual Test Plan Generation | Instruction steps 3-4: ALWAYS generates manual section; dual-mode logic (all scenarios without framework, non-automatable with framework) | Verified |
| Test Manifest Artifact | Template body contains Configuration table, Automated Tests section (optional), Manual Test Plan section (always), Traceability Summary | Verified |
| Manual Edit Preservation | Instruction step 6: checks `@manual` markers, preserves marked tests, reports in manifest | Verified |

#### artifact-pipeline spec (MODIFIED — 1 requirement changed)

| Requirement | Evidence | Status |
|---|---|---|
| Eight-Stage Pipeline (was Seven-Stage) | WORKFLOW.md pipeline: `[research, proposal, specs, design, preflight, tests, tasks, review]`; body text updated; spec updated to reference 8 stages | Verified |

#### quality-gates spec (MODIFIED — 1 requirement extended)

| Requirement | Evidence | Status |
|---|---|---|
| Post-Implementation Verification — Testing dimension | review.md instruction dimension 8: "Test Coverage: verify tests from tests.md cover scenarios"; summary table includes Tests row; spec has 4 new scenarios | Verified |
| Post-Implementation Verification — existing dimensions | Dimensions 1-7 unchanged in review template instruction | Verified |

### Scenario Coverage

#### test-generation (18 scenarios)

| Scenario | Covered By |
|---|---|
| Constitution has Testing section | tests.md instruction step 2 (reads ## Testing) |
| Constitution has no Testing section | tests.md instruction step 2 ("manual-only mode") |
| Testing section with partial configuration | tests.md instruction step 2 (infers from framework conventions) |
| Parse standard Gherkin scenario | tests.md instruction step 1 (extract GIVEN/WHEN/THEN) |
| Parse scenario with AND clause | tests.md instruction step 1 (THEN/AND extraction) |
| Parse Edge Cases section | tests.md instruction steps 1, 7 (edge case tests) |
| Multiple capabilities in proposal | tests.md instruction step 1 ("from spec files listed in the proposal's capabilities") |
| Generate Vitest test stubs | tests.md instruction step 3 (framework-specific stubs, test.todo) |
| Generate pytest test stubs | tests.md instruction step 3 (pytest.mark.skip) |
| Tests initially fail (TDD red phase) | tests.md instruction step 3 ("MUST initially fail or be marked pending") |
| Automated test includes traceability comment | tests.md instruction step 5 (comment format) |
| Python test uses correct comment syntax | tests.md instruction step 5 ("or the language's comment syntax equivalent") |
| Manual plan without framework (all scenarios) | tests.md instruction step 3 (WITHOUT framework: all scenarios) |
| Manual plan with framework (non-automatable only) | tests.md instruction step 3 (WITH framework: non-automatable only) |
| Manual checklist item format | tests.md instruction step 4 (Setup/Action/Verify format) |
| Manifest with framework configured | Template body: Configuration table, Automated Tests, Manual Test Plan, Summary |
| Manifest without framework | Template body: Manual Test Plan always present; Automated section conditional |
| Preserve manually edited test | tests.md instruction step 6 (@manual preservation) |
| Regenerate unmarked test | tests.md instruction step 6 (implicit: only @manual preserved) |

#### artifact-pipeline (3 updated scenarios)

| Scenario | Covered By |
|---|---|
| Pipeline stages execute in dependency order | WORKFLOW.md pipeline array enforces order; spec updated to 8 stages |
| Skipping a stage is prevented | Unchanged — dependency gating logic in router |
| All stages produce verifiable artifacts | Spec updated to include tests.md in artifact list |

#### quality-gates (4 new scenarios)

| Scenario | Covered By |
|---|---|
| Test coverage verification with automated tests | review.md instruction dimension 8 |
| Test coverage with missing automated test file | review.md instruction dimension 8 (check files exist) |
| Test coverage with unchecked manual items | review.md instruction dimension 8 (check checklist items ticked) |
| Test coverage for project without framework | review.md instruction dimension 8 (verify only manual completion) |

### Design Adherence

| Decision | Implementation | Status |
|---|---|---|
| New pipeline stage (not tasks sub-step) | `openspec/templates/tests.md` as separate Smart Template with `requires: [preflight]` | Followed |
| Constitution for framework config | Tests instruction reads `## Testing` from constitution | Followed |
| Always generate manual checklist | Instruction step 3: manual section generated in both modes | Followed |
| LLM-generated stubs (not code templates) | Instruction provides framework hints; no per-framework templates | Followed |

### Scope Control

All 19 changed files trace to tasks or design components:

| File | Traces To |
|---|---|
| openspec/templates/tests.md | Task 1.1 |
| src/templates/tests.md | Task 1.2 |
| openspec/WORKFLOW.md | Task 2.1 |
| src/templates/workflow.md | Task 2.2 |
| openspec/templates/tasks.md | Task 2.3 |
| src/templates/tasks.md | Task 2.4 |
| openspec/templates/review.md | Task 2.5 |
| src/templates/review.md | Task 2.6 |
| openspec/templates/constitution.md | Task 2.7 |
| src/templates/constitution.md | Task 2.8 |
| openspec/CONSTITUTION.md | Task 2.9 |
| openspec/specs/test-generation/spec.md | Change artifact (new spec) |
| openspec/specs/artifact-pipeline/spec.md | Change artifact (modified spec) |
| openspec/specs/quality-gates/spec.md | Change artifact (modified spec) |
| openspec/changes/*/research.md | Change artifact |
| openspec/changes/*/proposal.md | Change artifact |
| openspec/changes/*/design.md | Change artifact |
| openspec/changes/*/preflight.md | Change artifact |
| openspec/changes/*/tasks.md | Change artifact |

0 untraced files.

### Preflight Side-Effects Cross-Check

| Side Effect | Task/Evidence | Status |
|---|---|---|
| Pipeline array change (7→8) | Task 2.1: template-version bumped 3→4 | Addressed |
| tasks.md requires chain | Task 2.3: requires changed to [tests] | Addressed |
| Review template new dimension | Task 2.5: dimension 8 added | Addressed |
| Constitution template change | Task 2.7-2.8: ## Testing added | Addressed |

### Findings

#### CRITICAL
(none)

#### WARNING
(none)

#### SUGGESTION
(none)

### Verdict

**PASS**
