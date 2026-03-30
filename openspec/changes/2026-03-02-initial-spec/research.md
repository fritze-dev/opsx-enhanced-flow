# Research: Initial Project Specification

## 1. Current State

This is a Claude Code plugin (`opsx-enhanced-flow`) that provides a spec-driven development workflow on top of the OpenSpec CLI framework. The plugin delivers 13 skills as SKILL.md files organized in a three-layer architecture:

**Layer 1 — Constitution:** `openspec/constitution.md` defines global project rules (tech stack, architecture, code style, constraints, conventions). Referenced by all AI actions via `config.yaml` workflow rules.

**Layer 2 — Schema:** `openspec/schemas/opsx-enhanced/schema.yaml` defines a 6-artifact pipeline (research → proposal → specs → design → preflight → tasks) with templates for each artifact type. The `apply` phase is gated by tasks completion.

**Layer 3 — Skills:** 13 `skills/*/SKILL.md` files:
- **Workflow** (6): new, continue, ff, apply, verify, archive
- **Governance** (5): init, bootstrap, discover, preflight, sync
- **Documentation** (2): changelog, docs

**Key files:**
- `.claude-plugin/plugin.json` — Plugin identity (name: "opsx", version: "1.0.0")
- `.claude-plugin/marketplace.json` — Self-hosted marketplace definition
- `openspec/config.yaml` — Workflow rules (9 rules including approval gates, bidirectional feedback)
- `openspec/schemas/opsx-enhanced/` — Schema with 6 artifact templates
- `skills/` — 13 skill directories

**No existing specs** — this is a fresh bootstrap after a full reset.

## 2. External Research

**OpenSpec CLI (`@fission-ai/openspec@^1.2.0`):**
- Provides: change management, artifact pipeline, schema validation, spec storage
- CLI commands: `new change`, `status`, `instructions`, `archive`, `list`, `validate`, `schema`
- Supports agent-driven spec sync via `openspec-sync-specs` built-in skill template
- Programmatic archive merge has limitations (expects `## Purpose` + `## Requirements` format)

**Claude Code Plugin System:**
- Skills defined as `SKILL.md` with YAML frontmatter (name, description, disable-model-invocation)
- Model invocation control per skill (true = user-only, false = model-invocable)
- Plugin discovery via `.claude-plugin/plugin.json` and `marketplace.json`

## 3. Approaches

Not applicable for initial bootstrap — we are documenting the existing system, not choosing between implementation approaches.

## 4. Risks & Constraints

| Risk | Impact | Mitigation |
|------|--------|------------|
| Spec granularity: too many fine-grained specs creates maintenance burden | Medium | Group related behavior into logical capabilities (e.g., one spec for artifact-generation covers both continue and ff) |
| Spec granularity: too few coarse specs loses traceability | Medium | Ensure each spec maps to one coherent capability with clear boundaries |
| OpenSpec CLI programmatic merge limitations | Low | Agent-driven sync via `/opsx:sync` is the primary merge path |
| Schema version locked at 1 | Low | Version bump requires coordinated change across schema and skills |

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Full project covered — 3 layers, 13 skills, 6 artifacts, plugin manifests |
| Behavior | Clear | Each skill has detailed instructions in SKILL.md, schema defines pipeline |
| Data Model | Clear | File-based: specs, artifacts, config, constitution — no database |
| UX | Clear | User interacts via slash commands, review gates between pipeline stages |
| Integration | Clear | OpenSpec CLI, Claude Code plugin system, GitHub CLI (optional) |
| Edge Cases | Clear | Recovery mode in bootstrap, idempotent init, drift detection |
| Constraints | Clear | Documented in constitution — version pins, approval gates, mandatory preflight |
| Terminology | Clear | Constitution, Schema, Skills, Artifacts, Delta Specs, Baseline Specs |
| Non-Functional | Clear | No performance/scalability concerns — file-based workflow |

## 6. Open Questions

All categories are Clear. No open questions.

## 7. Decisions

No decisions needed — this is a documentation-only bootstrap of an existing system.

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Identify capabilities at three levels: design concepts, structural components, operational features | Ensures comprehensive coverage without gaps or overlaps | Single-level (too flat) vs per-skill (too granular) |
| 2 | Group workflow commands (continue/ff) under one capability (artifact-generation) | They share the same concern (generating pipeline artifacts) despite being separate skills | One spec per skill (14+ specs, too granular) |
| 3 | Separate spec-format as its own capability | Format rules are cross-cutting and referenced by multiple skills | Embedding in artifact-generation (hidden, hard to find) |
