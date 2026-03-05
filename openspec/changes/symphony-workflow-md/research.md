# Research: Symphony WORKFLOW.md Concept Integration

## 1. Current State

### opsx-enhanced-flow Architecture
opsx-enhanced-flow is a Claude Code plugin providing a spec-driven development workflow. Project-level configuration lives in two files:

- **`openspec/constitution.md`** — free-form markdown with project rules, conventions, and constraints. Read by the AI at the start of every skill invocation as behavioral context.
- **`openspec/config.yaml`** — minimal YAML with `schema: opsx-enhanced` and a `context` block that instructs the AI to read the constitution.

The current split means:
- Machine-readable settings are minimal (only the schema reference)
- All behavioral rules live in the unstructured constitution markdown
- There is no YAML front matter convention for structured project settings
- No prompt template mechanism — the constitution is used as raw context, not rendered against issue/change data

### Existing Specs
All specs under `openspec/specs/` appear aligned with current behavior (verified by inspection of `artifact-pipeline`, `spec-format`, `roadmap-tracking`, `task-implementation`, and others). No stale-spec risks detected.

---

## 2. External Research

### Symphony SPEC.md (https://github.com/openai/symphony/blob/main/SPEC.md)
Symphony is a long-running agent orchestration service. Its core repository contract is `WORKFLOW.md`:

**Format**: Markdown file with optional YAML front matter.
```
---
tracker:
  kind: linear
  project_slug: my-project
  active_states: [Todo, In Progress]
polling:
  interval_ms: 30000
agent:
  max_concurrent_agents: 10
codex:
  approval_policy: auto-edit
  turn_timeout_ms: 3600000
hooks:
  after_create: |
    git clone https://github.com/org/repo .
---
You are working on an issue from Linear.

Issue: {{ issue.identifier }} — {{ issue.title }}
Description: {{ issue.description }}
{% if attempt %}Retry attempt: {{ attempt }}{% endif %}
```

Key concepts:
1. **YAML front matter** — structured machine-readable config (tracker, polling, workspace, hooks, agent, codex settings)
2. **Markdown body** — a Liquid-compatible prompt template rendered per-issue with variables like `{{ issue.title }}`, `{{ attempt }}`
3. **Repository-owned** — checked into the project repo, versioned alongside code
4. **Dynamically reloadable** — the orchestration service watches the file for changes and applies new settings to future runs without restart
5. **Strict template rendering** — unknown variables or filters fail loudly to prevent silent misbehavior

### Relevance to opsx-enhanced-flow
The `WORKFLOW.md` concept directly parallels `openspec/constitution.md` but adds:
- **Structured config via YAML front matter** instead of free-form prose
- **Template rendering** (prompt variables like `{{ change.name }}`, `{{ capability }}`)
- **Machine-readable settings** that the CLI/agent can validate and act on programmatically
- **Single authoritative file** instead of `constitution.md` + `config.yaml` split

---

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Introduce `WORKFLOW.md`** replacing `config.yaml` + `constitution.md` with a single file using YAML front matter + markdown body (Symphony-style) | Single authoritative project contract; machine-readable settings; template rendering; aligns with Symphony standard; clean separation of config vs. prose | Breaking change for existing projects; requires migration from current files |
| **B: Add YAML front matter to `constitution.md`** (constitution becomes the WORKFLOW.md equivalent) | Minimal disruption; no new file; existing constitution content preserved | Mixed concerns — YAML config lives in what is currently a pure prose file; risk of parsing friction |
| **C: Extend `config.yaml`** with a `prompt_template` field for the markdown body (inverted: YAML is primary, markdown is embedded) | No new file; config already machine-readable | Markdown prompt embedded in YAML is ergonomically poor; large prompts become unwieldy; not idiomatic |
| **D: Add `WORKFLOW.md` as an optional overlay** alongside existing files, using it when present and falling back to constitution + config otherwise | Zero breaking change; gradual adoption path; existing projects unaffected | Two conventions supported simultaneously adds complexity; documentation split |

**Recommended: Approach A** (with a migration path that makes it non-breaking by generating `WORKFLOW.md` during `/opsx:init` while keeping backward compatibility with legacy `constitution.md` if `WORKFLOW.md` is absent).

---

## 4. Risks & Constraints

- **Breaking change risk**: Replacing `constitution.md` + `config.yaml` with `WORKFLOW.md` affects every project using opsx-enhanced-flow. A migration guide and backward-compatibility fallback are needed.
- **Template engine scope**: Introducing Liquid-style rendering adds a new dependency and new failure modes (template parse errors, unknown variables). Scope should be limited initially to simple `{{ variable }}` substitution.
- **Agent awareness**: The AI agent must be instructed to parse and respect YAML front matter values from `WORKFLOW.md` — this is a prompt/skill change, not just a schema change.
- **Skill immutability constraint**: Per the constitution, skills in `skills/` MUST NOT be modified for project-specific behavior. The WORKFLOW.md feature must be implemented as constitution/schema/config changes, not skill edits.
- **CLI integration**: The OpenSpec CLI (`@fission-ai/openspec`) would need to be aware of `WORKFLOW.md` if machine-readable settings are to be validated at CLI level. This is an external dependency.
- **Dynamic reload**: Real dynamic reload (watching the file) requires an agent loop / daemon, which is out of scope for a Claude Code plugin. However, the file being version-controlled and re-read each session achieves the same goal.

---

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Replace constitution+config with Symphony-style WORKFLOW.md |
| Behavior | Clear | YAML front matter for config; markdown body as prompt template |
| Data Model | Clear | YAML front matter schema for opsx-specific settings (schema ref, project name, custom phases, etc.) |
| UX | Clear | Projects run `/opsx:init` and get WORKFLOW.md; existing projects get migration guide |
| Integration | Clear | WORKFLOW.md read by agent at skill start; CLI reads YAML section for validation |
| Edge Cases | Clear | Backward compat fallback to constitution.md; template error handling |
| Constraints | Clear | No skill modifications; external CLI dependency noted |
| Terminology | Clear | "WORKFLOW.md" as the file name, "workflow contract" as the concept |
| Non-Functional | Clear | File must be human-readable, version-controlled, and parseable by the agent |

All categories are Clear. No questions needed.

---

## 6. Open Questions

_All categories are Clear — no questions._

---

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use `WORKFLOW.md` as the filename | Aligns with Symphony convention; descriptive name; clearly different from the technical `config.yaml` | `AGENT.md`, `PROJECT.md`, keeping `constitution.md` |
| 2 | YAML front matter for structured config | Machine-readable without a separate file; standard markdown convention (used by Jekyll, Hugo, etc.); consistent with Symphony | Separate YAML file; TOML front matter |
| 3 | Markdown body as agent prompt context | Natural authoring experience; allows rich explanatory prose alongside instructions; consistent with Symphony's prompt template concept | Embedded in YAML as a string field |
| 4 | Liquid-compatible template variables (minimal subset: `{{ variable }}`) | Enables dynamic prompts without a full Liquid dependency; simple `{{ }}` substitution is implementable in any language | Jinja2, Handlebars, no templating |
| 5 | Backward compatibility: fall back to `constitution.md` if `WORKFLOW.md` absent | Non-breaking migration; existing projects keep working | Require immediate migration |
