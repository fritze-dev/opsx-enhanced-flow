---
title: "Quality Gates"
capability: "quality-gates"
description: "Provides pre-implementation quality checks via /opsx:preflight, post-implementation verification via /opsx:verify, and documentation drift detection via /opsx:docs-verify."
lastUpdated: "2026-04-09"
---

# Quality Gates

Three commands guard the quality of every change: `/opsx:preflight` checks your specs and design before implementation begins, `/opsx:verify` checks your implementation against those specs after coding is done, and `/opsx:docs-verify` checks that your generated documentation still matches the current specs.

## Purpose

Starting implementation on incomplete or contradictory specs wastes effort and produces code that does not match requirements. Similarly, finishing implementation without checking it against the specs risks shipping gaps and divergences. And generated documentation can silently drift from specs after manual edits or hotfixes outside the spec process. Quality gates address all three risks -- preflight catches problems before any code is written, verify catches problems before the change is merged, and docs-verify catches documentation drift before it causes confusion.

## Rationale

Preflight covers seven distinct dimensions (traceability, gaps, side effects, constitution compliance, duplication, marker audit, and draft spec validation) because each catches a different category of problem that would be expensive to fix during implementation. The draft spec validation dimension checks that all specs in draft status belong to the current change, preventing cross-change interference. When preflight finds warnings but no blockers, it pauses and requires your explicit acknowledgment before proceeding. Verify assesses two dimensions -- Implementation (Completeness + Correctness) and Scope (Coherence + Side-Effects) -- using the branch diff as the primary evidence source, and includes a draft spec gate that prevents draft specs from reaching the main branch. The verify completion step flips spec `draft` to `stable`, bumps `version`, and sets `lastModified`, ensuring tracking fields stay accurate. Docs-verify uses semantic checks rather than diff-based regeneration because comparing structural elements is cheaper and produces more actionable output. All three commands are stateless and report findings without auto-fixing (except mechanically fixable WARNINGs in verify), keeping you in control of resolution decisions.

> **Workflow sequence**: `/opsx:preflight` runs after the design phase and before task creation. `/opsx:verify` runs after implementation as part of the QA loop (steps 3.2 and 3.5 in tasks.md). `/opsx:docs-verify` runs anytime to check documentation freshness.

## Features

- **Preflight Quality Check (`/opsx:preflight`)**: A mandatory review across seven dimensions before tasks are created, producing a preflight report with a verdict of PASS, PASS WITH WARNINGS, or BLOCKED.
- **Draft Spec Validation**: Preflight verifies that all specs with `status: draft` have a `change` value matching the current change. Specs drafted by a different change are flagged as BLOCKED; specs with no change owner are flagged as WARNING.
- **Mandatory Pause on Warnings**: When preflight returns PASS WITH WARNINGS, the system pauses and requires you to review and explicitly acknowledge each warning before proceeding to task creation.
- **Post-Implementation Verification (`/opsx:verify`)**: A check of the implementation against change artifacts across two dimensions -- Implementation and Scope -- using the branch diff as primary evidence, producing a report with issues classified as CRITICAL, WARNING, or SUGGESTION.
- **Draft Spec Gate in Verify**: Verify checks all specs modified by the current change for `status: draft`. If any remain in draft status, the report includes a CRITICAL issue requiring finalization before merge.
- **Verify Completion (Draft-to-Stable Flip)**: When verify passes and the change is approved, the system finalizes tracking fields: flips spec `status` to `stable`, removes the `change` field, increments `version`, sets `lastModified`, and sets the proposal's `status` to `completed`.
- **Seven Preflight Dimensions**: Traceability Matrix, Gap Analysis, Side-Effect Analysis, Constitution Check, Duplication and Consistency, Marker Audit, and Draft Spec Validation.
- **Diff-Based Verification**: Verify loads the full branch diff and uses it as the primary evidence source for assessing whether changes match requirement intent. Codebase keyword search serves as a fallback for pre-existing code.
- **Two Verify Dimensions**: Implementation (Completeness + Correctness: task completion, requirement coverage, and scenario coverage) and Scope (Coherence + Side-Effects: design adherence, diff scope, side-effects, and code pattern consistency).
- **Task-Diff Mapping**: For each completed task, verify checks that the branch diff contains corresponding changes -- matching both file paths and diff content. Tasks marked complete with no evidence in the diff are flagged as WARNINGs.
- **Diff Scope Check**: Verify checks that every file in the branch diff is traceable to a task or design component. Untraced files are reported as a single grouped SUGGESTION.
- **Preflight Side-Effect Cross-Check**: As part of scope verification, verify reads `preflight.md` Section C and cross-checks each identified side-effect against task entries, diff content, and codebase evidence.
- **Documentation Drift Detection (`/opsx:docs-verify`)**: A check of generated documentation against current specs across three dimensions, producing a drift report with issues classified as CRITICAL, WARNING, or INFO and a verdict of CLEAN, DRIFTED, or OUT OF SYNC. Uses the design.md `has_decisions` frontmatter field to efficiently skip designs without decision tables.
- **Severity Classification**: Verify errs on the side of lower severity when uncertain (SUGGESTION over WARNING, WARNING over CRITICAL). Docs-verify similarly prefers INFO over WARNING when uncertain.
- **Auto-Fix for Mechanical WARNINGs**: When verify finds WARNINGs that are mechanically fixable (stale cross-references, inconsistent naming, outdated text correctable by text replacement), it fixes them inline and notes the fix in the report as "WARNING (auto-fixed)." WARNINGs that require your judgment remain as open issues.

