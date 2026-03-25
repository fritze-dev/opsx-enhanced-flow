# Technical Design: ADR-Aware Docs Restructure

## Context

`docs/README.md` is a 148-line auto-generated monolith where the Key Design Decisions table (26 ADRs) and Notable Trade-offs (~30 lines) consume nearly half the document and grow with every archived change. This makes the entry point harder to scan and conflates navigation with reference material.

Separately, `/opsx:discover` builds research context from constitution and baseline specs but is unaware of existing architectural decisions — missing critical context about constraints, patterns, and rejected alternatives that should inform new research.

Both improvements connect through the new `docs/decisions.md`: it serves as both a standalone reference document and a lightweight index for discover's ADR awareness.

## Architecture & Components

### Part 1: README Split

**Files modified:**

| File | Change |
|------|--------|
| `skills/docs/SKILL.md` | Step 5 splits into 3 sub-steps: (5a) architecture.md, (5b) decisions.md, (5c) README hub. Step 6 cleanup updated. |
| `openspec/schemas/opsx-enhanced/templates/docs/readme.md` | Reduced to hub structure: nav links + capabilities table |
| `openspec/schemas/opsx-enhanced/templates/docs/architecture.md` | **New**: System Architecture + Tech Stack + Conventions |
| `openspec/schemas/opsx-enhanced/templates/docs/decisions.md` | **New**: Key Design Decisions table + Notable Trade-offs |

**Generation flow (Step 5 sub-steps):**

```
Step 5a: Generate docs/architecture.md
  Trigger: constitution drift OR file doesn't exist
  Source: constitution (Tech Stack, Architecture Rules, Conventions) + three-layer-architecture spec

Step 5b: Generate docs/decisions.md
  Trigger: new ADRs created in Step 4 OR file doesn't exist
  Source: all docs/decisions/adr-*.md files

Step 5c: Generate docs/README.md (hub)
  Trigger: capability docs changed (Step 3) OR architecture.md/decisions.md changed (5a/5b) OR file doesn't exist
  Source: baseline spec frontmatter (category, order) + capability doc titles
```

Each sub-step tracks whether it wrote to disk (boolean flag), used as trigger for the next sub-step.

### Part 2: Discover ADR Awareness

**Files modified:**

| File | Change |
|------|--------|
| `skills/discover/SKILL.md` | Step 2 gains sub-step: read `docs/decisions.md`, identify relevant ADRs, read selected ADR files |
| `openspec/schemas/opsx-enhanced/schema.yaml` | Research instruction adds ADR awareness guidance |
| `openspec/schemas/opsx-enhanced/templates/research.md` | New optional "Related Decisions" section (section 0, before Current State) |

**ADR selection flow in discover:**

```
1. Read docs/decisions.md → parse Decision + ADR columns from table
2. Match change topic against decision titles/rationale (keyword overlap, capability overlap)
3. Read only matched ADR files → extract ## Decision + ## Consequences
4. Write findings to research.md "Related Decisions" section
```

If `docs/decisions.md` doesn't exist → skip silently, proceed without ADR context.

## Goals & Success Metrics

* `/opsx:docs` generates 3 separate files: `docs/README.md` (hub, <50 lines), `docs/architecture.md`, `docs/decisions.md` — PASS/FAIL
* All 26+ ADRs appear in `docs/decisions.md` Key Design Decisions table — PASS/FAIL
* `docs/README.md` contains working relative links to `architecture.md` and `decisions.md` — PASS/FAIL
* Capabilities table in README hub is complete (all 18 capabilities, grouped by category) — PASS/FAIL
* `/opsx:discover` on a new change references relevant ADRs in research.md "Related Decisions" section when `docs/decisions.md` exists — PASS/FAIL
* Constitution change triggers only `docs/architecture.md` regeneration (not decisions.md) — PASS/FAIL

## Non-Goals

- No changes to capability doc generation (user-docs spec unchanged)
- No changes to ADR file generation logic (decision-docs spec unchanged)
- No changes to archive, sync, or apply workflows
- No changes to constitution content
- No automated ADR relevance scoring — keyword matching is sufficient

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Split README into hub + architecture.md + decisions.md — three files provides clean separation while keeping capabilities as the natural browsing entry point in the hub | Decisions table (26+ entries) and trade-offs grow with every change; architecture and conventions change rarely; capabilities are the primary browsing interface | Keep monolithic README (ADR-009); split into 4+ files (over-engineered); use collapsible HTML sections (rendering issues) |
| Per-file conditional regeneration with independent triggers — architecture.md triggers on constitution drift, decisions.md on ADR changes, README on capability/sub-file changes | Minimizes unnecessary regeneration; each file has a single clear responsibility and trigger | Single trigger for all files (causes unnecessary rewrites); no conditional regeneration (always regenerate everything) |
| Discover reads decisions.md index then selects specific ADRs — two-step process avoids reading all ADR files | decisions.md is lightweight (~30 lines of table); reading 26+ individual ADR files for every discover run is wasteful; index provides enough context for relevance filtering | Read all ADR files directly (too heavy); use ADR file names only for matching (too imprecise); skip ADR awareness entirely (misses valuable context) |
| Add optional "Related Decisions" section to research template — section 0, before Current State | Makes ADR references structured and visible; optional so trivial changes aren't burdened; positioned first because decisions set the architectural context for research | Inline ADR references in Current State (less structured); mandatory section (burdens simple changes); position after Approaches (too late) |

## Risks & Trade-offs

- **Reverses ADR-009 (Consolidated README)** → Accepted: the new structure provides better separation while maintaining a clear entry point. New ADR will supersede ADR-009.
- **Three files instead of one** → More files to maintain, but each has independent triggers so maintenance is actually simpler (only changed files regenerate).
- **Keyword-based ADR relevance in discover** → May miss some relevant ADRs or include irrelevant ones. Acceptable because: false negatives just mean less context (same as today), false positives are low-cost (a few extra lines read).
- **Old monolithic README overwritten on first run** → One-time migration. No rollback needed since README is auto-generated.
- **Step 5 complexity increases** → Three sub-steps instead of one, but each is simpler than the current monolithic step. Net complexity is comparable.

## Migration Plan

1. First `/opsx:docs` run after this change:
   - Existing `docs/README.md` is overwritten with hub format
   - `docs/architecture.md` and `docs/decisions.md` are created
   - `docs/architecture-overview.md` deleted if present (existing cleanup)
2. No manual migration steps required — fully automated on next `/opsx:docs` run.

## Open Questions

No open questions.

## Assumptions

- The `/opsx:docs` skill can track write flags across sub-steps within the same run. <!-- ASSUMPTION: Sub-step flags are in-memory booleans -->
- Keyword matching between change topics and ADR decision titles is sufficient for relevance filtering without sophisticated NLP. <!-- ASSUMPTION: Keyword matching sufficient -->
