# Technical Design: Documentation Ecosystem

## Context

`/opsx:docs` currently generates capability docs from baseline specs only. This change enriches the skill to also read archived artifacts (proposal, research, design, preflight) and generate additional documentation outputs (architecture overview, ADRs). The `docs-generation` capability is split into focused capabilities (`user-docs`, `architecture-docs`, `decision-docs`) and changelog moves to `release-workflow`. The only implementation file modified is `skills/docs/SKILL.md` — the skill prompt that instructs the agent. Spec restructuring is handled via delta specs (ADDED for new capabilities, REMOVED for docs-generation, ADDED to release-workflow).

## Architecture & Components

**Modified file:**

| File | Change |
|------|--------|
| `skills/docs/SKILL.md` | Add new steps and enriched template to the skill prompt |

**Generated files (by running `/opsx:docs` after implementation):**

| File | Source |
|------|--------|
| `docs/capabilities/*.md` | Enriched with archive-derived sections |
| `docs/architecture-overview.md` | Constitution + three-layer-architecture spec + design Decisions |
| `docs/decisions/adr-NNN-*.md` | Design.md Decisions tables across all archives |
| `docs/decisions/README.md` | ADR index |
| `docs/README.md` | Expanded TOC |

**How archive lookup works:**

For each capability being documented, the agent globs `openspec/changes/archive/*/specs/<capability>/` to find archives that touched it. Then reads `proposal.md`, `research.md`, `design.md`, `preflight.md` from those archive root directories. No index-building step — just a direct glob per capability.

**Step sequence in enriched SKILL.md:**

```
Step 1: Discover Specs (unchanged)
Step 2: Extract Features + Archive Enrichment (expanded)
Step 3: Generate Enriched Capability Docs (new template)
Step 4: Generate Architecture Overview (new)
Step 5: Generate ADRs (new)
Step 6: Update Table of Contents (expanded)
Step 7: Confirm (unchanged)
```

## Goals & Success Metrics

* `skills/docs/SKILL.md` contains enrichment steps — PASS if steps for archive lookup, architecture overview, and ADR generation are present
* Running `/opsx:docs` produces `docs/capabilities/release-workflow.md` with "Why This Exists" section — PASS if section present and derived from proposal
* Running `/opsx:docs` produces `docs/architecture-overview.md` — PASS if file exists with System Architecture, Tech Stack, Key Design Decisions, Conventions sections
* Running `/opsx:docs` produces ADR files in `docs/decisions/` — PASS if ADR count matches total Decisions table rows across all archived design.md files
* Running `/opsx:docs` produces `docs/decisions/README.md` — PASS if index lists all ADRs with number, title, date, change name
* `docs/README.md` links architecture overview and decisions index — PASS if links present
* Capabilities with no archive data generate spec-only docs (no enriched sections) — PASS if no errors and no empty sections

## Non-Goals

* No modifications to `/opsx:changelog` behavior (works as-is, just moves to `release-workflow` spec)
* No new skills or subcommand flags
* No schema or constitution modifications
* No tasks.md usage in documentation (implementation-internal)
* No separate research log output (research context integrated into ADR Context sections)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Split `docs-generation` into `user-docs`, `architecture-docs`, `decision-docs` | Each concern is independently spec'd and testable; changelog fits better under `release-workflow` | Keep everything in one bloated `docs-generation` spec |
| All doc types in `/opsx:docs`, no new skills | User preference, avoids skill proliferation, single entry point | Separate `/opsx:adr` + `/opsx:research-log` skills |
| Direct glob per capability instead of pre-built index | Simpler, no separate step needed, archives are few | Capability-to-Change Index with proposal parsing (over-engineering) |
| ADRs fully regenerated each run | Deterministic, no state to track, numbering always consistent | Incremental updates (requires tracking which archives are processed) |
| Research context integrated into ADR Context section | One place for "why did we decide this?", avoids separate research log | Separate `docs/research/` output (more files, less focused) |
| "Why This Exists" uses newest archive's proposal | Most current motivation, older may be superseded | Concatenate all (verbose), oldest only (may be outdated) |
| initial-spec-only capabilities use spec Purpose | Bootstrap proposal "Why" is about spec creation, not individual capabilities | Use bootstrap proposal anyway (misleading) |

## Risks & Trade-offs

* **SKILL.md prompt length** (~150 → ~300 lines) → Acceptable for a comprehensive doc generation skill. Clear section headers maintain readability.
* **Missing archive artifacts** (e.g., no design.md in fix-init-skill) → Graceful fallback: skip enrichment from missing artifacts, omit empty sections.
* **ADR numbering instability** if archives reordered → Numbers are regenerated deterministically from chronological sort. Not an issue in practice.

## Open Questions

No open questions.

## Assumptions

<!-- ASSUMPTION: skills/docs/SKILL.md is the only file that needs modification — all behavior is prompt-driven -->
<!-- ASSUMPTION: The glob pattern archive/*/specs/<capability>/ reliably finds all archives that touched a capability -->
<!-- ASSUMPTION: Decisions table format is consistent across archives (3-column or 4-column variants) -->
