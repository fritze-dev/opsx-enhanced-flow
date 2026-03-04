---
title: "Three-Layer Architecture"
capability: "three-layer-architecture"
description: "Constitution, Schema, and Skills — three independently modifiable layers that structure the plugin"
order: 3
lastUpdated: "2026-03-04"
---

# Three-Layer Architecture

The plugin is structured into three independently modifiable layers: the Constitution (project rules), the Schema (artifact pipeline), and Skills (commands). Each layer has distinct responsibilities, and changes to one layer do not require changes to the others.

## Features

- Constitution layer for project-wide rules that govern all AI behavior
- Schema layer defining the 6-stage artifact pipeline declaratively
- Skills layer delivering all 13 commands as discoverable plugin files
- Independent modifiability — update one layer without touching the others

## Behavior

### Constitution Layer

The constitution file defines global project rules covering Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Every AI action reads the constitution before performing work, ensuring consistency across all commands and artifacts.

### Schema Layer

The schema defines the 6-stage artifact pipeline (research, proposal, specs, design, preflight, tasks). Each stage has a template, instruction, and dependency list. The schema is the single source of truth for pipeline structure and artifact generation instructions.

### Skills Layer

All 13 commands are delivered as skill files within the Claude Code plugin system. They are categorized as:
- **Workflow** (6): new, continue, ff, apply, verify, archive
- **Governance** (5): init, bootstrap, discover, preflight, sync
- **Documentation** (2): changelog, docs

All skills are model-invocable except `init`, which is user-only (one-time setup).

### Layer Separation

The schema does not embed skill logic — skills depend on the schema via the OpenSpec CLI. The constitution does not contain schema-specific artifact definitions. You can update pipeline stages without rewriting skills, or change global rules without touching the schema.

## Edge Cases

- If the constitution is missing or empty, skills report an error rather than proceeding without rules.
- If the schema contains invalid YAML, the OpenSpec CLI rejects it with a validation error before any artifact generation begins.
- If a skill directory exists but contains no skill file, the plugin system does not register that command.
- If a new skill is added without updating documentation, the system still functions but documentation becomes stale (detected by `/opsx:verify`).
