# ADR-052: No settings.json Template in src/templates/

## Status
Accepted (2026-04-11)

## Context
The plugin uses Smart Templates in `src/templates/` for pipeline artifacts that follow a standard pattern. The question arose whether `.claude/settings.json` should also be a Smart Template, since init generates it for consumer projects.

## Decision
Do not add a settings.json Smart Template -- the file is project-specific (marketplace references vary per consumer repo) and is a configuration file, not a pipeline artifact. Init generates it inline based on the project's GitHub repo context.

## Alternatives Considered
- **Smart Template approach**: Over-engineered for a simple config file; marketplace references would need template variable substitution that the existing template system does not support.

## Consequences

### Positive
- No template maintenance overhead for a file that varies per project
- Keeps the template system focused on pipeline artifacts

### Negative
- Init logic for settings.json generation is inline rather than template-driven; changes to the settings format require updating the init instruction

## References
- Change: openspec/changes/2026-04-11-claude-code-web-setup/
- Spec: openspec/specs/project-init/spec.md
- Issue: #14
