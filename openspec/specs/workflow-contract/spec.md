---
order: 3
category: reference
status: stable
version: 2
lastModified: 2026-04-09
---
## Purpose

Defines the WORKFLOW.md pipeline orchestration contract, Smart Template format, and the skill reading pattern for pipeline configuration.

## Requirements

### Requirement: WORKFLOW.md Pipeline Orchestration
The system SHALL support an `openspec/WORKFLOW.md` file as the pipeline orchestration contract. WORKFLOW.md SHALL use markdown-with-YAML-frontmatter format with a clear separation of concerns:

**YAML frontmatter** — structured configuration only:
- `template-version` (integer, for template merge detection during `/opsx:setup`)
- `templates_dir` (path to Smart Templates directory)
- `pipeline` (ordered array of step IDs — both artifact steps and action steps)
- `apply` (object with `requires` and `tracks` fields)
- `worktree` (optional object with `enabled`, `path_pattern`, `auto_cleanup`)
- `automation` (optional CI pipeline configuration)
- `docs_language` (optional, defaults to English)

**Markdown body** — prose instructions as named sections:
- `## Context` — project-level behavioral context (e.g., constitution reference, language rules)
- `## Post-Artifact Hook` — instructions executed after each artifact creation (branch management, commit, push, draft PR)

The `pipeline` array SHALL be the single source of truth for the complete change lifecycle — from research through finalization. Frontmatter SHALL NOT contain multi-line prose instructions — these belong in body sections or in action template `instruction` fields.

**User Story:** As a plugin maintainer I want a single WORKFLOW.md file for pipeline orchestration with structured config in frontmatter and prose instructions in the body, so that the file is both machine-readable and human-readable.

#### Scenario: Skill reads WORKFLOW.md for pipeline configuration
- **GIVEN** a project with `openspec/WORKFLOW.md` containing frontmatter and body sections
- **WHEN** any pipeline-executing skill is invoked
- **THEN** the skill SHALL read frontmatter for `templates_dir`, `pipeline`, and `apply` configuration
- **AND** SHALL read the `## Post-Artifact Hook` body section for post-artifact instructions
- **AND** SHALL read the `## Context` body section for behavioral context

#### Scenario: WORKFLOW.md frontmatter contains required structured fields
- **GIVEN** a valid `openspec/WORKFLOW.md`
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `apply`, and `template-version` fields
- **AND** SHALL NOT contain multi-line prose instructions

#### Scenario: WORKFLOW.md body contains instruction sections
- **GIVEN** a valid `openspec/WORKFLOW.md`
- **WHEN** its markdown body is inspected
- **THEN** it SHALL contain `## Context` and `## Post-Artifact Hook` sections with prose instructions

#### Scenario: Pipeline array contains both artifact and action steps
- **GIVEN** a valid `openspec/WORKFLOW.md`
- **WHEN** the `pipeline` array is inspected
- **THEN** it MAY contain both artifact step IDs (e.g., `research`, `proposal`) and action step IDs (e.g., `apply`, `verify`, `changelog`)
- **AND** each ID SHALL map to a template file at `<templates_dir>/<id>.md`

### Requirement: Smart Template Format
All template files SHALL use the Smart Template format: markdown with YAML frontmatter containing `id` (step identifier), `description` (brief purpose), `requires` (array of dependency step IDs), `instruction` (AI behavioral constraints for execution), and `template-version` (integer, monotonically increasing — bumped when the plugin changes the template content).

Templates SHALL support two types via an optional `type` field:
- **`type: artifact`** (default when `type` is absent): Generates a file. Frontmatter SHALL additionally contain `generates` (output file path relative to change directory). The markdown body SHALL define the output structure for the generated artifact. Status is determined by file existence at the `generates` path.
- **`type: action`**: Executes a skill or action. Action steps are always executed when their dependencies are satisfied — the action itself handles idempotency (e.g., `apply` checks which tasks are still open, `changelog` checks which entries already exist). Action templates MAY have a markdown body for supplementary documentation but it is not used as output structure.

