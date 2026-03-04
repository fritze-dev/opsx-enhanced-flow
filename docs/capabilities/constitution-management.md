---
title: "Constitution Management"
capability: "constitution-management"
description: "Auto-generated project constitution from codebase patterns, with automatic updates and global enforcement"
order: 4
lastUpdated: "2026-03-04"
---

# Constitution Management

The project constitution captures your codebase's real patterns and conventions, ensuring every AI action respects your project's established rules. It is auto-generated from your codebase and evolves as your project grows.

## Features

- Auto-generated constitution based on observed codebase patterns — no invented rules
- Uncertain conventions marked with `<!-- REVIEW -->` for your confirmation
- Automatic enforcement across all AI actions via configuration
- Constitution updates when new technologies or patterns are introduced during design
- Friction tracking convention for capturing workflow issues as GitHub Issues
- Only project-specific rules — no duplication of schema-defined rules

## Behavior

### Bootstrap-Generated Constitution

When you run `/opsx:bootstrap`, the system scans your source files, configuration, directory structures, and dependency manifests to infer your tech stack, architecture rules, code style, constraints, and conventions. Every entry is traceable to an observed pattern. Where the system is uncertain (e.g., inconsistent indentation styles), entries are marked with `<!-- REVIEW -->` so you can confirm or correct them.

The constitution covers at minimum: Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions.

### Global Context Enforcement

Every skill invocation and artifact generation step reads the constitution before proceeding. This ensures AI-generated content respects your project's conventions without you having to remind the AI each time. If the constitution file is missing, the system warns you and recommends running `/opsx:bootstrap`.

### Automatic Updates During Design

When the design phase introduces new technologies, patterns, or architectural changes, the constitution is updated to reflect the additions. For example, if a design introduces Redis as a caching layer, Redis is added to the Tech Stack section. Updates are additive by default — existing entries are not removed without your explicit approval. If a technology is being replaced, the old entry is marked with `<!-- REVIEW -->` and the new one is added, noting the proposed replacement.

Constitution changes are documented in the design artifact so they are visible during review.

### Friction Tracking Convention

The constitution includes a convention requiring that workflow friction discovered during any workflow run be captured as a GitHub Issue with the `friction` label, including what happened, expected behavior, and a suggested fix.

### No Redundancy with Schema

The constitution contains only project-specific rules. Rules about spec format, task format, assumption markers, capability naming, or artifact pipeline ordering live in the schema — not the constitution.

## Edge Cases

- On an empty project (no source files), a minimal constitution with placeholder sections is generated, with all entries marked `<!-- REVIEW -->`.
- If contradictory patterns are observed (e.g., both camelCase and snake_case), both are documented and marked with `<!-- REVIEW -->` for your resolution.
- Manual edits to the constitution are treated as authoritative and are not overwritten during subsequent bootstrap or design updates.
- Sequential design phases each add to the constitution — later updates preserve additions from earlier changes.
- In a monorepo with mixed tech stacks, all observed stacks are documented with notes on which directories each applies to.
- When the schema is updated with new instructions, the constitution should be audited for newly-redundant entries.
