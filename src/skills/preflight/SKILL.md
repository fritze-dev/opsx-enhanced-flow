---
name: preflight
description: Standalone pre-flight quality check for specs and design artifacts. Use after manual changes to specs or design to validate consistency.
disable-model-invocation: false
---

# /opsx:preflight — Pre-Flight Quality Check

> Standalone quality review — use after manual changes to specs or design.

**Input**: Optionally specify a change name. If omitted, infer from context or auto-select if only one active change exists.

## Instructions

### Prerequisite: Verify Setup

Check that `openspec/WORKFLOW.md` exists. If it is missing, tell the user to run `/opsx:setup` first and stop.

### Step 1: Select Change

**Worktree context detection** (runs first, before directory listing):
If no explicit change name was provided as an argument:
1. Run: `git rev-parse --git-dir`
2. If the result contains `/worktrees/`, derive change name from branch: `git rev-parse --abbrev-ref HEAD`
3. Search for a directory matching `openspec/changes/*-<branch-name>/` in the current working tree
4. If valid: auto-select this change and announce "Detected worktree context: using change '<name>'"
5. If not valid: fall through to normal detection below

If no change name provided:
- Infer from conversation context
- Auto-select if only one active change exists
- If ambiguous, list active change directories under `openspec/changes/` (those with unchecked tasks or no tasks.md) and ask the user to select

### Step 2: Read Context

1. Read `openspec/CONSTITUTION.md` for project rules and conventions.
2. Read all artifacts in the current change directory (`openspec/changes/<change-dir>/`).
3. Read baseline specs at `openspec/specs/` for cross-spec consistency. For the Traceability Matrix, read the proposal's Capabilities section to identify which baseline specs should have been updated by this change.

### Step 3: Get Preflight Instructions

Read the Smart Template from `openspec/templates/preflight.md`. Extract the `instruction` from its YAML frontmatter for content guidance. Use the template body for the output structure.

### Step 4: Execute Pre-Flight

Create `preflight.md` following the instruction and template from the Smart Template. Read all dependency artifacts listed in the `requires` field.

The pre-flight covers:
- **A. Traceability Matrix** — Every story mapped to scenarios and components
- **B. Gap Analysis** — Missing edge cases, error handling, empty states
- **C. Side-Effect Analysis** — Impact on existing systems, regression risks
- **D. Constitution Check** — Consistency with project rules
- **E. Duplication & Consistency** — Overlaps and contradictions across specs
- **F. Assumption Audit** — All `<!-- ASSUMPTION -->` markers rated

### Step 5: Verdict

Summarize findings. Clearly state blockers if any.
The user must review and resolve issues before proceeding to task creation.

---

## Output On Completion

```
## Pre-Flight Complete

**Change**: <change-name>
**Output**: preflight.md

### Findings
- Blockers: N
- Warnings: N
- Info: N

### Assumptions Audited
- Acceptable Risk: N
- Needs Clarification: N
- Blocking: N

Verdict: PASS / PASS WITH WARNINGS / BLOCKED
```

## Guardrails

- Always read all change artifacts before running the check
- Read WORKFLOW.md and Smart Templates for artifact instructions and templates — do not hardcode instruction content
- If required artifacts (spec.md, design.md) are missing, abort with a clear message
- Do not auto-fix issues — report findings for the user to resolve
- Do not proceed to task creation — preflight is a review gate, not a generator
