# Technical Design: Auto GitHub Releases + Plugin Source Restructuring

## Context

The plugin currently has a flat repository structure where plugin source files (skills, templates, plugin.json) are co-located with project files (docs, CI, specs, changelog). Consumers download everything. GitHub Releases are manual. The developer workflow relies on `--plugin-dir` which doesn't work in VS Code.

This change introduces three interconnected improvements: (1) move plugin source into `src/` for clean consumer distribution, (2) automate GitHub Releases via CI, (3) document the local marketplace workflow for developers.

## Architecture & Components

### Repository Structure (before → after)

```
BEFORE (flat):                       AFTER (separated):
├── .claude-plugin/                  ├── .claude-plugin/
│   ├── plugin.json    ← moves      │   └── marketplace.json  ← source: "./src"
│   └── marketplace.json             ├── src/                   ← NEW plugin root
├── skills/            ← moves      │   ├── .claude-plugin/
├── openspec/                        │   │   └── plugin.json
│   ├── templates/     ← moves      │   ├── skills/
│   ├── WORKFLOW.md                  │   └── templates/
│   ├── CONSTITUTION.md              ├── openspec/              ← project only
│   ├── specs/                       │   ├── templates/         ← project copy
│   └── changes/                     │   ├── WORKFLOW.md
├── docs/                            │   ├── CONSTITUTION.md
├── .github/                         │   ├── specs/
├── .devcontainer/                   │   └── changes/
├── CLAUDE.md                        ├── docs/
├── README.md                        ├── .github/
└── CHANGELOG.md                     │   └── workflows/
                                     │       ├── claude.yml
                                     │       ├── claude-code-review.yml
                                     │       └── release.yml     ← NEW
                                     ├── .devcontainer/
                                     ├── CLAUDE.md
                                     ├── README.md
                                     └── CHANGELOG.md
```

### Affected Components

| Component | Change | Details |
|-----------|--------|---------|
| `src/.claude-plugin/plugin.json` | Move | From `.claude-plugin/plugin.json` |
| `.claude-plugin/marketplace.json` | Edit | `source: "./"` → `source: "./src"` |
| `src/skills/` | Move | From `skills/` |
| `src/templates/` | Move | From `openspec/templates/` |
| `src/skills/setup/SKILL.md` | Edit | Template path: `openspec/templates/` → `templates/` |
| `.github/workflows/release.yml` | Create | New release action |
| `.devcontainer/devcontainer.json` | Edit | Local marketplace instead of GitHub |
| `openspec/CONSTITUTION.md` | Edit | Updated conventions |
| `.claude/settings.local.json` | Edit | Add `git tag` permission |
| `README.md` | Edit | Developer docs, structure explanation |

### Release Action Flow

```
Push to main with src/.claude-plugin/plugin.json change
  → GitHub Action triggers (paths filter)
  → Read version from src/.claude-plugin/plugin.json
  → Check if tag v<version> exists → skip if yes
  → Extract latest CHANGELOG.md entry (first ## section)
  → gh release create v<version> --title "v<version>" --notes "<entry>"
```

## Goals & Success Metrics

* `claude plugin marketplace add /local/path` + `claude plugin install opsx@opsx-enhanced-flow` loads plugin from `src/` — verified via `claude plugin list` showing correct version
* After push with version change to main, GitHub Release is created automatically within 2 minutes
* Consumer cache at `~/.claude/plugins/cache/opsx-enhanced-flow/opsx/<version>/` contains only `src/` contents (skills, templates, plugin.json) — no docs, CI, or OpenSpec project files
* `/opsx:setup` in a consumer project copies templates from `${CLAUDE_PLUGIN_ROOT}/templates/` successfully
* `/reload-plugins` picks up SKILL.md changes without `plugin update`

## Non-Goals

* Minor/major release automation (stays manual)
* Changelog skill changes (Action reads existing CHANGELOG.md)
* WORKFLOW.md hook additions
* `git-subdir` sparse checkout (relative path achieves same caching benefit)
* Consumer migration tooling (old cache is simply replaced on update)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| `src/` as subdirectory name | Short, conventional, clearly "source" | `plugin/` (longer, less standard) |
| `src/templates/` flat (not `src/openspec/templates/`) | Cleaner; `openspec/` nesting was artifact of co-location | Keep `openspec/templates/` (unnecessary depth) |
| marketplace.json stays at root `.claude-plugin/` | Required for marketplace discovery (`marketplace add` looks for `.claude-plugin/marketplace.json` at repo root) | Move alongside plugin.json (breaks discovery) |
| GitHub Action triggers on `src/.claude-plugin/plugin.json` path | Precise; only fires on version changes, not other pushes | Trigger on any push to main (too broad), trigger on tag push (chicken-and-egg) |
| Action uses `gh release create` (not GitHub API directly) | Simpler; `gh` is pre-installed on runners; handles both tag + release | REST API (more verbose), separate tag + release steps (more complex) |
| Root `.claude-plugin/` has only marketplace.json (no plugin.json) | plugin.json belongs with the plugin source in `src/`; avoids ambiguity about which plugin.json is authoritative | Keep plugin.json at root too (confusing dual source of truth) |

## Risks & Trade-offs

* **[Breaking change for existing consumers]** → Old cache layout is replaced on next `plugin update`. No migration needed — Claude Code handles this natively. Document in CHANGELOG.
* **[CLAUDE_PLUGIN_ROOT assumption]** → We assume it resolves to the cached `src/` directory, not the repo root. Validated via Claude Code docs. → If wrong, setup skill template copy fails; detectable immediately on first `/opsx:setup`.
* **[Relative path resolution assumption]** → We assume `source: "./src"` resolves relative to repo root, not `.claude-plugin/`. Validated via Claude Code docs. → If wrong, plugin installation fails; detectable immediately.
* **[Action GITHUB_TOKEN permissions]** → Default token may lack `contents: write` on repos with branch protection rules. → Action reports clear error; maintainer can switch to a PAT if needed.
* **[First tag ever]** → Repository has no existing tags. First Action run creates the first tag. No risk — idempotent design handles this.

## Migration Plan

1. **Move files**: `skills/` → `src/skills/`, `openspec/templates/` → `src/templates/`, `.claude-plugin/plugin.json` → `src/.claude-plugin/plugin.json`
2. **Update references**: marketplace.json source, setup skill path, constitution conventions, README
3. **Create release action**: `.github/workflows/release.yml`
4. **Update devcontainer**: Local marketplace path
5. **Test locally**: `claude plugin marketplace add .`, verify `claude plugin list` shows version, verify `/opsx:setup` copies templates
6. **Push + merge**: Action creates first tag + release automatically
7. **Consumer update**: Consumers run `marketplace update` + `plugin update` — new cache layout applied automatically

Rollback: Revert the merge commit. Consumers on old version continue working. New consumers can re-add marketplace.

## Open Questions

No open questions.

## Assumptions

- `source: "./src"` in marketplace.json resolves relative to the repository root, not the `.claude-plugin/` directory. <!-- ASSUMPTION: relative path resolution -->
- Claude Code caches only the referenced subdirectory contents, not the full repo clone. <!-- ASSUMPTION: subdirectory caching -->
- `CLAUDE_PLUGIN_ROOT` resolves to the plugin's cached directory (the `src/` contents after caching). <!-- ASSUMPTION: plugin root resolution -->
- The `GITHUB_TOKEN` provided by GitHub Actions has sufficient permissions to create tags and releases. <!-- ASSUMPTION: token permissions -->
