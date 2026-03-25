# ADR-028: Post-Artifact Commit and PR Integration

## Status

Accepted (2026-03-25) — supersedes [ADR-026](adr-026-inline-pr-integration-in-proposal-step.md)

## Context

ADR-026 placed branch creation and draft PR in the proposal artifact instruction. Issue #51 identified two problems: (1) the draft PR was created before the user reviewed or approved the proposal, risking orphaned PRs, and (2) only the proposal step committed — all other artifacts remained uncommitted until the post-apply workflow. Moving to a schema-level `post_artifact` hook ensures every artifact is committed incrementally, with the branch and draft PR created on the first commit (typically after research). This aligns with ADR-002 (schema owns workflow rules) and keeps skills generic.

## Decision

1. **Schema-level `post_artifact` field for commit-after-every-artifact** — schema owns the rule (ADR-002); DRY; one place to maintain. Alternatives: per-artifact instruction blocks (repetitive 6x), skill-level logic (wrong layer per three-layer architecture).
2. **Branch and draft PR created on first artifact commit, not in `/opsx:new`** — first commit has real content (research.md); no empty commits needed. Alternatives: PR in `/opsx:new` (empty commit required), PR in proposal only (ADR-026, caused Issue #51).
3. **`/opsx:continue` and `/opsx:ff` skills read and execute `post_artifact`** — consistent with how skills already read `instruction` and `template` from schema. If `post_artifact` is absent, skills skip silently (backward compatibility).
4. **Remove `## Pull Request` section from proposal template** — `gh pr view` derives PR from branch on-demand; no metadata storage needed. Alternative: `.meta.yaml` in change dir (adds file management complexity for no benefit).
5. **Graceful degradation unchanged** — if `gh` CLI unavailable, skip PR creation; if push fails, continue locally. Consistent with ADR-026 approach.

## Alternatives Considered

- Keep PR in proposal instruction, add approval gate (adds complexity; still creates PR before user approval)
- New `post_artifact` as separate artifact in pipeline (breaks 6-stage structure)
- PR creation in `/opsx:new` before any artifacts (empty commit; PR before any content)
- Per-artifact commit instructions in each artifact's `instruction` field (repetitive; maintenance burden)

## Consequences

### Positive

- Every artifact gets its own commit — better git history and traceability
- Draft PR created on first real commit, not coupled to proposal approval
- No orphaned PRs from rejected proposals (Issue #51 resolved)
- Schema owns the rule — consistent with ADR-002
- Backward compatible — absent `post_artifact` field is silently ignored

### Negative

- Skills need a small update to read the new schema field (one-time change)
- More commits per change (one per artifact instead of one bulk commit at proposal) — intentional trade-off for traceability
- PR body is initially minimal WIP; enriched only at post-apply via constitution standard task

## References

- [Archive: move-pr-to-new-skill](../../openspec/changes/archive/) (pending archive)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [ADR-026: Inline PR Integration in Proposal Step](adr-026-inline-pr-integration-in-proposal-step.md) (superseded)
- [ADR-002: Workflow Rule Ownership](adr-002-workflow-rule-ownership.md)
