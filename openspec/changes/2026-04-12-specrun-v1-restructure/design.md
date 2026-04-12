<!--
---
has_decisions: true
---
-->
# Technical Design: SpecShift Beta Restructure

## Context

The project is being restructured from "OpenSpec/OPSX" to "SpecShift". This is a cross-cutting change affecting every artifact in the repository: specs, templates, skill router, plugin manifests, docs, and project configuration. The primary constraint is preserving git blame history (Fork & Rewrite approach via bare clone).

Current state: All artifacts live under `openspec/` with deeply nested spec directories. The skill is named `workflow`. Templates are duplicated between `src/templates/` and `openspec/templates/`.

Target state: Infrastructure in `.specshift/`, knowledge in `docs/`, skill named `specshift`, no template duplication, dogfooding setup identical to a client project.

## Architecture & Components

### Repo Duplication (Phase 0)

```
git clone --bare git@github.com:fritze-dev/opsx-enhanced-flow.git
cd opsx-enhanced-flow.git
git remote set-url origin git@github.com:fritze-dev/specshift.git
git push --mirror
cd .. && rm -rf opsx-enhanced-flow.git
git clone git@github.com:fritze-dev/specshift.git
```

### File Moves (Phase 1 — git mv operations)

```
# Infrastructure → .specshift/
git mv openspec/WORKFLOW.md .specshift/WORKFLOW.md
git mv openspec/CONSTITUTION.md .specshift/CONSTITUTION.md
git mv openspec/templates .specshift/templates
git mv openspec/changes .specshift/changes

# Specs → docs/specs/ (flatten)
for dir in openspec/specs/*/; do
  name=$(basename "$dir")
  git mv "$dir/spec.md" "docs/specs/$name.md"
done

# Skill rename
git mv src/skills/workflow src/skills/specshift

# Cleanup
git rm -r openspec/          # Remove empty shell
git rm -r .agents/            # Remove broken symlinks
git rm -r .claude/skills/     # Remove workaround symlinks
git rm AGENTS.md              # Replaced by CLAUDE.md
```

### Content Updates (Phase 2 — edits)

| File(s) | Changes |
|---------|---------|
| `src/skills/specshift/SKILL.md` | All `openspec/` paths → `.specshift/` and `docs/specs/`. All `workflow` commands → `specshift`. All requirement anchor links updated for flat spec filenames. |
| `src/templates/*.md` (14 files) | `openspec/` paths → `.specshift/` and `docs/specs/`. `workflow` commands → `specshift`. Template instruction text debranded. |
| `.specshift/WORKFLOW.md` | `templates_dir: .specshift/templates`. Context section: `.specshift/CONSTITUTION.md`. All `workflow` → `specshift` in action instructions. |
| `.specshift/CONSTITUTION.md` | All self-referential paths updated. Plugin name `opsx` → `specshift`. Repo name → `specshift`. Skill path → `skills/specshift/`. |
| `src/.claude-plugin/plugin.json` | `name: "specshift"`, `version: "0.1.0-beta"` |
| `.claude-plugin/marketplace.json` | Plugin name → `specshift`, version → `0.1.0-beta` |
| `CLAUDE.md` | New file — ultra-lean agent entry point, replaces AGENTS.md + symlink |
| `README.md` | Rewrite with SpecShift branding, new install flow |
| `CHANGELOG.md` | Fresh start, v0.1.0-beta entry |

### Per-Change Spec Snapshots (Phase 3 — flatten historical)

```
# Flatten spec snapshots in completed changes
find .specshift/changes -path "*/specs/*/spec.md" -exec bash -c '
  dir=$(dirname "$1")
  name=$(basename "$dir")
  target="$(dirname "$dir")/$name.md"
  git mv "$1" "$target"
  rmdir "$dir" 2>/dev/null
' _ {} \;
```

## Goals & Success Metrics

