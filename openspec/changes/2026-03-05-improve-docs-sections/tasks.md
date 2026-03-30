# Implementation Tasks: Improve Docs Sections

## 1. Foundation

- [x] 1.1. Update capability doc template (`openspec/schemas/opsx-enhanced/templates/docs/capability.md`): rename "Why This Exists" → "Purpose" with BAD/GOOD guidance, merge "Background"/"Design Rationale" → "Rationale", add "Future Enhancements" section
- [x] 1.2. Update SKILL.md (`skills/docs/SKILL.md`): add "CRITICAL — Purpose section source" guidance, Non-Goals classification, "read before write" guardrail, update conciseness guards for new headings
- [x] 1.3. Update user-docs baseline spec (`openspec/specs/user-docs/spec.md`): align section names, add Future Enhancements requirement and scenarios

## 2. Implementation

- [x] 2.1. [P] Rename headings in all 18 capability docs: "Why This Exists" → "Purpose", "Background"/"Design Rationale" → "Rationale"
- [x] 2.2. [P] Add "Known Limitations" section to capability docs where applicable (architecture-docs, artifact-generation, decision-docs)
- [x] 2.3. [P] Add "Future Enhancements" section to capability docs where applicable (release-workflow, artifact-generation, user-docs, quality-gates, interactive-discovery, task-implementation)
- [x] 2.4. Update user-docs.md content to reflect new enrichment sections (Purpose/Rationale/Future Enhancements descriptions in Features and Behavior)

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: All 18 docs use "Purpose" and "Rationale" headings — PASS
- [x] 3.2. Metric Check: Every Purpose section describes capability purpose via problem-framing — PASS
- [x] 3.3. Metric Check: Every Rationale section describes design reasoning, not change events — PASS
- [x] 3.4. Metric Check: 6+ docs include "Future Enhancements" section — PASS (6 docs)
- [x] 3.5. Metric Check: SKILL.md contains Purpose source guidance and read-before-write guardrail — PASS
- [x] 3.6. Metric Check: Template includes Future Enhancements section — PASS
- [x] 3.7. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command). — PASSED, 0 critical, 0 warnings
- [x] 3.8. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.9. Fix Loop: Skipped — no issues found.
- [x] 3.10. Final Verify: Skipped — fix loop not entered.
- [x] 3.11. Approval: **Approved** by user.
