---
order: 4
category: change-workflow
status: draft
version: 1
lastModified: 2026-04-09
change: 2026-04-09-skill-consolidation
---
## Purpose

Defines the 7-stage artifact pipeline (research, proposal, specs, design, preflight, tasks, review) driven by WORKFLOW.md and Smart Templates, with strict dependency gating that ensures no stage is skipped, implementation is gated by task completion, and verification produces a review.md artifact.

## Requirements

### Requirement: Seven-Stage Pipeline
The system SHALL define a 7-stage artifact pipeline with the following stages in order: research, proposal, specs, design, preflight, tasks, and review. Each stage SHALL produce a verifiable artifact file. The pipeline stages SHALL execute in strict dependency order: research has no dependencies, proposal requires research, specs requires proposal, design requires specs, preflight requires design, tasks requires preflight, and review requires tasks. The review artifact is generated during the apply phase (after implementation) rather than during artifact-forward generation. No stage SHALL be skippable; each MUST complete before the change is considered complete. The pipeline order SHALL be declared in the `pipeline` array of `openspec/WORKFLOW.md` frontmatter. Each stage's metadata (generates, requires, instruction) SHALL be defined in the corresponding Smart Template's YAML frontmatter.

**User Story:** As a developer I want a structured pipeline that guides me from research through to implementation tasks, so that no critical thinking step is skipped and every decision is documented.

#### Scenario: Pipeline stages execute in dependency order
- **GIVEN** a new change workspace with no artifacts generated
- **WHEN** the user progresses through the pipeline
- **THEN** the system SHALL enforce the order: research first, then proposal, then specs, then design, then preflight, then tasks, then review

#### Scenario: Skipping a stage is prevented
- **GIVEN** a change workspace where only research.md has been generated
- **WHEN** a user or agent attempts to generate specs (skipping proposal)
- **THEN** the system SHALL reject the attempt and report that the proposal artifact must be completed first

#### Scenario: All stages produce verifiable artifacts
- **GIVEN** a completed pipeline run
- **WHEN** the change workspace is inspected
- **THEN** it SHALL contain research.md, proposal.md, one or more `specs/<capability>/spec.md` files, design.md, preflight.md, tasks.md, and review.md

### Requirement: Artifact Output Frontmatter
Certain pipeline artifacts SHALL include YAML frontmatter in their generated output for machine-readable metadata:

