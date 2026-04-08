---
title: "Quality Gates"
capability: "quality-gates"
description: "Provides pre-implementation quality checks via /opsx:preflight, post-implementation verification via /opsx:verify, and documentation drift detection via /opsx:docs-verify."
lastUpdated: "2026-04-08"
---

# Quality Gates

Three commands guard the quality of every change: `/opsx:preflight` checks your specs and design before implementation begins, `/opsx:verify` checks your implementation against those specs after coding is done, and `/opsx:docs-verify` checks that your generated documentation still matches the current specs.

## Purpose

Starting implementation on incomplete or contradictory specs wastes effort and produces code that does not match requirements. Similarly, finishing implementation without checking it against the specs risks shipping gaps and divergences. And generated documentation can silently drift from specs after manual edits, multiple archive cycles, or hotfixes outside the spec process. Quality gates address all three risks -- preflight catches problems before any code is written, verify catches problems before the change is archived, and docs-verify catches documentation drift before it causes confusion.

## Rationale

Preflight covers six distinct dimensions (traceability, gaps, side effects, constitution compliance, duplication, and marker audit) because each catches a different category of problem that would be expensive to fix during implementation. The marker audit dimension checks both assumption format compliance and the presence of unresolved `<!-- REVIEW -->` markers, since either issue indicates unfinished work that should not proceed to implementation. When preflight finds warnings but no blockers, it pauses and requires your explicit acknowledgment before proceeding -- this prevents warnings from being silently accepted and surfacing as issues later. Verify assesses two dimensions -- Implementation (Completeness + Correctness) and Scope (Coherence + Side-Effects) -- using the branch diff as the primary evidence source, and classifies every finding by severity, giving you clear prioritization. Docs-verify uses semantic checks rather than diff-based regeneration because comparing structural elements (Purpose, requirement names, capability listings) is cheaper and produces more actionable output than regenerating docs in memory. All three commands are stateless and report findings without auto-fixing, keeping you in control of all resolution decisions.

> **Workflow sequence**: `/opsx:preflight` runs after the design phase and before task creation. `/opsx:verify` runs after implementation as part of the QA loop (steps 3.2 and 3.5 in tasks.md). `/opsx:docs-verify` runs anytime to check documentation freshness.

## Features

- **Preflight Quality Check (`/opsx:preflight`)**: A mandatory review across six dimensions before tasks are created, producing a preflight report with a verdict of PASS, PASS WITH WARNINGS, or BLOCKED.
- **Mandatory Pause on Warnings**: When preflight returns PASS WITH WARNINGS, the system pauses and requires you to review and explicitly acknowledge each warning before proceeding to task creation.
- **Post-Implementation Verification (`/opsx:verify`)**: A check of the implementation against change artifacts across two dimensions -- Implementation and Scope -- using the branch diff as primary evidence, producing a report with issues classified as CRITICAL, WARNING, or SUGGESTION.
- **Six Preflight Dimensions**: Traceability Matrix, Gap Analysis, Side-Effect Analysis, Constitution Check, Duplication and Consistency, and Marker Audit.
- **Diff-Based Verification**: Verify loads the full branch diff and uses it as the primary evidence source for assessing whether changes match requirement intent. Codebase keyword search serves as a fallback for pre-existing code.
- **Two Verify Dimensions**: Implementation (Completeness + Correctness: task completion, requirement coverage, and scenario coverage) and Scope (Coherence + Side-Effects: design adherence, diff scope, side-effects, and code pattern consistency).
- **Task-Diff Mapping**: For each completed task, verify checks that the branch diff contains corresponding changes -- matching both file paths and diff content. Tasks marked complete with no evidence in the diff are flagged as WARNINGs.
- **Diff Scope Check**: Verify checks that every file in the branch diff is traceable to a task or design component. Untraced files are reported as a single grouped SUGGESTION.
- **Preflight Side-Effect Cross-Check**: As part of scope verification, verify reads `preflight.md` Section C and cross-checks each identified side-effect against task entries, diff content, and codebase evidence. Unaddressed side-effects are flagged as WARNINGs.
- **Documentation Drift Detection (`/opsx:docs-verify`)**: A check of generated documentation against current specs across three dimensions, producing a drift report with issues classified as CRITICAL, WARNING, or INFO and a verdict of CLEAN, DRIFTED, or OUT OF SYNC.
- **Severity Classification**: Verify errs on the side of lower severity when uncertain (SUGGESTION over WARNING, WARNING over CRITICAL). Docs-verify similarly prefers INFO over WARNING when uncertain.
- **Auto-Fix for Mechanical WARNINGs**: When verify finds WARNINGs that are mechanically fixable (stale cross-references between artifacts, inconsistent naming, outdated text correctable by simple text replacement), it fixes them inline and notes the fix in the report as "WARNING (auto-fixed)." WARNINGs that require your judgment (such as spec/design divergence) remain as open issues.

