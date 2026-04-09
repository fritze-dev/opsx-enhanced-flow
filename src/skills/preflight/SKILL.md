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

**Change context detection** (runs first, before directory listing):
If no explicit change name was provided as an argument:
1. Get current branch: `git rev-parse --abbrev-ref HEAD`
2. **Proposal frontmatter lookup**: Scan `openspec/changes/*/proposal.md` for a proposal whose YAML frontmatter `branch` field matches the current branch. If found, auto-select that change.
3. **Fallback — worktree convention**: If no matching proposal frontmatter, check if inside a worktree (`git rev-parse --git-dir` contains `/worktrees/`), derive change name from branch, search for `openspec/changes/*-<branch-name>/`.
4. If valid: auto-select and announce "Detected change context: using change '<name>'"
5. If not valid: fall through to normal detection below

If no change name provided:
- Infer from conversation context
- Auto-select if only one active change exists (proposal `status: active` or fallback: unchecked tasks/no tasks.md)
- If ambiguous, list active changes and ask the user to select

### Step 2: Read Context

1. Read `openspec/CONSTITUTION.md` for project rules and conventions.
2. Read all artifacts in the current change directory (`openspec/changes/<change-dir>/`).
3. Read specs at `openspec/specs/` for cross-spec consistency. For the Traceability Matrix, read the proposal's YAML frontmatter `capabilities` field to identify which specs should have been updated by this change (fall back to parsing the `## Capabilities` section if frontmatter is absent).

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
- **G. Draft Spec Validation** — Verify all specs with `status: draft` have a `change` value matching the current change directory. Specs with `status: draft` belonging to a different change = BLOCKED. Specs with `status: draft` and no `change` field = WARNING.

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
