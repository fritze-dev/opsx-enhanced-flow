---
title: "Human Approval Gate"
capability: "human-approval-gate"
description: "QA loop with review.md artifact, fix-verify cycles, auto_approve bypass, and mandatory human approval"
lastUpdated: "2026-04-10"
---

# Human Approval Gate

No change is finalized without explicit human sign-off. The QA loop ensures that every change is verified via a persistent `review.md` artifact, issues are resolved through a structured fix cycle, and the user gives a clear "Approved" before the change can proceed to finalization.

## Purpose

Automated workflows risk finalizing changes that have unresolved issues or do not meet the developer's expectations. Without an explicit approval gate, a change could be merged with critical verification failures, misunderstood requirements, or untested behavior. The human approval gate prevents this by requiring the user to explicitly approve after reviewing the review.md verification report and success metrics.

## Rationale

The QA loop places verification before approval so that the user reviews concrete findings rather than making a judgment call without data. Verification now produces a `review.md` artifact in the change directory instead of a transient report -- this makes verification persistent, PR-visible, and not skippable (file existence is the check). The fix loop supports bidirectional feedback -- when implementation reveals that a spec is wrong, updating the spec is a valid resolution path. A final verification pass after the fix loop catches issues introduced by the fixes themselves. Success metrics from the design phase are carried into the QA loop as PASS/FAIL checkboxes. The `auto_approve` configuration in WORKFLOW.md allows projects to skip the human gate after a passing review, enabling fully autonomous pipeline execution when desired.

## Features

- **Mandatory Human Approval**: The system requires an explicit "Approved" response before a change can proceed to the post-apply workflow. Ambiguous responses are not accepted.
- **review.md as Approval Gate**: Verification produces a persistent `review.md` artifact in the change directory, replacing the previous transient verify report. The artifact is PR-visible and not skippable.
- **Structured QA Loop**: The tasks.md template includes a QA section with steps in order: Metric Check, Auto-Verify, User Testing, Fix Loop, Final Verify, and Approval. Implementation changes are committed and pushed before User Testing.
- **Success Metric Checkboxes**: Every success metric from `design.md` is carried over as a PASS/FAIL checkbox. All must be marked PASS before approval.
- **Fix-Verify Cycles**: Issues are resolved by fixing code or updating specs. Multiple iterations are supported until all critical issues are resolved.
- **Final Verification Pass**: After the fix loop completes, a final `review.md` is regenerated to confirm all fixes are consistent. Skipped if the fix loop was not entered.
- **Bidirectional Feedback**: When implementation reveals that a spec or design is wrong, updating the spec is a valid resolution path.
- **Auto-Approve Configuration**: When `auto_approve: true` is set in WORKFLOW.md, the pipeline proceeds without user confirmation after a passing review.md verdict. A FAIL verdict always stops regardless of this setting.

## Behavior

### Approval After Clean Verification

When all tasks are complete, apply generates `review.md` in the change directory. If the report shows no CRITICAL or WARNING issues and all success metric checkboxes are marked PASS, the system presents the report and asks for explicit approval. The user responds "Approved" and the system proceeds to the post-apply workflow.

### Critical Issues Block Approval

When a review.md report contains CRITICAL issues, the system does not request approval. It states that critical issues must be resolved first and lists the specific issues.

### Warnings Can Be Acknowledged

When a report contains no CRITICAL issues but does contain WARNINGs, the system requests approval while highlighting the warnings. The user may respond "Approved" to accept them.

### Success Metrics Are Carried Into the QA Loop

When `design.md` contains success metrics, the generated tasks.md includes a PASS/FAIL checkbox for each one. All must be marked PASS before approval can be granted.

### Final Verify Runs After the Fix Loop

When the fix loop resolves all issues, a final `review.md` is regenerated. The final report must confirm 0 CRITICAL issues before approval is requested. If new issues are found, the developer returns to the fix loop.

### Final Verify Is Skipped When First Verify Is Clean

When the first verify finds no CRITICAL or WARNING issues, User Testing finds no bugs, and the fix loop is not entered, the Final Verify step is marked complete immediately.

### Fix Loop Resolves Issues Through Code or Spec Changes

Issues are resolved by fixing code to match the spec or updating the spec to match the intended implementation. After fixes, `review.md` is regenerated to confirm resolution. If a fix introduces a new issue, it appears in the next report. When implementation reveals a design is wrong, updating design.md is a valid resolution.

### Auto-Approve Skips Human Gate

When `auto_approve: true` is set in WORKFLOW.md and review.md's verdict is PASS (no CRITICAL, no WARNING), the pipeline skips the user testing pause and proceeds directly to finalize without pausing for human approval. The design review checkpoint during propose is also skipped. A FAIL or BLOCKED verdict always stops regardless of the setting, and PASS WITH WARNINGS still pauses for acknowledgment.

## Known Limitations

- Spec updates during the fix loop do not automatically re-trigger preflight.
- The fix loop has no maximum iteration count; it continues until the user is satisfied.
- "Approved" is the canonical approval token, recognized case-insensitively.

## Edge Cases

- If review.md has never been generated, the QA Loop approval checkbox is not checked. The system warns that verification has not been performed.
- If code changes are made after the last verify run, the review.md may be stale. The system notes the timestamp relative to recent changes.
- If `design.md` does not contain success metrics, the QA Loop section has no PASS/FAIL checkboxes but still includes the mandatory approval checkbox.
- If the user provides an ambiguous response, the system clarifies that it needs an explicit "Approved."
- If verification produces only SUGGESTION-level findings, the system proceeds directly to requesting approval.
