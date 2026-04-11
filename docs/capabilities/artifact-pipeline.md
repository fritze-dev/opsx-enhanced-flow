---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "8-stage pipeline with dependency gating, artifact frontmatter, consolidation checks, and worktree-aware PR integration"
lastUpdated: "2026-04-10"
---

# Artifact Pipeline

The artifact pipeline guides every change through eight mandatory stages -- research, proposal, specs, design, preflight, tests, tasks, and review -- enforcing strict dependency order so that no stage is skipped and implementation is gated by complete planning. Key artifacts include YAML frontmatter for machine-readable metadata. Every artifact is committed incrementally, with a draft pull request created automatically on the first commit.

## Purpose

Development teams working with AI assistants need a structured process that prevents jumping straight to code without adequate research, design, and quality review. Without enforced stages, critical thinking steps get skipped, decisions go undocumented, and implementation begins before requirements are fully understood. Without machine-readable metadata in artifacts, downstream actions must parse markdown sections to extract structured data like affected capabilities or the presence of design decisions.

## Rationale

The pipeline uses WORKFLOW.md for declarative orchestration and Smart Templates for self-describing artifact definitions, so that the workflow structure is transparent and modifiable without touching command code. The pipeline expanded from 7 to 8 stages with the addition of tests between preflight and tasks -- the tests stage generates test artifacts from Gherkin scenarios before implementation, enabling TDD. Review remains the final stage as a persistent, PR-visible verification artifact. Propose serves as the single entry point for all pipeline traversal operations (workspace creation, checkpoint/resume, full lifecycle execution), eliminating the need for separate commands. The `auto_approve` configuration defaults to `true`, so pipeline traversal proceeds without user confirmation at checkpoints on success paths. Users who prefer inline pauses can set `auto_approve: false` explicitly.

## Features

- **Eight-Stage Pipeline** (`workflow propose`): Research, proposal, specs, design, preflight, tests, tasks, and review execute in strict dependency order. Each stage produces a verifiable artifact file.
- **Artifact Output Frontmatter**: Proposals include `status`, `branch`, `capabilities` (new/modified/removed), and optionally `worktree`. Designs include `has_decisions` (boolean). Actions prefer frontmatter over markdown parsing.
- **Explicit Dependency Declarations**: Each Smart Template declares its dependencies via a `requires` field. Dependencies are enforced by verifying file existence.
- **Apply Gate**: Implementation is gated by the tasks artifact. Apply cannot begin until `tasks.md` exists and is non-empty.
- **Propose as Single Entry Point**: `workflow propose` handles workspace creation, progress display, checkpoint/resume, and full artifact generation. Displays artifact status showing which stages are done, ready, or blocked. The `auto_approve` configuration (defaults to `true`) controls whether checkpoints pause for user confirmation.
- **WORKFLOW.md-Owned Workflow Rules**: The tasks template's `instruction` contains the Definition of Done rule and standard tasks directive. WORKFLOW.md action instructions contain the post-apply workflow sequence.
- **Incremental Commits with Draft PR**: After each artifact, the system commits and pushes. On the first commit, a feature branch and draft PR are created. The post-artifact hook is worktree-aware.
- **Post-Implementation Commit Before Approval**: After apply's auto-verify passes, the system commits implementation changes and pushes before pausing for user approval.
- **Standard Tasks in Every Task List**: The tasks template includes universal post-implementation steps. Constitution extras from `## Standard Tasks` are appended.
- **Capability Granularity Guidance**: The proposal template defines what constitutes a capability versus a feature detail, with merging heuristics (shared actor/trigger/data model).
- **Mandatory Consolidation Check**: Before finalizing proposal capabilities, overlap with existing specs, pair-wise overlap between new capabilities, and minimum requirement counts are verified.
- **Specs Overlap Verification**: Before creating spec files, overlap between proposed capabilities and existing specs is verified.

## Behavior

### Pipeline Stages Execute in Dependency Order (`workflow propose`)

When progressing through the pipeline, the system enforces the order: research, proposal, specs, design, preflight, tests, tasks, review. Attempting to skip a stage is rejected. A completed pipeline run produces `research.md`, `proposal.md`, one or more `specs/<capability>/spec.md` files, `design.md`, `preflight.md`, `tests.md`, `tasks.md`, and `review.md`.

### Propose Creates and Manages Workspaces (`workflow propose`)

When invoked with a description or name and no matching change exists, propose creates a new change workspace (with worktree if enabled). When invoked without arguments and existing changes are present, propose lists active changes and lets you select one. It displays artifact status for the current change, showing which artifacts are complete, in progress, or blocked.

### Auto-Approve Controls Pipeline Checkpoint Behavior

The `auto_approve` workflow configuration defaults to `true` in WORKFLOW.md frontmatter. When absent or `true`, checkpoints are skipped on success paths -- preflight warnings are auto-acknowledged and the post-apply PASS proceeds without pausing. When explicitly set to `false`, the pipeline pauses at each checkpoint for user confirmation. FAIL verdicts always stop regardless of `auto_approve`. The design review checkpoint is a constitutional requirement and pauses independently of `auto_approve`.

### Artifact Output Frontmatter

When the proposal is generated, it includes YAML frontmatter with `status: active`, `branch`, optionally `worktree`, and `capabilities` (structured new/modified/removed lists). When the design is generated, it includes `has_decisions: true` if the Decisions section contains entries. Actions that need to identify affected capabilities read the proposal's `capabilities` frontmatter field.

### Dependency Checks Are Enforced via File Existence

Before generating any artifact, the system reads WORKFLOW.md and Smart Templates and checks that all required predecessors are complete. An artifact is considered complete when its file exists and is non-empty. For glob patterns in the `generates` field, at least one matching file must exist.

### Incremental Commits and Draft PR

After creating any artifact, the system commits and pushes. On the first artifact commit, the system creates a feature branch, commits, pushes, and creates a draft PR using available GitHub tooling. If no GitHub tooling is available, PR creation is skipped. The pipeline is never blocked by push or PR creation failures.

### Consolidation Check and Overlap Verification

The proposal template requires reviewing existing specs for domain overlap, checking pair-wise overlap between new capabilities, and verifying minimum requirement counts. The proposal includes a Consolidation Check section documenting this reasoning. During the specs phase, overlap with existing baseline specs is verified before creating spec files.

## Known Limitations

- PR body is initially minimal ("WIP: <name>") until the constitution standard task enriches it post-apply.
- Multi-PR or stacked-PR workflows are not supported.
- Automated migration of existing proposals to include frontmatter is not supported -- they remain without frontmatter and actions fall back gracefully.

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system treats it as incomplete.
- If a user manually deletes an artifact file mid-pipeline, the system detects the gap and requires regeneration.
- If `tasks.md` contains no checkbox items, the apply phase is still gated by `tasks.md` existence.
- If the feature branch already exists, the system reuses it rather than failing.
- If push succeeds but draft PR creation fails, the failure is noted but the pipeline is not blocked.
- If `worktree.path_pattern` does not contain `{change}`, the system reports an error during propose.
