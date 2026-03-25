---
order: 4
category: change-workflow
---
## MODIFIED Requirements

### Requirement: Six-Stage Pipeline
The system SHALL define a 6-stage artifact pipeline with the following stages in order: research, proposal, specs, design, preflight, and tasks. Each stage SHALL produce a verifiable artifact file. The pipeline stages SHALL execute in strict dependency order: research has no dependencies, proposal requires research, specs requires proposal, design requires specs, preflight requires design, and tasks requires preflight. No stage SHALL be skippable; each MUST complete before the next can begin. The pipeline order SHALL be declared in the `pipeline` array of `openspec/WORKFLOW.md` frontmatter. Each stage's metadata (generates, requires, instruction) SHALL be defined in the corresponding Smart Template's YAML frontmatter.

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
Each artifact in the pipeline SHALL declare its dependencies explicitly in the Smart Template's YAML frontmatter `requires` field. Skills SHALL enforce these dependencies by reading WORKFLOW.md and Smart Templates and checking artifact completion status via file existence before allowing generation of a dependent artifact. An artifact SHALL be considered complete when its corresponding file exists and is non-empty in the change workspace. For artifacts with glob patterns in the `generates` field (e.g., `specs/**/*.md`), completion SHALL be determined by at least one matching file existing.

**User Story:** As a developer I want the system to enforce artifact dependencies automatically, so that I cannot accidentally generate a design before the specs are written.

#### Scenario: Dependency check passes
- **GIVEN** a change workspace with completed research.md and proposal.md
- **WHEN** the system checks dependencies for the specs artifact
- **THEN** the dependency check SHALL pass because both research and proposal (the transitive chain) are complete

#### Scenario: Dependency check fails
- **GIVEN** a change workspace with only research.md completed
- **WHEN** the system checks dependencies for the design artifact
- **THEN** the dependency check SHALL fail and report that proposal and specs must be completed first

#### Scenario: Smart Template declares dependencies explicitly
- **GIVEN** a Smart Template file (e.g., `openspec/templates/proposal.md`)
- **WHEN** its YAML frontmatter is inspected
- **THEN** it SHALL have a `requires` field listing its direct dependencies by artifact ID (e.g., `[research]`)

#### Scenario: Artifact status computed from file existence
- **GIVEN** a change workspace with research.md and proposal.md present
- **WHEN** a skill computes artifact status by reading WORKFLOW.md and Smart Templates
- **THEN** research and proposal SHALL be marked as "done", specs as "ready", and design/preflight/tasks as "blocked"

### Requirement: Apply Gate
Implementation (the apply phase) SHALL be gated by completion of the tasks artifact. The apply phase SHALL NOT begin until tasks.md exists and is non-empty. The apply phase SHALL track progress against the task checklist in tasks.md, marking items complete as implementation proceeds. WORKFLOW.md SHALL declare this gate via the `apply.requires` field referencing the tasks artifact.

**User Story:** As a project lead I want implementation to be gated by task completion in the pipeline, so that developers cannot start coding before the full analysis and planning cycle is done.

#### Scenario: Apply is blocked without tasks
- **GIVEN** a change workspace where preflight.md is the latest completed artifact and tasks.md does not exist
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system SHALL reject the apply attempt and report that tasks.md must be generated first

#### Scenario: Apply proceeds after tasks completion
- **GIVEN** a change workspace with all 6 artifacts completed including tasks.md
- **WHEN** the user invokes `/opsx:apply`
- **THEN** the system SHALL begin implementation, reading the task checklist from tasks.md

#### Scenario: Apply tracks progress in tasks.md
- **GIVEN** the apply phase is active and tasks.md contains 10 unchecked task items
- **WHEN** the agent completes a task item
- **THEN** the system SHALL mark the corresponding `- [ ]` checkbox as `- [x]` in tasks.md

### Requirement: WORKFLOW.md Owns Pipeline Configuration
`openspec/WORKFLOW.md` SHALL serve as the pipeline orchestration file. Its YAML frontmatter SHALL contain: `templates_dir` pointing to the Smart Templates directory, `pipeline` array defining artifact order, `apply` object with `requires` and `instruction`, `post_artifact` instructions for commit/push/PR, `context` pointing to the constitution, and optionally `docs_language`. Skills SHALL read WORKFLOW.md for all pipeline-level configuration.

**User Story:** As a workflow maintainer I want pipeline orchestration in a single WORKFLOW.md file, so that configuration is not scattered across schema.yaml and config.yaml.

#### Scenario: WORKFLOW.md contains pipeline orchestration
- **GIVEN** the `openspec/WORKFLOW.md` file
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `apply`, `post_artifact`, and `context` fields

### Requirement: Post-Artifact Commit and PR Integration
WORKFLOW.md SHALL define a `post_artifact` field containing instructions that the `/opsx:ff` skill executes after creating each artifact. The `post_artifact` instruction SHALL direct the agent to: (1) check if a feature branch for the change exists — if not, create one via `git checkout -b <change-name>`, (2) stage and commit the change artifacts with a WIP commit message including the artifact ID, (3) push the branch to the remote, and (4) on the first push only, create a draft PR via `gh pr create --draft`. If the `post_artifact` field is absent from WORKFLOW.md (backward compatibility), the skill SHALL skip post-artifact operations silently.

**User Story:** As a developer I want every artifact committed incrementally with a draft PR created on the first commit, so that my team has early visibility and every pipeline stage is tracked in version control.

