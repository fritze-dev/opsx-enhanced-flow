## ADDED Requirements

### Requirement: Documentation Drift Verification

The system SHALL verify that generated documentation accurately reflects the current state of specs when the user invokes `/opsx:docs-verify`. The verification SHALL assess three dimensions:

1. **Capability Docs vs Specs** — For each spec in `openspec/specs/*/spec.md`, the system SHALL check that a corresponding capability doc exists in `docs/capabilities/` and that the doc's Purpose section aligns with the spec's Purpose, and that documented features cover the spec's requirements. Missing capability docs SHALL be classified as CRITICAL. Capability docs that omit requirements present in the spec SHALL be classified as WARNING.

2. **ADRs vs Design Decisions** — The system SHALL scan all archived `design.md` files in `openspec/changes/archive/*/design.md` for Decisions tables and verify that each decision has a corresponding ADR in `docs/decisions/`. Missing ADRs SHALL be classified as WARNING. The system SHALL recognize manual ADRs (prefix `adr-MNNN`) and skip them during the cross-check, since they have no corresponding design.md entry.

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
- **AND** all archived design decisions have corresponding ADRs in `docs/decisions/`
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

#### Scenario: No archived design decisions to check

- **GIVEN** a project with no archives in `openspec/changes/archive/`
- **WHEN** the user invokes `/opsx:docs-verify`
- **THEN** the system skips the ADR dimension
- **AND** notes "No archived design decisions to verify against"
- **AND** still checks the other two dimensions

#### Scenario: Manual ADR without design decision is not flagged

- **GIVEN** a manual ADR `docs/decisions/adr-M001-initial-approach.md`
- **AND** no corresponding entry in any archived design.md Decisions table
- **WHEN** the system checks ADRs vs Design Decisions
- **THEN** the manual ADR is recognized by its `adr-MNNN` prefix
- **AND** no issue is raised for it

## Edge Cases

- **Spec with no matching doc name**: If a spec directory uses a different naming convention than the capability doc filename, the system SHALL attempt to match by reading the doc's frontmatter `title` or first heading before reporting it as missing.
- **Multiple specs mapping to one doc**: If a documentation restructuring merged multiple specs into one doc, the system SHALL report this as INFO rather than flagging missing docs.
- **Empty capability doc**: If a capability doc exists but has no meaningful content (only frontmatter or a single heading), the system SHALL classify it as WARNING ("Capability doc for <name> appears empty").
- **README with custom sections**: The system SHALL only check the capabilities table and Key Design Decisions table within the README, not custom project-specific sections that may intentionally differ from specs.
- **Concurrent docs regeneration**: If `/opsx:docs` is running concurrently, the verification report reflects the state at the time of each individual check.

## Assumptions

- Capability docs in `docs/capabilities/` follow the naming convention `<capability-name>.md` matching the spec directory name in `openspec/specs/`. <!-- ASSUMPTION: Naming convention -->
- The README capabilities table uses a parseable format (Markdown table or structured list) that allows the system to extract capability names. <!-- ASSUMPTION: README format -->
- Archived design.md Decisions tables use a consistent Markdown table format with identifiable column headers. <!-- ASSUMPTION: Design decisions format -->
