## MODIFIED Requirements

### Requirement: Generate Enriched Capability Documentation
The `/opsx:docs` command SHALL generate user-facing documentation from the merged baseline specs located in `openspec/specs/<capability>/spec.md`. The command SHALL produce one documentation file per capability, placed under `docs/capabilities/<capability>.md`. The agent SHALL read the capability doc template at `openspec/schemas/opsx-enhanced/templates/docs/capability.md` for the expected output format. Generated documentation SHALL use clear, user-facing language that explains what the capability does, how to use it, and what behavior to expect. Documentation SHALL NOT include implementation details, internal architecture references, or normative specification language (SHALL/MUST). The agent SHALL transform requirement descriptions into natural explanations, convert Gherkin scenarios into readable usage examples or behavioral descriptions, and organize content with appropriate headings. If a User Story is present in the spec, the agent SHALL use it to inform the documentation's framing and context. The `docs/capabilities/` directory SHALL be created if it does not exist.

Additionally, when generating a capability doc, the agent SHALL look up `openspec/changes/archive/*/specs/<capability>/` to find archived changes that touched that capability. For each relevant archive found, the agent SHALL read `proposal.md`, `research.md`, `design.md`, and `preflight.md` (where they exist) and enrich the capability doc with:
- A "Why This Exists" section (max 3 sentences) derived from the proposal's `## Why` section. When multiple archives exist, use the newest archive's proposal. When the only archive is `initial-spec` (a bootstrap change), the agent SHALL derive context from the spec's `## Purpose` section using problem-framing: frame as what problem the capability solves (not what it is), consider what would happen WITHOUT the capability, and use the spec's User Stories ("so that...") for motivation. The agent SHALL NOT restate the Purpose section verbatim.
- A "Background" section (max 3-5 sentences) summarizing research context from `research.md` — key findings, alternatives explored. Omit this section entirely if the research is trivial or missing.
- A "Design Rationale" section (3-5 sentences) for initial-spec-only capabilities, derived from the initial-spec archive's `research.md` (approaches, decisions) or from the spec's Assumptions section. This section explains why this specific design was chosen. The agent SHALL only generate this section for capabilities whose only archive is `initial-spec`. Enriched capabilities already get this context through Background and Known Limitations.
- A "Known Limitations" section (max 5 bullets) derived from `design.md` Non-Goals (rewritten as "Does not support X"), `design.md` Risks (user-relevant risks), and `preflight.md` Assumption Audit (assumptions rated "Acceptable Risk" that affect users). Omit this section entirely if empty.

The enriched sections SHALL appear in this order: Overview, Why This Exists, Background, Design Rationale, Features, Behavior, Known Limitations, Edge Cases.

For capabilities that involve multiple commands or phases (e.g., quality-gates covers both `/opsx:preflight` and `/opsx:verify`), the agent SHALL add a brief workflow sequence note at the top of the Behavior section explaining when each command is used relative to the overall workflow.

The Edge Cases section SHALL only include surprising states, error conditions, or non-obvious interactions. Normal flow variants and expected UX behaviors SHALL be placed in the Behavior section instead. A good test: if a user would not be surprised by the behavior, it belongs in Behavior, not Edge Cases.

If no archived changes exist for a capability, the agent SHALL fall back to generating a spec-only doc (no enriched sections except Design Rationale where initial-spec research data is available).

**User Story:** As a user of the plugin I want clear documentation for each capability that explains not just what it does but why it exists and what its limitations are, so that I can make informed decisions about using it.

#### Scenario: Documentation generated for single capability
- **GIVEN** a merged baseline spec exists at `openspec/specs/user-auth/spec.md` with two requirements and four scenarios
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent creates `docs/capabilities/user-auth.md` containing a description of the user-auth capability, explanations of each feature, and usage examples derived from the scenarios

