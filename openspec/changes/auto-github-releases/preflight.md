# Pre-Flight Check: Auto GitHub Releases + Plugin Source Restructuring

## A. Traceability Matrix

- [x] Automated GitHub Release via CI → Scenarios: release on push, tag exists skip, no version change, first release → Component: `.github/workflows/release.yml`
- [x] Consumer Version Pinning → Scenarios: pin to version, pinned no updates → Component: README documentation
- [x] Developer Local Marketplace → Scenarios: register local, skill reload, version update → Component: README, DevContainer
- [x] Plugin Source Directory Structure → Scenarios: consumer cache, plugin root resolution → Component: `src/` directory, marketplace.json
- [x] Marketplace Source Configuration → Scenarios: local resolve, GitHub resolve, version detection → Component: `.claude-plugin/marketplace.json`
- [x] Repository Layout Separation → Scenarios: CLAUDE.md at root, OpenSpec at root → Component: repo file moves
- [x] Manual Minor/Major Release (modified) → Scenarios: push-based release, retroactive tagging → Component: constitution convention, release action
- [x] Post-Push Developer Update (modified) → Scenarios: local marketplace update, GitHub marketplace update → Component: constitution convention
- [x] Setup Template Path (modified) → Scenarios: first-time setup, idempotent re-setup → Component: `src/skills/setup/SKILL.md`

## B. Gap Analysis

- **Consumer migration**: No explicit migration step. Old cache is replaced on `plugin update`. Spec covers this as edge case. Gap: README should mention this in the "Updating" section. → Addressed in README update task.
- **marketplace.json version field**: Currently marketplace.json has a `version` field that is synced with plugin.json. After restructuring, `version` in marketplace.json should still match `src/.claude-plugin/plugin.json`. → Constitution convention must update the bump path.
- **Agents directory**: `/reload-plugins` showed "5 agents". Need to verify agents are discovered from `src/` too, or if they need to be inside `src/`. → Checked: agents are likely in the plugin root. Must verify during implementation.

## C. Side-Effect Analysis

- **Existing consumers**: Next `plugin update` replaces flat cache with `src/` layout. If `/opsx:setup` was already run, consumer's `openspec/templates/` is a local copy — unaffected.
- **Setup skill**: Path changes from `${CLAUDE_PLUGIN_ROOT}/openspec/templates/` to `${CLAUDE_PLUGIN_ROOT}/templates/`. Consumers with old cached plugin who run `/opsx:setup` will use the old path. After update, new path is used. No backwards compatibility issue — update replaces the entire cache.
- **Post-archive version bump convention**: Path changes from `.claude-plugin/plugin.json` to `src/.claude-plugin/plugin.json`. Must update CONSTITUTION.md.
- **GitHub Actions path filter**: `release.yml` triggers on `src/.claude-plugin/plugin.json`. Existing actions (`claude.yml`, `claude-code-review.yml`) are unaffected.
- **Standard tasks in CONSTITUTION.md**: Post-merge task references `claude plugin marketplace update` — still valid.

## D. Constitution Check

Updates needed:
- **Post-archive version bump**: Path changes to `src/.claude-plugin/plugin.json` + `src/.claude-plugin/marketplace.json` wait — marketplace.json stays at root `.claude-plugin/`. Version must be synced in both: `src/.claude-plugin/plugin.json` (plugin manifest) and `.claude-plugin/marketplace.json` (marketplace listing).
- **Release convention**: Add that GitHub Action auto-creates tag + release on push.
- **README accuracy**: Triggered by this change — README must be updated.

## E. Duplication & Consistency

- No contradictions between specs. `release-workflow` delta extends the existing spec consistently.
- `project-setup` delta is a focused path change, consistent with the directory restructuring in `release-workflow`.
- The `workflow-contract` spec defines WORKFLOW.md fields — no conflict, WORKFLOW.md is not modified.
- The `three-layer-architecture` spec defines CONSTITUTION → WORKFLOW → Skills layering — the restructuring doesn't change the logical layering, only the physical file locations.

## F. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | GITHUB_TOKEN permissions for tags/releases | release-workflow spec, design | Acceptable Risk | Default token has `contents: write` when explicitly granted in workflow. Action declares this permission. |
| 2 | jq availability on ubuntu-latest | release-workflow spec | Acceptable Risk | jq is pre-installed on all GitHub-hosted runners. |
| 3 | CHANGELOG.md follows Keep a Changelog format | release-workflow spec | Acceptable Risk | Enforced by `/opsx:changelog` skill. |
| 4 | Relative path resolution from repo root | release-workflow spec, design | Needs Verification | Validated via Claude Code docs, but must be tested during implementation. |
| 5 | Subdirectory caching | release-workflow spec, design | Needs Verification | Validated via Claude Code docs, but must be tested during implementation. |
| 6 | CLAUDE_PLUGIN_ROOT resolves to src/ contents | release-workflow spec, design, project-setup spec | Needs Verification | Critical for setup skill. Must be tested during implementation. |

**Verdict: PASS WITH WARNINGS**

Assumptions 4-6 (path resolution, caching, plugin root) are validated via documentation but have not been tested hands-on with the `./src` subdirectory configuration. These must be verified early in implementation before proceeding with the full file restructuring.

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any spec or design artifacts.
