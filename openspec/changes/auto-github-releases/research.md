# Research: Auto GitHub Releases

## 1. Current State

**Release workflow today (manual):**
- `/opsx:archive` auto-bumps patch version in `plugin.json` + `marketplace.json` (constitution convention)
- `/opsx:changelog` generates CHANGELOG.md entries from archived specs
- Git tags, GitHub Releases: fully manual (`git tag v<version>`, `gh release create`)
- No existing tags in the repository
- No GitHub Actions workflow for releases

**Existing CI/CD:**
- `.github/workflows/claude.yml` — @claude mention handler on issues/PRs
- `.github/workflows/claude-code-review.yml` — auto code review on PRs
- No release automation

**Plugin distribution:**
- `marketplace.json` uses `source: "./"` (plugin co-located with marketplace)
- Consumers install via `claude plugin marketplace add fritze-dev/opsx-enhanced-flow`
- Version field in `plugin.json` drives cache organization and update detection
- Plugin files (skills, templates) mixed with project files (docs, CI, specs, changelog) at repo root
- Consumers download entire repo including development-only files

**Repo structure (current — flat):**
- `.claude-plugin/plugin.json` + `marketplace.json` — both at root
- `skills/` — 12 skills at repo root
- `openspec/templates/` — templates at repo root (shared between plugin source and project copy)
- `openspec/specs/`, `openspec/changes/` — project-specific
- `docs/`, `.github/`, `.devcontainer/` — development-only

**Developer workflow (validated through testing):**
- Local marketplace (`claude plugin marketplace add <local-path>`) reads directly from filesystem
- Skill changes reload via `/reload-plugins` immediately
- Version changes in `plugin.json` require explicit `claude plugin update`
- VS Code extension does NOT support `--plugin-dir` — local marketplace is the solution
- `source: "./"` in marketplace.json is required for local marketplace to work

**Relevant specs:**
- `release-workflow/spec.md` — defines version bump convention, manual release process, consumer update flow
- `workflow-contract/spec.md` — defines WORKFLOW.md fields including `post_artifact`

**Relevant constitution conventions:**
- Post-archive version bump (CONSTITUTION.md line 33)
- README accuracy convention
- Commit style: imperative present tense with category prefix

## 2. External Research

**Claude Code plugin system (validated through hands-on testing):**
- `claude plugin marketplace add owner/repo#v1.0.30` — consumers can pin to a specific tag at add-time
- `marketplace.json` `source` field: `"./"` for co-located, or `{"source": "github", "repo": "...", "ref": "..."}` for external
- Changing source from `"./"` to GitHub ref breaks local marketplace — mutually exclusive
- Consumer version pinning works via `#ref` at marketplace add time, not via marketplace.json source field

**Plugin subdirectory distribution (validated via docs):**
- `source: "./src"` in marketplace.json resolves relative to repo root
- Claude Code caches ONLY the referenced subdirectory, not the entire repo
- Works with both local path (`marketplace add /local/path`) and GitHub (`marketplace add owner/repo`)
- `git-subdir` source type exists for sparse checkout but uses URLs (incompatible with local dev)
- Relative path `"./src"` achieves clean caching without sparse checkout complexity
- Setup skill references `${CLAUDE_PLUGIN_ROOT}/openspec/templates/` — needs update to `${CLAUDE_PLUGIN_ROOT}/templates/`

**GitHub Actions:**
- `paths` filter supports triggering on specific file changes (e.g., `.claude-plugin/plugin.json`)
- `gh release create` available in Actions via `GITHUB_TOKEN`
- `jq` available on `ubuntu-latest` runners for JSON parsing

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **GitHub Action on version change** | Fully automated after push; no local `gh` dependency; consistent; project already has Actions | New workflow file; release happens async after push |
| `post_changelog` hook in WORKFLOW.md | Inline with OpenSpec flow; immediate feedback | Requires `gh` CLI locally; adds skill complexity; new hook pattern |
| Dedicated `/opsx:release` skill | Single responsibility; can handle minor/major too | Another skill (consolidation planned); doesn't solve "automatic" |
| Constitution convention only | Zero code changes | Not automated; relies on agent following instructions |

## 4. Risks & Constraints

- **marketplace.json uses `source: "./src"`** — relative path that works for both local and GitHub marketplace
- **Repo restructuring** — moving skills and templates to `src/` is a significant change; all path references must be updated
- **No existing tags** — first release will be the first tag ever in the repo
- **Action must be idempotent** — re-running on same version must not fail
- **CHANGELOG.md must exist** when Action runs — changelog is generated before push in the post-apply workflow
- **Skill immutability** — no project-specific logic in skills; changes go in constitution, WORKFLOW.md, or CI

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | GitHub Action for auto-release, README update, DevContainer update |
| Behavior | Clear | Action triggers on plugin.json change, creates tag + release from CHANGELOG |
| Data Model | Clear | No new data; reads existing plugin.json + CHANGELOG.md |
| UX | Clear | Transparent to user — push triggers release automatically |
| Integration | Clear | Fits alongside existing claude.yml and claude-code-review.yml Actions |
| Edge Cases | Clear | Tag exists → skip; no CHANGELOG → use minimal notes; first run → first tag |
| Constraints | Clear | source: "./" must stay; skill immutability; constitution conventions |
| Terminology | Clear | Standard: tag, release, marketplace, consumer, version bump |
| Non-Functional | Clear | Action runs in ~30s; no performance concerns |

All categories are Clear — no open questions needed.

## 6. Open Questions

All Clear — no questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | GitHub Action for tag + release creation | Fully automated, no local dependencies, consistent, project already uses Actions | post_changelog hook (requires local gh), dedicated skill (not automatic), constitution convention (not automated) |
| 2 | Plugin source in `src/` subdirectory with `source: "./src"` | Clean consumer cache (only plugin files); works for both local and GitHub marketplace | Flat structure with `source: "./"` (consumers download everything), `git-subdir` (incompatible with local dev) |
| 3 | Consumer version pinning via `#ref` at add-time | Works without marketplace.json changes; clean separation of dev vs consumer | ref field in marketplace.json source (mutually exclusive with local dev) |
| 4 | Templates at `src/templates/` (flat, not `src/openspec/templates/`) | Cleaner plugin structure; setup skill path simplified | Keep `openspec/templates/` nesting (unnecessary depth inside plugin) |
| 5 | CLAUDE.md stays at repo root, not in `src/` | CLAUDE.md is project config, not plugin code | CLAUDE.md in src/ (consumers don't need project rules) |
| 6 | DevContainer uses local marketplace | Developers working in the repo should use local filesystem, not GitHub clone | Keep GitHub marketplace (would load cached/outdated version) |
| 7 | Update README developer docs | Current docs only mention `--plugin-dir` which doesn't work in VS Code | Leave as-is (inaccurate for VS Code users) |
