---
order: 15
category: reference
status: stable
version: 1
lastModified: 2026-04-08
---
## Purpose

Tracks planned improvements and future features as GitHub Issues with a `roadmap` label, providing a single always-current view of planned work via the project README.

## Requirements

### Requirement: Roadmap Tracking via GitHub Issues
Concrete improvements and planned features for the project SHALL be tracked as GitHub Issues labeled with `roadmap`. Each roadmap issue SHALL describe a specific, actionable improvement with enough context for a developer to understand the intent and scope. Roadmap issues SHALL be created when the team identifies improvements during development, review, retrospectives, or spec work that are not part of the current change but should be addressed in the future. The project README SHALL contain a Roadmap section that links to the filtered GitHub Issues list (i.e., issues with the `roadmap` label), providing a single, always-current view of planned work. The Roadmap section SHALL NOT duplicate issue content inline -- it SHALL link to the filtered issue view so that the roadmap is always in sync with the actual issue tracker.

**User Story:** As a contributor or user I want to see what improvements are planned for the project, so that I can understand the project's direction, avoid duplicating effort, and contribute to planned work.

#### Scenario: Roadmap issue created for identified improvement
- **GIVEN** a developer identifies a concrete improvement during a spec review (e.g., "Add support for custom spec templates")
- **WHEN** the developer creates a GitHub Issue for the improvement
- **THEN** the issue is labeled with `roadmap`, contains a clear title, a description of the improvement, and enough context to act on it independently

#### Scenario: README contains Roadmap section with link
- **GIVEN** the project README exists
- **WHEN** a user reads the README
- **THEN** they find a "Roadmap" section containing a link to the GitHub Issues filtered by the `roadmap` label (e.g., `https://github.com/<owner>/<repo>/issues?q=label:roadmap`)

#### Scenario: Roadmap link stays current without manual updates
- **GIVEN** the README links to the filtered GitHub Issues view
- **AND** a new roadmap issue is created
- **WHEN** a user clicks the roadmap link in the README
- **THEN** the new issue appears in the filtered list without any README edits being necessary

#### Scenario: Roadmap issues are actionable
- **GIVEN** a roadmap issue titled "Support YAML spec format alongside Markdown"
- **WHEN** a developer reads the issue
- **THEN** the issue contains a description explaining what the feature would do, why it is valuable, and any known constraints -- sufficient to start a `workflow propose` change for it

#### Scenario: Improvement discovered during development tracked
- **GIVEN** a developer working on a current change notices a potential improvement outside the current scope
- **WHEN** they want to capture the idea without derailing their current work
- **THEN** they create a GitHub Issue with the `roadmap` label, capturing the improvement for future prioritization

#### Scenario: Completed roadmap items closed
- **GIVEN** a roadmap issue "Add pre-flight gap analysis for missing scenarios" that has been implemented through the spec-driven workflow
- **WHEN** the change is complete
- **THEN** the corresponding roadmap issue is closed, and it no longer appears in the active roadmap view

## Edge Cases

- **No roadmap issues exist**: The README's Roadmap section links to the filtered issue view, which shows an empty list. This is acceptable -- the link remains valid and will populate as issues are created.
- **Issue created without roadmap label**: An improvement issue is created but the `roadmap` label is forgotten. It will not appear in the filtered roadmap view. The team SHOULD review unlabeled issues periodically to catch missed labels.
- **Roadmap label does not exist in repository**: The first time a roadmap issue is created, the `roadmap` label may need to be created in the GitHub repository. The developer or agent SHALL create the label if it does not exist.
- **Large number of roadmap issues**: If the roadmap grows to many issues, the team MAY use GitHub milestones or project boards for grouping, but the `roadmap` label and README link SHALL remain as the primary entry point.
- **Stale roadmap issues**: Issues that have been open for a long time without activity. The team SHOULD periodically review and close or update stale roadmap issues to keep the roadmap meaningful.
- **Roadmap items that become full changes**: A roadmap issue may grow in scope and require the full spec-driven workflow (`workflow propose`). The issue SHALL be referenced in the change's research or proposal for traceability, and closed when the change is complete.

## Assumptions

- The project is hosted on GitHub and uses GitHub Issues for tracking. <!-- ASSUMPTION: GitHub is the project hosting platform -->
- The `roadmap` label name is a fixed convention and does not need to be configurable. <!-- ASSUMPTION: Single label convention is sufficient for most projects -->
- The README is located at the project root as `README.md`. <!-- ASSUMPTION: Standard README location -->
