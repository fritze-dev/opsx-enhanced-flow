## ADDED Requirements

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

## MODIFIED Requirements

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

## Edge Cases

- **Branch already exists:** If the feature branch already exists (e.g., from a prior attempt), the agent SHALL reuse the existing branch rather than failing.
- **Network failure during PR creation:** If the push succeeds but `gh pr create` fails, the agent SHALL record the branch info and note the PR creation failure. The pipeline SHALL NOT be blocked.
- **No remote configured:** If no git remote is configured, the agent SHALL skip push and PR creation and note it in the Pull Request section.

## Assumptions

- The `gh` CLI, when available, is authenticated and has permission to create PRs on the current repository. <!-- ASSUMPTION: gh CLI authentication -->
- The change name (kebab-case) is a valid git branch name. <!-- ASSUMPTION: Branch name validity -->
No further assumptions beyond those marked above.
