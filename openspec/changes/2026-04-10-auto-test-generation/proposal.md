<!--
---
status: active
branch: worktree-auto-test-generation
capabilities:
  new: [test-generation]
  modified: [artifact-pipeline, quality-gates]
  removed: []
---
-->
## Why

Specs contain structured Gherkin scenarios (GIVEN/WHEN/THEN) that are currently only verified manually during the review phase. By generating test artifacts from these scenarios before implementation begins, we enable test-first development (TDD) and give every project — even those without a test framework — a structured verification plan. This closes the gap between specification and validation.

## What Changes

- **New pipeline stage `tests`** between `preflight` and `tasks` — generates a `tests.md` manifest in the change workspace
- **Automated test stubs** written to the project's test directory when a framework is configured (TDD red phase)
- **Manual test checklist** always included in `tests.md` — covers all scenarios (without framework) or non-automatable scenarios (with framework)
- **Constitution `## Testing` section** for framework configuration (framework, directory, file pattern, import style, conventions)
- **`@manual` marker convention** to preserve human edits to generated tests across regeneration
- **Review dimension** added for test coverage verification (automated + manual)

## Capabilities

### New Capabilities
- `test-generation`: Automatic generation of test stubs and manual test plans from Gherkin scenarios in specs. Covers framework configuration, dual-mode output (automated + manual), traceability, and manual edit preservation.

### Modified Capabilities
- `artifact-pipeline`: Pipeline expands from 7 to 8 stages (new `tests` stage between `preflight` and `tasks`). The `tasks` template dependency changes from `[preflight]` to `[tests]`.
- `quality-gates`: Post-implementation verification gains an 8th dimension — test coverage verification checking that automated tests pass and manual checklist items are ticked off.

### Removed Capabilities
(none)

### Consolidation Check
1. Existing specs reviewed: artifact-pipeline, quality-gates, task-implementation, spec-format, workflow-contract, constitution-management, project-init, documentation, release-workflow, human-approval-gate, three-layer-architecture, change-workspace, roadmap-tracking
2. Overlap assessment: `test-generation` is closest to `quality-gates` (both deal with verification) but is distinct — quality-gates defines preflight checks and post-implementation review, while test-generation creates testable artifacts before implementation. Also adjacent to `spec-format` (which defines the Gherkin format being parsed) but does not modify spec format rules.
3. Merge assessment: Only one new capability proposed. No merge needed.

## Impact

- **WORKFLOW.md**: `pipeline` array gains `tests` stage, `template-version` bumps to 4
- **Smart Templates**: New `tests.md` template; `tasks.md` and `review.md` templates updated
- **Constitution template**: New `## Testing` section added for consumer projects
- **Init flow**: Will auto-detect test framework during codebase scan and populate `## Testing`
- **Consumer projects**: Existing projects with old pipeline array will see template-version diff on next `init`; the `tests` stage is additive (no breaking change)

## Scope & Boundaries

**In scope:**
- New `test-generation` spec with requirements and scenarios
- New `tests` Smart Template
- Pipeline array update in WORKFLOW.md + consumer template
- Tasks template dependency chain update
- Review template new verification dimension
- Constitution template `## Testing` section
- This project's constitution update (framework: None)

**Out of scope:**
- Actual test runner execution (tests are generated, not run — running is the developer's responsibility)
- Per-framework code templates (LLM generates framework-specific code from constitution hints)
- Incremental scenario diffing (v1 regenerates all tests per change; optimization deferred)
- Init flow auto-detection logic (separate change; for now, section is manually populated)
