---
name: verify
description: Verify implementation matches change artifacts. Use when the user wants to validate that implementation is complete, correct, and coherent.
disable-model-invocation: false
---

Verify that an implementation matches the change artifacts (specs, tasks, design).

**Input**: Optionally specify a change name. If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **If no change name provided, prompt for selection**

   **Worktree context detection** (runs first, before directory listing):
   If no explicit change name was provided as an argument:
   1. Run: `git rev-parse --git-dir`
   2. If the result contains `/worktrees/`, derive change name from branch: `git rev-parse --abbrev-ref HEAD`
   3. Search for a directory matching `openspec/changes/*-<branch-name>/` in the current working tree
   4. If valid: auto-select this change and announce "Detected worktree context: using change '<name>'"
   5. If not valid: fall through to normal detection below

   If not detected via worktree: List active change directories under `openspec/changes/` (those with unchecked tasks or no tasks.md). Use the **AskUserQuestion tool** to let the user select.

   Show changes that have implementation tasks (tasks.md exists).
   Mark changes with incomplete tasks as "(In Progress)".

   **IMPORTANT**: Do NOT auto-select from directory listing. Worktree context detection is acceptable.

2. **Check status**

   Read `openspec/WORKFLOW.md` to get the artifact pipeline from its YAML frontmatter. For each artifact, check if its output file exists in `openspec/changes/<name>/`. Note which artifacts are available for verification.

3. **Load artifacts**

   Read all available artifact files from the change directory:
   - `openspec/changes/<change-dir>/research.md`
   - `openspec/changes/<change-dir>/proposal.md`
   - `openspec/changes/<change-dir>/design.md`
   - `openspec/changes/<change-dir>/preflight.md`
   - `openspec/changes/<change-dir>/tasks.md`

   Also read specs for the capabilities listed in the proposal's Capabilities section:
   - `openspec/specs/<capability>/spec.md` for each capability mentioned

4. **Initialize verification report structure**

   Create a report structure with three dimensions:
   - **Completeness**: Track tasks and spec coverage
   - **Correctness**: Track requirement implementation and scenario coverage
   - **Coherence**: Track design adherence and pattern consistency

   Each dimension can have CRITICAL, WARNING, or SUGGESTION issues.

5. **Verify Completeness**

   **Task Completion**:
   - If tasks.md exists, read it
   - Parse checkboxes: `- [ ]` (incomplete) vs `- [x]` (complete)
   - Count complete vs total tasks
   - If incomplete tasks exist:
     - Add CRITICAL issue for each incomplete task
     - Recommendation: "Complete task: <description>" or "Mark as done if already implemented"

   **Spec Coverage** (read-then-compare):
   - Read specs for capabilities listed in the proposal's Capabilities section
   - For each requirement in the relevant specs:
     1. **Identify** the implementation file(s) that should contain this requirement — use design.md references, proposal Impact section, or file naming conventions to locate them
     2. **Read** the relevant section of each implementation file (do NOT just grep for keywords)
     3. **Extract** key terms from the spec requirement: normative language, field names, headings, behavioral descriptions
     4. **Compare** those terms against the implementation content in context:
        - Are the spec's key terms present in the correct section (not just anywhere in the file)?
        - Does the implementation cover the full scope of the requirement?
     5. If the requirement has no corresponding implementation section:
        - Add CRITICAL issue: "Requirement not found: <requirement name>"
        - Recommendation: "Implement requirement X: <description>"

6. **Verify Correctness**

   **Requirement Implementation Mapping** (content comparison):
   - For each requirement from the relevant specs:
     1. **Read** the implementation file section that should contain this requirement (identified during Completeness check)
     2. **Compare terminology**: extract headings, field names, and normative language from the spec requirement, then check if the implementation uses the same terms
        - If the spec says "X" but the implementation says "Y" (e.g., spec says "Change context detection" but implementation says "Worktree context detection"), flag as terminology mismatch
     3. **Compare scope**: if the spec lists N items, fields, or steps, verify the implementation covers all N (not just some)
     4. If terminology mismatch or scope gap detected:
       - Add WARNING: "Implementation diverges from spec: <spec term> vs <implementation term>" or "Implementation covers N of M items from requirement"
       - Recommendation: "Review <file>:<line> — update implementation to match spec terminology, or update spec if the implementation term is correct"

   **Scenario Coverage** (read-and-verify):
   - For each scenario in the relevant specs (marked with "#### Scenario:"):
     1. **Read** the implementation section that should handle the scenario's GIVEN/WHEN/THEN conditions
     2. **Verify preconditions** (GIVEN): does the implementation handle the initial state described?
     3. **Verify triggers** (WHEN): does the implementation respond to the action described?
     4. **Verify assertions** (THEN): does the implementation produce the expected outcome?
     5. Also check if tests exist covering the scenario
     - If the implementation does not cover a scenario's conditions:
       - Add WARNING: "Scenario not covered: <scenario name> — <specific gap, e.g., 'THEN clause expects X but implementation does Y'>"
       - Recommendation: "Add implementation or test for scenario: <description>"

