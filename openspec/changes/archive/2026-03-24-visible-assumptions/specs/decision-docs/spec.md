## MODIFIED Requirements

### Requirement: ADR Generation from Archived Decisions

The `/opsx:docs` command SHALL generate formal Architecture Decision Records (ADRs) from `## Decisions` tables in archived `design.md` files.

Each ADR SHALL include:
- **Status**: "Accepted" with the archive date
- **Context**: From the `design.md` Context section, enriched with `research.md` Approaches and findings from the same archive where available. The Context section SHALL be at least 4-6 sentences. It SHALL include what motivated the decision (the problem being solved), what was investigated or researched, and key constraints or trade-offs that shaped the decision. The agent SHALL NOT write thin Context sections like "we chose X over Y because Z".
- **Decision**: From the Decisions table "Decision" column. Each decision item SHALL include its rationale inline using the em-dash pattern: `**Decision text** — rationale explaining why`. For consolidated ADRs, this is a numbered list of sub-decisions each with inline rationale. For single-decision ADRs, this is a single statement with inline rationale. The Rationale column from the Decisions table SHALL be used as the inline rationale text. There is no separate Rationale section.
- **Alternatives Considered**: From the Decisions table "Alternatives" column, expanded into bullets
- **Consequences**: Split into two subsections:
  - **Positive**: Benefits of this decision, derived from the rationale, context, and positive outcomes
  - **Negative**: Drawbacks, risks, or trade-offs, derived from the `design.md` "Risks & Trade-offs" section filtered to relevance for this specific decision where possible
- **References**: Internal relative links only — no external URLs (GitHub issues, external docs). The first reference SHALL be the source archive backlink (see "ADR Archive Backlinks" requirement). The agent SHALL use descriptive text like `[Spec: three-layer-architecture](path)`, NOT raw file paths as link text like `[../../openspec/specs/three-layer-architecture/spec.md](path)`. Include the relevant spec file and related ADRs if the decision connects to other decisions. The archive backlink provides traceability to GitHub issues via the archive's proposal.md.

**References determination:** The agent SHALL determine which specs are relevant to each decision by checking the archive's `specs/` subdirectory to find which capabilities were affected. The agent SHALL link to those baseline specs using semantic link text: `[Spec: capability-name](../../openspec/specs/capability/spec.md)`. The agent SHALL cross-reference other ADRs from the same archive when decisions are related.

**Reference validation with auto-resolution:** After generating the References section for each ADR, the agent SHALL validate all links and actively resolve broken references:
1. **Spec links**: For every `[Spec: <name>]` link, glob `openspec/specs/<name>/spec.md` to verify the spec exists. If a linked spec does not exist (e.g., it was renamed or split), the agent SHALL attempt to find the successor spec(s) by searching for the capability name in existing specs. If found, replace the broken link with the successor(s). If the successor cannot be determined, the agent SHALL ask the user to identify the correct spec and update the link accordingly. No `<!-- REVIEW -->` markers SHALL be left in the final output.
2. **Archive links**: For every `[Archive: <name>]` link, verify the archive directory exists under `openspec/changes/archive/`. If the archive does not exist, the agent SHALL ask the user whether to remove the link or provide the correct archive name. No `<!-- REVIEW -->` markers SHALL be left in the final output.

**Cross-reference heuristic for related ADRs:** Beyond cross-referencing ADRs from the same archive, the agent SHALL check whether the current ADR modifies, extends, or supersedes a system established by an earlier ADR. Specifically:
1. If the current archive's `proposal.md` or `design.md` references another change by name (e.g., "supersedes the full regeneration from doc-ecosystem"), the agent SHALL link to the ADR from that referenced change.
2. If the current archive modifies the same capabilities as an earlier archive's ADR (determined by overlapping `specs/` subdirectories), the agent SHOULD add a cross-reference to the most relevant earlier ADR.
3. The agent SHALL NOT add cross-references speculatively — only when a clear thematic relationship is evident from the archive content.

The slug SHALL be derived from the Decision column text using this deterministic algorithm:
1. Lowercase the entire string
2. Replace any character that is NOT in `[a-z0-9]` with a hyphen
3. Collapse consecutive hyphens into a single hyphen
4. Trim leading and trailing hyphens
5. Truncate to 50 characters
6. Trim trailing hyphens again (in case truncation split a word)

For consolidated ADRs, the slug SHALL be derived from the overarching decision title (e.g., "Rename init skill to setup" → `rename-init-skill-to-setup`), not from individual sub-decision texts.

**Step independence:** ADR generation SHALL read its own source materials independently. The agent SHALL NOT assume that data loaded during an earlier step (e.g., archive enrichment in Step 2) is still available — steps may execute in separate contexts. This is especially critical for ADR generation, which needs full archive data (design.md, research.md, proposal.md) independently of capability doc generation.

**User Story:** As a developer or contributor I want formal decision records with fully resolved references, so that I never encounter invisible REVIEW markers or broken links in generated ADRs.

#### Scenario: Spec link validated and auto-resolved
- **GIVEN** an ADR references `[Spec: docs-generation](../../openspec/specs/docs-generation/spec.md)`
- **AND** `openspec/specs/docs-generation/spec.md` does not exist
- **WHEN** the agent validates the References section
- **THEN** the agent searches existing specs for successors and replaces the broken link with the correct successor specs (e.g., `user-docs`, `architecture-docs`, `decision-docs`)

#### Scenario: Archive link validated and resolved via user question
- **GIVEN** an ADR references `[Archive: old-feature](../../openspec/changes/archive/2026-01-01-old-feature/)`
- **AND** the archive directory does not exist
- **WHEN** the agent validates the References section
- **THEN** the agent asks the user: "Archive 'old-feature' not found. Should I remove this reference or provide the correct archive name?"
- **AND** the agent applies the user's decision with no `<!-- REVIEW -->` marker left in the output

#### Scenario: No REVIEW markers in generated ADRs
- **GIVEN** a `/opsx:docs` run that generates multiple ADRs
- **WHEN** all ADRs are written to disk
- **THEN** zero `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers exist in any generated ADR file
