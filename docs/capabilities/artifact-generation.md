---
title: "Artifact Generation"
capability: "artifact-generation"
description: "Step-by-step and fast-forward commands for generating pipeline artifacts"
order: 9
lastUpdated: "2026-03-04"
---

# Artifact Generation

Generate pipeline artifacts one at a time with `/opsx:continue` or all at once with `/opsx:ff`. Both commands wrap the OpenSpec CLI, so updating the schema automatically updates generation behavior.

## Features

- Step-by-step generation with `/opsx:continue` — advance one artifact at a time for review between stages
- Fast-forward generation with `/opsx:ff` — generate all remaining artifacts in one command
- Automatic dependency ordering — stages are never skipped or generated out of order
- Progress reporting after each generation step
- Thin CLI wrappers — schema updates automatically change generation behavior without skill changes

## Behavior

### Step-by-Step Generation

When you run `/opsx:continue`, the system determines which artifact is next in the pipeline, generates exactly that one artifact, then reports what was generated and what the next step is. If all artifacts are already complete, it suggests proceeding to `/opsx:apply`.

The system respects dependency gating. If a required predecessor is missing (e.g., manually deleted), it generates that artifact rather than skipping ahead.

### Fast-Forward Generation

When you run `/opsx:ff`, the system identifies all pending artifacts and generates each one sequentially in dependency order. After completion, it reports a summary of all generated artifacts. If all artifacts are already complete, it suggests `/opsx:apply`.

Fast-forward never generates stages in parallel — it follows strict dependency order.

### Resuming with Partial Progress

If some artifacts are already complete, both commands skip completed stages and generate only what remains. If you manually edit an artifact file after generation, subsequent commands treat it as complete and move to the next stage.

## Edge Cases

- If the OpenSpec CLI returns an error during generation (e.g., schema not found), the error is reported and generation halts rather than producing a malformed artifact.
- If `/opsx:continue` is run when no active change exists, you are instructed to create a change first via `/opsx:new`.
- If `/opsx:ff` encounters an error mid-pipeline (e.g., fails on the design artifact), it stops, reports the error and the last successfully generated artifact, and does not attempt subsequent stages.
- If multiple capabilities are listed in the proposal, the specs stage generates one spec file per capability before marking the stage as complete.
