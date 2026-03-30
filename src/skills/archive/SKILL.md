---
name: archive
description: Archive a completed change in the experimental workflow. Use when the user wants to finalize and archive a change after implementation is complete.
disable-model-invocation: false
---

Archive a completed change in the experimental workflow.

**Input**: Optionally specify a change name. If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **If no change name provided, prompt for selection**

   **Worktree context detection** (runs first, before directory listing):
   If no explicit change name was provided as an argument:
   1. Run: `git rev-parse --git-dir`
   2. If the result contains `/worktrees/`, derive change name from branch: `git rev-parse --abbrev-ref HEAD`
   3. Verify: `openspec/changes/<branch-name>/` exists in the current working tree
   4. If valid: auto-select this change and announce "Detected worktree context: using change '<name>'"
   5. If not valid: fall through to normal detection below

   If not detected via worktree: List directories under `openspec/changes/` (exclude `archive/`). Use the **AskUserQuestion tool** to let the user select.

   Show only active changes (not already archived).

   **IMPORTANT**: Do NOT auto-select from directory listing. Worktree context detection is acceptable.

2. **Check artifact completion status**

   Read `openspec/WORKFLOW.md` to get the artifact pipeline from its YAML frontmatter. For each artifact, check if its output file exists in `openspec/changes/<name>/`.

   **If any artifacts are missing:**
   - Display warning listing incomplete artifacts
   - Use **AskUserQuestion tool** to confirm user wants to proceed
   - Proceed if user confirms

3. **Check task completion status**

   Read the tasks file (typically `tasks.md`) to check for incomplete tasks.

   Count tasks marked with `- [ ]` (incomplete) vs `- [x]` (complete).

   **If incomplete tasks found:**
   - Display warning showing count of incomplete tasks
   - Use **AskUserQuestion tool** to confirm user wants to proceed
   - Proceed if user confirms

   **If no tasks file exists:** Proceed without task-related warning.

4. **Auto-sync delta specs**

   Check for delta specs at `openspec/changes/<name>/specs/`. If none exist, skip this step.

   **If delta specs exist:**
   - Compare each delta spec with its corresponding main spec at `openspec/specs/<capability>/spec.md`
   - Determine what changes would be applied (adds, modifications, removals, renames)
   - Show a combined summary of pending changes
   - Automatically invoke sync using Task tool (subagent_type: "general-purpose", prompt: "Use Skill tool to invoke opsx:sync for change '<name>'. Delta spec analysis: <include the analyzed delta spec summary>")
   - If sync fails, report the error and stop — do NOT proceed to archive with unsynced specs
   - Proceed to archive after sync completes

5. **Perform the archive**

   Create the archive directory if it doesn't exist:
   ```bash
   mkdir -p openspec/changes/archive
   ```

   Generate target name using current date: `YYYY-MM-DD-<change-name>`

   **Check if target already exists:**
   - If yes: Fail with error, suggest renaming existing archive or using different date
   - If no: Move the change directory to archive

   ```bash
   mv openspec/changes/<name> openspec/changes/archive/YYYY-MM-DD-<name>
   ```

6. **Worktree cleanup (if applicable)**

   Check if the current session is in a git worktree (run `git rev-parse --git-dir` — if it contains `/worktrees/`, we're in a worktree).

   If in a worktree:
   - Read `openspec/WORKFLOW.md` frontmatter for `worktree.auto_cleanup`
   - If `auto_cleanup` is `true`:
     1. Determine the worktree path from `git rev-parse --show-toplevel`
     2. Navigate to the main repository (parent of the worktree)
     3. Run: `git worktree remove <worktree-path>`
     4. If the branch has been merged to main: `git branch -d <change-name>`
     5. Report: "Worktree cleaned up at <path>"
   - If `auto_cleanup` is `false` or absent:
     - Report: "Worktree at <path> still exists. Run `git worktree remove <path>` to clean up."

   If not in a worktree: skip this step.

7. **Display summary**

   Show archive completion summary including:
   - Change name
   - Archive location
   - Whether specs were synced (if applicable)
   - Note about any warnings (incomplete artifacts/tasks)
   - Worktree cleanup status (if applicable)

**Guardrails**
- Always prompt for change selection if not provided
- Check artifact completion by verifying output files exist for each artifact defined in WORKFLOW.md and Smart Templates
- Don't block archive on warnings - just inform and confirm
- Show clear summary of what happened
- If delta specs exist, auto-sync before archiving — no user prompt needed
- If sync fails, block the archive and report the error
