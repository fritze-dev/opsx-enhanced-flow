---
title: "Spec Sync"
capability: "spec-sync"
description: "Intelligent agent-driven merging of delta specs into baselines with partial update support"
order: 13
lastUpdated: "2026-03-04"
---

# Spec Sync

Merge your change's delta specs into baseline specs with `/opsx:sync`. The merge is performed by an AI agent that understands the semantic intent of each operation, producing coherent, well-structured baselines.

## Features

- Agent-driven intelligent merging — not mechanical find-and-replace
- Support for ADDED, MODIFIED, REMOVED, and RENAMED operations
- Intelligent partial updates — add a scenario to an existing requirement without copying the entire requirement
- Automatic baseline format enforcement — clean output without delta operation markers
- New baseline creation when a capability has no prior specs

## Behavior

### Agent-Driven Merging

When you run `/opsx:sync`, the AI agent reads both the delta spec and the current baseline, understands the semantic intent of each operation, and produces a coherent merged result. ADDED requirements are appended, MODIFIED requirements are replaced with updated content, and REMOVED requirements are deleted. If no baseline exists for a capability, one is created from the delta content.

### Intelligent Partial Updates

You can add individual scenarios, edge cases, or assumptions to existing requirements without copying the entire requirement block into the delta. When a delta adds a new scenario to an existing requirement, the agent locates that requirement in the baseline and appends the scenario without disturbing existing content. Conflicts are resolved by preferring the delta's intent while preserving baseline content the delta does not address.

### Baseline Format Enforcement

After sync, all baselines conform to a clean format: a Purpose section followed by a Requirements section. Delta operation prefixes (ADDED, MODIFIED, etc.) are stripped during merge. Each requirement maintains the standard ordering: header, normative description, optional User Story, and scenario blocks.

## Edge Cases

- If two changes modify the same requirement differently, the agent flags the conflict and asks you to resolve it rather than silently overwriting.
- If a delta spec contains empty sections (e.g., MODIFIED with no content), the agent ignores them and does not alter the baseline.
- If a delta has MODIFIED operations but the baseline does not exist, the agent treats this as an error and reports it.
- If a requirement is renamed, other specs referencing the old name are not automatically updated — the agent warns about potential stale references.
- If two changes in flight modify the same capability, the second sync detects that the baseline has changed since the delta was authored and prompts for re-review.