* `grep -r "openspec/" --include="*.md" --include="*.json" . | grep -v ".specshift/changes/"` returns 0 results (no stale path references outside historical change artifacts)
* `specshift init` in a fresh test project creates correct `.specshift/` structure with WORKFLOW.md, CONSTITUTION.md, templates/, and CLAUDE.md
* `specshift propose test-feature` creates `.specshift/changes/YYYY-MM-DD-test-feature/` and traverses pipeline
* All 14 spec files are at `docs/specs/<name>.md` (flat, no directories)
* `git log --follow docs/specs/artifact-pipeline.md` shows history from before the rename
* Plugin installs as `specshift` via `claude plugin install specshift`

## Non-Goals

* ADR consolidation (deferred to v1.0)
* Capability docs regeneration (deferred to v1.0)
* Final README/CHANGELOG polish (deferred to v1.0)
* Template freeze (deferred to v1.0)
* Scalable pipelines (deferred)
* Plugin update check hook (deferred)

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Execute git mv before content edits | git mv tracks renames for blame. Content edits after move create clean blame entries at new paths. | Edit first, move second (rejected: git may not track rename if content differs too much) |
| Flatten per-change spec snapshots | Consistency with new flat spec format. Historical changes should not have a different structure. | Leave as-is (rejected: inconsistent structure confuses future tooling) |
| Version 0.1.0-beta (not 1.0.0) | Beta phase — mechanics may still change. v1.0.0 reserved for post-beta polish. | Start at 1.0.0 (rejected: premature, locks in structure before validation) |
| Single CLAUDE.md (not AGENTS.md + symlink) | Simpler, no symlink maintenance. CLAUDE.md is the native Claude Code convention. | Keep AGENTS.md pattern (rejected: symlinks proven unreliable) |
| No `.agents/` directory | Cross-client discovery via `.agents/` didn't work reliably. Plugin system handles skill discovery. | Keep `.agents/` (rejected: broken symlinks) |
| Dogfooding as 1:1 client (no symlinks) | Validates the real user flow. `.specshift/templates/` contains real copies, not symlinks to `src/templates/`. | Symlinks for dev convenience (rejected: doesn't test real flow, proven unreliable) |

## Risks & Trade-offs

* **git mv rename detection threshold** → git uses a similarity index (~50%) to detect renames. If content changes are too large in the same commit as the move, blame may break. Mitigation: Do moves in a separate commit before content edits.
* **Historical change artifacts with old paths** → Old changes in `.specshift/changes/` still reference `openspec/` paths internally. Mitigation: Accept this — they are historical records. Only flatten the spec snapshot structure, don't rewrite prose.
* **Plugin cache after rename** → Consumers with cached `opsx` plugin may need to uninstall and reinstall. Mitigation: No consumers yet (pre-release).

## Migration Plan

1. Create empty `specshift` repo on GitHub
2. Bare clone + mirror push (preserves all history, tags, branches)
3. Clone new repo locally
4. Create branch `feat/specshift-beta`
5. **Commit 1**: `git mv` operations only (moves + renames, no content changes)
6. **Commit 2**: Content edits (paths, branding, SKILL.md, templates, manifests)
7. **Commit 3**: New files (CLAUDE.md, updated README, CHANGELOG)
8. **Commit 4**: Per-change spec snapshot flattening
9. Squash or keep commits — review and merge to main
10. Tag `v0.1.0-beta`
11. Archive old repo with redirect note in README

Rollback: The old repo remains archived and functional. The new repo can be deleted if needed.

## Open Questions

No open questions.

## Assumptions

- No active consumers depend on the current `opsx` plugin or `openspec/` structure. <!-- ASSUMPTION: no-consumers -->
- GitHub bare clone + mirror push preserves all branch history and tags. <!-- ASSUMPTION: mirror-preserves-history -->
- git mv with subsequent content edits in separate commits preserves blame tracking. <!-- ASSUMPTION: separate-commits-preserve-blame -->