7. **Verify Coherence**

   **Design Adherence**:
   - If design.md exists:
     - Extract key decisions (look for sections like "Decision:", "Approach:", "Architecture:")
     - Verify implementation follows those decisions
     - If contradiction detected:
       - Add WARNING: "Design decision not followed: <decision>"
       - Recommendation: "Update implementation or revise design.md to match reality"
   - If no design.md: Skip design adherence check, note "No design.md to verify against"

   **Code Pattern Consistency**:
   - Review new code for consistency with project patterns
   - Check file naming, directory structure, coding style
   - If significant deviations found:
     - Add SUGGESTION: "Code pattern deviation: <details>"
     - Recommendation: "Consider following project pattern: <example>"

8. **Verify Preflight Side-Effects**

   Cross-check side-effects from preflight against tasks and implementation:
   - Read `preflight.md` Section C (Side-Effect Analysis)
   - Extract side-effect entries from tables or lists (look for risk descriptions with assessments)
   - Filter out entries assessed as "NONE", "Zero", or similar (no actual risk identified)
   - For each remaining side-effect:
     1. Search `tasks.md` for a keyword match against the side-effect description
     2. If no task match: search codebase for keyword evidence of the side-effect being addressed
     3. If neither task nor code evidence found:
        - Add WARNING: "Preflight side-effect not addressed: <side-effect description>"
        - Recommendation: "Add a task or verify that this side-effect is handled in the implementation"
     4. If task or code evidence found: mark as addressed, no issue raised
   - If Section C contains no actionable side-effects (all NONE or empty): skip and note "No preflight side-effects to verify"
   - If a side-effect description is too generic for meaningful keyword matching: skip that entry and note as inconclusive

9. **Generate Verification Report**

   **Summary Scorecard**:
   ```
   ## Verification Report: <change-name>

   ### Summary
   | Dimension      | Status           |
   |----------------|------------------|
   | Completeness   | X/Y tasks, N reqs|
   | Correctness    | M/N reqs covered |
   | Coherence      | Followed/Issues  |
   | Side-Effects   | N checked, M unaddressed |
   ```

   **Auto-Fix Pass** (before presenting the report):

   Before generating the final report, scan all WARNING-level findings
   for mechanically fixable issues — stale cross-references between
   artifacts, inconsistent naming, or outdated text correctable by
   simple text replacement without judgment. Auto-fix these inline
   (edit the affected file) and record them as "WARNING (auto-fixed)"
   in the report. Do NOT auto-fix WARNINGs that require user judgment
   (e.g., spec/design divergence where the user must choose which is
   correct) — present those as open issues.

   **Issues by Priority**:

   1. **CRITICAL** (Must fix before proceeding):
      - Incomplete tasks
      - Missing requirement implementations
      - Each with specific, actionable recommendation

   2. **WARNING** (Should fix):
      - Spec/design divergences
      - Missing scenario coverage
      - Unaddressed preflight side-effects
      - Each with specific recommendation
      - Auto-fixed warnings listed separately as "WARNING (auto-fixed)"

   3. **SUGGESTION** (Nice to fix):
      - Pattern inconsistencies
      - Minor improvements
      - Each with specific recommendation

   **Final Assessment**:
   - If CRITICAL issues: "X critical issue(s) found. Fix before proceeding."
   - If only warnings: "No critical issues. Y warning(s) to consider. Ready to proceed (with noted improvements)."
   - If all clear: "All checks passed. Ready to proceed with post-apply workflow."

**Verification Heuristics**

- **Completeness**: Focus on objective checklist items (checkboxes, requirements list)
- **Correctness**: Read implementation files and compare content against spec requirements — use keyword search only for initial file discovery, then read and compare the relevant sections. Don't require perfect certainty, but DO read the actual content before concluding a requirement is covered
- **Coherence**: Look for glaring inconsistencies, don't nitpick style
- **Side-Effects**: Use keyword matching from preflight Section C against tasks and codebase — skip entries that are too generic for meaningful matching
- **False Positives**: When uncertain, prefer SUGGESTION over WARNING, WARNING over CRITICAL
- **Actionability**: Every issue must have a specific recommendation with file/line references where applicable

**Graceful Degradation**

- If only tasks.md exists: verify task completion only, skip spec/design checks
- If tasks + specs exist: verify completeness and correctness, skip design
- If full artifacts: verify all three dimensions
- Always note which checks were skipped and why

**Output Format**

Use clear markdown with:
- Table for summary scorecard
- Grouped lists for issues (CRITICAL/WARNING/SUGGESTION)
- Code references in format: `file.ts:123`
- Specific, actionable recommendations
- No vague suggestions like "consider reviewing"