The `instruction` field content SHALL NOT be copied into generated artifacts — it serves as constraints for the AI during generation or execution. The `template-version` field enables `/opsx:setup` to detect whether a local template has been customized by the user and to merge plugin updates with local customizations instead of overwriting them. The field is named `template-version` (not `version`) to distinguish it from spec `version` (content version tracking).

**User Story:** As a developer I want each pipeline step to be self-describing with its own instruction and metadata, so that I can understand what a step does and whether it generates an artifact or executes an action.

#### Scenario: Artifact template contains required frontmatter fields
- **GIVEN** a Smart Template file with `type: artifact` (or no `type` field)
- **WHEN** its YAML frontmatter is inspected
- **THEN** it SHALL contain `id`, `description`, `generates`, `requires`, `instruction`, and `template-version` fields

#### Scenario: Action template contains required frontmatter fields
- **GIVEN** a Smart Template file with `type: action`
- **WHEN** its YAML frontmatter is inspected
- **THEN** it SHALL contain `id`, `description`, `requires`, `instruction`, and `template-version` fields
- **AND** SHALL NOT require a `generates` field

#### Scenario: Skill reads instruction from template frontmatter
- **GIVEN** a Smart Template with an `instruction` field in its frontmatter
- **WHEN** a skill executes a step using this template
- **THEN** the skill SHALL apply the instruction as behavioral constraints
- **AND** SHALL NOT copy the instruction text into generated artifacts

#### Scenario: Template body defines output structure for artifacts
- **GIVEN** a Smart Template with `type: artifact` and markdown headings in its body
- **WHEN** a skill generates an artifact using this template
- **THEN** the generated artifact SHALL follow the section structure defined in the template body

#### Scenario: All templates use Smart Template format
- **GIVEN** the `openspec/templates/` directory
- **WHEN** all template files are inspected
- **THEN** every template (pipeline artifacts, actions, docs, constitution) SHALL have YAML frontmatter with at minimum `id` and `description` fields

### Requirement: Skill Reading Pattern
Skills SHALL follow this reading pattern: (1) read `openspec/WORKFLOW.md` frontmatter for `templates_dir` and `pipeline` array, (2) for each step in `pipeline`, read `<templates_dir>/<id>.md` to get frontmatter fields and (for artifact types) output structure from body, (3) check step status: for artifact steps (`type: artifact` or no `type`), check file existence at `openspec/changes/<name>/<generates>`; for action steps (`type: action`), always execute when dependencies are satisfied (the action handles its own idempotency), (4) read WORKFLOW.md's `## Context` body section for project-level behavioral context, (5) for artifact steps, execute the instructions from WORKFLOW.md's `## Post-Artifact Hook` body section after artifact creation.

When executing action steps, skills SHALL use the Agent tool to spawn an isolated sub-agent for each step. The sub-agent SHALL receive the template's `instruction` as its primary directive and only the artifacts listed in `requires` as input context (read from disk). This bounded-context approach prevents context window exhaustion during full pipeline execution.

Skills SHALL support checkpoint/resume: if invoked on a change with existing artifacts or completed actions, they SHALL skip completed steps and resume from the first incomplete step. If a step's status check indicates failure (e.g., preflight verdict BLOCKED), the skill SHALL stop and report the failure.

**User Story:** As a skill author I want a clear, documented pattern for reading pipeline configuration, so that all skills interact with the pipeline consistently — whether the step generates an artifact or executes an action.

#### Scenario: Skill resolves template path from WORKFLOW.md
- **GIVEN** WORKFLOW.md with `templates_dir: openspec/templates` and `pipeline: [research, ...]`
- **WHEN** a skill needs the research template
- **THEN** it SHALL read `openspec/templates/research.md`

