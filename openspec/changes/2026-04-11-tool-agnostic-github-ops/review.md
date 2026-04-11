## Review: Tool-Agnostic GitHub Operations

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 3/3 complete |
| Requirements | 4/4 verified |
| Scenarios | 5/5 covered |
| Tests | 7/7 items defined |
| Scope | Clean — all changed files trace to tasks |

### Findings

#### CRITICAL

(none)

#### WARNING

- `task-implementation/spec.md` and `project-init/spec.md` still contain `gh` CLI references. These are out of scope for this change (different capabilities, different use cases). Consider a follow-up change to make those tool-agnostic as well.

#### SUGGESTION

(none)

### Dimension Details

**Task Completion:** All 3 implementation tasks completed:
- SKILL.md line 105: `gh pr create --draft` → intent-based instruction
- CONSTITUTION.md line 58: `gh pr ready && gh pr edit` → intent description
- README.md lines 299-309: Rewritten to describe MCP tools as primary, `gh` as optional

**Requirement Verification:**
1. Post-Artifact Commit and PR Integration (artifact-pipeline): requirement text updated, "gh pr create --draft" → "available GitHub tooling". Two scenarios updated.
2. Lazy Worktree Cleanup (change-workspace): tier 2 and 4 text updated, "gh pr view" → "available GitHub tooling", "gh unavailable" → "no GitHub tooling available". One scenario updated.
3. Post-Merge Worktree Cleanup (change-workspace): requirement text "gh pr merge or equivalent" → "any merge method". One scenario updated.
4. Assumption updated: "gh CLI" → "GitHub tooling (gh CLI, MCP tools, or API)".

**Scenario Coverage:**
- First artifact triggers branch and PR creation: GIVEN updated to "GitHub tooling is available (gh CLI, MCP tools, or API)"
- Graceful degradation: renamed from "without gh CLI" to "without GitHub tooling", GIVEN updated
- Cleanup without GitHub tooling: renamed and GIVEN updated
- Post-merge cleanup: "runs gh pr merge" → "merges the PR"
- Edge case "gh CLI unavailable" → "GitHub tooling unavailable"

**Scope Control:** All changed files map to proposal scope:
- `src/skills/workflow/SKILL.md` — task 2.1
- `openspec/CONSTITUTION.md` — task 2.2
- `README.md` — task 2.3
- `openspec/specs/artifact-pipeline/spec.md` — specs artifact
- `openspec/specs/change-workspace/spec.md` — specs artifact
- `openspec/changes/2026-04-11-tool-agnostic-github-ops/*` — pipeline artifacts

### Verdict

**PASS WITH WARNINGS** — all in-scope changes verified. Warning about remaining `gh` references in out-of-scope specs (task-implementation, project-init) noted for follow-up.
