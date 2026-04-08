# Pre-Flight Check: Fix Friction Batch (#81, #86, #87, #88)

## A. Traceability Matrix

| Capability | Requirement / Change | Scenarios | Components |
|---|---|---|---|
| task-implementation | Automated QA steps (#81) | QA automated steps run without pausing | `apply.instruction` in WORKFLOW.md (both copies) |
| quality-gates | Verify auto-fix for mechanical WARNINGs (#86) | Auto-fixes stale cross-reference; Does not auto-fix judgment divergence | Verify SKILL.md |
| change-workspace | Post-merge worktree cleanup (#88) | Cleanup after local merge; Skipped when not in worktree; Fails gracefully on dirty state | `apply.instruction` in WORKFLOW.md (both copies) |
| (constitution convention) | Template synchronization (#87) | N/A (convention, no scenario) | CONSTITUTION.md, `src/templates/constitution.md` |

All proposed changes have matching scenarios and target components. No orphaned requirements.

## B. Gap Analysis

- **Auto-fix boundary clarity**: The quality-gates spec defines "mechanically fixable" as "stale cross-references, inconsistent naming, outdated text correctable by simple text replacement." This is sufficiently specific — no gap.
- **Post-merge cleanup error handling**: The change-workspace spec includes a scenario for dirty worktree failure. Covered.
- **Template sync scope**: The constitution convention needs to clarify which WORKFLOW.md fields must sync vs. which may intentionally differ (e.g., `worktree.enabled` default). This is an implementation detail for the convention text, not a spec gap.

No gaps found.

## C. Side-Effect Analysis

| Side-Effect | Risk | Assessment |
|---|---|---|
| Verify auto-fix modifies artifact files during verification | Low — only stale references; report documents each fix | Acceptable. Scope explicitly limited to mechanical fixes. |
| apply.instruction text grows longer | Low — adding ~6 lines to an already ~20-line instruction | NONE. No functional risk. |
| Consumer template divergence if convention not followed | Medium — the whole point of #87 is to prevent this | Addressed by the new convention itself. |

No unaddressed side-effects.

## D. Constitution Check

- **Skill immutability**: All skill changes are to SKILL.md instruction text, not skill logic. The verify SKILL.md update adds guidance (what to do with findings), not new behavior that should live in a spec. Consistent with the three-layer architecture.
- **README accuracy**: The README will need updating after implementation (handled by `/opsx:docs` in standard tasks).
- **New convention needed**: #87 adds a "Template synchronization" convention to CONSTITUTION.md. This is the correct location per the architecture rules ("project-specific workflows and conventions MUST be defined in this constitution").

Constitution update required: add "Template synchronization" convention. No conflicting rules.

## E. Duplication & Consistency

- **task-implementation vs. human-approval-gate**: The automated QA steps change is in task-implementation (where apply execution behavior lives). The human-approval-gate spec defines the approval structure and already says "Metric Check, Auto-Verify, User Testing" as the QA sequence — no contradiction. The new text says "automated steps" for the first two, which aligns with the "Auto-" prefix already in the template.
- **change-workspace lazy cleanup vs. post-merge cleanup**: Lazy cleanup (at `/opsx:new`) and post-merge cleanup (immediate, in-session) are complementary, not duplicative. The spec explicitly states this relationship.
- **WORKFLOW.md dual copies**: Both `openspec/WORKFLOW.md` and `src/templates/workflow.md` need the same `apply.instruction` changes. The design identifies this. The new convention (#87) formally requires this going forward.

No duplication or inconsistency issues.

## F. Assumption Audit

| Source | Assumption | Tag | Rating |
|---|---|---|---|
| design.md | Agent reads and follows `apply.instruction` text during QA loop execution | Agent instruction compliance | Acceptable Risk — consistent with project enforcement philosophy (ADR-004, -006, -015) |
| design.md | `src/templates/constitution.md` has a Conventions section | Constitution template structure | Acceptable Risk — verified: the template has `## Conventions` at line 25 |

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any artifact.

---

**Verdict: PASS**

0 blockers, 0 warnings. All requirements traced, no gaps, no side-effect risks, no constitution conflicts, no duplication, all assumptions acceptable, no unresolved markers.
