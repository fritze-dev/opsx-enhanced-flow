## Why

The workflow has inconsistent pausing: too much at routine transitions, too little at critical checkpoints. Preflight warnings are auto-accepted without review (#16), `/opsx:continue` pauses after every artifact even when the next step is obvious (#40), and `/opsx:sync` can run before `/opsx:verify` (#26). These three issues share a root cause: no defined checkpoint model distinguishing routine from critical transitions.

## What Changes

- Define a checkpoint model in the constitution classifying each transition as `auto-continue` or `mandatory-pause`
- Update `/opsx:continue` and `/opsx:ff` skills to respect the checkpoint model (auto-continue through routine transitions, pause at critical ones)
- Add mandatory pause for preflight PASS WITH WARNINGS (require explicit user acknowledgment)
- Enforce verify-before-sync ordering in the apply instruction and constitution
- Update quality-gates spec to require mandatory pause on preflight warnings
- Update artifact-generation spec to document checkpoint behavior for continue/ff

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `quality-gates`: Add mandatory pause requirement for PASS WITH WARNINGS verdict
- `artifact-generation`: Document checkpoint model — which transitions auto-continue vs mandatory-pause for continue and ff skills

## Impact

- `openspec/constitution.md` — checkpoint model definition + verify-before-sync convention
- `openspec/schemas/opsx-enhanced/schema.yaml` — apply instruction update (verify-before-sync ordering)
- `skills/continue/SKILL.md` — auto-continue through routine transitions
- `skills/ff/SKILL.md` — mandatory pause on preflight warnings
- `openspec/specs/quality-gates/spec.md` — mandatory pause requirement
- `openspec/specs/artifact-generation/spec.md` — checkpoint model documentation

## Scope & Boundaries

**In scope:**
- Checkpoint model definition (constitution)
- Skill instruction updates (continue, ff)
- Spec updates (quality-gates, artifact-generation)
- Apply instruction update (verify-before-sync)

**Out of scope:**
- CLI code changes or hard enforcement in OpenSpec CLI
- Archive skill changes (approval gate already works)
- Verify skill changes (verify itself is correct)
- Sync skill changes (sync itself is correct)
