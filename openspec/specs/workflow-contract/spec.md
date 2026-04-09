---
order: 3
category: reference
status: draft
change: 2026-04-09-pr-lifecycle-automation
version: 1
lastModified: 2026-04-08
---
## Purpose

Defines the WORKFLOW.md pipeline orchestration contract, Smart Template format, and the skill reading pattern for pipeline configuration.

## Requirements

### Requirement: WORKFLOW.md Pipeline Orchestration
The system SHALL support an `openspec/WORKFLOW.md` file as the pipeline orchestration contract. WORKFLOW.md SHALL use markdown-with-YAML-frontmatter format. The YAML frontmatter SHALL contain: `templates_dir` (path to Smart Templates directory), `pipeline` (ordered array of artifact IDs), `apply` (object with `requires`, `tracks`, and `instruction` fields), `post_artifact` (instructions executed after each artifact creation), `context` (path to constitution or behavioral context), optionally `docs_language`, and `template-version` (integer, for template merge detection during `/opsx:setup`). The markdown body MAY contain supplementary workflow documentation.

**User Story:** As a plugin maintainer I want a single WORKFLOW.md file for pipeline orchestration, so that all pipeline configuration lives in one place.

#### Scenario: Skill reads WORKFLOW.md for pipeline configuration
- **GIVEN** a project with `openspec/WORKFLOW.md` containing pipeline frontmatter
- **WHEN** any artifact-generating skill is invoked
- **THEN** the skill SHALL read WORKFLOW.md frontmatter for `templates_dir`, `pipeline`, `apply`, and `post_artifact` configuration

#### Scenario: WORKFLOW.md frontmatter contains required fields
- **GIVEN** a valid `openspec/WORKFLOW.md`
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `apply`, `post_artifact`, `context`, and `template-version` fields

### Requirement: Smart Template Format
All template files SHALL use the Smart Template format: markdown with YAML frontmatter containing `id` (artifact identifier), `description` (brief purpose), `generates` (output file path relative to change directory), `requires` (array of dependency artifact IDs), `instruction` (AI behavioral constraints for artifact generation), and `template-version` (integer, monotonically increasing — bumped when the plugin changes the template content). The markdown body SHALL define the output structure for the generated artifact. The `instruction` field content SHALL NOT be copied into generated artifacts — it serves as constraints for the AI during generation. The `template-version` field enables `/opsx:setup` to detect whether a local template has been customized by the user and to merge plugin updates with local customizations instead of overwriting them. The field is named `template-version` (not `version`) to distinguish it from spec `version` (content version tracking).

**User Story:** As a developer I want each template to be self-describing with its own instruction and metadata, so that I can understand what a template does without consulting a separate schema file.

#### Scenario: Smart Template contains required frontmatter fields
- **GIVEN** a Smart Template file (e.g., `openspec/templates/research.md`)
- **WHEN** its YAML frontmatter is inspected
- **THEN** it SHALL contain `id`, `description`, `generates`, `requires`, `instruction`, and `template-version` fields

#### Scenario: Skill reads instruction from template frontmatter
- **GIVEN** a Smart Template with an `instruction` field in its frontmatter
- **WHEN** a skill generates an artifact using this template
- **THEN** the skill SHALL apply the instruction as behavioral constraints
- **AND** SHALL NOT copy the instruction text into the generated artifact file

#### Scenario: Template body defines output structure
- **GIVEN** a Smart Template with markdown headings in its body
- **WHEN** a skill generates an artifact using this template
- **THEN** the generated artifact SHALL follow the section structure defined in the template body

#### Scenario: All templates use Smart Template format
- **GIVEN** the `openspec/templates/` directory
- **WHEN** all template files are inspected
- **THEN** every template (pipeline artifacts, docs, constitution) SHALL have YAML frontmatter with at minimum `id` and `description` fields

### Requirement: Skill Reading Pattern
Skills SHALL follow this reading pattern: (1) read `openspec/WORKFLOW.md` frontmatter for `templates_dir` and `pipeline` array, (2) for each artifact in `pipeline`, read `<templates_dir>/<id>.md` to get `generates`, `requires`, and `instruction` from frontmatter and output structure from body, (3) check artifact status via file existence at `openspec/changes/<name>/<generates>`, (4) read WORKFLOW.md's `context` field for project-level behavioral context, (5) execute `post_artifact` from WORKFLOW.md after artifact creation.

