# Research: Improve Docs Efficiency

## 1. Current State

### Affected Skills
- **`skills/docs/SKILL.md`** — Main `/opsx:docs` skill prompt (227 lines). Controls all doc generation logic as LLM instructions.

### Affected Specs
- **`openspec/specs/user-docs/spec.md`** — Capability doc generation rules. Contains "read before write" guardrail for incremental updates but no archive-level change detection.
- **`openspec/specs/decision-docs/spec.md`** — ADR generation rules. Explicitly states "ADRs SHALL be fully regenerated on each run (not incremental)" (line 12).
- **`openspec/specs/architecture-docs/spec.md`** — README generation rules. States "The content SHALL be regenerated fully on each run" (line 12) and "The `docs/README.md` SHALL always be regenerated on each run" (line 52).

### Current Generation Flow (Steps 0–6)
1. **Step 0**: Read `docs_language` from config
2. **Step 1**: Discover all specs via glob
3. **Step 2**: For each capability, glob ALL archives for enrichment data — reads `proposal.md`, `research.md`, `design.md`, `preflight.md` from every matching archive
4. **Step 3**: Generate/update capability docs (`docs/capabilities/<capability>.md`) — has "read before write" but always writes and bumps `lastUpdated`
5. **Step 4**: Regenerate ALL ADRs from scratch — glob all `design.md` files, number sequentially, write all files
6. **Step 5**: Regenerate README from scratch — reads constitution, all ADRs, all capability docs
7. **Step 6**: Cleanup stale files + confirm

### Current Scale
- 13 archives in `openspec/changes/archive/`
- 18 capability specs in `openspec/specs/`
- 49+ generated ADR files in `docs/decisions/`
- 1 consolidated README at `docs/README.md`

### Key Metadata Already Available
- **Capability docs**: `lastUpdated: "YYYY-MM-DD"` in YAML frontmatter
- **Archive directories**: `YYYY-MM-DD-<slug>` naming with date prefix
- **ADR files**: `adr-NNN-<slug>.md` naming with sequential numbers

## 2. External Research

No external dependencies. This is purely an LLM-prompt optimization — the "code" is `SKILL.md` instructions that guide the agent's behavior. Change detection and content comparison must be expressible as agent instructions.

Key constraint: The agent cannot run arbitrary code, compute hashes, or maintain runtime state between steps. Detection must rely on **file metadata readable by the agent** (dates in filenames, frontmatter fields, file content comparison).

## 3. Approaches

