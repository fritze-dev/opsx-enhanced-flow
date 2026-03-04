---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "Six-stage pipeline from research to tasks with strict dependency gating"
order: 5
lastUpdated: "2026-03-04"
---

# Artifact Pipeline

The artifact pipeline guides you through six stages — research, proposal, specs, design, preflight, and tasks — ensuring no critical thinking step is skipped and every decision is documented before implementation begins.

## Features

- Structured 6-stage pipeline: research → proposal → specs → design → preflight → tasks
- Strict dependency gating — each stage must complete before the next can begin
- Every stage produces a verifiable artifact file
- Implementation gated by task completion — you cannot start coding until the full analysis cycle is done
- Minimal configuration bootstrap — workflow rules live in the schema, not in config files

## Behavior

### Pipeline Stages

The pipeline enforces a strict order: research first, then proposal, then specs, then design, then preflight, then tasks. You cannot skip stages — each must complete before the next begins. When the full pipeline is complete, the workspace contains research.md, proposal.md, one or more spec files, design.md, preflight.md, and tasks.md.

### Dependency Gating

Each artifact declares its dependencies. The system checks that all required preceding artifacts are complete before allowing the next one to be generated. An artifact is considered complete when its file exists and is non-empty.

### Implementation Gate

Implementation (the apply phase) is gated by completion of the tasks artifact. You cannot start coding until tasks.md exists and is non-empty. During implementation, progress is tracked against the task checklist.

### Configuration Bootstrap

The configuration file serves as a minimal bootstrap — it contains only the schema reference and a pointer to the project constitution. All workflow rules are owned by the schema or the constitution, not by the config file.

### Schema-Owned Workflow Rules

The schema's artifact instructions contain workflow rules that apply to all projects. The tasks instruction includes the Definition of Done rule, and the apply instruction includes the post-apply workflow sequence (`/opsx:verify` → `/opsx:archive` → `/opsx:changelog` → `/opsx:docs` → commit).

## Edge Cases

- If an artifact file exists but is empty (0 bytes), it is treated as incomplete and does not satisfy dependency checks.
- If you manually delete an artifact file mid-pipeline, the system detects the gap and requires regeneration before proceeding.
- If the schema is modified to add a new artifact stage while a change is in progress, the new schema applies to new changes only — in-progress changes continue with the schema version active when they were created.
- If tasks.md contains no checkbox items (e.g., documentation-only change), the apply phase is still gated by tasks.md existence but reports that there are no implementation tasks.
- If multiple spec files are required (one per capability), the specs stage is not considered complete until all capability specs listed in the proposal have been generated.
- If a project has no constitution file, the config pointer is harmless — the system notes the missing file and proceeds.
- Existing projects with workflow rules in the config continue to work — the rules are additive to schema instructions.
