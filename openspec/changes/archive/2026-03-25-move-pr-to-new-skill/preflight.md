# Pre-Flight Check: Post-Artifact Commit and PR Integration

## A. Traceability Matrix

- [x] Post-Artifact Commit and PR Integration → Scenario: First artifact triggers branch and PR creation → schema.yaml `post_artifact` field + continue SKILL.md
- [x] Post-Artifact Commit and PR Integration → Scenario: Subsequent artifacts commit and push only → schema.yaml `post_artifact` field + continue SKILL.md
- [x] Post-Artifact Commit and PR Integration → Scenario: Graceful degradation without gh CLI → schema.yaml `post_artifact` field
- [x] Post-Artifact Commit and PR Integration → Scenario: Schema without post_artifact field → continue SKILL.md (backward compat check)
- [x] Post-Artifact Commit and PR Integration → Scenario: Proposal template does not include Pull Request section → templates/proposal.md
- [x] REMOVED: Proposal PR Integration → schema.yaml proposal instruction + templates/proposal.md

## B. Gap Analysis

No gaps identified:
- Graceful degradation covers: no gh CLI, no remote, push failure, branch exists
- Backward compatibility covered: absent `post_artifact` field = no-op
- Edge cases documented: auto-continue transitions, existing changes without branches

## C. Side-Effect Analysis

- **Continue skill behavior change**: After each artifact, the skill now commits and pushes. Users accustomed to local-only artifact creation until post-apply will see incremental commits. This is intentional and documented.
- **Git history**: More granular commits (one per artifact instead of one bulk commit at proposal). This is a positive change for traceability.
- **`/opsx:ff` skill**: Uses the same continue logic internally. If it delegates to continue, it inherits `post_artifact` behavior. If it has its own artifact creation loop, it needs the same `post_artifact` handling. **Action needed**: Verify `/opsx:ff` skill reads `post_artifact` or delegates to continue.

## D. Constitution Check

No constitution updates needed:
- The standard task "Update PR: mark ready for review" remains valid — it runs post-apply
- No new architecture patterns introduced
- `post_artifact` is a schema-level concern, not a constitution rule

## E. Duplication & Consistency

- No duplication: `post_artifact` is the single source for commit behavior; proposal instruction no longer duplicates it
- Consistent with ADR-002: schema owns workflow rules
- Consistent with existing `apply.instruction` pattern: schema defines behavior, skills execute it

## F. Assumption Audit

| Assumption | Source | Rating |
|-----------|--------|--------|
| gh CLI authentication | spec, design | Acceptable Risk — carried over from ADR-026; graceful degradation mitigates |
| Branch name validity | spec | Acceptable Risk — kebab-case validation already in `/opsx:new` |
| git branch detection | design | Acceptable Risk — `git branch --show-current` available since git 2.22 (2019) |

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in any artifacts.

---

**Result: PASS**

One action item to verify during implementation: confirm `/opsx:ff` skill either delegates to continue or has its own `post_artifact` handling.
