# Pre-Flight Check: Auto-Test Generation

## A. Traceability Matrix

| Capability | Spec | Requirements | Scenarios | Components |
|---|---|---|---|---|
| test-generation (NEW) | openspec/specs/test-generation/spec.md | 7 requirements | 18 scenarios | openspec/templates/tests.md, src/templates/tests.md, openspec/templates/constitution.md, src/templates/constitution.md |
| artifact-pipeline (MODIFIED) | openspec/specs/artifact-pipeline/spec.md | 1 requirement modified (Seven→Eight-Stage Pipeline) | 3 scenarios updated | openspec/WORKFLOW.md, src/templates/workflow.md |
| quality-gates (MODIFIED) | openspec/specs/quality-gates/spec.md | 1 requirement modified (Post-Implementation Verification) | 4 scenarios added | openspec/templates/review.md, src/templates/review.md |

All capabilities from proposal mapped to specs. All requirements have at least one scenario. All scenarios map to at least one component.

- [x] All 3 capabilities have corresponding specs ✓
- [x] All requirements have scenarios ✓
- [x] All scenarios trace to components ✓

## B. Gap Analysis

**Edge cases reviewed:**
- test-generation spec: 8 edge cases documented (no scenarios, empty edge cases, duplicate names, long names, missing directory, existing file, no capabilities, unknown framework)
- artifact-pipeline: existing edge cases still valid; updated stage count references
- quality-gates: existing edge cases still valid; new test coverage scenarios cover framework and no-framework paths

**Potential gaps identified:**
- NONE — all identified scenarios include both happy path and error cases. The dual-mode design (with/without framework) handles the primary variability.

## C. Side-Effect Analysis

| Side Effect | Risk | Assessment |
|---|---|---|
| Pipeline array change (7→8 stages) | Consumer projects with cached WORKFLOW.md will be out of sync | LOW — template-version bump (3→4) signals the change. `init` detects and offers merge. |
| tasks.md `requires` chain change | tasks template depends on `[tests]` instead of `[preflight]` | LOW — the `tests` stage always produces a tests.md (even without framework), so tasks is never blocked. |
| Review template new dimension | Existing review.md artifacts from prior changes won't have test coverage | NONE — review.md is regenerated each apply run. No stale data risk. |
| Constitution template change | Consumer constitutions won't have ## Testing until re-init | NONE — absence of ## Testing triggers manual-only mode. Graceful degradation by design. |

## D. Constitution Check

- **Three-layer architecture**: Respected. No router (SKILL.md) changes. Config in constitution (Layer 1), logic in template (Layer 2), orchestration in WORKFLOW.md (Layer 3).
- **Router immutability**: SKILL.md is unchanged. ✓
- **Template synchronization**: All openspec/templates/ changes must sync to src/templates/. Noted as task requirement.
- **Spec format rules**: New spec uses correct format (#### Scenario: headings, GIVEN/WHEN/THEN, visible assumptions). ✓
- **No ADR references in specs**: No ADR references found in specs. ✓

No constitution conflicts detected.

## E. Duplication & Consistency

- **test-generation vs quality-gates**: No overlap. test-generation creates test artifacts pre-implementation. quality-gates verifies them post-implementation.
- **test-generation vs spec-format**: No overlap. spec-format defines the Gherkin format. test-generation consumes it.
- **test-generation vs task-implementation**: No overlap. task-implementation executes tasks. test-generation creates test artifacts before tasks.
- **artifact-pipeline changes**: Consistent with test-generation spec (both reference 8-stage pipeline).
- **quality-gates changes**: New test coverage dimension is additive to existing dimensions. No contradictions.

No duplication or consistency issues found.

## F. Assumption Audit

| # | Source | Assumption | Visible Text | Rating |
|---|---|---|---|---|
| 1 | test-generation spec | Gherkin format compliance | "Gherkin scenarios in specs follow the format defined in the spec-format spec" ✓ | Acceptable Risk — enforced by spec-format spec |
| 2 | test-generation spec | LLM framework knowledge | "The LLM generating test stubs has sufficient knowledge of mainstream test frameworks" ✓ | Acceptable Risk — Claude knows mainstream frameworks |
| 3 | test-generation spec | Automatable vs manual classification | "The distinction between automatable and non-automatable scenarios can be determined by the LLM" ✓ | Acceptable Risk — heuristic, users can override with @manual |
| 4 | design.md | Router dynamic discovery | "The router's dynamic pipeline reading is sufficient to pick up new stages" ✓ | Acceptable Risk — router reads pipeline array from WORKFLOW.md dynamically |
| 5 | design.md | Consumer re-init | "Consumer projects will re-run init after updating the plugin" ✓ | Acceptable Risk — template-version bump triggers init merge flow |

All assumptions have visible text before HTML comment tags. ✓
No Blocking or Needs Clarification assumptions.

## G. Review Marker Audit

Scanned all change artifacts (research.md, proposal.md, specs, design.md) for `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers.

**Result: 0 REVIEW markers found.** ✓

## H. Draft Spec Validation

| Spec | Status | Change | Valid |
|---|---|---|---|
| test-generation | draft | 2026-04-10-auto-test-generation | ✓ Owned by current change |
| artifact-pipeline | draft | 2026-04-10-auto-test-generation | ✓ Owned by current change |
| quality-gates | draft | 2026-04-10-auto-test-generation | ✓ Owned by current change |

No orphaned drafts. No drafts owned by other changes.

---

## Verdict: PASS

- 0 Blockers
- 0 Warnings
- All dimensions clear
