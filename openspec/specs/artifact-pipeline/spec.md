---
order: 4
category: change-workflow
---
## Purpose

Defines the schema-driven 6-stage artifact pipeline (research, proposal, specs, design, preflight, tasks) with strict dependency gating that ensures no stage is skipped and implementation is gated by task completion.

## Requirements

### Requirement: Six-Stage Pipeline
The system SHALL define a 6-stage artifact pipeline with the following stages in order: research, proposal, specs, design, preflight, and tasks. Each stage SHALL produce a verifiable artifact file. The pipeline stages SHALL execute in strict dependency order: research has no dependencies, proposal requires research, specs requires proposal, design requires specs, preflight requires design, and tasks requires preflight. No stage SHALL be skippable; each MUST complete before the next can begin.

**User Story:** As a developer I want a structured pipeline that guides me from research through to implementation tasks, so that no critical thinking step is skipped and every decision is documented.

#### Scenario: Pipeline stages execute in dependency order
- **GIVEN** a new change workspace with no artifacts generated
- **WHEN** the user progresses through the pipeline
- **THEN** the system SHALL enforce the order: research first, then proposal, then specs, then design, then preflight, then tasks

#### Scenario: Skipping a stage is prevented
- **GIVEN** a change workspace where only research.md has been generated
- **WHEN** a user or agent attempts to generate specs (skipping proposal)
- **THEN** the system SHALL reject the attempt and report that the proposal artifact must be completed first

#### Scenario: All stages produce verifiable artifacts
- **GIVEN** a completed pipeline run
- **WHEN** the change workspace is inspected
- **THEN** it SHALL contain research.md, proposal.md, one or more `specs/<capability>/spec.md` files, design.md, preflight.md, and tasks.md

### Requirement: Artifact Dependencies
Each artifact in the pipeline SHALL declare its dependencies explicitly in the schema. The dependency declaration SHALL list which preceding artifacts MUST be complete before the artifact can be generated. Skills SHALL enforce these dependencies by reading schema.yaml and checking artifact completion status via file existence before allowing generation of a dependent artifact. An artifact SHALL be considered complete when its corresponding file exists and is non-empty in the change workspace. For artifacts with glob patterns in the `generates` field (e.g., `specs/**/*.md`), completion SHALL be determined by at least one matching file existing.

**User Story:** As a developer I want the system to enforce artifact dependencies automatically, so that I cannot accidentally generate a design before the specs are written.

#### Scenario: Dependency check passes
- **GIVEN** a change workspace with completed research.md and proposal.md
- **WHEN** the system checks dependencies for the specs artifact
- **THEN** the dependency check SHALL pass because both research and proposal (the transitive chain) are complete

#### Scenario: Dependency check fails
- **GIVEN** a change workspace with only research.md completed
- **WHEN** the system checks dependencies for the design artifact
- **THEN** the dependency check SHALL fail and report that proposal and specs must be completed first

#### Scenario: Schema declares dependencies explicitly
- **GIVEN** the `schema.yaml` file
- **WHEN** the artifact definitions are inspected
- **THEN** each artifact SHALL have a `requires` field listing its direct dependencies by artifact ID

#### Scenario: Artifact status computed from file existence
- **GIVEN** a change workspace with research.md and proposal.md present
- **WHEN** a skill computes artifact status by reading schema.yaml
- **THEN** research and proposal SHALL be marked as "done", specs as "ready", and design/preflight/tasks as "blocked"

### Requirement: Apply Gate
Implementation (the apply phase) SHALL be gated by completion of the tasks artifact. The apply phase SHALL NOT begin until tasks.md exists and is non-empty. The apply phase SHALL track progress against the task checklist in tasks.md, marking items complete as implementation proceeds. The schema SHALL declare this gate via the `apply.requires` field referencing the tasks artifact.

**User Story:** As a project lead I want implementation to be gated by task completion in the pipeline, so that developers cannot start coding before the full analysis and planning cycle is done.

#### Scenario: Apply is blocked without tasks
- **GIVEN** a change workspace where preflight.md is the latest completed artifact and tasks.md does not exist
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system SHALL reject the apply attempt and report that tasks.md must be generated first

#### Scenario: Apply proceeds after tasks completion
- **GIVEN** a change workspace with all 6 artifacts completed including tasks.md
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system SHALL begin implementation, reading the task checklist from tasks.md and working through items sequentially

#### Scenario: Apply tracks progress in tasks.md
- **GIVEN** the apply phase is active and tasks.md contains 10 unchecked task items
- **WHEN** the agent completes a task item
- **THEN** the system SHALL mark the corresponding `- [ ]` checkbox as `- [x]` in tasks.md

