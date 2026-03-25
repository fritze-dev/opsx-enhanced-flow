# Pre-Flight Check: ADR-Aware Docs Restructure

## A. Traceability Matrix

### architecture-docs (Modified)

- [x] Generate Architecture Overview → Scenarios: standalone file, skip on no drift, regenerate on drift, no three-layer spec → Components: `skills/docs/SKILL.md` Step 5a, `templates/docs/architecture.md`
- [x] Generate Decisions Index → Scenarios: generated from ADRs, includes manual ADRs, skip when no new ADRs, no ADR files → Components: `skills/docs/SKILL.md` Step 5b, `templates/docs/decisions.md`
- [x] Generate Documentation Table of Contents → Scenarios: compact hub, grouped capabilities, regenerate on capability change, regenerate on sub-file change, skip when no changes, stale cleanup → Components: `skills/docs/SKILL.md` Step 5c, `templates/docs/readme.md`
- [x] Language-Aware Architecture Overview → Scenarios: architecture in language, decisions translated → Components: `skills/docs/SKILL.md` Steps 5a/5b/5c

### decision-docs (Modified)

- [x] ADR Discovery via Decisions Index → Scenarios: discovery via index, no decisions/README.md → Components: `skills/docs/SKILL.md` Step 4 (rule update), Step 5b, Step 6 (cleanup)

### interactive-discovery (Modified)

- [x] Standalone Research with Q&A → Scenarios: ADR awareness, without decisions index, no relevant ADRs, partial categories, all clear, record decisions, max 5 questions, stale-spec, no active change, no advance past research, prerequisite fail → Components: `skills/discover/SKILL.md` Step 2, `templates/research.md`, `schema.yaml` research instruction

## B. Gap Analysis

- **No gap:** First-run migration from monolithic README to hub is covered — old README is overwritten, new files created.
- **No gap:** `docs/decisions/README.md` cleanup already exists in Step 6 of SKILL.md.
- **No gap:** Discover gracefully degrades when `docs/decisions.md` doesn't exist.
- **Minor:** No explicit scenario for what happens when `docs/architecture.md` exists but `docs/decisions.md` doesn't (e.g., ADR generation was skipped). Not a real gap — each file has independent triggers, so one can exist without the other.

## C. Side-Effect Analysis

- **SKILL.md line 196 — "Do NOT generate an ADR index":** Currently prohibits ADR index at `docs/decisions/README.md` because "ADR discovery is handled by inline links in `docs/README.md`". Our change creates `docs/decisions.md` as exactly such an index. **This rule must be rewritten** to reflect that `docs/decisions.md` is now the canonical ADR index and `docs/decisions/README.md` remains prohibited.
- **SKILL.md line 220 — "single entry point ... merges architecture overview and capabilities":** This describes the monolithic README pattern we're dissolving. Must be rewritten to describe the hub pattern.
- **SKILL.md line 240 (Step 6 cleanup):** Cleanup text says "ADR discovery is now via inline links in `docs/README.md`". Must update to reference `docs/decisions.md`.
- **SKILL.md line 3 — description:** Says "consolidated README with architecture overview". Must reflect 3-file structure.
- **SKILL.md lines 248-258 — Output template:** Only references `docs/README.md` status. Must add `docs/architecture.md` and `docs/decisions.md` status lines.
- **SKILL.md line 310 — Guardrails:** References "consolidated README". Must be updated.
- **architecture-docs spec line 96:** Says "SHALL NOT generate a separate `docs/decisions/README.md` file". Our delta spec replaces this with the hub pattern. Baseline updated via sync.
- **decision-docs "no ADR index" rule:** SKILL.md line 196 prohibits ADR index. Now addressed by new `decision-docs` delta spec that defines `docs/decisions.md` as the canonical ADR discovery index while still prohibiting `docs/decisions/README.md`.
- **SKILL.md Step 5 restructure:** Step 5 currently generates one file. Splitting into 3 sub-steps changes the flow. Step 5 remains "Step 5" with sub-steps 5a/5b/5c — the step number doesn't change.
- **Discover skill change:** Additive only — new sub-step in Step 2. Existing behavior preserved when `docs/decisions.md` doesn't exist.
- **Research template change:** New optional section added before "Current State". Existing research.md files are unaffected (section is optional).
- **Schema instruction change:** Additive guidance text. Does not break existing behavior.

## D. Constitution Check

No constitution updates needed. The three-layer architecture is unchanged. No new technologies, patterns, or conventions introduced. The "README accuracy" convention still applies — the README hub will reflect current state.

## E. Duplication & Consistency

- **No duplication:** Architecture content lives in `docs/architecture.md` only (not duplicated in README hub). Decisions content lives in `docs/decisions.md` only.
- **Consistency with decision-docs spec:** The decision-docs spec (line 196 of SKILL.md) says "Do NOT generate `docs/decisions/README.md`". The new `docs/decisions.md` is in the parent directory, not `docs/decisions/README.md` — consistent.
- **Consistency with existing cleanup rules:** Step 6 deletes `docs/architecture-overview.md` and `docs/decisions/README.md`. These rules remain valid. No conflict with new files.
- **Spec overlap check:** architecture-docs spec now owns three output files (architecture.md, decisions.md, README.md hub). The Key Design Decisions content moved from "Generate Architecture Overview" requirement to new "Generate Decisions Index" requirement — clean separation.

## F. Assumption Audit

### From specs

| Assumption | Tag | Rating |
|-----------|-----|--------|
| Constitution maintained by archive workflow | Constitution maintained | Acceptable Risk — constitution is project convention, enforced by workflow |
| SKILL.md step ordering guarantees ADR before decisions.md | Step ordering | Acceptable Risk — SKILL.md is the authoritative step sequence |
| Templates created as part of this change | Templates created | Acceptable Risk — templates are implementation tasks in this change |
| Change workspace exists before /opsx:discover | Change workspace exists | Acceptable Risk — same assumption as existing spec |
| User answers before ff | User answers before ff | Acceptable Risk — same assumption as existing spec |
| Heuristic detection | Heuristic detection | Acceptable Risk — same assumption as existing spec |
| Question limit sufficient | Question limit sufficient | Acceptable Risk — same assumption as existing spec |
| decisions.md generated by docs skill | decisions.md generated | Acceptable Risk — this change creates it |

### From design

| Assumption | Tag | Rating |
|-----------|-----|--------|
| Sub-step flags are in-memory booleans | Sub-step flags | Acceptable Risk — skill runs as single agent session, flags don't need persistence |
| Keyword matching sufficient for ADR relevance | Keyword matching sufficient | Acceptable Risk — false negatives = same as today; false positives = low cost |

## G. Review Marker Audit

Scanned all spec and design files for `<!-- REVIEW -->` and `<!-- REVIEW: ... -->` markers.

**Result:** No REVIEW markers found. All files clean.

## Verdict: PASS
