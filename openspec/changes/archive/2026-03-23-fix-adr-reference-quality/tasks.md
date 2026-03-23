# Implementation Tasks: Fix ADR Reference Quality

## 1. Foundation

- [x] 1.1. Read `skills/docs/SKILL.md` Step 4 References paragraph to identify exact text to modify

## 2. Implementation

### Internal-Only References (SKILL.md)
- [x] 2.1. Replace the References instruction in Step 4: add "References SHALL contain only internal relative links (archive backlinks, spec links, ADR cross-references). Do NOT include external URLs (GitHub issues, external docs)."
- [x] 2.2. Remove the line "If the design.md or research.md references GitHub Issues, include those too" from the References paragraph
- [x] 2.3. Remove any mention of GitHub Issues from the References determination in the existing decision-docs spec reference

### Reference Validation (SKILL.md)
- [x] 2.4. Add reference validation sub-paragraph to Step 4: after writing References, glob to verify every `[Spec: <name>]` link exists; replace broken links with successors or add `<!-- REVIEW -->` marker
- [x] 2.5. Add archive link validation: verify `[Archive: <name>]` links point to existing archive directories

### Cross-Reference Heuristic (SKILL.md)
- [x] 2.6. Add cross-reference heuristic sub-paragraph: check if current archive references other changes by name or modifies same capabilities as earlier ADRs; add back-references when relationship is clear

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md — PASS / FAIL:
  - [x] No external URLs in any generated ADR References — PASS (instruction explicitly forbids external URLs)
  - [x] Every `[Spec: ...]` link points to an existing spec — PASS (validation step globs to verify)
  - [x] Every `[Archive: ...]` link points to an existing archive — PASS (validation step globs to verify)
  - [x] ADRs modifying earlier systems include cross-references — PASS (cross-reference heuristic added)
- [x] 3.2. Auto-Verify: Run `/opsx:verify` — all checks passed, no issues.
- [x] 3.3. User Testing: User approved.
- [x] 3.4. Fix Loop: Not entered — no issues found.
- [x] 3.5. Final Verify: Skipped — 3.4 was not entered.
- [x] 3.6. Approval: User approved.
