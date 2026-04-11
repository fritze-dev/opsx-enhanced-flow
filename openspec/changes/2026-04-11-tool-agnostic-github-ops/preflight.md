# Pre-Flight Check: Tool-Agnostic GitHub Operations

## A. Traceability Matrix

- [x] Post-Artifact Commit and PR Integration (artifact-pipeline) → Scenarios: First artifact PR creation, Graceful degradation → SKILL.md line 105, spec requirement text, 2 scenarios, 1 assumption
- [x] Lazy Worktree Cleanup (change-workspace) → Scenarios: PR status fallback, Cleanup without GitHub tooling → spec requirement text (tiers 2, 4), 1 scenario, 1 edge case
- [x] Post-Merge Worktree Cleanup (change-workspace) → Scenario: Cleanup after merge → spec requirement text, 1 scenario
- [x] Constitution standard tasks → Pre-merge task wording → CONSTITUTION.md line 58
- [x] README setup documentation → Setup section → README.md lines 299-309

## B. Gap Analysis

No gaps. All changes are wording-only — replacing tool-specific commands with intent-based descriptions. The runtime behavior is unchanged because Claude already picks the best available tool.

## C. Side-Effect Analysis

- **No runtime side effects**: These are documentation/instruction changes only
- **Existing test artifacts**: Prior changes' `tests.md` files reference `gh` CLI in scenario context — these are historical and not modified (correct, since they describe the state at the time of that change)

## D. Constitution Check

Yes — CONSTITUTION.md line 58 needs updating (pre-merge standard task references `gh pr ready && gh pr edit`). This is part of the change scope.

## E. Duplication & Consistency

- No duplication across changes
- Consistent terminology: "available GitHub tooling" used everywhere as the umbrella term
- Consistent fallback pattern: "no GitHub tooling is available" replaces "gh CLI unavailable" uniformly

## F. Assumption Audit

| Assumption | Source | Rating |
|-----------|--------|--------|
| GitHub tooling, when available, is authenticated and has permission to create PRs | artifact-pipeline/spec.md | Acceptable Risk — unchanged assumption, just broadened from `gh` CLI to all GitHub tooling |

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any modified files.

**Verdict: PASS** — all checks clear, no blocking issues.
