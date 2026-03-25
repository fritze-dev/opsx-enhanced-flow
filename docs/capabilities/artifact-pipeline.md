---
title: "Artifact Pipeline"
capability: "artifact-pipeline"
description: "Defines the schema-driven 6-stage artifact pipeline with strict dependency gating, PR integration, and implementation controls."
lastUpdated: "2026-03-25"
---

# Artifact Pipeline

The artifact pipeline guides every change through six mandatory stages -- research, proposal, specs, design, preflight, and tasks -- enforcing strict dependency order so that no stage is skipped and implementation is gated by complete planning. A draft pull request is created automatically at the proposal stage for early team visibility.

## Purpose

Development teams working with AI assistants need a structured process that prevents jumping straight to code without adequate research, design, and quality review. Without enforced stages, critical thinking steps get skipped, decisions go undocumented, and implementation begins before requirements are fully understood. The artifact pipeline provides a schema-driven sequence of mandatory stages that ensures every change is thoroughly analyzed before a single line of code is written.

## Rationale

The pipeline uses a declarative schema rather than hardcoded skill logic so that the workflow structure is transparent and modifiable without touching command code. Each artifact declares its dependencies explicitly, and skills enforce these dependencies by reading schema.yaml and checking file existence before allowing generation. The 6-stage design captures the full lifecycle from initial research through implementation-ready tasks, with each stage producing a verifiable file. Config.yaml serves as a minimal bootstrap containing only the schema reference and a constitution pointer, while workflow rules live at their authoritative source -- the schema for universal rules, the constitution for project-specific rules. PR creation is inlined in the proposal instruction rather than added as a separate artifact, preserving the 6-stage pipeline structure while providing early team visibility through draft PRs.

## Features

- **Six-Stage Pipeline**: Research, proposal, specs, design, preflight, and tasks execute in strict dependency order. Each stage produces a verifiable artifact file that must be complete (exists and is non-empty) before the next stage can begin.
- **Explicit Dependency Declarations**: Each artifact in the schema declares its dependencies via a `requires` field. Skills enforce these checks by reading schema.yaml and verifying file existence.
- **Apply Gate**: Implementation is gated by the tasks artifact. The apply phase cannot begin until `tasks.md` exists and is non-empty. During apply, progress is tracked against the task checklist.
- **Minimal Config Bootstrap**: The `openspec/config.yaml` file contains only the schema reference and a constitution pointer -- no workflow rules or per-artifact rules entries.
- **Schema-Owned Workflow Rules**: The `tasks.instruction` field in the schema contains the Definition of Done rule and the standard tasks directive. The `apply.instruction` field contains the post-apply workflow sequence (`/opsx:verify` then `/opsx:archive` then `/opsx:changelog` then `/opsx:docs` then commit, then execute constitution pre-merge standard tasks) and clarifies that standard tasks are not part of apply.
- **Draft PR at Proposal**: After writing `proposal.md`, the system creates a feature branch, commits change artifacts, pushes to the remote, and creates a draft PR via `gh pr create --draft` with the proposal content as the PR body. The PR URL is recorded in a `## Pull Request` section in `proposal.md`.
- **Standard Tasks in Every Task List**: The tasks template includes universal post-implementation steps (archive, changelog, docs, commit and push) as a final section. Projects can add extras via the constitution's `## Standard Tasks` section, which are appended after the universal steps.
- **Capability Granularity Guidance**: The proposal instruction defines what constitutes a capability (a cohesive behavior domain with 3-8 requirements) versus a feature detail (a single behavior within an existing capability). Heuristics guide merging: shared actor, trigger, or data model suggests one capability, and proposed capabilities producing fewer than ~100 lines should be folded into existing specs.
- **Mandatory Consolidation Check**: Before finalizing proposal capabilities, you must verify overlap with existing specs, check pair-wise overlap between new capabilities, and confirm each has 3+ distinct requirements. The proposal template includes a Consolidation Check section to make this reasoning visible and reviewable.
- **Specs Overlap Verification**: Before creating spec files, the system verifies there is no overlap between proposed new capabilities and existing baseline specs. If overlap is found, the capability is reclassified as a modification to the existing spec.

## Behavior

### Pipeline Stages Execute in Dependency Order

When progressing through the pipeline, the system enforces the order: research first, then proposal, then specs, then design, then preflight, then tasks. Attempting to skip a stage -- for example, generating specs before completing the proposal -- is rejected with a message indicating which prerequisite artifact must be completed first. A completed pipeline run produces `research.md`, `proposal.md`, one or more `specs/<capability>/spec.md` files, `design.md`, `preflight.md`, and `tasks.md`.

### Dependency Checks Are Enforced via File Existence

Before generating any artifact, the system reads schema.yaml and checks that all required predecessor artifacts are complete. An artifact is considered complete when its corresponding file exists and is non-empty. For artifacts with glob patterns in the `generates` field (e.g., `specs/**/*.md`), completion is determined by at least one matching file existing. If a dependency check fails, the system reports which artifacts must be completed first. The schema declares these dependencies explicitly so that the enforcement is transparent and inspectable.

