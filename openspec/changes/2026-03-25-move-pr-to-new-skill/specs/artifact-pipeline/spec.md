## MODIFIED Requirements

### Requirement: Post-Artifact Commit and PR Integration
The schema SHALL define a top-level `post_artifact` field containing instructions that the `/opsx:continue` and `/opsx:ff` skills execute after creating each artifact. The `post_artifact` instruction SHALL direct the agent to: (1) check if a feature branch for the change exists — if not, create one via `git checkout -b <change-name>`, (2) stage and commit the change artifacts with a WIP commit message including the artifact ID, (3) push the branch to the remote, and (4) on the first push only, create a draft PR via `gh pr create --draft` with a minimal WIP body. Subsequent artifact commits SHALL push to the existing branch without creating a new PR.

The proposal artifact instruction SHALL NOT create a branch or PR. The proposal template SHALL NOT include a `## Pull Request` section — PR metadata is available on-demand via `gh pr view` from the current branch.

If the `post_artifact` field is absent from the schema (backward compatibility), the skill SHALL skip post-artifact operations silently.

**User Story:** As a developer I want every artifact committed incrementally with a draft PR created on the first commit, so that my team has early visibility and every pipeline stage is tracked in version control.

#### Scenario: First artifact triggers branch and PR creation
- **GIVEN** a change workspace where no feature branch exists yet
- **AND** the `gh` CLI is installed and authenticated
- **WHEN** the agent finishes creating the first artifact (e.g., research.md)
- **THEN** the agent SHALL create a feature branch named after the change
- **AND** SHALL commit the artifact with message "WIP: <change-name> — research"
- **AND** SHALL push the branch to the remote
- **AND** SHALL create a draft PR with a minimal WIP body

#### Scenario: Subsequent artifacts commit and push only
- **GIVEN** a change workspace with an existing feature branch and draft PR
- **WHEN** the agent finishes creating a subsequent artifact (e.g., proposal.md)
- **THEN** the agent SHALL commit the artifact with message "WIP: <change-name> — proposal"
- **AND** SHALL push to the existing branch
- **AND** SHALL NOT create a new PR

#### Scenario: Graceful degradation without gh CLI
- **GIVEN** the `gh` CLI is not installed or not authenticated
- **WHEN** the agent finishes creating the first artifact
- **THEN** the agent SHALL create the feature branch and commit
- **AND** SHALL attempt to push
- **AND** SHALL skip draft PR creation
- **AND** SHALL NOT block the pipeline

#### Scenario: Schema without post_artifact field
- **GIVEN** a schema.yaml that does not contain a `post_artifact` field
- **WHEN** the agent finishes creating an artifact
- **THEN** the agent SHALL skip post-artifact commit/push operations
- **AND** SHALL proceed normally

#### Scenario: Proposal template does not include Pull Request section
- **GIVEN** the proposal template at `openspec/schemas/opsx-enhanced/templates/proposal.md`
- **WHEN** the template is inspected
- **THEN** it SHALL NOT contain a `## Pull Request` section

## REMOVED Requirements

### Requirement: Proposal PR Integration
**Reason**: Replaced by "Post-Artifact Commit and PR Integration" — PR creation moved from proposal artifact instruction to schema-level `post_artifact` hook executed after every artifact. This avoids orphaned PRs from unapproved proposals and ensures incremental commits for all artifacts.
**Migration**: PR creation is now triggered on the first artifact commit via `post_artifact`. Existing changes without a branch are unaffected — the `post_artifact` hook creates the branch on the next artifact commit. Use `gh pr view` to check PR status from any branch.

## Edge Cases

- **Existing changes created before this update**: Changes without a feature branch will have the branch created on the next artifact commit via `post_artifact`. No retroactive PR creation for already-completed artifacts.
- **Branch name conflicts**: If a branch with the change name exists from a non-opsx context, the agent reuses it. The user should be warned if the branch has unexpected commits.
- **No remote configured**: If no git remote is configured, the agent skips push and PR creation and continues with local-only commits.
- **Push failure**: If push fails (network issue, permission denied), the agent continues with local commits only and notes the failure.
- **Auto-continue transitions**: When auto-continuing (e.g., research→proposal), the `post_artifact` hook runs after each artifact individually, resulting in separate commits per artifact.

## Assumptions

- The `gh` CLI, when available, is authenticated and has permission to create PRs on the current repository. <!-- ASSUMPTION: gh CLI authentication -->
- The change name (kebab-case) is a valid git branch name. <!-- ASSUMPTION: Branch name validity -->
No further assumptions beyond those marked above.
