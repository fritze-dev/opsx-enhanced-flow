---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "Defines the 6-stage artifact pipeline driven by WORKFLOW.md and Smart Templates, with strict dependency gating, incremental commits, PR integration, and implementation controls."
lastUpdated: "2026-03-26"
---

# Artifact Pipeline

The artifact pipeline guides every change through six mandatory stages -- research, proposal, specs, design, preflight, and tasks -- enforcing strict dependency order so that no stage is skipped and implementation is gated by complete planning. Every artifact is committed incrementally, with a draft pull request created automatically on the first commit for early team visibility.

## Purpose

Development teams working with AI assistants need a structured process that prevents jumping straight to code without adequate research, design, and quality review. Without enforced stages, critical thinking steps get skipped, decisions go undocumented, and implementation begins before requirements are fully understood. The artifact pipeline provides a mandatory sequence of stages that ensures every change is thoroughly analyzed before a single line of code is written.

## Rationale

The pipeline uses WORKFLOW.md for declarative orchestration and Smart Templates for self-describing artifact definitions, so that the workflow structure is transparent and modifiable without touching command code. WORKFLOW.md declares the pipeline order, apply gate, and post-artifact hook in YAML frontmatter, while each Smart Template carries its own instruction, output path, and dependencies. Skills enforce dependencies by reading these files and checking artifact existence before allowing generation. The 6-stage design captures the full lifecycle from initial research through implementation-ready tasks, with each stage producing a verifiable file. A `post_artifact` hook in WORKFLOW.md handles commit, push, and PR creation after every artifact -- WORKFLOW.md owns the rule, skills execute it. This avoids coupling PR creation to any single artifact stage and ensures every artifact is tracked in version control.

## Features

- **Six-Stage Pipeline**: Research, proposal, specs, design, preflight, and tasks execute in strict dependency order. Each stage produces a verifiable artifact file that must be complete (exists and is non-empty) before the next stage can begin.
- **Explicit Dependency Declarations**: Each Smart Template declares its dependencies via a `requires` field in YAML frontmatter. Skills enforce these checks by reading WORKFLOW.md and Smart Templates and verifying file existence.
- **Apply Gate**: Implementation is gated by the tasks artifact. The apply phase cannot begin until `tasks.md` exists and is non-empty. During apply, progress is tracked against the task checklist.
- **WORKFLOW.md-Owned Workflow Rules**: The tasks Smart Template's `instruction` field contains the Definition of Done rule and the standard tasks directive. The `apply.instruction` field in WORKFLOW.md contains the post-apply workflow sequence (`/opsx:verify` then `/opsx:archive` then `/opsx:changelog` then `/opsx:docs` then commit, then execute constitution pre-merge standard tasks) and clarifies that standard tasks are not part of apply.
- **Incremental Commits with Draft PR**: After creating any artifact, the system commits and pushes it. On the first commit, a feature branch is created and a draft PR is opened via `gh pr create --draft`. Subsequent artifacts are committed to the same branch. PR metadata is available on-demand via `gh pr view`.
- **Standard Tasks in Every Task List**: The tasks template includes universal post-implementation steps (archive, changelog, docs, commit and push) as a final section. Projects can add extras via the constitution's `## Standard Tasks` section, which are appended after the universal steps.
- **Capability Granularity Guidance**: The proposal Smart Template's instruction defines what constitutes a capability (a cohesive behavior domain with 3-8 requirements) versus a feature detail (a single behavior within an existing capability). Heuristics guide merging: shared actor, trigger, or data model suggests one capability, and proposed capabilities producing fewer than ~100 lines should be folded into existing specs.
- **Mandatory Consolidation Check**: Before finalizing proposal capabilities, you must verify overlap with existing specs, check pair-wise overlap between new capabilities, and confirm each has 3+ distinct requirements. The proposal template includes a Consolidation Check section to make this reasoning visible and reviewable.
- **Specs Overlap Verification**: Before creating spec files, the system verifies there is no overlap between proposed new capabilities and existing baseline specs. If overlap is found, the capability is reclassified as a modification to the existing spec.

## Behavior

### Pipeline Stages Execute in Dependency Order

When progressing through the pipeline, the system enforces the order: research first, then proposal, then specs, then design, then preflight, then tasks. Attempting to skip a stage -- for example, generating specs before completing the proposal -- is rejected with a message indicating which prerequisite artifact must be completed first. A completed pipeline run produces `research.md`, `proposal.md`, one or more `specs/<capability>/spec.md` files, `design.md`, `preflight.md`, and `tasks.md`.

### Dependency Checks Are Enforced via File Existence

