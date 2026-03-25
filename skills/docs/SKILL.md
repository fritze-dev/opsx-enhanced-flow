---
name: docs
description: Generate or update user-facing documentation from merged specs. Run after /opsx:archive to create capability docs, ADRs, architecture overview, decisions index, and README hub.
disable-model-invocation: false
---

# /opsx:docs — Generate User Documentation

> Run this **after** `/opsx:archive` to generate or update user-facing documentation.

**Input**: Optional argument:
- No argument → incremental update (only regenerate docs for capabilities with newer archives, new ADRs, and README if needed)
- A capability name (e.g., `auth`) → regenerate only that capability's doc (always regenerated regardless of dates, only reads that capability's archives)
- A comma-separated list of capability names (e.g., `artifact-pipeline,artifact-generation`) → regenerate only the listed capabilities (always regenerated regardless of dates, archives only read for listed capabilities). Designed for the post-archive workflow where the caller already knows which capabilities were affected.

## Instructions

### Prerequisite: Verify Setup

Run `openspec schema which opsx-enhanced --json`. If it fails, tell the user to run `/opsx:setup` first and stop.

### Step 0: Determine Documentation Language

Read `openspec/config.yaml` and extract the `docs_language` field.

- **Missing or "English":** Proceed with English output (default behavior, no change).
- **Non-English value (e.g., "German", "French"):** Generate all headings and content in the target language for Steps 3, 4, and 5. Apply these translation rules throughout:
  - YAML frontmatter **keys** remain in English (machine-readable identifiers)
  - YAML frontmatter **values** (`title`, `description`) are translated to the target language
  - Product names (OpenSpec, Claude Code), commands (`/opsx:*`), and file paths remain in English
  - If an existing doc is in a different language than the configured `docs_language`, treat it as a full regeneration rather than an incremental update

### Step 1: Discover Specs and Detect Changes

Glob `openspec/specs/*/spec.md` to find all available capabilities. The directory name is the capability ID.

If a capability name argument was given (single or comma-separated list), handle as follows:

- **Single capability** (e.g., `auth`): Process only that one (error if not found). Always marked for regeneration regardless of dates. Only read archives matching that capability's glob pattern.
- **Comma-separated list** (e.g., `artifact-pipeline,artifact-generation`): Parse the list, trim whitespace from each name, and deduplicate. Validate each name against `openspec/specs/<name>/spec.md` — if a name does not exist, warn and skip it. All valid capabilities are always marked for regeneration regardless of dates. Only read archives for the listed capabilities. Do NOT scan or process unlisted capabilities at all.

**Change detection (no argument mode):** For each discovered capability, determine whether regeneration is needed:

1. Check if `docs/capabilities/<capability>.md` exists. If not → mark for regeneration.
2. If the file exists, read its YAML frontmatter and extract the `lastUpdated` value (format: `YYYY-MM-DD`). If the field is missing or malformed → mark for regeneration.
3. Glob `openspec/changes/archive/*/specs/<capability>/` to find all archives that touched this capability. Extract the date prefix (`YYYY-MM-DD`) from each archive directory name.
4. If ANY archive date is newer than or equal to the doc's `lastUpdated` → mark for regeneration. (Use `>=` comparison to handle same-day re-archiving.)
5. If no archive date is newer → skip this capability entirely.

Build two lists: **capabilities to regenerate** and **capabilities to skip**. Only capabilities marked for regeneration proceed to Steps 2 and 3.

If all capabilities are skipped (no newer archives for any), report: "All capability docs are up-to-date — no changes detected" and proceed to Step 4.

### Step 2: Look Up Archive Enrichment

For each capability **marked for regeneration**, glob `openspec/changes/archive/*/specs/<capability>/` to find archived changes that touched it. Skip capabilities not marked for regeneration — do not read their archives.

