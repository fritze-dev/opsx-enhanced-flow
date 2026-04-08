---
order: 8
category: development
---
## Purpose

Provides `/opsx:preflight` for pre-implementation quality checks across six dimensions, and `/opsx:verify` for post-implementation verification of completeness, correctness, and coherence.

## Requirements

### Requirement: Preflight Quality Check

The system SHALL run a mandatory quality review before task creation when the user invokes `/opsx:preflight`. The preflight check SHALL cover six dimensions: (A) Traceability Matrix -- mapping each capability listed in the proposal to its corresponding spec at `openspec/specs/<capability>/spec.md` and verifying that the spec has been updated to reflect the proposed changes, (B) Gap Analysis -- identifying missing edge cases, error handling, and empty states, (C) Side-Effect Analysis -- assessing impact on existing systems and regression risks, (D) Constitution Check -- verifying consistency with project rules in constitution.md, (E) Duplication and Consistency -- detecting overlaps and contradictions across specs, and (F) Marker Audit -- auditing all assumption and review markers from spec.md and design.md. The Marker Audit SHALL:
1. Collect all `<!-- ASSUMPTION: ... -->` tags and verify each has an accompanying visible list item. Assumptions written entirely inside HTML comments (no visible text) SHALL be flagged as format violations.
2. Rate each valid assumption as Acceptable Risk, Needs Clarification, or Blocking.
3. Scan for any remaining `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers. Any REVIEW marker found SHALL be rated as Blocking, because REVIEW markers must be resolved before implementation.

The system SHALL produce a `preflight.md` artifact containing findings and a verdict of PASS, PASS WITH WARNINGS, or BLOCKED. The system SHALL NOT auto-fix issues; it SHALL report findings for the user to resolve. The system SHALL NOT proceed to task creation if blockers are found. If the verdict is PASS WITH WARNINGS, the system SHALL pause and require explicit user acknowledgment of the warnings before proceeding to task creation. The system SHALL NOT auto-accept warnings or continue without the user reviewing each warning.

- All change artifacts (specs, design) are available and up to date when preflight is invoked. <!-- ASSUMPTION: Artifact availability -->

**User Story:** As a developer I want a thorough quality review of my specs and design before tasks are created, so that implementation is based on complete, consistent, and well-traced requirements with no unresolved markers.

#### Scenario: Preflight passes with no issues

- **GIVEN** a change named "add-user-auth" with complete specs and design artifacts
- **AND** all requirements have scenarios, no gaps are detected, all assumptions have visible text, and no REVIEW markers remain
- **WHEN** the user invokes `/opsx:preflight add-user-auth`
- **THEN** the system reads constitution.md, all change artifacts, and existing specs
- **AND** produces `preflight.md` covering all six dimensions
- **AND** the verdict is "PASS"
- **AND** the summary shows 0 blockers, 0 warnings

#### Scenario: Preflight finds invisible assumption

- **GIVEN** a change with a spec containing `<!-- ASSUMPTION: External API rate limit is 1000/min -->` with no visible list item
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the Marker Audit flags the invisible assumption as a format violation
- **AND** the verdict is "BLOCKED"
- **AND** the system recommends adding visible text: `- External API rate limit is 1000/min. <!-- ASSUMPTION: API rate limit -->`

#### Scenario: Preflight finds unresolved REVIEW marker

- **GIVEN** a change where design.md contains `<!-- REVIEW: confirm caching strategy -->`
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the Marker Audit flags the REVIEW marker as Blocking
- **AND** the verdict is "BLOCKED"
- **AND** the system informs the user that REVIEW markers must be resolved before proceeding

#### Scenario: Preflight detects contradiction with constitution

- **GIVEN** a design.md that proposes adding a project-level package.json
- **AND** the constitution states "Package manager: npm (global installs only -- no project-level package.json)"
- **WHEN** the system runs the Constitution Check
- **THEN** the system flags a contradiction between design.md and the constitution
- **AND** classifies it as a blocker
- **AND** recommends either updating the design to comply or updating the constitution if the rule should change

#### Scenario: Preflight with warnings requires user acknowledgment

- **GIVEN** a change where all requirements have scenarios, all assumptions have visible text, and no REVIEW markers remain
- **BUT** a minor gap is detected (missing error handling for an unlikely edge case)
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the verdict is "PASS WITH WARNINGS"
- **AND** each warning is listed with a recommendation
- **AND** the system SHALL pause and ask the user to acknowledge each warning
- **AND** the system SHALL NOT proceed to task creation until the user explicitly confirms

#### Scenario: Required artifacts missing

- **GIVEN** a change where specs exist but design.md has not been created
- **WHEN** the user invokes `/opsx:preflight`
- **THEN** the system SHALL abort the preflight
- **AND** SHALL report which required artifacts are missing
- **AND** SHALL suggest running `/opsx:continue` or `/opsx:ff` to generate them

### Requirement: Post-Implementation Verification

The system SHALL verify the implementation against change artifacts when the user invokes `/opsx:verify`. Verification SHALL assess three dimensions: Completeness (task completion and spec coverage), Correctness (requirement implementation accuracy and scenario coverage), and Coherence (design adherence and code pattern consistency). The system SHALL read specs at `openspec/specs/<capability>/spec.md` for the capabilities listed in the change's proposal to verify implementation against. Each issue found SHALL be classified as CRITICAL (must fix before proceeding), WARNING (should fix), or SUGGESTION (nice to fix). The system SHALL produce a verification report with a summary scorecard, issues grouped by priority, and specific actionable recommendations with file and line references where applicable. The system SHALL err on the side of lower severity when uncertain (SUGGESTION over WARNING, WARNING over CRITICAL).

When a WARNING is **mechanically fixable** — i.e., it involves stale cross-references between artifacts, inconsistent naming, or outdated text that can be corrected by simple text replacement without judgment — the system SHALL auto-fix the issue inline before presenting the report. Auto-fixed issues SHALL still appear in the report as resolved WARNINGs with a note indicating the fix applied. WARNINGs that require user judgment (e.g., spec/design divergence where the user must choose which is correct) SHALL NOT be auto-fixed and SHALL be presented as open issues for user resolution.

The system SHALL additionally read `preflight.md` and cross-check each side-effect identified in Section C (Side-Effect Analysis) against `tasks.md` entries and codebase implementation evidence. For each side-effect, the system SHALL search for a corresponding task in `tasks.md` (keyword match) or implementation evidence in the codebase (keyword heuristic). If a side-effect has neither a matching task nor detectable implementation evidence, the system SHALL report a WARNING issue with an actionable recommendation. If Section C contains no side-effects (e.g., all risks assessed as NONE), the system SHALL skip the cross-check and note it in the report.

The `/opsx:verify` command SHALL serve as both the initial verification (tasks.md step 3.2) and the final verification (step 3.5) in the QA loop. When invoked as a final verify after the fix loop, the command SHALL operate identically — checking completeness, correctness, and coherence against the current state of code and artifacts. No special flags or modes are needed; the verify skill is stateless and always checks the current state.

**User Story:** As a developer I want post-implementation verification that checks my code against the specs, so that I can catch gaps, divergences, and inconsistencies before proceeding.

#### Scenario: Verification with all checks passing

- **GIVEN** a change "add-user-auth" with all tasks complete
- **AND** all spec requirements are implemented and all design decisions are followed
- **WHEN** the user invokes `/opsx:verify add-user-auth`
- **THEN** the system produces a verification report
- **AND** the Completeness dimension shows all tasks and requirements covered
- **AND** the Correctness dimension shows all scenarios satisfied
- **AND** the Coherence dimension shows design adherence
- **AND** the final assessment is "All checks passed. Ready to proceed."

#### Scenario: Verification finds critical issues

- **GIVEN** a change with 5 of 7 tasks marked complete
- **AND** one spec requirement has no corresponding implementation in the codebase
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the report lists 2 CRITICAL issues: incomplete tasks and missing requirement implementation
- **AND** each issue includes a specific recommendation (e.g., "Complete task: Add rate limiting middleware" and "Implement requirement: Session Timeout -- no session timeout logic found in auth module")
- **AND** the final assessment states "2 critical issue(s) found. Fix before proceeding."

#### Scenario: Verification finds implementation diverging from spec

- **GIVEN** a spec requiring JWT-based authentication
- **AND** the implementation uses session cookies instead
- **WHEN** the system checks correctness
- **THEN** the report includes a WARNING: "Implementation may diverge from spec: auth uses session cookies, spec requires JWT"
- **AND** recommends "Review src/auth/handler.ts:45 against requirement: JWT Authentication"

#### Scenario: Verify auto-fixes stale artifact cross-reference

- **GIVEN** a change where `proposal.md` references an artifact filename that was renamed during the specs stage
- **AND** the stale reference is a simple text replacement (old filename → new filename)
- **WHEN** the system runs `/opsx:verify`
- **THEN** the system SHALL auto-fix the stale reference in `proposal.md`
- **AND** the verification report SHALL list the fix as "WARNING (auto-fixed): Updated stale reference in proposal.md"
- **AND** the report SHALL NOT present it as an open issue requiring user action

#### Scenario: Verify does not auto-fix judgment-requiring divergence

- **GIVEN** a spec requiring JWT authentication
- **AND** the implementation uses session cookies instead
- **WHEN** the system runs `/opsx:verify`
- **THEN** the system SHALL NOT auto-fix the divergence
- **AND** SHALL present it as an open WARNING for the user to decide whether to update the spec or the code

#### Scenario: Verification finds code pattern inconsistency

- **GIVEN** the project uses kebab-case file naming throughout
- **AND** a new file is named `userAuth.ts` (camelCase)
- **WHEN** the system checks coherence
- **THEN** the report includes a SUGGESTION: "Code pattern deviation: file userAuth.ts uses camelCase, project convention is kebab-case"
- **AND** recommends "Consider renaming to user-auth.ts to follow project pattern"

#### Scenario: Graceful degradation with missing artifacts

- **GIVEN** a change with only tasks.md (no specs or design)
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the system verifies task completion only
- **AND** skips spec coverage and design adherence checks
- **AND** notes in the report which checks were skipped and why

#### Scenario: Verification with no spec changes

- **GIVEN** a change that has tasks but the proposal lists no capability modifications
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the system skips requirement-level verification
- **AND** focuses on task completion and code pattern coherence

#### Scenario: Final verify confirms fix loop resolved all issues

- **GIVEN** a change where the initial verify found 2 CRITICAL issues
- **AND** the developer fixed both issues in the fix loop
- **WHEN** the developer runs `/opsx:verify` as the final verification step (3.5)
- **THEN** the verification report SHALL show 0 CRITICAL issues
- **AND** the report SHALL reflect the current state of all artifacts (including any specs updated during the fix loop)
- **AND** the final assessment SHALL be "All checks passed. Ready to proceed." or note remaining warnings

#### Scenario: Side-effect from preflight not addressed

- **GIVEN** a change where preflight Section C identifies "Regression to existing auth middleware" as a side-effect
- **AND** no task in tasks.md addresses auth middleware regression
- **AND** no codebase evidence of auth middleware changes
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the report includes a WARNING: "Preflight side-effect not addressed: Regression to existing auth middleware"
- **AND** recommends "Add a task or verify that this side-effect is handled in the implementation"

#### Scenario: Side-effect addressed in code but not as task

- **GIVEN** a change where preflight Section C identifies "Schema migration needed for user table"
- **AND** no explicit task in tasks.md mentions schema migration
- **BUT** a migration file exists in the codebase matching the keyword "user table"
- **WHEN** the system cross-checks preflight side-effects
- **THEN** the side-effect is marked as addressed (implementation evidence found)
- **AND** no issue is raised for this side-effect

#### Scenario: Preflight Section C has no side-effects

- **GIVEN** a change where preflight Section C shows all risks assessed as NONE
- **WHEN** the user invokes `/opsx:verify`
- **THEN** the system skips the side-effect cross-check
- **AND** notes "No preflight side-effects to verify" in the report

### Requirement: Documentation Drift Verification

The system SHALL verify that generated documentation accurately reflects the current state of specs when the user invokes `/opsx:docs-verify`. The verification SHALL assess three dimensions:

1. **Capability Docs vs Specs** — For each spec in `openspec/specs/*/spec.md`, the system SHALL check that a corresponding capability doc exists in `docs/capabilities/` and that the doc's Purpose section aligns with the spec's Purpose, and that documented features cover the spec's requirements. Missing capability docs SHALL be classified as CRITICAL. Capability docs that omit requirements present in the spec SHALL be classified as WARNING.

2. **ADRs vs Design Decisions** — The system SHALL scan all completed change directories' `design.md` files in `openspec/changes/*/design.md` for Decisions tables and verify that each decision has a corresponding ADR in `docs/decisions/`. Missing ADRs SHALL be classified as WARNING. The system SHALL recognize manual ADRs (prefix `adr-MNNN`) and skip them during the cross-check, since they have no corresponding design.md entry.

3. **README vs Current State** — The system SHALL verify that `docs/README.md` lists all current capabilities from `openspec/specs/` in its capabilities table, that the Key Design Decisions table references existing ADRs, and that the architecture overview is consistent with `openspec/CONSTITUTION.md`. Missing capabilities in the README SHALL be classified as CRITICAL. Stale ADR references (pointing to deleted or renamed ADRs) SHALL be classified as WARNING.

Each issue found SHALL be classified as:
- **CRITICAL** — documentation is missing or fundamentally incorrect (e.g., capability doc missing entirely, README omits a capability)
- **WARNING** — documentation exists but has drifted from specs (e.g., requirement not reflected in capability doc, stale ADR reference)
- **INFO** — minor discrepancy or observation that may be intentional (e.g., manual ADR with no matching design decision, capability doc has extra context beyond spec)

The system SHALL produce a verification report with a summary (total issues by severity), followed by findings grouped by dimension, with file references for each issue. The report SHALL conclude with a verdict: **CLEAN** (0 critical, 0 warnings), **DRIFTED** (warnings but no criticals), or **OUT OF SYNC** (at least one critical). The system SHALL NOT automatically fix any issues; it SHALL recommend running `/opsx:docs` or `/opsx:docs <capability>` to regenerate drifted documentation.

The system SHALL gracefully handle missing documentation directories: if `docs/capabilities/` does not exist, the system SHALL report all capabilities as missing (CRITICAL) rather than erroring. If `docs/decisions/` does not exist, the system SHALL skip the ADR dimension and note it. If `docs/README.md` does not exist, the system SHALL report it as a single CRITICAL issue.

**User Story:** As a developer I want to verify that my generated documentation still matches the current specs, so that I can detect documentation drift before it causes confusion or misinformation.

#### Scenario: All documentation is in sync

- **GIVEN** a project with 5 capabilities, each having a corresponding capability doc in `docs/capabilities/`
- **AND** all completed changes' design decisions have corresponding ADRs in `docs/decisions/`
- **AND** `docs/README.md` lists all 5 capabilities and references valid ADRs
- **WHEN** the user invokes `/opsx:docs-verify`
- **THEN** the system produces a verification report
- **AND** all three dimensions show no issues
- **AND** the verdict is "CLEAN"

#### Scenario: Capability doc missing for a spec

- **GIVEN** a project with specs for "user-auth" and "data-export"
- **AND** `docs/capabilities/` contains only `user-auth.md` (no `data-export.md`)
- **WHEN** the user invokes `/opsx:docs-verify`
- **THEN** the Capability Docs dimension reports a CRITICAL issue: "Missing capability doc for data-export"
- **AND** the recommendation is "Run `/opsx:docs data-export` to generate the missing documentation"
- **AND** the verdict is "OUT OF SYNC"

#### Scenario: Capability doc omits a requirement from spec

- **GIVEN** a spec for "quality-gates" with requirements for Preflight, Verify, and Docs-Verify
- **AND** the capability doc `docs/capabilities/quality-gates.md` only documents Preflight and Verify
- **WHEN** the system checks Capability Docs vs Specs
- **THEN** the report includes a WARNING: "Capability doc for quality-gates missing requirement: Documentation Drift Verification"
- **AND** the verdict is "DRIFTED"

#### Scenario: README missing a capability

- **GIVEN** a project with 6 specs in `openspec/specs/`
- **AND** `docs/README.md` capabilities table lists only 5 of them
- **WHEN** the system checks README vs Current State
- **THEN** the report includes a CRITICAL issue: "README capabilities table missing: <capability-name>"
- **AND** recommends "Run `/opsx:docs` to regenerate the README"

#### Scenario: Stale ADR reference in README

- **GIVEN** a README Key Design Decisions table referencing `adr-005-old-caching.md`
- **AND** the file `docs/decisions/adr-005-old-caching.md` does not exist
- **WHEN** the system checks README vs Current State
- **THEN** the report includes a WARNING: "README references non-existent ADR: adr-005-old-caching.md"

#### Scenario: Documentation directory does not exist

- **GIVEN** a project where `docs/capabilities/` has not been created yet
- **WHEN** the user invokes `/opsx:docs-verify`
- **THEN** the system reports each spec as a CRITICAL missing capability doc
- **AND** does not error or abort
- **AND** recommends "Run `/opsx:docs` to generate initial documentation"

#### Scenario: No design decisions to check

- **GIVEN** a project with no completed changes in `openspec/changes/`
- **WHEN** the user invokes `/opsx:docs-verify`
- **THEN** the system skips the ADR dimension
- **AND** notes "No design decisions to verify against"
- **AND** still checks the other two dimensions

#### Scenario: Manual ADR without design decision is not flagged

- **GIVEN** a manual ADR `docs/decisions/adr-M001-initial-approach.md`
- **AND** no corresponding entry in any completed change's design.md Decisions table
- **WHEN** the system checks ADRs vs Design Decisions
- **THEN** the manual ADR is recognized by its `adr-MNNN` prefix
- **AND** no issue is raised for it

## Edge Cases

- **No change selected**: If no change name is provided and multiple changes exist, the system SHALL prompt the user to select one. For preflight, auto-selection is allowed if only one change exists. For verify, the system SHALL always ask.
- **Preflight on change with no specs**: If the change has no spec files, preflight SHALL abort and report that specs must be created first.
- **Verify on change with no tasks**: If tasks.md does not exist, verify SHALL report the missing artifact and suggest generating it.
- **Concurrent modifications**: If the codebase is modified while verify is running, the report reflects the state at the time of each individual check. The system does not lock files.
- **False positives in keyword search**: Verify uses heuristic search to find implementation evidence. If a requirement keyword matches unrelated code, the system SHALL prefer SUGGESTION severity to avoid false critical issues.
- **Large codebase**: Verification scans may be slow on very large codebases. The system SHALL focus on files referenced in design.md and recently modified files rather than exhaustive codebase search.
- **Side-effect keyword ambiguity**: If a preflight side-effect description is too generic to produce meaningful keyword matches (e.g., "general performance impact"), the system SHALL skip that entry and note it as inconclusive rather than raising a false warning.
- **Spec with no matching doc name**: If a spec directory uses a different naming convention than the capability doc filename, the system SHALL attempt to match by reading the doc's frontmatter `title` or first heading before reporting it as missing.
- **Multiple specs mapping to one doc**: If a documentation restructuring merged multiple specs into one doc, the system SHALL report this as INFO rather than flagging missing docs.
- **Empty capability doc**: If a capability doc exists but has no meaningful content (only frontmatter or a single heading), the system SHALL classify it as WARNING ("Capability doc for <name> appears empty").
- **README with custom sections**: The system SHALL only check the capabilities table and Key Design Decisions table within the README, not custom project-specific sections that may intentionally differ from specs.
- **Concurrent docs regeneration**: If `/opsx:docs` is running concurrently, the verification report reflects the state at the time of each individual check.

## Assumptions

- The OpenSpec CLI provides accurate artifact dependency and status information. <!-- ASSUMPTION: CLI accuracy -->
- Keyword-based code search provides reasonable (not perfect) implementation coverage detection. <!-- ASSUMPTION: Heuristic search -->
- constitution.md is the authoritative source for project rules and is kept up to date. <!-- ASSUMPTION: Constitution authority -->
- The codebase is accessible and searchable for verification of requirement implementation. <!-- ASSUMPTION: Codebase accessibility -->
- Preflight Section C uses a consistent structure (table or list with risk descriptions and assessments) that can be parsed for side-effect extraction. <!-- ASSUMPTION: Section C format -->
- Capability docs in `docs/capabilities/` follow the naming convention `<capability-name>.md` matching the spec directory name in `openspec/specs/`. <!-- ASSUMPTION: Naming convention -->
- The README capabilities table uses a parseable format (Markdown table or structured list) that allows the system to extract capability names. <!-- ASSUMPTION: README format -->
- Completed changes' design.md Decisions tables use a consistent Markdown table format with identifiable column headers. <!-- ASSUMPTION: Design decisions format -->
