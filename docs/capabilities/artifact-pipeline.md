---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "6-stage pipeline (research through tasks) with strict dependency gating and clean rule ownership"
order: 4
lastUpdated: "2026-03-02"
---

# Artifact Pipeline

Every change follows a structured 6-stage pipeline: research, proposal, specs, design, preflight, and tasks. Each stage must complete before the next can begin, and implementation is gated by task completion. Configuration is minimal — workflow rules live in the schema and constitution, not in config.yaml.

## Features

- Structured pipeline guides you from research through to implementation tasks
- Strict dependency ordering prevents skipping critical thinking steps
- Every stage produces a verifiable artifact file
- Implementation cannot start until the full planning cycle is done
- Minimal config.yaml — just a schema reference and constitution pointer
- Workflow rules owned by their authoritative source (schema for universal rules, constitution for project rules)

## Behavior

### Pipeline Stages

The stages execute in order: research (no dependencies), proposal (requires research), specs (requires proposal), design (requires specs), preflight (requires design), and tasks (requires preflight). You cannot skip a stage.

### Dependency Enforcement

Each artifact declares its dependencies in the schema. The OpenSpec CLI checks completion status before allowing generation. An artifact is considered complete when its file exists and is non-empty.

### Apply Gate

Implementation (the apply phase) only begins after tasks.md exists and is non-empty. As you work through tasks, each completed item is marked with `- [x]` in tasks.md.

### Minimal Configuration

The `config.yaml` file serves as a bootstrap pointer only. It contains the schema reference and a `context` entry pointing to the project constitution. All workflow rules are owned by the schema (universal rules in artifact `instruction` fields) or the constitution (project-specific rules) — not by config.yaml.

### Schema-Owned Workflow Rules

The schema defines workflow rules that apply to all projects using it. The tasks stage includes the Definition of Done rule (emergent from artifacts — Gherkin scenarios, success metrics, preflight findings, and user approval). The apply stage includes the post-apply workflow sequence.

## Edge Cases

- An empty file (0 bytes) does not satisfy dependency checks.
- If you manually delete an artifact mid-pipeline, the system detects the gap and requires regeneration.
- If the schema is modified while a change is in progress, the new schema applies to new changes only.
- If tasks.md contains no checkbox items (documentation-only change), the apply phase is still gated by tasks.md existence but reports no tasks to execute.
- If the proposal lists multiple capabilities, the specs stage is not complete until all capability specs are generated.
- If a project has no constitution file, the config.yaml context pointer is harmless — the AI notes the missing file and proceeds.
- Existing projects with workflow rules in config.yaml continue to work — the rules are additive to schema instructions.
