---
order: 3
category: reference
status: stable
version: 5
lastModified: 2026-04-10
---
## Purpose

Defines the WORKFLOW.md pipeline orchestration contract, Smart Template format, inline action definitions, custom actions, and the router dispatch pattern for pipeline configuration.

## Requirements

### Requirement: WORKFLOW.md Pipeline Orchestration

The system SHALL support an `openspec/WORKFLOW.md` file as the pipeline orchestration contract. WORKFLOW.md SHALL use markdown-with-YAML-frontmatter format with a clear separation of concerns:

**YAML frontmatter** — structured configuration only:
- `template-version` (integer, for template merge detection during `/opsx:workflow init`)
- `templates_dir` (path to Smart Templates directory)
- `pipeline` (ordered array of artifact step IDs — each generates a file)
- `actions` (array of action names, e.g., `[init, propose, apply, finalize]` — each has a corresponding `## Action: <name>` body section)
- `worktree` (optional object with `enabled`, `path_pattern`, `auto_cleanup`)
- `auto_approve` (optional boolean, defaults to `true` — when true, the full propose→apply→finalize flow runs end-to-end without checkpoints on success paths; when false, pauses at every checkpoint including design review, preflight, user testing, and cross-action transitions)
- `docs_language` (optional, defaults to English)

**Markdown body** — prose instructions as named sections:
- `## Context` — project-level behavioral context (e.g., constitution reference, language rules)

The `pipeline` array SHALL be the single source of truth for the artifact generation sequence. Frontmatter SHALL NOT contain multi-line prose instructions — these belong in body sections or in action `instruction` fields.

**User Story:** As a plugin maintainer I want a single WORKFLOW.md file for pipeline orchestration and action definitions, so that all workflow configuration lives in one place.

#### Scenario: Router reads WORKFLOW.md for pipeline configuration
- **GIVEN** a project with `openspec/WORKFLOW.md` containing frontmatter and body sections
- **WHEN** any command is invoked
- **THEN** the router SHALL read frontmatter for `templates_dir`, `pipeline`, and `actions` configuration
- **AND** SHALL read the `## Context` body section for behavioral context

#### Scenario: WORKFLOW.md frontmatter contains required structured fields
- **GIVEN** a valid `openspec/WORKFLOW.md`
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `actions`, and `template-version` fields
- **AND** SHALL NOT contain multi-line prose instructions in frontmatter

#### Scenario: WORKFLOW.md body contains instruction sections
- **GIVEN** a valid `openspec/WORKFLOW.md`
- **WHEN** its markdown body is inspected
- **THEN** it SHALL contain `## Context` and `## Action: <name>` sections with prose instructions

### Requirement: Smart Template Format

All template files SHALL use the Smart Template format: markdown with YAML frontmatter containing `id` (artifact identifier), `description` (brief purpose), `generates` (output file path relative to change directory), `requires` (array of dependency artifact IDs), `instruction` (AI behavioral constraints for artifact generation), and `template-version` (integer, monotonically increasing — bumped when the plugin changes the template content). The markdown body SHALL define the output structure for the generated artifact. The `instruction` field content SHALL NOT be copied into generated artifacts — it serves as constraints for the AI during generation. The `template-version` field enables `/opsx:workflow init` to detect whether a local template has been customized by the user and to merge plugin updates with local customizations instead of overwriting them.

**User Story:** As a developer I want each template to be self-describing with its own instruction and metadata, so that I can understand what a template does without consulting a separate schema file.

#### Scenario: Smart Template contains required frontmatter fields
- **GIVEN** a Smart Template file (e.g., `openspec/templates/research.md`)
- **WHEN** its YAML frontmatter is inspected
- **THEN** it SHALL contain `id`, `description`, `generates`, `requires`, `instruction`, and `template-version` fields

#### Scenario: Instruction applied as constraints not content
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

### Requirement: Inline Action Definitions

WORKFLOW.md frontmatter SHALL contain `actions` as an array of action names. The array SHALL include the 4 built-in actions (`init`, `propose`, `apply`, `finalize`) and MAY include additional consumer-defined custom actions (e.g., `actions: [init, propose, apply, qa-review, finalize]`). Each action SHALL have a corresponding `## Action: <name>` section in the WORKFLOW.md markdown body containing only `### Instruction` (procedural guidance for the AI agent). For built-in actions, requirement links (clickable markdown links to specific spec requirements using the format `[Requirement Name](openspec/specs/<spec>/spec.md#requirement-<slug>)`) SHALL live in the SKILL.md file, NOT in WORKFLOW.md. Custom actions do not have requirement links in SKILL.md — their instruction text in WORKFLOW.md SHALL be self-contained. This structure ensures prose stays out of frontmatter, the sub-agent receives focused context, and requirement wiring is managed at the skill level for built-in actions. Actions are NOT pipeline steps — they do not generate artifacts in the pipeline sequence. Actions are invoked by the router when the user calls the corresponding command.

