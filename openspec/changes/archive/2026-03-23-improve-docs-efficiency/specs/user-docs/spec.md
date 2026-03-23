## ADDED Requirements

### Requirement: Incremental Capability Documentation Generation
The `/opsx:docs` command SHALL support incremental generation by default. Before generating each capability doc, the agent SHALL determine whether regeneration is needed by comparing archive dates against the doc's `lastUpdated` frontmatter field.

**Change detection logic:** For each capability, the agent SHALL:
1. Read the existing `docs/capabilities/<capability>.md` and extract the `lastUpdated` value from YAML frontmatter. If the file does not exist, the capability needs generation.
2. Glob `openspec/changes/archive/*/specs/<capability>/` to find all archives that touched this capability.
3. Extract the date prefix (`YYYY-MM-DD`) from each matching archive directory name.
4. If ANY archive date is newer than (or equal to) the doc's `lastUpdated`, the capability needs regeneration.
5. If no archive date is newer, skip this capability entirely.

**First run:** When no capability docs exist yet, all capabilities SHALL be generated (equivalent to full generation).

**Single-capability mode:** When the user provides a capability name argument (e.g., `/opsx:docs auth`), the agent SHALL only read archives matching that capability's glob pattern — not archives for other capabilities. The specified capability SHALL always be regenerated regardless of dates.

**Content-aware writes:** After generating a capability doc, the agent SHALL compare the generated content against the existing file content, excluding the `lastUpdated` frontmatter field. If the content is identical, the agent SHALL NOT write the file and SHALL NOT bump the `lastUpdated` timestamp. This prevents false timestamp updates when regeneration produces unchanged output.

**Output summary:** The agent SHALL report which capabilities were regenerated, which were skipped (no newer archives), and which had unchanged content (regenerated but not written).

**User Story:** As a user I want `/opsx:docs` to only regenerate documentation for capabilities that have new archive data, so that unchanged docs are not touched and timestamps remain accurate.

#### Scenario: Capability skipped when no newer archives exist
- **GIVEN** `docs/capabilities/release-workflow.md` exists with `lastUpdated: "2026-03-20"`
- **AND** all archives touching `release-workflow` have date prefixes of `2026-03-04` or earlier
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent skips `release-workflow` and does not read its archives or regenerate its doc

#### Scenario: Capability regenerated when newer archive exists
- **GIVEN** `docs/capabilities/user-docs.md` exists with `lastUpdated: "2026-03-05"`
- **AND** a new archive `2026-03-23-improve-docs-efficiency/specs/user-docs/` exists
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent regenerates `docs/capabilities/user-docs.md`

#### Scenario: First run generates all capabilities
- **GIVEN** no capability doc files exist under `docs/capabilities/`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the agent generates documentation for all capabilities

#### Scenario: Content-aware write prevents false timestamp bump
- **GIVEN** `docs/capabilities/change-workspace.md` exists with `lastUpdated: "2026-03-20"`
- **AND** a newer archive touches `change-workspace` but only changes assumption comments in the spec
- **WHEN** the agent regenerates the capability doc
- **AND** the generated content (excluding `lastUpdated`) is identical to the existing file
- **THEN** the agent does NOT write the file and `lastUpdated` remains `"2026-03-20"`

#### Scenario: Single-capability mode scopes archive reading
- **GIVEN** the developer runs `/opsx:docs release-workflow`
- **WHEN** the agent looks up archive enrichment
- **THEN** the agent only reads archives matching `openspec/changes/archive/*/specs/release-workflow/`
- **AND** the agent does NOT read archives for other capabilities

#### Scenario: Output summary shows skipped and unchanged capabilities
- **GIVEN** 18 capabilities exist, 2 have newer archives, and 1 of those produces identical content
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the output shows 1 capability regenerated, 1 skipped (unchanged content), and 16 skipped (no newer archives)

## MODIFIED Requirements

### Requirement: Generate Enriched Capability Documentation
The `/opsx:docs` command SHALL generate user-facing documentation from the merged baseline specs located in `openspec/specs/<capability>/spec.md`. The command SHALL produce one documentation file per capability, placed under `docs/capabilities/<capability>.md`. The agent SHALL read the capability doc template at `openspec/schemas/opsx-enhanced/templates/docs/capability.md` for the expected output format. Generated documentation SHALL use clear, user-facing language that explains what the capability does, how to use it, and what behavior to expect. Documentation SHALL NOT include implementation details, internal architecture references, or normative specification language (SHALL/MUST). The agent SHALL transform requirement descriptions into natural explanations, convert Gherkin scenarios into readable usage examples or behavioral descriptions, and organize content with appropriate headings. If a User Story is present in the spec, the agent SHALL use it to inform the documentation's framing and context. The `docs/capabilities/` directory SHALL be created if it does not exist.

