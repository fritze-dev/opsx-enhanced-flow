---
title: "Spec Sync"
capability: "spec-sync"
description: "Handles agent-driven merging of delta specs from completed changes into baseline specs, with intelligent partial updates and baseline format enforcement."
lastUpdated: "2026-03-05"
---

# Spec Sync

Merges delta specs from completed changes into baseline specs using AI-driven interpretation, keeping the project's authoritative spec library up to date after every change.

## Purpose

After a change is completed, its delta specs describe what was added, modified, or removed -- but the baseline specs still reflect the previous state. Without a reliable merge process, baselines go stale and lose their value as the authoritative reference for how the system works. Spec Sync bridges this gap by intelligently merging deltas into baselines, producing clean, well-structured results that a mechanical find-and-replace approach cannot achieve.

## Rationale

The merge is agent-driven (performed by the AI rather than a script) because delta specs express semantic intent -- adding a scenario, refining a constraint, removing a deprecated requirement -- that requires contextual understanding to merge correctly. Partial updates are supported so that delta specs stay minimal: you can add a single scenario to an existing requirement without copying the entire requirement block. After every sync, baselines are enforced to follow a clean format (Purpose + Requirements) with no leftover delta operation markers, ensuring they remain readable and authoritative.

## Features

- **Agent-driven merging** via `/opsx:sync` -- the AI reads both the delta and the baseline, understands the intent, and produces a coherent merged result.
- **Intelligent partial updates** -- add a scenario, edge case, or constraint to an existing requirement without duplicating the full requirement in the delta.
- **Baseline format enforcement** -- merged baselines always follow the standard format with no delta operation prefixes (ADDED, MODIFIED, REMOVED, RENAMED) left behind.
- **New baseline creation** -- if no baseline exists for a capability, one is created from the delta content.

## Behavior

### Merging Delta Specs into Baselines

When you run `/opsx:sync`, the system processes each delta spec from the completed change. For each capability:

- **ADDED requirements** are appended to the baseline's Requirements section without duplicating existing content.
- **MODIFIED requirements** replace the corresponding baseline requirement with the updated version, preserving all unmodified requirements.
- **REMOVED requirements** are deleted from the baseline, with a confirmation in the output.
- **New capabilities** (no existing baseline) get a fresh baseline created from the delta content, starting with a Purpose section and followed by Requirements.

### Partial Updates Without Full Copies

You do not need to copy an entire requirement into a delta just to add one scenario. If a delta references an existing requirement and adds only a new scenario, the system locates that requirement in the baseline and appends the scenario while preserving everything else. The same applies to edge cases and constraint refinements -- the delta expresses only what changed, and the system integrates it naturally.

### Baseline Format Enforcement

After merging, every baseline follows the standard format: a `## Purpose` section, then a `## Requirements` section with each requirement in strict order (header, normative description, optional user story, scenarios). All delta operation prefixes (ADDED, MODIFIED, etc.) are stripped from section headers. The result is a clean, readable spec that serves as the authoritative reference.

## Known Limitations

- Does not support concurrent sync operations; only one sync runs at a time.
- If a requirement is renamed, other documents referencing the old name are not automatically updated. The system warns about potential stale references.

## Edge Cases

- If two changes modify the same requirement differently, the system flags the conflict and asks you to resolve it rather than silently overwriting.
- If a delta section (e.g., MODIFIED Requirements) is empty, the system ignores it and does not alter the baseline.
- If a delta contains MODIFIED operations for a capability that has no existing baseline, the system reports an error.
- If the baseline has changed since the delta was authored (e.g., a concurrent change was synced first), the system detects the discrepancy and prompts for re-review.