#### Scenario: First artifact triggers branch and PR creation
- **GIVEN** a change workspace where no feature branch exists yet
- **AND** the `gh` CLI is installed and authenticated
- **WHEN** the agent finishes creating the first artifact
- **THEN** the agent SHALL create a feature branch, commit, push, and create a draft PR

#### Scenario: Subsequent artifacts commit and push only
- **GIVEN** a change workspace with an existing feature branch and draft PR
- **WHEN** the agent finishes creating a subsequent artifact
- **THEN** the agent SHALL commit and push but SHALL NOT create a new PR

#### Scenario: Graceful degradation without gh CLI
- **GIVEN** the `gh` CLI is not installed or not authenticated
- **WHEN** the agent finishes creating the first artifact
- **THEN** the agent SHALL create the branch, commit, attempt push, and skip PR creation

#### Scenario: WORKFLOW.md without post_artifact field
- **GIVEN** a WORKFLOW.md that does not contain a `post_artifact` field
- **WHEN** the agent finishes creating an artifact
- **THEN** the agent SHALL skip post-artifact operations and proceed normally

### Requirement: Smart Templates Own Workflow Rules
Each Smart Template's `instruction` field SHALL contain workflow rules that apply to its artifact type. The tasks template instruction SHALL include the Definition of Done rule (emergent from artifacts). The tasks template instruction SHALL include a standard tasks directive for including universal post-implementation steps and appending constitution-defined project-specific extras. The apply instruction in WORKFLOW.md SHALL include the post-apply workflow sequence and clarify that standard tasks are executed separately after apply completes.

#### Scenario: Tasks template instruction includes DoD rule
- **GIVEN** the tasks Smart Template at `openspec/templates/tasks.md`
- **WHEN** its `instruction` frontmatter field is inspected
- **THEN** it SHALL contain a rule stating that Definition of Done is emergent from artifacts

#### Scenario: Apply instruction in WORKFLOW.md includes post-apply workflow
- **GIVEN** `openspec/WORKFLOW.md`
- **WHEN** the `apply.instruction` field is inspected
- **THEN** it SHALL contain the post-apply sequence: `/opsx:verify` → `/opsx:archive` → `/opsx:changelog` → `/opsx:docs`

### Requirement: Capability Granularity Guidance
The proposal Smart Template's `instruction` field SHALL include explicit rules defining what constitutes a capability versus a feature detail, including heuristics for merging (shared actor/trigger/data model) and minimum scope (3+ requirements).

#### Scenario: Guidance defines capability vs feature detail
- **GIVEN** the proposal Smart Template at `openspec/templates/proposal.md`
- **WHEN** its `instruction` frontmatter field is inspected
- **THEN** it SHALL contain a definition distinguishing capabilities from feature details and merging heuristics

### Requirement: Mandatory Consolidation Check
The proposal Smart Template's `instruction` field SHALL include a mandatory consolidation check requiring the agent to review existing specs, check domain overlap, check pair-wise overlap between new capabilities, and verify minimum requirement counts.

#### Scenario: Consolidation check is present in proposal template instruction
- **GIVEN** the proposal Smart Template at `openspec/templates/proposal.md`
- **WHEN** its `instruction` frontmatter field is inspected
- **THEN** it SHALL contain a mandatory consolidation check with steps for existing spec review, domain overlap, pair-wise overlap, and minimum requirements

### Requirement: Specs Overlap Verification
The specs Smart Template's `instruction` field SHALL include an overlap verification step before creating spec files, requiring the agent to read the proposal's Consolidation Check and scan existing specs for overlap.

#### Scenario: Overlap verification is present in specs template instruction
- **GIVEN** the specs Smart Template at `openspec/templates/specs/spec.md`
- **WHEN** its `instruction` frontmatter field is inspected
- **THEN** it SHALL contain an overlap verification step

## REMOVED Requirements

### Requirement: Config Bootstrap
**Reason**: `openspec/config.yaml` is replaced by `openspec/WORKFLOW.md`. The bootstrap configuration (schema reference, context pointer, docs_language) is now in WORKFLOW.md frontmatter.
**Migration**: Run `/opsx:setup` to generate WORKFLOW.md from existing config.yaml content.

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system SHALL treat it as incomplete.
- If a user manually deletes an artifact file mid-pipeline, the system SHALL detect the gap and require regeneration.
- If tasks.md contains no checkbox items (documentation-only change), the apply phase SHALL still be gated by tasks.md existence.
- If multiple spec files are required, the specs stage SHALL not be considered complete until all capability specs listed in the proposal have been generated.
- **Branch already exists:** The agent SHALL reuse the existing branch rather than failing.
- **Network failure during PR creation:** The pipeline SHALL NOT be blocked.
- **Auto-continue transitions:** The `post_artifact` hook runs after each artifact individually.

## Assumptions

- The `gh` CLI, when available, is authenticated and has permission to create PRs. <!-- ASSUMPTION: gh CLI authentication -->
- Artifact completion is determined by file existence and non-empty content. <!-- ASSUMPTION: File-existence-based completion -->
- Agent compliance with instruction-based guidance is sufficient for consolidation enforcement. <!-- ASSUMPTION: Agent compliance sufficient -->
- The WORKFLOW.md context field reliably enforces constitution loading. <!-- ASSUMPTION: Context-based constitution loading -->
No further assumptions beyond those marked above.