For built-in actions, the router SHALL read the `### Instruction` from the WORKFLOW.md body section and the requirement links from the SKILL.md, load the referenced requirement sections from specs, and spawn a sub-agent via the Agent tool with the instruction text as primary directive and the extracted requirements as behavioral context. For custom actions, the router SHALL read the `### Instruction` from the WORKFLOW.md body section and execute it directly — the executing agent decides whether to handle it inline or spawn a sub-agent based on the instruction content. Custom actions do not receive spec requirement links.

The system SHALL provide 4 built-in actions: `init` (project initialization and health check), `propose` (pipeline traversal for artifact generation), `apply` (task implementation with review.md generation), and `finalize` (post-approval changelog, docs, and version-bump). Consumer projects MAY define additional custom actions by adding them to the `actions` array and providing corresponding `## Action: <name>` body sections.

**User Story:** As a consumer project maintainer I want to define custom actions in my WORKFLOW.md alongside the built-in ones, so that I can extend the workflow with project-specific steps without modifying the plugin.

#### Scenario: Action defined as body section with instruction
- **GIVEN** a WORKFLOW.md with a `## Action: apply` body section
- **WHEN** the section is inspected
- **THEN** it SHALL contain `### Instruction` with procedural guidance text
- **AND** it SHALL NOT contain requirement links (those live in the SKILL.md)

#### Scenario: Router executes built-in action as sub-agent
- **GIVEN** a user invokes `/opsx:workflow apply`
- **WHEN** the router reads `## Action: apply` from WORKFLOW.md body and requirement links from the SKILL.md
- **THEN** it SHALL parse the requirement links from the SKILL.md
- **AND** SHALL load each linked requirement section from the target spec files
- **AND** SHALL read the `### Instruction` from the WORKFLOW.md body section
- **AND** SHALL spawn a sub-agent with `### Instruction` text as primary directive and extracted requirements as behavioral context
- **AND** the sub-agent SHALL NOT receive the router's full conversation history

#### Scenario: Router executes custom action as sub-agent
- **GIVEN** a WORKFLOW.md with `actions: [init, propose, apply, qa-review, finalize]`
- **AND** a `## Action: qa-review` body section with `### Instruction`
- **WHEN** a user invokes `/opsx:workflow qa-review`
- **THEN** the router SHALL read the `### Instruction` from the `## Action: qa-review` body section
- **AND** SHALL execute the instruction directly (the agent decides whether to handle it inline or spawn a sub-agent)
- **AND** SHALL NOT look for requirement links in the SKILL.md for this action

#### Scenario: Actions are not pipeline steps
- **GIVEN** a WORKFLOW.md with `pipeline: [research, proposal, specs, design, preflight, tasks, review]`
- **AND** `actions: [init, propose, apply, qa-review, finalize]`
- **WHEN** the pipeline is traversed
- **THEN** actions SHALL NOT be included in the pipeline artifact sequence
- **AND** SHALL only be invoked via direct command

### Requirement: Router Dispatch Pattern

The system SHALL provide a single router skill that handles all user-facing commands. The router SHALL validate commands against the `actions` array from WORKFLOW.md frontmatter. If WORKFLOW.md is missing, the router SHALL fall back to the built-in actions: `init`, `propose`, `apply`, `finalize`. The router SHALL implement shared orchestration logic once:
1. **Intent recognition**: Determine which command was invoked and validate it against the `actions` array
2. **Change context detection** (for all actions except `init`): Get current branch via `git rev-parse --abbrev-ref HEAD`, scan `openspec/changes/*/proposal.md` for a proposal whose `branch` frontmatter field matches, fall back to worktree convention if inside a worktree
3. **WORKFLOW.md loading**: Read frontmatter for `templates_dir`, `pipeline`, and `actions`
4. **Dispatch**: For `propose` — traverse the pipeline, generate artifacts, handle checkpoint/resume. For `apply`/`finalize`/`init` — read action definition from WORKFLOW.md, spawn sub-agent with instruction + requirement links. For custom actions — read action definition from WORKFLOW.md, execute instruction directly with change context (no requirement links, agent decides execution mode).

**User Story:** As a developer I want a single entry point that handles built-in and custom actions with shared logic, so that change detection and context loading happen once and consumer projects can extend the workflow.

#### Scenario: Router detects change from branch
- **GIVEN** the user is on branch `my-feature`
- **AND** `openspec/changes/2026-04-09-my-feature/proposal.md` has `branch: my-feature` in frontmatter
- **WHEN** the user invokes `/opsx:workflow apply`
- **THEN** the router SHALL auto-detect the change and announce "Detected change context: using change '2026-04-09-my-feature'"

