---
title: "Artifact Generation"
capability: "artifact-generation"
description: "Fast-forward command for generating pipeline artifacts, with smart checkpoints at critical transitions and change selection for existing workspaces."
lastUpdated: "2026-03-26"
---

# Artifact Generation

The `/opsx:ff` command generates the six pipeline artifacts (research, proposal, specs, design, preflight, tasks) that drive every change through the OpenSpec workflow.

## Purpose

Without a dedicated generation command, you would need to manually create each pipeline artifact, figure out the correct order, and remember which ones are already done. Artifact generation provides a fast-forward approach that handles the full sequence automatically, with smart checkpoints at the moments that require your attention.

## Rationale

A single `/opsx:ff` command serves all generation needs: it generates all remaining artifacts in sequence for straightforward changes, while pausing at critical decision points. The command reads WORKFLOW.md for pipeline configuration and Smart Templates for artifact definitions and instructions, so updating the workflow or templates automatically updates generation behavior without changing the skill. A checkpoint model classifies each pipeline transition as either routine (auto-continue without pausing) or critical (mandatory pause for your input). Routine transitions -- such as research to proposal, or specs to design -- proceed automatically because no user decision is needed. Critical transitions pause at two points: after the design artifact for approach review, and after a preflight that returns warnings for explicit acknowledgment. When existing changes are present, the command offers change selection so you can resume work on an in-progress change.

## Features

- **Fast-forward generation** with `/opsx:ff` -- generates all remaining artifacts in dependency order with pauses at critical checkpoints
- **Change selection** -- when invoked without a name and existing changes are present, lists active changes and lets you select which to continue
- **New change creation** -- when invoked with a description, derives a kebab-case name and creates a new change workspace
- **Dependency gating** -- always respects the pipeline order (research, proposal, specs, design, preflight, tasks)
- **Design review checkpoint** -- pauses after the design artifact for user alignment before continuing
- **Preflight warnings checkpoint** -- pauses when preflight returns warnings, requiring your explicit acknowledgment before generating tasks
- **Consolidation verification** -- when creating specs, verifies the proposal's Consolidation Check confirms no overlap with existing specs before creating files
- **Direct WORKFLOW.md and template reads** -- reads WORKFLOW.md for pipeline configuration and Smart Templates for artifact definitions, rather than duplicating pipeline logic

## Behavior

### Fast-Forward from Any State (/opsx:ff)

Running `/opsx:ff` identifies all pending artifacts by reading WORKFLOW.md and Smart Templates and checking file existence, then generates them sequentially. If only research is complete, it generates the remaining five. If research, proposal, and specs are done, it generates design, preflight, and tasks.

### Change Selection for Existing Changes (/opsx:ff)

When you run `/opsx:ff` without specifying a change name and existing changes are present, the command lists active changes and lets you select which one to continue. The most recently modified change is marked as recommended. When invoked with a description of what to build, the command derives a kebab-case name and creates a new change workspace.

### Fast-Forward Respects Dependency Order (/opsx:ff)

Even when generating multiple artifacts, `/opsx:ff` follows strict pipeline order and does not attempt parallel generation.

### Design Review Checkpoint

After generating or encountering the design artifact, `/opsx:ff` pauses for user alignment before proceeding to preflight. This checkpoint gives you the opportunity to review the approach and architecture decisions while feedback is still inexpensive.

### Preflight Warnings Checkpoint (/opsx:ff)

When preflight returns a verdict of PASS WITH WARNINGS during a fast-forward run, the system pauses and presents the warnings to you. It requires your explicit acknowledgment before generating the tasks artifact. If you want to address a warning, the system pauses the fast-forward and allows you to fix the issue before continuing.

### Checkpoint Skipped on Resume (/opsx:ff)

If you resume `/opsx:ff` on a workspace where preflight already exists, the design review checkpoint is skipped -- preflight existence implies prior design review.

### Pipeline Already Complete (/opsx:ff)

If all artifacts are done, `/opsx:ff` reports that nothing remains and suggests `/opsx:apply`.

### Consolidation Verification (/opsx:ff)

When the specs artifact is next, `/opsx:ff` verifies the proposal's Consolidation Check section before creating spec files. If the proposal lists a new capability that overlaps with an existing spec, the system flags the unresolved overlap before proceeding. If the proposal has no Consolidation Check section (for example, it was created before this feature existed), the system proceeds without the verification step and relies on the specs instruction's built-in overlap verification instead.

### Skill Delivery

`/opsx:ff` is delivered as a skill file that reads WORKFLOW.md for pipeline configuration and Smart Templates for artifact definitions, instructions, and output structure. It checks file existence in the change workspace to determine pipeline status rather than hardcoding artifact names or pipeline logic. The skill is model-invocable.

## Edge Cases

- If WORKFLOW.md is unreadable or missing, the skill reports the error and suggests running `/opsx:setup`.
- If `/opsx:ff` is run when no active change exists and no description is provided, the skill asks you what you want to build.
- If `/opsx:ff` encounters an error mid-pipeline, it stops, reports the error and the last successfully generated artifact, and does not attempt subsequent stages.
- If you modify an artifact file manually after generation, subsequent `/opsx:ff` calls treat it as complete and move to the next stage.
- If multiple capabilities are listed in the proposal, the specs stage generates one spec file per capability before marking the stage as complete.
- If you provide feedback at the design review checkpoint indicating misalignment, the agent incorporates the feedback by regenerating affected artifacts before proceeding.