Before generating any artifact, the system reads WORKFLOW.md and Smart Templates and checks that all required predecessor artifacts are complete. An artifact is considered complete when its corresponding file exists and is non-empty. For artifacts with glob patterns in the `generates` field (e.g., `specs/**/*.md`), completion is determined by at least one matching file existing. If a dependency check fails, the system reports which artifacts must be completed first. Smart Templates declare these dependencies explicitly so that the enforcement is transparent and inspectable.

### Implementation Is Gated by Task Completion

Invoking `/opsx:apply` before `tasks.md` exists is rejected with a message to generate tasks first. Once all 6 artifacts are complete, apply begins by reading the task checklist from `tasks.md` and working through items sequentially. As each task item is completed, the corresponding checkbox is marked from `- [ ]` to `- [x]`.

### Incremental Commits and Draft PR

After creating any artifact, the system commits and pushes it to the remote. On the first artifact commit (typically research), the system creates a feature branch named after the change, commits the artifact, pushes the branch, and creates a draft PR with a minimal WIP body. Subsequent artifact commits push to the existing branch without creating a new PR. If the `gh` CLI is not installed or not authenticated, the system creates the feature branch and commits locally but skips PR creation. The pipeline is never blocked by push or PR creation failures. If WORKFLOW.md does not contain a `post_artifact` field, the commit and push step is skipped entirely.

### WORKFLOW.md and Smart Templates Own Workflow Rules

The tasks Smart Template's `instruction` field contains the rule that Definition of Done is emergent from artifacts, referencing Gherkin scenarios, success metrics, preflight findings, and user approval. It also contains the standard tasks directive for including universal post-implementation steps and appending constitution-defined extras. The `apply.instruction` field in WORKFLOW.md contains the post-apply workflow sequence and directs the agent to execute constitution-defined pre-merge standard tasks after the universal post-apply steps (commit and push), marking each as complete in tasks.md. Post-merge standard tasks remain unchecked as reminders for manual execution after the PR is merged.

### Standard Tasks in Task Generation

The tasks template includes a section 4 with universal post-implementation steps that appear in every generated task list: archive, changelog, docs, and commit and push. If the project constitution defines a `## Standard Tasks` section, those items are appended after the universal steps. This two-layer approach provides a consistent baseline for all projects while allowing project-specific customization.

### Capability Granularity Guidance

The proposal Smart Template's instruction provides explicit rules for what qualifies as a new capability versus a feature detail. A capability represents a cohesive domain of behavior exercised independently, typically containing 3-8 requirements. A feature detail is a single behavior or edge case that belongs as a requirement within an existing spec. If two proposed capabilities share the same actor, trigger, or data model, they should be merged. If a proposed capability would produce fewer than ~100 lines (1-2 requirements), it should be folded into a related existing capability.

### Mandatory Consolidation Check

Before finalizing the Capabilities section in a proposal, you must perform a consolidation check: list all existing specs and read their Purpose sections, check each proposed new capability for domain overlap with existing specs, check pairs of new capabilities for shared actor/trigger/data model, and verify each proposed capability will have 3+ distinct requirements. The proposal template includes a Consolidation Check section where this reasoning is documented, making it visible for review.

### Specs Overlap Verification

Before creating any spec files, the specs phase verifies there is no overlap between proposed new capabilities and existing baseline specs. If overlap is found, the capability is reclassified as a Modified Capability on the existing spec, and the proposal is updated accordingly before proceeding.

## Known Limitations

- PR body is initially minimal ("WIP: <name>") until the constitution standard task enriches it post-apply.
- PR reviewer assignment, label management, and merge automation are not supported.
- Multi-PR or stacked-PR workflows are not supported.
- Branch protection rules and CI configuration are outside the pipeline's scope.

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system treats it as incomplete and does not satisfy dependency checks.
- If a user manually deletes an artifact file mid-pipeline, the system detects the gap and requires regeneration before proceeding.
- If `tasks.md` contains no checkbox items (e.g., a documentation-only change), the apply phase is still gated by `tasks.md` existence but reports that there are no implementation tasks to execute.
- If multiple spec files are required (one per capability), the specs stage is not considered complete until all capability specs listed in the proposal have been generated.
- If a project has zero existing specs (greenfield), the consolidation check applies between proposed new capabilities but skips the existing-spec overlap scan.
- If the feature branch already exists (e.g., from a prior attempt), the system reuses the existing branch rather than failing.
- If the push succeeds but `gh pr create` fails due to a network issue, the failure is noted. The pipeline is not blocked.
- During auto-continue transitions (e.g., research to proposal), each artifact gets its own commit.
