---
title: "Workflow Contract"
capability: "workflow-contract"
description: "WORKFLOW.md pipeline orchestration, Smart Templates, inline actions, custom actions, and router dispatch"
lastUpdated: "2026-04-10"
---

# Workflow Contract

WORKFLOW.md, Smart Templates, and inline action definitions provide the declarative contract that the router reads to understand the pipeline structure, artifact definitions, action instructions, and automation configuration.

## Purpose

Without a standardized contract format, pipeline configuration scatters across multiple files, action instructions live separately from their templates, and commands must hardcode assumptions about where to find artifact definitions. The workflow contract centralizes pipeline orchestration, action definitions, and automation config in a single WORKFLOW.md file and makes each template self-describing, so that the router interacts with the pipeline through a consistent, inspectable interface.

## Rationale

A slim WORKFLOW.md handles pipeline orchestration (stage ordering, apply gate, project context) while Smart Templates handle artifact definitions (instruction, output path, dependencies). Actions are defined inline in WORKFLOW.md because they have no output structure -- separate action template files (as explored in PR #97) add maintenance overhead without benefit. The router dispatch pattern consolidates 11 separate skill files into a single router that reads WORKFLOW.md dynamically, eliminating copy-pasted logic like change context detection. Both WORKFLOW.md and Smart Templates include a `template-version` field (integer) that enables `/opsx:workflow init` to detect user customizations and merge plugin updates instead of overwriting. Custom actions extend this system by allowing consumer projects to add their own actions to the `actions` array without modifying the plugin source.

## Features

- **WORKFLOW.md pipeline orchestration** -- YAML frontmatter with `templates_dir`, `pipeline` array (7 stages), `actions` array, `template-version`, optional `worktree`, `auto_approve`, `automation`, and `docs_language`; markdown body with `## Context` and `## Action: <name>` sections
- **Smart Template format** -- each template carries `id`, `description`, `generates`, `requires`, `instruction`, and `template-version` fields in YAML frontmatter, with the output structure as the markdown body
- **Inline action definitions** -- `actions` array in frontmatter lists action names (built-in and custom); each action has a `## Action: <name>` body section with `### Instruction` for procedural guidance
- **Custom actions** -- consumer projects define additional actions by adding names to the `actions` array and writing corresponding `## Action: <name>` body sections with self-contained instructions; no plugin modification required
- **Router dispatch pattern** -- single router handles all commands (built-in and custom) with shared intent recognition, change context detection, and WORKFLOW.md loading; validates actions against the `actions` array with fallback to built-in list
- **Automation configuration** -- optional `automation.post_approval` section configures CI-triggered finalize on PR approval with state labels
- **Template versioning** -- `template-version` (integer, monotonically increasing) enables version-aware merge during `/opsx:workflow init`

## Behavior

### WORKFLOW.MD Provides Pipeline and Action Configuration

The router reads WORKFLOW.md's YAML frontmatter to determine the template directory, pipeline stage order, available actions, and optional automation config. The markdown body provides the `## Context` section for project-level behavioral context and `## Action: <name>` sections with procedural instructions for each action.

### Smart Templates Are Self-Describing

Each template file contains everything needed to generate its artifact: the `instruction` field provides behavioral constraints for the AI, the `generates` field specifies where the output goes, `requires` lists dependency artifacts, and the markdown body defines the output structure. The `instruction` content is never copied into generated artifacts -- it serves only as generation-time constraints.

### Built-in Actions Use Requirement Links from SKILL.md

Each built-in action (init, propose, apply, finalize) has a `## Action: <name>` section in the WORKFLOW.md body containing `### Instruction` with procedural guidance. Requirement links (clickable markdown links to spec requirements) live in the SKILL.md file, not in WORKFLOW.md. When executing a built-in action, the router reads the instruction from WORKFLOW.md and the requirement links from SKILL.md, loads the referenced requirements from specs, and spawns a sub-agent with bounded context.

### Custom Actions Execute Instructions Directly

Custom actions listed in the `actions` array have their `## Action: <name>` sections read by the router, which executes the instruction directly. The executing agent decides whether to handle it inline or spawn a sub-agent based on the instruction content. Custom actions do not receive spec requirement links -- their instruction text is self-contained. Custom actions go through change context detection (like apply/finalize), enabling them to operate on the current change.

### Router Validates Actions Dynamically

The router validates the invoked command against the `actions` array from WORKFLOW.md frontmatter. If WORKFLOW.md is missing (pre-init), the router falls back to the 4 built-in actions. If the action is not recognized, the router reports the error and lists available actions.

### Automation Configuration

The optional `automation.post_approval` section defines what happens when a PR receives all required review approvals: which action to execute (e.g., `finalize`) and which GitHub labels to use for state tracking (`running`, `complete`, `failed`). When absent, automation is treated as disabled.

## Known Limitations

- YAML frontmatter parsing depends on Claude's native ability to interpret YAML in markdown files.
- The `template-version` field is only used by init for merge detection; the router ignores it at runtime.
- Sub-agents spawned via the Agent tool do not receive the router's full conversation history.
- Custom action instruction quality depends on the author -- if the instruction is vague, execution may underperform.

## Edge Cases

- If WORKFLOW.md is missing, the router reports an error and suggests running `/opsx:workflow init`. For action validation, it falls back to the built-in actions list.
- If a Smart Template lacks YAML frontmatter, the router treats it as a plain template with no instruction or metadata and reports a warning.
- If a Smart Template is missing the `template-version` field, init treats it as version 0 (always eligible for update).
- If WORKFLOW.md contains malformed YAML, the router reports a parse error and stops.
- If the `pipeline` array is empty, the router reports that no artifacts are defined and stops.
- If an action name does not match any entry in the `actions` array, the router reports the error and lists available actions.
- If a custom action is listed in the `actions` array but has no corresponding `## Action: <name>` body section, the router reports the missing instruction and stops.
- Custom actions go through change context detection; if a custom action does not need change context, the instruction text should handle that.
