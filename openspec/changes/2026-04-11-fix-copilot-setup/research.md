# Research: Fix Copilot Coding Agent Setup

## 1. Current State

The initial Copilot setup (PR #116) was merged but **does not work**. User testing with the actual Copilot coding agent revealed three problems:

1. **Skill not discoverable**: The symlink `.github/skills/workflow/SKILL.md` -> `src/skills/workflow/SKILL.md` is not recognized by Copilot as an invocable skill. Copilot only sees built-in skills like `customizing-copilot-cloud-agents-environment`.

2. **Skill content is Claude Code-specific**: Even if discovered, the SKILL.md body references Claude Code tools (`Agent` tool for sub-agents, `AskUserQuestion`, `Read` tool) that don't exist in Copilot's execution environment. Copilot has its own tools (`web_fetch`, `web_search`, `ask_user`, bash execution).

3. **Setup steps too minimal**: The `copilot-setup-steps.yml` only has a checkout step. Copilot coding agent may need additional configuration (git identity, tool availability).

## 2. External Research

### How Copilot Agent Skills Actually Work

From the awesome-copilot examples (add-educational-comments, azure-architecture-autopilot):

- **Frontmatter**: Just `name` and `description` — same as ours, format is compatible
- **Body**: Plain markdown instructions the agent follows step-by-step. References Copilot's own capabilities (bash execution, file reads, web fetch, sub-tasks)
- **Discovery**: Skills in `.github/skills/<name>/SKILL.md` are auto-discovered by Copilot
- **Invocation**: User types `/skill-name` in Copilot chat or issue assignment

### Key Differences from Claude Code Skills

| Aspect | Claude Code | Copilot Coding Agent |
|--------|------------|---------------------|
| Sub-agents | `Agent` tool with isolation | Task-based sub-agents (built-in) |
| User prompts | `AskUserQuestion` tool | `ask_user` / PR comments |
| File reads | `Read` tool | Direct file access / bash `cat` |
| Shell | `Bash` tool | Direct bash execution |
| GitHub ops | `mcp__github__*` MCP tools | `gh` CLI (pre-installed) |
| Skill prefix | `opsx:workflow` | `workflow` (flat) |

### copilot-setup-steps.yml

- Location: `.github/copilot-setup-steps.yml` (directly in `.github/`, NOT in `workflows/`)
- Format: GitHub Actions workflow syntax
- Purpose: Runs before the agent starts working on a task
- The agent has `gh` CLI pre-installed and authenticated
- Git is pre-configured with the agent's identity

## 3. Approaches

### Skill Strategy

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Copilot-specific SKILL.md** (separate file, not symlink) | Written for Copilot's execution model; actually works | Two skill files to maintain |
| **B: Dual-compatible SKILL.md** | Single file | Impossible — fundamentally different tool APIs |
| **C: No skill, just instructions** | Simplest | No `/workflow` slash command for Copilot |

**Recommendation: Approach A** — Replace symlink with a Copilot-specific SKILL.md that translates the OpenSpec workflow into Copilot-friendly instructions. The skill should instruct Copilot to read WORKFLOW.md and templates directly (same source of truth) but use its own tools for execution.

### copilot-setup-steps.yml

The current file location may be wrong (it was placed at `.github/copilot-setup-steps.yml` but needs verification). Content needs to be more than just checkout — should ensure the environment is ready.

### copilot-instructions.md

The current content mirrors CLAUDE.md which is minimal. For Copilot, this needs to be more comprehensive since Copilot doesn't have the plugin system that auto-loads CONSTITUTION.md.

## 4. Risks & Constraints

- **Copilot execution fidelity**: Complex multi-step workflows may not execute as reliably as in Claude Code. The skill should be simpler and more explicit.
- **Two skill files**: `.github/skills/workflow/SKILL.md` (Copilot) and `src/skills/workflow/SKILL.md` (Claude Code) are separate — content drift risk. Mitigated by both reading the same WORKFLOW.md as source of truth.
- **Copilot tool availability**: `gh` CLI is pre-installed in Copilot's environment but we should verify this in setup steps.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Replace symlink, fix setup-steps, enhance instructions |
| Behavior | Clear | Copilot reads WORKFLOW.md + templates, uses its own tools |
| Data Model | Clear | Same YAML/Markdown artifacts, different execution |
| UX | Clear | `/workflow` slash command in Copilot |
| Integration | Clear | Files in `.github/` |
| Edge Cases | Clear | Copilot may not follow complex multi-step instructions |
| Constraints | Clear | No symlinks, Copilot-native tools only |
| Terminology | Clear | |
| Non-Functional | Clear | |

## 6. Open Questions

All Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Replace symlink with Copilot-specific SKILL.md | Symlink not recognized; content must use Copilot tools | Dual-compatible (impossible), no skill (loses /workflow) |
| 2 | Copilot skill reads WORKFLOW.md as source of truth | Same pipeline definition, different execution | Hardcoded instructions (drift risk) |
| 3 | Enhance copilot-instructions.md with architecture context | Copilot has no plugin system to auto-load CONSTITUTION.md | Keep minimal (insufficient context) |
