# Tests: SpecShift Beta Restructure

## Configuration

| Setting | Value |
|---------|-------|
| Mode | Manual only |
| Framework | (none) |
| Test directory | (none) |
| File pattern | (none) |

## Manual Test Plan

### project-init

#### Install Workflow

- [ ] **Scenario: Fresh install creates structure**
  - Setup: A fresh project without `.specshift/WORKFLOW.md`
  - Action: Run `specshift init`
  - Verify: `.specshift/templates/` exists with templates copied from plugin, `.specshift/WORKFLOW.md` exists with `templates_dir: .specshift/templates`, `.specshift/CONSTITUTION.md` exists, `docs/specs/` directory exists

- [ ] **Scenario: Re-init preserves customizations**
  - Setup: An initialized project with user-modified templates in `.specshift/templates/`
  - Action: Run `specshift init` again
  - Verify: User customizations in templates are preserved, updated templates merged where version differs

#### CLAUDE.md Bootstrap

- [ ] **Scenario: CLAUDE.md generated on fresh init**
  - Setup: A project without a `CLAUDE.md` file
  - Action: Run `specshift init`
  - Verify: `CLAUDE.md` exists at project root, contains `## Workflow` and `## Knowledge Management` sections, no `AGENTS.md` file or symlink created

- [ ] **Scenario: CLAUDE.md skipped when already exists**
  - Setup: A project with an existing `CLAUDE.md` file
  - Action: Run `specshift init`
  - Verify: `CLAUDE.md` is NOT overwritten, system reports "CLAUDE.md already exists — skipped"

#### Legacy Migration

- [ ] **Scenario: Legacy layout detected and migrated**
  - Setup: A project with `openspec/schemas/opsx-enhanced/schema.yaml` but no `.specshift/WORKFLOW.md`
  - Action: Run `specshift init`
  - Verify: WORKFLOW.md generated, templates moved and converted, constitution renamed, legacy files removed

### change-workspace

#### Create Change Workspace

- [ ] **Scenario: Workspace created with correct path**
  - Setup: An initialized project with `.specshift/WORKFLOW.md`
  - Action: Run `specshift propose new-feature`
  - Verify: Directory `.specshift/changes/YYYY-MM-DD-new-feature/` is created

#### Change Context Detection

- [ ] **Scenario: Context detected from proposal frontmatter**
  - Setup: An active change with `branch: new-feature` in `.specshift/changes/*/proposal.md`
  - Action: Run `specshift apply` on the `new-feature` branch
  - Verify: System detects the correct change context automatically

### artifact-pipeline

#### Eight-Stage Pipeline

- [ ] **Scenario: Pipeline traversal with new paths**
  - Setup: An initialized project with `.specshift/WORKFLOW.md` containing `templates_dir: .specshift/templates`
  - Action: Run `specshift propose test-change`
  - Verify: Templates are read from `.specshift/templates/`, artifacts are written to `.specshift/changes/*/`

#### Post-Artifact Commit and PR Integration

- [ ] **Scenario: Commit after artifact generation**
  - Setup: A change with a newly generated artifact
  - Action: Pipeline generates an artifact
  - Verify: Commit message contains change name, artifacts staged from `.specshift/changes/`

### workflow-contract

#### WORKFLOW.md Pipeline Orchestration

- [ ] **Scenario: WORKFLOW.md at new path**
  - Setup: Project with `.specshift/WORKFLOW.md`
  - Action: Run any `specshift` command
  - Verify: System reads `.specshift/WORKFLOW.md` (not `openspec/WORKFLOW.md`), extracts frontmatter and actions correctly

#### Smart Template Format

- [ ] **Scenario: Templates read from .specshift/templates/**
  - Setup: Project with templates in `.specshift/templates/`
  - Action: Run `specshift propose`
  - Verify: Templates loaded from `.specshift/templates/` as specified by `templates_dir` in WORKFLOW.md

### constitution-management

#### Constitution as Global Context

- [ ] **Scenario: Constitution read from new path**
  - Setup: Project with `.specshift/CONSTITUTION.md`
  - Action: Run `specshift propose`
  - Verify: System reads and follows `.specshift/CONSTITUTION.md` (not `openspec/CONSTITUTION.md`)

### release-workflow

#### Auto Patch Version Bump

- [ ] **Scenario: Version bump with new plugin name**
  - Setup: `src/.claude-plugin/plugin.json` with `"name": "specshift"`
  - Action: Run `specshift finalize` on a completed change
  - Verify: Patch version incremented in `plugin.json`, synced to `marketplace.json`

#### Plugin Source Directory Structure

- [ ] **Scenario: Skill at new path**
  - Setup: Plugin with skill at `src/skills/specshift/SKILL.md`
  - Action: Install plugin via marketplace
  - Verify: Skill discovered and available as `specshift` command

### documentation

#### Capability Doc Generation

- [ ] **Scenario: Docs generated from flat specs**
  - Setup: Specs at `docs/specs/<name>.md` (flat)
  - Action: Run `specshift finalize`
  - Verify: Capability docs generated, referencing `docs/specs/<name>.md` paths

### three-layer-architecture

#### Layer Separation

- [ ] **Scenario: Router reads from .specshift/ paths**
  - Setup: SKILL.md referencing `.specshift/WORKFLOW.md` and `docs/specs/`
  - Action: Run `specshift propose`
  - Verify: SKILL.md correctly loads WORKFLOW.md from `.specshift/`, loads spec requirements from `docs/specs/`

### Structural Verification (cross-cutting)

#### Path Consistency

- [ ] **Scenario: No stale openspec/ references**
  - Setup: Fully restructured project
  - Action: Run `grep -r "openspec/" --include="*.md" --include="*.json" . | grep -v ".specshift/changes/"`
  - Verify: 0 results (no stale references outside historical change artifacts)

- [ ] **Scenario: No stale workflow command references**
  - Setup: Fully restructured project
  - Action: Run `grep -rn "workflow init\|workflow propose\|workflow apply\|workflow finalize" --include="*.md" .`
  - Verify: 0 results

- [ ] **Scenario: No OpenSpec branding in specs**
  - Setup: All 14 spec files at `docs/specs/`
  - Action: Run `grep -rn "OpenSpec" docs/specs/`
  - Verify: 0 results

- [ ] **Scenario: All specs are flat files**
  - Setup: Fully restructured project
  - Action: `ls docs/specs/`
  - Verify: 14 flat `.md` files, no subdirectories

#### Git History Preservation

- [ ] **Scenario: Blame preserved after git mv**
  - Setup: A spec file moved via `git mv`
  - Action: Run `git log --follow docs/specs/artifact-pipeline.md`
  - Verify: History shows commits from before the rename

#### Plugin Installation

- [ ] **Scenario: Plugin installs under new name**
  - Setup: Plugin published with `"name": "specshift"`
  - Action: Run `claude plugin install specshift`
  - Verify: Plugin installed, `specshift` command available

## Traceability Summary

| Metric | Count |
|--------|-------|
| Total scenarios | 22 |
| Automated tests | 0 |
| Manual test items | 22 |
| Preserved (@manual) | 0 |
| Edge case tests | 3 (structural verification) |
| Warnings | 0 |
