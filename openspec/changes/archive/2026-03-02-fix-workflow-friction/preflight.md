# Pre-Flight Check: Fix Workflow Friction

## A. Traceability Matrix

| Requirement | Scenarios | Components |
|-------------|-----------|------------|
| Per-Artifact Config Rules (artifact-pipeline) | Global context universal, Specs targeted rules, Tasks targeted rules, No rules = global only | `openspec/config.yaml` |
| Friction Tracking Convention (constitution-management) | Convention present in constitution, Developer discovers friction | `openspec/constitution.md` |
| Archive Completed Change (change-workspace) | Archive change, Sync prompt, Incomplete artifacts, Target exists, Incomplete tasks, Auto-bump version, Skip version bump, Friction prompt, User reports friction | `skills/archive/SKILL.md`, `.claude-plugin/plugin.json` |

**Verdict:** All requirements have scenarios. All scenarios map to specific components. No orphan scenarios.

## B. Gap Analysis

- **Missing edge cases:** None. The version bump covers both presence and absence of `plugin.json`. The friction prompt covers both "yes" and "no" responses.
- **Error handling:** Archive skill already handles missing archive directory (`mkdir -p`) and duplicate archive names. Version bump adds a non-semver edge case (warn and skip).
- **Empty states:** If `rules` key has no entries for an artifact, only global context is injected — explicitly covered in spec.

No gaps found.

## C. Side-Effect Analysis

- **config.yaml restructure:** Existing rules are redistributed, not removed. Every rule from the current `context` is preserved — either in the new `context` or in `rules.specs`/`rules.tasks`. **No behavioral regression** for existing artifacts.
- **Archive skill extension:** New steps 6 and 7 are added *after* the existing archive `mv` operation. Existing archive behavior (steps 1–5) is unchanged.
- **Constitution update:** Additive only — one new convention entry appended. No existing conventions modified.
- **README changes:** Additive sections (cheatsheet, expanded dev docs). No existing content removed.

No regressions expected.

## D. Constitution Check

- **Tech Stack:** No new technologies introduced. ✓
- **Architecture Rules:** No structural changes to the three-layer architecture. ✓
- **Code Style:** YAML 2-space indentation maintained in config.yaml. ✓
- **Constraints:** OpenSpec CLI `^1.2.0` compatibility preserved; `rules` field supported per docs. ✓
- **Conventions:** New convention follows existing convention format (bold label + description). ✓

No contradictions found.

## E. Duplication & Consistency

- **config.yaml rules vs schema.yaml instructions:** The per-artifact rules supplement schema instructions — they do not duplicate them. Schema instructions define *what* to generate; rules add *project-specific constraints* on how.
- **Constitution friction convention vs archive friction prompt:** Complementary, not duplicative. The convention establishes the rule; the archive prompt enforces it at the right workflow point.

No duplication or contradictions found.

## F. Assumption Audit

| Assumption | Source | Rating | Notes |
|------------|--------|--------|-------|
| plugin.json version follows semver MAJOR.MINOR.PATCH | change-workspace spec | Acceptable Risk | Current version is `1.0.1` (valid semver). Non-semver versions handled by warn-and-skip. |
| File system supports atomic mv | change-workspace spec (existing) | Acceptable Risk | Pre-existing assumption, unchanged. |
| System clock provides correct date | change-workspace spec (existing) | Acceptable Risk | Pre-existing assumption, unchanged. |

No blocking or needs-clarification assumptions.

---

## Verdict: PASS

All checks pass. No blockers, no warnings. Ready to proceed to task creation.
