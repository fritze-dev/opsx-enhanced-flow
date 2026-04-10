# ADR-049: Auto-Test Generation from Gherkin Scenarios

## Status
Accepted (2026-04-10)

## Context
The OpenSpec workflow produces specs with Gherkin scenarios that define testable behavior, but these scenarios were only used for manual verification in the review phase. There was no mechanism to generate test artifacts before implementation, leaving a gap where test-first development could not occur. The plugin serves diverse consumer projects with different test frameworks, so any solution needed to be framework-agnostic at its core while still producing framework-specific output when configured.

## Decision
Four key decisions shape the test generation design:

1. **New pipeline stage vs. tasks sub-step**: Tests are a separate pipeline stage (`tests`) between `preflight` and `tasks`, not a sub-step within tasks. This provides clean TDD flow where tests exist as artifacts before tasks are created, with separate dependency tracking. The alternative of embedding in the tasks instruction was rejected because it conflates planning with test generation and produces no separate artifact.

2. **Constitution for framework configuration**: Test framework settings (framework name, test directory, file pattern, import style, conventions) live in the constitution's `## Testing` section. This fits the three-layer architecture where project-specific config belongs in Layer 1, following the Tech Stack section as precedent. The alternative of WORKFLOW.md frontmatter was rejected because it mixes orchestration with project config. A separate config file was rejected as a new mechanism outside the architecture.

3. **Always generate manual checklist**: A manual verification checklist is produced for every change, regardless of whether automated tests are also generated. Projects without frameworks get full manual coverage. Projects with frameworks still get manual items for non-automatable scenarios (visual, UX, multi-system). The alternative of only generating with/without framework was rejected because it would leave some projects or scenarios without coverage.

4. **LLM-generated test stubs (not code templates)**: The LLM generates framework-specific test stubs at runtime rather than using pre-built per-framework templates. Unbounded framework diversity makes template maintenance infeasible, and the LLM already knows mainstream frameworks. Constitution provides framework hints to guide generation. Per-framework Mustache/Handlebars templates were rejected due to maintenance burden and limited framework coverage.

## Alternatives Considered
- **Tasks sub-step**: Embedding test generation in the tasks instruction -- rejected because it conflates planning with test generation and produces no separate artifact for dependency tracking.
- **WORKFLOW.md frontmatter for framework config**: Rejected because it mixes orchestration metadata with project-specific configuration.
- **Per-framework code templates**: Rejected due to unbounded framework diversity making template maintenance infeasible.
- **Framework-conditional manual checklist**: Only generating manual checklists when no framework is configured -- rejected because non-automatable scenarios need manual coverage even with a framework.

## Consequences

### Positive
- Enables test-first development workflow where tests exist before implementation begins
- Every project gets structured verification via manual checklists, regardless of test framework adoption
- Framework-agnostic design supports any test framework without plugin changes
- Traceability from tests back to spec scenarios ensures no specified behavior is left untested
- Clean pipeline dependency chain: preflight validates specs, tests generates test artifacts, tasks references those artifacts

### Negative
- Pipeline expanded from 7 to 8 stages, adding one more artifact to every change
- LLM-generated test stubs may be too generic for complex frameworks -- mitigated by stubs being TDD red-phase starting points
- Manual vs. automatable classification relies on LLM heuristics, which may occasionally misclassify -- mitigated by `@manual` marker for user override
- Breaking pipeline change for consumers with old WORKFLOW.md -- mitigated by template-version bump (3 to 4) signaling the change

## References
- Change: openspec/changes/2026-04-10-auto-test-generation/
- Spec: openspec/specs/test-generation/spec.md
