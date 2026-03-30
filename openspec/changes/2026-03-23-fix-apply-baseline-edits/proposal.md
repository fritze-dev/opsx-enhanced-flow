## Why

During `/opsx:apply`, task lists sometimes include edits to baseline specs (`openspec/specs/`), bypassing the delta-spec-to-sync pipeline. This creates a dual-write pattern where baseline specs are modified both directly during apply AND via `/opsx:sync` at archive time, making sync redundant and undermining the single-path guarantee for spec updates. Observed during the `rename-init-to-setup` change (#43).

## What Changes

- Schema task-generation instruction extended to explicitly exclude baseline spec edits from generated tasks
- Apply skill guardrails extended with a baseline-spec exclusion rule (defense in depth)
- Task-implementation spec gains a new requirement formalizing the exclusion

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `task-implementation`: Add requirement that baseline specs (`openspec/specs/`) are excluded from implementation scope — spec changes flow exclusively through delta specs and `/opsx:sync`

## Impact

- `openspec/schemas/opsx-enhanced/schema.yaml` — task instruction text
- `skills/apply/SKILL.md` — guardrail section
- `openspec/specs/task-implementation/spec.md` — new requirement + scenario

No code logic, no API changes, no dependency changes.

## Scope & Boundaries

**In scope:**
- Task generation instruction update (schema.yaml)
- Apply skill guardrail update (SKILL.md)
- Task-implementation spec update (spec.md)

**Out of scope:**
- Sync skill changes (sync itself is correct)
- Delta spec format changes
- Any runtime/CLI code changes
