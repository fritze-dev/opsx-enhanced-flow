# ADR-027: Remove OpenSpec CLI Dependency

## Status

Accepted (2026-03-25)

## Context

The opsx-enhanced-flow plugin required the OpenSpec CLI (`@fission-ai/openspec@^1.2.0`) as a globally-installed npm package, making Node.js and npm prerequisites for using the plugin. Eleven of thirteen skills shelled out to CLI commands for schema resolution, artifact status, change management, and instruction retrieval. However, all data the CLI provided already existed in local files -- `schema.yaml`, templates, `config.yaml`, and the directory structure. Since skills are executed by Claude, which natively reads and interprets YAML, the CLI was unnecessary indirection that added an external dependency, slowed execution (subprocess spawning), and complicated setup for new users. Investigation confirmed that every CLI command had a straightforward file-based replacement: `openspec status` mapped to file-existence checks, `openspec new change` mapped to `mkdir -p`, `openspec list` mapped to directory listing, and `openspec instructions` mapped to direct schema.yaml reads.

## Decision

1. **Skills read schema.yaml directly via the Read tool** -- Claude natively understands YAML, making this simpler than spawning CLI subprocesses with zero external dependencies. The alternative of a bash YAML parser would be fragile, and keeping the CLI as optional would create two code paths to maintain.
2. **Artifact status is computed via file existence checks** -- the CLI already used file existence internally, so the same logic applies without a wrapper. A separate status tracking file or database would be over-engineered for this use case.
3. **Change creation uses `mkdir -p`** -- the CLI's `openspec new change` only created a directory plus a metadata file; `mkdir` is sufficient. Keeping the CLI for just this one command would be inconsistent with the rest of the change.
4. **Change listing uses directory listing** -- the CLI's `openspec list --json` only listed directories under `changes/`, which is trivial to replicate directly.
5. **Node.js feature removed from devcontainer** -- Node.js was only installed for the CLI and no other dependency requires it. Keeping it "just in case" would be unnecessary bloat.
6. **Config.yaml to schema path indirection preserved** -- this maintains extensibility for future multi-schema support without over-engineering now. Hardcoding the path would lose flexibility.

## Alternatives Considered

- **Thin bash wrapper script** replacing CLI: would add a new dependency and bash YAML parsing is fragile
- **Keep CLI as optional** with two code paths: does not achieve the simplification goal and doubles maintenance burden
- **Keep Node.js feature in devcontainer** "just in case": unnecessary bloat with no current consumer
- **Hardcode schema path** instead of config.yaml indirection: loses multi-schema extensibility

## Consequences

### Positive

- Setup no longer requires Node.js or npm, reducing prerequisites to just Claude Code
- Faster skill execution by eliminating CLI subprocess spawning
- The plugin is fully self-contained with no external runtime dependencies
- Simpler onboarding for new users -- no npm global install permission issues
- One fewer moving part to version-manage and keep compatible

### Negative

- Skills are slightly more verbose (file-read instructions replace shorter CLI commands), though net complexity is lower without JSON parsing
- No programmatic schema validation via CLI's `schema validate` -- low risk since schema.yaml is version-controlled and read errors are caught at runtime
- Breaking change for the setup skill (no longer installs CLI), though no consumer migration is needed since schema files were already copied locally

## References

- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [Spec: three-layer-architecture](../../openspec/specs/three-layer-architecture/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: artifact-generation](../../openspec/specs/artifact-generation/spec.md)
- [Spec: change-workspace](../../openspec/specs/change-workspace/spec.md)
- [Spec: task-implementation](../../openspec/specs/task-implementation/spec.md)
- [Spec: interactive-discovery](../../openspec/specs/interactive-discovery/spec.md)
- [Change archive](../../openspec/changes/archive/2026-03-25-remove-cli-dependency/)