Additionally, when generating a capability doc, the agent SHALL look up `openspec/changes/archive/*/specs/<capability>/` to find archived changes that touched that capability. For each relevant archive found, the agent SHALL read `proposal.md`, `research.md`, `design.md`, and `preflight.md` (where they exist) and enrich the capability doc with:
- A "Purpose" section (max 3 sentences) describing what the capability does and why it matters. ALWAYS derive from the spec's `## Purpose` section using problem-framing: frame as what goes wrong WITHOUT this capability, consider the User Stories ("so that...") for motivation. Archive proposals provide context for Rationale, NOT for Purpose. The agent SHALL NOT use proposal "Why" sections as the Purpose — they describe change motivation, not capability purpose. The agent SHALL NOT restate the spec Purpose section verbatim.
- A "Rationale" section (max 3-5 sentences) summarizing design context: key decisions, alternatives explored, why this approach was chosen. For enriched capabilities: derived from `research.md` and `design.md`. For initial-spec-only: derived from spec requirements, scenarios, and assumptions — explain WHY the design works this way (e.g., why kebab-case naming, why date-prefix sorting, why certain constraints exist). Only omit Rationale if truly no design reasoning is derivable from the spec itself. The Rationale SHALL describe the current design in present tense. The agent SHALL NOT narrate change history (e.g., "was later added", "initially... then...", "a subsequent change introduced..."). Every Rationale sentence SHALL answer "why does it work this way?" not "how did it get this way?".
- A "Known Limitations" section (max 5 bullets) derived from `design.md` Non-Goals that describe current technical constraints (rewritten as "Does not support X"), `design.md` Risks (user-relevant risks), and `preflight.md` Assumption Audit (assumptions rated "Acceptable Risk" that affect users). Omit this section entirely if empty.
- A "Future Enhancements" section (max 5 bullets) derived from `design.md` Non-Goals that are explicitly deferred or represent natural extensions of the capability. Items marked "(deferred)" or "(separate feature)" SHALL be included. Sensible out-of-scope items that would genuinely improve the capability MAY be included. Change-level scope boundaries (e.g., "No changes to other skills") SHALL NOT be included. Link to GitHub Issues where they exist. Omit this section entirely if no actionable future ideas.

**Section completeness:** The agent SHALL include ALL sections from the capability doc template when source data exists for that section. The agent SHALL only omit a section when no source data is available (e.g., no Non-Goals in any archive → omit Known Limitations; no deferred items → omit Future Enhancements). Per-section maximum limits (Purpose max 3 sentences, Known Limitations max 5 bullets, etc.) are sufficient conciseness guards. The agent SHALL NOT treat any enriched section as optional when source data exists.

The enriched sections SHALL appear in this order: Overview, Purpose, Rationale, Features, Behavior, Known Limitations, Future Enhancements, Edge Cases.

**Behavior depth:** Each distinct Gherkin scenario group in the spec SHALL produce at least one Behavior subsection. The agent SHALL NOT merge multiple distinct scenarios into fewer subsections than the spec defines.

For capabilities that involve multiple commands or phases (e.g., quality-gates covers both `/opsx:preflight` and `/opsx:verify`), the agent SHALL add a brief workflow sequence note at the top of the Behavior section explaining when each command is used relative to the overall workflow. For multi-command capabilities, the agent SHALL include the command name in behavior subsection headers for quick scanning (e.g., `### Step-by-Step Generation (/opsx:continue)` rather than just `### Step-by-Step Generation`).

The Edge Cases section SHALL only include surprising states, error conditions, or non-obvious interactions. Normal flow variants and expected UX behaviors SHALL be placed in the Behavior section instead. A good test: if a user would not be surprised by the behavior, it belongs in Behavior, not Edge Cases.

If no archived changes exist for a capability, the agent SHALL fall back to generating a spec-only doc (no enriched sections except Rationale where initial-spec research data is available).

**Step independence:** Each documentation generation step SHALL read its own source materials independently. The agent SHALL NOT assume that data loaded during an earlier step (e.g., archive enrichment in Step 2) is still available in later steps — steps may execute in separate contexts.

**Incremental generation:** The agent SHALL only regenerate capability docs that need updating, as determined by the "Incremental Capability Documentation Generation" requirement. Capabilities with no newer archives SHALL be skipped entirely — no archive reading, no generation, no file writes. The "read before write" guardrail still applies for capabilities that ARE regenerated.

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
- **THEN** the generated `docs/capabilities/release-workflow.md` includes a "Purpose" section derived from the spec Purpose, and a "Known Limitations" section derived from design Non-Goals and preflight assumptions