### Requirement: Config Bootstrap
The `openspec/config.yaml` SHALL serve as a minimal bootstrap file. It SHALL contain only the schema reference and a global `context` pointing to the project constitution. All workflow rules SHALL be owned by the schema (in artifact `instruction` fields) or the constitution (project-specific rules) — not by config.yaml.

**User Story:** As a workflow maintainer I want config.yaml to be minimal, so that workflow rules live at their authoritative source (schema for universal rules, constitution for project rules) instead of being duplicated in config.

#### Scenario: Config contains only bootstrap content

- **GIVEN** the `openspec/config.yaml` file
- **WHEN** its contents are inspected
- **THEN** it SHALL contain a `schema` field referencing the active schema
- **AND** a `context` field pointing to the project constitution
- **AND** no other workflow rules or per-artifact `rules` entries

### Requirement: Proposal PR Integration
The proposal artifact instruction SHALL include steps for creating a feature branch and draft pull request after writing `proposal.md`. The instruction SHALL direct the agent to: (1) create a feature branch using the change name, (2) stage and commit change artifacts with a WIP commit message, (3) push the branch to the remote, and (4) create a draft PR via `gh pr create --draft` with the proposal content as the PR body. The instruction SHALL direct the agent to append a `## Pull Request` section to `proposal.md` recording the PR URL, branch name, and status. If `gh` CLI is unavailable or not authenticated, the instruction SHALL direct the agent to skip PR creation, record only the branch information, and note that a PR can be created manually.

**User Story:** As a developer I want a draft PR created automatically when my proposal is written, so that my team can review and discuss the change on GitHub before implementation begins.

#### Scenario: Draft PR created after proposal
- **GIVEN** a change workspace with research.md and proposal.md just created
- **AND** the `gh` CLI is installed and authenticated
- **WHEN** the agent finishes writing proposal.md
- **THEN** the agent SHALL create a feature branch named after the change
- **AND** SHALL commit the change artifacts (research.md, proposal.md)
- **AND** SHALL push the branch to the remote
- **AND** SHALL create a draft PR with the proposal content as the body
- **AND** SHALL append a `## Pull Request` section to proposal.md with the PR URL

#### Scenario: Graceful degradation without gh CLI
- **GIVEN** a change workspace with proposal.md just created
- **AND** the `gh` CLI is not installed or not authenticated
- **WHEN** the agent finishes writing proposal.md
- **THEN** the agent SHALL create the feature branch and push it
- **AND** SHALL append a `## Pull Request` section to proposal.md noting "PR not created — gh CLI unavailable"
- **AND** SHALL NOT block the pipeline

#### Scenario: Proposal template includes Pull Request section
- **GIVEN** the proposal template at `openspec/schemas/opsx-enhanced/templates/proposal.md`
- **WHEN** the template is inspected
- **THEN** it SHALL contain a `## Pull Request` section with placeholders for branch name, PR URL, and status

### Requirement: Schema Owns Workflow Rules
The schema's artifact `instruction` fields SHALL contain workflow rules that apply to all projects using the schema. The `tasks.instruction` SHALL include the Definition of Done rule (emergent from artifacts). The `tasks.instruction` SHALL include a standard tasks directive for including universal post-implementation steps from the template and appending constitution-defined project-specific extras. The `apply.instruction` SHALL include the post-apply workflow sequence. The `apply.instruction` SHALL clarify that standard tasks are not part of the apply phase and are executed separately after apply completes. The `apply.instruction` SHALL direct the agent to execute constitution-defined pre-merge standard tasks after the universal post-apply steps (commit and push), marking each as complete in tasks.md. Post-merge standard tasks SHALL remain unchecked as reminders for manual execution after the PR is merged.

#### Scenario: Tasks instruction includes DoD rule

- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `tasks.instruction` field is inspected
- **THEN** it SHALL contain a rule stating that Definition of Done is emergent from artifacts
- **AND** it SHALL reference Gherkin scenarios, success metrics, preflight findings, and user approval

#### Scenario: Apply instruction includes post-apply workflow

- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `apply.instruction` field is inspected
- **THEN** it SHALL contain the post-apply sequence: `/opsx:verify` → `/opsx:archive` → `/opsx:changelog` → `/opsx:docs` → commit → execute constitution pre-merge standard tasks

#### Scenario: Tasks instruction includes standard tasks directive

- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `tasks.instruction` field is inspected
- **THEN** it SHALL contain a directive to always include universal standard tasks from the template
- **AND** it SHALL instruct the agent to check the constitution for additional project-specific standard tasks
- **AND** it SHALL instruct the agent to append constitution extras after the universal steps

#### Scenario: Apply instruction clarifies standard tasks scope

- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `apply.instruction` field is inspected
- **THEN** it SHALL state that standard tasks (post-implementation section) are not part of apply
- **AND** they are tracked for auditability but executed separately after apply completes

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

