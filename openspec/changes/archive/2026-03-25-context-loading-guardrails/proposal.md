# Proposal: Context Loading Guardrails

## Why

Claude has no guidance on which artifacts to prioritize or skip during the research phase. Without guardrails, it may load archived changes (~13k lines) or capability docs that duplicate baseline specs — wasting context window. Issue #17 asked for ADR awareness in discovery; PR #52 tried a complex approach (29 files). This solves it minimally by adding context-loading guidance directly to the schema research instruction.

## What Changes

- **Enrich the schema research instruction** with context-loading guardrails: what to read (specs, docs/README.md), what to consult conditionally (ADRs via README index), and what to skip (archive, capability docs)

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None — this is a schema instruction enrichment, not a requirement-level change.

## Impact

- `openspec/schemas/opsx-enhanced/schema.yaml` — Research instruction enrichment (~5 lines)

## Scope & Boundaries

**In scope:**
- Schema research instruction enrichment with context-loading guidance

**Out of scope:**
- Constitution changes
- Template changes
- Skill modifications
- Hard enforcement / runtime validation
