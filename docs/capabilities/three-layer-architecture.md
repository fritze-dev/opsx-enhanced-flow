---
title: "Three-Layer Architecture"
capability: "three-layer-architecture"
description: "Constitution, WORKFLOW.md + Smart Templates, and Router + Actions with independent modifiability"
lastUpdated: "2026-04-10"
---

# Three-Layer Architecture

The plugin organizes all behavior into three independent layers: Constitution, WORKFLOW.md + Smart Templates, and Router + Actions. Each layer has a clear responsibility, and changes to one layer do not require changes to another.

## Purpose

Projects using AI-driven workflows need a way to separate global rules, pipeline definitions, and command logic so they can evolve independently. Without this separation, every change risks unintended side effects across unrelated concerns. The three-layer architecture provides clear boundaries that allow each concern to be modified in isolation.

## Rationale

Separating concerns into Constitution (project rules), WORKFLOW.md + Smart Templates (pipeline structure and artifact definitions), and Router + Actions (command dispatch) ensures each layer has a single authoritative owner. WORKFLOW.md provides slim pipeline orchestration -- stage ordering, apply gate, inline action definitions, optional worktree configuration -- while Smart Templates carry their own instructions and metadata in YAML frontmatter. The third layer consolidated from 11 separate skill files to a single router that dispatches to 4 built-in actions (init, propose, apply, finalize) plus consumer-defined custom actions, eliminating 90%+ of orchestration code duplication. Actions are defined inline in WORKFLOW.md, making the router a thin dispatcher that reads WORKFLOW.md dynamically at runtime. Custom actions leverage the same layer separation -- they are defined in WORKFLOW.md (Layer 2) and dispatched by the router (Layer 3) without requiring changes to either the router or the constitution.

## Features

- **Constitution Layer**: A single `CONSTITUTION.md` file at `openspec/CONSTITUTION.md` defines all project-wide rules, including Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions. Every AI action reads this file before performing work, enforced via WORKFLOW.md's `context` field.
- **WORKFLOW.md + Smart Templates Layer**: `openspec/WORKFLOW.md` declares the 7-stage artifact pipeline order, inline action definitions (built-in and custom), apply gate, optional worktree configuration, automation config, and project context. Smart Templates in `openspec/templates/` carry per-artifact instructions, output paths, and dependencies in YAML frontmatter. Together they serve as the single source of truth for pipeline structure, action instructions, and artifact generation.
- **Router + Actions Layer**: All commands are delivered through a single router SKILL.md that dispatches to 4 built-in actions: `init` (project setup and health checks), `propose` (pipeline traversal), `apply` (task implementation with review.md), and `finalize` (changelog, docs, version bump). The router additionally supports consumer-defined custom actions listed in the WORKFLOW.md `actions` array. The router is model-invocable.
- **Layer Separation**: Each layer is independently modifiable. WORKFLOW.md and Smart Templates do not embed router logic, and the constitution does not contain pipeline-specific definitions. The router depends on WORKFLOW.md and Smart Templates by reading them directly at runtime. Adding a custom action requires only WORKFLOW.md changes -- no router or constitution modifications.

## Behavior

### Constitution Is Read Before Any Action

The constitution file is loaded and its rules are applied before any AI-driven action executes. This is enforced through the `context` field in WORKFLOW.md, which points to `openspec/CONSTITUTION.md`.

### WORKFLOW.md and Smart Templates Define the Pipeline and Actions

WORKFLOW.md declares 7 artifacts in strict dependency order via its `pipeline` array: research, proposal, specs, design, preflight, tasks, and review. It also defines inline actions (built-in and custom) with `## Action: <name>` body sections containing procedural instructions. Each Smart Template contains `id`, `generates`, `requires`, and `instruction` fields. The apply phase is gated by the tasks artifact.

### Router Dispatches to Built-in and Custom Actions

A single router SKILL.md handles all user-facing commands. It performs shared orchestration (intent recognition, change context detection, WORKFLOW.md loading) and dispatches to the appropriate action. For propose, it traverses the pipeline. For apply and finalize, it spawns a sub-agent with bounded context. For init, it executes without change context. For custom actions, it reads the instruction from WORKFLOW.md and executes it directly, with the agent deciding the execution mode.

### Adding Custom Actions Does Not Require Router Changes

A consumer adds a custom action by appending it to the `actions` array in WORKFLOW.md frontmatter and writing a `## Action: <name>` body section. The router validates against the `actions` array dynamically and dispatches via a generic fallback -- no modification to the router SKILL.md is needed.

### Layers Are Independently Modifiable

Updating a WORKFLOW.md action instruction does not require changes to the router, because the router reads WORKFLOW.md dynamically. Adding a new code style rule to the constitution does not require WORKFLOW.md changes. Refining the router's dispatch logic does not require changes to the constitution or WORKFLOW.md. Adding a custom action only touches WORKFLOW.md.

## Known Limitations

- The Claude Code plugin system discovers the router by scanning `skills/*/SKILL.md` files. This is based on observed behavior, not a documented guarantee.
- The WORKFLOW.md `context` field mechanism is assumed to reliably enforce constitution reading before action execution.

## Edge Cases

- If the constitution is missing or empty, the router reports an error rather than proceeding without rules.
- If WORKFLOW.md contains malformed YAML, the router reports a read error rather than proceeding with invalid data.
- If the router SKILL.md is missing, the plugin system does not register any commands.
- If a new action is added without updating documentation, the system still functions but documentation is stale.