#### Scenario: Normative language replaced with user-facing language
- **GIVEN** a baseline spec containing "The system SHALL validate email format before account creation"
- **WHEN** the agent generates documentation for this capability
- **THEN** the documentation reads something like "Email addresses are validated when you create an account" — natural language without SHALL/MUST

#### Scenario: Gherkin scenarios converted to usage examples
- **GIVEN** a spec scenario with GIVEN a user on the dashboard, WHEN they click Export, THEN a CSV downloads
- **WHEN** the agent generates documentation
- **THEN** the documentation includes a section describing the export workflow in natural terms

#### Scenario: Implementation details excluded
- **GIVEN** a spec requirement that mentions internal module names or database schema details
- **WHEN** the agent generates documentation
- **THEN** the documentation omits internal references and focuses only on user-visible behavior

#### Scenario: Enriched doc with archive data
- **GIVEN** a baseline spec exists at `openspec/specs/release-workflow/spec.md`
- **AND** an archived change at `openspec/changes/archive/2026-03-04-release-workflow/` contains `proposal.md` with a Why section, `design.md` with Non-Goals, and `preflight.md` with an Assumption Audit
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the generated `docs/capabilities/release-workflow.md` includes a "Why This Exists" section derived from the proposal, and a "Known Limitations" section derived from design Non-Goals and preflight assumptions

#### Scenario: Capability with no archive data falls back to spec-only
- **GIVEN** a baseline spec exists at `openspec/specs/new-feature/spec.md`
- **AND** no archived change directory contains `specs/new-feature/`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the generated doc contains Overview, Features, Behavior, and Edge Cases sections only — no enriched sections

#### Scenario: Initial-spec-only capability uses problem-framing for Why This Exists
- **GIVEN** a capability whose only relevant archive is `initial-spec` (a bootstrap change)
- **WHEN** the agent generates the "Why This Exists" section
- **THEN** the agent derives context from the spec's `## Purpose` section using problem-framing (what goes wrong without this capability), not by restating the Purpose verbatim

#### Scenario: Initial-spec-only capability gets Design Rationale
- **GIVEN** a capability whose only archive is `initial-spec`
- **AND** the initial-spec archive's `research.md` contains approaches and decisions relevant to this capability
- **WHEN** the agent generates documentation
- **THEN** the doc includes a "Design Rationale" section explaining why this design was chosen, derived from the research data

#### Scenario: Multi-command capability includes workflow sequence note
- **GIVEN** a capability that spans multiple commands (e.g., quality-gates covers `/opsx:preflight` and `/opsx:verify`)
- **WHEN** the agent generates the Behavior section
- **THEN** the top of the Behavior section includes a brief workflow sequence note explaining when each command is used

#### Scenario: Edge cases contain only surprising behavior
- **GIVEN** a spec with edge cases including "If multiple active changes exist, the system lists them and asks you to select one"
- **WHEN** the agent generates the Edge Cases section
- **THEN** that item is placed in the Behavior section instead, because prompting for selection is normal UX, not a surprising state

#### Scenario: Conciseness guards enforced
- **GIVEN** a capability with extensive archive data across multiple changes
- **WHEN** the agent generates the enriched doc
- **THEN** "Why This Exists" contains at most 3 sentences, "Background" at most 3-5 sentences, and "Known Limitations" at most 5 bullets

#### Scenario: Agent reads capability template
- **GIVEN** a doc template exists at `openspec/schemas/opsx-enhanced/templates/docs/capability.md`
- **WHEN** the agent generates a capability doc
- **THEN** the agent reads the template and uses it as the structural format for the output

### Requirement: Generate Documentation Table of Contents
The `/opsx:docs` command SHALL create or update `docs/README.md` as the single entry point for all generated documentation. The README SHALL include the architecture overview content (System Architecture, Tech Stack, Key Design Decisions with ADR links, Conventions) followed by a capabilities section. The capabilities section SHALL be grouped by the `category` frontmatter field from baseline specs, rendered as category group headers (title-case). Within each category group, capabilities SHALL be ordered by the `order` frontmatter field (lower first). The Key Design Decisions table SHALL include an "ADR" column linking directly to the corresponding ADR file instead of a "Source" column. The README SHALL surface notable trade-offs from ADR Consequences for the most significant decisions. The `docs/README.md` SHALL always be regenerated on each run. The agent SHALL read the README template at `openspec/schemas/opsx-enhanced/templates/docs/readme.md` for the expected output format.

