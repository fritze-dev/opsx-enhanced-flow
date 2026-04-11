---
has_decisions: true
---
# Technical Design: Tool-Agnostic GitHub Operations

## Context

The plugin currently hardcodes `gh` CLI commands in specs, skill instructions, constitution, and README. Claude Code Web provides built-in GitHub MCP tools that work without `gh` CLI. By replacing tool-specific commands with intent-based descriptions, the plugin becomes environment-agnostic — Claude picks the best available method at runtime.

This is a text-only change across 5 files. No behavioral change occurs because the runtime is already tool-agnostic (Claude chooses the tool); only the instructions are being updated to match this reality.

## Architecture & Components

| File | Change | Type |
|------|--------|------|
| `src/skills/workflow/SKILL.md` | Line 105: replace `gh pr create --draft` with intent-based instruction | Skill |
| `openspec/CONSTITUTION.md` | Line 58: replace `gh pr ready && gh pr edit` with intent description | Constitution |
| `openspec/specs/artifact-pipeline/spec.md` | Requirement text + 2 scenarios + 1 assumption | Spec |
| `openspec/specs/change-workspace/spec.md` | Requirement text + 2 scenarios + 1 edge case | Spec |
| `README.md` | Lines 299-309: rewrite setup section for tool-agnosticism | Docs |

## Goals & Success Metrics

* `grep -r "gh pr\|gh issue\|gh api" src/ openspec/specs/ openspec/CONSTITUTION.md` returns zero hits
* All modified scenarios describe identical behavior (same GIVEN/WHEN/THEN outcomes)
* README documents MCP tools as primary, `gh` CLI as optional alternative

## Non-Goals

- ADRs are not modified (historical records)
- `.github/workflows/release.yml` is not modified (CI correctly uses `gh`)
- CHANGELOG historical entries are not modified
- No runtime behavior changes

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Use "available GitHub tooling" as umbrella term | Covers gh CLI, MCP tools, REST API without coupling to any specific tool | "GitHub API" (too specific), "PR tooling" (too vague) |
| Keep `git branch -d` fallback wording unchanged | Already tool-agnostic — it's the fallback when no GitHub tooling works | N/A |
| Rewrite README section rather than just adding MCP mention | Clean break from "gh is primary" framing to "tools are available, gh is optional" | Append MCP note to existing section (messier) |

## Risks & Trade-offs

- [Loss of explicit command examples] → Developers who want exact commands can check ADR-028/031/035 for historical context
- [Spec version not bumped] → Changes are wording-only, not behavioral; `lastModified` update is sufficient

## Open Questions

No open questions.

## Assumptions

No assumptions made.