## Behavior

### Preflight: `/opsx:preflight`

#### Preflight Passes With No Issues

When a change has complete specs and design artifacts, all requirements have scenarios, no gaps are detected, all assumptions have visible text, and no REVIEW markers remain, the preflight produces a report covering all six dimensions with a verdict of "PASS" and a summary showing 0 blockers and 0 warnings.

#### Preflight Finds Blocking Issues

When a spec requirement has no scenario or an assumption has not been verified, the traceability matrix flags the requirement gap and the assumption audit rates the unverified assumption as "Needs Clarification." The verdict is "BLOCKED" and the system informs you that issues must be resolved before proceeding to tasks.

#### Preflight Detects Invisible Assumptions

When a spec contains an assumption written entirely inside an HTML comment with no visible list item, the Marker Audit flags it as a format violation. The verdict is "BLOCKED" and the system recommends converting the assumption to the visible format with a list item preceding the HTML tag.

#### Preflight Detects Unresolved REVIEW Markers

When a spec or design artifact contains `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers, the Marker Audit flags each one as "Blocking" because REVIEW markers must be resolved before implementation. The verdict is "BLOCKED."

#### Preflight Detects Constitution Contradictions

When a design proposes something that contradicts the constitution (for example, adding a project-level package.json when the constitution specifies global installs only), the constitution check flags the contradiction as a blocker and recommends either updating the design to comply or updating the constitution if the rule should change.

#### Preflight Passes With Warnings

When all requirements have scenarios and no assumptions are blocking, but a minor gap is detected (such as missing error handling for an unlikely edge case), the verdict is "PASS WITH WARNINGS." Each warning is listed with a recommendation. The system pauses and asks you to acknowledge each warning. It does not proceed to task creation until you explicitly confirm.

#### Preflight Aborts When Artifacts Are Missing

When required artifacts (such as the design) have not been created, the preflight aborts and reports which artifacts are missing, suggesting you run `/opsx:continue` or `/opsx:ff` to generate them.

### Verify: `/opsx:verify`

#### Verification With All Checks Passing

When all tasks are complete, all spec requirements are implemented, and all design decisions are followed, the verification report shows full coverage across Implementation and Scope. The final assessment is "All checks passed. Ready to proceed."

#### Verification Finds Critical Issues

When tasks are incomplete or a spec requirement has no corresponding implementation, the report lists CRITICAL issues with specific recommendations (for example, "Complete task: Add rate limiting middleware" or "Implement requirement: Session Timeout -- no session timeout logic found in auth module"). The final assessment states the number of critical issues found and instructs to fix before archiving.

#### Verification Finds Implementation Diverging From Spec

When the implementation uses a different approach than the spec requires (for example, session cookies instead of JWT), the report includes a WARNING with a reference to the specific location, recommending review against the relevant requirement.

#### Verification Finds Code Pattern Inconsistency

When a new file does not follow the project's established naming convention (for example, camelCase when the project uses kebab-case), the report includes a SUGGESTION recommending a rename to follow the project pattern.

#### Verification Degrades Gracefully With Missing Artifacts

When a change has only tasks but no specs or design, verification checks task completion only, skips requirement verification and scope checks, and notes in the report which checks were skipped and why. When no merge base is available (for example, an orphan branch or first commit), diff-based checks are skipped and verification falls back to codebase keyword search only.

#### Verification Catches Unaddressed Preflight Side-Effects

As part of scope verification, verify reads the preflight report's Side-Effect Analysis (Section C) and cross-checks each identified side-effect against your task list, the diff content, and the codebase. If a side-effect has a matching task or detectable implementation evidence, no issue is raised. If a side-effect has neither, the report includes a WARNING recommending you add a task or verify that the side-effect is handled. When all side-effects in Section C are assessed as having no risk, the cross-check is skipped and noted in the report.

#### Verify Auto-Fixes Stale Cross-References

When verify detects a WARNING that is mechanically fixable -- such as an artifact referencing a filename that was renamed, or inconsistent naming between artifacts -- it auto-fixes the issue inline (editing the affected file) before presenting the report. The fix appears in the report as "WARNING (auto-fixed)" so you can see what was changed, but it is not presented as an open issue requiring your action.

#### Verify Does Not Auto-Fix Judgment-Required Divergences

When verify detects a WARNING that requires your judgment -- such as the implementation using a different approach than the spec requires -- it does not auto-fix. The divergence is presented as an open WARNING for you to decide whether to update the spec or the code.

#### Final Verify Confirms Fix Loop Resolution

When invoked as the final verification step after you have fixed all issues from the initial verify, the report reflects the current state of all artifacts -- including any specs updated during the fix loop -- and confirms whether all critical issues have been resolved.

### Docs-Verify: `/opsx:docs-verify`

#### All Documentation Is In Sync

When every spec has a corresponding capability doc, all completed changes with design decisions have corresponding ADRs, and the README lists all capabilities with valid ADR references, the drift report shows no issues across all three dimensions. The verdict is "CLEAN."

#### Capability Doc Missing For a Spec

When a spec exists but no corresponding capability doc is found, the report includes a CRITICAL issue identifying the missing doc and recommending you run `/opsx:docs <capability-name>` to generate it. The verdict is "OUT OF SYNC."

#### Capability Doc Omits a Requirement

When a capability doc exists but does not cover a requirement present in the spec, the report includes a WARNING identifying the missing requirement and recommending regeneration. The verdict is "DRIFTED."

#### README Missing a Capability

When the README capabilities table does not list a spec that exists, the report includes a CRITICAL issue and recommends running `/opsx:docs` to regenerate the README.

#### Stale ADR Reference in README

When the README Key Design Decisions table references an ADR file that does not exist, the report includes a WARNING identifying the stale reference.

#### Documentation Directory Does Not Exist

When the docs directory has not been created yet, the system reports each spec as a missing capability doc (CRITICAL) without erroring, and recommends running `/opsx:docs` to generate initial documentation.

#### No Completed Changes With Design Decisions to Check

When no completed changes exist, the system skips the ADR dimension, notes it in the report, and still checks the other two dimensions.

#### Manual ADR Without Design Decision Is Not Flagged

Manual ADRs (files with the `adr-MNNN` prefix) are recognized and excluded from the cross-check against completed changes with design decisions. No issue is raised for manual ADRs.

## Known Limitations

- Verify uses the branch diff as its primary evidence source and falls back to heuristic keyword-based codebase search for pre-existing code. If a requirement keyword matches unrelated code, the system prefers SUGGESTION severity to avoid false critical issues.
- Task-Diff Mapping relies on keyword matching between task descriptions and file paths/diff content. Tasks with very generic descriptions may be marked as inconclusive rather than flagged.
- When a preflight side-effect description is too generic to produce meaningful keyword matches, the system skips that entry and notes it as inconclusive rather than raising a false warning.
- All change artifacts (specs, design) are assumed to be available and up to date when preflight is invoked.
- Docs-verify does not perform deep content comparison -- it checks structural alignment (presence of requirements, capabilities, ADRs), not prose-level semantic equivalence.

## Future Enhancements

- Auto-fixing drifted docs (deferred -- currently detection and reporting only; use `/opsx:docs` to regenerate)
- Docs language consistency checking (deferred -- already handled by `/opsx:docs` generation logic)

## Edge Cases

- If no change name is provided and multiple changes exist, the system prompts you to select one. For preflight, auto-selection is allowed if only one change exists.
- If a change has no spec files, preflight aborts and reports that specs must be created first.
- If the tasks artifact does not exist, verify reports the missing artifact and suggests generating it.
- If the codebase is modified while verify is running, the report reflects the state at the time of each individual check. The system does not lock files.
- If a spec directory uses a different naming convention than the capability doc filename, docs-verify attempts to match by reading the doc's frontmatter or first heading before reporting it as missing.
- If a capability doc exists but has no meaningful content, docs-verify classifies it as WARNING.
- Docs-verify only checks the capabilities table and Key Design Decisions table within the README, not custom project-specific sections.
