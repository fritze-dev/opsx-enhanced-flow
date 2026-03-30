# Research: Fix Docs Regeneration Quality

## 1. Current State

The `/opsx:docs` skill (`skills/docs/SKILL.md`) generates three types of documentation: capability docs (Step 3), ADRs (Step 4), and a consolidated README (Step 5). Two quality regressions were observed during a full QA cycle (delete all docs → regenerate → diff):

**Affected files:**
- `skills/docs/SKILL.md` — Primary skill definition (220 lines)
- `openspec/specs/user-docs/spec.md` — Capability doc generation spec (165 lines)
- `openspec/specs/decision-docs/spec.md` — ADR generation spec (152 lines)
- `openspec/schemas/opsx-enhanced/templates/docs/adr.md` — ADR template (59 lines)
- `openspec/schemas/opsx-enhanced/templates/docs/capability.md` — Capability doc template (101 lines)

**Regression 1 — ADR thin contexts (GitHub Issue #28):**
Step 4 (ADR generation, SKILL.md lines 98–135) instructs the agent to "generate formal ADRs from `## Decisions` tables across all archived `design.md` files." The Discovery paragraph (line 106) reads only `design.md` and only extracts the Decisions table. The ADR template comment (line 13 of adr.md) says "Enrich with research.md" — but template comments are format guidance, not actionable read instructions.

When Step 4 runs in the same context as Step 2, it implicitly benefits from data already loaded (research.md, proposal.md, full design.md). When Step 4 runs in a subagent, this data is missing. Result: ADR Context sections lose ~50% length and 30-60% of References.

**Regression 2 — Dropped capability doc sections (GitHub Issue #29):**
Step 3 (capability doc generation, SKILL.md lines 60–96) has a "space-constrained" priority rule at line 82:
```
Priority when space-constrained: Features + Behavior (mandatory) > Purpose (preferred) > Rationale + Limitations + Future Enhancements (optional)
```
This marks Known Limitations and Future Enhancements as `(optional)`, giving the agent permission to drop them. 9 of 18 docs lost Known Limitations, 6 lost Future Enhancements. No capability doc exceeds 1.3 pages — the space constraint doesn't exist. The per-section max limits (Purpose max 3, Limitations max 5 bullets, etc.) are sufficient conciseness guards.

**Spec-to-code alignment check:**
- `user-docs/spec.md` lines 17-18 specify Known Limitations and Future Enhancements derivation rules but don't address the priority rule. The spec doesn't say sections are optional — the SKILL.md added this independently. → Spec is correct, SKILL.md contradicts it.
- `decision-docs/spec.md` line 20 specifies Context enrichment from `design.md Context section` and `research.md Approaches` — but SKILL.md Step 4 never instructs reading these. → Spec is correct, SKILL.md underspecifies the reads.

## 2. External Research

Not applicable — this is an internal skill fix with no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Fix SKILL.md only (priority rule + enrichment + guardrail) | Minimal change, addresses both root causes directly | Specs already describe correct behavior — no spec delta needed, but convention requires spec changes to go through flow |
| B: Fix SKILL.md + delta specs for user-docs and decision-docs | Keeps specs and skill aligned, documents the fix formally | Specs already say the right thing — delta changes would be reinforcement, not new requirements |
| C: Fix SKILL.md + restructure into per-step subagent instructions | Each step becomes a fully self-contained unit with its own read instructions — robust for autonomous agent execution | Currently only Step 4 has this problem; restructuring all steps adds scope without immediate benefit |

**Recommended: Approach A with spec reinforcement.**
The specs already describe the correct behavior, but adding explicit "step independence" language to both specs reinforces the requirement. The SKILL.md is the primary fix surface. Currently only Step 4 suffers from the implicit dependency — Step 3's regression has a different root cause (the priority rule, not missing data).

**Fallback / Future Enhancement:** If Approach A proves insufficient (e.g., other steps develop similar subagent regressions), Approach C (full per-step restructure) is the next level. This aligns with the planned transition to autonomous agents, where each step must be fully self-contained. Track as a future enhancement if not needed now.

## 4. Risks & Constraints

- **Low risk — additive changes only:** All changes add instructions or replace a permissive rule with a stricter one. No structural changes to the skill.
- **Template change risk:** Modifying the ADR template comment is cosmetic — it doesn't affect output structure. Low risk.
- **Regression testing:** The verification method (delete all → regenerate → diff) is the same QA cycle that discovered the issues. It's reliable but time-consuming (~37 ADRs + 18 capability docs).
- **No behavioral change for existing docs:** The `read-before-write` guardrail (SKILL.md line 213) means existing docs won't be affected by the priority rule change — only fresh regeneration is impacted.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Two specific regressions with known root causes and proposed fixes |
| Behavior | Clear | Both issues document exact expected vs. actual behavior with evidence |
| Data Model | Clear | No data model changes — only instruction text in SKILL.md and specs |
| UX | Clear | No user-facing UX changes — fixes affect generated doc quality |
| Integration | Clear | Changes are contained within the docs skill, no cross-skill impact |
| Edge Cases | Clear | Issue #29 explicitly notes content depth is deferred — not addressable by rules alone |
| Constraints | Clear | Per-section max limits remain as conciseness guards |
| Terminology | Clear | "Step independence", "enrichment", "section-completeness" are self-explanatory |
| Non-Functional | Clear | No performance impact — adding read instructions adds minimal overhead |

All categories are Clear. No open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Handle both issues in a single change | Both modify SKILL.md, share the step independence guardrail, and are the same class of bug (implicit step dependencies) | Separate changes — rejected because the shared guardrail creates a merge conflict |
| 2 | Replace priority rule rather than remove it | A section-completeness rule provides positive guidance ("include when data exists") vs. the current negative guidance ("drop when constrained") | Just removing the line — rejected because it leaves no guidance at all |
| 3 | Add explicit enrichment reads to Step 4 rather than restructuring all steps | Only Step 4 has the implicit dependency problem — making it self-contained is sufficient. Full per-step restructure is a valid fallback if this fix proves insufficient, and aligns with the planned autonomous agent transition. | Full restructure into per-step subagent instructions — deferred as future enhancement (autonomous agent readiness) |
| 4 | Reinforce specs even though they already describe correct behavior | Keeps specs and skill explicitly aligned. Adding step independence language to specs prevents future drift. | Skip spec changes — rejected because the convention requires changes go through the spec flow |
