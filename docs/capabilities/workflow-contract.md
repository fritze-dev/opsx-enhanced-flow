---
title: "Workflow Contract"
capability: "workflow-contract"
description: "Defines the WORKFLOW.md pipeline orchestration format, Smart Template format with template versioning, and the skill reading pattern."
lastUpdated: "2026-04-08"
---

# Workflow Contract

WORKFLOW.md and Smart Templates provide the declarative contract that all skills read to understand the pipeline structure, artifact definitions, and generation instructions.

## Purpose

Without a standardized contract format, pipeline configuration scatters across multiple files, instructions live separately from their templates, and skills must hardcode assumptions about where to find artifact definitions. The workflow contract centralizes pipeline orchestration in a single WORKFLOW.md file and makes each template self-describing, so that skills interact with the pipeline through a consistent, inspectable interface.

## Rationale

A slim WORKFLOW.md handles pipeline orchestration (stage ordering, apply gate, post-artifact hook, project context) while Smart Templates handle artifact definitions (instruction, output path, dependencies). This separation keeps WORKFLOW.md concise and makes each template a self-contained unit that carries its own metadata in YAML frontmatter. Both WORKFLOW.md and Smart Templates include a `template-version` field (integer) that enables `/opsx:setup` to detect user customizations and merge plugin updates instead of overwriting. The field is named `template-version` (not `version`) to distinguish it from the spec `version` field, which tracks content changes. Skills follow a uniform reading pattern: read WORKFLOW.md for pipeline-level config, then read individual Smart Templates for artifact-level details.

## Features

- **WORKFLOW.md pipeline orchestration** -- a single markdown file with YAML frontmatter containing `templates_dir`, `pipeline` array, `apply` gate, `post_artifact` hook, `context` pointer, optional `docs_language`, and `template-version`
- **Smart Template format** -- each template carries `id`, `description`, `generates`, `requires`, `instruction`, and `template-version` fields in YAML frontmatter, with the output structure as the markdown body
- **Template versioning** -- the `template-version` field (integer, monotonically increasing) enables `/opsx:setup` to detect customized templates and merge plugin updates rather than overwriting local changes
- **Uniform skill reading pattern** -- all skills follow the same steps: read WORKFLOW.md, resolve template paths, check artifact status via file existence, apply template instructions as constraints

## Behavior

### WORKFLOW.md Provides Pipeline Configuration

Skills read WORKFLOW.md's YAML frontmatter to determine the template directory location, the ordered list of pipeline stages, the apply gate requirements, the post-artifact hook instructions, and the `template-version`. The markdown body provides supplementary documentation about the workflow but is not parsed programmatically by skills.

### Smart Templates Are Self-Describing

Each template file contains everything needed to generate its artifact: the `instruction` field provides behavioral constraints for the AI, the `generates` field specifies where the output goes, `requires` lists dependency artifacts, and the markdown body defines the output structure. The `instruction` content is never copied into generated artifacts -- it serves only as generation-time constraints. The `template-version` field enables `/opsx:setup` to detect whether the template has been customized since installation.

### Skills Follow a Consistent Reading Pattern

Every artifact-generating skill follows the same sequence: (1) read WORKFLOW.md frontmatter for pipeline configuration, (2) read the constitution via the `context` field, (3) for each pipeline artifact, read its Smart Template for instruction, output path, and dependencies, (4) check artifact status via file existence, (5) generate the artifact using the template body as structure and the instruction as constraints, (6) execute the post-artifact hook.

## Known Limitations

- YAML frontmatter parsing depends on Claude's native ability to interpret YAML in markdown files.
- The `template-version` field is only used by setup for merge detection; skills other than setup ignore it at runtime.

## Edge Cases

- If WORKFLOW.md is missing, skills report an error and suggest running `/opsx:setup`.
- If a Smart Template lacks YAML frontmatter, skills treat it as a plain template with no instruction or metadata and report a warning.
- If a Smart Template is missing the `template-version` field, setup treats it as version 0 (always eligible for update).
- If WORKFLOW.md contains malformed YAML, skills report a parse error and stop.
- If the `pipeline` array is empty, skills report that no artifacts are defined and stop.
- If `templates_dir` points to a nonexistent directory, skills report the missing directory and suggest running `/opsx:setup`.
