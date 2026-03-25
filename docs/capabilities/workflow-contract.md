---
title: "Workflow Contract"
capability: "workflow-contract"
description: "Defines the WORKFLOW.md pipeline orchestration format, Smart Template format, and the skill reading pattern that skills use to interact with the pipeline."
lastUpdated: "2026-03-26"
---

# Workflow Contract

WORKFLOW.md and Smart Templates provide the declarative contract that all skills read to understand the pipeline structure, artifact definitions, and generation instructions.

## Purpose

Without a standardized contract format, pipeline configuration scatters across multiple files, instructions live separately from their templates, and skills must hardcode assumptions about where to find artifact definitions. The workflow contract centralizes pipeline orchestration in a single WORKFLOW.md file and makes each template self-describing, so that skills interact with the pipeline through a consistent, inspectable interface.

## Rationale

A slim WORKFLOW.md handles pipeline orchestration (stage ordering, apply gate, post-artifact hook, project context) while Smart Templates handle artifact definitions (instruction, output path, dependencies). This separation keeps WORKFLOW.md concise and makes each template a self-contained unit that carries its own metadata in YAML frontmatter -- a pattern familiar from static site generators like Jekyll and Hugo. Template variable substitution uses simple string replacement for tokens like `{{ change.name }}`, avoiding the complexity of a full template engine while covering the most common use cases. Skills follow a uniform reading pattern: read WORKFLOW.md for pipeline-level config, then read individual Smart Templates for artifact-level details.

## Features

- **WORKFLOW.md pipeline orchestration** -- a single markdown file with YAML frontmatter containing `templates_dir`, `pipeline` array, `apply` gate, `post_artifact` hook, `context` pointer, and optional `docs_language`
- **Smart Template format** -- each template carries `id`, `description`, `generates`, `requires`, and `instruction` fields in YAML frontmatter, with the output structure as the markdown body
- **Template variable substitution** -- `{{ change.name }}`, `{{ change.stage }}`, and `{{ project.name }}` are replaced before using template content; unknown tokens are left as-is
- **Uniform skill reading pattern** -- all skills follow the same steps: read WORKFLOW.md, resolve template paths, check artifact status via file existence, apply template instructions as constraints

## Behavior

### WORKFLOW.md Provides Pipeline Configuration

Skills read WORKFLOW.md's YAML frontmatter to determine the template directory location, the ordered list of pipeline stages, the apply gate requirements, and the post-artifact hook instructions. The markdown body provides supplementary documentation about the workflow but is not parsed programmatically by skills.

### Smart Templates Are Self-Describing

Each template file contains everything needed to generate its artifact: the `instruction` field provides behavioral constraints for the AI, the `generates` field specifies where the output goes, `requires` lists dependency artifacts, and the markdown body defines the output structure. The `instruction` content is never copied into generated artifacts -- it serves only as generation-time constraints.

### Template Variables Are Resolved at Generation Time

Before using a template's body content, skills replace `{{ change.name }}` with the current change directory name, `{{ change.stage }}` with the artifact being generated, and `{{ project.name }}` with the project name from WORKFLOW.md or the repository name. Unrecognized `{{ tokens }}` remain as-is.

### Skills Follow a Consistent Reading Pattern

Every artifact-generating skill follows the same sequence: (1) read WORKFLOW.md frontmatter for pipeline configuration, (2) read the constitution via the `context` field, (3) for each pipeline artifact, read its Smart Template for instruction, output path, and dependencies, (4) check artifact status via file existence, (5) generate the artifact using the template body as structure and the instruction as constraints, (6) execute the post-artifact hook.

## Known Limitations

- Template variable substitution uses simple string replacement, not a full template engine. Conditional logic and loops are not supported.
- YAML frontmatter parsing depends on Claude's native ability to interpret YAML in markdown files.
- Only three template variables are defined (`change.name`, `change.stage`, `project.name`). Custom variables are not supported.

## Edge Cases

- If WORKFLOW.md is missing, skills report an error and suggest running `/opsx:setup`.
- If a Smart Template lacks YAML frontmatter, skills treat it as a plain template with no instruction or metadata and report a warning.
- If WORKFLOW.md contains malformed YAML, skills report a parse error and stop.
- If the `pipeline` array is empty, skills report that no artifacts are defined and stop.
- If `templates_dir` points to a nonexistent directory, skills report the missing directory and suggest running `/opsx:setup`.
