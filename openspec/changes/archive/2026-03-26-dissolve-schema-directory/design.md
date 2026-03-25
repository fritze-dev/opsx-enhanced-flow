# Technical Design: Dissolve Schema Directory

## Context

The plugin's three-layer architecture currently uses `openspec/schemas/opsx-enhanced/` as the schema layer — a leftover from the removed OpenSpec CLI. This directory contains schema.yaml (pipeline definition + instructions), templates/, and README.md. Instructions are separated from templates, config is split across schema.yaml and config.yaml, and two generation skills (continue, ff) duplicate checkpoint logic. PR #27 proposed a WORKFLOW.md concept but was never implemented and didn't address schema dissolution.

**Stakeholders**: Plugin maintainers, consumer projects using opsx-enhanced, AI agents executing skills.

**Constraints**:
- Skills are generic plugin code — MUST NOT be modified for project-specific behavior (constitution rule)
- No external runtime dependencies
- Must support migration from old layout

## Architecture & Components

### New File: `openspec/WORKFLOW.md`

Slim pipeline orchestration file with YAML frontmatter:

```yaml
---
templates_dir: openspec/templates
pipeline: [research, proposal, specs, design, preflight, tasks]

apply:
  requires: [tasks]
  tracks: tasks.md
  instruction: |
    [full apply instruction from current schema.yaml]

post_artifact: |
  [full post_artifact instruction from current schema.yaml]

context: |
  Always read and follow openspec/CONSTITUTION.md before proceeding.
  All workflow artifacts must be written in English regardless of docs_language.

# docs_language: English
---

# Workflow

Research → Propose → Specs → Design → Pre-Flight → Tasks → Apply → QA → Sync → Archive
```

### New Directory: `openspec/templates/`

All 10 templates moved from `openspec/schemas/opsx-enhanced/templates/` and converted to Smart Template format with YAML frontmatter:

```
openspec/templates/
├── research.md        ← frontmatter: id, generates, requires, instruction
├── proposal.md
├── design.md
├── preflight.md
├── tasks.md
├── constitution.md    ← used by bootstrap skill
├── specs/
│   └── spec.md
└── docs/
    ├── capability.md  ← used by docs skill
    ├── adr.md
    └── readme.md
```

### Renamed File: `openspec/CONSTITUTION.md`

Renamed from `openspec/constitution.md` (caps). Content updated to reflect new architecture:
- Tech Stack: YAML (WORKFLOW.md) replaces (schema.yaml, config.yaml)
- Architecture Rules: CONSTITUTION.md → WORKFLOW.md → Skills replaces Constitution → Schema → Skills
- Path references updated throughout

### Removed Files

| File | Replaced By |
|------|------------|
| `openspec/schemas/opsx-enhanced/schema.yaml` | WORKFLOW.md (orchestration) + Smart Templates (artifact defs) |
| `openspec/schemas/opsx-enhanced/README.md` | Removed (info in WORKFLOW.md body or project README) |
| `openspec/schemas/opsx-enhanced/templates/*` | Moved to `openspec/templates/` |
| `openspec/config.yaml` | WORKFLOW.md frontmatter |
| `skills/continue/SKILL.md` | Merged into `skills/ff/SKILL.md` |

### Skill Reading Pattern (New)

```
Skill invocation:
1. Read openspec/WORKFLOW.md frontmatter
   → templates_dir, pipeline[], apply{}, post_artifact, context
2. Read context (CONSTITUTION.md)
3. For each artifact in pipeline[]:
   Read <templates_dir>/<id>.md
   → Frontmatter: id, generates, requires, instruction
   → Body: output structure (with {{ variable }} substitution)
4. Check status: openspec/changes/<name>/<generates> exists?
5. Generate artifact: template body as structure, instruction as constraints
6. Execute post_artifact hook
```

### Template Variable Substitution

Simple string replacement before using template body:
- `{{ change.name }}` → current change directory name
- `{{ change.stage }}` → current artifact ID being generated
- `{{ project.name }}` → from WORKFLOW.md frontmatter or repo name
- Unknown `{{ tokens }}` → left as-is

Implementation: straight `str.replace()` per variable. No parsing, no template engine.

### FF Skill Changes

1. **Read WORKFLOW.md + Smart Templates** instead of schema.yaml + config.yaml
2. **Change selection for existing changes**: When invoked without name and changes exist, list active changes with AskUserQuestion (adopted from continue skill)
3. **Template variable substitution**: Replace `{{ }}` tokens before using template body
4. **References**: All `schema.yaml` → `WORKFLOW.md`, all `config.yaml` → `WORKFLOW.md`, all `/opsx:continue` → `/opsx:ff`

