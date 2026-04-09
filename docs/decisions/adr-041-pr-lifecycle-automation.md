# ADR-041: PR Lifecycle Automation

## Status

Accepted (2026-04-09)

## Context

The OpenSpec post-implementation workflow (verify, changelog, docs, version-bump) required manual execution of every step. The pipeline definition in WORKFLOW.md covered only artifact generation (research through tasks), while action steps were prose instructions embedded in a ~50-line `apply.instruction` YAML string. This created several problems: WORKFLOW.md's frontmatter was unwieldy with multi-line prose, the pipeline array was not the single source of truth for the full lifecycle, and there was no CI automation for PR lifecycle events beyond code review.

Research confirmed that `claude-code-action@v1` supports loading plugins from local marketplace paths (`plugin_marketplaces: './'`), that `GITHUB_TOKEN` pushes do not trigger recursive workflows, and that `pull_request_review: submitted` events require a `reviewDecision == APPROVED` check to ensure all required reviews are met before triggering automation.

The design explored creating a new `/opsx:auto` skill but concluded that extending the existing `/opsx:ff` and the pipeline model was simpler and avoided a new skill. Similarly, options like `status_check` fields for action templates, opt-out labels, and custom auto-merge were evaluated and eliminated as unnecessary complexity.

## Decision

1. **Structured config in frontmatter, prose in body sections** — WORKFLOW.md uses YAML frontmatter for machine-readable config (~20 lines) and markdown body sections (`## Context`, `## Post-Artifact Hook`) for prose instructions, eliminating ~50 lines of YAML multi-line strings
2. **`apply.instruction` distributed across action templates** — each action template carries its own instruction field, eliminating duplication between the pipeline definition and the apply instruction prose
3. **Extend `pipeline` array with action steps** — a single `pipeline` array is the source of truth for the full lifecycle; templates self-describe their type via a `type` field (artifact or action)
4. **Action steps always execute (no status tracking)** — existing skills handle idempotency internally, so external status tracking adds complexity without value
5. **Sub-agent per action step via Agent tool** — each action step spawns an isolated sub-agent with only its required artifacts, preventing context window exhaustion
6. **Thin trigger YAML + WORKFLOW.md config** — pipeline logic stays in WORKFLOW.md; the GitHub Action YAML is only the event trigger (~30 lines)
7. **`reviewDecision == APPROVED` check in CI** — prevents premature pipeline runs when multi-reviewer setups have partial approvals
8. **Load plugin via `plugin_marketplaces: './'`** — confirmed working in claude-code-action source code; uses the existing marketplace.json at the repo root

## Alternatives Considered

- All config in frontmatter (current state — unwieldy with 95+ lines of YAML)
- Separate `post_pipeline` array instead of extending `pipeline` (two config points)
- `status_check` field per action template (overengineered for idempotent skills)
- Single-context execution without sub-agents (context exhaustion risk)
- New `/opsx:auto` skill instead of extending ff (unnecessary new surface area)
- Full pipeline logic in the GitHub Action YAML (duplicates WORKFLOW.md)
- Extending `claude.yml` for post-approval automation (wrong purpose, requires @claude mention)
- Trigger on any single approval (may run prematurely in multi-reviewer setups)
- Published plugin version in CI (chicken-and-egg for skill changes)

## Consequences

### Positive

- WORKFLOW.md is cleaner (~20 lines frontmatter vs ~95) and the pipeline array is the single source of truth
- Post-approval steps (changelog, docs, version-bump) run automatically without manual intervention
- `/opsx:ff` can execute the entire pipeline end-to-end, including with `--auto-approve` for autonomous mode
- Each action step gets bounded context via sub-agents, preventing context window exhaustion
- Backward-compatible fallbacks ensure consumers on template-version 1 continue working

### Negative

- Sub-agent execution for action steps is unverified in practice — the assumption that SKILL.md instructions can direct Agent tool usage needs real-world confirmation
- Each post-approval pipeline run consumes API credits (mitigated by `reviewDecision` check and concurrency groups)
- The restructured WORKFLOW.md format is a breaking change for consumers — requires template-version bump and setup re-run

## References

- [Change: pr-lifecycle-automation](../../openspec/changes/2026-04-09-pr-lifecycle-automation/)
- [Spec: workflow-contract](../../openspec/specs/workflow-contract/spec.md)
- [Spec: release-workflow](../../openspec/specs/release-workflow/spec.md)
- [ADR-028: Post-artifact commit and PR integration](adr-028-post-artifact-commit-and-pr-integration.md)
