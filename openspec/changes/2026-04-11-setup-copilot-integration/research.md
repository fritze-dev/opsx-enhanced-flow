# Research: GitHub Copilot Coding Agent Setup

## 1. Current State

The opsx-enhanced-flow plugin currently runs exclusively on Claude Code (desktop, web, and GitHub Actions). The plugin system uses:

- **`CLAUDE.md`** — Project-level agent instructions, loaded every session
- **`src/skills/workflow/SKILL.md`** — Single router skill with YAML frontmatter (`name`, `description`, `disable-model-invocation`)
- **`.claude/settings.json`** — Declarative plugin installation for Claude Code Web
- **`.github/workflows/claude.yml`** — Claude Code GitHub Action for issue/PR automation
- **`.github/workflows/claude-code-review.yml`** — Copilot-powered code review (already exists)

No `.github/copilot-instructions.md`, no `copilot-setup-steps.yml`, and no `.github/skills/` directory exist.

Issue #15 tracks two parts: (1) skill format compatibility and (2) Copilot coding agent onboarding. The user has scoped this change to Copilot only — other agents (Cursor, Windsurf) are not required.

## 2. External Research

### GitHub Copilot Coding Agent Setup Files

| File | Location | Format | Purpose |
|------|----------|--------|---------|
| Custom instructions | `.github/copilot-instructions.md` | Plain Markdown (no frontmatter) | Repository-level instructions for Copilot — equivalent to `CLAUDE.md` |
| Setup steps | `.github/copilot-setup-steps.yml` | GitHub Actions workflow YAML | Pre-installs dependencies before agent starts |
| Agent skills | `.github/skills/<name>/SKILL.md` | Markdown with YAML frontmatter | Slash-command skills for the Copilot agent |

### Skill Frontmatter Compatibility

| Field | Claude Code (ours) | Copilot Agent Skills |
|-------|-------------------|---------------------|
| `name` | yes | yes (required) |
| `description` | yes | yes (required) |
| `disable-model-invocation` | yes | not documented, ignored |

Our SKILL.md frontmatter is **already compatible** with the Copilot Agent Skills spec. Both use `name` + `description` in YAML frontmatter with Markdown body.

### Key Differences

- **Location**: Claude Code reads from `src/skills/`, Copilot reads from `.github/skills/`
- **Invocation**: Claude Code uses `/opsx:workflow`, Copilot uses `/workflow` (flat, no namespace prefix)
- **Always-on context**: Claude Code uses `CLAUDE.md`, Copilot uses `.github/copilot-instructions.md`
- **Environment setup**: Claude Code needs nothing (pure Markdown), Copilot requires `copilot-setup-steps.yml`

## 3. Approaches

### Skill Portability

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Symlinks** `.github/skills/workflow/` → `../../src/skills/workflow/` | Zero duplication, always in sync | Git symlinks can be fragile on Windows; some CI may not follow symlinks |
| **B: Copy at build/release** | Clean separation, can transform frontmatter | Requires build step, drift risk between source and copy |
| **C: Move skills to `.github/skills/`** | Native Copilot location | Breaks Claude Code plugin layout (`src/` is the published root) |

**Recommendation: Approach A (symlinks)**. This is a Markdown-only project with no Windows users. Symlinks are tracked by git and followed by GitHub.

### copilot-instructions.md Content

| Approach | Pro | Contra |
|----------|-----|--------|
| **Derive from CONSTITUTION.md** | Accurate, comprehensive | May be too long / verbose for Copilot |
| **Minimal pointer** (just reference CONSTITUTION.md) | Short, no drift | Copilot may not follow file read instructions |
| **Curated subset** | Right level of detail | Manual maintenance, drift risk |

**Recommendation: Curated subset** focused on the three-layer architecture, workflow rules, and coding conventions. Reference CONSTITUTION.md for full details.

### copilot-setup-steps.yml

This project has **no external dependencies** — it's pure Markdown/YAML. The setup step is minimal: just ensure the workspace is ready. No npm, no build tools needed.

## 4. Risks & Constraints

- **Skill body size**: Copilot may have token limits for skill instructions. Our `SKILL.md` is ~150 lines — within typical limits.
- **Copilot skill invocation**: Copilot uses `/workflow` (no namespace prefix). Users must adjust from `/opsx:workflow`.
- **No runtime guarantee**: Copilot agent may not follow WORKFLOW.md-based instructions as reliably as Claude Code. The skill body is complex (router logic, sub-agent dispatching).
- **Symlink support**: GitHub resolves symlinks in repo content. Git tracks symlinks natively. Low risk.
- **Maintenance**: `.github/copilot-instructions.md` is a separate file from `CLAUDE.md` — changes to one don't propagate to the other. Covered by constitution convention.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Three files: copilot-instructions.md, copilot-setup-steps.yml, skills symlink |
| Behavior | Clear | Copilot reads these files at agent startup |
| Data Model | Clear | YAML frontmatter + Markdown, already compatible |
| UX | Clear | Copilot uses `/workflow` slash command |
| Integration | Clear | Files go in `.github/`, read by GitHub Copilot |
| Edge Cases | Clear | Symlink handling, no-dependency setup |
| Constraints | Clear | No Windows users, no build tools needed |
| Terminology | Clear | "Agent Skills" = Copilot's term for slash-command skills |
| Non-Functional | Clear | No performance or security implications |

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use symlinks for skill portability | Zero duplication, git-native, always in sync | Copy at build, move to .github/skills |
| 2 | Curated copilot-instructions.md derived from CONSTITUTION.md | Right level of detail without drift | Full copy, minimal pointer |
| 3 | Minimal copilot-setup-steps.yml (no dependencies) | Project is pure Markdown/YAML, no build tools | npm install openspec CLI |