The agent SHALL NOT generate a separate `docs/architecture-overview.md` file. The agent SHALL NOT generate a separate `docs/decisions/README.md` file. If either file exists from a previous run, the agent SHALL delete it.

**User Story:** As a user I want a single documentation entry point that gives me the architecture overview, lists all capabilities grouped by workflow phase, and links to ADRs inline, so that I don't have to navigate between multiple index files.

#### Scenario: Consolidated README generated
- **GIVEN** the agent has generated capability docs and ADR files
- **WHEN** the agent updates `docs/README.md`
- **THEN** the README contains System Architecture, Tech Stack, Key Design Decisions (with ADR links), Conventions, and a category-grouped capabilities section — all in one file

#### Scenario: Stale files cleaned up
- **GIVEN** `docs/architecture-overview.md` and `docs/decisions/README.md` exist from a previous run
- **WHEN** the agent generates `docs/README.md`
- **THEN** the agent deletes `docs/architecture-overview.md` and `docs/decisions/README.md`

#### Scenario: Capabilities grouped by category
- **GIVEN** baseline specs with `category` frontmatter values like `setup`, `change-workflow`, `development`
- **WHEN** the agent generates the capabilities section
- **THEN** capabilities appear under category group headers (e.g., "### Setup", "### Change Workflow"), ordered by `order` within each group

#### Scenario: Capabilities without category appear in Other group
- **GIVEN** a baseline spec with no `category` frontmatter
- **WHEN** the agent generates the capabilities section
- **THEN** the capability appears under an "Other" group header

#### Scenario: Design decisions table includes ADR links
- **GIVEN** ADR files have been generated at `docs/decisions/adr-NNN-slug.md`
- **WHEN** the agent generates the Key Design Decisions table
- **THEN** each row includes an ADR link column pointing to the corresponding ADR file

#### Scenario: Notable trade-offs surfaced
- **GIVEN** ADR Consequences sections contain significant negative consequences
- **WHEN** the agent generates the Key Design Decisions section
- **THEN** notable trade-offs are surfaced as brief notes in the table or a subsection

## Edge Cases

- **No baseline specs exist**: If `openspec/specs/` is empty, the agent SHALL inform the user and suggest running `/opsx:sync` first.
- **Spec with no scenarios**: The agent SHALL still generate documentation from requirement descriptions, noting that usage examples are unavailable.
- **Existing documentation files**: The agent SHALL overwrite existing docs with freshly generated content, since specs are the source of truth.
- **Missing archive artifacts**: If an archive lacks `design.md`, `research.md`, or `preflight.md`, the agent SHALL skip enrichment from that artifact without error.
- **Initial-spec research.md too thin**: If the initial-spec archive's research.md lacks useful approaches or decisions for a capability, the agent SHALL omit the Design Rationale section rather than generating empty content.

## Assumptions

- Baseline specs in `openspec/specs/` are the source of truth for documentation generation. <!-- ASSUMPTION: Docs generated after sync -->
- Archived changes follow `YYYY-MM-DD-<feature-name>` naming under `openspec/changes/archive/`. <!-- ASSUMPTION: Archive naming enforced by archive skill -->
- The `initial-spec` archive is a bootstrap change whose proposal "Why" describes spec creation, not individual capability motivations. <!-- ASSUMPTION: Based on observed archive content -->
- Doc templates at `openspec/schemas/opsx-enhanced/templates/docs/` are available in consumer projects after `/opsx:init` copies the schema. <!-- ASSUMPTION: Schema copy includes subdirectories -->
