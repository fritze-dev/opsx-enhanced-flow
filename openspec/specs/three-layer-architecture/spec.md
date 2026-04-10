---
order: 13
category: reference
status: draft
version: 3
lastModified: 2026-04-10
change: 2026-04-10-custom-actions
---
## Purpose

Defines the three-layer architecture (Constitution, WORKFLOW.md + Smart Templates, Router + Actions) that structures the opsx-enhanced plugin. Each layer has distinct responsibilities, separation rules, and interaction patterns that allow independent modification.

## Requirements

### Requirement: Constitution Layer
The system SHALL have a `CONSTITUTION.md` file at `openspec/CONSTITUTION.md` that defines global project rules. The constitution SHALL include sections for Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. All AI actions SHALL read the constitution before performing any work, enforced via WORKFLOW.md's `context` field. The constitution SHALL serve as the single authoritative source for project-wide rules that apply across all skills and artifacts.

**User Story:** As a project maintainer I want a single constitution file that governs all AI behavior, so that consistency is enforced without repeating rules in every skill.

#### Scenario: Constitution is read before any AI action
- **GIVEN** a project with `openspec/CONSTITUTION.md` and `openspec/WORKFLOW.md` containing a `context` field pointing to the constitution
- **WHEN** any AI-driven skill is invoked
- **THEN** the constitution file is read and its rules are applied to the action

#### Scenario: Constitution contains all required sections
- **GIVEN** a freshly bootstrapped project
- **WHEN** the constitution is generated
- **THEN** the file SHALL contain Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions sections

### Requirement: Schema Layer
The system SHALL use `openspec/WORKFLOW.md` (YAML frontmatter) combined with Smart Templates in `openspec/templates/` to define the 6-stage artifact pipeline. WORKFLOW.md SHALL declare the pipeline order, apply gate, and project context. Post-artifact commit/push logic is handled by the skill during propose pipeline traversal. Each Smart Template SHALL declare its artifact's instruction, output path, and dependencies via YAML frontmatter. Together, WORKFLOW.md and Smart Templates SHALL be the single source of truth for pipeline structure and artifact generation instructions. Skills SHALL read WORKFLOW.md and Smart Templates directly to obtain artifact definitions, instructions, and dependency information.

**User Story:** As a developer I want the artifact pipeline defined declaratively in WORKFLOW.md and self-describing templates, so that I can understand and modify the workflow without editing skill code.

#### Scenario: WORKFLOW.md defines the pipeline order
- **GIVEN** the `openspec/WORKFLOW.md` file
- **WHEN** its frontmatter is read by a skill
- **THEN** it SHALL declare a `pipeline` array with exactly 6 artifact IDs: research, proposal, specs, design, preflight, and tasks in that dependency order

#### Scenario: Each Smart Template has instruction and metadata
- **GIVEN** a Smart Template in `openspec/templates/`
- **WHEN** the template is inspected
- **THEN** it SHALL have `id`, `generates`, `requires`, and `instruction` fields in its YAML frontmatter

#### Scenario: Apply phase is gated by tasks
- **GIVEN** WORKFLOW.md with an `apply` section
- **WHEN** the apply configuration is inspected
- **THEN** it SHALL require the `tasks` artifact to be complete before implementation begins

### Requirement: Router + Actions Layer
The system SHALL deliver all commands through a single router SKILL.md that dispatches to inline actions defined in WORKFLOW.md. The router SHALL provide 4 built-in actions with specialized dispatch logic: `init` (project setup and health checks), `propose` (workspace creation and full artifact pipeline), `apply` (task implementation with review.md QA output), and `finalize` (changelog, docs, version bump, commit). The router SHALL additionally support consumer-defined custom actions listed in the WORKFLOW.md `actions` array, dispatching them via a generic Sub-Agent Execution pattern. The router SHALL be model-invocable (disable-model-invocation: false or absent).

**User Story:** As a developer I want a single router that dispatches to built-in and custom actions, so that the command surface is extensible and all behavior is defined declaratively in WORKFLOW.md.

#### Scenario: Router dispatches to built-in actions
- **GIVEN** a fully installed plugin
- **WHEN** the `skills/` directory is listed
- **THEN** it SHALL contain a single router `SKILL.md` that dispatches to init, propose, apply, and finalize actions

#### Scenario: Router dispatches to custom actions
- **GIVEN** a consumer WORKFLOW.md with `actions: [init, propose, apply, qa-review, finalize]`
- **AND** a `## Action: qa-review` body section with `### Instruction`
- **WHEN** a user invokes `/opsx:workflow qa-review`
- **THEN** the router SHALL dispatch the custom action using the generic Sub-Agent Execution pattern

#### Scenario: Router is model-invocable
- **GIVEN** the router `SKILL.md`
- **WHEN** its YAML frontmatter is inspected
- **THEN** the `disable-model-invocation` field SHALL be set to `false` or be absent (defaulting to false)

### Requirement: Layer Separation
The three layers SHALL be independently modifiable. WORKFLOW.md and Smart Templates SHALL NOT embed action logic; instead, the router and actions SHALL depend on WORKFLOW.md and Smart Templates by reading them directly for pipeline configuration, artifact definitions, instructions, and dependencies. The constitution SHALL NOT contain pipeline-specific artifact definitions. Modifications to one layer SHALL NOT require changes to another layer unless the interface contract between them changes.

**User Story:** As a maintainer I want each layer to be independently modifiable, so that I can update pipeline stages without rewriting actions, or change global rules without touching the workflow contract.

#### Scenario: WORKFLOW.md change does not require skill changes
- **GIVEN** WORKFLOW.md is updated with a new action instruction
- **WHEN** the change is applied
- **THEN** existing actions SHALL continue to function without modification because they read WORKFLOW.md dynamically at runtime

#### Scenario: Adding a custom action does not require router changes
- **GIVEN** a consumer adds `qa-review` to their WORKFLOW.md `actions` array and writes a `## Action: qa-review` body section
- **WHEN** the user invokes `/opsx:workflow qa-review`
- **THEN** the router SHALL dispatch the custom action without any modification to the router SKILL.md

#### Scenario: Constitution update does not require WORKFLOW.md changes
- **GIVEN** a new code style rule is added to CONSTITUTION.md
- **WHEN** the constitution is updated
- **THEN** WORKFLOW.md SHALL remain unchanged because it does not embed constitution rules

#### Scenario: Action update does not require constitution or WORKFLOW.md changes
- **GIVEN** an action's instruction text needs refinement
- **WHEN** the action definition in WORKFLOW.md is updated
- **THEN** neither the constitution nor the router SKILL.md SHALL require modification

## Edge Cases

- If the constitution is missing or empty, the router SHALL report an error rather than proceeding without rules.
- If WORKFLOW.md is malformed YAML, the router SHALL report a read error rather than proceeding with invalid data.
- If the router SKILL.md is missing, the Claude Code plugin system SHALL not register any commands.
- If a new action is added without updating documentation, the system still functions but documentation is stale (detected by review.md generation during apply).

## Assumptions

- The Claude Code plugin system discovers the router by scanning `skills/*/SKILL.md` files and uses YAML frontmatter for configuration. <!-- ASSUMPTION: Router discovery mechanism -->
- The WORKFLOW.md `context` field reliably enforces constitution reading before action execution. <!-- ASSUMPTION: Context enforcement -->
No further assumptions beyond those marked above.
