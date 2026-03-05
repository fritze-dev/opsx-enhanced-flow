---
name: docs
description: Generate or update user-facing documentation from merged specs. Run after /opsx:archive to create capability docs, ADRs, and a consolidated README with architecture overview.
disable-model-invocation: false
---

# /opsx:docs — Generate User Documentation

> Run this **after** `/opsx:archive` to generate or update user-facing documentation.

**Input**: Optional argument:
- No argument → regenerate all docs (capability docs, ADRs, consolidated README)
- A capability name (e.g., `auth`) → regenerate only that capability's doc

## Instructions

### Prerequisite: Verify Setup

Run `openspec schema which opsx-enhanced --json`. If it fails, tell the user to run `/opsx:init` first and stop.

### Step 0: Determine Documentation Language

Read `openspec/config.yaml` and extract the `docs_language` field.

- **Missing or "English":** Proceed with English output (default behavior, no change).
- **Non-English value (e.g., "German", "French"):** Generate all headings and content in the target language for Steps 3, 4, and 5. Apply these translation rules throughout:
  - YAML frontmatter **keys** remain in English (machine-readable identifiers)
  - YAML frontmatter **values** (`title`, `description`) are translated to the target language
  - Product names (OpenSpec, Claude Code), commands (`/opsx:*`), and file paths remain in English
  - If an existing doc is in a different language than the configured `docs_language`, treat it as a full regeneration rather than an incremental update

### Step 1: Discover Specs

Glob `openspec/specs/*/spec.md` to find all available capabilities. The directory name is the capability ID.

If a capability name argument was given, process only that one (error if not found).

### Step 2: Look Up Archive Enrichment

For each capability being documented, glob `openspec/changes/archive/*/specs/<capability>/` to find archived changes that touched it.

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

**Language reminder:** If Step 0 determined a non-English `docs_language`, generate all section headings and content in the target language. YAML frontmatter keys stay English; `title` and `description` values are translated.

Read the capability doc template at `openspec/schemas/opsx-enhanced/templates/docs/capability.md` for the expected output format.

For each capability, read its baseline spec's YAML frontmatter (if present) to get the `order` and `category` values. Write or update `docs/capabilities/<capability>.md` following the template structure.

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
- Priority when space-constrained: Features + Behavior (mandatory) > Purpose (preferred) > Rationale + Limitations + Future Enhancements (optional)
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
| User-facing syntax/markers (`<!-- ASSUMPTION -->`, `<!-- REVIEW -->`, `[P]`, etc.) | **Included** — if users need to recognize or use a syntax convention, document it |

### Step 4: Generate Architecture Decision Records

**Language reminder:** If Step 0 determined a non-English `docs_language`, generate all ADR section headings and content in the target language. ADR file names (`adr-NNN-<slug>.md`) remain in English — the slug is always derived from the English Decision column text.

Read the ADR template at `openspec/schemas/opsx-enhanced/templates/docs/adr.md` for the expected output format.

Generate formal ADRs from `## Decisions` tables across all archived `design.md` files.

**Discovery:** Glob `openspec/changes/archive/*/design.md`. Sort archives chronologically by their `YYYY-MM-DD` prefix. Skip archives without `design.md`.

**Skip rule:** After reading each `design.md`, verify that a markdown table with pipe delimiters exists under a heading containing "Decisions" (e.g., `## Decisions` or `## Architecture Decisions`). A valid Decisions table MUST have columns that include "Decision" and "Rationale". If the section contains only prose (e.g., "No architectural changes"), a non-Decisions table (e.g., Success Metrics), or no table at all — skip that archive for ADR generation.

**Numbering:** Assign sequential numbers (zero-padded, 3 digits) across all archives. Within each archive, number decisions in table row order. Example: initial-spec has 3 decisions → ADR-001, ADR-002, ADR-003. release-workflow has 4 → ADR-004 through ADR-007.

**Slug generation:** From the Decision column text, apply this deterministic algorithm:
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

**For each decision, generate `docs/decisions/adr-NNN-<slug>.md`** following the template structure. The template includes split Consequences (Positive/Negative) and a References section.

**Do NOT generate an ADR index at `docs/decisions/README.md`.** ADR discovery is handled by inline links in the `docs/README.md` Key Design Decisions table.

