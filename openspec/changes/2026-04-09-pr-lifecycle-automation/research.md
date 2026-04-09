# Research: PR Lifecycle Automation

## 1. Current State

### Manual Post-Implementation Workflow
The current post-apply workflow (WORKFLOW.md `apply.instruction`) is fully manual:
`/opsx:verify` → commit+push → user approval → `/opsx:changelog` → `/opsx:docs` → version bump → pre-merge standard tasks

Each step requires the user to trigger it explicitly. The QA loop (human-approval-gate spec) mandates human sign-off before finalization.

### Existing GitHub Actions
Three workflows exist in `.github/workflows/`:
- **claude-code-review.yml** — runs `/code-review:code-review` on non-draft PRs (`opened, synchronize, ready_for_review, reopened`). Uses `claude-code-action@v1` with external plugin.
- **claude.yml** — interactive `@claude` mentions in comments/issues/reviews. Generic Claude Code invocation.
- **release.yml** — auto-creates git tag + GitHub Release when `src/.claude-plugin/plugin.json` version changes on main. Uses `contents: write`.

### Existing Specs Affected
- **workflow-contract** — defines WORKFLOW.md format, post_artifact hook, skill reading pattern. Would need `automation` config section.
- **quality-gates** — defines `/opsx:verify` and `/opsx:preflight` behavior. Verify would run in CI context.
- **human-approval-gate** — mandates explicit human approval in QA loop. Autonomous flow must respect or explicitly supersede this.
- **release-workflow** — defines version bump, changelog, GitHub Release. Post-approval pipeline overlaps with this.

### Related Issues
- **#60** — PR Lifecycle & Automation Concept: state machine, two GitHub Actions, labels
- **#37** — Autonomous Agent Flow: `/opsx:auto` with specialized sub-agents
- **#38** — Agent Handoff Protocol: validation gates, rollback rules, auditability

## 2. External Research

### A. claude-code-action Plugin Self-Reference

**Local plugin loading is fully supported.** The `install-plugins.ts` source code in `claude-code-action@v1` has an explicit `isLocalPath()` function that recognizes `./`, `../`, and absolute paths. When detected, URL validation is skipped entirely — the path is passed directly to `claude plugin marketplace add`.

**Three approaches for self-referencing:**

| Approach | Config | Mechanism |
|----------|--------|-----------|
| Local marketplace | `plugin_marketplaces: './'` | `claude plugin marketplace add ./` → loads marketplace.json |
| Absolute path | `plugin_marketplaces: '${{ github.workspace }}'` | Same, with absolute path |
| Plugin dir flag | `claude_args: '--plugin-dir ${{ github.workspace }}'` | Session-only loading, no marketplace registration |

All three work. Option 1 (local marketplace `'./'`) is simplest and leverages the existing `marketplace.json` at repo root.

**CLAUDE.md security on PRs:** On PR events, `claude-code-action` restores CLAUDE.md from the base branch (not the PR head) as a security mechanism. This means CLAUDE.md rules from `main` apply in CI — PR changes to CLAUDE.md only take effect after merge.

**Recursive workflow prevention:** Pushes from `GITHUB_TOKEN` do NOT trigger new workflow runs (built-in safety). This means Action 2 can push commits without causing infinite loops.

### B. GitHub Actions Patterns

**PR Review Trigger:**
```yaml
on:
  pull_request_review:
    types: [submitted]
jobs:
  pipeline:
    if: github.event.review.state == 'approved'
```
Fires per reviewer. Does NOT indicate "all required reviews met" — only that one reviewer approved. To check full approval: `gh pr view --json reviewDecision --jq '.reviewDecision'` → `APPROVED`.

**Concurrency Groups:**
- `cancel-in-progress: true` — cancels running job, starts new one (ideal for verify)
- `cancel-in-progress: false` — queues new job, max 1 running + 1 pending (ideal for pipeline)
- Different policies per job are supported

**Push to PR Branch:**
- `GITHUB_TOKEN` with `contents: write` can push to unprotected PR branches
- Cannot push to protected branches — needs GitHub App token or PAT + ruleset bypass
- For our use case (PR branches, not main), `GITHUB_TOKEN` is sufficient

**Label Management:**
- REST API is preferred over `gh pr edit` (avoids `repository-projects: read` bug in gh CLI)
- `POST /repos/{owner}/{repo}/issues/{number}/labels` to add
- `DELETE /repos/{owner}/{repo}/issues/{number}/labels/{name}` to remove
- Requires `pull-requests: write`

**Status Checks:**
- Job name becomes the status check name automatically
- Can be made required via repo Settings → Rulesets
- Gotcha: skipped jobs report as "Success" — conditional required checks silently pass

