# Pre-Flight Check: Fix Docs Skill Quality Regressions

## A. Traceability Matrix

- [x] R1 (Phantom ADR) → Scenario: "Archive with prose-only Decisions section skipped" + "Archive with non-Decisions table skipped" → `skills/docs/SKILL.md` Step 4, `decision-docs` spec
- [x] R2 (Manual ADR lost) → Scenario: "Manual ADRs preserved during regeneration" + "Manual ADR appears in README table" + "Multiple manual ADRs ordered" → `skills/docs/SKILL.md` Steps 4/5/6, `decision-docs` spec (new requirement), `architecture-docs` spec, `docs/decisions/adr-M001-init-model-invocable.md`
- [x] R4 (Slug non-deterministic) → Scenario: "Slug generated deterministically" → `skills/docs/SKILL.md` Step 4, `decision-docs` spec
- [x] R5 (Raw path references) → Scenario: "ADR includes references with semantic link text" → `adr.md` template
- [x] R6 (Verbose descriptions) → Scenario: "Capability descriptions are concise" → `readme.md` template, `architecture-docs` spec
- [x] R8 (Trade-offs reduced) → Scenario: "Trade-offs surfaced comprehensively" → `readme.md` template, `architecture-docs` spec
- [x] R9 (Behavior headers) → Scenario: "Multi-command behavior headers include command names" → `capability.md` template, `user-docs` spec
- [x] R10 (Rationale drift) → Scenario: "Rationale uses present tense without change history" → `capability.md` template, `user-docs` spec
- [x] R11 (Initial-spec Rationale omitted) → Scenario: "Initial-spec-only capability gets Rationale from spec" → `skills/docs/SKILL.md` Step 2, `user-docs` spec

All 9 regressions traced to scenarios and components. No unmapped requirements.

## B. Gap Analysis

- **No gaps found.** Each regression has a specific root cause, a spec scenario, and a targeted fix location. The edge cases cover:
  - Prose-only Decisions sections (R1)
  - Non-Decisions tables in same design.md (R1)
  - Manual ADR with missing sections (R2)
  - Multiple manual ADRs ordering (R2)
  - Slug derivation edge cases with special chars (R4)
- Error handling: Missing artifacts already handled by existing "skip enrichment" guardrails in SKILL.md.

## C. Side-Effect Analysis

- **ADR file renames (R4)**: New slug algorithm changes some filenames (e.g., `opsxsync` → `opsx-sync`). README links regenerate to match → no broken references. Git will show file renames. Accepted trade-off.
- **No regression risk to other skills**: Changes are isolated to `skills/docs/SKILL.md` and doc templates. No other skills read these files.
- **No impact on archive workflow**: Archive artifacts are read-only inputs to the docs skill. This change does not modify archive structure.
- **Existing docs preserved**: The "read before write" guardrail in SKILL.md remains unchanged. Only full regeneration (delete + regenerate) will produce the new output format.

## D. Constitution Check

No constitution changes needed. This change adds guardrails within existing skill/template/spec layers without introducing new patterns, conventions, or architectural rules.

## E. Duplication & Consistency

- **Manual ADR concept appears in three places**: `decision-docs` spec (new requirement + scenarios), `architecture-docs` spec (README table inclusion), `skills/docs/SKILL.md` (execution instructions). All three are consistent on naming convention (`adr-MNNN-slug.md`) and behavior (preserve during regeneration, include in README table).
- **Slug algorithm appears in two places**: `decision-docs` spec (requirement text) and `skills/docs/SKILL.md` (Step 4). Both describe the same 6-step algorithm. No contradiction.
- **Rationale guardrail appears in two places**: `user-docs` spec (requirement text) and `capability.md` template (comment block). Both say: present tense, no change history. No contradiction.
- **No contradictions with existing specs** in `openspec/specs/`. The changes are additive — they add new edge cases and constraints without modifying existing requirement semantics.

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | Archive artifacts follow opsx-enhanced schema templates | decision-docs spec | Acceptable Risk | Archives are created by schema-driven workflow; format is enforced |
| 2 | ADR template at templates/docs/adr.md defines output structure | decision-docs spec | Acceptable Risk | Template exists and is read by agent at generation time |
| 3 | Baseline specs are source of truth for docs generation | user-docs spec | Acceptable Risk | Established convention; docs generated after sync |
| 4 | Archives follow YYYY-MM-DD naming | user-docs spec | Acceptable Risk | Enforced by archive skill |
| 5 | initial-spec proposal "Why" describes spec creation, not capability motivations | user-docs spec | Acceptable Risk | Verified by reading initial-spec archive content |
| 6 | Doc templates available after /opsx:init copies schema | user-docs spec | Acceptable Risk | Schema copy includes subdirectories |
| 7 | Constitution maintained by archive workflow | architecture-docs spec | Acceptable Risk | Established convention |
| 8 | README template defines output structure | architecture-docs spec | Acceptable Risk | Template exists and is read by agent |
| 9 | Lost ADR content recoverable from git history (commit 3689c3e) | design.md | Acceptable Risk | Verified — content retrieved successfully |
| 10 | SKILL.md is primary instruction source at runtime | design.md | Acceptable Risk | Based on observed skill execution pattern |

All assumptions rated Acceptable Risk. No Needs Clarification or Blocking items.
