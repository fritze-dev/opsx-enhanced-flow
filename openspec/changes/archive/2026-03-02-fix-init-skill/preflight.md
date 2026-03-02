# Pre-Flight Check: Fix init skill

## A. Traceability Matrix

- [x] Install OpenSpec and Schema (modified) → Scenario: First-time init → `skills/init/SKILL.md` Steps 1-6
- [x] Install OpenSpec and Schema (modified) → Scenario: Idempotent re-init → `skills/init/SKILL.md` (--force, skip-if-exists, mkdir -p)
- [x] Install OpenSpec and Schema (modified) → Scenario: No duplicate skills → Removal of `openspec init --tools claude` step
- [x] Constitution update → `openspec/constitution.md` line 18

## B. Gap Analysis

- No gaps identified. All three bugs are addressed:
  1. `disable-model-invocation` fix → skill becomes discoverable
  2. Duplicate skill removal → no conflicting `.claude/skills/openspec-*`
  3. `mkdir -p` → safe file copy

## C. Side-Effect Analysis

- **Positive:** Changing `disable-model-invocation` to `false` means Claude *could* auto-invoke `/opsx:init`. Risk is low: the description clearly says "Run once per project" and the steps are idempotent. No regression expected.
- **Existing projects:** Projects already initialized via a manual workaround are unaffected — init is idempotent.
- **Cached plugin:** The plugin cache needs updating after this change. Users must update the plugin in their projects.

## D. Constitution Check

- [x] Constitution line 18 says "All skills are model-invocable except `init` (user-only, one-time setup)". This needs updating to remove the init exception since `disable-model-invocation` is now `false`.

## E. Duplication & Consistency

- No overlapping stories or contradictions.
- The spec delta is consistent with the existing `project-setup` baseline spec.
- Edge case about `.claude-plugin/plugin.json` conflict was removed from delta spec because init no longer touches `.claude-plugin/` — consistent with the removal of `openspec init`.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | `openspec schema init` works independently without prior `openspec init` | spec.md | Acceptable Risk — verified by testing in clean /tmp directory |
| 2 | `npm install -g` is the correct installation method for OpenSpec CLI | baseline spec | Acceptable Risk — unchanged from baseline, standard approach |
| 3 | `^1.2.0` version constraint enforced via npm semver | baseline spec | Acceptable Risk — unchanged from baseline |
