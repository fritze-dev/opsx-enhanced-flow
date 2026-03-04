---
name: docs
description: Generate or update user-facing documentation from merged specs. Run after /opsx:archive to create capability docs, architecture overview, ADRs, and a table of contents.
disable-model-invocation: false
---

# /opsx:docs — Generate User Documentation

> Run this **after** `/opsx:archive` to generate or update user-facing documentation.

**Input**: Optional argument:
- No argument → regenerate all docs (capability docs, architecture overview, ADRs, TOC)
- A capability name (e.g., `auth`) → regenerate only that capability's doc

## Instructions

### Prerequisite: Verify Setup

Run `openspec schema which opsx-enhanced --json`. If it fails, tell the user to run `/opsx:init` first and stop.

### Step 1: Discover Specs

Glob `openspec/specs/*/spec.md` to find all available capabilities. The directory name is the capability ID.

If a capability name argument was given, process only that one (error if not found).

### Step 2: Look Up Archive Enrichment

For each capability being documented, glob `openspec/changes/archive/*/specs/<capability>/` to find archived changes that touched it.

For each archive found, read the following files from the archive root directory (skip any that don't exist):
- `proposal.md` — extract the `## Why` section
- `research.md` — extract the `## 3. Approaches` section and key findings
- `design.md` — extract `## Non-Goals`, `## Risks & Trade-offs`, and `## Decisions` table
- `preflight.md` — extract `## F. Assumption Audit` (assumptions rated "Acceptable Risk" that affect users)

**Multiple archives for one capability:** When multiple archives exist, use the newest archive's proposal for "Why This Exists" (most current motivation). Aggregate limitations across all archives.

**initial-spec fallback:** If a capability's only relevant archive is `initial-spec` (a bootstrap change whose proposal "Why" describes spec creation, not the capability itself), derive "Why This Exists" from the spec's `## Purpose` section instead.

**No archives found:** Skip enrichment — generate a spec-only doc (current behavior).

### Step 3: Generate Enriched Capability Documentation

For each capability, write or update `docs/capabilities/<capability>.md`:

```markdown
---
title: "[Capability Title]"
capability: "[capability-id]"
description: "[One-line summary of what this capability does]"
order: [number]
lastUpdated: "[YYYY-MM-DD]"
---

# [Capability Title]

[1-2 sentence overview derived from user stories or requirements.]

## Why This Exists

[1-3 sentences from proposal.md "Why" section of the relevant archive.
 Rewrite in user-facing language.
 OMIT this section if no archive data or initial-spec-only with no useful Purpose.]

## Background

[3-5 sentences summarizing research context: what was investigated,
 key findings, alternatives explored. Derived from research.md.
 OMIT this section entirely if research.md is trivial or missing.]

## Features

- [Bullet list of what users can do — derived from stories/requirements]

## Behavior

### [Feature Group]

[Plain-language description of key scenarios. Derived from Gherkin scenario titles and WHEN/THEN structure. Group related scenarios.]

## Known Limitations

- [design.md Non-Goals rewritten as "Does not support X"]
- [design.md Risks rewritten as user-relevant limitations]
- [preflight.md assumptions rated "Acceptable Risk" that affect users]
[Max 5 bullets. OMIT this section entirely if empty.]

## Edge Cases

- [All edge cases from the spec, rewritten in user-facing language. Include every edge case — do not drop any.]
```

**Conciseness guards:**
- "Why This Exists": max 3 sentences
- "Background": max 3-5 sentences
- "Known Limitations": max 5 bullets
- Priority when space-constrained: Features + Behavior (mandatory) > Why (preferred) > Background + Limitations (optional)
- Total: still 1-2 pages per capability

#### YAML Frontmatter Fields

| Field | Description |
|-------|-------------|
| `title` | Human-readable capability name |
| `capability` | Machine-readable ID (matches spec directory name) |
| `description` | One-line summary for the table of contents |
| `order` | Display order in the TOC (lower = higher) |
| `lastUpdated` | Date of last generation (`YYYY-MM-DD`) |

#### Mapping Rules

| Spec Element | Doc Element |
|---|---|
| User Story title + motivation | Features bullet |
| Gherkin scenario title | Behavior subsection |
| GIVEN/WHEN/THEN detail | Plain-language example under behavior |
| Edge Cases section | Edge Cases (simplified) |
| Technical terms (API, DB, etc.) | Replaced with plain-language or omitted |
| Product names (OpenSpec, Claude Code, etc.) | **Preserved as-is** — never abstract product names into generic terms |
| Implementation details (file paths, configs) | Omitted entirely |
| User-facing syntax/markers (`<!-- ASSUMPTION -->`, `<!-- REVIEW -->`, `[P]`, etc.) | **Included** — if users need to recognize or use a syntax convention, document it |

### Step 4: Generate Architecture Overview

Generate `docs/architecture-overview.md` — a cross-cutting document synthesized from:
- `openspec/constitution.md` — Tech Stack, Architecture Rules, Conventions sections
- `openspec/specs/three-layer-architecture/spec.md` — the three-layer model description
- All `openspec/changes/archive/*/design.md` — aggregate `## Decisions` tables for key design decisions

**Structure:**

```markdown
# Architecture Overview

## System Architecture

[Describe the three-layer model from the three-layer-architecture spec.
 If that spec doesn't exist, derive from constitution Architecture Rules.]

## Tech Stack

[From constitution Tech Stack section. Present as a readable list.]

## Key Design Decisions

[Aggregate notable decisions from all archived design.md Decisions tables.
 Deduplicate — if the same decision appears in multiple archives, include once.
 Present as a summary table or list. Focus on architectural decisions, not tactical ones.]

## Conventions

[From constitution Conventions section. Present as a readable list.]
```

**No constitution found:** Warn the user and skip architecture overview generation.
**No archived design.md files:** Omit the Key Design Decisions section.

This file is fully regenerated on each run.

### Step 5: Generate Architecture Decision Records

Generate formal ADRs from `## Decisions` tables across all archived `design.md` files.

**Discovery:** Glob `openspec/changes/archive/*/design.md`. Sort archives chronologically by their `YYYY-MM-DD` prefix. Skip archives without `design.md`.

**Numbering:** Assign sequential numbers (zero-padded, 3 digits) across all archives. Within each archive, number decisions in table row order. Example: initial-spec has 3 decisions → ADR-001, ADR-002, ADR-003. release-workflow has 4 → ADR-004 through ADR-007.

**Slug generation:** From the Decision column text: lowercase, replace spaces with hyphens, truncate to 50 characters, strip trailing hyphens.

**Handle both table formats:**
- 3-column: `| Decision | Rationale | Alternatives |`
- 4-column: `| # | Decision | Rationale | Alternatives Considered |`

**For each decision, generate `docs/decisions/adr-NNN-<slug>.md`:**

```markdown
# ADR-NNN: [Decision Title]

## Status

Accepted (YYYY-MM-DD)

## Context

[From the design.md "## Context" section.
 Enrich with research.md "## 3. Approaches" from the same archive if available —
 include relevant investigated approaches and findings.]

## Decision

[From the Decisions table "Decision" column.]

## Rationale

[From the Decisions table "Rationale" column.]

## Alternatives Considered

- [From the Decisions table "Alternatives" column, expanded into bullet points]

## Consequences

[From the design.md "## Risks & Trade-offs" section.
 Filter to entries relevant to this specific decision where possible.
 If no clear mapping, include the full Risks section for context.]
```

**Generate ADR index at `docs/decisions/README.md`:**

```markdown
# Architecture Decision Records

| ADR | Decision | Date | Change |
|-----|----------|------|--------|
| [ADR-001](adr-001-slug.md) | Decision title | YYYY-MM-DD | change-name |
| ... | ... | ... | ... |
```

**No archives with design.md:** Skip ADR generation entirely, do not create `docs/decisions/`.

ADRs are fully regenerated on each run (not incremental). Create `docs/decisions/` directory if it does not exist.

### Step 6: Update Table of Contents

Create or update `docs/README.md` with links to all generated documentation:

```markdown
# Documentation

## Architecture

- [Architecture Overview](architecture-overview.md)

## Capabilities

| Capability | Description |
|---|---|
| [Capability Title](capabilities/<capability-id>.md) | One-line summary (from frontmatter `description`) |
| ... | ... |

## Decisions

- [Architecture Decision Records](decisions/README.md)
```

Order capabilities by the `order` frontmatter field (lower = higher).

The architecture overview link appears before the capability table. The decisions link appears after.

### Step 7: Confirm

Show the user which docs were created/updated and a summary of changes.

---

## Output On Success

```
## Docs Generated

**Generated**: N capability docs + architecture overview + M ADRs + README
**Output**:
- `docs/capabilities/*.md` (N capability docs)
- `docs/architecture-overview.md`
- `docs/decisions/adr-*.md` (M ADRs) + `docs/decisions/README.md`
- `docs/README.md`

### Capabilities
- [x] Capability Title (capability-id) — enriched / spec-only
- [x] ...

### Architecture Overview
- [x] Generated from constitution + N design artifacts

### Decision Records
- [x] M ADRs generated from N archived design.md files

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
- If a spec has no User Stories and no Requirements section, skip it and warn
- If a doc file already exists, update it — don't overwrite manual additions
- Preserve existing docs for specs not being regenerated (single-capability mode)
- The overview page (`docs/README.md`) must always be regenerated — it links all capabilities
- Use consistent terminology across all generated docs
- **Internal consistency check**: After generating each doc, verify that the Behavior section and Edge Cases section do not contradict each other. If an edge case qualifies a behavior (e.g., "X is blocked, unless user explicitly confirms"), the behavior section must reflect the nuance — not state an absolute that the edge case then contradicts.
