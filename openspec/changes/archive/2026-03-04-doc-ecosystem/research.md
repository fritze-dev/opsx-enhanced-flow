# Research: Documentation Ecosystem

## 1. Current State

`/opsx:docs` (skill at `skills/docs/SKILL.md`) currently reads **only** baseline specs at `openspec/specs/*/spec.md` to generate user-facing capability docs at `docs/capabilities/*.md`. Five archived artifact types (proposal, research, design, preflight, tasks) and the constitution are unused for documentation — valuable context about *why* capabilities exist, what alternatives were considered, and what limitations apply is locked in archives.

**Current docs skill steps:**
1. Discover specs (glob `openspec/specs/*/spec.md`)
2. Extract features (user stories, requirements, scenarios, edge cases)
3. Generate `docs/capabilities/<capability>.md` (overview, features, behavior, edge cases)
4. Update `docs/README.md` (table of contents)
5. Confirm

**Current output template sections:** Overview, Features, Behavior, Edge Cases — all derived from spec content only.

**Existing capability spec:** `openspec/specs/docs-generation/spec.md` covers both `/opsx:docs` and `/opsx:changelog` in two requirements.

**Archive structure available for enrichment:**
```
openspec/changes/archive/YYYY-MM-DD-<name>/
├── proposal.md     → "## Why" (motivation), "## Capabilities" (new/modified mapping)
├── research.md     → Approaches, Decisions, Open Questions
├── design.md       → Context, Decisions table, Non-Goals, Risks & Trade-offs
├── preflight.md    → Gap Analysis, Side-Effect Analysis, Assumption Audit
├── tasks.md        → Implementation-internal (excluded from docs)
└── specs/*/spec.md → Delta specs (already merged into baseline)
```

**5 archived changes exist:** initial-spec, fix-init-skill, fix-workflow-friction, final-verify-step, release-workflow.

**Key observation:** `proposal.md` Capabilities section consistently uses `- \`capability-name\`: description` format under `### New Capabilities` / `### Modified Capabilities`, enabling reliable parsing for the Capability-to-Change Index.

## 2. External Research

**Architecture Decision Records (ADRs):**
- Standard format from Michael Nygard: Status, Context, Decision, Consequences
- Commonly stored as `docs/decisions/adr-NNN-title.md` with sequential numbering
- Design.md `## Decisions` tables map directly: each row becomes one ADR

**Research Logs:**
- Less standardized than ADRs — per-change narrative documenting discovery context
- Useful for onboarding and "why did we do it this way?" questions
- research.md already captures: approaches evaluated, decisions made, open questions

**Keep a Changelog (existing pattern):**
- `/opsx:changelog` already follows this format — no changes needed there

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Enrich `/opsx:docs` with all tiers (chosen) | Single entry point, no skill proliferation, one run generates everything | Longer skill prompt (~300 lines), more complex single skill |
| Separate skills per tier (`/opsx:adr`, `/opsx:research-log`) | Clean separation of concerns | 2 new skills to maintain, user must remember multiple commands, violates user preference |
| Enrich docs only (Tier 1), defer ADR + research log | Smaller scope, faster delivery | Loses valuable ADR and research log output, multiple changes needed |

## 4. Risks & Constraints

| Risk | Impact | Mitigation |
|------|--------|------------|
| Skill prompt length increases (~150 → ~300 lines) | Low | Clear section headers, concise instruction language — within normal SKILL.md range |
| `initial-spec` proposal "Why" is about bootstrapping, not individual capabilities | Medium | Special handling: for capabilities whose only archive is initial-spec, derive "Why This Exists" from spec Purpose instead of proposal |
| Archives missing specific artifacts (e.g., fix-init-skill has no design.md) | Low | Graceful fallback: skip missing artifacts, omit sections with no data |
| ADR numbering shifts if archives are reordered | Low | ADRs are fully regenerated each run — numbering is deterministic from chronological sort |
| Capability-to-Change mapping is many-to-many (initial-spec created 15 capabilities) | Medium | Index handles it: one archive maps to multiple capabilities, one capability can appear in multiple archives |

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Three tiers defined: enriched capability docs, ADRs, research log — all in `/opsx:docs` |
| Behavior | Clear | New steps + enriched template well-defined in Issue #8 and approved plan |
| Data Model | Clear | Archive artifacts are the source; output is Markdown files in `docs/` |
| UX | Clear | No new commands — `/opsx:docs` gains richer output automatically |
| Integration | Clear | Reads existing archives + specs, writes to `docs/` — no new dependencies |
| Edge Cases | Clear | Missing artifacts → omit section, no archives → current behavior, initial-spec → use spec Purpose |
| Constraints | Clear | Skill immutability rule satisfied — this IS a spec'd change to the skill itself |
| Terminology | Clear | ADR, Capability-to-Change Index, Research Log — all defined in Issue #8 |
| Non-Functional | Clear | File-based reads/writes only, no performance concerns |

## 6. Open Questions

All categories are Clear. No open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Consolidate all three tiers into `/opsx:docs` | User preference, avoids skill proliferation, single entry point | Separate `/opsx:adr` + `/opsx:research-log` skills (rejected) |
| 2 | No subcommand flags — full regeneration always | Regeneration is fast (file reads + writes), keeps skill simple | `--adr`, `--research` flags (unnecessary complexity) |
| 3 | ADR numbering is global sequential, fully regenerated each run | Deterministic, reproducible, standard ADR convention | Per-archive numbering (non-standard), incremental (requires state) |
| 4 | "Why This Exists" uses newest archive's proposal | Most current motivation; older motivations may be superseded | Concatenate all (too verbose), oldest only (may be outdated) |
| 5 | For initial-spec-only capabilities, use spec Purpose instead of proposal Why | initial-spec proposal is about bootstrapping, not individual capabilities | Use proposal anyway (misleading context) |
| 6 | Research log is per-change, not per-capability | Research is conducted at change level; per-capability would fragment narrative | Per-capability (loses coherence) |
