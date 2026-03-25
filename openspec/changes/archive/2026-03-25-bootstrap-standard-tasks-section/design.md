# Technical Design: Bootstrap Standard Tasks Section

## Context

The standard-tasks feature (#12) added a two-layer system: universal steps in the schema template + project-specific extras in the constitution's `## Standard Tasks` section. The bootstrap template in `skills/bootstrap/SKILL.md` generates the constitution but omits this section, leaving new projects unaware of the feature.

## Architecture & Components

Two files affected:

1. **`skills/bootstrap/SKILL.md`** (lines 47–64) — The markdown template in Step 2 that defines which sections the generated constitution contains. Add `## Standard Tasks` with an HTML comment after the `## Conventions` section.

2. **`openspec/specs/constitution-management/spec.md`** — The "Constitution Contains Only Project-Specific Rules" requirement lists retained sections. Add Standard Tasks to this list.

No constitution update needed — no new technologies or architectural patterns introduced.

## Goals & Success Metrics

* The bootstrap SKILL.md template includes a `## Standard Tasks` section after `## Conventions`
* The `constitution-management` spec lists Standard Tasks as a retained section
* The Standard Tasks section contains only an HTML comment (no invented content)

## Non-Goals

* Backfilling `## Standard Tasks` into existing constitutions
* Changing re-run/recovery mode behavior
* Modifying the schema template or task generation logic

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Place `## Standard Tasks` after `## Conventions` | Logical grouping — conventions define patterns, standard tasks define post-implementation workflow | Place before Conventions (rejected: less intuitive ordering) |
| Use HTML comment matching the issue description | Clearly explains the feature's purpose and relationship to schema template | Use a placeholder item (rejected: bootstrap should not invent rules) |

## Risks & Trade-offs

No significant risks. This is a two-line template addition and a spec text update.

## Open Questions

No open questions.

## Assumptions

No assumptions made.
