# Technical Design: Design Review Checkpoint

## Context

The `/opsx:ff` command currently generates all 6 pipeline artifacts without pausing. Issue #9 reports that users need a review checkpoint after design — the point where approach and architecture decisions are finalized — before the system proceeds to preflight and tasks. The fix is a constitution convention (not a skill change), since the constitution is loaded into every AI prompt and agents are required to follow it.

## Architecture & Components

Four files affected across three layers:

| Layer | File | Change |
|-------|------|--------|
| Constitution | `openspec/constitution.md` | Add "Design review checkpoint" convention |
| Spec | `openspec/specs/artifact-generation/spec.md` | Merge delta spec: updated ff requirement + new scenarios |
| Docs | `docs/capabilities/artifact-generation.md` | Update ff behavior description, add Review Checkpoint subsection |
| Docs | `README.md` | Update Quick Start, Feature Cycle, Workflow Principles |

**Not affected:** `skills/ff/SKILL.md` (skill immutability), `openspec/schemas/opsx-enhanced/schema.yaml` (no pipeline changes).

**How it works:** The constitution convention instructs the agent to pause after design in any workflow that generates multiple artifacts. Since the constitution is injected via `config.yaml` into every prompt, all agents — including ff — will follow this rule without skill code changes.

## Goals & Success Metrics

* Constitution contains "Design review checkpoint" convention — PASS/FAIL
* Artifact-generation spec describes two-phase ff behavior with review checkpoint — PASS/FAIL
* All Gherkin scenarios cover: fresh run, partial resume, resume past design, all done — PASS/FAIL
* README and capability docs reflect the two-phase ff behavior — PASS/FAIL
* `skills/ff/SKILL.md` is NOT modified — PASS/FAIL

## Non-Goals

- Modifying the ff skill file
- Modifying the schema or artifact pipeline order
- Changing `/opsx:continue` behavior (already pauses after every artifact)
- Adding hard enforcement mechanisms beyond constitution convention

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Constitution convention only | Respects skill immutability; constitution is always loaded and authoritative | Skill modification (violates architecture), schema checkpoint (over-engineering) |
| Checkpoint after design specifically | Design finalizes approach/architecture — last point where feedback is cheap before quality gates | After specs (too early, design not done), after preflight (too late, already invested in quality review) |
| Skip checkpoint when preflight already done | Avoids unnecessary friction on resume; preflight existence implies prior design review | Always checkpoint (annoying for resume cases) |
| Update constitution before spec | Constitution establishes the governance rule; spec formalizes the behavioral change | Spec first (would lack governance backing) |

## Risks & Trade-offs

- **Soft enforcement only** — The constitution convention relies on agent compliance, not hard code enforcement. Mitigated by: constitution is injected into every prompt via config.yaml, and agents are instructed to always read and follow it.
- **Spec text contradiction during transition** — Until the delta spec is archived, the baseline spec says "without pausing." Mitigated by: delta spec takes precedence during active change, and archiving resolves the contradiction.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
