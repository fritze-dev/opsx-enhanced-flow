## MODIFIED Requirements

### Requirement: Smart Templates Own Workflow Rules

Each Smart Template's `instruction` field SHALL contain workflow rules that apply to its artifact type. The tasks template instruction SHALL include the Definition of Done rule (emergent from artifacts). The tasks template instruction SHALL include a standard tasks directive for including universal post-implementation steps and appending constitution-defined project-specific extras. The apply instruction in WORKFLOW.md SHALL include the post-apply workflow sequence and clarify that standard tasks are executed separately after apply completes.

#### Scenario: Apply instruction in WORKFLOW.md includes post-apply workflow

- **GIVEN** `openspec/WORKFLOW.md`
- **WHEN** the `apply.instruction` field is inspected
- **THEN** it SHALL contain the post-apply sequence: `/opsx:verify` → `/opsx:changelog` → `/opsx:docs`
- **AND** SHALL NOT reference `/opsx:sync` or `/opsx:archive`

### Requirement: Standard Tasks Directive in Task Generation

The tasks Smart Template's `instruction` field SHALL include a standard tasks directive. The tasks template SHALL include a section 4 with universal post-implementation steps (changelog, docs, version bump, commit and push) that apply to all opsx-enhanced projects. The `instruction` SHALL additionally instruct the agent to check the project constitution for a `## Standard Tasks` section. If the constitution defines extra standard tasks, the agent SHALL append them to the template's universal steps in the generated `tasks.md`. If no `## Standard Tasks` section exists in the constitution, the agent SHALL include only the universal steps from the template.

**User Story:** As a project maintainer I want universal post-implementation steps automatically in every task list, with the option to add project-specific extras in my constitution, so that all projects get a consistent baseline and each project can extend it.

#### Scenario: Universal standard tasks always included

- **GIVEN** a change progressing through the artifact pipeline
- **AND** the tasks template contains section 4 with universal standard tasks
- **WHEN** the tasks artifact is generated
- **THEN** the generated `tasks.md` SHALL contain a final section titled `## 4. Standard Tasks (Post-Implementation)` (or the next available number)
- **AND** the section SHALL contain the universal steps: changelog, docs, version bump, commit and push
- **AND** SHALL NOT contain an archive step

### Requirement: Specs Overlap Verification

The specs Smart Template's `instruction` field SHALL include an overlap verification step before editing spec files, requiring the agent to read the proposal's Consolidation Check and scan existing specs for overlap.

#### Scenario: Overlap verification is present in specs template instruction

- **GIVEN** the specs Smart Template
- **WHEN** its `instruction` frontmatter field is inspected
- **THEN** it SHALL contain an overlap verification step

#### Scenario: Agent catches overlap during specs creation

- **GIVEN** a proposal that listed `admin-filters` as a new capability, but the baseline `admin-table-view` spec already covers filter behavior
- **WHEN** the agent begins the specs artifact phase and performs overlap verification
- **THEN** the agent SHALL reclassify `admin-filters` as a Modified Capability on `admin-table-view` and update the proposal before editing the spec file

### Requirement: Post-Artifact Commit and PR Integration

WORKFLOW.md SHALL define a `post_artifact` field containing instructions that the `/opsx:ff` skill executes after creating each artifact. The `post_artifact` instruction SHALL direct the agent to: (1) check the current branch, (2) stage and commit the change artifacts AND any modified spec files with a WIP commit message including the artifact ID, (3) push the branch to the remote, and (4) on the first push only, create a draft PR. The staging step SHALL include both `git add openspec/changes/<change-dir>/` and `git add openspec/specs/` to capture direct spec edits made during the specs stage.

**User Story:** As a developer I want every artifact committed incrementally including spec edits, so that my team has early visibility and every pipeline stage is tracked in version control.

#### Scenario: Specs stage commits both artifacts and spec edits

- **GIVEN** a change where the agent just completed the specs stage by editing `openspec/specs/user-auth/spec.md`
- **WHEN** the post-artifact hook runs
- **THEN** the agent stages `openspec/changes/<change-dir>/` AND `openspec/specs/`
- **AND** commits with message "WIP: <change-name> — specs"
- **AND** pushes to remote

## Edge Cases

- **Constitution changes between task generation and apply:** If the constitution's standard tasks are updated after tasks.md was generated, the already-generated tasks.md retains its original content. The user can regenerate tasks if needed.
- **Empty standard tasks section in constitution:** If the constitution contains `## Standard Tasks` but no checkbox items, only the universal template steps appear (no extras appended).
- **Project without constitution:** Universal template steps still appear; constitution extras are simply absent.

## Assumptions

- Artifact completion is determined by file existence and non-empty content. <!-- ASSUMPTION: File-existence-based completion -->
No further assumptions beyond those marked above.
