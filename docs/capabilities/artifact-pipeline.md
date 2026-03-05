---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "Defines the schema-driven 6-stage artifact pipeline with strict dependency gating and implementation controls."
lastUpdated: "2026-03-05"
---

# Artifact Pipeline

The artifact pipeline guides every change through six mandatory stages -- research, proposal, specs, design, preflight, and tasks -- enforcing strict dependency order so that no stage is skipped and implementation is gated by complete planning.

## Purpose

Development teams working with AI assistants need a structured process that prevents jumping straight to code without adequate research, design, and quality review. Without enforced stages, critical thinking steps get skipped, decisions go undocumented, and implementation begins before requirements are fully understood. The artifact pipeline provides a schema-driven sequence of mandatory stages that ensures every change is thoroughly analyzed before a single line of code is written.

## Rationale

The pipeline uses a declarative schema rather than hardcoded skill logic so that the workflow structure is transparent and modifiable without touching command code. Each artifact declares its dependencies explicitly, and the OpenSpec CLI enforces these dependencies by checking completion status before allowing generation. The 6-stage design captures the full lifecycle from initial research through implementation-ready tasks, with each stage producing a verifiable file. Config.yaml serves as a minimal bootstrap containing only the schema reference and a constitution pointer, while workflow rules live at their authoritative source -- the schema for universal rules, the constitution for project-specific rules.

## Features

- **Six-Stage Pipeline**: Research, proposal, specs, design, preflight, and tasks execute in strict dependency order. Each stage produces a verifiable artifact file that must be complete (exists and is non-empty) before the next stage can begin.
- **Explicit Dependency Declarations**: Each artifact in the schema declares its dependencies via a `requires` field. The OpenSpec CLI enforces these checks automatically.
- **Apply Gate**: Implementation is gated by the tasks artifact. The apply phase cannot begin until `tasks.md` exists and is non-empty. During apply, progress is tracked against the task checklist.
- **Minimal Config Bootstrap**: The `openspec/config.yaml` file contains only the schema reference and a constitution pointer -- no workflow rules or per-artifact rules entries.
- **Schema-Owned Workflow Rules**: The schema's `tasks.instruction` field contains the Definition of Done rule. The `apply.instruction` field contains the post-apply workflow sequence (`/opsx:verify` then `/opsx:archive` then `/opsx:changelog` then `/opsx:docs` then commit).

## Behavior

### Pipeline Stages Execute in Dependency Order

When progressing through the pipeline, the system enforces the order: research first, then proposal, then specs, then design, then preflight, then tasks. Attempting to skip a stage -- for example, generating specs before completing the proposal -- is rejected with a message indicating which prerequisite artifact must be completed first. A completed pipeline run produces `research.md`, `proposal.md`, one or more `specs/<capability>/spec.md` files, `design.md`, `preflight.md`, and `tasks.md`.

### Dependency Checks Are Enforced Automatically

Before generating any artifact, the system checks that all required predecessor artifacts are complete. An artifact is considered complete when its corresponding file exists and is non-empty. If a dependency check fails, the system reports which artifacts must be completed first. The schema declares these dependencies explicitly so that the enforcement is transparent and inspectable.

### Implementation Is Gated by Task Completion

Invoking `/opsx:apply` before `tasks.md` exists is rejected with a message to generate tasks first. Once all 6 artifacts are complete, apply begins by reading the task checklist from `tasks.md` and working through items sequentially. As each task item is completed, the corresponding checkbox is marked from `- [ ]` to `- [x]`.

### Config Contains Only Bootstrap Content

The `config.yaml` file contains a `schema` field referencing the active schema and a `context` field pointing to the project constitution. It contains no other workflow rules or per-artifact rules entries. All workflow logic resides in the schema's instruction fields or in the constitution.

### Schema Owns Universal Workflow Rules

The `tasks.instruction` field in the schema contains the rule that Definition of Done is emergent from artifacts, referencing Gherkin scenarios, success metrics, preflight findings, and user approval. The `apply.instruction` field contains the post-apply workflow sequence.

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system treats it as incomplete and does not satisfy dependency checks.
- If a user manually deletes an artifact file mid-pipeline, the system detects the gap and requires regeneration before proceeding.
- If the schema is modified to add a new artifact stage while a change is in progress, the new schema applies to new changes only; in-progress changes continue with the schema version that was active when they were created.
- If `tasks.md` contains no checkbox items (e.g., a documentation-only change), the apply phase is still gated by `tasks.md` existence but reports that there are no implementation tasks to execute.
- If multiple spec files are required (one per capability), the specs stage is not considered complete until all capability specs listed in the proposal have been generated.
- If a project has no constitution file, the `config.yaml` context pointer is harmless -- the AI notes the missing file and proceeds.
