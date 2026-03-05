---
title: "Quality Gates"
capability: "quality-gates"
description: "Provides pre-implementation quality checks via /opsx:preflight and post-implementation verification via /opsx:verify."
lastUpdated: "2026-03-05"
---

# Quality Gates

Two commands guard the quality of every change: `/opsx:preflight` checks your specs and design before implementation begins, and `/opsx:verify` checks your implementation against those specs after coding is done.

## Purpose

Starting implementation on incomplete or contradictory specs wastes effort and produces code that does not match requirements. Similarly, finishing implementation without checking it against the specs risks shipping gaps and divergences. Quality gates address both risks -- preflight catches problems before any code is written, and verify catches problems before the change is archived.

## Rationale

Preflight covers six distinct dimensions (traceability, gaps, side effects, constitution compliance, duplication, and assumptions) because each catches a different category of problem that would be expensive to fix during implementation. Verify assesses three dimensions (completeness, correctness, and coherence) and classifies every finding by severity, giving the developer clear prioritization. Both commands are stateless and report findings without auto-fixing, keeping the developer in control of all resolution decisions. The verify command serves as both the initial check and the final check in the QA loop -- no special flags or modes are needed because it always evaluates the current state.

> **Workflow sequence**: `/opsx:preflight` runs after the design phase and before task creation. `/opsx:verify` runs after implementation as part of the QA loop (steps 3.2 and 3.5 in tasks.md).

## Features

- **Preflight Quality Check (`/opsx:preflight`)**: A mandatory review across six dimensions before tasks are created, producing a `preflight.md` artifact with a verdict of PASS, PASS WITH WARNINGS, or BLOCKED.
- **Post-Implementation Verification (`/opsx:verify`)**: A check of the implementation against change artifacts across three dimensions, producing a report with issues classified as CRITICAL, WARNING, or SUGGESTION.
- **Six Preflight Dimensions**: Traceability Matrix, Gap Analysis, Side-Effect Analysis, Constitution Check, Duplication and Consistency, and Assumption Audit.
- **Three Verify Dimensions**: Completeness (task completion and spec coverage), Correctness (requirement implementation accuracy), and Coherence (design adherence and code pattern consistency).
- **Severity Classification**: Verify errs on the side of lower severity when uncertain (SUGGESTION over WARNING, WARNING over CRITICAL).

## Behavior

### Preflight: `/opsx:preflight`

#### Preflight Passes With No Issues

When a change has complete specs and design artifacts, all requirements have scenarios, no gaps are detected, and no assumptions are blocking, the preflight produces a `preflight.md` covering all six dimensions with a verdict of "PASS" and a summary showing 0 blockers and 0 warnings.

#### Preflight Finds Blocking Issues

When a spec requirement has no scenario or an assumption has not been verified, the traceability matrix flags the requirement gap and the assumption audit rates the unverified assumption as "Needs Clarification." The verdict is "BLOCKED" and the system informs the user that issues must be resolved before proceeding to tasks.

#### Preflight Detects Constitution Contradictions

When a design proposes something that contradicts the constitution (for example, adding a project-level `package.json` when the constitution specifies global installs only), the constitution check flags the contradiction as a blocker and recommends either updating the design to comply or updating the constitution if the rule should change.

#### Preflight Passes With Warnings

When all requirements have scenarios and no assumptions are blocking, but a minor gap is detected (such as missing error handling for an unlikely edge case), the verdict is "PASS WITH WARNINGS." The warning is listed with a recommendation, and the user may proceed to task creation at their discretion.

#### Preflight Aborts When Artifacts Are Missing

When required artifacts (such as `design.md`) have not been created, the preflight aborts and reports which artifacts are missing, suggesting the user run `/opsx:continue` or `/opsx:ff` to generate them.

### Verify: `/opsx:verify`

#### Verification With All Checks Passing

When all tasks are complete, all spec requirements are implemented, and all design decisions are followed, the verification report shows full coverage across Completeness, Correctness, and Coherence. The final assessment is "All checks passed. Ready for archive."

#### Verification Finds Critical Issues

When tasks are incomplete or a spec requirement has no corresponding implementation, the report lists CRITICAL issues with specific recommendations (for example, "Complete task: Add rate limiting middleware" or "Implement requirement: Session Timeout -- no session timeout logic found in auth module"). The final assessment states the number of critical issues found and instructs to fix before archiving.

#### Verification Finds Implementation Diverging From Spec

When the implementation uses a different approach than the spec requires (for example, session cookies instead of JWT), the report includes a WARNING with a reference to the specific file and line, recommending review against the relevant requirement.

#### Verification Finds Code Pattern Inconsistency

When a new file does not follow the project's established naming convention (for example, camelCase when the project uses kebab-case), the report includes a SUGGESTION recommending a rename to follow the project pattern.

#### Verification Degrades Gracefully With Missing Artifacts

When a change has only `tasks.md` but no specs or design, verification checks task completion only, skips spec coverage and design adherence checks, and notes in the report which checks were skipped and why. When a change has tasks but no delta specs (for example, a documentation-only change), the system skips requirement-level verification and focuses on task completion and code pattern coherence.

#### Final Verify Confirms Fix Loop Resolution

When invoked as the final verification step (step 3.5 in the QA loop) after the developer has fixed all issues from the initial verify, the report reflects the current state of all artifacts -- including any specs updated during the fix loop -- and confirms whether all critical issues have been resolved.

## Known Limitations

- Verify uses heuristic keyword-based code search to find implementation evidence. If a requirement keyword matches unrelated code, the system prefers SUGGESTION severity to avoid false critical issues.
- On very large codebases, verification scans focus on files referenced in `design.md` and recently modified files rather than performing an exhaustive codebase search.
- All change artifacts (specs, design) are assumed to be available and up to date when preflight is invoked.

## Edge Cases

- If no change name is provided and multiple changes exist, the system prompts the user to select one. For preflight, auto-selection is allowed if only one change exists.
- If a change has no spec files, preflight aborts and reports that specs must be created first.
- If `tasks.md` does not exist, verify reports the missing artifact and suggests generating it.
- If the codebase is modified while verify is running, the report reflects the state at the time of each individual check. The system does not lock files.
