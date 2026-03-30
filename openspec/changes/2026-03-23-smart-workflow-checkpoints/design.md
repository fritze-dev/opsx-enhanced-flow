# Technical Design: Smart Workflow Checkpoints

## Context

The workflow lacks a clear checkpoint model. Three sub-problems: (1) preflight warnings auto-accepted (#16), (2) unnecessary pausing at routine transitions (#40), (3) verify runs after sync instead of before (#26). All share a root cause: no distinction between routine and critical transitions.

## Architecture & Components

**Checkpoint model** defined in constitution, respected by skills:

| Transition | Type | Rationale |
|---|---|---|
| research → proposal | auto-continue | Routine, no user decision needed |
| proposal → specs | auto-continue | Routine, specs follow from proposal |
| specs → design | auto-continue | Routine, design follows from specs |
| **design → preflight** | **mandatory-pause** | Design review checkpoint (existing) |
| preflight (PASS) → tasks | auto-continue | No issues, safe to proceed |
| **preflight (WARNINGS) → tasks** | **mandatory-pause** | User must review and acknowledge warnings |
| preflight (BLOCKED) → tasks | blocked | Cannot proceed (already enforced) |
| **discovery Q&A** | **mandatory-pause** | User input explicitly needed (existing) |

**Post-apply ordering** enforced via constitution + apply instruction:

```
/opsx:apply → /opsx:verify → /opsx:sync (via archive) → /opsx:archive
```

Never: `/opsx:sync` before `/opsx:verify`.

**Files to modify:**

1. **`openspec/constitution.md`** — Add checkpoint model definition + verify-before-sync convention
2. **`openspec/schemas/opsx-enhanced/schema.yaml`** — Update apply instruction to enforce verify-before-sync
3. **`skills/continue/SKILL.md`** — Add auto-continue behavior for routine transitions
4. **`skills/ff/SKILL.md`** — Add mandatory pause on preflight warnings
5. **`openspec/specs/quality-gates/spec.md`** — Mandatory pause for PASS WITH WARNINGS
6. **`openspec/specs/artifact-generation/spec.md`** — Document checkpoint model in continue/ff specs

## Goals & Success Metrics

* Constitution contains checkpoint model classifying each transition as auto-continue or mandatory-pause
* Continue skill auto-continues through routine transitions without pausing
* FF skill pauses on preflight PASS WITH WARNINGS and requires user acknowledgment
* Apply instruction enforces verify-before-sync ordering
* Quality-gates spec requires mandatory pause on warnings
* Artifact-generation spec documents checkpoint behavior

## Non-Goals

- CLI-level enforcement (hard gates in OpenSpec CLI code)
- Archive skill changes (approval gate already works)
- Verify or sync skill changes (both are correct as-is)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Checkpoint model in constitution | Injected into every prompt, authoritative per ADR-006 | Schema metadata (too rigid), skill-only (scattered) |
| Auto-continue as default, mandatory-pause as exception | Reduces friction; only pause when user input is genuinely needed | Pause everywhere (current), never pause (unsafe) |
| Verify-before-sync in constitution + apply instruction | Two enforcement points; constitution is authoritative, apply instruction is contextual | Sync skill guard (violates skill immutability) |
| Preflight warnings as mandatory pause | Warnings were auto-accepted causing downstream issues | Auto-continue with warnings (broken status quo) |

## Risks & Trade-offs

- **Risk: Agent ignores checkpoint model** → Mitigation: Constitution is injected into every prompt + skill instructions reinforce the model
- **Risk: Auto-continue too aggressive** → Mitigation: Only applies to 4 clearly routine transitions; design and preflight-warnings remain mandatory pauses

## Open Questions

No open questions.

## Assumptions

No assumptions made.
