---
has_decisions: true
---
# Technical Design: GitHub Copilot Coding Agent Setup

## Context

The opsx-enhanced-flow plugin runs on Claude Code but GitHub Copilot coding agent cannot discover or use it because the repo lacks three Copilot-specific configuration files. The skill format is already compatible (both use `name` + `description` YAML frontmatter in SKILL.md). This change adds the missing configuration files without modifying any existing plugin behavior.

## Architecture & Components

Files to add:

1. **`.github/copilot-instructions.md`** — Plain Markdown file with project instructions for Copilot. Derived from CONSTITUTION.md content (three-layer architecture, workflow rules, coding conventions). Read automatically by Copilot at agent startup.

2. **`.github/copilot-setup-steps.yml`** — GitHub Actions-format YAML. Runs before the Copilot agent starts. Since the project has no external dependencies (pure Markdown/YAML), this is minimal — just a checkout step.

3. **`.github/skills/workflow/SKILL.md`** — Git symlink pointing to `../../../src/skills/workflow/SKILL.md`. Copilot discovers skills in `.github/skills/`, our source of truth lives in `src/skills/`. Symlink keeps them in sync without duplication.

Files to modify:

4. **`openspec/CONSTITUTION.md`** — Add sync convention for `copilot-instructions.md` to the Conventions section.

No existing files are deleted or renamed. No changes to the skill content, pipeline, or workflow.

## Goals & Success Metrics

* `.github/copilot-instructions.md` exists and contains project-relevant instructions
* `.github/copilot-setup-steps.yml` exists with valid GitHub Actions workflow syntax
* `.github/skills/workflow/SKILL.md` is a valid symlink resolving to `src/skills/workflow/SKILL.md`
* Symlink target file exists and is non-empty
* CONSTITUTION.md contains sync convention for copilot-instructions.md

## Non-Goals

- Supporting Cursor, Windsurf, or other AI agents
- Modifying the SKILL.md content or frontmatter
- Adding agent profiles (`.agent.md`)
- Creating a build step or transformation pipeline for skills
- Generating copilot-instructions.md automatically from CONSTITUTION.md

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Symlink for skill portability | Zero duplication, always in sync, git-native | Copy at release (drift risk), move to .github/skills (breaks plugin layout) |
| Curated copilot-instructions.md | Right detail level; Copilot needs self-contained instructions, can't be told to read CONSTITUTION.md | Full CONSTITUTION copy (too verbose), minimal pointer (unreliable) |
| Minimal copilot-setup-steps.yml | No external dependencies — project is pure Markdown/YAML | Install OpenSpec CLI (doesn't exist yet), install Node.js (not needed) |
| Constitution convention for sync | Consistent with existing template-sync convention pattern | Automated sync (overengineered for two files) |

## Risks & Trade-offs

- **Copilot skill execution fidelity**: The workflow skill body is complex (router logic, sub-agent spawning). Copilot may not follow it as reliably as Claude Code. -> Mitigation: This is inherent to the Copilot platform; the skill format is correct and discoverable.
- **copilot-instructions.md drift**: Separate file from CLAUDE.md means manual sync needed. -> Mitigation: Constitution convention makes this explicit, same pattern as template sync.
- **Symlink on Windows**: Windows requires special git config for symlinks. -> Mitigation: No Windows users in this project; symlinks work natively on macOS/Linux and GitHub.

## Open Questions

No open questions.

## Assumptions

- GitHub Copilot coding agent resolves symlinks when reading `.github/skills/`. <!-- ASSUMPTION: Copilot resolves symlinks -->
- The `copilot-setup-steps.yml` format follows GitHub Actions workflow syntax. <!-- ASSUMPTION: Setup steps use Actions format -->