**No archives with design.md:** Skip ADR generation entirely, do not create `docs/decisions/`.

ADRs are fully regenerated on each run (not incremental). Create `docs/decisions/` directory if it does not exist.

**Manual ADR preservation:** Do NOT delete files matching `adr-M*.md` in `docs/decisions/`. These are manual ADRs not generated from archived design.md files. They use the `adr-MNNN-slug.md` naming convention (M prefix + 3-digit zero-padded number) to distinguish them from generated ADRs.

### Step 5: Generate Consolidated README

**Language reminder:** If Step 0 determined a non-English `docs_language`, generate all section headings, table headers, and content in the target language. Product names, commands, and file paths remain in English.

Read the README template at `openspec/schemas/opsx-enhanced/templates/docs/readme.md` for the expected output format.

Create or update `docs/README.md` as the **single entry point** for all generated documentation. This file merges the architecture overview and capabilities table into one document, synthesized from:
- `openspec/constitution.md` — Tech Stack, Architecture Rules, Conventions sections
- `openspec/specs/three-layer-architecture/spec.md` — the three-layer model description
- All `openspec/changes/archive/*/design.md` — aggregate `## Decisions` tables for key design decisions
- All generated ADR files (from Step 4) — for inline ADR links
- All generated capability docs (from Step 3) — for the capabilities table

**Key Design Decisions table:** Use an "ADR" column linking directly to the corresponding ADR file (e.g., `[ADR-001](decisions/adr-001-slug.md)`). Include ALL decisions from archived design.md files. Additionally, discover manual ADRs matching `docs/decisions/adr-M*.md` and include them in the table after all generated ADRs, with links like `[ADR-M001](decisions/adr-M001-init-model-invocable.md)`. Extract the Decision and Rationale from the manual ADR's `## Decision` and `## Rationale` sections. Surface notable trade-offs from ADR Negative Consequences — add a "Notable Trade-offs" subsection if any decisions have significant negative consequences. Include trade-offs that affect documentation consumers or represent meaningful constraints — every ADR with a substantive negative consequence should be represented.

**Capabilities section:** Group capabilities by the `category` field from baseline spec YAML frontmatter. Render each category as a group header (title-case of the kebab-case value, e.g., `change-workflow` → "Change Workflow"). Within each group, order by `order` field (lower first). If a capability has no `category`, place in an "Other" group.

**No constitution found:** Warn the user and skip architecture overview generation.
**No archived design.md files:** Omit the Key Design Decisions section.

This file is fully regenerated on each run.

### Step 6: Cleanup Stale Files + Confirm

**Cleanup:** If `docs/architecture-overview.md` exists (from a previous run), delete it — its content is now part of `docs/README.md`. If `docs/decisions/README.md` exists, delete it — ADR discovery is now via inline links in `docs/README.md`. Never delete files matching `adr-M*.md` in `docs/decisions/` — these are manual ADRs.

**Confirm:** Show the user which docs were created/updated and a summary of changes.

---

## Output On Success

```
## Docs Generated

**Generated**: N capability docs + M ADRs + consolidated README
**Output**:
- `docs/capabilities/*.md` (N capability docs)
- `docs/decisions/adr-*.md` (M ADRs)
- `docs/README.md` (architecture overview + capabilities + ADR index)

### Capabilities
- [x] Capability Title (capability-id) — enriched / spec-only
- [x] ...

### Decision Records
- [x] M ADRs generated from N archived design.md files

### Cleaned Up
- [x] Deleted docs/architecture-overview.md (merged into README)
- [x] Deleted docs/decisions/README.md (replaced by inline ADR links)
(only shown if files were deleted)

### Skipped (no changes)
- ...
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
- `docs/README.md` must always be regenerated — it contains the architecture overview and links all capabilities
- Do NOT generate `docs/architecture-overview.md` or `docs/decisions/README.md` — these are replaced by the consolidated README
- Use consistent terminology across all generated docs
- **Internal consistency check**: After generating each doc, verify that the Behavior section and Edge Cases section do not contradict each other. If an edge case qualifies a behavior (e.g., "X is blocked, unless user explicitly confirms"), the behavior section must reflect the nuance — not state an absolute that the edge case then contradicts.
