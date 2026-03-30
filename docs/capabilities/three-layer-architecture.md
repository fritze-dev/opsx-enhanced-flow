---
title: "Three-Layer Architecture"
capability: "three-layer-architecture"
description: "CONSTITUTION.md, WORKFLOW.md + Smart Templates, and Skills layers with distinct responsibilities and independent modifiability"
lastUpdated: "2026-03-30"
---

# Three-Layer Architecture

The plugin organizes all behavior into three independent layers: Constitution, WORKFLOW.md + Smart Templates, and Skills. Each layer has a clear responsibility, and changes to one layer do not require changes to another.

## Purpose

Projects using AI-driven workflows need a way to separate global rules, pipeline definitions, and command logic so they can evolve independently. Without this separation, every change risks unintended side effects across unrelated concerns. The three-layer architecture provides clear boundaries that allow each concern to be modified in isolation.

## Rationale

Separating concerns into Constitution (project rules), WORKFLOW.md + Smart Templates (pipeline structure and artifact definitions), and Skills (command logic) ensures that each layer has a single authoritative owner. WORKFLOW.md provides slim pipeline orchestration -- stage ordering, apply gate, post-artifact hook, optional worktree configuration -- while Smart Templates carry their own instructions and metadata in YAML frontmatter, making each artifact definition self-contained. This mirrors established software architecture patterns where configuration, orchestration, and execution are kept distinct. The separation enables the plugin to serve different projects -- each project brings its own Constitution while sharing the same WORKFLOW.md structure and Skills.

## Features

- **Constitution Layer**: A single `CONSTITUTION.md` file at `openspec/CONSTITUTION.md` defines all project-wide rules, including Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Every AI action reads this file before performing work, enforced via WORKFLOW.md's `context` field.
- **WORKFLOW.md + Smart Templates Layer**: `openspec/WORKFLOW.md` declares the 6-stage artifact pipeline order, apply gate, post-artifact hook, optional worktree configuration, and project context. Smart Templates in `openspec/templates/` carry per-artifact instructions, output paths, and dependencies in YAML frontmatter. Together they serve as the single source of truth for pipeline structure and artifact generation.
- **Skills Layer**: All commands are delivered as `skills/*/SKILL.md` files within the Claude Code plugin system. Skills are categorized as workflow (new, ff, apply, verify, archive), governance (setup, bootstrap, discover, preflight, sync, docs-verify), and documentation (changelog, docs). All skills are model-invocable.
- **Layer Separation**: Each layer is independently modifiable. WORKFLOW.md and Smart Templates do not embed skill logic, and the constitution does not contain pipeline-specific artifact definitions. Skills depend on WORKFLOW.md and Smart Templates by reading them directly at runtime.

## Behavior

### Constitution Is Read Before Any Action

The constitution file is loaded and its rules are applied before any AI-driven skill executes. This is enforced through the `context` field in WORKFLOW.md, which points to `openspec/CONSTITUTION.md`. When a project is first set up, the constitution is generated with standard sections: Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions.

### WORKFLOW.md and Smart Templates Define the Pipeline

WORKFLOW.md declares exactly 6 artifacts in strict dependency order via its `pipeline` array: research, proposal, specs, design, preflight, and tasks. Each Smart Template in `openspec/templates/` contains `id`, `generates`, `requires`, and `instruction` fields in YAML frontmatter, with the output structure as the markdown body. The apply phase is gated by the tasks artifact -- implementation cannot begin until tasks are complete. WORKFLOW.md also supports optional configuration sections such as `worktree` for change isolation and `docs_language` for documentation.

### All Skills Are Present and Invocable

A fully installed plugin contains skill subdirectories, each with a `SKILL.md` file. All skills have `disable-model-invocation` set to `false` (or absent, which defaults to false), allowing bootstrap workflows and other skills to invoke them programmatically.

### Layers Are Independently Modifiable

Updating WORKFLOW.md with a new post-artifact instruction does not require changes to existing skills, because skills read WORKFLOW.md dynamically at runtime. Adding a new code style rule to the constitution does not require WORKFLOW.md changes, because WORKFLOW.md does not embed constitution rules. Refining a skill's instruction text does not require changes to either the constitution or WORKFLOW.md.

## Known Limitations

- The Claude Code plugin system discovers skills by scanning `skills/*/SKILL.md` files and uses YAML frontmatter for configuration. This is based on observed Claude Code behavior, not a documented guarantee.
- The WORKFLOW.md `context` field mechanism is assumed to reliably enforce constitution reading before skill execution.

## Edge Cases

- If the constitution is missing or empty, skills report an error rather than proceeding without rules.
- If WORKFLOW.md contains malformed YAML, skills report a read error rather than proceeding with invalid data.
- If a skill directory exists but contains no `SKILL.md` file, the Claude Code plugin system does not register that command.
- If a new skill is added without updating documentation, the system still functions but documentation becomes stale. This is detected by `/opsx:verify`.