#### Scenario: Router dispatches propose to pipeline traversal
- **GIVEN** the user invokes `/opsx:workflow propose my-feature`
- **WHEN** the router processes the command
- **THEN** it SHALL create the change workspace if needed
- **AND** SHALL traverse the `pipeline` array, generating artifacts in sequence
- **AND** SHALL support checkpoint/resume (skip completed artifacts)

#### Scenario: Router dispatches apply to sub-agent
- **GIVEN** the user invokes `/opsx:workflow apply`
- **WHEN** the router detects the change and reads `actions.apply`
- **THEN** it SHALL spawn a sub-agent with the apply instruction and referenced specs

#### Scenario: Init runs without change context
- **GIVEN** the user invokes `/opsx:workflow init`
- **WHEN** the router processes the command
- **THEN** it SHALL skip change context detection
- **AND** SHALL execute the init action directly

#### Scenario: Router dispatches custom action via generic fallback
- **GIVEN** a WORKFLOW.md with `actions: [init, propose, apply, qa-review, finalize]`
- **AND** a `## Action: qa-review` body section with `### Instruction`
- **WHEN** a user invokes `/opsx:workflow qa-review`
- **THEN** the router SHALL validate `qa-review` against the `actions` array
- **AND** SHALL read the `### Instruction` from the `## Action: qa-review` section
- **AND** SHALL execute the instruction directly (agent decides execution mode)
- **AND** SHALL NOT look for requirement links in SKILL.md

#### Scenario: Router auto-dispatches propose→apply→finalize when auto_approve is true
- **GIVEN** `auto_approve: true` in WORKFLOW.md
- **AND** the user invokes `/opsx:workflow propose my-feature`
- **WHEN** propose completes successfully (all pipeline artifacts generated)
- **THEN** the router SHALL automatically dispatch apply without pausing
- **AND** when apply completes with review.md verdict PASS, SHALL automatically dispatch finalize
- **AND** SHALL only pause if a FAIL verdict, BLOCKED preflight, or genuine clarification question occurs

#### Scenario: Router pauses at each transition when auto_approve is false
- **GIVEN** `auto_approve: false` in WORKFLOW.md
- **AND** the user invokes `/opsx:workflow propose my-feature`
- **WHEN** propose completes
- **THEN** the router SHALL stop and suggest `/opsx:workflow apply`
- **AND** SHALL NOT auto-dispatch subsequent actions

#### Scenario: Router rejects action not in actions array
- **GIVEN** a WORKFLOW.md with `actions: [init, propose, apply, finalize]`
- **WHEN** a user invokes `/opsx:workflow deploy`
- **THEN** the router SHALL report that `deploy` is not a recognized action
- **AND** SHALL list the available actions from the `actions` array

## Edge Cases

- **WORKFLOW.md missing**: Router SHALL report an error and suggest running `/opsx:workflow init`.
- **Smart Template missing frontmatter**: Router SHALL treat the file as a plain template (no instruction, no metadata) and report a warning.
- **Smart Template missing template-version field**: Init SHALL treat the template as version 0 (always eligible for update).
- **WORKFLOW.md with malformed YAML**: Router SHALL report a parse error and stop.
- **Empty `pipeline` array**: Router SHALL report that no artifacts are defined and stop.
- **`templates_dir` points to nonexistent directory**: Router SHALL report the missing directory and suggest running `/opsx:workflow init`.
- **Unknown action referenced**: If an action name does not match any entry in the `actions` array from WORKFLOW.md frontmatter, the router SHALL report the error and list available actions.
- **Action with missing spec**: If a spec listed in the SKILL.md's requirement links does not exist at the referenced path, the sub-agent SHALL proceed without it and note the missing spec.
- **Custom action without body section**: If a custom action is listed in the `actions` array but has no corresponding `## Action: <name>` body section in WORKFLOW.md, the router SHALL report the missing instruction and stop.
- **Custom action with init skip**: Custom actions SHALL go through change context detection (like apply/finalize), not skip it like init. If a custom action does not need change context, the instruction text should handle that.

## Assumptions

- Claude natively parses YAML frontmatter from markdown files when instructed to read and interpret them. <!-- ASSUMPTION: Claude YAML frontmatter parsing -->
- The Agent tool is available in the execution environment and supports spawning sub-agents with custom prompts and bounded context. <!-- ASSUMPTION: Agent tool availability -->
- Sub-agents spawned via the Agent tool can read and write files in the same working directory as the router. <!-- ASSUMPTION: Sub-agent file access -->
