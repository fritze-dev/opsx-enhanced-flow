## MODIFIED Requirements

### Requirement: Generate Architecture Decision Records

**References determination:** The agent SHALL determine which specs are relevant to each decision by checking the archive's `specs/` subdirectory to find which capabilities were affected. The agent SHALL link to those baseline specs using semantic link text: `[Spec: capability-name](../../openspec/specs/capability/spec.md)`. The agent SHALL cross-reference other ADRs from the same archive when decisions are related.

**Internal links only:** ADR References SHALL contain only internal relative links: archive backlinks, spec links, and other ADR links. The agent SHALL NOT include external URLs (e.g., GitHub issue links, external documentation URLs) in the References section. Traceability to GitHub issues is provided via the archive backlink — the archive's proposal.md contains the issue references. This eliminates external URL maintenance and prevents stale or incorrect URLs.

**Reference validation:** After generating the References section for each ADR, the agent SHALL validate all links:
1. **Spec links**: For every `[Spec: <name>]` link, glob `openspec/specs/<name>/spec.md` to verify the spec exists. If a linked spec does not exist (e.g., it was renamed or split), the agent SHALL replace the broken link with the correct successor spec(s). If the successor is unknown, the agent SHALL omit the broken link and add a comment `<!-- REVIEW: spec <name> no longer exists -->`.
2. **Archive links**: For every `[Archive: <name>]` link, verify the archive directory exists under `openspec/changes/archive/`. If the archive does not exist, the agent SHALL add a comment `<!-- REVIEW: archive <name> not found -->`.

**Cross-reference heuristic for related ADRs:** Beyond cross-referencing ADRs from the same archive, the agent SHALL check whether the current ADR modifies, extends, or supersedes a system established by an earlier ADR. Specifically:
1. If the current archive's `proposal.md` or `design.md` references another change by name (e.g., "supersedes the full regeneration from doc-ecosystem"), the agent SHALL link to the ADR from that referenced change.
2. If the current archive modifies the same capabilities as an earlier archive's ADR (determined by overlapping `specs/` subdirectories), the agent SHOULD add a cross-reference to the most relevant earlier ADR.
3. The agent SHALL NOT add cross-references speculatively — only when a clear thematic relationship is evident from the archive content.

**User Story:** As a developer or contributor I want formal decision records with internal-only references that are always valid, so that I can navigate between related decisions, specs, and archives without encountering broken links.

#### Scenario: References contain only internal links
- **GIVEN** an archive's design.md references "GitHub Issue #22"
- **WHEN** the agent generates the References section
- **THEN** the References section does NOT include a GitHub URL
- **AND** the archive backlink provides traceability to the issue via the archive's proposal.md

#### Scenario: Spec link validated after generation
- **GIVEN** an ADR references `[Spec: docs-generation](../../openspec/specs/docs-generation/spec.md)`
- **AND** `openspec/specs/docs-generation/spec.md` does not exist
- **WHEN** the agent validates the References section
- **THEN** the agent replaces the broken link with the correct successor specs (e.g., `user-docs`, `architecture-docs`, `decision-docs`)

#### Scenario: Archive link validated after generation
- **GIVEN** an ADR references `[Archive: old-feature](../../openspec/changes/archive/2026-01-01-old-feature/)`
- **AND** the archive directory does not exist
- **WHEN** the agent validates the References section
- **THEN** the agent adds `<!-- REVIEW: archive old-feature not found -->`

#### Scenario: Cross-reference to earlier ADR when system is modified
- **GIVEN** archive `improve-docs-efficiency` modifies the docs system established by archive `doc-ecosystem`
- **AND** ADR-003 was generated from `doc-ecosystem`
- **WHEN** the agent generates ADR-012 from `improve-docs-efficiency`
- **THEN** the References section includes `[ADR-003: Documentation Ecosystem](adr-003-documentation-ecosystem.md)`

#### Scenario: No speculative cross-references
- **GIVEN** two archives both touch the `user-docs` capability but address unrelated concerns
- **WHEN** the agent generates ADRs
- **THEN** the agent does NOT add cross-references between them unless the content explicitly references the other change

## Edge Cases

- **Spec was split into multiple successors**: The agent SHALL replace the single broken link with all successor spec links (e.g., `docs-generation` → `user-docs` + `architecture-docs` + `decision-docs`).
- **No earlier ADR exists for the system being modified**: The agent SHALL skip the cross-reference — not all systems have a founding ADR.
- **Manual ADRs (adr-M*.md)**: Cross-reference heuristics apply to manual ADRs too. If a generated ADR relates to a manual ADR's topic, a cross-reference SHOULD be added.
- **Existing ADRs with external URLs**: When regenerating ADRs that previously contained GitHub issue links, the agent SHALL omit those links. The archive backlink is sufficient for traceability.

## Assumptions

- Spec renames/splits are infrequent and the agent can determine successors from context (e.g., knowing docs-generation became user-docs, architecture-docs, decision-docs). <!-- ASSUMPTION: Major spec restructuring is rare -->
