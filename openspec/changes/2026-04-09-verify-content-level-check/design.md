# Technical Design: Verify Content-Level Check

## Context

The verify skill (`src/skills/verify/SKILL.md`) performs post-implementation verification. Steps 5–7 instruct the agent to "search codebase for keywords" and "assess if implementation matches," but this vague guidance produces shallow grep-based checks. The agent confirms keyword presence without reading implementation content or comparing it against spec requirements. This caused a false-pass where a stale heading went undetected (Issue #93).

The quality-gates spec already requires "implementation accuracy" and has scenarios for divergence detection. The skill instructions just need a more explicit methodology.

## Architecture & Components

**Single file affected:** `src/skills/verify/SKILL.md`

Changes are localized to three sections of the skill instructions:

1. **Step 5 — Spec Coverage** (lines 65–72): Replace "search codebase for keywords" with read-then-compare instructions
2. **Step 6 — Requirement Implementation Mapping** (lines 76–83): Replace "search codebase for implementation evidence" with explicit content comparison instructions
3. **Step 6 — Scenario Coverage** (lines 85–91): Replace "check if conditions are handled" with read-and-verify instructions
4. **Verification Heuristics** (lines 177–184): Update Correctness heuristic from "keyword search" to "content comparison"

**What changes in agent behavior:**

| Current (keyword grep) | New (read-then-compare) |
|------------------------|------------------------|
| `grep -c "collision"` in codebase → word found → pass | Read implementation file → locate the section implementing the requirement → compare content against spec requirement → check terminology matches |
| "search for keywords related to the requirement" | "read each implementation file that should contain the requirement, extract the relevant section, and compare it against the spec requirement text" |
| "assess if implementation matches requirement intent" | "compare spec terminology against implementation text — flag if spec says X but implementation says Y" |

**The read-then-compare pattern:**

For each spec requirement:
1. **Identify** the implementation file(s) that should contain this requirement (from design.md references, file naming conventions, or proposal's Impact section)
2. **Read** the relevant section of each implementation file
3. **Extract** key terms from the spec requirement (normative language, field names, headings, behavioral descriptions)
4. **Compare** those terms against the implementation content:
   - Are the terms present in the correct context (not just anywhere in the file)?
   - Does the implementation use the same terminology as the spec?
   - Does the implementation cover the full scope of the requirement (not just part of it)?
5. **Flag** mismatches: terminology differences, missing coverage, stale references

## Goals & Success Metrics

* Verify detects terminology mismatches between spec and implementation (e.g., spec says "Change context detection" but implementation says "Worktree context detection") — PASS/FAIL
* Verify reads actual file content before reporting coverage, not just keyword grep — PASS/FAIL
* Verify reports stale headings, field names, or normative language as WARNING with file:line references — PASS/FAIL

## Non-Goals

- Changing the quality-gates spec requirements
- Adding new verification dimensions
- Changing the report format or severity classification
- Optimizing for very large codebases (existing constraints remain)
- Perfect semantic understanding (the agent still uses heuristics, just better-informed ones)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Replace vague instructions inline (not add new step) | Content comparison is part of Correctness, not a separate dimension — adding a step would bloat the already long skill | Add a dedicated Step 6b for content comparison — rejected as over-separation |
| Keep "keyword search" as fallback for large codebases | For code projects with many files, keyword search is still useful for initial file discovery before reading | Remove keyword search entirely — rejected as it still helps narrow down files to read |
| Update Verification Heuristics to say "content comparison" | Heuristics section shapes agent behavior for edge cases; saying "keyword search" there undermines the new instructions | Leave heuristics unchanged — rejected as contradictory |

## Risks & Trade-offs

- [Agent may still shortcut to keyword grep despite instructions] → Mitigated by explicit "you MUST read the file" language and concrete examples of what content comparison looks like
- [Longer instructions increase skill file length] → Mitigated by replacing vague text with specific text (net increase ~20-30 lines, not additive bloat)
- [Reading full files is slower than grep on large codebases] → Mitigated by keeping the existing "focus on files referenced in design.md" constraint; the new instructions add "identify the file first, then read the relevant section"

## Open Questions

No open questions.

## Assumptions

No assumptions made.