#### Scenario: Skill checks artifact status via file existence
- **GIVEN** a change workspace at `openspec/changes/my-change/`
- **AND** a Smart Template with `type: artifact` and `generates: research.md`
- **WHEN** the skill checks step status
- **THEN** it SHALL check if `openspec/changes/my-change/research.md` exists and is non-empty

#### Scenario: Skill reads context from WORKFLOW.md body
- **GIVEN** a WORKFLOW.md with a `## Context` section in the markdown body
- **WHEN** a skill needs project-level behavioral context
- **THEN** it SHALL read the `## Context` section content
- **AND** SHALL NOT look for a `context` field in the frontmatter

#### Scenario: Skill reads post-artifact hook from WORKFLOW.md body
- **GIVEN** a WORKFLOW.md with a `## Post-Artifact Hook` section in the markdown body
- **WHEN** a skill has created an artifact
- **THEN** it SHALL execute the instructions from the `## Post-Artifact Hook` section

#### Scenario: Skill always executes action steps when dependencies met
- **GIVEN** a pipeline with an action step `apply` that `requires: [tasks]`
- **AND** the `tasks` artifact step is complete (file exists)
- **WHEN** the skill reaches the `apply` step
- **THEN** it SHALL execute the action (the action itself determines what work remains)

#### Scenario: Skill executes action step as sub-agent
- **GIVEN** a pipeline step with `type: action` and `requires: [tasks]`
- **WHEN** the skill executes this step
- **THEN** it SHALL spawn a sub-agent via the Agent tool
- **AND** the sub-agent SHALL receive the template's `instruction` and the required artifacts as input
- **AND** SHALL NOT receive the orchestrator's full conversation history

#### Scenario: Skill resumes from checkpoint
- **GIVEN** a change with `research.md` and `proposal.md` already created
- **WHEN** a pipeline-executing skill is invoked
- **THEN** it SHALL detect existing artifacts and skip completed steps
- **AND** SHALL resume from the first incomplete step

### Requirement: Automation Configuration

WORKFLOW.md frontmatter SHALL support an optional `automation` section that configures CI-triggered pipeline behavior. The `automation` section SHALL contain: `post_approval` (object defining what happens when a PR receives all required review approvals). The `post_approval` object SHALL contain: `steps` (ordered array of step identifiers — e.g., `[changelog, docs, version-bump]`) and `labels` (object mapping state names to GitHub label names — `running`, `complete`, `failed`). The `automation` section is the single source of truth for CI pipeline behavior — GitHub Action workflows SHALL read this configuration rather than hardcoding steps.

**User Story:** As a plugin maintainer I want CI automation behavior defined in WORKFLOW.md, so that the pipeline configuration stays centralized alongside the rest of the workflow contract.

#### Scenario: WORKFLOW.md contains automation configuration
- **GIVEN** a valid `openspec/WORKFLOW.md`
- **AND** the project has CI automation enabled
- **WHEN** the frontmatter is inspected
- **THEN** it SHALL contain an `automation.post_approval` section with `steps` and `labels` fields

#### Scenario: CI workflow reads automation config from WORKFLOW.md
- **GIVEN** a GitHub Actions workflow triggered by PR review approval
- **WHEN** the workflow starts executing
- **THEN** it SHALL read `openspec/WORKFLOW.md` frontmatter for `automation.post_approval` configuration
- **AND** SHALL execute the steps listed in `automation.post_approval.steps` in order

#### Scenario: Automation section is optional
- **GIVEN** a valid `openspec/WORKFLOW.md` without an `automation` section
- **WHEN** a skill or CI workflow checks for automation config
- **THEN** the system SHALL treat automation as disabled
- **AND** SHALL NOT report an error

### Requirement: Full Pipeline Execution

