# Research: Design Review Checkpoint

## 1. Current State

The `/opsx:ff` skill ([SKILL.md](skills/ff/SKILL.md)) generates all 6 pipeline artifacts (research → proposal → specs → design → preflight → tasks) in a single uninterrupted loop. There is no built-in pause point for user review between stages.

**Affected files:**
- `openspec/constitution.md` — governance layer, `## Conventions` section (currently 4 conventions)
- `openspec/specs/artifact-generation/spec.md` — formal requirement for ff behavior (lines 27–50)
- `docs/capabilities/artifact-generation.md` — user-facing docs for ff
- `README.md` — Quick Start (line 78), Feature Cycle table (line 216), Workflow Principles (line 190)
- `skills/ff/SKILL.md` — **NOT to be modified** (skill immutability rule in constitution)

**Existing review mechanisms:**
- `/opsx:continue` already pauses after every artifact (natural checkpoint)
- `/opsx:preflight` is a mandatory quality gate but only fires after all artifacts are generated
- `/opsx:verify` + explicit "Approved" gate exists post-implementation
- The constitution is loaded into every AI prompt via `config.yaml`, so conventions are authoritative

**Relevant architecture rules:**
- Three-layer architecture: Constitution → Schema → Skills
- Skill immutability: Skills MUST NOT be modified for project-specific behavior
- Constitution conventions are followed by all agents at every step

## 2. External Research

Not applicable — this is an internal workflow change with no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Constitution convention only | Respects skill immutability; agents read constitution at every step; single source of truth | Depends on agent compliance — no hard enforcement in skill code |
| B: Constitution + skill modification | Hard enforcement in the loop logic | Violates skill immutability rule; creates project-specific skill fork |
| C: Schema-level checkpoint | Universal enforcement via artifact pipeline | Over-engineering — schema defines artifact order, not interaction pauses |

**Selected: Approach A** — Constitution convention only, with spec/docs alignment. The constitution is authoritative and always loaded. No skill changes needed.

## 4. Risks & Constraints

- **Agent compliance risk (low):** An agent could theoretically ignore the constitution convention. Mitigated by the fact that the constitution is injected into every prompt via `config.yaml` and agents are instructed to follow it.
- **Spec drift risk (low):** The artifact-generation spec currently says ff runs "without pausing between stages." This must be updated to avoid contradiction.
- **No breaking changes:** This is additive — a new convention plus spec/doc updates.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Constitution convention + spec + docs update, no skill changes |
| Behavior | Clear | Pause after design, continue after user confirms alignment |
| Data Model | Clear | No data model changes — text artifacts only |
| UX | Clear | Agent presents review summary, asks for alignment via AskUserQuestion |
| Integration | Clear | Constitution is already loaded via config.yaml — no integration work |
| Edge Cases | Clear | Resume scenarios (design done, preflight done, all done) |
| Constraints | Clear | Skill immutability respected |
| Terminology | Clear | "Design review checkpoint" is self-explanatory |
| Non-Functional | Clear | No performance impact |

All categories are Clear — no open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Constitution convention only, no skill changes | Respects skill immutability; constitution is always loaded and authoritative | Skill modification (rejected: violates architecture rule), schema change (rejected: over-engineering) |
| 2 | Checkpoint triggers after design artifact | Design is where approach/architecture decisions are finalized — the last point where feedback is cheap | After specs (too early), after preflight (too late) |
| 3 | Skip checkpoint when preflight already done | If user resumes ff past design, they already reviewed | Always checkpoint (unnecessary friction for resume case) |
