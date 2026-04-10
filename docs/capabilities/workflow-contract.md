---
title: "Workflow Contract"
capability: "workflow-contract"
description: "WORKFLOW.md pipeline orchestration, Smart Templates, inline actions, and router dispatch pattern"
lastUpdated: "2026-04-10"
---

# Workflow Contract

WORKFLOW.md, Smart Templates, and inline action definitions provide the declarative contract that the router reads to understand the pipeline structure, artifact definitions, action instructions, and automation configuration.

## Purpose

Without a standardized contract format, pipeline configuration scatters across multiple files, action instructions live separately from their templates, and commands must hardcode assumptions about where to find artifact definitions. The workflow contract centralizes pipeline orchestration, action definitions, and automation config in a single WORKFLOW.md file and makes each template self-describing, so that the router interacts with the pipeline through a consistent, inspectable interface.

## Rationale

A slim WORKFLOW.md handles pipeline orchestration (stage ordering, apply gate, project context) while Smart Templates handle artifact definitions (instruction, output path, dependencies). Actions are defined inline in WORKFLOW.md because they have no output structure -- separate action template files (as explored in PR #97) add maintenance overhead without benefit. The router dispatch pattern consolidates 11 separate skill files into a single router that reads WORKFLOW.md dynamically, eliminating copy-pasted logic like change context detection. Both WORKFLOW.md and Smart Templates include a `template-version` field (integer) that enables `/opsx:workflow init` to detect user customizations and merge plugin updates instead of overwriting.

## Features

- **WORKFLOW.md pipeline orchestration** -- YAML frontmatter with `templates_dir`, `pipeline` array (7 stages), `actions` array, `template-version`, optional `worktree`, `auto_approve`, `automation`, and `docs_language`; markdown body with `## Context` and `## Action: <name>` sections
- **Smart Template format** -- each template carries `id`, `description`, `generates`, `requires`, `instruction`, and `template-version` fields in YAML frontmatter, with the output structure as the markdown body
- **Inline action definitions** -- `actions` array in frontmatter lists action names; each action has a `## Action: <name>` body section with `### Instruction` for procedural guidance
- **Router dispatch pattern** -- single router handles all 4 commands (init, propose, apply, finalize) with shared intent recognition, change context detection, and WORKFLOW.md loading
- **Automation configuration** -- optional `automation.post_approval` section configures CI-triggered finalize on PR approval with state labels
- **Template versioning** -- `template-version` (integer, monotonically increasing) enables version-aware merge during `/opsx:workflow init`

## Behavior

### WORKFLOW.md Provides Pipeline and Action Configuration

The router reads WORKFLOW.md's YAML frontmatter to determine the template directory, pipeline stage order, available actions, and optional automation config. The markdown body provides the `## Context` section for project-level behavioral context and `## Action: <name>` sections with procedural instructions for each action.

### Smart Templates Are Self-Describing

Each template file contains everything needed to generate its artifact: the `instruction` field provides behavioral constraints for the AI, the `generates` field specifies where the output goes, `requires` lists dependency artifacts, and the markdown body defines the output structure. The `instruction` content is never copied into generated artifacts -- it serves only as generation-time constraints.

### Actions Are Defined Inline in WORKFLOW.md

Each action has a `## Action: <name>` section in the WORKFLOW.md body containing `### Instruction` with procedural guidance. Requirement links (clickable markdown links to spec requirements) live in the SKILL.md file for each action, not in WORKFLOW.md. When executing an action, the router reads the instruction from WORKFLOW.md and the requirement links from SKILL.md, loads the referenced requirements from specs, and spawns a sub-agent with bounded context.

### Router Dispatches All Commands

The single router handles intent recognition, change context detection (proposal frontmatter lookup, worktree fallback, directory listing fallback), WORKFLOW.md loading, and dispatch. For `propose`, it traverses the pipeline. For `apply` and `finalize`, it reads the action definition and spawns a sub-agent. For `init`, it executes directly without change context.

### Automation Configuration

The optional `automation.post_approval` section defines what happens when a PR receives all required review approvals: which action to execute (e.g., `finalize`) and which GitHub labels to use for state tracking (`running`, `complete`, `failed`). When absent, automation is treated as disabled.

## Known Limitations

- YAML frontmatter parsing depends on Claude's native ability to interpret YAML in markdown files.
- The `template-version` field is only used by init for merge detection; the router ignores it at runtime.
- Sub-agents spawned via the Agent tool do not receive the router's full conversation history.

## Edge Cases

- If WORKFLOW.md is missing, the router reports an error and suggests running `/opsx:workflow init`.
- If a Smart Template lacks YAML frontmatter, the router treats it as a plain template with no instruction or metadata and reports a warning.
- If a Smart Template is missing the `template-version` field, init treats it as version 0 (always eligible for update).
- If WORKFLOW.md contains malformed YAML, the router reports a parse error and stops.
- If the `pipeline` array is empty, the router reports that no artifacts are defined and stops.
- If an action name does not match a defined action, the router reports the error and lists available actions.
