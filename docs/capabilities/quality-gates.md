---
title: "Quality Gates"
capability: "quality-gates"
description: "Preflight checks during propose, review.md verification during apply, and docs drift detection during init"
lastUpdated: "2026-04-10"
---

# Quality Gates

Three quality gates guard every change: preflight checks your specs and design during `/opsx:workflow propose` before tasks are created, review.md verification checks your implementation during `/opsx:workflow apply` after coding is done, and documentation drift detection runs during `/opsx:workflow init` as a project health check.

## Purpose

Starting implementation on incomplete or contradictory specs wastes effort and produces code that does not match requirements. Similarly, finishing implementation without checking it against the specs risks shipping gaps and divergences. And generated documentation can silently drift from specs after manual edits or hotfixes. Quality gates address all three risks -- preflight catches problems before code is written, review.md catches problems before the change is merged, and docs drift detection catches documentation staleness.

## Rationale

Preflight covers seven distinct dimensions (traceability, gaps, side effects, constitution compliance, duplication, marker audit, and draft spec validation) because each catches a different category of problem expensive to fix during implementation. Verify now produces a `review.md` artifact in the change directory rather than a transient report -- this makes verification results persistent, PR-visible, and not skippable (file existence is checked). Verify assesses two dimensions -- Implementation (Completeness + Correctness) and Scope (Coherence + Side-Effects) -- using the branch diff as the primary evidence source. The verify completion step flips spec `draft` to `stable`, bumps `version`, and sets `lastModified`. Documentation drift verification moved from a standalone command to an init health check, consolidating project-level checks under a single entry point. All gates are stateless and report findings without auto-fixing (except mechanically fixable WARNINGs in verify).

> **Workflow sequence**: Preflight runs during `/opsx:workflow propose` after the design phase and before task creation. Verify runs during `/opsx:workflow apply` as part of the QA loop (generating review.md). Docs drift detection runs during `/opsx:workflow init` as a project health check.

## Features

- **Preflight Quality Check** (`/opsx:workflow propose`): Mandatory review across seven dimensions before tasks are created, producing `preflight.md` with a verdict of PASS, PASS WITH WARNINGS, or BLOCKED.
- **Draft Spec Validation**: Preflight verifies that all specs with `status: draft` belong to the current change. Foreign drafts are BLOCKED; orphaned drafts are WARNING.
- **Mandatory Pause on Warnings**: When preflight returns PASS WITH WARNINGS, the system pauses and requires explicit acknowledgment before task creation.
- **Post-Implementation Verification** (`/opsx:workflow apply`): Verification that produces `review.md` in the change directory -- a persistent artifact assessing Implementation and Scope dimensions using the branch diff as primary evidence, with issues classified as CRITICAL, WARNING, or SUGGESTION.
- **Draft Spec Gate in Verify**: Verify checks all specs modified by the change for `status: draft`. Any remaining drafts produce a CRITICAL issue.
- **Verify Completion (Draft-to-Stable Flip)**: When verify passes and the change is approved, spec tracking fields are finalized: `status` flips to `stable`, `change` is removed, `version` increments, `lastModified` is set. The proposal's `status` is set to `completed`.
- **Seven Preflight Dimensions**: Traceability Matrix, Gap Analysis, Side-Effect Analysis, Constitution Check, Duplication and Consistency, Marker Audit, and Draft Spec Validation.
- **Test Coverage Verification**: Verify includes an 8th dimension checking that generated tests cover all spec scenarios and that automated test stubs exist for automatable scenarios when a framework is configured.
- **Diff-Based Verification**: Verify loads the full branch diff as primary evidence. Codebase keyword search serves as a fallback.
- **Task-Diff Mapping**: For each completed task, verify checks that the diff contains corresponding changes matching both file paths and content.
- **Diff Scope Check**: Every file in the diff must be traceable to a task or design component. Untraced files are a single grouped SUGGESTION.
- **Preflight Side-Effect Cross-Check**: Verify reads `preflight.md` Section C and cross-checks each side-effect against tasks, diff, and codebase evidence.
- **Documentation Drift Detection** (`/opsx:workflow init`): Checks capability docs, ADRs, and README against specs across three dimensions with CLEAN/DRIFTED/OUT OF SYNC verdicts. Uses `has_decisions` frontmatter for efficient ADR scanning.
- **Auto-Fix for Mechanical WARNINGs**: Stale cross-references, inconsistent naming, and outdated text are fixed inline. Judgment-required WARNINGs remain as open issues.

