# ADR-050: Declarative Plugin Install via Marketplace Fields

## Status
Accepted (2026-04-11)

## Context
The plugin needs to auto-install in Claude Code Web cloud sessions without user intervention. Cloud sessions clone the repo and read `.claude/settings.json` at startup. The plugin install mechanism must be reliable and not depend on timing or script execution order.

## Decision
Use `extraKnownMarketplaces` and `enabledPlugins` fields in `.claude/settings.json` for declarative plugin installation -- Claude Code reads these fields at session start and installs the declared plugin automatically without any script execution. The SessionStart hook is reserved solely for system-level dependencies (`gh` CLI).

## Alternatives Considered
- **`claude plugin` commands in SessionStart hook**: Would require the plugin system to be ready before the hook runs, introducing timing issues and making the install more fragile than the declarative approach.

## Consequences

### Positive
- Plugin installs reliably at session start with no timing dependencies
- Clear separation of concerns: declarative config for plugin, script for system dependencies

### Negative
- Depends on Claude Code supporting the `extraKnownMarketplaces` + `enabledPlugins` fields as documented

## References
- Change: openspec/changes/2026-04-11-claude-code-web-setup/
- Spec: openspec/specs/project-init/spec.md
- Issue: #14
