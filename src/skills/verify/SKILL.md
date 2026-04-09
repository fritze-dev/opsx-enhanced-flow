---
name: verify
description: Verify implementation matches change artifacts. Use when the user wants to validate that implementation is complete, correct, and coherent.
disable-model-invocation: false
---

Verify that an implementation matches the change artifacts (specs, tasks, design).

**Input**: Optionally specify a change name. If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **Select change**

   **Change context detection** (runs first, before directory listing):
   If no explicit change name was provided as an argument:
   1. Get current branch: `git rev-parse --abbrev-ref HEAD`
   2. **Proposal frontmatter lookup**: Scan `openspec/changes/*/proposal.md` for a proposal whose YAML frontmatter `branch` field matches the current branch. If found, auto-select that change.
   3. **Fallback — worktree convention**: If no matching proposal frontmatter, check if inside a worktree (`git rev-parse --git-dir` contains `/worktrees/`), derive change name from branch, search for `openspec/changes/*-<branch-name>/`.
   4. If valid: auto-select and announce "Detected change context: using change '<name>'"
   5. If not valid: fall through to normal detection below

   If not detected via context: List active change directories under `openspec/changes/` (those whose `proposal.md` has frontmatter `status: active`, or fallback: unchecked tasks or no tasks.md). Use the **AskUserQuestion tool** to let the user select.

   Show changes that have implementation tasks (tasks.md exists).
   Mark changes with incomplete tasks as "(In Progress)".

   **IMPORTANT**: Do NOT auto-select from directory listing. Change context detection (proposal frontmatter or worktree) is acceptable.

2. **Check status**

   Read `openspec/WORKFLOW.md` to get the artifact pipeline from its YAML frontmatter. For each artifact, check if its output file exists in `openspec/changes/<name>/`. Note which artifacts are available for verification.

3. **Load context**

   Read all available artifact files from the change directory:
   - `openspec/changes/<change-dir>/research.md`
   - `openspec/changes/<change-dir>/proposal.md`
   - `openspec/changes/<change-dir>/design.md`
   - `openspec/changes/<change-dir>/preflight.md`
   - `openspec/changes/<change-dir>/tasks.md`

   Read the proposal's YAML frontmatter `capabilities` field to identify affected specs. If frontmatter is absent, fall back to parsing the `## Capabilities` section.
   - `openspec/specs/<capability>/spec.md` for each capability listed

   **Draft spec gate**: For each spec listed in the proposal's capabilities, check the spec's frontmatter. If `status: draft` and `change` matches the current change directory, flag as CRITICAL: "Spec <name> is still in draft status — must be finalized before merge."

   Load the branch diff:
   1. Run `git merge-base HEAD main` to find the common ancestor commit
   2. If successful, run `git diff <base>...HEAD` to get the full diff content, and `git diff <base>...HEAD --name-only` to get the changed file list. Store both for use in subsequent steps.
   3. If `git merge-base` fails (no common ancestor — e.g., orphan branch, first commit, detached HEAD), set a flag to skip all diff-based checks. Note "No merge base available — diff checks skipped" for inclusion in the report.
   4. From the file list, exclude files under `openspec/changes/` and `openspec/specs/` — these are expected in the diff for any OpenSpec change and should not be flagged as unintended.