**Cost/Debouncing:**
- `synchronize` fires on every push — concurrency cancel-in-progress is the primary debounce
- Path filters reduce unnecessary runs but have gotchas with required checks (workflow doesn't run → check never reports → PR blocked)

### C. Autonomous Agent Orchestration

**No formal Agent tool available to skills.** Skills cannot spawn independent sub-agents with isolated contexts. The available mechanisms are:
- **Skill tool** — invokes another skill in the same conversation context (not isolated)
- **RemoteTrigger** — calls the claude.ai API to create remote agent executions (fully isolated, loses shared context)
- **CronCreate** — session-scoped scheduling (auto-expires after 7 days)

**Existing orchestration patterns:**
- `/opsx:ff` already orchestrates the full artifact pipeline in one context (research → tasks)
- `/opsx:apply` references the post-apply workflow as prose instructions
- State is tracked via file existence + frontmatter values (proven pattern)
- No persistent cross-session state mechanism beyond file system

**Context window constraint:** Running the full 12-step pipeline (research → ... → docs) in one context would consume tokens rapidly. Each skill reads CONSTITUTION.md, WORKFLOW.md, templates, specs, and change artifacts. The `/opsx:docs` skill alone reads every spec + every change's proposal/research/design + every ADR.

**Feasible MVP: single orchestrator skill**, not specialized sub-agents. Same sequential pattern as `/opsx:ff` but extending through apply, verify, changelog, docs, version-bump. The "Reviewer", "QA", "Test", "Approval" agent roles from #37 map to existing skills (preflight, verify, verify, human-approval-gate) invoked sequentially.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A. Two GitHub Actions only (#60)** | Simplest. Immediate CI value. No new skills needed. | Doesn't address #37/#38. Still manual locally. |
| **B. `/opsx:auto` skill only (#37/#38)** | Full local automation. One command does everything. | No CI integration. Doesn't run when no local agent active. Context window risk. |
| **C. Complementary: Actions + Auto skill** | Both channels covered. CI for review workflow, local for development. Shared handoff protocol. | More scope. Must coordinate two automation paths. |
| **D. RemoteTrigger-based autonomous flow** | True isolation per step. Could handle context limits. | Loses shared context. Complex orchestration. RemoteTrigger API is immature. |

**Recommended: Approach C** — complementary architecture. GitHub Actions handle CI-triggered automation (verify on ready_for_review, pipeline on approved). `/opsx:auto` handles local end-to-end orchestration. Both use the same file-based handoff protocol (artifact existence + frontmatter status as gates).

## 4. Risks & Constraints

| Risk | Severity | Mitigation |
|------|----------|------------|
| Context window exhaustion in `/opsx:auto` | HIGH | Break into checkpoint-resumable steps; each step reads only what it needs |
| Plugin self-reference in CI | LOW | Confirmed working via `plugin_marketplaces: './'` |
| `synchronize` cost (verify on every push) | MEDIUM | cancel-in-progress concurrency + consider path filter |
| `pull_request_review` fires per reviewer | LOW | Check `reviewDecision == APPROVED` before running pipeline |
| GITHUB_TOKEN can't push to protected branches | LOW | PR branches are unprotected; main is protected but pipeline pushes to PR branch only |
| Human-approval-gate spec conflict | MEDIUM | `/opsx:auto` offers `--auto-approve` flag; default preserves human gate. CI pipeline replaces manual approval with GitHub review approval (human review IS the gate). |
| Version-bump idempotency in pipeline | MEDIUM | Check if version was already bumped in current PR before bumping again |
| Existing code-review action overlap | LOW | Different purposes (general quality vs OpenSpec compliance); coexist as parallel checks |
| Stale worktree after CI pipeline commits | LOW | Pipeline pushes to PR branch; worktree syncs on next `git pull` |

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Three issues define boundaries; complementary architecture decided |
| Behavior | Clear | State machine from #60, orchestration from #37, handoff from #38 |
| Data Model | Clear | Labels, frontmatter status, file existence as state |
| UX | Clear | Two entry points: PR events (CI) and `/opsx:auto` (local) |
| Integration | Clear | claude-code-action, GitHub API, existing skills |
| Edge Cases | Partial | Race conditions, idempotency, error recovery need design attention |
| Constraints | Clear | Context window, token permissions, recursive prevention |
| Terminology | Clear | Actions/Pipeline/Handoff/Gates terminology established |
| Non-Functional | Partial | Cost per CI run, latency of LLM-based verify in CI |

## 6. Open Questions

| # | Question | Category | Impact |
|---|----------|----------|--------|
| 1 | Should `/opsx:auto` be a single skill or a chain of existing skills invoked by the user? A single skill risks context exhaustion; a chain loses the "one command" UX. | Edge Cases | High |
| 2 | How should CI cost be managed? Each `synchronize` event runs Claude Code (verify). Should we add path filters (e.g., only run verify when `openspec/` or `src/` files change)? | Non-Functional | Medium |
| 3 | Should the post-approval pipeline check `reviewDecision == APPROVED` (all required reviews) or trigger on any single approval? | Edge Cases | Medium |

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | `/opsx:auto` as lightweight orchestrator, existing skills as sub-agents via Agent tool, artifacts on disk as shared state | Solves context window exhaustion — each sub-agent gets fresh context with only relevant inputs. Handoff protocol (#38) emerges naturally: artifact existence + frontmatter status = gate between agents. | Single monolithic skill (context exhaustion risk); guided chain of user-invoked skills (loses one-command UX); RemoteTrigger-based (loses shared filesystem) |
| 2 | No CI-Verify action — verify stays local only | Verify already runs locally as part of the apply workflow. Code-review action provides independent CI check. Saves API credits and complexity. | CI verify on ready_for_review (redundant, costly); CI replaces local verify (longer feedback loop) |
| 3 | Post-approval pipeline triggers on `reviewDecision == APPROVED` (all required reviews) | Prevents unnecessary pipeline runs in multi-reviewer setups. Single approval could trigger pipeline prematurely. | Trigger on any single approval (may run multiple times); manual label trigger (extra step) |
| 4 | Plugin self-reference via `plugin_marketplaces: './'` | Simplest approach, leverages existing marketplace.json. Confirmed working in claude-code-action source. | `--plugin-dir` via claude_args (session-only, less integrated); published version (chicken-and-egg problem) |
