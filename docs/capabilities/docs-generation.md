---
title: "Documentation Generation"
capability: "docs-generation"
description: "Generate user-facing capability docs and changelogs from specs and archived changes"
order: 14
lastUpdated: "2026-03-04"
---

# Documentation Generation

Generate clear, user-facing documentation with `/opsx:docs` and release notes with `/opsx:changelog`. Documentation is derived from your baseline specs; changelogs are derived from archived changes.

## Features

- Generate one documentation file per capability from baseline specs
- User-facing language — no technical jargon or implementation details
- Gherkin scenarios converted to readable usage examples
- Changelog generation from archived changes in Keep a Changelog format
- Existing manually written changelog entries are preserved

## Behavior

### Capability Documentation

When you run `/opsx:docs`, the system reads each baseline spec and generates a documentation file under `docs/capabilities/`. Requirement descriptions are transformed into natural explanations, Gherkin scenarios become readable behavioral descriptions, and technical terms are replaced with plain language. If a User Story is present, it informs the documentation's framing. A table of contents linking all capability docs is generated at `docs/README.md`.

You can regenerate docs for a single capability by passing its name, or regenerate all by running the command without arguments.

### Changelog Generation

When you run `/opsx:changelog`, the system reads each archived change directory, examines the proposal, delta specs, and design artifacts, and produces a changelog entry summarizing what changed from your perspective. Entries follow the Keep a Changelog format (Added, Changed, Deprecated, Removed, Fixed, Security) and are ordered newest first. If a changelog already exists, new entries are added without modifying existing manually written entries.

### Normative Language Replaced

Specification language (SHALL, MUST, etc.) is replaced with natural phrasing like "You can..." and "The system...". The focus is on what you can do, not how the system implements it.

## Edge Cases

- If no baseline specs exist, the system informs you and suggests running `/opsx:sync` first.
- If a spec has no scenarios, documentation is still generated from requirement descriptions, noting that usage examples are unavailable.
- Existing documentation files are overwritten with freshly generated content, since specs are the source of truth.
- If no archived changes exist, the changelog command informs you that no entries were generated.
- Malformed archive directories are skipped with a warning; remaining archives are processed normally.
- On re-run, existing changelog entries are not duplicated.
