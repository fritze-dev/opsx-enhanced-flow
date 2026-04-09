---
has_decisions: true
---
# Technical Design: PR Lifecycle Automation

## Context

The OpenSpec workflow currently requires manual execution of every post-implementation step: verify, changelog, docs, version-bump, and PR finalization. The pipeline definition in WORKFLOW.md covers only artifact generation (research → tasks). Action steps (apply, verify, changelog, docs, version-bump) are prose instructions in `apply.instruction`, not formal pipeline steps.

This change extends the pipeline model to cover the full change lifecycle and adds CI-triggered automation for the post-approval phase. Two layers work together:
- **Local**: `/opsx:ff` executes the full pipeline including action steps via sub-agents
- **CI**: A thin GitHub Action triggers post-approval steps when a PR receives all required review approvals

Constraints:
- Skills in `src/skills/` are generic plugin code — modifications must be plugin-level enhancements, not project-specific
- WORKFLOW.md is the single source of truth for pipeline configuration
- Existing skills (verify, changelog, docs) must not be modified — they are invoked as-is
- This repo IS the opsx plugin — CI must load the plugin from its own checkout

## Architecture & Components

### 1. WORKFLOW.md Extension

**File**: `openspec/WORKFLOW.md` (+ consumer template `src/templates/workflow.md`)

Extended pipeline array and new automation block:

```yaml
pipeline: [research, proposal, specs, design, preflight, tasks, apply, verify, changelog, docs, version-bump]

automation:
  post_approval:
    steps: [changelog, docs, version-bump]
    labels:
      running: automation/running
      complete: automation/complete
      failed: automation/failed
    opt_out: [skip-docs]
    auto_merge: false
```

The `apply` section remains for backward compatibility — its `instruction` field is still read by the apply skill. The extended `pipeline` array is the new authoritative sequence.

### 2. Action Templates

**Directory**: `openspec/templates/` (+ consumer copies in `src/templates/`)

New template files for action steps:

| Template | `type` | `requires` | `instruction` summary |
|----------|--------|------------|----------------------|
| `apply.md` | action | [tasks] | Read context, implement tasks, mark complete |
| `verify.md` | action | [apply] | Run verification against specs and diff |
| `changelog.md` | action | [verify] | Generate changelog from completed changes |
| `docs.md` | action | [changelog] | Generate/update capability docs, ADRs, README |
| `version-bump.md` | action | [docs] | Bump patch version, sync marketplace.json |

