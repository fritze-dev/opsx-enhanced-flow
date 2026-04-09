---
name: changelog
description: Generate release notes from completed changes. Run after implementation is complete to incrementally update CHANGELOG.md.
disable-model-invocation: false
---

# /opsx:changelog — Generate Release Notes

> Run this **after** implementation and verification to generate changelog entries from completed changes.

**Input**: No arguments. Incrementally updates `CHANGELOG.md` — only new entries are added, existing entries are preserved.

## Instructions

### Prerequisite: Verify Setup

Check that `openspec/WORKFLOW.md` exists. If it is missing, tell the user to run `/opsx:setup` first and stop.

### Step 0: Determine Documentation Language

Read `openspec/WORKFLOW.md` and extract the `docs_language` field from its YAML frontmatter.

- **Missing or "English":** Proceed with English output (default behavior, no change).
- **Non-English value (e.g., "German", "French"):** Generate all new changelog entry headings and descriptions in the target language in Step 6. Dates remain in ISO format. Product names (OpenSpec, Claude Code), commands (`/opsx:*`), and file paths remain in English.

### Step 1: Discover Completed Changes

Glob `openspec/changes/*/` to find all change directories.
The directory name follows the pattern `YYYY-MM-DD-<change-name>`.

**Filter to completed changes:** For each change directory, check if the proposal's YAML frontmatter has `status: completed`. Fallback: check if `tasks.md` exists and all checkbox items are marked `- [x]` (no `- [ ]` items). Only include changes where all tasks are complete.

If no completed changes exist, create an empty `CHANGELOG.md` with proper headers and stop.

### Step 2: Read Existing Changelog

If `CHANGELOG.md` exists in the project root, read it. Extract dates and change names from existing `##` headings to determine which change entries are already documented.

### Step 3: Determine New Entries

Compare completed change directories against existing headings. Only process entries whose date + name combination is not yet in the changelog.

If no new entries exist, report and stop.

### Step 4: Extract Information per New Entry

From each new completed change directory, read:
- `proposal.md` — Problem statement, motivation, capabilities

Then identify affected capabilities from the proposal's YAML frontmatter `capabilities` field (fall back to parsing the `## Capabilities` section if frontmatter is absent). Read the current specs:
- `openspec/specs/<capability>/spec.md` — User-facing behavior (stories + scenarios)

Also read from the change directory:
- `design.md` — Architecture decisions, success metrics

If `proposal.md` is missing, skip the entry with a warning.

**Fallback for proposals without capabilities frontmatter or structured Capabilities section:** Derive the change description from the proposal's "What Changes" and "Why" sections instead of looking up specs.

### Step 5: Classify Changes

Derive a type from the proposal and spec content:

| Source | Changelog Element |
|--------|-------------------|
| proposal.md "Why" section | Context for the entry |
| proposal.md "Capabilities" table | Change type: Added (NEW) / Changed (MODIFIED) |
| Specs User Stories | User-facing description of changes |
| Specs Gherkin scenario titles | Behavioral details (if relevant) |
| design.md | Not used directly (too technical) |
| Implementation details (file paths, APIs) | Omitted entirely |

### Step 6: Generate Entry and Merge

**Language reminder:** If Step 0 determined a non-English `docs_language`, translate section headers (e.g., `### Added` → `### Hinzugefügt` for German) and entry descriptions to the target language. Dates remain in ISO format. Product names and commands remain in English. Existing entries in previous languages are preserved unchanged.

Generate entries following [Keep a Changelog](https://keepachangelog.com/) format. Insert new entries at the correct chronological position (newest first).

```markdown
## YYYY-MM-DD — Feature Name

### Added
- [New capabilities — one line per change, user perspective]

### Changed
- [Modified behavior]

### Fixed
- [Bug fixes, if any]
```

> **No `[Unreleased]` tag.** Each changelog entry is generated *after* the change is complete. The change directory date *is* the release date.

If no `CHANGELOG.md` exists yet, create it from scratch with proper headers.

### Step 7: Confirm

Show the user a summary of what was added.

---

## Output On Success

```
## Changelog Updated

**New entries**: N added (total: M entries)
**Output**: `CHANGELOG.md`

### New Entries
- YYYY-MM-DD — Feature Name
- ...

### Already Present (skipped)
- ...
```

## Output When No Completed Changes

```
## Changelog

No completed changes found in openspec/changes/.
Created empty CHANGELOG.md. Entries will be added as changes are completed.
```

## Output When No New Entries

```
## Changelog

No new entries. All N completed changes are already in the changelog.
```

## Guardrails

- Always read each change's proposal.md before generating — do not generate from memory
- If a change has no proposal.md, skip it and warn
- Never overwrite or modify existing changelog entries — only add new ones
- Write from the **user's perspective**, not the developer's
- No implementation details: no file paths, no CLI commands, no API endpoints
- Keep entries concise — one line per change
- If `CHANGELOG.md` already has content, preserve all of it
