---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "6-stage artifact pipeline driven by WORKFLOW.md and Smart Templates with dependency gating, artifact output frontmatter, incremental commits, and worktree-aware PR integration"
lastUpdated: "2026-04-08"
---

# Artifact Pipeline

The artifact pipeline guides every change through six mandatory stages -- research, proposal, specs, design, preflight, and tasks -- enforcing strict dependency order so that no stage is skipped and implementation is gated by complete planning. Key artifacts (proposal and design) include YAML frontmatter in their output for machine-readable metadata. Every artifact is committed incrementally, with a draft pull request created automatically on the first commit for early team visibility.

## Purpose

Development teams working with AI assistants need a structured process that prevents jumping straight to code without adequate research, design, and quality review. Without enforced stages, critical thinking steps get skipped, decisions go undocumented, and implementation begins before requirements are fully understood. Without machine-readable metadata in artifacts, downstream skills must parse markdown sections to extract structured data like affected capabilities or the presence of design decisions.

## Rationale

The pipeline uses WORKFLOW.md for declarative orchestration and Smart Templates for self-describing artifact definitions, so that the workflow structure is transparent and modifiable without touching command code. Skills enforce dependencies by reading these files and checking artifact existence before allowing generation. The proposal and design artifacts include YAML frontmatter in their output: proposals carry `status`, `branch`, `capabilities` (new/modified/removed), and optionally `worktree` for machine-readable change tracking; designs carry `has_decisions` (boolean) so that downstream skills can skip designs without decision tables. This eliminates fragile markdown section parsing across 6+ skills. A `post_artifact` hook in WORKFLOW.md handles commit, push, and PR creation after every artifact, and is worktree-aware -- when already on a feature branch, branch creation is skipped.

## Features

- **Six-Stage Pipeline**: Research, proposal, specs, design, preflight, and tasks execute in strict dependency order. Each stage produces a verifiable artifact file that must be complete before the next can begin.
- **Artifact Output Frontmatter**: Proposals include YAML frontmatter with `status`, `branch`, `capabilities`, and optionally `worktree`. Designs include `has_decisions` (boolean). Skills prefer frontmatter fields over markdown section parsing.
- **Explicit Dependency Declarations**: Each Smart Template declares its dependencies via a `requires` field in YAML frontmatter. Skills enforce these checks by verifying file existence.
- **Apply Gate**: Implementation is gated by the tasks artifact. The apply phase cannot begin until `tasks.md` exists and is non-empty.
- **WORKFLOW.md-Owned Workflow Rules**: The tasks template's `instruction` field contains the Definition of Done rule and the standard tasks directive. The `apply.instruction` field in WORKFLOW.md contains the post-apply workflow sequence.
- **WORKFLOW.md Pipeline Configuration**: WORKFLOW.md's YAML frontmatter contains `templates_dir`, `pipeline`, `apply`, `post_artifact`, `context`, and optionally `worktree` and `docs_language`.
- **Incremental Commits with Draft PR**: After creating any artifact, the system commits and pushes it. On the first commit, a feature branch is created and a draft PR is opened. The post-artifact hook is worktree-aware.
- **Post-Implementation Commit Before Approval**: After `/opsx:verify` passes, the system commits all implementation changes and pushes before pausing for user approval. This ensures the PR diff is available for review.
- **Standard Tasks in Every Task List**: The tasks template includes universal post-implementation steps as a final section. Projects can add extras via the constitution's `## Standard Tasks` section.
- **Capability Granularity Guidance**: The proposal template's instruction defines what constitutes a capability versus a feature detail, with heuristics for merging.
- **Mandatory Consolidation Check**: Before finalizing proposal capabilities, you must verify overlap with existing specs, check pair-wise overlap, and confirm minimum requirement counts.
- **Specs Overlap Verification**: Before creating spec files, the system verifies no overlap between proposed new capabilities and existing specs.

## Behavior

### Pipeline Stages Execute in Dependency Order