Each action template contains:
- `type: action` in frontmatter (no `generates` field)
- `requires` for dependency chain
- `instruction` with the behavioral constraints (extracted from current `apply.instruction` prose and constitution conventions)
- No markdown body structure (actions don't generate artifacts in the change directory)

### 3. ff Skill Extension

**File**: `src/skills/ff/SKILL.md`

Changes to ff:
- **Template type detection**: After reading a template, check for `type: action`. If absent, default to artifact behavior (current).
- **Action step execution**: For `type: action` templates, spawn a sub-agent via the Agent tool. The sub-agent prompt includes: (1) the template's `instruction`, (2) paths to files listed in `requires` (read from disk by the sub-agent), (3) WORKFLOW.md `context` reference (constitution).
- **Action step status**: Action steps are always executed when dependencies are satisfied. The action itself handles idempotency.
- **`--auto-approve` flag**: When present, skip the human approval gate in the QA loop. When absent (default), pause at the verify→approval boundary per the human-approval-gate spec.
- **Pipeline scope**: ff processes ALL steps in the `pipeline` array, not just up to `tasks`.

Sub-agent prompt structure:
```
You are executing the "{id}" step of the OpenSpec pipeline for change "{change-name}".

Read and follow: openspec/CONSTITUTION.md

{instruction from template}

Change artifacts are at: openspec/changes/{change-dir}/
Affected specs: openspec/specs/{capabilities}/spec.md
```

### 4. Post-Approval CI Trigger

**File**: `.github/workflows/opsx-pipeline.yml` (new, ~30 lines)

```yaml
name: OpenSpec Pipeline
on:
  pull_request_review:
    types: [submitted]
concurrency:
  group: opsx-pipeline-${{ github.event.pull_request.number }}
  cancel-in-progress: false
jobs:
  pipeline:
    if: github.event.review.state == 'approved'
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
      issues: read
      id-token: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.ref }}
          fetch-depth: 0
      - name: Check reviewDecision
        id: check
        run: |
          DECISION=$(gh pr view ${{ github.event.pull_request.number }} --json reviewDecision -q '.reviewDecision')
          echo "approved=$([ "$DECISION" = "APPROVED" ] && echo true || echo false)" >> "$GITHUB_OUTPUT"
        env:
          GH_TOKEN: ${{ github.token }}
      - name: Run pipeline
        if: steps.check.outputs.approved == 'true'
        uses: anthropics/claude-code-action@v1
        with:
          claude_code_oauth_token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          plugin_marketplaces: './'
          plugins: 'opsx@opsx-enhanced-flow'
          prompt: |
            Read openspec/WORKFLOW.md automation.post_approval config.
            Execute the steps listed there for PR #${{ github.event.pull_request.number }}.
            Manage labels as defined in the config.
            Commit and push all changes to the PR branch.
            If any step fails, set the failed label and post error details as a PR comment.
```

Key design choices:
- `fetch-depth: 0` for full git history (verify needs `git merge-base`)
- `cancel-in-progress: false` to prevent mid-commit corruption
- `reviewDecision` check ensures ALL required reviews are met, not just one
- `plugin_marketplaces: './'` loads the opsx plugin from the repo checkout
- `contents: write` for pushing commits, `pull-requests: write` for labels

### 5. CONSTITUTION.md Update

**File**: `openspec/CONSTITUTION.md`

Add CI automation convention:
```markdown
## CI Automation

- **Post-approval pipeline**: Defined in WORKFLOW.md `automation.post_approval`. Triggered by GitHub Action on PR review approval.
- **Labels**: `automation/running`, `automation/complete`, `automation/failed` track pipeline state. `skip-docs` opts out of docs generation. `auto-merge` enables auto-merge after successful pipeline.
- **Plugin self-reference**: CI loads the opsx plugin from the repo checkout via `plugin_marketplaces: './'`.
```

## Goals & Success Metrics

- ff with full pipeline completes all steps (research → version-bump) without manual intervention when `--auto-approve` is used — PASS/FAIL: run on a test change
- Post-approval CI pipeline commits changelog + docs + version-bump to PR branch within one run — PASS/FAIL: approve a test PR, verify artifacts committed
- Pipeline respects `skip-docs` label — PASS/FAIL: add label, approve, verify docs step skipped
- Pipeline sets correct labels at each state — PASS/FAIL: check label transitions during run
- Sub-agents receive bounded context (not full conversation) — PASS/FAIL: verify agent prompt size is proportional to required artifacts, not conversation history

## Non-Goals

- Replacing the existing code-review Action (stays independent)
- Running verify in CI (stays local only)
- Supporting custom action step types beyond the predefined set (deferred)
- Multi-repo pipeline orchestration
- Automatic retry on pipeline failure (manual re-trigger via re-approval or `@claude`)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Extend `pipeline` array with action steps instead of separate `post_pipeline` | Single source of truth; ff reads one array. Templates self-describe their type via `type` field. | Separate `post_pipeline` array (two config points); inline actions in WORKFLOW.md (bloats frontmatter) |
| Action steps always execute (no status tracking) | Existing skills handle idempotency internally. Adding status tracking adds complexity without value. | `status_check` field per action template (overengineered); progress file in change dir (extra state) |
| Sub-agent per action step via Agent tool | Prevents context window exhaustion. Each sub-agent gets fresh context with only required artifacts. | Single-context execution (context exhaustion risk); RemoteTrigger (loses filesystem access) |
| Thin trigger YAML + WORKFLOW.md config | Pipeline logic stays in WORKFLOW.md (single source of truth). YAML is only the event trigger (~30 lines). | Full pipeline logic in YAML (duplicates WORKFLOW.md); extend claude.yml (wrong purpose, requires @claude mention) |
| `reviewDecision == APPROVED` check in CI | Prevents premature pipeline runs when multi-reviewer setup has partial approvals. | Trigger on any single approval (may run multiple times); label-based trigger (extra manual step) |
| Load plugin via `plugin_marketplaces: './'` | Confirmed working in claude-code-action source. Uses existing marketplace.json. Simplest approach. | `--plugin-dir` via claude_args (session-only); published version (chicken-and-egg for skill changes) |

## Risks & Trade-offs

- **Context window for full ff pipeline**: Even with sub-agents, the orchestrator ff itself accumulates context from managing all steps. → Mitigation: ff's orchestrator loop is lightweight (read template, check status, spawn agent, check result). Heavy work is in sub-agents.
- **CI cost per approval event**: Each approval triggers a Claude Code run (~API credits). → Mitigation: `reviewDecision` check prevents premature runs; concurrency group prevents duplicate runs.
- **GITHUB_TOKEN push limitation**: Can't push to protected branches. → Mitigation: pipeline pushes to PR branch (unprotected). Main is protected but only receives merges.
- **Recursive workflow trigger**: Pipeline pushes commits — could trigger other workflows. → Mitigation: GITHUB_TOKEN pushes do NOT trigger new workflow runs (built-in GitHub safety).
- **HEAD divergence during pipeline**: Someone pushes while pipeline runs. → Mitigation: Pipeline checks branch HEAD before committing; aborts with `automation/failed` label if diverged.
- **CLAUDE.md restored from base branch in CI**: On PR events, claude-code-action restores CLAUDE.md from main. → Mitigation: acceptable — CLAUDE.md on main contains the project rules.

## Open Questions

No open questions.

## Assumptions

- `claude-code-action@v1` correctly loads plugins from local marketplace paths (`'./'`). Confirmed in source code but not tested in this specific repo. <!-- ASSUMPTION: Local plugin loading works -->
- The Agent tool in Claude Code supports spawning sub-agents with custom prompts within a skill's execution context. <!-- ASSUMPTION: Agent tool in skill context -->
- `pull_request_review: submitted` event fires reliably for all review types including required reviews from CODEOWNERS. <!-- ASSUMPTION: Review event reliability -->
