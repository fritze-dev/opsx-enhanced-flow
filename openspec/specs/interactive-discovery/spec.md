---
order: 6
category: change-workflow
---
## Purpose

Provides `/opsx:discover` for standalone interactive research with targeted Q&A for complex features, generating only research.md with coverage assessment and clarification questions before pausing for user input.

## Requirements

### Requirement: Standalone Research with Q&A

The system SHALL run an interactive discovery session when the user invokes `/opsx:discover`. Discovery SHALL operate independently from the artifact pipeline -- it generates only the `research.md` artifact and then pauses for user answers. It SHALL NOT generate proposal, specs, design, or any downstream artifacts. The discovery process SHALL: (1) verify that `openspec/WORKFLOW.md` and `openspec/templates/` exist, (2) read the constitution for project rules, (3) read the current change directory and existing specs, (4) check whether existing specs reflect the current codebase and note stale-spec risks, (5) read the research artifact's `instruction` field from the Smart Template and WORKFLOW.md, (6) generate `research.md` with a coverage assessment rating each category as Clear, Partial, or Missing, and (7) generate targeted clarification questions only for Partial or Missing categories, limited to a maximum of 5 questions prioritized by Impact multiplied by Uncertainty. If all categories are Clear, the system SHALL state that and skip questions. After the user provides answers, the system SHALL record decisions with rationale in the Decisions section of research.md and then stop.

**User Story:** As a developer I want a dedicated interactive research phase with targeted questions, so that I can explore complex features thoroughly and ensure all ambiguities are resolved before the artifact pipeline generates specs and design.

#### Scenario: Discovery with questions for partial categories

- **GIVEN** a change named "add-payment-gateway" has been created via `/opsx:new`
- **AND** the constitution and existing specs have been read
- **WHEN** the user invokes `/opsx:discover add-payment-gateway`
- **THEN** the system reads the constitution, change directory, and existing specs
- **AND** generates research.md with findings about the payment gateway domain
- **AND** rates coverage categories (Scope: Clear, Behavior: Partial, Data Model: Missing, UX: Clear, Integration: Partial, Edge Cases: Partial, Constraints: Clear, Terminology: Clear, Non-Functional: Clear)
- **AND** presents 3 targeted questions for Behavior, Data Model, and Integration (the Partial/Missing categories)
- **AND** pauses and waits for the user to answer

#### Scenario: Discovery with all categories clear

- **GIVEN** a change named "fix-typo-in-docs" has been created
- **AND** the change is straightforward with no ambiguity
- **WHEN** the user invokes `/opsx:discover fix-typo-in-docs`
- **THEN** the system generates research.md with all categories rated as Clear
- **AND** states "All categories are Clear. No questions needed."
- **AND** saves research.md and stops
- **AND** suggests running `/opsx:ff` to generate remaining artifacts

#### Scenario: Record decisions after user answers

- **GIVEN** the system has presented 3 questions to the user
- **AND** the user has provided answers to all 3 questions
- **WHEN** the system processes the answers
- **THEN** the system records each decision in the Decisions section of research.md
- **AND** each decision includes: a number, the decision text, the rationale, and alternatives considered
- **AND** research.md is saved
- **AND** the system stops without generating further artifacts

#### Scenario: Maximum 5 questions enforced

- **GIVEN** a complex change where 4 categories are rated Partial and 2 are rated Missing
- **AND** there are potentially 10+ questions across all categories
- **WHEN** the system generates questions
- **THEN** the system presents at most 5 questions
- **AND** questions are prioritized by Impact multiplied by Uncertainty (highest priority first)
- **AND** lower-priority questions are omitted or noted as "covered if time permits"

#### Scenario: Detect stale-spec risk

- **GIVEN** existing specs at `openspec/specs/auth/spec.md` reference a function `validateToken()`
- **AND** the codebase has been modified outside the spec process to rename it to `verifyToken()`
- **WHEN** the system reads context during discovery
- **THEN** research.md notes the stale-spec risk: "Spec auth references validateToken(), but codebase uses verifyToken(). Spec may be outdated."
- **AND** the stale-spec risk is surfaced in the coverage assessment

#### Scenario: No active change exists

- **GIVEN** no active changes exist in `openspec/changes/`
- **WHEN** the user invokes `/opsx:discover`
- **THEN** the system SHALL inform the user that no active change exists
- **AND** SHALL suggest running `/opsx:new` to create a change first
- **AND** SHALL NOT generate any artifacts

#### Scenario: Discovery does not advance past research

- **GIVEN** the user has completed discovery and research.md is saved
- **WHEN** the discovery session ends
- **THEN** no proposal.md, spec files, design.md, or other artifacts SHALL have been created
- **AND** the system suggests running `/opsx:ff` or `/opsx:continue` for remaining artifacts

#### Scenario: Prerequisite check fails

- **GIVEN** the project has not been set up with `/opsx:setup`
- **WHEN** the user invokes `/opsx:discover`
- **THEN** the system checks for `openspec/WORKFLOW.md` and `openspec/templates/`
- **AND** one or both are missing
- **AND** the system tells the user to run `/opsx:setup` first and stops

## Edge Cases

- **User provides partial answers**: If the user answers some questions but not all, the system SHALL record decisions for answered questions and note unanswered questions as "Deferred -- no answer provided." The system SHALL still save research.md.
- **User provides answers that contradict each other**: The system SHALL flag the contradiction and ask for clarification before recording the decision. It SHALL NOT silently accept contradictory inputs.
- **Change has pre-existing research.md**: If research.md already exists from a previous discovery or from `/opsx:continue`, the system SHALL overwrite it with fresh research. The user is warned that existing research will be replaced.
- **No specs exist**: If `openspec/specs/` is empty (as in a bootstrap scenario), the system SHALL proceed without stale-spec analysis and note "No specs to compare against."
- **User invokes discover on a completed change**: If the change has all artifacts complete, the system SHALL still allow discovery to re-run research, since the user may want to revisit decisions. It SHALL warn that re-running research may invalidate downstream artifacts.
- **Ambiguous change selection**: If not in a worktree context and multiple active changes exist, the system SHALL list active changes and ask the user to select one.

## Assumptions

- The user has already created a change workspace via /opsx:new before invoking /opsx:discover. <!-- ASSUMPTION: Change workspace exists -->
No further assumptions beyond those marked above.
