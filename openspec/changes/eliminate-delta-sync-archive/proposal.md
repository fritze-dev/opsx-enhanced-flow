## Why

The delta-spec → sync → archive pattern creates significant friction: three spec formats (baseline, delta, merged), an agent-driven sync step that has caused race condition bugs (v1.0.36), and an unnecessary archive move step. This change eliminates all three by editing main specs directly, removing the sync skill entirely, and replacing the archive directory with flat date-prefixed change directories.

## What Changes

- **BREAKING**: `/opsx:sync` skill removed entirely — no more agent-driven spec merging
- **BREAKING**: `/opsx:archive` skill removed entirely — no more directory move step
- **BREAKING**: Delta spec format (ADDED/MODIFIED/REMOVED sections) eliminated — specs edited directly in `openspec/specs/`
- Change directories use creation-date prefix: `openspec/changes/YYYY-MM-DD-<name>/`
- No more `openspec/changes/archive/` subdirectory — all changes flat under `openspec/changes/`
- Active vs. completed changes distinguished by tasks.md status (open vs. all-checked)
- Worktree cleanup moves to lazy detection at `/opsx:new`
- Changelog reads proposal.md + current main specs instead of archived delta specs
- Docs incremental detection uses proposal.md Capabilities table instead of archived `specs/<cap>/` directories
- Post-apply workflow simplifies: verify → changelog → docs (no sync, no archive)
- Existing 37 archives migrated from `archive/` to `changes/`

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `change-workspace`: Remove archive requirement, remove delta-spec references, add date-prefixed directory naming at creation, add lazy worktree cleanup at `/opsx:new`, remove worktree-cleanup-after-archive requirement
- `artifact-pipeline`: Update post-apply workflow sequence (remove sync/archive), update standard tasks (remove archive step), update spec stage to edit main specs directly
- `artifact-generation`: Update ff spec stage behavior — edit main specs instead of creating delta specs
- `quality-gates`: Update preflight traceability to check main spec changes instead of delta specs
- `task-implementation`: Update apply to read main specs, update change detection for date-prefixed directories
- `release-workflow`: Update changelog to read from flat changes directory, use main specs for spec data
- `user-docs`: Update docs incremental detection mechanism, update glob paths
- `interactive-discovery`: Remove archive exclusion from context loading guardrails (no more archive directory)

### Consolidation Check

N/A — no new specs proposed. All changes modify existing capabilities.

**Existing specs reviewed:** change-workspace, spec-sync, artifact-pipeline, artifact-generation, quality-gates, task-implementation, release-workflow, user-docs, interactive-discovery, workflow-contract, spec-format.

**Removal:** `spec-sync` capability is removed entirely (its entire domain — delta spec merging — is eliminated).

## Impact

**Skills removed (2):**
- `src/skills/sync/SKILL.md`
- `src/skills/archive/SKILL.md`

**Skills modified (8):**
- `src/skills/new/SKILL.md` — date-prefixed directory, lazy worktree cleanup
- `src/skills/ff/SKILL.md` — spec stage edits main specs directly
- `src/skills/apply/SKILL.md` — change detection, reads main specs
- `src/skills/verify/SKILL.md` — verifies against main specs, no sync/archive references
- `src/skills/changelog/SKILL.md` — new glob path, reads main specs for spec data
- `src/skills/docs/SKILL.md` — new incremental detection, new glob path
- `src/skills/docs-verify/SKILL.md` — new glob path
- `src/skills/preflight/SKILL.md` — traceability against main specs

**Templates modified (1):**
- `src/templates/specs/spec.md` — remove delta format, instruction for direct editing

**Specs removed (1):**
- `openspec/specs/spec-sync/spec.md`

**Specs modified (8):**
- change-workspace, artifact-pipeline, artifact-generation, quality-gates, task-implementation, release-workflow, user-docs, interactive-discovery

**Config modified (2):**
- `openspec/WORKFLOW.md` — remove sync/archive from post-apply workflow
- `openspec/CONSTITUTION.md` — remove delta-spec, archive, sync references

**Migration (one-time):**
- Move `openspec/changes/archive/*` → `openspec/changes/`
- Remove `openspec/changes/archive/` directory

## Scope & Boundaries

**In scope:**
- Eliminate delta-spec format, sync skill, archive skill
- Flatten change directory structure with date prefix
- Update all 8 affected skills
- Update spec template for direct editing
- Update all 8 affected main specs
- Migrate existing archives
- Update WORKFLOW.md and CONSTITUTION.md

**Out of scope:**
- Changing the 6-stage artifact pipeline itself (research → proposal → specs → design → preflight → tasks)
- Changing the worktree feature (except moving cleanup to `/opsx:new`)
- Changing the Gherkin/BDD spec format within requirements
- Changing how docs, changelog, or ADRs are generated (only their data sources change)
- Redesigning the three-layer architecture
