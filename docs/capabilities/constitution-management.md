---
title: "Constitution Management"
capability: "constitution-management"
description: "Constitution generation from codebase, automatic updates during design, global enforcement, and friction tracking"
order: 13
lastUpdated: "2026-03-02"
---

# Constitution Management

The project constitution is auto-generated from your codebase during bootstrap, automatically updated when design introduces new technologies, and enforced across all AI actions. It contains only project-specific rules — universal workflow rules live in the schema.

## Features

- Constitution generated from observed codebase patterns, not generic defaults
- Uncertain conventions marked with `<!-- REVIEW -->` for your confirmation
- Automatic updates when design phases introduce new technologies or patterns
- Global enforcement: every AI action reads the constitution before proceeding
- Only project-specific rules — no duplication of schema or template instructions
- Built-in friction tracking convention for systematic workflow improvement

## Behavior

### Bootstrap Generation

During `/opsx:bootstrap`, the agent scans source files, configuration, and dependencies to infer the constitution. Every entry is traceable to an observed pattern. The constitution covers Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions.

### Global Context

The constitution is referenced through `config.yaml` workflow rules. Every skill invocation and artifact generation reads the constitution first, ensuring all AI output respects your project's conventions.

### Design-Phase Updates

When a design introduces a new technology (e.g., Redis) or architectural pattern not in the constitution, the agent adds it. Updates are additive by default: existing entries are not removed without your approval. Proposed replacements are marked with `<!-- REVIEW -->`. Constitution changes are documented in the design artifact.

### Project-Specific Rules Only

The constitution contains only rules specific to the project. Rules about spec format, task format, artifact pipeline ordering, assumption markers, or capability naming belong in the schema and are not duplicated in the constitution. The constitution retains: Tech Stack, Architecture Rules (structure and paths), Code Style (project conventions), Constraints (principles not enforced by schema mechanics), and Conventions.

### Friction Tracking

The constitution's Conventions section includes a rule for capturing workflow friction as GitHub Issues with the `friction` label. Each issue must include: what happened, expected behavior, and a suggested fix. This ensures problems discovered during workflow runs are tracked and addressed instead of lost.

## Edge Cases

- If the project has no source files, bootstrap generates a minimal constitution with placeholder sections marked `<!-- REVIEW -->`.
- If the codebase has conflicting conventions, both patterns are documented and marked `<!-- REVIEW -->`.
- If you manually edit the constitution, the agent treats your edits as authoritative.
- Sequential design phases preserve earlier additions and don't regress them.
- In a monorepo with mixed tech stacks, the agent documents all stacks and notes which directories each applies to.
- The friction tracking convention applies to all projects using the opsx workflow, not just the plugin itself.
- When the schema is updated with new instructions, the constitution should be audited for newly-redundant entries.
