## MODIFIED Requirements

### Requirement: Generate Enriched Capability Documentation
The `/opsx:docs` command SHALL generate user-facing documentation from the merged baseline specs located in `openspec/specs/<capability>/spec.md`. The command SHALL produce one documentation file per capability, placed under `docs/capabilities/<capability>.md`. The agent SHALL read the capability doc template at `openspec/schemas/opsx-enhanced/templates/docs/capability.md` for the expected output format. Generated documentation SHALL use clear, user-facing language that explains what the capability does, how to use it, and what behavior to expect. Documentation SHALL NOT include implementation details, internal architecture references, or normative specification language (SHALL/MUST). The agent SHALL transform requirement descriptions into natural explanations, convert Gherkin scenarios into readable usage examples or behavioral descriptions, and organize content with appropriate headings. If a User Story is present in the spec, the agent SHALL use it to inform the documentation's framing and context. The `docs/capabilities/` directory SHALL be created if it does not exist.

Additionally, when generating a capability doc, the agent SHALL look up `openspec/changes/archive/*/specs/<capability>/` to find archived changes that touched that capability. For each relevant archive found, the agent SHALL read `proposal.md`, `research.md`, `design.md`, and `preflight.md` (where they exist) and enrich the capability doc with:
- A "Purpose" section (max 3 sentences) describing what the capability does and why it matters. ALWAYS derive from the spec's `## Purpose` section using problem-framing: frame as what goes wrong WITHOUT this capability, consider the User Stories ("so that...") for motivation. Archive proposals provide context for Rationale, NOT for Purpose. The agent SHALL NOT use proposal "Why" sections as the Purpose — they describe change motivation, not capability purpose. The agent SHALL NOT restate the spec Purpose section verbatim.
- A "Rationale" section (max 3-5 sentences) summarizing design context: key decisions, alternatives explored, why this approach was chosen. For enriched capabilities: derived from `research.md` and `design.md`. For initial-spec-only: derived from initial-spec `research.md` or spec Assumptions. Omit this section entirely if no useful design context is available.
- A "Known Limitations" section (max 5 bullets) derived from `design.md` Non-Goals that describe current technical constraints (rewritten as "Does not support X"), `design.md` Risks (user-relevant risks), and `preflight.md` Assumption Audit (assumptions rated "Acceptable Risk" that affect users). Omit this section entirely if empty.
- A "Future Enhancements" section (max 5 bullets) derived from `design.md` Non-Goals that are explicitly deferred or represent natural extensions of the capability. Items marked "(deferred)" or "(separate feature)" SHALL be included. Sensible out-of-scope items that would genuinely improve the capability MAY be included. Change-level scope boundaries (e.g., "No changes to other skills") SHALL NOT be included. Link to GitHub Issues where they exist. Omit this section entirely if no actionable future ideas.

The enriched sections SHALL appear in this order: Overview, Purpose, Rationale, Features, Behavior, Known Limitations, Future Enhancements, Edge Cases.

For capabilities that involve multiple commands or phases (e.g., quality-gates covers both `/opsx:preflight` and `/opsx:verify`), the agent SHALL add a brief workflow sequence note at the top of the Behavior section explaining when each command is used relative to the overall workflow.

The Edge Cases section SHALL only include surprising states, error conditions, or non-obvious interactions. Normal flow variants and expected UX behaviors SHALL be placed in the Behavior section instead. A good test: if a user would not be surprised by the behavior, it belongs in Behavior, not Edge Cases.

If no archived changes exist for a capability, the agent SHALL fall back to generating a spec-only doc (no enriched sections except Rationale where initial-spec research data is available).

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

#### Scenario: Initial-spec-only capability gets Rationale
- **GIVEN** a capability whose only archive is `initial-spec`
- **AND** the initial-spec archive's `research.md` contains approaches and decisions relevant to this capability
- **WHEN** the agent generates documentation
- **THEN** the doc includes a "Rationale" section explaining why this design was chosen, derived from the research data

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
- **THEN** "Purpose" contains at most 3 sentences, "Rationale" at most 3-5 sentences, and "Known Limitations" at most 5 bullets

#### Scenario: Agent reads capability template
- **GIVEN** a doc template exists at `openspec/schemas/opsx-enhanced/templates/docs/capability.md`
- **WHEN** the agent generates a capability doc
- **THEN** the agent reads the template and uses it as the structural format for the output

## Edge Cases

- **Existing documentation files**: The agent SHALL overwrite existing docs with freshly generated content, since specs are the source of truth.
- **Initial-spec research.md too thin**: If the initial-spec archive's research.md lacks useful approaches or decisions for a capability, the agent SHALL omit the Rationale section rather than generating empty content.

## Assumptions

- Doc templates at `openspec/schemas/opsx-enhanced/templates/docs/` are available in consumer projects after `/opsx:init` copies the schema. <!-- ASSUMPTION: Schema copy includes subdirectories -->
