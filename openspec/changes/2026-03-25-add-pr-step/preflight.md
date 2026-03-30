# Pre-Flight Check: Add PR Step to Workflow

## A. Traceability Matrix

- [x] Proposal PR Integration → Scenario: Draft PR created after proposal → `schema.yaml` proposal.instruction
- [x] Proposal PR Integration → Scenario: Graceful degradation without gh CLI → `schema.yaml` proposal.instruction
- [x] Proposal PR Integration → Scenario: Proposal template includes Pull Request section → `templates/proposal.md`
- [x] Schema Owns Workflow Rules (MODIFIED) → Scenario: Apply instruction includes post-apply workflow → `schema.yaml` apply.instruction
- [x] Standard Tasks Exclusion (MODIFIED) → Scenario: All standard tasks marked before commit → `schema.yaml` apply.instruction, `constitution.md`

## B. Gap Analysis

No gaps identified:
- Graceful degradation covers `gh` CLI missing, network failure, no remote
- Branch collision handled (reuse existing branch)
- Error handling: partial state recorded, pipeline not blocked
- Edge case: no-code changes — PR still created from proposal content (valid use case)

## C. Side-Effect Analysis

- **Existing proposals**: In-progress changes with existing `proposal.md` are unaffected — instruction changes only affect new artifact generation.
- **Constitution extras behavior change**: The `task-implementation` spec previously stated constitution extras are NOT auto-executed (edge case on line 189). This change modifies that behavior — constitution extras are now executed during post-apply. The existing constitution extra (`Update plugin locally`) will now be auto-executed instead of manually marked. This is intentional and desirable.
- **Other consumers of opsx-enhanced schema**: The proposal instruction gains PR steps, but graceful degradation ensures non-GitHub projects continue to work (branch is created, PR is skipped).

## D. Constitution Check

The constitution's `## Standard Tasks` section gains a new entry for PR finalization. No new technologies or architectural patterns are introduced — `gh` CLI is an optional external tool, not a project dependency.

No constitution updates needed beyond the new standard task entry.

## E. Duplication & Consistency

- No overlapping stories or contradictions between delta specs.
- The `artifact-pipeline` delta adds a new requirement (Proposal PR Integration) and modifies one existing requirement (Schema Owns Workflow Rules). No conflict with other requirements in that spec.
- The `task-implementation` delta modifies Standard Tasks Exclusion. The change is consistent with the apply.instruction update in `artifact-pipeline`.
- Existing specs checked: `release-workflow` (covers version bumps, not PRs — distinct), `change-workspace` (covers workspace lifecycle, not git branching — distinct).

## F. Assumption Audit

| Assumption | Source | Rating |
|------------|--------|--------|
| gh CLI authentication | artifact-pipeline delta spec | Acceptable Risk — graceful degradation handles the failure case |
| Branch name validity | artifact-pipeline delta spec | Acceptable Risk — change names are validated as kebab-case by `/opsx:new`, which is git-safe |
| Git remote availability | design.md | Acceptable Risk — push and PR are skipped if remote is unavailable |

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any artifact.

---

**Verdict: PASS**
