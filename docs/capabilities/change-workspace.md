---
title: "Change Workspace"
capability: "change-workspace"
description: "Create, manage, and archive change workspaces with date-prefixed naming"
lastUpdated: "2026-03-25"
---

# Change Workspace

Manages the full lifecycle of a change workspace -- from creation through archiving -- so that every feature or improvement follows a structured, traceable path.

## Purpose

Without structured change workspaces, spec-driven development becomes disorganized -- artifacts scatter across the project, changes lack clear boundaries, and completed work has no consistent archival pattern. This capability ensures every change has a dedicated workspace with a defined structure, and completed changes are preserved chronologically for future reference.

## Rationale

Change names use kebab-case to ensure consistent, URL-safe, filesystem-safe identifiers across operating systems. Archives use a date-prefixed directory naming scheme (YYYY-MM-DD-name) based on ISO 8601, so they sort chronologically in the filesystem by default. The archive step prompts for spec sync before moving files, ensuring baseline specs stay current without forcing the user's hand.

## Features

- One-command workspace creation via `/opsx:new <change-name>` -- creates the workspace directory and reads schema.yaml to display the artifact pipeline
- Automatic name derivation -- provide a description instead of a kebab-case name and the system converts it
- Schema-driven structure -- the workspace contains exactly the artifacts defined by the active schema, with dependency gating
- Date-prefixed archiving via `/opsx:archive` -- moves completed changes to a chronologically sorted archive
- Sync prompt before archive -- surfaces unsynced delta specs and offers to sync before filing the change away
- Warnings for incomplete artifacts or tasks before archiving

## Behavior

### Creating a Workspace

When you run `/opsx:new add-user-auth`, the system creates a workspace at `openspec/changes/add-user-auth/` via `mkdir -p` and reads schema.yaml to determine the artifact pipeline, displaying the artifact status and first artifact template. If you provide a description like "add user authentication" instead of a name, the system derives `add-user-auth` automatically. If the name is invalid (contains uppercase or special characters), the system asks for a valid kebab-case name. If a change with that name already exists, the system suggests continuing the existing change instead.

### Workspace Structure and Dependency Gating

The created workspace is a directory at `openspec/changes/<name>/`. The artifact pipeline sequence is determined by reading `openspec/schemas/opsx-enhanced/schema.yaml` -- for the opsx-enhanced schema, the stages are: research, proposal, specs, design, preflight, and tasks. Only the first stage (research) is ready initially; downstream stages are blocked by unmet dependencies as determined by file existence checks.

### Archiving a Completed Change

When you run `/opsx:archive`, the system moves the workspace to the archive directory with a date prefix (e.g., `2026-03-02-add-user-auth/`). Before archiving:

- If unsynced delta specs exist, the system shows a summary and offers "Sync now" or "Archive without syncing."
- If artifacts or tasks are incomplete, the system displays a warning with details and asks you to confirm.
- If the archive target directory already exists, the system fails with an error and suggests a resolution.

### Archiving with Incomplete Tasks

When tasks are partially complete (e.g., 3 of 7 checkboxes marked), the system displays the exact count and asks for confirmation before proceeding.

## Edge Cases

- If no active changes exist when archiving, the system informs you and suggests creating a new change.
- If multiple active changes exist and you do not specify which to archive, the system lists them and asks you to select one.
- An empty workspace (no artifacts created) can still be archived if you confirm the warning.
- If the move operation fails mid-way (e.g., disk full), the workspace remains in its original location and the error is reported.
- The archive directory is created automatically if it does not yet exist.
