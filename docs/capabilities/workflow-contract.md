---
title: "Workflow Contract"
capability: "workflow-contract"
description: "Defines the WORKFLOW.md pipeline orchestration format, Smart Template format with artifact and action types, and the skill reading pattern."
lastUpdated: "2026-04-09"
---

# Workflow Contract

WORKFLOW.md and Smart Templates provide the declarative contract that all skills read to understand the pipeline structure, step definitions, and execution instructions.

## Purpose

Without a standardized contract format, pipeline configuration scatters across multiple files, instructions live separately from their templates, and skills must hardcode assumptions about where to find step definitions. The workflow contract centralizes pipeline orchestration in a single WORKFLOW.md file and makes each template self-describing, so that skills interact with the pipeline through a consistent, inspectable interface.

## Rationale

WORKFLOW.md uses a clean separation: structured config in YAML frontmatter (template directory, pipeline array, worktree settings, automation config) and prose instructions in markdown body sections (context, post-artifact hook). This prevents the frontmatter from growing unwieldy with multi-line strings. Smart Templates carry their own metadata in YAML frontmatter, supporting two types: artifact templates that generate files and action templates that execute skills. Both types include a `template-version` field (integer) for merge detection during `/opsx:setup`. Skills follow a uniform reading pattern: read WORKFLOW.md for pipeline-level config and body sections, then read individual Smart Templates for step-level details.

## Features

- **WORKFLOW.md pipeline orchestration** -- a single markdown file with structured config in frontmatter (`templates_dir`, `pipeline`, `apply`, `worktree`, `automation`) and prose instructions in body sections (`## Context`, `## Post-Artifact Hook`)
- **Smart Template format** -- each template carries `id`, `description`, `requires`, `instruction`, and `template-version` in YAML frontmatter; artifact templates additionally have `generates` and an output structure body
- **Action template type** -- pipeline steps with `type: action` execute skills instead of generating files; actions handle their own idempotency and are always executed when dependencies are met
- **Template versioning** -- the `template-version` field enables `/opsx:setup` to detect customized templates and merge plugin updates rather than overwriting local changes
- **Uniform skill reading pattern** -- all skills follow the same steps: read WORKFLOW.md frontmatter for config, body for instructions, resolve templates, check step status, execute
- **Automation configuration** -- optional `automation.post_approval` section defines CI pipeline steps and label state machine for post-approval automation
- **Full pipeline execution** -- `/opsx:ff` processes both artifact and action steps, enabling end-to-end pipeline execution with `--auto-approve` for autonomous mode

## Behavior

### WORKFLOW.md Provides Pipeline Configuration

Skills read WORKFLOW.md's YAML frontmatter to determine the template directory, the pipeline step array, the apply gate, worktree settings, and automation configuration. The markdown body contains the `## Context` section (behavioral context like constitution reference) and the `## Post-Artifact Hook` section (commit, push, and draft PR instructions). Frontmatter contains only structured data — no multi-line prose.

### Smart Templates Are Self-Describing

Each template file contains everything needed to execute its step. Artifact templates (`type: artifact` or no `type` field) include `generates` for the output path and a markdown body defining the output structure. Action templates (`type: action`) include only `instruction` and `requires` — they execute skills and do not generate files in the change directory. The `instruction` content is never copied into generated artifacts.

### Action Steps Are Always Executed

When the pipeline reaches an action step whose dependencies are satisfied, the step is executed regardless of prior runs. The action itself determines what work remains (for example, `/opsx:apply` checks which tasks are still open, `/opsx:changelog` checks which entries already exist). This eliminates the need for external status tracking.

### Skills Follow a Consistent Reading Pattern

Every pipeline skill follows the same sequence: (1) read WORKFLOW.md frontmatter for config, (2) read the `## Context` body section for behavioral context, (3) for each step in the pipeline, read its Smart Template, (4) check step status (file existence for artifacts, always-execute for actions), (5) execute the step — generate an artifact or spawn a sub-agent for an action, (6) for artifact steps, execute the `## Post-Artifact Hook`.

### Sub-Agent Execution for Action Steps

When `/opsx:ff` processes an action step, it spawns an isolated sub-agent via the Agent tool. The sub-agent receives the template's instruction and only the artifacts listed in `requires` — not the full conversation history. This bounded-context approach prevents context window exhaustion during full pipeline execution.

### Automation Configuration

The optional `automation.post_approval` section in WORKFLOW.md frontmatter defines CI pipeline behavior: which steps to run after PR approval, and which labels to use for state tracking. GitHub Action workflows read this configuration rather than hardcoding steps, keeping WORKFLOW.md as the single source of truth.

### Full Pipeline with Human Gate

`/opsx:ff` processes the entire `pipeline` array including action steps. After the verify step passes, ff pauses for explicit human approval before proceeding to post-apply steps. The `--auto-approve` flag skips this gate for autonomous execution.

## Known Limitations

- YAML frontmatter parsing depends on Claude's native ability to interpret YAML in markdown files.
- The `template-version` field is only used by setup for merge detection; skills other than setup ignore it at runtime.
- Sub-agents spawned for action steps share the same filesystem but have no access to the orchestrator's conversation context.

## Edge Cases

- If WORKFLOW.md is missing, skills report an error and suggest running `/opsx:setup`.
- If a Smart Template lacks YAML frontmatter, skills treat it as a plain template with no instruction or metadata and report a warning.
- If a Smart Template is missing the `template-version` field, setup treats it as version 0 (always eligible for update).
- If WORKFLOW.md contains malformed YAML, skills report a parse error and stop.
- If the `pipeline` array is empty, skills report that no artifacts are defined and stop.
- If a pipeline step has no corresponding template file, skills report the missing template and stop.
- If a sub-agent fails mid-pipeline, the orchestrator reports the error and stops; previously completed steps remain on disk.
- If the `## Context` or `## Post-Artifact Hook` body sections are missing, skills fall back to the frontmatter `context` and `post_artifact` fields (backward compatibility for template-version 1).
