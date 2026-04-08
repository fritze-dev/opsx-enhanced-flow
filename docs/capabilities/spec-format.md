---
title: "Spec Format"
capability: "spec-format"
description: "Defines the format rules for specifications including normative descriptions, Gherkin scenarios, frontmatter metadata with tracking fields, and baseline structure."
lastUpdated: "2026-04-08"
---

# Spec Format

Specifications follow a strict format that ensures consistency, machine-parseability, and clear communication of requirements. Every spec uses normative descriptions with RFC 2119 keywords, Gherkin scenarios for testable behavior, YAML frontmatter for documentation ordering and change tracking, and a standardized structure.

## Purpose

When multiple people and AI agents create and modify specifications, inconsistent formatting leads to misinterpretation, broken parsing, and specs that cannot be reliably verified. Without tracking fields, skills cannot reliably detect which specs are being edited, which change owns them, or whether they have been modified since the last documentation run -- forcing fragile text parsing and overly broad regeneration fallbacks.

## Rationale

Normative descriptions using RFC 2119 keywords (SHALL, MUST, SHOULD, MAY) provide unambiguous obligation levels that distinguish mandatory behavior from optional guidance. Gherkin scenarios with strict heading levels (`####` for scenarios) ensure that automated tools can parse scenario blocks without confusion -- using the wrong heading level causes a silent failure where the scenario is misinterpreted as a requirement heading. YAML frontmatter serves dual purposes: documentation fields (`order` and `category`) enable deterministic, project-specific ordering in generated documentation, while tracking fields (`status`, `change`, `version`, `lastModified`) give skills machine-readable metadata about spec lifecycle state. The `status`/`change` pair enables collision detection when two changes attempt to edit the same spec, and `version`/`lastModified` enables efficient incremental documentation generation without scanning change directories. Assumptions use a dual-format pattern -- visible list item plus hidden HTML tag -- so that reviewers can audit them in Markdown preview while preflight can still grep for machine-parseable tags.

## Features

- **Normative Descriptions**: Every requirement has a binding description using RFC 2119 keywords, placed immediately after the requirement header. An optional User Story follows.
- **Gherkin Scenarios**: Every requirement has at least one scenario using `#### Scenario:` (exactly 4 hashtags) with GIVEN/WHEN/THEN clauses as bold-prefixed list items.
- **Baseline Spec Format**: Specs use `## Purpose` followed by `## Requirements` without operation prefixes, representing the current state.
- **Spec Frontmatter Metadata**: Specs support optional YAML frontmatter with documentation fields (`order`, `category`) for TOC ordering and tracking fields (`status`, `change`, `version`, `lastModified`) for change lifecycle management.
- **Assumption Marker Format**: Assumptions use a visible list item with an HTML comment tag for machine parsing, ensuring assumptions are readable in Markdown preview and auditable by preflight.

## Behavior

### Normative Descriptions Come First

Each requirement block begins with a normative description using SHALL/MUST keywords immediately after the `### Requirement:` header. An optional User Story in the format `**User Story:** As a [role] I want [goal], so that [benefit]` may follow the description. The description always comes before the User Story -- reversing this order is a format violation flagged during preflight. A requirement with no User Story is valid as long as it has the normative description and scenarios.

### Gherkin Scenarios Use Strict Heading Levels

Scenarios use the heading `#### Scenario: <name>` with exactly 4 hashtags. Each scenario contains GIVEN, WHEN, and THEN clauses formatted as `- **GIVEN** ...`, `- **WHEN** ...`, `- **THEN** ...`. Additional conditions use `- **AND** ...` after the relevant clause. Using 3 hashtags (`### Scenario:`) is a silent failure -- the scenario renders as a requirement-level heading and the GIVEN/WHEN/THEN content is orphaned from its intended context. Multiple scenarios per requirement are supported, each with a unique name.

### Baseline Specs Represent Current State

Specs at `openspec/specs/<capability>/spec.md` use a `## Purpose` section followed by a `## Requirements` section. Each requirement within the spec follows the standard format: `### Requirement:` header, normative description, optional User Story, and `#### Scenario:` blocks.

### Frontmatter Controls Documentation Ordering

Specs may include YAML frontmatter at the top of the file with `order` (an integer for display position in the documentation table of contents) and `category` (a kebab-case string for workflow phase grouping). Standard categories are: `setup`, `change-workflow`, `development`, `finalization`, `reference`, `meta`. The `/opsx:docs` command reads these values to determine capability ordering and group headers. If `order` is absent, the agent determines ordering. If `category` is absent, the capability appears in an "Other" group.

### Frontmatter Tracks Change Lifecycle

Specs include tracking fields in YAML frontmatter: `status` (stable or draft), `change` (the change directory currently editing this spec -- present only when draft), `version` (integer, incremented on each successful change completion), and `lastModified` (YYYY-MM-DD, set when the spec is edited and again at completion). When a change edits a spec during the specs stage, `status` is set to `draft` and `change` is set to the change directory name. When verify completion runs, `status` is flipped back to `stable`, `change` is removed, `version` is incremented, and `lastModified` is updated. Missing tracking fields are treated as defaults: `status` as `stable`, `version` as `1`, and `lastModified` as unset (requiring regeneration).

### Collision Detection via Draft Status

When a change attempts to edit a spec that already has `status: draft` with a `change` value referencing a different change, the agent detects the conflict via mismatched `change` values and warns the user about the collision before proceeding.

### Assumptions Use Visible Text With Machine Tags

Assumptions are written as a visible list item followed by an HTML comment tag: `- Visible assumption text. <!-- ASSUMPTION: short tag -->`. The visible text is a complete, readable statement of the assumption. The HTML comment tag is a brief identifier for preflight grep. Assumptions written entirely inside an HTML comment with no visible text are invisible in Markdown preview and are flagged as format violations during preflight. If no assumptions were made, the `## Assumptions` section states "No assumptions made."

## Known Limitations

- Tracking fields are managed by skills (FF and verify); there is no hard enforcement preventing manual edits to frontmatter that could desynchronize status and version.
- Collision detection relies on the `change` field being set correctly during the specs stage; if a change edits a spec without updating frontmatter, the collision goes undetected.

## Edge Cases

- If a requirement has zero scenarios, the spec is considered invalid and flagged during preflight.
- If two specs share the same `order` value, `/opsx:docs` uses alphabetical capability name as a tiebreaker.
- If a `category` value is not one of the standard categories, `/opsx:docs` still renders it as a group header using title-case formatting.
- If a spec has `status: draft` but no `change` field, preflight flags this as a warning (unknown change owner).
- If a spec has `status: stable` with a `change` field present, the `change` field is ignored (stale data).