**User Story:** As a skill author I want a clear, documented pattern for reading pipeline configuration, so that all skills interact with the pipeline consistently.

#### Scenario: Skill resolves template path from WORKFLOW.md
- **GIVEN** WORKFLOW.md with `templates_dir: openspec/templates` and `pipeline: [research, ...]`
- **WHEN** a skill needs the research template
- **THEN** it SHALL read `openspec/templates/research.md`

#### Scenario: Skill checks artifact status via file existence
- **GIVEN** a change workspace at `openspec/changes/my-change/`
- **AND** a Smart Template with `generates: research.md`
- **WHEN** the skill checks artifact status
- **THEN** it SHALL check if `openspec/changes/my-change/research.md` exists and is non-empty

### Requirement: Automation Configuration

WORKFLOW.md frontmatter SHALL support an optional `automation` section that configures CI-triggered pipeline behavior. The `automation` section SHALL contain: `post_approval` (object defining what happens when a PR receives all required review approvals). The `post_approval` object SHALL contain: `steps` (ordered array of step identifiers — e.g., `[changelog, docs, version-bump]`), `labels` (object mapping state names to GitHub label names — `running`, `complete`, `failed`), `opt_out` (array of opt-out label names — e.g., `[skip-docs]`), and `auto_merge` (boolean, default `false` — when `true` AND an `auto-merge` label is present on the PR, the system SHALL enable auto-merge after successful pipeline completion). The `automation` section is the single source of truth for CI pipeline behavior — GitHub Action workflows SHALL read this configuration rather than hardcoding steps.

**User Story:** As a plugin maintainer I want CI automation behavior defined in WORKFLOW.md, so that the pipeline configuration stays centralized alongside the rest of the workflow contract.

#### Scenario: WORKFLOW.md contains automation configuration
- **GIVEN** a valid `openspec/WORKFLOW.md`
- **AND** the project has CI automation enabled
- **WHEN** the frontmatter is inspected
- **THEN** it SHALL contain an `automation.post_approval` section with `steps`, `labels`, `opt_out`, and `auto_merge` fields

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

#### Scenario: Opt-out label skips a step
- **GIVEN** `automation.post_approval.opt_out` contains `skip-docs`
- **AND** a PR has the label `skip-docs`
- **WHEN** the post-approval pipeline runs
- **THEN** the `docs` step SHALL be skipped
- **AND** all other steps SHALL execute normally

### Requirement: Pipeline Orchestrator Pattern

The workflow contract SHALL define a pattern for end-to-end pipeline orchestration via a single skill invocation. An orchestrator skill (e.g., `/opsx:auto`) SHALL read the `pipeline` array from WORKFLOW.md and execute each step as an isolated sub-agent using the Agent tool. Each sub-agent SHALL receive only the artifacts it needs as input (read from disk), produce its output artifact (written to disk), and return control to the orchestrator. The orchestrator SHALL validate the handoff between steps by checking artifact existence and frontmatter status before proceeding to the next step. If a handoff validation fails, the orchestrator SHALL stop, report the failure, and NOT proceed to subsequent steps.

The orchestrator SHALL support checkpoint/resume: if invoked on a change with existing artifacts, it SHALL skip completed steps (artifacts already exist) and resume from the first incomplete step. The orchestrator SHALL preserve all existing human gates defined in the QA loop (human-approval-gate spec) by default, with an optional `--auto-approve` flag that replaces human approval with the verify skill's pass/fail assessment.

**User Story:** As a developer I want to run the entire OpenSpec pipeline with a single command, so that routine changes can be processed end-to-end without manually invoking each step.

#### Scenario: Orchestrator runs full pipeline from scratch
- **GIVEN** a new change with no artifacts
- **WHEN** the user invokes `/opsx:auto`
- **THEN** the orchestrator SHALL read the `pipeline` array from WORKFLOW.md
- **AND** SHALL execute each pipeline step as an isolated sub-agent
- **AND** each sub-agent SHALL read its predecessor's artifacts from disk
- **AND** SHALL write its output artifact to the change directory

