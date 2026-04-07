---
title: "Human Approval Gate"
capability: "human-approval-gate"
description: "Defines the QA loop with mandatory explicit human approval before archiving, including verification, fix-verify cycles, and bidirectional feedback."
lastUpdated: "2026-04-07"
---

# Human Approval Gate

No change is finalized without explicit human sign-off. The QA loop ensures that every change is verified, issues are resolved through a structured fix cycle, and the user gives a clear "Approved" before the change can be archived.

## Purpose

Automated workflows risk finalizing changes that have unresolved issues or do not meet the developer's expectations. Without an explicit approval gate, a change could be archived with critical verification failures, misunderstood requirements, or untested behavior. The human approval gate prevents this by requiring the user to explicitly approve after reviewing verification results and success metrics.

## Rationale

The QA loop places verification before approval so that the user reviews concrete findings rather than making a judgment call without data. The fix loop supports bidirectional feedback -- when implementation reveals that a spec is wrong, updating the spec is a valid resolution path, not just fixing code. A final verification pass after the fix loop catches issues introduced by the fixes themselves. Success metrics from the design phase are carried into the QA loop as PASS/FAIL checkboxes, providing measurable acceptance criteria rather than subjective assessments. The explicit "Approved" token prevents ambiguous responses from being treated as approval.

## Features

- **Mandatory Human Approval**: The system requires an explicit "Approved" response before a change can be archived. Ambiguous responses (like "looks ok" or "seems fine") are not accepted.
- **Structured QA Loop**: The tasks.md template includes a QA section with these steps in order: Metric Check, Auto-Verify, User Testing, Fix Loop, Final Verify, and Approval. Implementation changes are committed and pushed before User Testing via the `apply.instruction` in WORKFLOW.md.
- **Success Metric Checkboxes**: Every success metric from `design.md` is carried over as a PASS/FAIL checkbox in the QA Loop section. All must be marked PASS before approval.
- **Fix-Verify Cycles**: Issues found during verification are resolved either by fixing the code to match the spec or by updating the spec to match the implementation. Multiple iterations are supported until all critical issues are resolved.
- **Final Verification Pass**: After the fix loop completes, a final `/opsx:verify` run confirms that all fixes are consistent. This step is skipped if the fix loop was not entered.
- **Bidirectional Feedback**: When implementation reveals that a spec or design is wrong, updating the spec is a valid resolution path.

## Behavior

### Approval After Clean Verification

When all tasks are complete, the user runs `/opsx:verify`, which produces a verification report. If the report shows no CRITICAL or WARNING issues and all success metric checkboxes are marked PASS, the system presents the report and asks for explicit approval. The user responds "Approved" and the system allows archiving to proceed.

### Archiving Is Blocked Without Approval

If the user attempts to invoke `/opsx:archive` without having completed the QA loop, the system checks the approval checkbox in the QA Loop section of tasks.md. If it is not checked, the system warns that human approval has not been given and prompts the user to complete the QA loop first.

### Critical Issues Block Approval

When a verification report contains CRITICAL issues, the system does not request approval. Instead, it states that critical issues must be resolved first and lists the specific issues requiring resolution. The user must address them through the fix loop before approval can be requested.

### Warnings Can Be Acknowledged

When a verification report contains no CRITICAL issues but does contain WARNING issues, the system requests approval while highlighting the warnings. The user may respond "Approved" to accept the warnings, and the system proceeds to allow archiving.

### Success Metrics Are Carried Into the QA Loop

When `design.md` contains success metrics (for example, "Auth response time < 200ms", "All endpoints require valid JWT"), the generated tasks.md includes a PASS/FAIL checkbox for each one in the QA Loop section. Each checkbox must be marked by the user or verifier during the QA phase. All must be marked PASS before approval can be granted.

### Final Verify Runs After the Fix Loop

When Auto-Verify finds CRITICAL issues and the developer completes the Fix Loop, the system runs `/opsx:verify` one final time (Final Verify). The final verify report must confirm 0 CRITICAL issues before the system proceeds to request Approval. If Final Verify discovers new issues introduced by Fix Loop changes, the developer returns to the Fix Loop to resolve them and then re-runs Final Verify.

### Final Verify Is Skipped When First Verify Is Clean

When Auto-Verify finds no CRITICAL or WARNING issues, User Testing finds no bugs, and the Fix Loop is not entered, the Final Verify step is marked complete immediately and the system proceeds to Approval.

### Fix Loop Resolves Issues Through Code or Spec Changes

When verification finds CRITICAL or WARNING issues, the user addresses each by either fixing the code to match the spec or updating the spec to match the intended implementation. After fixes are applied, the user re-runs `/opsx:verify` to confirm resolution. If a fix introduces a new issue, the new issue appears in the next verification report and must also be addressed. When implementation reveals that a spec or design is wrong, updating the design document to reflect the actual architecture is a valid resolution.

## Known Limitations

- Spec updates during the fix loop do not automatically re-trigger the preflight check. The user can manually re-run preflight if desired.
- The fix loop has no maximum iteration count; it continues until the user is satisfied.
- "Approved" is the canonical approval token, recognized case-insensitively. No other approval phrases are accepted.

## Edge Cases

- If the user has never run `/opsx:verify` for the current change, the QA Loop approval checkbox in tasks.md is not checked. The system warns during archive that verification has not been performed.
- If code changes are made after the last verify run, the verification report may be stale. The system notes the timestamp of the last verify run relative to the most recent code changes when the user requests archive.
- If `design.md` does not contain explicit success metrics, the QA Loop section still includes the mandatory human approval checkbox but has no PASS/FAIL metric checkboxes.
- If the user provides an ambiguous response (like "looks ok"), the system clarifies that it needs an explicit "Approved" and does not treat ambiguous responses as approval.
- If verification produces only SUGGESTION-level findings and no CRITICAL or WARNING issues, the system proceeds directly to requesting approval without requiring fixes.
- If a CRITICAL issue is a false positive (for example, a keyword search matched unrelated code), the user may acknowledge the false positive. Re-running verify with the same code is a valid fix loop iteration.
- If the Fix Loop produces additional changes, those changes are committed during the Fix Loop's re-verify cycle. The initial commit before User Testing captures the implementation state at first verify pass; subsequent Fix Loop commits are incremental.