#### Scenario: Capability with no archive data falls back to spec-only
- **GIVEN** a baseline spec exists at `openspec/specs/new-feature/spec.md`
- **AND** no archived change directory contains `specs/new-feature/`
- **WHEN** the developer runs `/opsx:docs`
- **THEN** the generated doc contains Overview, Features, Behavior, and Edge Cases sections only — no enriched sections

#### Scenario: Capability Purpose uses problem-framing
- **GIVEN** a capability being documented
- **WHEN** the agent generates the "Purpose" section
- **THEN** the agent derives it from the spec's `## Purpose` section using problem-framing (what goes wrong without this capability), not from archive proposal "Why" sections and not by restating the Purpose verbatim

#### Scenario: Initial-spec-only capability gets Rationale from spec
- **GIVEN** a capability whose only archive is `initial-spec`
- **AND** the spec contains requirements with design reasoning (e.g., kebab-case naming conventions, date-prefix sorting, specific constraints)
- **WHEN** the agent generates documentation
- **THEN** the doc includes a "Rationale" section explaining why the design works this way, derived from spec requirements and scenarios

#### Scenario: Rationale uses present tense without change history
- **GIVEN** a capability with archive data spanning multiple changes
- **WHEN** the agent generates the "Rationale" section
- **THEN** the Rationale describes the current design in present tense (e.g., "X handles the common case. Y covers edge cases where Z occurs.") and does NOT narrate change history (e.g., "The initial design used X. A later change added Y.")

#### Scenario: Multi-command capability includes workflow sequence note
- **GIVEN** a capability that spans multiple commands (e.g., quality-gates covers `/opsx:preflight` and `/opsx:verify`)
- **WHEN** the agent generates the Behavior section
- **THEN** the top of the Behavior section includes a brief workflow sequence note explaining when each command is used

#### Scenario: Multi-command behavior headers include command names
- **GIVEN** a capability that spans multiple commands (e.g., artifact-generation covers `/opsx:continue` and `/opsx:ff`)
- **WHEN** the agent generates behavior subsection headers
- **THEN** each subsection header includes the command name for quick scanning (e.g., `### Step-by-Step Generation (/opsx:continue)`)

#### Scenario: Edge cases contain only surprising behavior
- **GIVEN** a spec with edge cases including "If multiple active changes exist, the system lists them and asks you to select one"
- **WHEN** the agent generates the Edge Cases section
- **THEN** that item is placed in the Behavior section instead, because prompting for selection is normal UX, not a surprising state

#### Scenario: Conciseness guards enforced
- **GIVEN** a capability with extensive archive data across multiple changes
- **WHEN** the agent generates the enriched doc
- **THEN** "Purpose" contains at most 3 sentences, "Rationale" at most 3-5 sentences, and "Known Limitations" at most 5 bullets

#### Scenario: Agent reads capability template
- **GIVEN** a doc template exists at `openspec/schemas/opsx-enhanced/templates/docs/capability.md`
- **WHEN** the agent generates a capability doc
- **THEN** the agent reads the template and uses it as the structural format for the output

#### Scenario: All sections included when source data exists
- **GIVEN** a capability with archived changes containing `design.md` with Non-Goals items
- **WHEN** the agent generates the enriched doc from scratch (no existing doc)
- **THEN** the doc includes a "Known Limitations" section derived from the Non-Goals
- **AND** the agent does NOT omit the section based on space or priority considerations

#### Scenario: Behavior subsections match scenario groups
- **GIVEN** a baseline spec with 5 distinct Gherkin scenario groups
- **WHEN** the agent generates the Behavior section
- **THEN** the Behavior section contains at least 5 subsections — one per scenario group
- **AND** the agent does NOT merge distinct scenarios into fewer subsections

## Edge Cases

- **Archive date equals lastUpdated**: The agent SHALL regenerate the capability doc (use >= comparison, not strictly >). This handles same-day re-archiving.
- **Capability doc exists but has no lastUpdated field**: The agent SHALL treat it as needing regeneration.
- **Capability doc exists but has malformed lastUpdated**: The agent SHALL treat it as needing regeneration.
- **All capabilities skipped (no changes)**: The agent SHALL report "All capability docs are up-to-date — no changes detected" and proceed to ADR/README steps.

## Assumptions

- Archive directory date prefixes accurately reflect when the archive was created. <!-- ASSUMPTION: Archive naming enforced by archive skill -->
- The `lastUpdated` frontmatter field in capability docs is only written by `/opsx:docs`, not manually edited. <!-- ASSUMPTION: Users follow workflow conventions -->