4. **Verify Implementation** (Completeness + Correctness)

   Check that all planned work was completed and that the actual changes match what was specified.

   **Task Completion**:
   - Parse checkboxes in tasks.md: `- [ ]` (incomplete) vs `- [x]` (complete)
   - Count complete vs total tasks
   - If incomplete tasks exist:
     - Add CRITICAL issue for each incomplete task
     - Recommendation: "Complete task: <description>" or "Mark as done if already implemented"

   **Task-Diff Mapping** (skip if diff unavailable):
   - For each task marked complete (`- [x]`) in tasks.md:
     - Extract keywords from the task description (component names, file names, module references)
     - Check whether at least one file in the diff file list matches those keywords
     - If a match is found, additionally check the diff content for evidence that the task was actually addressed (e.g., a task about "Add error handling" should show error-handling code in the diff, not just a comment change)
     - If a task description is too generic to produce meaningful matches (e.g., "Clean up code"), skip it and note as inconclusive
     - If a completed task has no corresponding file or content evidence in the diff:
       - Add WARNING: "Task marked complete but no corresponding changes in diff: <task description>"
       - Recommendation: "Verify this task was implemented or update the task description"

   **Requirement Verification** (using diff as primary evidence, content comparison for correctness):
   - For each requirement in the relevant specs:
     1. **Identify** the implementation file(s) that should contain this requirement — use design.md references, proposal Impact section, or file naming conventions to locate them
     2. **Diff evidence** (primary): Search the diff content for keywords and patterns related to the requirement. The diff shows exactly what this change introduced — it is the most relevant evidence source.
     3. **Codebase evidence** (fallback): If the requirement may have been implemented in a prior change or pre-existing code, search the codebase for keywords related to the requirement.
     4. **Content comparison** (correctness): When evidence is found, **read** the relevant section of the implementation file (do NOT just confirm keyword presence) and compare against the spec requirement:
        - **Compare terminology**: extract headings, field names, and normative language from the spec requirement, then check if the implementation uses the same terms. If the spec says "X" but the implementation says "Y" (e.g., spec says "Change context detection" but implementation says "Worktree context detection"), flag as terminology mismatch.
        - **Compare scope**: if the spec lists N items, fields, or steps, verify the implementation covers all N (not just some)
     5. Assess whether the evidence matches the requirement intent:
        - If no evidence found anywhere: Add CRITICAL issue: "Requirement not implemented: <requirement name>"
        - If terminology mismatch or scope gap detected: Add WARNING: "Implementation diverges from spec: <spec term> vs <implementation term>" or "Implementation covers N of M items from requirement". Recommendation: "Review <file>:<line> — update implementation to match spec terminology, or update spec if the implementation term is correct"
        - If evidence matches: requirement is satisfied

   **Scenario Coverage** (read-and-verify):
   - For each scenario in the relevant specs (marked with "#### Scenario:"):
     1. **Read** the implementation section that should handle the scenario's GIVEN/WHEN/THEN conditions (check diff content first, then codebase as fallback)
     2. **Verify preconditions** (GIVEN): does the implementation handle the initial state described?
     3. **Verify triggers** (WHEN): does the implementation respond to the action described?
     4. **Verify assertions** (THEN): does the implementation produce the expected outcome?
     5. Also check if tests exist covering the scenario
     - If the implementation does not cover a scenario's conditions:
       - Add WARNING: "Scenario not covered: <scenario name> — <specific gap, e.g., 'THEN clause expects X but implementation does Y'>"
       - Recommendation: "Add implementation or test for scenario: <description>"

5. **Verify Scope** (Coherence + Side-Effects)

   Check that the change stays within planned boundaries and doesn't introduce unintended side-effects.

   **Design Adherence**:
   - If design.md exists:
     - Extract key decisions (look for sections like "Decision:", "Approach:", "Architecture:")
     - Verify implementation follows those decisions (check diff content for evidence)
     - If contradiction detected:
       - Add WARNING: "Design decision not followed: <decision>"
       - Recommendation: "Update implementation or revise design.md to match reality"
   - If no design.md: Skip design adherence check, note "No design.md to verify against"

   **Diff Scope Check** (skip if diff unavailable):
   - For each file in the diff file list (after exclusions):
     - Check whether the file is traceable to a task description in `tasks.md` or a component listed in `design.md`'s Architecture & Components section
     - A file is "traceable" if its path or filename matches keywords from any task description or design component entry
   - Collect all untraced files (files with no connection to any task or design component)
   - If untraced files exist:
     - Add a single grouped SUGGESTION: "Untraced files in diff not covered by any task or design component:" followed by the list of file paths
     - Recommendation: "Review these files — they may be legitimate dependencies or accidental changes"

   **Preflight Side-Effects**:
   - Read `preflight.md` Section C (Side-Effect Analysis)
   - Extract side-effect entries from tables or lists (look for risk descriptions with assessments)
   - Filter out entries assessed as "NONE", "Zero", or similar (no actual risk identified)
   - For each remaining side-effect:
     1. Search `tasks.md` for a keyword match against the side-effect description
     2. If no task match: search diff content and codebase for evidence of the side-effect being addressed
     3. If neither task nor evidence found:
        - Add WARNING: "Preflight side-effect not addressed: <side-effect description>"
        - Recommendation: "Add a task or verify that this side-effect is handled in the implementation"
     4. If evidence found: mark as addressed, no issue raised
   - If Section C contains no actionable side-effects (all NONE or empty): skip and note "No preflight side-effects to verify"
   - If a side-effect description is too generic for meaningful keyword matching: skip that entry and note as inconclusive

   **Code Pattern Consistency**:
   - Review new code (from diff content) for consistency with project patterns
   - Check file naming, directory structure, coding style
   - If significant deviations found:
     - Add SUGGESTION: "Code pattern deviation: <details>"
     - Recommendation: "Consider following project pattern: <example>"

