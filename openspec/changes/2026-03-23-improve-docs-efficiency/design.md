# Technical Design: Improve Docs Efficiency

## Context

The `/opsx:docs` command regenerates all documentation artifacts on every run — reading all 13 archives, rebuilding 49+ ADRs, and rewriting the README — even when nothing changed. This creates unnecessary overhead as the project grows.

The entire generation logic lives in `skills/docs/SKILL.md`, a prompt that guides an LLM agent through 6 steps. There is no traditional code — "implementation" means modifying agent instructions. Change detection must use file metadata the agent can read: dates in filenames, YAML frontmatter fields, and file content comparison.

Four issues are addressed: incremental generation (#22), false timestamp bumps (#42), missing archive backlinks in ADRs (#30), and excessive ADR granularity (#44).

## Architecture & Components

### Affected Files

| File | Change Type | Description |
|------|------------|-------------|
| `skills/docs/SKILL.md` | Modified | Add change detection logic, content-aware writes, consolidation heuristics, archive backlinks, conditional README regeneration |
| `openspec/specs/user-docs/spec.md` | Modified (via sync) | New incremental generation requirement, content-aware timestamps |
| `openspec/specs/decision-docs/spec.md` | Modified (via sync) | Incremental ADR generation, consolidation, archive backlinks |
| `openspec/specs/architecture-docs/spec.md` | Modified (via sync) | Conditional README regeneration |

### SKILL.md Step Modifications

**Step 1 (Discover Specs)** — Add change detection phase:
- After discovering all specs, read existing `docs/capabilities/<capability>.md` files to extract `lastUpdated` from each
- For each capability, glob its archives and compare dates against `lastUpdated`
- Build a list of capabilities that need regeneration vs. those to skip
- Report skip decisions in output

**Step 2 (Archive Enrichment)** — Scope to changed capabilities:
- Only read archives for capabilities marked for regeneration
- In single-capability mode, only read that capability's archives (reinforce existing behavior)

**Step 3 (Capability Docs)** — Content-aware writes:
- Skip capabilities not marked for regeneration
- After generating each doc, compare content (excluding `lastUpdated` line) against existing file
- Only write file and bump `lastUpdated` if content differs
- Track whether any capability doc was actually written (for README conditional)

**Step 4 (ADRs)** — Incremental generation + consolidation + backlinks:
- Count existing `adr-[0-9]*.md` files and find highest number
- Check each archive's ADR files for archive backlinks to identify already-processed archives
- Only process new archives with valid Decisions tables
- Apply consolidation heuristics before numbering
- Add archive backlink as first reference in each ADR
- Track whether any ADR was created (for README conditional)

**Step 5 (README)** — Conditional regeneration:
- Only regenerate if: any capability doc was written, any ADR was created, README doesn't exist, or constitution content has drifted from what's in the README
- For constitution drift detection: read `openspec/constitution.md`, compare key sections (Tech Stack, Architecture Rules, Conventions) against corresponding README sections
- Otherwise skip and report "README is up-to-date"

**Step 6 (Cleanup + Confirm)** — Enhanced output:
- Show three categories: regenerated, skipped (unchanged content), skipped (no newer archives)
- Report ADR generation status (new count or "up-to-date")
- Report README status (regenerated or "up-to-date")

### Consolidation Logic Detail

The agent applies these rules in Step 4 when processing a Decisions table:

1. Read all rows from the Decisions table
2. If the archive represents a single-topic change (determined by: archive name suggests one topic, all decisions reference the same capabilities) AND has 3+ rows → consolidate all into one ADR
3. If decisions clearly address different concerns → keep separate
4. For borderline cases (2 rows, or mixed topics) → keep separate (conservative default)

The consolidated ADR:
- Title: derived from archive name or the primary decision
- Slug: derived from the consolidated title
- Decision section: numbered list of sub-decisions with individual rationale
- Alternatives: merged from all rows
- Consequences: combined across all decisions
- References: same archive backlink, all affected specs

## Goals & Success Metrics

* Running `/opsx:docs` with no new archives completes without writing any files — PASS if zero files modified
* Running `/opsx:docs` after adding one archive regenerates only affected capability docs and new ADRs — PASS if unchanged capabilities are skipped
* Capability doc `lastUpdated` is NOT bumped when generated content is identical — PASS if timestamp stays unchanged after regeneration with no content changes
* ADR files include archive backlink in References — PASS if every generated ADR has `[Archive: ...]` link
* Single-topic archive with 3+ decisions produces 1 consolidated ADR — PASS if rename-init-to-setup archive produces 1 ADR instead of 5
* README is only regenerated when capability docs or ADRs change — PASS if README is skipped when no docs/ADRs change

## Non-Goals

- Manifest or state file for tracking processed archives (decided against — stateless approach is simpler)
- Design.md format changes for explicit decision grouping columns
- Detecting spec-only changes without new archives (acceptable gap — user can run `/opsx:docs <capability>` to force)
- Preflight validation for decision granularity (separate concern, future enhancement)
- Performance benchmarking or timing measurements (the system is prompt-driven, not code)

## Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Stateless date comparison for change detection | Uses existing metadata (archive date prefixes + doc `lastUpdated`). No new state to maintain, no drift risk, always reflects true file system state. | Manifest file (adds complexity + drift risk), Git-based detection (requires git, brittle with rebases) |
| 2 | Content comparison before write for timestamp accuracy | Prevents false `lastUpdated` bumps when regeneration produces identical content. Agent compares generated body text against existing file, excluding `lastUpdated` field. | Skip-write-when-no-new-archives (less precise — misses cases where archive touches capability but output is unchanged) |
| 3 | Agent-side consolidation heuristics for ADR grouping | Works retroactively with all existing archives. No design.md format changes needed. Conservative rules (3+ rows + single-topic) minimize false consolidation. | Design.md grouping column (requires format change + retroactive archive edits), Preflight validation (future-only, doesn't fix existing) |
| 4 | Archive backlink as first reference in ADR | Improves traceability from decision to source research/design. Archive path already known during generation. Uses short name without date prefix for readability. | No alternatives — straightforward enhancement |
| 5 | One-time full ADR regeneration when consolidation is introduced | Consolidation changes ADR numbering. Must regenerate all ADRs once to apply grouping consistently. Detected by comparing expected consolidated count vs. existing file count. | Incremental-only (leaves inconsistent numbering between old granular and new consolidated ADRs) |
| 6 | Conditional README regeneration based on this-run writes and constitution drift | README depends on capability docs, ADRs, and constitution. Agent tracks whether any doc/ADR was written, and also compares constitution content against README sections to detect drift. | Always regenerate (wastes effort), Timestamp comparison against README (less precise — README has no frontmatter date) |

## Risks & Trade-offs

- **Agent misinterprets date comparison** → Mitigation: Explicit step-by-step instructions with concrete examples (e.g., "2026-03-23 > 2026-03-05 means newer"). Worst case: unnecessary regeneration (safe failure mode).
- **Consolidation heuristics misjudge grouping** → Mitigation: Conservative rules — only auto-consolidate when 3+ rows AND single-topic archive. Borderline cases stay separate. Worst case: one over-consolidated ADR that can be fixed by splitting in a future run.
- **ADR numbering shift from consolidation** → Mitigation: One-time full regeneration on first run. README Key Design Decisions table is regenerated in the same run, so references stay consistent.
- **Constitution drift detection imperfect** → Mitigation: Agent compares key sections (Tech Stack, Architecture Rules, Conventions) from constitution against README. If comparison misses a subtle change, README may not regenerate. Safe failure mode — user can force with `/opsx:docs <any-capability>`.
- **Content comparison is imperfect for non-English docs** → Mitigation: Same comparison logic works regardless of language. The agent compares exact text, not semantic equivalence.

## Open Questions

No open questions.

## Assumptions

- Archive directories are immutable after archiving — content does not change, ensuring stable date-based detection. <!-- ASSUMPTION: Core architectural guarantee from archive workflow -->
- The `lastUpdated` field in capability doc frontmatter is only written by `/opsx:docs`, not manually edited. <!-- ASSUMPTION: Users follow workflow conventions -->
- Archive date prefixes accurately reflect creation date and are chronologically sortable. <!-- ASSUMPTION: Archive naming enforced by archive skill -->
- The agent can reliably compare two text blocks for equality (excluding specific frontmatter fields). <!-- ASSUMPTION: LLM agents can perform text comparison when given clear instructions -->
