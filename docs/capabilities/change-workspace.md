---
title: "Change Workspace"
capability: "change-workspace"
description: "Create, structure, and archive change workspaces for the spec-driven workflow"
order: 7
lastUpdated: "2026-03-04"
---

# Change Workspace

Manage the full lifecycle of changes — from creating a new workspace with `/opsx:new` through to archiving completed work with `/opsx:archive`. Each workspace is pre-structured according to the workflow schema.

## Features

- Create a new change workspace with a single command
- Automatic name derivation from descriptions (converted to kebab-case)
- Pre-structured workspace with schema-defined artifacts and dependency gating
- Archive completed changes with date-prefixed directory names for chronological history
- Sync prompt before archiving to keep baseline specs up to date

## Behavior

### Creating a Change Workspace

Run `/opsx:new <change-name>` to create a scaffolded workspace. The name must be in kebab-case format. If you provide a description instead of a name, the system derives a kebab-case name from it. If the name contains invalid characters, the system asks for a valid name. If a change with that name already exists, the system suggests continuing the existing change instead.

### Workspace Structure

The workspace is pre-structured according to the active schema. It includes a manifest recording the schema used and creation metadata. The artifact pipeline sequence is determined by the schema definition (research, proposal, specs, design, preflight, tasks for the `opsx-enhanced` schema). Only the first artifact (research) is ready initially — downstream artifacts are blocked by unmet dependencies.

### Archiving Changes

Run `/opsx:archive` to move a completed change to the archive with a date-prefixed directory name (e.g., `2026-03-02-add-user-auth`). Before archiving, the system checks for unsynced delta specs and prompts you to sync if needed — you can choose to sync now or archive without syncing.

If artifacts or tasks are incomplete, the system warns you and asks for confirmation before proceeding. If the archive target directory already exists, the system fails with an error and suggests a resolution.

## Edge Cases

- If no active changes exist when archiving, the system informs you and suggests creating a new change.
- If multiple active changes exist and you do not specify which to archive, the system lists available changes and asks you to select one.
- An empty workspace (no artifacts created) can still be archived if you confirm the warning.
- If the move operation fails (e.g., disk full), the workspace remains in its original location and the error is reported.
- The archive directory is created automatically if it does not already exist.
