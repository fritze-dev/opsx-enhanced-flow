# ADR-055: Tool-Agnostic GitHub Operations

## Status

Accepted (2026-04-11)

## Context

The plugin's specs, skills, constitution, and README contained hardcoded references to the `gh` CLI for GitHub operations (PR creation, PR merging, PR status checks). Claude Code Web environments use built-in MCP tools for GitHub instead of the `gh` CLI, meaning these references were inaccurate and potentially confusing in non-desktop contexts. Issue #114 requested decoupling from any specific GitHub tooling.

## Decision

1. **Use "available GitHub tooling" as the umbrella term** covering `gh` CLI, MCP tools, and direct REST API access. This phrase is used consistently across specs, capability docs, skills, and the constitution wherever GitHub operations are referenced.

2. **Keep `git branch -d` fallback wording unchanged**. Git branch operations are already tool-agnostic (they use git directly, not GitHub tooling), so no changes were needed for branch deletion fallback logic.

3. **Rewrite the README setup section completely** rather than appending an MCP mention. MCP tools are documented as the primary integration path (they require zero setup in Claude Code Web), with `gh` CLI listed as an optional alternative for desktop users.

## Alternatives Considered

- **Add MCP alongside `gh` references**: Would create inconsistent dual-mention patterns ("use `gh` or MCP tools") throughout the codebase, increasing maintenance burden.
- **Replace `gh` with MCP-specific references**: Would merely swap one tool-specific coupling for another.
- **Abstract behind a plugin-internal wrapper**: Over-engineered — the plugin instructs the AI agent, which already knows what tools are available in its environment.

## Consequences

### Positive

- Plugin works correctly in Claude Code Web (MCP tools), desktop (gh CLI), and any future GitHub integration without documentation changes
- Single consistent phrasing reduces cognitive load for contributors
- README accurately reflects the zero-setup experience for Claude Code Web users

### Negative

- Slightly less specific guidance for users who only know `gh` CLI (mitigated by the README section documenting `gh` as an alternative)

## References

- [Issue #114](https://github.com/fritze-dev/opsx-enhanced-flow/issues/114)
- [Change: tool-agnostic-github-ops](../../openspec/changes/2026-04-11-tool-agnostic-github-ops/)
