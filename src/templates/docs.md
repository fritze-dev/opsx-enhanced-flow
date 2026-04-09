---
id: docs
type: action
template-version: 1
description: Generate or update user-facing documentation from specs
requires: [changelog]
instruction: |
  Run /opsx:docs to generate or update capability docs, ADRs, and README.
  The skill handles incremental detection — only capabilities with newer
  changes are regenerated.

  Pass the affected capability names from the proposal's capabilities
  frontmatter as arguments for targeted regeneration.
---
