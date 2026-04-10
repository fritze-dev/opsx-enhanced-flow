# Specs: Auto-Approve as Default

## Modified Capabilities

### workflow-contract

**File:** `openspec/specs/workflow-contract/spec.md`

**Change:** In Requirement "WORKFLOW.md Pipeline Orchestration", updated `auto_approve` field description from "optional boolean, when `true` pipeline traversal proceeds without user confirmation at checkpoints" to "optional boolean, defaults to `true` — pipeline traversal proceeds without user confirmation at checkpoints; set to `false` to pause at every checkpoint".

This changes the semantic default: when `auto_approve` is absent from WORKFLOW.md frontmatter, the system now treats it as `true` (proceed without pausing) rather than `false` (pause at every checkpoint).

### artifact-pipeline

**File:** `openspec/specs/artifact-pipeline/spec.md`

**Change:** In Requirement "Propose as Single Entry Point for Pipeline Traversal", updated `auto_approve` description to clarify the new default behavior. Added explicit documentation of both states: absent/true = skip checkpoints, false = pause at checkpoints.
