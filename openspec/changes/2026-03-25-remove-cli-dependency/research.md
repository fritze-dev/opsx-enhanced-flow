# Research: Remove OpenSpec CLI Dependency

## 1. Current State

The opsx-enhanced-flow plugin depends on the OpenSpec CLI (`@fission-ai/openspec@^1.2.0`) as a globally-installed npm package. 11 of 13 skills shell out to it for:

- **Schema resolution**: `openspec schema which opsx-enhanced --json` → returns filesystem path to schema directory
- **Change creation**: `openspec new change "<name>"` → creates `openspec/changes/<name>/` directory
- **Change listing**: `openspec list --json` → lists directories under `openspec/changes/`
- **Artifact status**: `openspec status --change "<name>" --json` → checks file existence against `generates` fields
- **Artifact instructions**: `openspec instructions <id> --change "<name>" --json` → returns instruction, template, context, deps from schema.yaml
- **Schema validation**: `openspec schema validate opsx-enhanced` → validates schema.yaml is valid YAML
- **Schema registration**: `openspec schema init opsx-enhanced --force` → registers schema for CLI lookup
- **Archiving**: `openspec archive change "<name>"` → moves change to `archive/YYYY-MM-DD-<name>`

All information the CLI provides is already present in local files:
- `openspec/schemas/opsx-enhanced/schema.yaml` contains all artifact definitions, dependencies, instructions
- `openspec/schemas/opsx-enhanced/templates/*.md` contains all templates
- `openspec/config.yaml` contains the schema reference
- Directory structure under `openspec/changes/` provides status and listing

### Affected files

**Skills (13):** All `skills/*/SKILL.md` files. Setup needs major rework; 8 skills need moderate changes (CLI calls → file reads); 4 skills need minor changes (frontmatter cleanup or single CLI call replacement).

**Documentation & config (5):** `openspec/constitution.md`, `openspec/schemas/opsx-enhanced/README.md`, `README.md`, `.devcontainer/devcontainer.json`, `.claude/settings.local.json`.

**Specs affected (3):** `project-setup`, `three-layer-architecture`, `artifact-pipeline` — all reference CLI as part of the architecture.

### Stale-spec risks

The specs currently describe CLI-dependent behavior:
- `project-setup/spec.md`: "Install OpenSpec CLI globally via npm", "register schema via `openspec schema init`", CLI prerequisite check requirement
- `three-layer-architecture/spec.md`: "skills depend on schema via CLI", "schema is loaded by the OpenSpec CLI"
- `artifact-pipeline/spec.md`: "OpenSpec CLI enforces artifact dependency checks"

These specs will need delta modifications to reflect the new CLI-free architecture.

## 2. External Research

Not applicable — this is an internal refactoring. The OpenSpec CLI is an open-source tool by Fission AI, but we are removing the dependency, not integrating something new.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Skills read schema.yaml directly** (Claude interprets YAML natively) | Zero external dependencies; simplest implementation; Claude already parses YAML well | Skills are slightly more verbose (include file-read instructions instead of CLI commands) |
| **B: Thin bash wrapper script** replacing CLI | Single script, skills call one tool | Adds a new dependency (script); bash YAML parsing is fragile; over-engineered |
| **C: Keep CLI but make it optional** | Backward compatible | Doesn't achieve the goal; two code paths to maintain |

**Recommended: Approach A.** Claude natively reads and interprets YAML. The skills already consume CLI output by having Claude parse JSON — reading schema.yaml directly is simpler.

## 4. Risks & Constraints

- **Spec drift**: Three specs reference CLI-dependent behavior and need delta updates. If we forget, specs become stale.
- **Consumer migration**: Projects that already ran `/opsx:setup` with the old CLI-based version have schema files copied locally already — no migration needed. The CLI was only used during runtime, and local files are identical.
- **Multi-schema support**: Currently only one schema (`opsx-enhanced`) exists. The `config.yaml → schema name → path` indirection preserves multi-schema capability.
- **Archived `.openspec.yaml` files**: The CLI created metadata files in change directories. These are inert — no skill reads them. They can stay.
- **devcontainer**: Currently installs Node.js (for CLI) and npm. After removal, the `node` feature can be removed if nothing else needs it.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Remove all CLI calls from 13 skills + update docs/config |
| Behavior | Clear | Each CLI call has a direct file-based replacement |
| Data Model | Clear | No data model changes — same files, same structure |
| UX | Clear | User-facing commands unchanged; setup becomes simpler (no npm prerequisite) |
| Integration | Clear | No external integrations affected (gh CLI, git remain) |
| Edge Cases | Clear | Archived changes unaffected; consumer migration not needed |
| Constraints | Clear | Must go through opsx flow per CLAUDE.md |
| Terminology | Clear | "OpenSpec CLI" references become "schema.yaml" references |
| Non-Functional | Clear | Faster execution (no CLI subprocess spawning) |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use Approach A: direct schema.yaml reads | Zero dependencies; Claude natively parses YAML; simpler than CLI JSON parsing | Bash wrapper script (fragile YAML parsing); optional CLI (two code paths) |
| 2 | Keep config.yaml → schema path indirection | Preserves multi-schema extensibility without over-engineering | Hardcode path (loses flexibility) |
| 3 | Update specs via delta specs (project-setup, three-layer-architecture, artifact-pipeline) | Specs must reflect actual architecture; prevents stale-spec debt | Skip spec updates (creates drift) |
| 4 | Remove Node.js feature from devcontainer | Only needed for CLI; nothing else requires it | Keep it (unnecessary dependency) |
