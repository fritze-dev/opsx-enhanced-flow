---
title: "Three-Layer Architecture"
capability: "three-layer-architecture"
description: "Defines the Constitution, Schema, and Skills layers that structure the plugin, with distinct responsibilities and independent modifiability."
lastUpdated: "2026-03-05"
---

# Three-Layer Architecture

The plugin organizes all behavior into three independent layers: Constitution, Schema, and Skills. Each layer has a clear responsibility, and changes to one layer do not require changes to another.

## Purpose

Projects using AI-driven workflows need a way to separate global rules, pipeline definitions, and command logic so they can evolve independently. Without this separation, every change risks unintended side effects across unrelated concerns. The three-layer architecture provides clear boundaries that allow each concern to be modified in isolation.

## Rationale

A single-file or monolithic approach to AI workflow configuration quickly becomes unmaintainable as the number of rules, pipeline stages, and commands grows. Separating concerns into Constitution (project rules), Schema (pipeline structure), and Skills (command logic) ensures that each layer has a single authoritative owner. This mirrors established software architecture patterns where configuration, orchestration, and execution are kept distinct. The separation also enables the plugin to serve different projects -- each project brings its own Constitution while sharing the same Schema and Skills.

## Features

- **Constitution Layer**: A single `constitution.md` file at `openspec/constitution.md` defines all project-wide rules, including Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Every AI action reads this file before performing work.
- **Schema Layer**: The `opsx-enhanced` schema at `openspec/schemas/opsx-enhanced/` declares the 6-stage artifact pipeline (research, proposal, specs, design, preflight, tasks). Each artifact has a template, instruction, and dependency list.
- **Skills Layer**: All 13 commands are delivered as `skills/*/SKILL.md` files within the Claude Code plugin system. Skills are categorized as workflow (6), governance (5), or documentation (2). All skills are model-invocable.
- **Layer Separation**: Each layer is independently modifiable. The schema does not embed skill logic, and the constitution does not contain schema-specific artifact definitions.

## Behavior

### Constitution Is Read Before Any Action

The constitution file is loaded and its rules are applied before any AI-driven skill executes. This is enforced through workflow rules configured in `config.yaml`. When a project is first set up, the constitution is generated with standard sections: Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions.

### Schema Defines the Pipeline

The schema at `openspec/schemas/opsx-enhanced/schema.yaml` declares exactly 6 artifacts in strict dependency order: research, proposal, specs, design, preflight, and tasks. Each artifact definition includes a `generates` field, a `template` reference, an `instruction` block, and a `requires` dependency list. The apply phase is gated by the tasks artifact -- implementation cannot begin until tasks are complete.

### All 13 Skills Are Present and Invocable

A fully installed plugin contains exactly 13 skill subdirectories, each with a `SKILL.md` file. All skills have `disable-model-invocation` set to `false` (or absent, which defaults to false), allowing bootstrap workflows and other skills to invoke them programmatically.

### Layers Are Independently Modifiable

Updating the schema with a new optional artifact stage does not require changes to existing skills, because skills depend on the OpenSpec CLI rather than the schema directly. Adding a new code style rule to the constitution does not require schema changes, because the schema does not embed constitution rules. Refining a skill's instruction text does not require changes to either the constitution or the schema.

## Known Limitations

- The Claude Code plugin system discovers skills by scanning `skills/*/SKILL.md` files and uses YAML frontmatter for configuration. This is based on observed Claude Code behavior, not a documented guarantee.
- The `config.yaml` workflow rules mechanism is assumed to reliably enforce constitution reading before skill execution.

## Edge Cases

- If the constitution is missing or empty, skills report an error rather than proceeding without rules.
- If the schema is malformed YAML, the OpenSpec CLI rejects it with a validation error before any artifact generation begins.
- If a skill directory exists but contains no `SKILL.md` file, the Claude Code plugin system does not register that command.
- If a new skill is added without updating the constitution's skill count documentation, the system still functions but documentation becomes stale. This is detected by `/opsx:verify`.
