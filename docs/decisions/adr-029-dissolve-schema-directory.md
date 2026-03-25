---
status: accepted
date: 2026-03-26
archive: 2026-03-26-dissolve-schema-directory
capabilities: [workflow-contract, three-layer-architecture, artifact-pipeline, artifact-generation, project-setup]
---

# ADR-029: Dissolve Schema Directory -- WORKFLOW.md + Smart Templates

## Context

The plugin's schema layer (`openspec/schemas/opsx-enhanced/`) was a leftover from the removed OpenSpec CLI. Instructions were separated from templates in schema.yaml, configuration was split across schema.yaml and config.yaml, and two generation skills (continue, ff) duplicated checkpoint logic. PR #27 had proposed a WORKFLOW.md concept inspired by OpenAI Symphony but was never implemented.

## Decision

Replace the schema directory with WORKFLOW.md for slim pipeline orchestration and Smart Templates for self-describing artifact definitions. WORKFLOW.md carries pipeline ordering, apply gate, post-artifact hook, and project context in YAML frontmatter. Each Smart Template carries its own instruction, output path, and dependencies in YAML frontmatter alongside the output structure as the markdown body -- following the Jekyll/Hugo frontmatter pattern. Template variables (`{{ change.name }}`, `{{ change.stage }}`, `{{ project.name }}`) use simple string replacement, avoiding a full template engine. The `pipeline:` array in WORKFLOW.md provides explicit ordering rather than relying on topological sort from `requires:` fields. CONSTITUTION.md (caps) parallels WORKFLOW.md naming. The continue skill merges into ff, which absorbs change-selection logic without adding new parameters. Migration from the old layout is one-way with no runtime fallback -- `/opsx:setup` detects the legacy structure and converts automatically.

## Consequences

- All 12 skills read WORKFLOW.md + Smart Templates instead of schema.yaml + config.yaml
- Templates are self-contained units with instruction, metadata, and output structure in a single file
- The schema directory, config.yaml, and continue skill are removed
- Consumer projects require a `/opsx:setup` re-run for migration
- The three-layer architecture becomes CONSTITUTION.md, WORKFLOW.md + Smart Templates, Skills
- `/opsx:ff` is the sole generation command with change selection for existing workspaces