### Issue #22: Incremental Generation

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Stateless date comparison** — Compare archive date prefixes against capability doc `lastUpdated`. For ADRs, count existing files and only generate new ones from newer archives. | No new state file; uses existing metadata; simple for agent to follow; always correct (no drift risk) | May trigger unnecessary regeneration if archive touches capability but output is unchanged (mitigated by #42 fix); ADR detection slightly more complex |
| **B: Manifest file** — Track processed archives in `docs/.docs-manifest.yaml` | Explicit record of what was processed; fast lookup | New file to maintain; risk of manifest drift/corruption; needs `--force` escape hatch; more complex agent instructions |
| **C: Git-based detection** — Use `git log` to detect changed archives since last docs run | Leverages existing VCS | Requires git; doesn't work on first clone; brittle with rebases/squashes; agent may not have git access in all contexts |

**Recommendation: Approach A (Stateless date comparison)** — simplest, no new state, uses existing metadata, eliminates drift risk.

### Issue #42: Content-Aware Timestamps

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Content comparison before write** — Generate doc in memory, compare with existing (excluding `lastUpdated`), only write if different | Precise; no false positives; works with any trigger | Agent must hold both versions and compare; slightly more complex prompt instructions |
| **B: Skip write when no new archives** — Don't regenerate at all if no newer archives | Simpler; avoids generation entirely | Misses cases where spec itself changed; less precise |

**Recommendation: Approach A** — combined with #22's date-based detection, the agent regenerates only when an archive is newer, then compares content before writing. Double protection.

### Issue #30: ADR Archive Backlinks

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Add archive link to References** — `[Archive: <name>](../../openspec/changes/archive/<dir>/)` | Simple; archive path already known during generation; improves traceability | Minor increase in References section length |

**Recommendation: Approach A** — straightforward, no trade-offs.

### Issue #44: ADR Consolidation

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Agent-side heuristics** — When decisions from same archive share context/motivation, consolidate into single ADR with numbered sub-decisions | Reduces noise; reflects actual decision structure; no design.md format changes needed | Heuristics may misjudge; agent needs clear consolidation rules; changes ADR numbering behavior |
| **B: Design.md grouping column** — Add explicit "Group" column to Decisions table | Explicit control; no ambiguity | Requires design.md format change; retroactive archive updates needed; breaks existing table format |
| **C: Preflight validation** — Flag excessive fine-grained decisions during preflight | Prevents problem at source; doesn't change docs skill | Doesn't fix existing archives; only future prevention |

**Recommendation: Approach A (agent-side heuristics)** — works retroactively with existing archives, no format changes needed. Clear rules make it predictable:
- Decisions from same archive that share the same primary affected capability(ies) → consolidate
- Single-topic changes (rename, single feature) with 3+ decisions → consolidate by default
- The consolidated ADR gets one number (not one per sub-decision), reducing ADR count

## 4. Risks & Constraints

| Risk | Impact | Mitigation |
|------|--------|------------|
| Agent misinterprets date comparison logic | Medium — could skip needed regeneration or regenerate unnecessarily | Clear, explicit step-by-step instructions with examples |
| ADR consolidation heuristics produce wrong grouping | Low — worst case: one over-consolidated ADR | Conservative rules: only consolidate when decisions clearly share a single topic |
| ADR numbering changes from consolidation | High — existing ADR references in README become stale | Must regenerate all ADRs when consolidation logic is first introduced (one-time full regen) |
| Content comparison misses subtle changes | Low — agent compares full text | Instruct agent to compare body text excluding only `lastUpdated` field |
| Archives are immutable assumption violated | Low — core architectural guarantee | If violated, stateless detection still works (compares dates, doesn't track state) |
| README conditional regeneration misses constitution changes | Medium — README becomes stale | Agent checks constitution/three-layer-architecture modification dates against README date |

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Four well-defined issues: #22, #42, #30, #44 |
| Behavior | Clear | Stateless detection via date comparison; content comparison before write; consolidation heuristics; archive backlinks |
| Data Model | Clear | No new data model — uses existing frontmatter dates and file naming conventions |
| UX | Clear | `/opsx:docs` gains incremental behavior by default; output summary shows skipped items |
| Integration | Clear | Only modifies `skills/docs/SKILL.md` and three specs; no external dependencies |
| Edge Cases | Clear | First run, language change, spec-only changes, empty archives, consolidation edge cases |
| Constraints | Clear | Agent-executable instructions only; no runtime state; no hash computation |
| Terminology | Clear | "Incremental" = skip unchanged; "consolidation" = merge related decisions |
| Non-Functional | Clear | Reduces I/O and generation time proportional to unchanged capabilities |

## 6. Open Questions

All categories are Clear. No open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use stateless date comparison instead of manifest file | Simpler, no new state to maintain, no drift risk, uses existing metadata (archive date prefixes + doc `lastUpdated` frontmatter) | Manifest file (adds complexity + drift risk), Git-based detection (requires git, brittle) |
| 2 | Content comparison before write for timestamp accuracy | Prevents false `lastUpdated` bumps when regeneration produces identical content; precise and reliable | Skip-write-when-no-new-archives (less precise, misses spec changes) |
| 3 | Agent-side consolidation heuristics for ADR grouping | Works retroactively with existing archives, no design.md format changes needed, reduces ADR noise | Design.md grouping column (requires format change + archive updates), Preflight validation (future-only) |
| 4 | Add archive source link to ADR References section | Improves traceability; archive path already known during generation; minimal effort | No alternatives considered — straightforward enhancement |
| 5 | One-time full ADR regeneration when consolidation is introduced | Consolidation changes numbering; must regenerate all ADRs once to apply new grouping consistently | Incremental-only (would leave inconsistent numbering between old granular and new consolidated ADRs) |