- **proposal.md**: SHALL include frontmatter with `status` (active/completed), `branch`, optionally `worktree`, and `capabilities` (structured list of new/modified/removed capability names mirroring the body's Capabilities section). Skills that create proposals SHALL populate these fields. Skills that read proposals SHALL use frontmatter fields preferentially over parsing markdown sections.
- **design.md**: SHALL include frontmatter with `has_decisions` (boolean, `true` if the Decisions section contains at least one entry). Skills that scan for design decisions (docs, docs-verify) SHALL check this field to skip designs without decisions.

Other artifacts (research.md, preflight.md, tasks.md) do not require output frontmatter.

**User Story:** As a skill author I want artifacts to carry machine-readable metadata, so that downstream skills can query artifact properties without parsing markdown sections.

#### Scenario: Proposal includes capabilities frontmatter
- **GIVEN** a proposal that lists `user-auth` as new and `quality-gates` as modified
- **WHEN** the proposal is generated
- **THEN** `proposal.md` SHALL include frontmatter `capabilities: { new: [user-auth], modified: [quality-gates], removed: [] }`

#### Scenario: Design includes has_decisions frontmatter
- **GIVEN** a design artifact with a Decisions table containing 3 entries
- **WHEN** the design is generated
- **THEN** `design.md` SHALL include frontmatter `has_decisions: true`

#### Scenario: Design without decisions table
- **GIVEN** a design artifact with no Decisions section (e.g., simple implementation with no architectural choices)
- **WHEN** the design is generated
- **THEN** `design.md` SHALL include frontmatter `has_decisions: false`

#### Scenario: Skills prefer frontmatter over markdown parsing
- **GIVEN** a proposal with frontmatter `capabilities: { new: [user-auth], modified: [], removed: [] }`
- **WHEN** a skill needs to identify affected capabilities
- **THEN** the skill SHALL read the `capabilities` frontmatter field
- **AND** SHALL NOT parse the `## Capabilities` markdown section

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
`openspec/WORKFLOW.md` SHALL serve as the pipeline orchestration file. Its YAML frontmatter SHALL contain: `templates_dir` pointing to the Smart Templates directory, `pipeline` array defining artifact order, `apply` object with `requires` and `instruction`, `post_artifact` instructions for commit/push/PR, `context` pointing to the constitution, optionally `docs_language`, and optionally `worktree` object with `enabled` (boolean), `path_pattern` (string with `{change}` placeholder), and `auto_cleanup` (boolean). Skills SHALL read WORKFLOW.md for all pipeline-level configuration.

**User Story:** As a workflow maintainer I want pipeline orchestration in a single WORKFLOW.md file, so that all pipeline configuration lives in one place.

#### Scenario: WORKFLOW.md contains pipeline orchestration
- **GIVEN** the `openspec/WORKFLOW.md` file
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain `templates_dir`, `pipeline`, `actions`, and `template-version` fields
- **AND** the `pipeline` array SHALL include `review` as the final stage

#### Scenario: WORKFLOW.md contains optional worktree configuration
- **GIVEN** the `openspec/WORKFLOW.md` file with worktree mode enabled
- **WHEN** its frontmatter is inspected
- **THEN** it SHALL contain a `worktree` object with `enabled: true`, `path_pattern`, and `auto_cleanup` fields

#### Scenario: WORKFLOW.md without worktree configuration
- **GIVEN** the `openspec/WORKFLOW.md` file without a `worktree` section
- **WHEN** a skill reads WORKFLOW.md
- **THEN** the skill SHALL treat worktree mode as disabled and use existing directory-based behavior

### Requirement: Post-Artifact Commit and PR Integration
WORKFLOW.md SHALL define a `post_artifact` field containing instructions that the `/opsx:propose` skill executes after creating each artifact. The `post_artifact` instruction SHALL direct the agent to: (1) check the current branch — if already on `<change-name>` branch (e.g., in a worktree), skip branch creation; if on main, create the branch via `git checkout -b <change-name>`; if on another branch, switch to it via `git checkout <change-name>`, (2) stage and commit the change artifacts with a WIP commit message including the artifact ID, (3) push the branch to the remote, and (4) on the first push only, create a draft PR via `gh pr create --draft`. If the `post_artifact` field is absent from WORKFLOW.md, the skill SHALL skip post-artifact operations.

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

#### Scenario: Worktree skips branch creation
- **GIVEN** a change workspace in a git worktree already on the `<change-name>` branch
- **WHEN** the agent finishes creating an artifact
- **THEN** the agent SHALL skip the branch creation step and proceed directly to staging, committing, and pushing

#### Scenario: Graceful degradation without gh CLI
- **GIVEN** the `gh` CLI is not installed or not authenticated
- **WHEN** the agent finishes creating the first artifact
- **THEN** the agent SHALL create the branch, commit, attempt push, and skip PR creation

#### Scenario: WORKFLOW.md without post_artifact field
- **GIVEN** a WORKFLOW.md that does not contain a `post_artifact` field
- **WHEN** the agent finishes creating an artifact
- **THEN** the agent SHALL skip post-artifact operations and proceed normally

### Requirement: Post-Implementation Commit Before Approval

The WORKFLOW.md `apply.instruction` SHALL direct the agent to commit and push all implementation changes after `/opsx:apply` passes and before pausing for user approval. The commit message SHALL use the format `WIP: <change-name> — implementation`. This follows the same pattern as `post_artifact` (WIP commit + push per checkpoint) but applies to the implementation phase rather than the artifact phase, and is defined in `apply.instruction` rather than the tasks template. If push fails, the system SHALL continue with a local commit and note that the user should review changes locally. This WIP commit is distinct from the final commit in the Standard Tasks section, which includes changelog, docs, and version bump.

**User Story:** As a developer I want implementation changes committed and pushed before I'm asked for approval, so that I can review the actual PR diff rather than being asked to approve uncommitted local changes.

#### Scenario: Implementation committed before user testing

- **GIVEN** a change with all implementation tasks complete and Auto-Verify passed
- **WHEN** the post-apply workflow reaches the commit-before-approval step
- **THEN** the system SHALL commit all changed files with message `WIP: <change-name> — implementation`
- **AND** SHALL push to the remote branch
- **AND** the PR diff SHALL be available for the user to review before User Testing

#### Scenario: Graceful degradation on push failure

- **GIVEN** a change where Auto-Verify passed but `git push` fails
- **WHEN** the post-apply workflow reaches the commit-before-approval step
- **THEN** the system SHALL create a local commit
- **AND** SHALL note that the user should review changes locally
- **AND** SHALL proceed to User Testing

#### Scenario: WIP commit does not replace final commit

- **GIVEN** a change where the WIP implementation commit was created during the post-apply workflow
- **AND** the post-apply workflow completes changelog, docs, and version bump
- **WHEN** the Standard Tasks commit step is reached
- **THEN** the system SHALL create a separate commit with all post-apply changes
- **AND** the WIP commit and the final commit SHALL be distinct commits in the git history

### Requirement: Smart Templates Own Workflow Rules
Each Smart Template's `instruction` field SHALL contain workflow rules that apply to its artifact type. The tasks template instruction SHALL include the Definition of Done rule (emergent from artifacts). The tasks template instruction SHALL include a standard tasks directive for including universal post-implementation steps and appending constitution-defined project-specific extras. The apply instruction in WORKFLOW.md SHALL include the post-apply workflow sequence and clarify that standard tasks are executed separately after apply completes.

#### Scenario: Tasks template instruction includes DoD rule
- **GIVEN** the tasks Smart Template at `openspec/templates/tasks.md`
- **WHEN** its `instruction` frontmatter field is inspected
- **THEN** it SHALL contain a rule stating that Definition of Done is emergent from artifacts

#### Scenario: Apply instruction in WORKFLOW.md includes post-apply workflow
- **GIVEN** `openspec/WORKFLOW.md`
- **WHEN** the `apply.instruction` field is inspected
- **THEN** it SHALL contain the post-apply sequence: `/opsx:apply` → `/opsx:changelog` → `/opsx:docs`

### Requirement: Standard Tasks Directive in Task Generation

The tasks Smart Template's `instruction` field SHALL include a standard tasks directive. The tasks template SHALL include a section 4 with universal post-implementation steps (changelog, docs, version bump, commit and push) that apply to all opsx-enhanced projects. The `instruction` SHALL additionally instruct the agent to check the project constitution for a `## Standard Tasks` section. If the constitution defines extra standard tasks, the agent SHALL append them to the template's universal steps in the generated `tasks.md`. If no `## Standard Tasks` section exists in the constitution, the agent SHALL include only the universal steps from the template.

**User Story:** As a project maintainer I want universal post-implementation steps automatically in every task list, with the option to add project-specific extras in my constitution, so that all projects get a consistent baseline and each project can extend it.

#### Scenario: Universal standard tasks always included

- **GIVEN** a change progressing through the artifact pipeline
- **AND** the tasks template contains section 4 with universal standard tasks
- **WHEN** the tasks artifact is generated
- **THEN** the generated `tasks.md` SHALL contain a final section titled `## 4. Standard Tasks (Post-Implementation)` (or the next available number)
- **AND** the section SHALL contain the universal steps: changelog, docs, version bump, commit and push

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

- **GIVEN** the tasks template at `openspec/templates/tasks.md`
- **WHEN** the template is inspected
- **THEN** it SHALL contain a section 4 with universal post-implementation steps as checkbox items

### Requirement: Capability Granularity Guidance
The proposal Smart Template's `instruction` field SHALL include explicit rules defining what constitutes a capability versus a feature detail, including heuristics for merging (shared actor/trigger/data model) and minimum scope (3+ requirements).

#### Scenario: Guidance defines capability vs feature detail
- **GIVEN** the proposal Smart Template at `openspec/templates/proposal.md`
- **WHEN** its `instruction` frontmatter field is inspected
- **THEN** it SHALL contain a definition distinguishing capabilities from feature details and merging heuristics

#### Scenario: Agent consolidates related feature details into one capability
- **GIVEN** a user requesting three related UX changes (pagination, clickable rows, status labels) for a table view
- **WHEN** the agent creates the proposal's Capabilities section
- **THEN** the agent SHALL list one capability (e.g., `table-view`) with the individual changes as requirements, not three separate capabilities

### Requirement: Mandatory Consolidation Check
The proposal Smart Template's `instruction` field SHALL include a mandatory consolidation check requiring the agent to review existing specs, check domain overlap, check pair-wise overlap between new capabilities, and verify minimum requirement counts.

#### Scenario: Consolidation check is present in proposal template instruction
- **GIVEN** the proposal Smart Template at `openspec/templates/proposal.md`
- **WHEN** its `instruction` frontmatter field is inspected
- **THEN** it SHALL contain a mandatory consolidation check with steps for existing spec review, domain overlap, pair-wise overlap, and minimum requirements

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
- **GIVEN** the proposal template at `openspec/templates/proposal.md`
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
The specs Smart Template's `instruction` field SHALL include an overlap verification step before editing spec files, requiring the agent to read the proposal's Consolidation Check and scan existing specs for overlap.

#### Scenario: Overlap verification is present in specs template instruction
- **GIVEN** the specs Smart Template at `openspec/templates/specs/spec.md`
- **WHEN** its `instruction` frontmatter field is inspected
- **THEN** it SHALL contain an overlap verification step

#### Scenario: Agent catches overlap during specs creation
- **GIVEN** a proposal that listed `admin-filters` as a new capability, but the baseline `admin-table-view` spec already covers filter behavior
- **WHEN** the agent begins the specs artifact phase and performs overlap verification
- **THEN** the agent SHALL reclassify `admin-filters` as a Modified Capability on `admin-table-view` and update the proposal before editing the spec file

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system SHALL treat it as incomplete.
- If a user manually deletes an artifact file mid-pipeline, the system SHALL detect the gap and require regeneration.
- If tasks.md contains no checkbox items (documentation-only change), the apply phase SHALL still be gated by tasks.md existence.
- If multiple spec files are required, the specs stage SHALL not be considered complete until all capability specs listed in the proposal have been generated.
- If a project has zero existing specs (greenfield), the consolidation check still applies between proposed new capabilities but skip the existing-spec overlap scan.
- If an agent determines that an existing spec is too large (exceeding ~500 lines / 10+ requirements), it MAY propose splitting it rather than adding more requirements — but this should be documented as a conscious decision in the Consolidation Check section.
- If a proposed capability genuinely represents a new domain that shares no actor, trigger, or data model with existing specs, the consolidation check SHALL confirm this rather than force-merging.
- If the agent identifies overlap but the user explicitly requests separate specs (e.g., for team ownership reasons), the Consolidation Check SHALL document this decision with rationale.
- **Constitution changes between task generation and apply:** If the constitution's standard tasks are updated after tasks.md was generated, the already-generated tasks.md retains its original content. The user can regenerate tasks if needed.
- **Empty standard tasks section in constitution:** If the constitution contains `## Standard Tasks` but no checkbox items, only the universal template steps appear (no extras appended).
- **Custom section numbering:** If the QA Loop is not section 3 (e.g., due to merged sections), the standard tasks section SHALL use the next available number.
- **Project without constitution:** Universal template steps still appear; constitution extras are simply absent.
- **Branch already exists:** The agent SHALL reuse the existing branch rather than failing.
- **Network failure during PR creation:** The pipeline SHALL NOT be blocked.
- **Auto-continue transitions:** The `post_artifact` hook runs after each artifact individually.
- **Worktree config with invalid path_pattern**: If `path_pattern` does not contain `{change}`, the system SHALL report an error during `/opsx:new`.
- **Worktree config with empty path_pattern**: SHALL default to `.claude/worktrees/{change}`.

## Assumptions

- The `gh` CLI, when available, is authenticated and has permission to create PRs. <!-- ASSUMPTION: gh CLI authentication -->
- Artifact completion is determined by file existence and non-empty content. <!-- ASSUMPTION: File-existence-based completion -->
- Agent compliance with instruction-based guidance is sufficient for consolidation enforcement. <!-- ASSUMPTION: Agent compliance sufficient -->
- The WORKFLOW.md context field reliably enforces constitution loading. <!-- ASSUMPTION: Context-based constitution loading -->
No further assumptions beyond those marked above.