For each archive found, read the following files from the archive root directory (skip any that don't exist):
- `proposal.md` — extract the `## Why` section (for Rationale context, NOT for Purpose)
- `research.md` — extract the `## 3. Approaches` section and key findings
- `design.md` — extract `## Non-Goals` (for Known Limitations AND Future Enhancements), `## Risks & Trade-offs`, and `## Decisions` table
- `preflight.md` — extract `## F. Assumption Audit` (assumptions rated "Acceptable Risk" that affect users)

**Multiple archives for one capability:** When multiple archives exist, aggregate research findings, limitations, and future enhancements across all archives.

**Non-Goals classification:** Non-Goals from `design.md` serve two sections:
- **Known Limitations**: Non-Goals that describe current technical constraints or deliberate scope limits (rewrite as "Does not support X")
- **Future Enhancements**: Non-Goals explicitly marked "(deferred)" or "(separate feature)", plus sensible out-of-scope items that are natural extensions of the capability. Do NOT include items that are merely change-level scope boundaries (e.g., "No changes to other skills"). Link to GitHub Issues where they exist.

**CRITICAL — Purpose section source:** The Purpose section ALWAYS describes what the capability does and why it matters — never the motivation for a specific change. Derive Purpose from the spec's `## Purpose` section using problem-framing (what goes wrong without this capability). Archive proposals provide context for the Rationale section, NOT for Purpose. Do not use proposal "Why" sections as the Purpose — they describe why a change was made, not why the capability exists.

**initial-spec fallback:** If a capability's only relevant archive is `initial-spec`, derive Purpose from the spec's `## Purpose` section. Derive Rationale from spec requirements, scenarios, and assumptions — explain WHY the design works this way (e.g., why kebab-case naming, why date-prefix sorting, why certain constraints exist). The initial-spec research.md may also contain useful design context. Only omit Rationale if truly no design reasoning is derivable from the spec itself.

**No archives found:** Skip enrichment — generate a spec-only doc (current behavior).

### Step 3: Generate Enriched Capability Documentation

**Skip unchanged capabilities:** Only generate docs for capabilities marked for regeneration in Step 1. Skip all others entirely — no archive reading, no generation, no file writes.

**Language reminder:** If Step 0 determined a non-English `docs_language`, generate all section headings and content in the target language. YAML frontmatter keys stay English; `title` and `description` values are translated.

Read the capability doc template at `openspec/schemas/opsx-enhanced/templates/docs/capability.md` for the expected output format.

For each capability marked for regeneration, read its baseline spec's YAML frontmatter (if present) to get the `order` and `category` values. Generate the doc content following the template structure.

**Content-aware writes:** After generating each capability doc, compare the generated content against the existing file content, **excluding the `lastUpdated` frontmatter field**. If the content is identical (only `lastUpdated` would differ), do NOT write the file and do NOT bump the `lastUpdated` timestamp. Only write the file and set `lastUpdated` to today's date if the content has actually changed. This prevents false timestamp updates when regeneration produces unchanged output.

**Track writes:** Record whether any capability doc was actually written to disk during this step. This flag is needed for Step 5 (conditional README regeneration).

**YAML Frontmatter Fields** (in the generated capability doc):

| Field | Description |
|-------|-------------|
| `title` | Human-readable capability name |
| `capability` | Machine-readable ID (matches spec directory name) |
| `description` | One-line summary for the table of contents |
| `lastUpdated` | Date of last generation (`YYYY-MM-DD`) |

**Conciseness guards:**
- "Purpose": max 3 sentences
- "Rationale": max 3-5 sentences
- "Known Limitations": max 5 bullets
- "Future Enhancements": max 5 bullets
- Include ALL sections from the template when source data exists. Only omit a section when no source data is available for it.
- Total: still 1-2 pages per capability

#### Mapping Rules

| Spec Element | Doc Element |
|---|---|
| User Story title + motivation | Features bullet |
| Gherkin scenario title | Behavior subsection |
| GIVEN/WHEN/THEN detail | Plain-language example under behavior |
| Edge Cases section | Edge Cases (only surprising states, error conditions, or non-obvious interactions — normal flow variants belong in Behavior) |
| Technical terms (API, DB, etc.) | Replaced with plain-language or omitted |
| Product names (OpenSpec, Claude Code, etc.) | **Preserved as-is** — never abstract product names into generic terms |
| Implementation details (file paths, configs) | Omitted entirely |
| User-facing syntax/markers (`<!-- ASSUMPTION -->`, `[P]`, etc.) | **Included** — if users need to recognize or use a syntax convention, document it. `<!-- REVIEW -->` markers are transient and auto-resolved, so do not document them. |

**Behavior depth:** Each distinct Gherkin scenario group in the spec should produce at least one Behavior subsection. Do not merge multiple distinct scenarios into fewer subsections than the spec defines.

### Step 4: Generate Architecture Decision Records

**Language reminder:** If Step 0 determined a non-English `docs_language`, generate all ADR section headings (Status, Context, Decision, Alternatives Considered, Consequences, References) and content in the target language. ADR file names (`adr-NNN-<slug>.md`) remain in English — the slug is always derived from the English Decision column text.

Read the ADR template at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` for the expected output format.

Generate formal ADRs from `## Decisions` tables across archived `design.md` files.

**Incremental detection:** Before generating ADRs, determine whether new archives need processing:

1. Glob `docs/decisions/adr-[0-9]*.md` to find existing generated ADR files (excluding manual `adr-M*.md`). If none exist → full generation mode (first run).
2. In full generation mode, process all archives. Otherwise:
3. Determine the highest existing ADR number from filenames.
4. For each existing ADR file, check its References section for an `[Archive: ...]` backlink to identify which archive produced it. Build a set of already-processed archives.
5. If any existing ADR lacks an archive backlink (e.g., legacy files from before this feature), fall back to full generation for this run.
6. Glob `openspec/changes/archive/*/design.md` and sort chronologically. Identify archives NOT in the already-processed set.
7. For unprocessed archives, check if they contain valid Decisions tables (see skip rule below).
8. If no new archives with valid Decisions tables exist → skip ADR generation entirely and report "ADRs are up-to-date."
9. If new archives exist → generate new ADR files starting from `highest_existing_number + 1`.

**One-time full regeneration for consolidation:** If the existing ADR file count does not match the expected count after applying consolidation heuristics to all archives, perform a full regeneration. This handles the transition when consolidation is first introduced. Delete all existing generated `adr-[0-9]*.md` files (preserve `adr-M*.md`) and regenerate from scratch.

**Discovery:** Glob `openspec/changes/archive/*/design.md`. Sort archives chronologically by their `YYYY-MM-DD` prefix. Skip archives without `design.md`.

**Enrichment:** For each archive being processed, read the FULL `design.md` — not just the Decisions table. Read the `## Context`, `## Architecture & Components`, and `## Risks & Trade-offs` sections to provide rich source material for ADR Context and Consequences sections. Also read `research.md` (Sections 2 and 3: External Research and Approaches) and `proposal.md` (`## Why`) from the same archive if they exist. This data is essential for writing rich ADR Context sections and accurate Consequences. Do NOT rely on data loaded during earlier steps — Step 4 must independently read all source materials.

**Skip rule:** After reading each `design.md`, verify that a markdown table with pipe delimiters exists under a heading containing "Decisions" (e.g., `## Decisions` or `## Architecture Decisions`). A valid Decisions table MUST have columns that include "Decision" and "Rationale". If the section contains only prose (e.g., "No architectural changes"), a non-Decisions table (e.g., Success Metrics), or no table at all — skip that archive for ADR generation.

**Consolidation heuristics:** Before assigning numbers, apply these rules to each archive's Decisions table:

1. If the archive's Decisions table has 3 or more rows AND the archive represents a single-topic change (determined by: archive name suggests one topic, all decisions reference the same capabilities) → consolidate all decisions into one ADR.
2. If decisions within the same archive clearly address different concerns (e.g., one about naming, another about data migration) → keep them as separate ADRs.
3. For borderline cases (2 rows, or mixed topics) → keep separate (conservative default).

**Inline rationale (all ADR types):** Every ADR — whether consolidated or single-decision — SHALL include rationale inline in the Decision section using the em-dash pattern. There is no separate `## Rationale` section. The Rationale column from the design.md Decisions table provides the inline rationale text.

- **Consolidated ADRs**: Numbered list of sub-decisions, each with inline rationale: `1. **Sub-decision text** — rationale`
- **Single-decision ADRs**: `**Decision text** — rationale`

**Consolidated ADR format:** A consolidated ADR uses:
- **Title**: Derived from the archive name or the most significant decision row (e.g., "Rename init skill to setup")
- **Slug**: Derived from the consolidated title, not individual sub-decisions
- **Decision section**: Numbered list of sub-decisions with individual rationale inline (em-dash pattern)
- **Alternatives Considered**: Merged from all consolidated rows
- **Consequences**: Combined across all consolidated decisions

**Numbering:** Assign sequential numbers (zero-padded, 3 digits) across all archives, accounting for consolidation. Each consolidated group gets ONE number. Within each archive, unconsolidated decisions are numbered in table row order. Example: initial-spec has 3 separate decisions → ADR-001, ADR-002, ADR-003. rename-init-to-setup has 5 rows consolidated into 1 → ADR-004.

**Slug generation:** From the Decision column text (or consolidated title), apply this deterministic algorithm:
1. Lowercase the entire string
2. Replace any character that is NOT in `[a-z0-9]` with a hyphen
3. Collapse consecutive hyphens into a single hyphen
4. Trim leading and trailing hyphens
5. Truncate to 50 characters
6. Trim trailing hyphens again (in case truncation split a word)

Examples: "Sync marketplace.json in same convention" → `sync-marketplace-json-in-same-convention`. "Config as bootstrap-only" → `config-as-bootstrap-only`.

**Handle both table formats:**
- 3-column: `| Decision | Rationale | Alternatives |`
- 4-column: `| # | Decision | Rationale | Alternatives Considered |`

**For each decision (or consolidated group), generate `docs/decisions/adr-NNN-<slug>.md`** following the template structure. The template includes split Consequences (Positive/Negative) and a References section.

**References (internal links only):** References SHALL contain only internal relative links — no external URLs (GitHub issues, external docs). The archive backlink provides traceability to GitHub issues via the archive's proposal.md.

The first reference in every ADR SHALL be the source archive backlink: `[Archive: <short-name>](../../openspec/changes/archive/<archive-dir>/)` where `<short-name>` is the archive directory name without the date prefix (e.g., `improve-docs-quality` from `2026-03-05-improve-docs-quality`). After the archive link, determine which specs are relevant to each decision. Check the archive's `specs/` subdirectory to find which capabilities were affected. Link to those baseline specs using semantic link text: `[Spec: capability-name](../../openspec/specs/capability/spec.md)`. Also cross-reference other ADRs from the same archive when decisions are related.

**Reference validation with auto-resolution:** After writing each ADR's References, validate all links and actively resolve broken references:
- For every `[Spec: <name>]` link, glob `openspec/specs/<name>/spec.md` to verify the spec exists. If it doesn't exist (e.g., renamed or split), search for successor spec(s). If found, replace the broken link. If the successor cannot be determined, ask the user to identify the correct spec. No `<!-- REVIEW -->` markers should be left in the output.
- For every `[Archive: <name>]` link, glob `openspec/changes/archive/*-<name>/` to verify the archive exists. If not found, ask the user whether to remove the link or provide the correct archive name. No `<!-- REVIEW -->` markers should be left in the output.

**Cross-reference heuristic:** Beyond cross-referencing ADRs from the same archive, check if the current ADR's archive modifies a system established by an earlier ADR. Look for explicit references to other changes in proposal.md/design.md, or overlapping `specs/` subdirectories with earlier archives. If a clear thematic relationship exists, add a cross-reference to the earlier ADR. Do NOT add cross-references speculatively — only when the relationship is evident from the archive content.

**Do NOT generate an ADR index at `docs/decisions/README.md`.** ADR discovery is handled by `docs/decisions.md` (generated in Step 5b).

**No archives with design.md:** Skip ADR generation entirely, do not create `docs/decisions/`.

Create `docs/decisions/` directory if it does not exist.

**Track writes:** Record whether any ADR was created during this step. This flag is needed for Step 5b (conditional decisions.md regeneration) and Step 5c (conditional README regeneration).

**Manual ADR preservation:** Do NOT delete files matching `adr-M*.md` in `docs/decisions/`. These are manual ADRs not generated from archived design.md files. They use the `adr-MNNN-slug.md` naming convention (M prefix + 3-digit zero-padded number) to distinguish them from generated ADRs.

### Step 5: Generate Documentation Files

**Language reminder:** If Step 0 determined a non-English `docs_language`, generate all section headings, table headers, and content in the target language for all sub-steps below. Product names, commands, and file paths remain in English.

#### Step 5a: Generate Architecture Overview

**Conditional regeneration:** Only regenerate `docs/architecture.md` if at least one of these conditions is met:
1. `docs/architecture.md` does not exist yet (first run).
2. The content of `openspec/constitution.md` (Tech Stack, Architecture Rules, Conventions sections) has diverged from the corresponding sections in the existing `docs/architecture.md`. Read the constitution and compare its key content against the file to detect drift.

If none of these conditions are met, skip and report: "architecture.md is up-to-date — no constitution changes detected."

Read the architecture template at `openspec/schemas/opsx-enhanced/templates/docs/architecture.md` for the expected output format.

Create or update `docs/architecture.md` synthesized from:
- `openspec/constitution.md` — Tech Stack, Architecture Rules, Conventions sections
- `openspec/specs/three-layer-architecture/spec.md` — the three-layer model description

**No constitution found:** Warn the user and skip architecture overview generation.
**No three-layer-architecture spec:** Generate a minimal System Architecture section from constitution Architecture Rules only.

**Track writes:** Record whether `docs/architecture.md` was written to disk. This flag is needed for Step 5c.

#### Step 5b: Generate Decisions Index

**Conditional regeneration:** Only regenerate `docs/decisions.md` if at least one of these conditions is met:
1. Any ADR was created in Step 4 (check the tracking flag).
2. `docs/decisions.md` does not exist yet (first run).

If none of these conditions are met, skip and report: "decisions.md is up-to-date — no ADR changes detected."

Read the decisions template at `openspec/schemas/opsx-enhanced/templates/docs/decisions.md` for the expected output format.

Create or update `docs/decisions.md` with the **Key Design Decisions table** built by reading all ADR files in `docs/decisions/`. For each ADR, extract:
- **Decision**: A summary derived from the `## Decision` section content. For consolidated ADRs with numbered sub-decisions, summarize the overarching decision. For single-decision ADRs, use the decision text.
- **Rationale**: For generated ADRs, extract the inline rationale (the text after the em-dash `—` in the Decision section). For manual ADRs, extract from the `## Rationale` section if present.
- **ADR link**: Link directly to the ADR file (e.g., `[ADR-001](decisions/adr-001-slug.md)`).

List generated ADRs first (ordered by number), followed by manual ADRs (ordered by M-number). Do NOT read `design.md` archives for this table — ADR files are the single canonical source. Surface notable trade-offs from ADR Negative Consequences — add a "Notable Trade-offs" subsection if any decisions have significant negative consequences. Include trade-offs that affect documentation consumers or represent meaningful constraints — every ADR with a substantive negative consequence should be represented.

**No ADR files found:** If no ADR files exist in `docs/decisions/`, skip this step entirely — do not create `docs/decisions.md`.

**Track writes:** Record whether `docs/decisions.md` was written to disk. This flag is needed for Step 5c.

#### Step 5c: Generate README Hub

**Conditional regeneration:** Only regenerate `docs/README.md` if at least one of these conditions is met:
1. Any capability doc was written to disk in Step 3 (check the tracking flag).
2. `docs/architecture.md` was written in Step 5a (check the tracking flag).
3. `docs/decisions.md` was written in Step 5b (check the tracking flag).
4. `docs/README.md` does not exist yet (first run).

If none of these conditions are met, skip README regeneration and report: "README is up-to-date — no changes detected."

Read the README template at `openspec/schemas/opsx-enhanced/templates/docs/readme.md` for the expected output format.

Create or update `docs/README.md` as a **compact hub/index** for all generated documentation, containing:
- A brief project description derived from the constitution or three-layer-architecture spec
- Navigation links to `docs/architecture.md` and `docs/decisions.md`
- A capabilities section

**Capabilities section:** Group capabilities by the `category` field from baseline spec YAML frontmatter. Render each category as a group header (title-case of the kebab-case value, e.g., `change-workflow` → "Change Workflow"). Within each group, order by `order` field (lower first). If a capability has no `category`, place in an "Other" group.

### Step 6: Cleanup Stale Files + Confirm

**Cleanup:** If `docs/architecture-overview.md` exists (from a previous run), delete it — its content is now in `docs/architecture.md`. If `docs/decisions/README.md` exists, delete it — ADR discovery is via `docs/decisions.md`. Never delete files matching `adr-M*.md` in `docs/decisions/` — these are manual ADRs.

**Confirm:** Show the user which docs were created/updated and a summary of changes.

---

## Output On Success

```
## Docs Generated

**Capabilities**: N regenerated, K skipped (no newer archives), J skipped (unchanged content)
**ADRs**: M new ADRs generated / "up-to-date" (no new archives with decisions)
**Architecture**: Regenerated / "up-to-date" (no constitution changes)
**Decisions**: Regenerated / "up-to-date" (no ADR changes)
**README**: Regenerated / "up-to-date" (no changes detected)

**Output**:
- `docs/capabilities/*.md` (N capability docs updated)
- `docs/decisions/adr-*.md` (M new ADRs)
- `docs/architecture.md` (regenerated / skipped)
- `docs/decisions.md` (regenerated / skipped)
- `docs/README.md` (regenerated / skipped)

### Capabilities — Regenerated
- [x] Capability Title (capability-id) — enriched / spec-only
- [x] ...

### Capabilities — Skipped (unchanged content)
- [ ] Capability Title (capability-id) — regenerated but identical, lastUpdated preserved
(only shown if any)

### Capabilities — Skipped (no newer archives)
- [ ] Capability Title (capability-id)
- [ ] ...

### Decision Records
- [x] M new ADRs generated from N new archived design.md files
(or: "All ADRs are up-to-date — no new archives with decisions")

### Documentation Files
- [x] docs/architecture.md — Regenerated / "up-to-date"
- [x] docs/decisions.md — Regenerated / "up-to-date"
- [x] docs/README.md — Regenerated / "up-to-date"

### Cleaned Up
- [x] Deleted docs/architecture-overview.md (content now in docs/architecture.md)
- [x] Deleted docs/decisions/README.md (replaced by docs/decisions.md)
(only shown if files were deleted)
```

## Output When No Specs

```
## Docs

No specs found in openspec/specs/. Run /opsx:archive first to merge specs.
```

## Quality Guidelines

- Write for **end users**, not developers
- No technical jargon, no implementation details
- Use present tense ("You can...", "The system...")
- Each capability doc should be self-contained and understandable on its own
- Keep it concise: 1-2 pages per capability maximum
- Focus on WHAT users can do, not HOW the system implements it

## Guardrails

- Always read the spec file before generating — do not generate from memory
- **Read before write**: If a capability doc already exists, read it FIRST and update/enrich it rather than rewriting from scratch. This preserves established tone, phrasing, and structure. Only add or modify sections where enrichment data provides new information. If existing content is already good, keep it.
- If a spec has no User Stories and no Requirements section, skip it and warn
- Preserve existing docs for specs not being regenerated (single-capability mode)
- `docs/README.md` is conditionally regenerated — only when capability docs or sub-files (architecture.md, decisions.md) changed (see Step 5c conditions)
- Do NOT generate `docs/architecture-overview.md` or `docs/decisions/README.md` — these are replaced by `docs/architecture.md` and `docs/decisions.md`
- Use consistent terminology across all generated docs
- **Internal consistency check**: After generating each doc, verify that the Behavior section and Edge Cases section do not contradict each other. If an edge case qualifies a behavior (e.g., "X is blocked, unless user explicitly confirms"), the behavior section must reflect the nuance — not state an absolute that the edge case then contradicts.
- **Step independence:** Each step must read its own source materials independently. Do not assume that data loaded during an earlier step is still available — steps may execute in separate contexts. This is especially critical for Step 4 (ADR generation), which needs full archive data independently of Step 2.
