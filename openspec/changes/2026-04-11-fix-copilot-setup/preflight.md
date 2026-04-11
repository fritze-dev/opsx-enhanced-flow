# Pre-Flight Check: Agent Skills + AGENTS.md Standards

## A. Traceability Matrix

- [x] SKILL.md rewrite → Proposal item 1 → `src/skills/workflow/SKILL.md`
- [x] .agents symlink → Proposal item 2 → `.agents/skills/workflow/SKILL.md`
- [x] AGENTS.md → Proposal item 3 → `AGENTS.md`
- [x] CLAUDE.md symlink → Proposal item 4 → `CLAUDE.md`
- [x] Template update → Proposal item 5 → `src/templates/claude.md`
- [x] Setup-steps permissions → Proposal item 6 → `.github/copilot-setup-steps.yml`
- [x] Delete copilot-instructions → Proposal item 7
- [x] Delete .github/skills → Proposal item 8
- [x] Constitution update → Proposal item 9 → `openspec/CONSTITUTION.md`

## B. Gap Analysis

No gaps. All deliverables clearly defined.

## C. Side-Effect Analysis

- **CLAUDE.md becomes symlink**: Claude Code reads symlinks. If not → easy to revert to file copy.
- **SKILL.md rewrite**: Consumers on the current plugin version have the old Claude-specific SKILL.md. After next plugin update, they get the agnostic version. The agnostic version is MORE compatible (works everywhere), not less.
- **Template change**: Consumers running `workflow init` will get agnostic AGENTS.md-style content instead of Claude-specific CLAUDE.md content. This is an improvement.
- **Existing CI workflows**: Unaffected — they live in `.github/workflows/`, we don't touch them.

## D. Constitution Check

Constitution update needed: add Agent Skills + AGENTS.md conventions, remove old Copilot-sync convention. The "tool-agnostic instructions" rule already exists — this change brings the SKILL.md into compliance.

## E. Duplication & Consistency

- AGENTS.md vs CLAUDE.md: Symlink — zero duplication by design.
- .agents/skills/ vs src/skills/: Symlink — zero duplication.
- Template generates agnostic content: Consistent with AGENTS.md approach.

## F. Assumption Audit

| Assumption | Source | Rating |
|-----------|--------|--------|
| Symlink resolution in .agents | design.md | Acceptable Risk — git-native, GitHub resolves |
| Copilot reads AGENTS.md | design.md | Acceptable Risk — open standard, growing adoption |

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found.

**Verdict: PASS**
