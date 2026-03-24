---
order: 2
category: setup
---
## Purpose

Provides `/opsx:bootstrap` for initial codebase scanning, constitution generation, initial change creation with handoff to the standard pipeline, and recovery mode for detecting drift between code and specs.

## Requirements

### Requirement: First-Run Codebase Scan
The `/opsx:bootstrap` command SHALL analyze the entire project codebase on first run. The scan SHALL identify the tech stack, frameworks, languages, file structure, configuration patterns, dependency management approach, and coding conventions. The scan results SHALL be used as input for constitution generation. The bootstrap command SHALL handle projects of any size, skipping binary files and respecting `.gitignore` patterns.

**User Story:** As a developer adopting spec-driven development on an existing project I want bootstrap to understand my codebase automatically, so that the generated constitution reflects my actual project rather than generic defaults.

#### Scenario: First-run scan of an existing project
- **GIVEN** a project with source code, configuration files, and dependencies but no `openspec/constitution.md`
- **WHEN** the user runs `/opsx:bootstrap`
- **THEN** the system SHALL scan the entire codebase and identify the tech stack, languages, frameworks, file structure, and coding conventions

#### Scenario: Large project with binary files
- **GIVEN** a project containing source code, images, compiled binaries, and a `.gitignore` file
- **WHEN** the bootstrap scan runs
- **THEN** the system SHALL skip binary files and files matching `.gitignore` patterns, analyzing only text-based source and configuration files

### Requirement: Constitution Generation
The `/opsx:bootstrap` command SHALL generate a `constitution.md` file based on the observed patterns from the codebase scan. The constitution SHALL include Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions sections populated with project-specific values. The generated constitution SHALL use the format defined in the constitution template with appropriate sections for the detected technology.

**User Story:** As a developer I want the constitution to be auto-generated from my codebase, so that it accurately captures my project's existing patterns rather than requiring me to write it from scratch.

#### Scenario: Constitution generated from scan results
- **GIVEN** the codebase scan has completed and identified TypeScript, React, and Jest as the primary technologies
- **WHEN** the constitution generation phase runs
- **THEN** the system SHALL create `openspec/constitution.md` with Tech Stack listing TypeScript, React, and Jest, along with Architecture Rules, Code Style, Constraints, and Conventions sections reflecting the observed patterns

#### Scenario: Constitution respects existing conventions
- **GIVEN** a project using 4-space indentation, camelCase variables, and conventional commits
- **WHEN** the constitution is generated
- **THEN** the Code Style section SHALL reflect the 4-space indentation and camelCase convention, and the Conventions section SHALL reference the conventional commits format

### Requirement: Initial Change Creation
After generating the constitution, the `/opsx:bootstrap` command SHALL create an initial change workspace using the OpenSpec CLI and hand off to the standard pipeline. The initial change SHALL be named according to the project context (e.g., `initial-spec`). The bootstrap command SHALL then inform the user to continue with `/opsx:continue` or `/opsx:ff` to generate artifacts, followed by `/opsx:apply` for the QA loop, and finally `/opsx:archive` which prompts to sync delta specs into baselines. The bootstrap command SHALL NOT include sync or archive as apply tasks — these are separate workflow steps that follow after apply completes.

**User Story:** As a developer I want bootstrap to create my first change workspace automatically, so that I can immediately start the spec-driven workflow without manual setup.

#### Scenario: Initial change workspace created after constitution
- **GIVEN** the constitution has been generated successfully
- **WHEN** the initial change creation phase runs
- **THEN** the system SHALL create a change workspace via the OpenSpec CLI with an appropriate name and inform the user to run `/opsx:ff` or `/opsx:continue` to generate artifacts

#### Scenario: Handoff to standard pipeline
- **GIVEN** the initial change workspace has been created
- **WHEN** the bootstrap command completes
- **THEN** the system SHALL report the created change name and the full workflow: generate artifacts (`/opsx:ff`), run QA loop (`/opsx:apply`), then archive with sync (`/opsx:archive`)

#### Scenario: Sync is not an apply task
- **GIVEN** the initial change is a documentation-only bootstrap with no code implementation
- **WHEN** tasks.md is generated for the initial change
- **THEN** the tasks SHALL contain only QA loop tasks (success metrics, verify, approval)
- **AND** sync SHALL NOT appear as an apply task because it is handled by the archive step

### Requirement: Recovery Mode
The `/opsx:bootstrap` command SHALL detect when baseline specs already exist in `openspec/specs/`. When existing specs are found, the bootstrap command SHALL enter recovery mode: scanning the current codebase, comparing it against existing specs, and reporting drift findings. Recovery mode SHALL NOT overwrite existing specs or the constitution. Instead, it SHALL produce a drift report listing discrepancies between the codebase and the specs, and suggest corrective actions (e.g., `/opsx:new hotfix-xyz` for small drift or a full re-bootstrap for large drift).

**User Story:** As a maintainer whose codebase has drifted from its specs I want bootstrap to detect and report the drift, so that I can decide how to reconcile without losing existing spec work.

#### Scenario: Recovery mode with minor drift
- **GIVEN** a project with existing baseline specs and a codebase where two functions have been renamed without spec updates
- **WHEN** the user runs `/opsx:bootstrap`
- **THEN** the system SHALL detect the existing specs, enter recovery mode, report the two naming discrepancies, and suggest using `/opsx:new hotfix-xyz` to create a targeted change for the drift

#### Scenario: Recovery mode with major drift
- **GIVEN** a project with existing baseline specs and a codebase where an entire module has been rewritten without spec updates
- **WHEN** the user runs `/opsx:bootstrap`
- **THEN** the system SHALL detect the existing specs, enter recovery mode, report the extensive drift, and suggest a full re-bootstrap after backing up existing specs

#### Scenario: Recovery mode does not overwrite
- **GIVEN** a project with existing baseline specs and constitution
- **WHEN** the user runs `/opsx:bootstrap` and recovery mode activates
- **THEN** the system SHALL NOT modify any existing spec files or the constitution, only producing a read-only drift report

## Edge Cases

- If the project has no source code files (empty repository), bootstrap SHALL generate a minimal constitution with placeholder sections and inform the user to update it manually.
- If the codebase uses multiple languages or conflicting conventions, the constitution SHALL document the primary patterns and note the variations as exceptions.
- If `openspec/constitution.md` exists but `openspec/specs/` is empty, bootstrap SHALL treat this as a partial first-run and skip constitution generation while proceeding to initial change creation.
- If the OpenSpec CLI is not installed when bootstrap is invoked, bootstrap SHALL instruct the user to run `/opsx:setup` first.
- If the project has an extremely deep directory structure, the scan SHALL use reasonable depth limits to avoid performance issues.

## Assumptions

- The bootstrap command can reliably detect tech stack and conventions from static file analysis (file extensions, configuration files, package manifests) without executing any project code. <!-- ASSUMPTION: Static analysis sufficient -->
- Recovery mode's drift detection compares structural and naming patterns rather than performing deep semantic analysis of code behavior. <!-- ASSUMPTION: Structural comparison -->
No further assumptions beyond those marked above.
