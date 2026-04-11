# Research: Fix Copilot Setup — Agent Skills + AGENTS.md Standards

## 1. Current State

The initial Copilot setup (PR #116) does not work. Copilot cannot discover or invoke the skill. Three root causes:

1. **Symlink not followed**: `.github/skills/workflow/SKILL.md` symlink not recognized by Copilot
2. **SKILL.md is Claude Code-specific**: Body references `Agent` tool, `AskUserQuestion`, `Read` — tools that don't exist in Copilot
3. **Violates own constitution**: "tool-agnostic instructions" rule is violated by the current SKILL.md

## 2. External Research

### Agent Skills Standard (agentskills.io)

Open standard maintained by Anthropic, supported by 34+ clients (Claude Code, Copilot, Cursor, Gemini CLI, etc.).

- **Format**: `SKILL.md` with `name` + `description` YAML frontmatter + markdown body
- **Cross-client discovery path**: `.agents/skills/<name>/SKILL.md`
- **Client-specific paths**: `.<client>/skills/` (e.g., `.claude/skills/`, `.github/skills/`)
- **Progressive disclosure**: Agents scan metadata at startup, load full instructions on activation
- **Activation**: Slash command `/skill-name` or auto-activation based on description match

### AGENTS.md Standard (agents.md)

Open format: "a README for agents — a dedicated, predictable place to provide context and instructions."

- **Location**: `AGENTS.md` in project root
- **Format**: Plain Markdown, sections for dev environment, testing, workflow, PR guidelines
- **Cross-client**: Recognized by AI coding agents as project-level instructions
- **Replaces**: Client-specific instruction files (CLAUDE.md, .github/copilot-instructions.md)

### Client Implementation (from agentskills spec)

Discovery directories (per client):
| Scope | Paths |
|-------|-------|
| Project | `<project>/.<client>/skills/` AND `<project>/.agents/skills/` |
| User | `~/.<client>/skills/` AND `~/.agents/skills/` |

`.agents/skills/` is "a widely-adopted convention for cross-client skill sharing."

### Copilot Coding Agent Permissions

The `copilot-setup-steps.yml` in `.github/` configures the agent environment (GitHub Actions format). Permissions for issues/PRs need to be explicitly granted.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **Agent Skills + AGENTS.md standards** | Cross-client, one source of truth, follows own constitution | Requires SKILL.md rewrite |
| Keep client-specific files | No rewrite | Duplicated content, drift risk, doesn't work for Copilot |

**Decision: Standards-based approach.**

## 4. Risks & Constraints

- **Symlinks for CLAUDE.md**: Git tracks symlinks natively, GitHub resolves them. If a client doesn't follow → fallback to copies with sync convention.
- **Tool-agnostic skill body**: May be less precise for Claude Code users. Mitigated by WORKFLOW.md + templates providing the detailed procedural guidance.

## 5. Coverage Assessment

All categories Clear.

## 6. Open Questions

None.

## 7. Decisions

| # | Decision | Rationale | Alternatives |
|---|----------|-----------|-------------|
| 1 | Use `.agents/skills/` for cross-client discovery | Agent Skills Standard, 34+ clients | Client-specific paths (fragmented) |
| 2 | Use `AGENTS.md` for cross-client instructions | Open standard, replaces client-specific files | Separate CLAUDE.md + copilot-instructions.md (drift) |
| 3 | Symlink CLAUDE.md → AGENTS.md | Single source of truth | Manual sync (error-prone) |
| 4 | Rewrite SKILL.md tool-agnostic | Follows own constitution rule, works cross-client | Keep Claude-specific (breaks Copilot) |
| 5 | Update src/templates/claude.md | Consumer template must match new agnostic approach | Keep old template (inconsistent) |
