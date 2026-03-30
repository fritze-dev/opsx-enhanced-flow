# Research: Release Workflow

## 1. Current State

**Affected files:**
- `.claude-plugin/plugin.json` — version field (currently `1.0.3`)
- `.claude-plugin/marketplace.json` — version field (currently `1.0.0`, **out of sync**)
- `skills/archive/SKILL.md` — 6-step process, no version handling
- `openspec/constitution.md` — manual version bump convention (line 35)
- `README.md` — documents update flow (lines 409-431)

**Core problem:** `/plugin update` in consumer projects silently does nothing unless `plugin.json` version is bumped. The bump is manual and regularly forgotten. Additionally, `marketplace.json` is 3 patch versions behind `plugin.json`.

**Related issues:**
- GitHub Issue #5: Release Workflow (git tags, GitHub Releases, version pinning)
- GitHub Issue #7: Plugin install/update workflow is broken (5 sub-problems)

**Existing patterns:**
- Archive skill (`/opsx:archive`) is the "done" step for every change
- Changelog skill (`/opsx:changelog`) generates entries from archives
- No git tags exist (11 commits, 0 tags)
- No CI/CD, no git hooks, no test scripts

## 2. External Research

**Claude Code plugin system behavior:**
- `/plugin update` compares the `version` field in `plugin.json` to detect changes
- `/plugin marketplace update` refreshes the listing from the GitHub repo
- Both steps are required for consumers to get updates

**Semver convention:** Patch bumps (x.y.Z) are appropriate for backwards-compatible changes — which covers 95%+ of plugin changes (skill tweaks, docs, schema adjustments).

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Auto-bump in archive | Forgetting impossible, minimal effort | No version control (always patch), no tags |
| B: Separate /opsx:release skill | Full control, git tags, GitHub Releases | Manual step that can be forgotten (same problem as today) |
| C: Hybrid (auto-bump + manual major/minor) | Best of both — auto patches, manual when needed | Slightly inconsistent (auto vs manual) |

**Decision: Option C (Hybrid)** — Auto-bump patch in archive, manual process for minor/major documented in `docs/release-workflow.md`.

## 4. Risks & Constraints

- **Version inflation:** Each archive = patch bump. Acceptable trade-off vs. forgotten bumps.
- **marketplace.json sync:** Must always stay in sync with plugin.json. Auto-bump handles both.
- **No rollback:** If a bad version is pushed, consumers must wait for the next patch. Acceptable risk at current scale (1 consumer).
- **Archive skill complexity:** Adding a version step increases the skill's scope. Mitigated by keeping the step simple and conditional (only if plugin.json exists).

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Auto-bump in archive + docs for manual releases |
| Behavior | Clear | Patch bump on archive, sync both JSON files |
| Data Model | Clear | Only plugin.json and marketplace.json version fields |
| UX | Clear | Transparent in archive output, no extra user steps |
| Integration | Clear | Archive skill modification + new docs file |
| Edge Cases | Clear | No plugin.json = skip; first-time setup handled |
| Constraints | Clear | No CI/CD needed, no git hooks |
| Terminology | Clear | "patch", "minor", "major" per semver |
| Non-Functional | Clear | No performance concerns |

All categories Clear — no open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Auto-bump patch in `/opsx:archive` | Prevents forgotten version bumps (root cause of #7) | Separate release skill (too much overhead), manual-only (current broken state) |
| 2 | Sync marketplace.json in same step | Prevents version drift between the two files | Separate sync step (unnecessary complexity) |
| 3 | Document manual minor/major process | Rare enough that a docs page suffices | Dedicated skill (over-engineering for current needs) |
| 4 | E2E checklist as markdown | No test infrastructure exists; manual checklist fits project | Bash test script (out of pattern), CI/CD (out of scope) |
| 5 | No `/opsx:status` skill | Separate feature, would add scope | Include in this change (scope creep) |