When progressing through the pipeline, the system enforces the order: research first, then proposal, then specs, then design, then preflight, then tasks. Attempting to skip a stage is rejected. A completed pipeline run produces `research.md`, `proposal.md`, one or more `specs/<capability>/spec.md` files, `design.md`, `preflight.md`, and `tasks.md`.

### Artifact Output Frontmatter

When the proposal is generated, it includes YAML frontmatter with `status: active`, `branch` (the git branch name), optionally `worktree` (the worktree path), and `capabilities` (structured new/modified/removed lists mirroring the body's Capabilities section). When the design is generated, it includes `has_decisions: true` if the Decisions section contains entries, or `has_decisions: false` otherwise. Skills that need to identify affected capabilities read the proposal's `capabilities` frontmatter field instead of parsing the `## Capabilities` markdown section.

### Dependency Checks Are Enforced via File Existence

Before generating any artifact, the system reads WORKFLOW.md and Smart Templates and checks that all required predecessor artifacts are complete. An artifact is considered complete when its file exists and is non-empty. For glob patterns in the `generates` field, completion is determined by at least one matching file.

### Implementation Is Gated by Task Completion

Invoking `/opsx:apply` before `tasks.md` exists is rejected. Once all 6 artifacts are complete, apply begins by reading the task checklist and working through items sequentially, marking each as complete.

### Incremental Commits and Draft PR

After creating any artifact, the system commits and pushes it to the remote. The post-artifact hook checks the current branch: if already on the feature branch, it skips branch creation. On the first artifact commit, the system creates a feature branch, commits, pushes, and creates a draft PR. If `gh` is unavailable, PR creation is skipped. The pipeline is never blocked by push or PR creation failures.

### Post-Implementation Commit Before Approval

After `/opsx:verify` passes, the system commits all implementation changes with `WIP: <change-name> -- implementation` and pushes. If push fails, the system creates a local commit. This WIP commit is separate from the final commit in Standard Tasks.

### WORKFLOW.md and Smart Templates Own Workflow Rules

The tasks template's `instruction` field contains the Definition of Done rule and the standard tasks directive. The `apply.instruction` field contains the post-apply workflow sequence.

### Standard Tasks in Task Generation

The tasks template includes a section with universal post-implementation steps in every task list: changelog, docs, version bump, and commit and push. Constitution extras from `## Standard Tasks` are appended after the universal steps.

### Capability Granularity Guidance

The proposal template's instruction provides rules for what qualifies as a new capability versus a feature detail. A capability is a cohesive domain of behavior with 3-8 requirements. If two proposed capabilities share the same actor, trigger, or data model, they should be merged.

### Mandatory Consolidation Check

Before finalizing the Capabilities section in a proposal, you must perform a consolidation check: list all existing specs, check for domain overlap, check pair-wise overlap between new capabilities, and verify minimum requirement counts. The proposal includes a Consolidation Check section documenting this reasoning.

### Specs Overlap Verification

Before creating spec files, the specs phase verifies no overlap between proposed new capabilities and existing baseline specs. If overlap is found, the capability is reclassified as a modification to the existing spec.

## Known Limitations

- PR body is initially minimal ("WIP: <name>") until the constitution standard task enriches it post-apply.
- PR reviewer assignment, label management, and merge automation are not supported.
- Multi-PR or stacked-PR workflows are not supported.
- Automated migration of existing change proposals to include frontmatter is not supported -- they remain without frontmatter and skills fall back gracefully.

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system treats it as incomplete.
- If a user manually deletes an artifact file mid-pipeline, the system detects the gap and requires regeneration.
- If `tasks.md` contains no checkbox items, the apply phase is still gated by `tasks.md` existence.
- If multiple spec files are required, the specs stage is not considered complete until all capability specs listed in the proposal have been generated.
- If a project has zero existing specs (greenfield), the consolidation check applies between proposed new capabilities but skips the existing-spec overlap scan.
- If the feature branch already exists, the system reuses it rather than failing.
- If push succeeds but `gh pr create` fails, the failure is noted but the pipeline is not blocked.
- During auto-continue transitions, each artifact gets its own commit.
- If `worktree.path_pattern` does not contain `{change}`, the system reports an error during `/opsx:new`.
