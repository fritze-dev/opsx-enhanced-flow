## Why

The `/opsx:ff` command generates all 6 pipeline artifacts without pausing, which means users cannot review specs and design before the system proceeds to preflight and tasks. During real usage (issue #9), a user had to manually interrupt ff to discuss the approach — the workflow should have a natural review checkpoint after design, where approach and architecture decisions are finalized.

## What Changes

- Add a new constitution convention establishing the design phase as the mandatory review checkpoint in every OpenSpec workflow
- Update the artifact-generation spec to reflect that ff pauses after design for user alignment
- Update user-facing documentation (capability docs + README) to describe the two-phase ff behavior

## Capabilities

### New Capabilities

None — this change modifies existing capabilities only.

### Modified Capabilities

- `artifact-generation`: The Fast-Forward Generation requirement changes from "without pausing between stages" to a two-phase model that pauses after design for user review before continuing to preflight and tasks

## Impact

- `openspec/constitution.md` — new convention added
- `openspec/specs/artifact-generation/spec.md` — requirement and scenarios updated
- `docs/capabilities/artifact-generation.md` — behavior description updated
- `README.md` — Quick Start, Feature Cycle, and Workflow Principles updated
- No skill files modified (skill immutability preserved)
- No schema changes

## Scope & Boundaries

**In scope:**
- Constitution convention for design review checkpoint
- Spec update for ff behavior (requirement text + Gherkin scenarios)
- Documentation alignment (capability docs + README)

**Out of scope:**
- Skill file modifications (explicitly excluded per architecture rules)
- Schema changes
- Changes to `/opsx:continue` (already pauses after every artifact)
- Changes to `/opsx:apply`, `/opsx:verify`, or other skills
