---
id: changelog
type: action
template-version: 1
description: Generate release notes from completed changes
requires: [verify]
instruction: |
  Run /opsx:changelog to generate or update CHANGELOG.md.
  The skill handles incremental detection — only new entries are added,
  existing entries are preserved.
---
