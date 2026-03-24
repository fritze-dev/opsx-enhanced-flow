---
title: "Spec Format"
capability: "spec-format"
description: "Defines the format rules for specifications including normative descriptions, Gherkin scenarios, delta spec operations, frontmatter metadata, and baseline structure."
lastUpdated: "2026-03-24"
---

# Spec Format

Specifications follow a strict format that ensures consistency, machine-parseability, and clear communication of requirements. Every spec uses normative descriptions with RFC 2119 keywords, Gherkin scenarios for testable behavior, and a standardized structure for both delta changes and baseline state.

## Purpose

When multiple people and AI agents create and modify specifications, inconsistent formatting leads to misinterpretation, broken parsing, and specs that cannot be reliably merged or verified. The spec format defines precise rules for how requirements, scenarios, changes, and assumptions are expressed, so that every spec is both human-readable and machine-processable.

## Rationale

Normative descriptions using RFC 2119 keywords (SHALL, MUST, SHOULD, MAY) provide unambiguous obligation levels that distinguish mandatory behavior from optional guidance. Gherkin scenarios with strict heading levels (`####` for scenarios) ensure that automated tools can parse scenario blocks without confusion -- using the wrong heading level causes a silent failure where the scenario is misinterpreted as a requirement heading. Delta specs use operation prefixes (ADDED, MODIFIED, REMOVED, RENAMED) so the sync process can correctly categorize and merge changes into baselines. Baseline specs omit these prefixes because they represent the current merged state, not a set of changes. YAML frontmatter with `order` and `category` fields enables deterministic, project-specific ordering in generated documentation. Assumptions use a dual-format pattern -- visible list item plus hidden HTML tag -- so that reviewers can audit them in Markdown preview while preflight can still grep for machine-parseable tags.

## Features

- **Normative Descriptions**: Every requirement has a binding description using RFC 2119 keywords, placed immediately after the requirement header. An optional User Story follows.
- **Gherkin Scenarios**: Every requirement has at least one scenario using `#### Scenario:` (exactly 4 hashtags) with GIVEN/WHEN/THEN clauses as bold-prefixed list items.
- **Delta Spec Operations**: Delta specs use `## ADDED Requirements`, `## MODIFIED Requirements`, `## REMOVED Requirements`, and `## RENAMED Requirements` headers to categorize changes.
- **Baseline Spec Format**: Baseline specs use `## Purpose` followed by `## Requirements` without operation prefixes, representing the current state.
- **Spec Frontmatter Metadata**: Baseline specs support optional YAML frontmatter with `order` (integer for display position) and `category` (kebab-case workflow phase grouping).
- **Assumption Marker Format**: Assumptions use a visible list item with an HTML comment tag for machine parsing, ensuring assumptions are readable in Markdown preview and auditable by preflight.

## Behavior

### Normative Descriptions Come First

Each requirement block begins with a normative description using SHALL/MUST keywords immediately after the `### Requirement:` header. An optional User Story in the format `**User Story:** As a [role] I want [goal], so that [benefit]` may follow the description. The description always comes before the User Story -- reversing this order is a format violation flagged during preflight. A requirement with no User Story is valid as long as it has the normative description and scenarios.

### Gherkin Scenarios Use Strict Heading Levels

Scenarios use the heading `#### Scenario: <name>` with exactly 4 hashtags. Each scenario contains GIVEN, WHEN, and THEN clauses formatted as `- **GIVEN** ...`, `- **WHEN** ...`, `- **THEN** ...`. Additional conditions use `- **AND** ...` after the relevant clause. Using 3 hashtags (`### Scenario:`) is a silent failure -- the scenario renders as a requirement-level heading and the GIVEN/WHEN/THEN content is orphaned from its intended context. Multiple scenarios per requirement are supported, each with a unique name.

### Delta Specs Categorize Changes by Operation

New capabilities appear under `## ADDED Requirements`. Changes to existing capabilities appear under `## MODIFIED Requirements` and include the full updated requirement content (not partial diffs), because partial content loses detail when archived into the baseline. Deprecated capabilities appear under `## REMOVED Requirements` with a `**Reason**` and a `**Migration**` path. Name-only changes appear under `## RENAMED Requirements` using `FROM: <old name>` / `TO: <new name>` format.

### Baseline Specs Represent Current State

Baseline specs at `openspec/specs/<capability>/spec.md` use a `## Purpose` section followed by a `## Requirements` section. They do not use operation prefixes (ADDED, MODIFIED, REMOVED, RENAMED) because they represent the merged state of all requirements. Each requirement within the baseline follows the same format as delta specs: `### Requirement:` header, normative description, optional User Story, and `#### Scenario:` blocks.

### Frontmatter Controls Documentation Ordering

Baseline specs may include YAML frontmatter at the top of the file with `order` (an integer for display position in the documentation table of contents) and `category` (a kebab-case string for workflow phase grouping). Standard categories are: `setup`, `change-workflow`, `development`, `finalization`, `reference`, `meta`. The `/opsx:docs` command reads these values to determine capability ordering and group headers. If `order` is absent, the agent determines ordering. If `category` is absent, the capability appears in an "Other" group. Frontmatter is assigned during spec creation, preserved during sync, and takes precedence from delta specs when intentionally changed.

### Assumptions Use Visible Text With Machine Tags

Assumptions are written as a visible list item followed by an HTML comment tag: `- Visible assumption text. <!-- ASSUMPTION: short tag -->`. The visible text is a complete, readable statement of the assumption. The HTML comment tag is a brief identifier for preflight grep. Assumptions written entirely inside an HTML comment with no visible text are invisible in Markdown preview and are flagged as format violations during preflight. If no assumptions were made, the `## Assumptions` section states "No assumptions made."

## Known Limitations

- The sync process is agent-driven and relies on intelligent merging rather than exact programmatic parsing. This means frontmatter handling during sync depends on the agent's ability to preserve markdown structure.
- The OpenSpec CLI's programmatic archive merge expects baseline specs to use `## Purpose` + `## Requirements` format. Agent-driven sync via `/opsx:sync` is the primary merge path.

## Future Enhancements

- Automated validation of doc output against templates.
- Incremental documentation generation (docs currently regenerate fully each run).

## Edge Cases

- If a delta spec contains both ADDED and MODIFIED sections, the sync process handles each operation independently.
- If a delta spec uses an unrecognized operation prefix (for example, `## UPDATED Requirements`), the sync process flags it as an error and refuses to merge.
- If a requirement has zero scenarios, the spec is considered invalid and flagged during preflight.
- If the same requirement name appears in both ADDED and MODIFIED sections of the same delta spec, it is treated as a conflict and flagged during preflight.
- If a RENAMED requirement's target name conflicts with an existing baseline requirement, the sync process flags the naming collision.
- If a delta spec includes frontmatter that conflicts with the baseline, the delta values take precedence (the change is intentionally reordering the capability).
- If two specs share the same `order` value, `/opsx:docs` uses alphabetical capability name as a tiebreaker.
- If a `category` value is not one of the standard categories, `/opsx:docs` still renders it as a group header using title-case formatting.
- If a MODIFIED requirement includes only the changed scenario and omits the normative description, preflight flags the partial content as a risk because archiving replaces the full baseline requirement with the incomplete delta.