6. **Generate Verification Report**

   **Auto-Fix Pass** (before presenting the report):

   Scan all WARNING-level findings for mechanically fixable issues — stale
   cross-references between artifacts, inconsistent naming, or outdated text
   correctable by simple text replacement without judgment. Auto-fix these
   inline (edit the affected file) and record them as "WARNING (auto-fixed)"
   in the report. Do NOT auto-fix WARNINGs that require user judgment
   (e.g., spec/design divergence where the user must choose which is
   correct) — present those as open issues.

   **Summary Scorecard**:
   ```
   ## Verification Report: <change-name>

   ### Summary
   | Dimension      | Status           |
   |----------------|------------------|
   | Implementation | X/Y tasks, N/M reqs verified |
   | Scope          | N files checked, M untraced, K side-effects |
   ```

   **Issues by Priority**:

   1. **CRITICAL** (Must fix before proceeding):
      - Incomplete tasks
      - Missing requirement implementations
      - Each with specific, actionable recommendation

   2. **WARNING** (Should fix):
      - Spec/implementation divergences
      - Tasks complete but no diff evidence
      - Missing scenario coverage
      - Unaddressed preflight side-effects
      - Design decisions not followed
      - Each with specific recommendation
      - Auto-fixed warnings listed separately as "WARNING (auto-fixed)"

   3. **SUGGESTION** (Nice to fix):
      - Untraced files in diff
      - Pattern inconsistencies
      - Each with specific recommendation

   **Final Assessment**:
   - If CRITICAL issues: "X critical issue(s) found. Fix before proceeding."
   - If only warnings: "No critical issues. Y warning(s) to consider. Ready to proceed (with noted improvements)."
   - If all clear: "All checks passed. Ready to proceed with post-apply workflow."

**Verification Heuristics**

- **Implementation**: Use diff content as primary evidence for what this change introduced. Fall back to codebase search for pre-existing implementations. When evidence is found, read the actual implementation content and compare against spec requirements — don't just confirm keyword presence. Check both existence and correctness in one pass — don't require perfect certainty, but DO read the actual content before concluding a requirement is covered.
- **Task-Diff Mapping**: Match task description keywords against file paths AND diff content. A file-level match alone is insufficient — verify the content relates to the task. Generic tasks (no specific component/file references) are inconclusive, not failures.
- **Scope**: Use file path keyword matching for traceability. Check design decisions against diff evidence. When uncertain, do not flag (err toward fewer false positives).
- **Side-Effects**: Use keyword matching from preflight Section C against tasks, diff content, and codebase — skip entries that are too generic for meaningful matching.
- **False Positives**: When uncertain, prefer SUGGESTION over WARNING, WARNING over CRITICAL.
- **Actionability**: Every issue must have a specific recommendation with file/line references where applicable.

**Graceful Degradation**

- If only tasks.md exists: verify task completion only, skip spec/design/diff checks
- If tasks + specs exist: verify implementation, skip design adherence
- If full artifacts: verify implementation and scope
- If no merge base available: skip all diff-based checks, fall back to codebase keyword search only
- Always note which checks were skipped and why

**Verify Completion (draft→stable flip)**

When verify passes (no CRITICAL issues) and the change is approved for merge (during the post-apply workflow, after user approval), finalize tracking fields:
1. **Specs**: For each spec listed in the proposal's capabilities that has `status: draft` and `change` matching the current change: set `status: stable`, remove the `change` field, increment `version` by 1, and set `lastModified` to the current date.
2. **Proposal**: Set the proposal's YAML frontmatter `status` to `completed`.

This step runs automatically as part of the post-apply workflow — do not prompt the user for it.

**Output Format**

Use clear markdown with:
- Table for summary scorecard
- Grouped lists for issues (CRITICAL/WARNING/SUGGESTION)
- Code references in format: `file.ts:123`
- Specific, actionable recommendations
- No vague suggestions like "consider reviewing"
