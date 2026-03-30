## ADDED Requirements

### Requirement: Standard Tasks Directive in Task Generation

The schema's `tasks.instruction` SHALL include a standard tasks directive. The tasks template SHALL include a section 4 with universal post-implementation steps (archive, changelog, docs, commit and push) that apply to all opsx-enhanced projects. The `tasks.instruction` SHALL additionally instruct the agent to check the project constitution for a `## Standard Tasks` section. If the constitution defines extra standard tasks, the agent SHALL append them to the template's universal steps in the generated `tasks.md`. If no `## Standard Tasks` section exists in the constitution, the agent SHALL include only the universal steps from the template.

**User Story:** As a project maintainer I want universal post-implementation steps automatically in every task list, with the option to add project-specific extras in my constitution, so that all projects get a consistent baseline and each project can extend it.

#### Scenario: Universal standard tasks always included

- **GIVEN** a change progressing through the artifact pipeline
- **AND** the tasks template contains section 4 with universal standard tasks
- **WHEN** the tasks artifact is generated
- **THEN** the generated `tasks.md` SHALL contain a final section titled `## 4. Standard Tasks (Post-Implementation)` (or the next available number)
- **AND** the section SHALL contain the universal steps: archive, changelog, docs, commit and push

#### Scenario: Constitution extras appended to universal steps

- **GIVEN** a project constitution containing a `## Standard Tasks` section with 1 extra checkbox item
- **AND** a change progressing through the artifact pipeline
- **WHEN** the tasks artifact is generated
- **THEN** the generated `tasks.md` section 4 SHALL contain the universal steps from the template
- **AND** SHALL append the 1 extra item from the constitution after the universal steps

#### Scenario: No constitution extras

- **GIVEN** a project constitution that does not contain a `## Standard Tasks` section
- **AND** a change progressing through the artifact pipeline
- **WHEN** the tasks artifact is generated
- **THEN** the generated `tasks.md` SHALL contain section 4 with only the universal steps from the template

#### Scenario: Template includes universal standard tasks

- **GIVEN** the tasks template at `openspec/schemas/opsx-enhanced/templates/tasks.md`
- **WHEN** the template is inspected
- **THEN** it SHALL contain a section 4 with universal post-implementation steps as checkbox items

## MODIFIED Requirements

### Requirement: Schema Owns Workflow Rules

The schema's artifact `instruction` fields SHALL contain workflow rules that apply to all projects using the schema. The `tasks.instruction` SHALL include the Definition of Done rule (emergent from artifacts). The `tasks.instruction` SHALL include a standard tasks directive for including universal post-implementation steps from the template and appending constitution-defined project-specific extras. The `apply.instruction` SHALL include the post-apply workflow sequence. The `apply.instruction` SHALL clarify that standard tasks are not part of the apply phase and are executed separately after apply completes.

#### Scenario: Tasks instruction includes DoD rule

- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `tasks.instruction` field is inspected
- **THEN** it SHALL contain a rule stating that Definition of Done is emergent from artifacts
- **AND** it SHALL reference Gherkin scenarios, success metrics, preflight findings, and user approval

#### Scenario: Tasks instruction includes standard tasks directive

- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `tasks.instruction` field is inspected
- **THEN** it SHALL contain a directive to always include universal standard tasks from the template
- **AND** it SHALL instruct the agent to check the constitution for additional project-specific standard tasks
- **AND** it SHALL instruct the agent to append constitution extras after the universal steps

#### Scenario: Apply instruction includes post-apply workflow

- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `apply.instruction` field is inspected
- **THEN** it SHALL contain the post-apply sequence: `/opsx:verify` → `/opsx:archive` → `/opsx:changelog` → `/opsx:docs` → commit

#### Scenario: Apply instruction clarifies standard tasks scope

- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `apply.instruction` field is inspected
- **THEN** it SHALL state that standard tasks (post-implementation section) are not part of apply
- **AND** they are tracked for auditability but executed separately after apply completes

## Edge Cases

- **Constitution changes between task generation and apply:** If the constitution's standard tasks are updated after tasks.md was generated, the already-generated tasks.md retains its original content. The user can regenerate tasks if needed.
- **Empty standard tasks section in constitution:** If the constitution contains `## Standard Tasks` but no checkbox items, only the universal template steps appear (no extras appended).
- **Custom section numbering:** If the QA Loop is not section 3 (e.g., due to merged sections), the standard tasks section SHALL use the next available number.
- **Project without constitution:** Universal template steps still appear; constitution extras are simply absent.

## Assumptions

<!-- ASSUMPTION: The constitution is read during task generation via the config.yaml context directive, which already points agents to the constitution -->
<!-- ASSUMPTION: Verbatim copy means the agent transfers the exact markdown text without rewriting, reordering, or interpreting the items -->
