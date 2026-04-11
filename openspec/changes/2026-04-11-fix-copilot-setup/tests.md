# Tests: Fix Copilot Setup

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### Skill Portability

- [ ] **Verify: SKILL.md is tool-agnostic**
  - Setup: Change implemented
  - Action: Read `src/skills/workflow/SKILL.md`
  - Verify: No Claude Code tool names (`Agent`, `AskUserQuestion`, `Read`, `Bash`, `mcp__github__*`)

- [ ] **Verify: SKILL.md follows Agent Skills Standard**
  - Setup: Change implemented
  - Action: Check frontmatter of `src/skills/workflow/SKILL.md`
  - Verify: Has `name` and `description` fields, no non-standard fields like `disable-model-invocation`

- [ ] **Verify: .agents symlink resolves**
  - Setup: Change implemented
  - Action: `readlink .agents/skills/workflow/SKILL.md` and `cat .agents/skills/workflow/SKILL.md`
  - Verify: Symlink points to `../../../src/skills/workflow/SKILL.md`, content is readable

### Cross-Client Instructions

- [ ] **Verify: AGENTS.md exists with agnostic language**
  - Setup: Change implemented
  - Action: Read `AGENTS.md`
  - Verify: No `workflow`, no `/workflow`, uses "workflow skill" language

- [ ] **Verify: CLAUDE.md is symlink to AGENTS.md**
  - Setup: Change implemented
  - Action: `readlink CLAUDE.md`
  - Verify: Points to `AGENTS.md`, content matches

### Cleanup

- [ ] **Verify: .github/copilot-instructions.md deleted**
  - Setup: Change implemented
  - Action: Check file existence
  - Verify: File does not exist

- [ ] **Verify: .github/skills/ deleted**
  - Setup: Change implemented
  - Action: Check directory existence
  - Verify: Directory does not exist

### Configuration

- [ ] **Verify: copilot-setup-steps.yml has permissions**
  - Setup: Change implemented
  - Action: Read `.github/copilot-setup-steps.yml`
  - Verify: Contains permissions for issues and pull-requests

- [ ] **Verify: Template updated**
  - Setup: Change implemented
  - Action: Read `src/templates/claude.md`
  - Verify: Generates agnostic content, no `workflow` in template body

- [ ] **Verify: CONSTITUTION.md updated**
  - Setup: Change implemented
  - Action: Read `openspec/CONSTITUTION.md`
  - Verify: Has Agent Skills + AGENTS.md conventions, old Copilot-sync convention removed

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 0 |
| Automated tests | 0 |
| Manual test items | 10 |
| Preserved (@manual) | 0 |
| Edge case tests | 0 |
| Warnings | 0 |
