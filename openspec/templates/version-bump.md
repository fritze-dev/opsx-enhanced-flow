---
id: version-bump
type: action
template-version: 1
description: Bump patch version and sync marketplace.json
requires: [docs]
instruction: |
  Increment the patch version in src/.claude-plugin/plugin.json
  (e.g., 1.0.3 → 1.0.4) and sync the version field in
  .claude-plugin/marketplace.json to match. If versions are out of
  sync, use src/.claude-plugin/plugin.json as source of truth.
  Display the new version.
---
