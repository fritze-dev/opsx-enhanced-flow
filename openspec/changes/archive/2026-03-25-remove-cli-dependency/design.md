# Technical Design: Remove OpenSpec CLI Dependency

## Context

The opsx-enhanced-flow plugin currently requires the OpenSpec CLI (`@fission-ai/openspec@^1.2.0`) as a runtime dependency. 11 of 13 skills shell out to CLI commands for schema resolution, artifact status, change management, and instruction retrieval. All data the CLI provides already exists in local files — `schema.yaml`, templates, config.yaml, and the directory structure. Since skills are executed by Claude (an LLM that natively reads YAML), the CLI is unnecessary indirection.

Affected systems: all 13 skills, 4 specs, constitution, README, devcontainer, settings.

## Architecture & Components

**Core change:** Replace CLI subprocess calls with direct file reads.

Skills currently follow this pattern:
```
Skill → Bash(openspec <command> --json) → parse JSON → act on result
```

After this change:
```
Skill → Read(schema.yaml) + Read(template) + check file existence → act directly
```

**Files affected:**
- `skills/*/SKILL.md` — all 13 skill files
- `openspec/constitution.md` — remove CLI from Tech Stack
- `openspec/schemas/opsx-enhanced/README.md` — remove CLI requirement
- `README.md` — remove CLI prerequisite
- `.devcontainer/devcontainer.json` — remove Node.js feature + npm install
- `.claude/settings.local.json` — remove openspec CLI permissions

**Files NOT affected:**
- `openspec/schemas/opsx-enhanced/schema.yaml` — stays identical
- `openspec/schemas/opsx-enhanced/templates/*.md` — stay identical
- `openspec/config.yaml` — stays identical
- `openspec/changes/archive/*` — all archived changes stay as-is

## Goals & Success Metrics

* No skill references `openspec` as a CLI command (grep returns zero matches for `openspec --`, `openspec schema`, `openspec new`, `openspec list`, `openspec status`, `openspec instructions`, `openspec archive` in skills)
* `/opsx:setup` works without Node.js/npm installed
* Full pipeline (`/opsx:new` → `/opsx:ff` → `/opsx:apply`) completes using only file reads
* README does not mention npm or CLI as a prerequisite
* devcontainer does not install Node.js or openspec

## Non-Goals

- Changing schema.yaml format or structure
- Changing template files
- Adding multi-schema support beyond the existing config.yaml indirection
- Migrating archived changes or removing inert `.openspec.yaml` metadata files
- Refactoring skill structure or consolidating skills

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Skills read schema.yaml directly via Read tool | Claude natively understands YAML; simpler than spawning CLI subprocesses; zero dependencies | Bash YAML parser (fragile), keep CLI as optional (two code paths) |
| Artifact status via file existence checks | CLI already used file existence internally; same logic, no wrapper needed | Status tracking file (over-engineered), database (absurd for this use case) |
| Change creation via `mkdir -p` | CLI's `openspec new change` only creates a directory + metadata file; mkdir is sufficient | Keep CLI for this one command (inconsistent) |
| Change listing via directory listing | CLI's `openspec list --json` only lists directories under changes/; trivial to replicate | Keep CLI for this one command (inconsistent) |
| Remove Node.js feature from devcontainer | Only installed for CLI; no other Node.js dependency exists | Keep it "just in case" (unnecessary bloat) |
| Keep config.yaml → schema path indirection | Preserves extensibility for future multi-schema support without over-engineering now | Hardcode path (loses flexibility) |

## Risks & Trade-offs

- **Skills become slightly more verbose** → Acceptable: the "read schema.yaml" instruction is ~4 lines vs a CLI command that was ~2 lines. Net complexity is lower because there's no JSON parsing step.
- **No programmatic schema validation** → Low risk: schema.yaml is checked into git and version-controlled. If it's readable, it's valid. The CLI's `schema validate` only checked YAML syntax.
- **Breaking change for existing consumers** → No actual risk: consumers already have schema files copied locally. The CLI was only used at runtime by skills. New setup skips CLI installation; existing setups continue to work because the CLI is just unused.

## Open Questions

No open questions.

## Assumptions

- Claude can reliably read and interpret YAML files via the Read tool. This is verified by extensive existing usage across the codebase. <!-- ASSUMPTION: Claude YAML comprehension -->
- No consumer project relies on the OpenSpec CLI independently of the skills (i.e., no one runs `openspec status` manually in their terminal as part of their workflow). <!-- ASSUMPTION: No direct CLI usage by consumers -->
No further assumptions beyond those marked above.
