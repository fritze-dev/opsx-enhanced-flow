# Tests: SessionStart Hook Fallback

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### Plugin Auto-Install

#### SessionStart Hook

- [ ] **Scenario: Plugin installs via hook on new session**
  - Setup: Open project in Claude Code Web (clean session, no manually installed plugins)
  - Action: Start a new session
  - Verify: `/opsx:workflow` skill is available without manual intervention

- [ ] **Scenario: Hook is idempotent when plugin already installed**
  - Setup: Plugin already installed (either via declarative or prior hook run)
  - Action: Start a new session
  - Verify: No errors; plugin remains available

- [ ] **Scenario: Hook fails silently when marketplace not ready**
  - Setup: Very first session (marketplace not yet cached)
  - Action: Start a new session
  - Verify: No error messages; session starts normally (plugin may not be available until second session)

- [ ] **Scenario: settings.json remains valid JSON**
  - Setup: After applying the change
  - Action: Run `jq . .claude/settings.json`
  - Verify: Parses successfully; contains `hooks`, `extraKnownMarketplaces`, and `enabledPlugins`

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 4 |
| Automated tests | 0 |
| Manual test items | 4 |
| Preserved (@manual) | 0 |
| Edge case tests | 1 |
| Warnings | 0 |
