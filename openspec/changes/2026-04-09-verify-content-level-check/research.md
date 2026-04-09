# Research: Verify Content-Level Check

## 1. Current State

The verify skill ([src/skills/verify/SKILL.md](src/skills/verify/SKILL.md)) performs post-implementation verification across three dimensions: Completeness, Correctness, and Coherence. The quality-gates spec ([openspec/specs/quality-gates/spec.md](openspec/specs/quality-gates/spec.md)) defines the requirements.

**How verification currently works (steps 5-7 in SKILL.md):**

- **Completeness (Step 5):** Parses task checkboxes + "search codebase for keywords related to the requirement" to assess if implementation exists.
- **Correctness (Step 6):** "Search codebase for implementation evidence" + "Assess if implementation matches requirement intent." For scenarios: "Check if conditions are handled in code."
- **Coherence (Step 7):** Extract design decisions, "verify implementation follows those decisions." Check file naming, directory structure, coding style.

**The gap:** The instructions say "search for keywords" and "assess if implementation matches" but provide no guidance on HOW to do content-level comparison. In practice, this results in shallow keyword grep (e.g., `grep -c "collision"`) confirming word presence without checking whether the word appears in the correct context or whether the implementation semantically matches the requirement.

**Concrete failure (Issue #93):** During the spec-frontmatter-tracking change, verify reported 0 issues. But the verify skill itself had a stale heading — "Worktree context detection" (line 15) instead of "Change context detection" as required by the updated spec. A keyword search for "worktree" or "context detection" would match, but reading the actual content reveals the terminology mismatch.

**What the spec already requires but the skill under-delivers on:**
- The spec says "requirement implementation **accuracy**" — not just presence
- Scenario "Verification finds implementation diverging from spec" explicitly expects content-level divergence detection (JWT vs session cookies)
- The spec says verify should produce "specific actionable recommendations with file and line references"

**Affected files:**
- `src/skills/verify/SKILL.md` — the skill instructions (primary target)
- `openspec/specs/quality-gates/spec.md` — the governing spec (may need minor refinement)

## 2. External Research

Not applicable — this is an internal skill instruction improvement. No external APIs or libraries involved.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Enhance skill instructions with explicit read-then-compare pattern** — Replace "search for keywords" with "read the implementation file, extract the relevant section, compare against each spec requirement" | Directly addresses the root cause; stays within skill instruction layer; no spec changes needed | Longer skill instructions; relies on agent following more detailed guidance |
| **B: Add a dedicated "content comparison" step** — Insert a new step between Correctness and Coherence that specifically reads each modified file and diffs terminology against specs | Clean separation of concerns; easier to understand | Adds a 9th step to an already long skill; content comparison is really part of Correctness, not a separate dimension |
| **C: Spec-level change to redefine verification methodology** — Change the spec's Heuristic Search assumption and add a new requirement for content-level comparison | Makes the expectation explicit at spec level | Over-engineering — the spec already says "accuracy"; the skill just needs better instructions to deliver on it |

**Recommendation:** Approach A. The spec already requires accuracy-level verification. The skill instructions just need to be more explicit about the methodology: read-then-compare instead of grep-then-infer.

## 4. Risks & Constraints

- **Skill immutability rule**: The constitution says "Skills in `skills/` are generic plugin code shared across all consumers. They MUST NOT be modified for project-specific behavior." However, this change is NOT project-specific — improving verification accuracy benefits all consumers. The change is to the generic skill instructions, not adding project-specific logic.
- **Instruction length**: The verify skill is already 200 lines. Adding more detailed comparison instructions increases length. Mitigated by replacing vague instructions with specific ones (net length increase should be modest).
- **Agent compliance**: More detailed instructions don't guarantee the agent will follow them perfectly. But explicit "read the file content" instructions are much more likely to produce file reads than vague "search for keywords."
- **Performance**: Reading full files instead of keyword searching is slower on large codebases. For markdown-based projects (like this one) this is negligible. For code projects, the skill already says "focus on files referenced in design.md and recently modified files" — this constraint remains.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Enhance verify skill instructions for content-level comparison |
| Behavior | Clear | Replace keyword grep with read-then-compare in steps 5-7 |
| Data Model | Clear | No data model changes — same report format |
| UX | Clear | Same command, same output format, better results |
| Integration | Clear | No integration changes — skill reads same files |
| Edge Cases | Clear | Handled by existing graceful degradation + false positive guidance |
| Constraints | Clear | Skill immutability respected (generic improvement) |
| Terminology | Clear | "Content-level verification" vs "keyword matching" is well-defined |
| Non-Functional | Clear | Minor performance impact, negligible for markdown projects |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Enhance skill instructions (Approach A) | Spec already requires accuracy; skill just needs explicit methodology | Dedicated step (B) — rejected as over-separation; Spec change (C) — rejected as unnecessary |
| 2 | No spec changes needed | The quality-gates spec already says "accuracy" and has scenarios for divergence detection; the gap is in skill instruction detail, not spec requirements | Adding a new requirement for content comparison — rejected as redundant with existing Correctness requirement |