#### Scenario: Orchestrator resumes from checkpoint
- **GIVEN** a change with `research.md` and `proposal.md` already created
- **WHEN** the user invokes `/opsx:auto`
- **THEN** the orchestrator SHALL detect existing artifacts
- **AND** SHALL skip the research and proposal steps
- **AND** SHALL resume from the specs step

#### Scenario: Handoff validation fails
- **GIVEN** a change where the preflight step produced a verdict of BLOCKED
- **WHEN** the orchestrator checks the handoff gate after preflight
- **THEN** the orchestrator SHALL stop execution
- **AND** SHALL report: "Pipeline stopped: preflight verdict is BLOCKED"
- **AND** SHALL NOT proceed to task creation

#### Scenario: Sub-agent receives bounded context
- **GIVEN** the orchestrator is executing the design step
- **WHEN** the design sub-agent is spawned via the Agent tool
- **THEN** the sub-agent SHALL receive the design template instruction, the proposal, and the specs as input
- **AND** SHALL NOT receive the full conversation history of the orchestrator

#### Scenario: Human gate preserved by default
- **GIVEN** the orchestrator has completed the verify step with no CRITICAL issues
- **AND** the `--auto-approve` flag was NOT provided
- **WHEN** the orchestrator reaches the approval gate
- **THEN** the orchestrator SHALL pause and ask the user for explicit approval
- **AND** SHALL NOT proceed to post-apply steps without approval

#### Scenario: Auto-approve bypasses human gate
- **GIVEN** the orchestrator is invoked with `--auto-approve`
- **AND** the verify step passes with no CRITICAL issues
- **WHEN** the orchestrator reaches the approval gate
- **THEN** the orchestrator SHALL skip the human approval step
- **AND** SHALL proceed directly to post-apply steps

## Edge Cases

- **WORKFLOW.md missing**: Skills SHALL report an error and suggest running `/opsx:setup`.
- **Smart Template missing frontmatter**: Skills SHALL treat the file as a plain template (no instruction, no metadata) and report a warning.
- **Smart Template missing template-version field**: Setup SHALL treat the template as version 0 (always eligible for update). Skills reading templates SHALL ignore the `template-version` field — it is only used by setup for merge detection.
- **WORKFLOW.md with malformed YAML**: Skills SHALL report a parse error and stop.
- **Empty `pipeline` array**: Skills SHALL report that no artifacts are defined and stop.
- **`templates_dir` points to nonexistent directory**: Skills SHALL report the missing directory and suggest running `/opsx:setup`.
- **Automation section with unknown step**: If `automation.post_approval.steps` contains a step identifier that does not map to a known action (changelog, docs, version-bump), the system SHALL skip the unknown step and report a warning.
- **Orchestrator invoked on completed change**: If the proposal has `status: completed`, the orchestrator SHALL report that the change is already complete and stop.
- **Sub-agent fails mid-pipeline**: If a sub-agent exits with an error, the orchestrator SHALL report the error, note which step failed, and stop. Artifacts created by previous steps remain on disk (no rollback of successfully completed steps).
- **Concurrent orchestrator invocations**: If two orchestrator instances run on the same change simultaneously, they may conflict on file writes. The system does not prevent this — the user is responsible for avoiding concurrent runs.

## Assumptions

- Claude natively parses YAML frontmatter from markdown files when instructed to read and interpret them. <!-- ASSUMPTION: Claude YAML frontmatter parsing -->
- The Agent tool is available in the execution environment and supports spawning sub-agents with custom prompts and bounded context. <!-- ASSUMPTION: Agent tool availability -->
- Sub-agents spawned via the Agent tool can read and write files in the same working directory as the orchestrator. <!-- ASSUMPTION: Sub-agent file access -->
- GitHub Actions workflows can read WORKFLOW.md frontmatter when invoked via `claude-code-action`. <!-- ASSUMPTION: CI WORKFLOW.md access -->