### Setup Skill Changes

Complete rewrite:
1. Copy `openspec/templates/` from plugin (Smart Templates)
2. Generate `openspec/WORKFLOW.md` from hardcoded template (not from plugin's own WORKFLOW.md)
3. Create `openspec/CONSTITUTION.md` placeholder if missing
4. **Migration**: Detect old layout → convert templates, generate WORKFLOW.md from schema.yaml, rename constitution, remove old files
5. Validate: check WORKFLOW.md readable, templates present, CONSTITUTION.md present

## Goals & Success Metrics

| Metric | Target | Verification |
|--------|--------|-------------|
| Schema directory removed | `openspec/schemas/` does not exist | PASS: `test ! -d openspec/schemas` |
| config.yaml removed | `openspec/config.yaml` does not exist | PASS: `test ! -f openspec/config.yaml` |
| WORKFLOW.md present | `openspec/WORKFLOW.md` exists and readable | PASS: `test -f openspec/WORKFLOW.md` |
| All Smart Templates have frontmatter | Every template in `openspec/templates/` has `id` field | PASS: grep all templates |
| No references to old paths | No `schema.yaml`, `config.yaml`, `/opsx:continue` in skills | PASS: grep returns 0 matches |
| continue skill removed | `skills/continue/` does not exist | PASS: `test ! -d skills/continue` |
| CONSTITUTION.md present | `openspec/CONSTITUTION.md` exists | PASS: `test -f openspec/CONSTITUTION.md` |
| Pipeline functions identically | All 6 artifacts generated in correct order | PASS: manual test with `/opsx:ff` on a test change |

## Non-Goals

- Moving WORKFLOW.md / CONSTITUTION.md to project root (separate follow-up)
- Full Liquid/Jinja2 template engine (simple `{{ }}` substitution only)
- Skill consolidation beyond continue→ff (planned separately per memory)
- Changing archive structure or spec format
- Backward-compatible runtime fallback to schema.yaml (migration is one-way)

## Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Smart Templates (instruction in template frontmatter) | Self-describing templates; single file per artifact; eliminates instruction/template split | Instructions in WORKFLOW.md body (too large); instructions in skills (violates DRY) |
| 2 | WORKFLOW.md for orchestration only | Slim file focused on pipeline ordering and cross-cutting config | Fat WORKFLOW.md with all instructions (300+ lines); no central config (config scattered across templates) |
| 3 | Explicit `pipeline:` array | Simple, readable, no computation needed | Topological sort from `requires:` (more complex, error-prone) |
| 4 | CONSTITUTION.md (caps) | Parallel naming to WORKFLOW.md; signals important project file | Keep lowercase (inconsistent with WORKFLOW.md) |
| 5 | One-way migration (no runtime fallback) | Simpler implementation; clean break from CLI legacy | Runtime fallback chain (adds complexity for temporary benefit) |
| 6 | Template variables via string replacement | Zero dependencies; sufficient for heading substitution | Full Liquid engine (overkill); no variables (less useful templates) |
| 7 | FF absorbs continue (no new parameters) | FF's existing checkpoint model covers all pause points; no step-by-step gap | Add `--step` parameter (unnecessary complexity) |

## Risks & Trade-offs

- **[Risk] Breaking consumer projects** → Mitigation: `/opsx:setup` migration logic detects old layout and converts automatically. Migration is well-defined and tested.
- **[Risk] Large number of files changing simultaneously** → Mitigation: All changes are tightly coupled and must happen together. The apply phase will work through them systematically.
- **[Risk] YAML frontmatter parsing edge cases** → Mitigation: Claude natively handles YAML in markdown. Smart Template format follows widely-used Jekyll/Hugo conventions.
- **[Risk] Users calling `/opsx:continue` get error** → Mitigation: Remove skill directory so Claude Code doesn't register it. Update all documentation and references.

## Open Questions

None — all questions resolved during planning phase.

## Assumptions

- Claude natively parses YAML frontmatter from markdown files when instructed to. <!-- ASSUMPTION: Claude YAML frontmatter parsing -->
- Simple string replacement for `{{ variable }}` tokens is sufficient for template rendering needs. <!-- ASSUMPTION: Simple substitution sufficient -->
- One-way migration is acceptable — no need to support both old and new layouts simultaneously at runtime. <!-- ASSUMPTION: One-way migration acceptable -->
No further assumptions beyond those marked above.
