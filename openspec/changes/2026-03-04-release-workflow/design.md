# Technical Design: Release Workflow

## Context

The plugin's update mechanism requires a version bump in `plugin.json` for `/plugin update` to detect changes. This is currently a manual convention that is regularly forgotten, causing consumers to miss updates. Additionally, `marketplace.json` version is out of sync (1.0.0 vs 1.0.3). The solution uses constitution conventions — not skill modifications — to define post-archive behavior.

## Architecture & Components

**Key principle:** Skills are generic shared plugin code. Project-specific behavior is defined in the constitution. The archive skill reads the constitution before execution and follows its conventions.

**Modified files:**

| File | Change |
|------|--------|
| `openspec/constitution.md` | New conventions: post-archive auto-bump, skill immutability rule. Replace existing manual bump convention (line 35). |
| `.claude-plugin/marketplace.json` | Immediate fix: version `1.0.0` → `1.0.3`. Ongoing: auto-synced via convention. |
| `README.md` | Brief note about release workflow in "Updating the Plugin" section. |

**Auto-generated files (via `/opsx:docs`):**

| File | Source |
|------|--------|
| `docs/capabilities/release-workflow.md` | Generated from `openspec/specs/release-workflow/spec.md` after archive + sync |

**How the auto-bump works:**

The constitution convention instructs the agent executing `/opsx:archive` to:
1. After the archive `mv` succeeds, check if `.claude-plugin/plugin.json` exists
2. If yes: read current version, increment patch (X.Y.Z → X.Y.Z+1)
3. Update `plugin.json` version field
4. If `.claude-plugin/marketplace.json` exists: sync its version field to match
5. Show new version in the archive summary output + next steps

This is a **convention** — the agent follows it because it reads the constitution. No skill code is modified.

## Goals & Success Metrics

* Constitution contains post-archive auto-bump convention — PASS if convention text present
* Constitution contains skill immutability rule — PASS if rule text present
* `marketplace.json` version matches `plugin.json` version — PASS if equal after fix
* `/opsx:docs` generates `docs/capabilities/release-workflow.md` from spec — PASS if generated after archive
* Constitution no longer references manual version bumps — PASS if old convention replaced
* README documents updated consumer workflow — PASS if section updated

## Non-Goals

* No skill file modifications (skills are shared plugin code)
* No `/opsx:release` skill (deferred)
* No `/opsx:status` skill (separate feature)
* No git hooks or CI/CD automation
* No automatic git tagging (manual for minor/major only)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Convention in constitution, not skill modification | Skills are shared across consumers; project-specific behavior in constitution (Issue #10) | Modify archive skill directly (violates skill immutability) |
| Patch-only auto-bump | 95%+ of changes are patches; minor/major are rare and intentional | Auto-detect from changelog (complex, unreliable) |
| Sync marketplace.json in same convention | One operation, no drift | Separate convention (unnecessary complexity) |
| Docs page for minor/major | Rare enough for manual process | Dedicated skill (over-engineering) |

## Risks & Trade-offs

* **Convention compliance** — Depends on agent reading and following the constitution. Mitigated by constitution being read at the start of every skill execution (standard behavior).
* **Version inflation** (many small patches) → Acceptable trade-off vs. forgotten bumps.
* **No rollback for bad version** → Consumer must wait for next patch. Acceptable at current scale.

## Open Questions

No open questions.

## Assumptions

<!-- ASSUMPTION: The archive skill (and agent executing it) reads the constitution before execution -->
<!-- ASSUMPTION: plugin.json always has "version" as a top-level field with quoted semver string -->
<!-- ASSUMPTION: marketplace.json always has plugins array with version field at plugins[0].version -->