## Behavior

### Preflight: `/opsx:preflight`

#### Preflight Passes With No Issues

When a change has complete specs and design artifacts, all requirements have scenarios, no gaps are detected, all assumptions have visible text, no REVIEW markers remain, and all draft specs belong to the current change, the preflight produces a report covering all seven dimensions with a verdict of "PASS."

#### Preflight Detects Invisible Assumptions

When a spec contains an assumption written entirely inside an HTML comment with no visible list item, the Marker Audit flags it as a format violation. The verdict is "BLOCKED" and the system recommends converting the assumption to the visible format.

#### Preflight Detects Unresolved REVIEW Markers

When a spec or design artifact contains `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers, the Marker Audit flags each one as "Blocking" because REVIEW markers must be resolved before implementation.

#### Preflight Detects Constitution Contradictions

When a design proposes something that contradicts the constitution, the constitution check flags the contradiction as a blocker and recommends either updating the design to comply or updating the constitution if the rule should change.

#### Preflight Validates Draft Spec Ownership

When a change runs preflight, the Draft Spec Validation dimension checks all specs with `status: draft`. Specs whose `change` field matches the current change are confirmed as valid. Specs whose `change` field references a different change are flagged as BLOCKED. Specs with `status: draft` but no `change` field are flagged as WARNING (orphaned draft).

#### Preflight Passes With Warnings

When all requirements have scenarios and no assumptions are blocking, but a minor gap is detected, the verdict is "PASS WITH WARNINGS." Each warning is listed with a recommendation. The system pauses and asks you to acknowledge each warning before proceeding.

#### Preflight Aborts When Artifacts Are Missing

When required artifacts (such as the design) have not been created, the preflight aborts and reports which artifacts are missing, suggesting you run `/opsx:continue` or `/opsx:ff` to generate them.

### Verify: `/opsx:verify`

#### Verify Gates on Draft Spec Status

When a change modified specs, verify checks each affected spec for `status: draft`. If any specs remain in draft status, the report includes a CRITICAL issue: the spec must be finalized before merge.

#### Verify Completion Flips Draft to Stable

When verify passes with no CRITICAL issues and the change is approved for merge, the verify completion step finalizes tracking fields. For all specs modified by the change: `status` is set to `stable`, `change` is removed, `version` is incremented by 1, and `lastModified` is set to the current date. The proposal's `status` is set to `completed`.

#### Verification With All Checks Passing

When all tasks are complete, all spec requirements are implemented, and all design decisions are followed, the verification report shows full coverage across Implementation and Scope. The final assessment is "All checks passed. Ready to proceed."

#### Verification Finds Critical Issues

When tasks are incomplete or a spec requirement has no corresponding implementation, the report lists CRITICAL issues with specific recommendations.

#### Verification Finds Implementation Diverging From Spec

When the implementation uses a different approach than the spec requires, the report includes a WARNING with a reference to the specific location.

#### Verification Degrades Gracefully With Missing Artifacts

When a change has only tasks but no specs or design, verification checks task completion only, skips requirement verification and scope checks, and notes which checks were skipped. When no merge base is available, diff-based checks are skipped.

#### Verification Catches Unaddressed Preflight Side-Effects

Verify reads the preflight report's Side-Effect Analysis and cross-checks each identified side-effect against your task list, the diff content, and the codebase.

#### Verify Auto-Fixes Stale Cross-References

When verify detects a WARNING that is mechanically fixable, it auto-fixes the issue inline and reports it as "WARNING (auto-fixed)."

#### Verify Does Not Auto-Fix Judgment-Required Divergences

When verify detects a WARNING that requires your judgment, it does not auto-fix. The divergence is presented as an open WARNING for you to decide.

#### Final Verify Confirms Fix Loop Resolution

When invoked as the final verification step, the report reflects the current state of all artifacts and confirms whether all critical issues have been resolved.

### Docs-Verify: `/opsx:docs-verify`

#### All Documentation Is In Sync

When every spec has a corresponding capability doc, all completed changes with design decisions have corresponding ADRs, and the README lists all capabilities with valid ADR references, the verdict is "CLEAN."

#### Capability Doc Missing For a Spec

When a spec exists but no corresponding capability doc is found, the report includes a CRITICAL issue and recommends running `/opsx:docs`.

#### Capability Doc Omits a Requirement

When a capability doc does not cover a requirement present in the spec, the report includes a WARNING.

#### README Missing a Capability

When the README capabilities table does not list a spec that exists, the report includes a CRITICAL issue.

#### Stale ADR Reference in README

When the README references an ADR file that does not exist, the report includes a WARNING.

#### Documentation Directory Does Not Exist

When the docs directory has not been created, the system reports each spec as a missing capability doc without erroring.

#### Efficient ADR Scanning via Design Frontmatter

When scanning completed changes for design decisions, docs-verify checks the `has_decisions` frontmatter field in design.md first. Designs without decisions are skipped without parsing the full file.

#### Manual ADR Without Design Decision Is Not Flagged

Manual ADRs (files with the `adr-MNNN` prefix) are recognized and excluded from the cross-check.

## Known Limitations

- Verify uses the branch diff as primary evidence and reads implementation files for content comparison against spec requirements, using keyword search only for initial file discovery. While this catches terminology mismatches and scope gaps, it still relies on heuristic comparison rather than formal equivalence checking. When uncertain, the system prefers SUGGESTION severity to avoid false critical issues.
- Task-Diff Mapping relies on keyword matching between task descriptions and file paths/diff content. Tasks with very generic descriptions may be marked as inconclusive rather than flagged.
- When a preflight side-effect description is too generic, the system skips that entry and notes it as inconclusive rather than raising a false warning.
- Docs-verify does not perform deep content comparison -- it checks structural alignment, not prose-level semantic equivalence.

## Future Enhancements

- Auto-fixing drifted docs (deferred -- currently detection and reporting only; use `/opsx:docs` to regenerate)

## Edge Cases

- If no change name is provided and multiple changes exist, the system prompts you to select one. For preflight, auto-selection is allowed if only one change exists.
- If a change has no spec files, preflight aborts and reports that specs must be created first.
- If the tasks artifact does not exist, verify reports the missing artifact and suggests generating it.
- If the codebase is modified while verify is running, the report reflects the state at the time of each individual check.
- If a spec directory uses a different naming convention than the capability doc filename, docs-verify attempts to match by reading the doc's frontmatter before reporting it as missing.
