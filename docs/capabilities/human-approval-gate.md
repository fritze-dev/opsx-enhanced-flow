---
title: "Human Approval Gate"
capability: "human-approval-gate"
description: "Mandatory human approval with QA loop, success metrics, and fix-verify cycles before archiving"
order: 11
lastUpdated: "2026-03-04"
---

# Human Approval Gate

No change is finalized without your explicit approval. The QA loop includes success metric validation, automated verification, user testing, fix-verify cycles, and a mandatory "Approved" sign-off before archiving.

## Features

- Mandatory explicit human approval before any change can be archived
- Success metrics from design carried over as PASS/FAIL checkboxes in the QA loop
- Structured fix-verify loop for resolving issues found during verification
- Bidirectional feedback — update code to match specs, or update specs to match implementation
- Final verification pass after the fix loop to confirm consistency

## Behavior

### QA Loop Structure

The QA loop follows these steps:
1. **Metric Check** — validate success metrics as PASS or FAIL
2. **Auto-Verify** — run `/opsx:verify` to produce a verification report
3. **User Testing** — pause for you to test manually
4. **Fix Loop** — fix issues, then re-verify
5. **Final Verify** — run `/opsx:verify` one last time to confirm all fixes are consistent
6. **Approval** — only proceed on your explicit "Approved"

### Approval Requirements

Approval is only requested after verification has been run and all CRITICAL issues have been resolved. If CRITICAL issues remain, the system states they must be resolved first and does not request approval. If only WARNING issues remain, you can approve while acknowledging the warnings. All success metric checkboxes must be marked PASS before approval is granted.

### Fix-Verify Loop

When verification finds CRITICAL or WARNING issues, you address each by either fixing the code to match the spec or updating the spec to match the intended implementation. After fixes, you re-run `/opsx:verify` to confirm resolution. This cycle repeats until all CRITICAL issues are resolved. Updating specs is a valid resolution path — when implementation reveals that a spec is wrong, the spec should be corrected.

### Final Verification

After the fix loop completes, a final `/opsx:verify` runs to ensure all changes made during the fix loop (spec updates, design changes, code fixes) are consistent. If this final verify finds new issues introduced by fixes, you return to the fix loop. If the first verify was clean and no fixes were needed, the final verify step is marked complete immediately.

### Archiving Without Approval

If you attempt to archive without having completed the QA loop, the system warns that human approval has not been given and prompts you to complete the loop first.

## Edge Cases

- If you have never run `/opsx:verify` for the current change, the approval checkbox is not checked and the system warns during archive.
- If code changes are made after the last verify run, the verification report may be stale — the system notes the timestamp of the last verify relative to the most recent code changes.
- If design.md does not contain explicit success metrics, the QA loop still includes the mandatory approval checkbox but has no PASS/FAIL metric checkboxes.
- If you respond with something ambiguous (e.g., "looks ok"), the system clarifies that it needs an explicit "Approved" and does not treat ambiguous responses as approval.
- If verification produces only SUGGESTION-level findings, the system proceeds directly to requesting approval without requiring fixes.
- If a CRITICAL issue is a false positive, re-running verify with the same code is a valid fix loop iteration.