The `/opsx:ff` skill SHALL support executing the complete `pipeline` array from WORKFLOW.md, including both artifact steps and action steps. When the pipeline contains action steps beyond the traditional artifact pipeline, ff SHALL process them using the sub-agent pattern defined in the Skill Reading Pattern requirement. The skill SHALL preserve all existing human gates defined in the QA loop (human-approval-gate spec) by default, pausing at action steps that require user interaction. An optional `--auto-approve` flag SHALL replace human approval with the verify skill's pass/fail assessment, enabling fully autonomous pipeline execution.

**User Story:** As a developer I want to run the entire OpenSpec pipeline with a single `/opsx:ff` command, so that routine changes can be processed end-to-end without manually invoking each step.

#### Scenario: ff executes full pipeline including action steps
- **GIVEN** a WORKFLOW.md with `pipeline: [research, proposal, specs, design, preflight, tasks, apply, verify, changelog, docs, version-bump]`
- **AND** a new change with no artifacts
- **WHEN** the user invokes `/opsx:ff`
- **THEN** ff SHALL execute each step in order, using artifact generation for artifact steps and sub-agent invocation for action steps

#### Scenario: ff pauses at human gates
- **GIVEN** a pipeline execution has completed the verify action step with no CRITICAL issues
- **AND** the `--auto-approve` flag was NOT provided
- **WHEN** ff reaches the approval gate in the QA loop
- **THEN** ff SHALL pause and ask the user for explicit approval
- **AND** SHALL NOT proceed to post-apply action steps without approval

#### Scenario: Auto-approve enables autonomous execution
- **GIVEN** ff is invoked with `--auto-approve`
- **AND** the verify step passes with no CRITICAL issues
- **WHEN** ff reaches the approval gate
- **THEN** ff SHALL skip the human approval step
- **AND** SHALL proceed directly to post-apply action steps

## Edge Cases

- **WORKFLOW.md missing**: Skills SHALL report an error and suggest running `/opsx:setup`.
- **Smart Template missing frontmatter**: Skills SHALL treat the file as a plain template (no instruction, no metadata) and report a warning.
- **Smart Template missing template-version field**: Setup SHALL treat the template as version 0 (always eligible for update). Skills reading templates SHALL ignore the `template-version` field — it is only used by setup for merge detection.
- **WORKFLOW.md with malformed YAML**: Skills SHALL report a parse error and stop.
- **Empty `pipeline` array**: Skills SHALL report that no artifacts are defined and stop.
- **`templates_dir` points to nonexistent directory**: Skills SHALL report the missing directory and suggest running `/opsx:setup`.
- **Automation section with unknown step**: If `automation.post_approval.steps` contains a step identifier that does not map to a known action, the system SHALL skip the unknown step and report a warning.
- **Pipeline step without template file**: If a step ID in the `pipeline` array has no corresponding template at `<templates_dir>/<id>.md`, the skill SHALL report the missing template and stop.
- **ff invoked on completed change**: If the proposal has `status: completed`, ff SHALL report that the change is already complete and stop.
- **Sub-agent fails mid-pipeline**: If a sub-agent exits with an error, ff SHALL report the error, note which step failed, and stop. Artifacts created by previous steps remain on disk (no rollback of successfully completed steps).
- **Concurrent pipeline invocations**: If two pipeline executions run on the same change simultaneously, they may conflict on file writes. The system does not prevent this — the user is responsible for avoiding concurrent runs.

## Assumptions

- Claude natively parses YAML frontmatter from markdown files when instructed to read and interpret them. <!-- ASSUMPTION: Claude YAML frontmatter parsing -->
- The Agent tool is available in the execution environment and supports spawning sub-agents with custom prompts and bounded context. <!-- ASSUMPTION: Agent tool availability -->
- Sub-agents spawned via the Agent tool can read and write files in the same working directory as the orchestrator. <!-- ASSUMPTION: Sub-agent file access -->
- GitHub Actions workflows can read WORKFLOW.md frontmatter when invoked via `claude-code-action`. <!-- ASSUMPTION: CI WORKFLOW.md access -->