### Requirement: Capability Granularity Guidance
The proposal `instruction` in the schema SHALL include explicit rules defining what constitutes a capability versus a feature detail. A "capability" SHALL be defined as a cohesive domain of behavior that a user or system exercises independently, typically containing 3-8 requirements and mapping to one testable surface area. A "feature detail" SHALL be defined as a single behavior, option, or edge case within a capability that belongs as a requirement inside an existing spec, not as a separate spec. The instruction SHALL state that if two proposed capabilities share the same actor, trigger, or data model, they are likely one capability and SHOULD be merged. The instruction SHALL state that a proposed capability producing fewer than ~100 lines (1-2 requirements) SHOULD be folded into a related existing capability.

**User Story:** As a developer creating a proposal I want clear rules on what qualifies as a new capability, so that I create cohesive domain specs instead of micro-specs for individual feature details.

#### Scenario: Guidance defines capability vs feature detail
- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `proposal.instruction` field is inspected
- **THEN** it SHALL contain a definition distinguishing capabilities (cohesive behavior domains) from feature details (individual behaviors within a domain)
- **AND** it SHALL include heuristics for merging (shared actor/trigger/data model) and minimum scope (3+ requirements)

#### Scenario: Agent consolidates related feature details into one capability
- **GIVEN** a user requesting three related UX changes (pagination, clickable rows, status labels) for a table view
- **WHEN** the agent creates the proposal's Capabilities section
- **THEN** the agent SHALL list one capability (e.g., `table-view`) with the individual changes as requirements, not three separate capabilities

### Requirement: Mandatory Consolidation Check
The proposal `instruction` in the schema SHALL include a mandatory consolidation check that the agent MUST perform before finalizing the Capabilities section. The consolidation check SHALL require the agent to: (1) list all existing specs in `openspec/specs/` and read their Purpose sections, (2) for each proposed new capability, check whether an existing spec already covers the domain and use Modified Capabilities if so, (3) for each pair of proposed new capabilities, check whether they share an actor, trigger, or data model and merge them if so, and (4) verify each proposed capability will have 3 or more distinct requirements, folding single-requirement capabilities into related specs.

**User Story:** As a project maintainer I want the proposal stage to enforce a consolidation check against existing specs, so that spec fragmentation is caught at the earliest possible point rather than post-hoc in preflight.

#### Scenario: Consolidation check is present in proposal instruction
- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `proposal.instruction` field is inspected
- **THEN** it SHALL contain a mandatory consolidation check with steps for reviewing existing specs, checking domain overlap, checking pair-wise overlap between new capabilities, and verifying minimum requirement count

#### Scenario: Agent identifies overlap with existing spec
- **GIVEN** a proposal for a feature that overlaps with the existing `quality-gates` spec
- **WHEN** the agent performs the consolidation check
- **THEN** the agent SHALL classify the feature as a Modified Capability on `quality-gates` rather than a New Capability

#### Scenario: Agent merges overlapping new capabilities
- **GIVEN** a proposal listing `admin-pagination` and `admin-clickable-rows` as separate new capabilities
- **WHEN** the agent performs the consolidation check
- **THEN** the agent SHALL merge them into a single capability (e.g., `admin-table-view`) because they share the same actor and data context

### Requirement: Proposal Template Consolidation Check Section
The proposal template SHALL include a `### Consolidation Check` section between the Modified Capabilities subsection and the `## Impact` section. This section SHALL require the agent to document: which existing specs were reviewed, the overlap assessment for each new capability (closest existing spec and why this is distinct or why Modified was chosen), and the merge assessment for pairs of new capabilities. If no new capabilities are proposed, the section SHALL contain "N/A — no new specs proposed."

**User Story:** As a reviewer reading a proposal I want to see the agent's consolidation reasoning documented, so that I can verify the capability boundaries are well-considered before specs are created.

#### Scenario: Proposal template includes Consolidation Check section
- **GIVEN** the proposal template at `openspec/schemas/opsx-enhanced/templates/proposal.md`
- **WHEN** the template is inspected
- **THEN** it SHALL contain a `### Consolidation Check` section with instructions for documenting existing specs reviewed, overlap assessment, and merge assessment

#### Scenario: Agent fills Consolidation Check for new capabilities
- **GIVEN** a proposal introducing two new capabilities
- **WHEN** the agent creates the proposal
- **THEN** the Consolidation Check section SHALL list which existing specs were reviewed, state the closest existing spec for each new capability, and document whether any pair of new capabilities was merged

#### Scenario: Consolidation Check for modification-only proposals
- **GIVEN** a proposal that only modifies existing capabilities with no new capabilities
- **WHEN** the agent creates the proposal
- **THEN** the Consolidation Check section SHALL contain "N/A — no new specs proposed."

