---
has_decisions: true
---
# Technical Design: Agent Skills + AGENTS.md Standards Adoption

## Context

The workflow skill is currently Claude Code-specific. Two open standards provide cross-client interoperability: Agent Skills (skill format + discovery) and AGENTS.md (project instructions). Adopting both makes the plugin work for any supporting client.

## Architecture & Components

**Source of truth chain (unchanged):** SKILL.md → WORKFLOW.md → CONSTITUTION.md → Smart Templates

**File layout changes:**

```
BEFORE:
  CLAUDE.md                              # Claude Code-specific instructions
  .github/copilot-instructions.md        # Copilot-specific instructions (copy)
  .github/skills/workflow/SKILL.md       # Broken symlink
  src/skills/workflow/SKILL.md           # Claude Code-specific skill

AFTER:
  AGENTS.md                              # Cross-client instructions (source of truth)
  CLAUDE.md → AGENTS.md                  # Symlink
  .agents/skills/workflow/SKILL.md → ../../../src/skills/workflow/SKILL.md  # Symlink
  .github/copilot-setup-steps.yml        # Copilot environment + permissions
  src/skills/workflow/SKILL.md           # Tool-agnostic skill (source of truth)
  src/templates/claude.md                # Updated template for agnostic output
```

## Goals & Success Metrics

* `src/skills/workflow/SKILL.md` contains zero Claude Code-specific tool names
* `.agents/skills/workflow/SKILL.md` is a valid symlink resolving to src
* `AGENTS.md` exists with agnostic language (no `/opsx:workflow`, no `/workflow`)
* `CLAUDE.md` is a symlink to `AGENTS.md`
* `.github/copilot-instructions.md` does not exist
* `.github/skills/` directory does not exist
* `.github/copilot-setup-steps.yml` includes issues/PR permissions
* `src/templates/claude.md` generates agnostic content
* CONSTITUTION.md has updated conventions

## Non-Goals

- Modifying WORKFLOW.md or Smart Templates
- Supporting skill distribution beyond Plugin Marketplace
- Agent profiles

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|-------------|
| Tool-agnostic SKILL.md body | Follows constitution rule, works cross-client | Keep Claude-specific (breaks other clients) |
| `.agents/skills/` for discovery | Agent Skills Standard cross-client path | `.github/skills/` (client-specific) |
| AGENTS.md as instructions source of truth | Open standard, single file | Separate per-client files (drift) |
| Symlink CLAUDE.md → AGENTS.md | Zero duplication | Copy with sync convention (error-prone) |
| Template generates AGENTS.md-style content | Consumers get agnostic instructions on init | Keep old template (inconsistent) |

## Risks & Trade-offs

- **Symlink not followed by client**: Git tracks symlinks, GitHub resolves them. If a client doesn't follow → can be replaced with copy + sync convention later.
- **Tool-agnostic skill less precise**: The skill body describes intent rather than exact tool calls. Mitigated by WORKFLOW.md + templates providing detailed procedural guidance that any client can follow.

## Open Questions

No open questions.

## Assumptions

- Clients that support Agent Skills resolve symlinks in `.agents/skills/`. <!-- ASSUMPTION: Symlink resolution in .agents -->
- AGENTS.md in project root is discoverable by Copilot coding agent. <!-- ASSUMPTION: Copilot reads AGENTS.md -->
