# ADR-050: SessionStart Hook Only for gh CLI

## Status
Accepted (2026-04-11)

## Context
Cloud sessions need system-level dependencies (specifically `gh` CLI) installed. The plugin itself is handled declaratively via marketplace fields (ADR-049), so the SessionStart hook only needs to cover non-plugin dependencies.

## Decision
The SessionStart hook calls `scripts/setup-remote.sh` which handles only `gh` CLI installation and authentication -- no plugin installation logic. This keeps the hook focused on system-level concerns that cannot be handled declaratively.

## Alternatives Considered
- **Single script for everything (plugin + gh CLI)**: Mixes declarative and imperative concerns, duplicates the declarative plugin install capability, and is harder to reason about.

## Consequences

### Positive
- Clean separation: declarative config for plugin, imperative script for system tools
- Script is small and focused, easy to audit and maintain

### Negative
- Two mechanisms instead of one (settings.json fields + hook script); slightly more surface area to understand

## References
- Change: openspec/changes/2026-04-11-claude-code-web-setup/
- Spec: openspec/specs/project-init/spec.md
- Issue: #14