### Implementation Is Gated by Task Completion

Invoking `/opsx:apply` before `tasks.md` exists is rejected with a message to generate tasks first. Once all 6 artifacts are complete, apply begins by reading the task checklist from `tasks.md` and working through items sequentially. As each task item is completed, the corresponding checkbox is marked from `- [ ]` to `- [x]`.

### Draft PR Created After Proposal

After writing `proposal.md`, the system creates a feature branch named after the change, commits the change artifacts (research.md, proposal.md), pushes the branch to the remote, and creates a draft PR with the proposal content as the PR body. A `## Pull Request` section is appended to `proposal.md` recording the PR URL, branch name, and status. If the `gh` CLI is not installed or not authenticated, the system creates the feature branch and pushes it but skips PR creation, noting "PR not created -- gh CLI unavailable" in the Pull Request section. The pipeline is never blocked by PR creation failures.

### Config Contains Only Bootstrap Content

The `config.yaml` file contains a `schema` field referencing the active schema and a `context` field pointing to the project constitution. It contains no other workflow rules or per-artifact rules entries. All workflow logic resides in the schema's instruction fields or in the constitution.

### Schema Owns Universal Workflow Rules

The `tasks.instruction` field in the schema contains the rule that Definition of Done is emergent from artifacts, referencing Gherkin scenarios, success metrics, preflight findings, and user approval. It also contains the standard tasks directive for including universal post-implementation steps and appending constitution-defined extras. The `apply.instruction` field contains the post-apply workflow sequence and directs the agent to execute constitution-defined pre-merge standard tasks after the universal post-apply steps (commit and push), marking each as complete in tasks.md. Post-merge standard tasks remain unchecked as reminders for manual execution after the PR is merged.

### Standard Tasks in Task Generation

The tasks template includes a section 4 with universal post-implementation steps that appear in every generated task list: archive, changelog, docs, and commit and push. If the project constitution defines a `## Standard Tasks` section, those items are appended after the universal steps. This two-layer approach provides a consistent baseline for all projects while allowing project-specific customization.

### Capability Granularity Guidance

The proposal instruction provides explicit rules for what qualifies as a new capability versus a feature detail. A capability represents a cohesive domain of behavior exercised independently, typically containing 3-8 requirements. A feature detail is a single behavior or edge case that belongs as a requirement within an existing spec. If two proposed capabilities share the same actor, trigger, or data model, they should be merged. If a proposed capability would produce fewer than ~100 lines (1-2 requirements), it should be folded into a related existing capability.

### Mandatory Consolidation Check

Before finalizing the Capabilities section in a proposal, you must perform a consolidation check: list all existing specs and read their Purpose sections, check each proposed new capability for domain overlap with existing specs, check pairs of new capabilities for shared actor/trigger/data model, and verify each proposed capability will have 3+ distinct requirements. The proposal template includes a Consolidation Check section where this reasoning is documented, making it visible for review.

### Specs Overlap Verification

Before creating any spec files, the specs phase verifies there is no overlap between proposed new capabilities and existing baseline specs. If overlap is found, the capability is reclassified as a Modified Capability on the existing spec, and the proposal is updated accordingly before proceeding.

## Known Limitations

- PR reviewer assignment, label management, and merge automation are not supported.
- Multi-PR or stacked-PR workflows are not supported.
- Branch protection rules and CI configuration are outside the pipeline's scope.

## Edge Cases

- If an artifact file exists but is empty (0 bytes), the system treats it as incomplete and does not satisfy dependency checks.
- If a user manually deletes an artifact file mid-pipeline, the system detects the gap and requires regeneration before proceeding.
- If the schema is modified to add a new artifact stage while a change is in progress, the new schema applies to new changes only; in-progress changes continue with the schema version that was active when they were created.
- If `tasks.md` contains no checkbox items (e.g., a documentation-only change), the apply phase is still gated by `tasks.md` existence but reports that there are no implementation tasks to execute.
- If multiple spec files are required (one per capability), the specs stage is not considered complete until all capability specs listed in the proposal have been generated.
- If a project has no constitution file, the `config.yaml` context pointer is harmless -- the AI notes the missing file and proceeds.
- If a project has zero existing specs (greenfield), the consolidation check applies between proposed new capabilities but skips the existing-spec overlap scan.
- If an existing spec exceeds ~500 lines or 10+ requirements, proposing to split it rather than adding more is allowed -- but the decision must be documented in the Consolidation Check section.
- If you explicitly request separate specs for capabilities that the consolidation check identifies as overlapping (e.g., for team ownership reasons), the Consolidation Check documents this decision with rationale.
- If the feature branch already exists (e.g., from a prior attempt), the system reuses the existing branch rather than failing.
- If the push succeeds but `gh pr create` fails due to a network issue, the branch info is recorded and PR creation failure is noted. The pipeline is not blocked.
- If no git remote is configured, push and PR creation are skipped and noted in the Pull Request section.