### Requirement: Specs Overlap Verification
The specs `instruction` in the schema SHALL include an overlap verification step that the agent MUST perform before creating any spec files. The verification SHALL require the agent to: (1) read the proposal's Consolidation Check section, (2) scan existing specs in `openspec/specs/` for requirements with overlapping scope (same actor, trigger, or data model) for each new capability, and (3) if overlap is found, STOP and reclassify the capability as a Modified Capability on the existing spec before proceeding. The agent SHALL update the proposal's Capabilities section to reflect the reclassification.

**User Story:** As a developer I want the specs creation stage to double-check for overlap before creating files, so that any consolidation opportunities missed during proposal creation are caught before spec files are written.

#### Scenario: Overlap verification is present in specs instruction
- **GIVEN** the opsx-enhanced schema at `openspec/schemas/opsx-enhanced/schema.yaml`
- **WHEN** the `specs.instruction` field is inspected
- **THEN** it SHALL contain an overlap verification step before the "Create one spec file per capability" instruction

#### Scenario: Agent catches overlap during specs creation
- **GIVEN** a proposal that listed `admin-filters` as a new capability, but the baseline `admin-table-view` spec already covers filter behavior
- **WHEN** the agent begins the specs artifact phase and performs overlap verification
- **THEN** the agent SHALL reclassify `admin-filters` as a Modified Capability on `admin-table-view` and update the proposal before creating the spec file

## Edge Cases

- **Projects without a constitution**: If a project using opsx-enhanced has no constitution file, the config.yaml context pointer is harmless — the AI will note the missing file and proceed.
- **Migration from old config**: Existing projects with workflow rules in config.yaml context will continue to work — the rules are additive to schema instructions.
- If an artifact file exists but is empty (0 bytes), the system SHALL treat it as incomplete and not satisfy dependency checks.
- If a user manually deletes an artifact file mid-pipeline, the system SHALL detect the gap and require regeneration before proceeding.
- If the schema is modified to add a new artifact stage while a change is in progress, the system SHALL apply the new schema to new changes only; in-progress changes continue with the schema version active when they were created.
- If tasks.md contains no checkbox items (e.g., documentation-only change), the apply phase SHALL still be gated by tasks.md existence but will report that there are no implementation tasks to execute.
- If multiple spec files are required (one per capability), the specs stage SHALL not be considered complete until all capability specs listed in the proposal have been generated.
- If a project has zero existing specs (greenfield), the consolidation check still applies between proposed new capabilities but skip the existing-spec overlap scan.
- If an agent determines that an existing spec is too large (exceeding ~500 lines / 10+ requirements), it MAY propose splitting it rather than adding more requirements — but this should be documented as a conscious decision in the Consolidation Check section.
- If a proposed capability genuinely represents a new domain that shares no actor, trigger, or data model with existing specs, the consolidation check SHALL confirm this rather than force-merging.
- If the agent identifies overlap but the user explicitly requests separate specs (e.g., for team ownership reasons), the Consolidation Check SHALL document this decision with rationale.
- **Constitution changes between task generation and apply:** If the constitution's standard tasks are updated after tasks.md was generated, the already-generated tasks.md retains its original content. The user can regenerate tasks if needed.
- **Empty standard tasks section in constitution:** If the constitution contains `## Standard Tasks` but no checkbox items, only the universal template steps appear (no extras appended).
- **Custom section numbering:** If the QA Loop is not section 3 (e.g., due to merged sections), the standard tasks section SHALL use the next available number.
- **Project without constitution:** Universal template steps still appear; constitution extras are simply absent.
- **Branch already exists:** If the feature branch already exists (e.g., from a prior attempt), the agent SHALL reuse the existing branch rather than failing.
- **Network failure during PR creation:** If the push succeeds but `gh pr create` fails, the agent SHALL record the branch info and note the PR creation failure. The pipeline SHALL NOT be blocked.
- **No remote configured:** If no git remote is configured, the agent SHALL skip push and PR creation and note it in the Pull Request section.

## Assumptions

- The `gh` CLI, when available, is authenticated and has permission to create PRs on the current repository. <!-- ASSUMPTION: gh CLI authentication -->
- The change name (kebab-case) is a valid git branch name. <!-- ASSUMPTION: Branch name validity -->
- Artifact completion is determined by file existence and non-empty content, not by content validation or quality assessment. <!-- ASSUMPTION: File-existence-based completion -->
- Agent compliance with instruction-based guidance is sufficient for consolidation enforcement. The Consolidation Check template section provides a reviewable artifact as enforcement. <!-- ASSUMPTION: Agent compliance sufficient -->
- The constitution is read during task generation via the config.yaml context directive, which already points agents to the constitution. <!-- ASSUMPTION: Config-based constitution loading -->
- Verbatim copy means the agent transfers the exact markdown text without rewriting, reordering, or interpreting the items. <!-- ASSUMPTION: Verbatim means exact copy -->
No further assumptions beyond those marked above.
