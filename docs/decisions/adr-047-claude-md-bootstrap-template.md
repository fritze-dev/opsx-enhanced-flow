# ADR-047: New `src/templates/claude.md` Bootstrap Template

## Status
Accepted (2026-04-10)

## Context
Consumer projects initialized via `/opsx:workflow init` need to receive a CLAUDE.md file with standard agent directives (workflow compliance and knowledge transparency). The plugin already uses a template pattern for constitution generation (`src/templates/constitution.md`), where a template file with frontmatter metadata is shipped with the plugin and used by init to generate project files. CLAUDE.md generation needed to follow the same pattern for consistency.

## Decision
Create a new `src/templates/claude.md` bootstrap template following the established template pattern -- with frontmatter containing `id: claude`, `generates: CLAUDE.md`, and `requires: []`, alongside the template body with `## Workflow` and `## Knowledge Management` sections. The template `id: claude` matches the artifact name convention used by other templates. Init generates CLAUDE.md from this template during Fresh mode, adapting it with project-specific rules discovered during the codebase scan.

## Alternatives Considered
- **Inline generation in init instruction (no template)**: Would work but is inconsistent with the template pattern used for constitution.md and other artifacts. Inline generation makes the content harder to maintain and version.
- **No template (consumers never get CLAUDE.md)**: Consumers would need to manually create CLAUDE.md, which defeats the purpose of one-command setup. Most consumers would never add the knowledge management directive.

## Consequences

### Positive
- Consumer projects get CLAUDE.md automatically during init, with no manual setup required
- Consistent with the existing template pattern (constitution.md, workflow.md)
- Template content is easy to maintain and version in a single file
- Template `id` field enables future template merge detection on re-init

### Negative
- One more template file to maintain (small surface area -- ~20 lines of content)
- Changes to CLAUDE.md directives require updating the template and bumping its version

## References
- Change: openspec/changes/2026-04-10-transparent-knowledge-management/
- Spec: openspec/specs/project-init/spec.md
- Issue: #69
