# Research: Fix Workflow Friction

## 1. Current State

This change addresses 4 remaining friction points from [Issue #6](https://github.com/fritze-dev/opsx-enhanced-flow/issues/6) (FP #4, #5, #7, #8) and combines FP #5 with [Issue #1](https://github.com/fritze-dev/opsx-enhanced-flow/issues/1) (config.yaml rules audit).

**Affected files:**
- `openspec/config.yaml` — All 9 workflow rules sit in global `context`. No per-artifact `rules` used.
- `skills/archive/SKILL.md` — 6 steps, no version bump or friction capture.
- `openspec/constitution.md` — No friction tracking convention.
- `README.md` — Minimal "Development & Testing" section (lines 458–471), no workflow cheatsheet.
- `.claude-plugin/plugin.json` — Version `1.0.1`.

**Relevant baseline specs:**
- `quality-gates` — verify skill checks completeness/correctness/coherence but no README consistency check.
- `artifact-pipeline` — defines 6-stage pipeline, config.yaml provides context injection.
- `constitution-management` — constitution referenced via config.yaml workflow rules.
- `task-implementation` — apply skill works through tasks.md checkboxes.

**Stale-spec risks:** None detected. All baseline specs accurately reflect current codebase behavior. The changes introduce new capabilities (config rules, auto version bump, friction convention) that don't conflict with existing specs.

## 2. External Research

**OpenSpec config.yaml customization** ([docs/customization.md](https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md)):
- `context` — injected into ALL artifacts (global)
- `rules` — per-artifact dictionary, injected ONLY for matching artifact ID
- Prompt injection order: `<context>` → `<rules>` → `<template>`
- Example: `rules.specs: [...]`, `rules.proposal: [...]`

This confirms that per-artifact rules are the correct mechanism for targeted enforcement instead of a status skill.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Config rules + README cheatsheet (chosen) | Rules enforced at prompt level; cheatsheet is lightweight reference; no new skill needed | Requires OpenSpec CLI to support `rules` field |
| New `/opsx:status` skill | Interactive, shows live status | Only shows info, doesn't enforce; adds maintenance burden |
| Workflow enforcement in skill instructions only | No config changes needed | Easy to forget; not injected during artifact generation |

## 4. Risks & Constraints

- **OpenSpec CLI `rules` support:** Requires `@fission-ai/openspec@^1.2.0` to support the `rules` field in config.yaml. The [customization docs](https://github.com/Fission-AI/OpenSpec/blob/main/docs/customization.md) confirm this is supported.
- **Auto version bump scope:** Only applies when `.claude-plugin/plugin.json` exists. Consumer projects without this file must be handled gracefully (silent skip).
- **Friction prompt fatigue:** Adding a friction check to every archive could feel repetitive. Mitigated by making it a quick yes/no prompt.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 4 friction points + 1 config audit, well-defined in issues |
| Behavior | Clear | Each friction point has specific expected behavior |
| Data Model | Clear | YAML config structure documented in OpenSpec docs |
| UX | Clear | Cheatsheet + AskUserQuestion prompts are straightforward |
| Integration | Clear | config.yaml rules integrate with OpenSpec CLI's injection mechanism |
| Edge Cases | Clear | plugin.json absence handled by silent skip |
| Constraints | Clear | OpenSpec CLI ^1.2.0 compatibility confirmed |
| Terminology | Clear | All terms established in existing project |
| Non-Functional | Clear | No performance or security concerns |

All categories are Clear — no open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use per-artifact `rules` in config.yaml instead of `/opsx:status` skill | Rules enforce behavior at prompt injection time; a status skill only shows info | Status skill, skill instruction changes only |
| 2 | Add workflow cheatsheet to README instead of separate skill | Lightweight, zero maintenance, always accessible | `/opsx:status` skill |
| 3 | Add friction prompt to archive skill (not verify) | Archive is the workflow closure point with existing interactive prompts; verify is automated scorecard | Adding to verify, adding to both |
| 4 | Auto-bump patch version only | Semver convention; major/minor bumps require human decision | Bump minor, prompt for bump type |