## Behavior

### Preflight: Quality Check During Propose (`/opsx:workflow propose`)

#### Preflight Passes With No Issues

When a change has complete specs and design, all requirements have scenarios, no gaps are detected, all assumptions have visible text, no REVIEW markers remain, and all draft specs belong to the current change, the verdict is "PASS."

#### Preflight Detects Invisible Assumptions

When a spec contains an assumption written entirely inside an HTML comment with no visible list item, the Marker Audit flags it as a format violation. The verdict is "BLOCKED."

#### Preflight Detects Unresolved REVIEW Markers

REVIEW markers in specs or design artifacts are flagged as "Blocking" because they must be resolved before implementation.

#### Preflight Detects Constitution Contradictions

When a design contradicts the constitution, the contradiction is flagged as a blocker with a recommendation to update the design or the constitution.

#### Preflight Validates Draft Spec Ownership

Draft specs whose `change` field matches the current change are confirmed valid. Drafts from a different change are BLOCKED. Drafts with no `change` field are WARNING.

#### Preflight Passes With Warnings

When no blockers are found but minor gaps are detected, the verdict is "PASS WITH WARNINGS." The system pauses and asks you to acknowledge each warning before proceeding.

### Verify: review.md During Apply (`/opsx:workflow apply`)

#### Verify Gates on Draft Spec Status

When affected specs remain in draft status, the review.md report includes a CRITICAL issue requiring finalization before merge.

#### Verify Completion Flips Draft to Stable

When verify passes and the change is approved, spec tracking fields are finalized: `status: stable`, `change` removed, `version` incremented, `lastModified` set. The proposal's `status` is set to `completed`.

#### Verification With All Checks Passing

When all tasks are complete, requirements are implemented, and design decisions are followed, the final assessment is "All checks passed. Ready to proceed."

#### Verification Finds Critical Issues

Incomplete tasks or missing requirement implementations are listed as CRITICAL issues with specific recommendations.

#### Verification Finds Divergence From Spec

When implementation uses a different approach than the spec requires, the report includes a WARNING with a specific file and line reference.

#### Verify Auto-Fixes Stale Cross-References

Mechanically fixable WARNINGs (stale references, inconsistent naming) are auto-fixed inline and reported as "WARNING (auto-fixed)." Judgment-required divergences remain as open issues.

#### Verify Catches Unaddressed Preflight Side-Effects

Verify cross-checks each side-effect from preflight's Section C against tasks, diff content, and the codebase. Unaddressed side-effects are WARNING.

### Docs Drift Detection: Health Check During Init (`/opsx:workflow init`)

#### All Documentation Is In Sync

When every spec has a corresponding capability doc, all design decisions have ADRs, and the README is complete, the verdict is "CLEAN."

#### Missing Capability Doc

When a spec exists but no corresponding capability doc is found, the report includes a CRITICAL issue recommending `/opsx:workflow finalize`.

#### README Missing a Capability

When the README capabilities table omits a spec, the report includes a CRITICAL issue.

#### Efficient ADR Scanning via Design Frontmatter

When scanning completed changes for design decisions, the system checks `has_decisions` frontmatter first. Designs without decisions are skipped.

## Known Limitations

- Verify uses the branch diff and keyword search rather than formal equivalence checking. When uncertain, it prefers SUGGESTION severity.
- Task-Diff Mapping relies on keyword matching; tasks with very generic descriptions may be marked inconclusive.
- Documentation drift detection checks structural alignment, not prose-level semantic equivalence.

## Edge Cases

- If a change has no spec files, preflight aborts and reports that specs must be created first.
- If tasks.md does not exist, verify reports the missing artifact and suggests generating it.
- If no merge base is available (orphan branch, first commit), diff-based checks are skipped with a note.
- If `docs/capabilities/` does not exist, all specs are reported as missing capability docs without erroring.
