# Tests: Setup Copilot Integration

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

No spec-level Gherkin scenarios exist for this change (infrastructure/config only). Manual verification derived from design.md success metrics.

### Copilot Configuration Files

#### File Existence and Content

- [ ] **Verify: copilot-instructions.md exists**
  - Setup: Change is implemented and committed
  - Action: Check `.github/copilot-instructions.md` exists
  - Verify: File exists, is non-empty, contains project architecture and workflow rules

- [ ] **Verify: copilot-setup-steps.yml exists**
  - Setup: Change is implemented and committed
  - Action: Check `.github/copilot-setup-steps.yml` exists
  - Verify: File exists, contains valid GitHub Actions workflow YAML with at least a checkout step

- [ ] **Verify: skills symlink is valid**
  - Setup: Change is implemented and committed
  - Action: Check `.github/skills/workflow/SKILL.md` is a symlink
  - Verify: Symlink resolves to `src/skills/workflow/SKILL.md`, target file exists and is non-empty

#### Constitution Update

- [ ] **Verify: sync convention added**
  - Setup: Change is implemented and committed
  - Action: Read `openspec/CONSTITUTION.md` Conventions section
  - Verify: Contains convention about keeping `copilot-instructions.md` in sync with project rules

### Edge Cases

- [ ] **Verify: existing workflows unaffected**
  - Setup: Change is implemented and committed
  - Action: Check `.github/workflows/claude.yml`, `.github/workflows/claude-code-review.yml`, `.github/workflows/release.yml`
  - Verify: All three files are unchanged from main branch

- [ ] **Verify: plugin source layout preserved**
  - Setup: Change is implemented and committed
  - Action: Check `src/` directory contents
  - Verify: No files added, modified, or removed in `src/` (symlink is in `.github/`, not `src/`)

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 0 (no spec scenarios) |
| Automated tests | 0 |
| Manual test items | 6 |
| Preserved (@manual) | 0 |
| Edge case tests | 2 |
| Warnings | 0 |
