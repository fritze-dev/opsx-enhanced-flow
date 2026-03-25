---
name: setup
description: Install the opsx-enhanced workflow into the current project. Run once per project before using any other /opsx commands.
disable-model-invocation: false
---

# /opsx:setup — Project Setup

> Install the opsx-enhanced workflow into the current project.

Run this **once per project** before using `/opsx:bootstrap` or any other `/opsx:*` commands.

## Instructions

Execute these steps in order. Report each result to the user. Stop on any failure and report what went wrong.

### 0. Legacy Migration Check

Check if `openspec/schemas/opsx-enhanced/schema.yaml` exists but `openspec/WORKFLOW.md` does **not**. If so, this is a legacy project — run the migration:

1. Generate `openspec/WORKFLOW.md` from schema.yaml content (extract pipeline definition, apply config, post_artifact hook) and config.yaml settings (context, docs_language)
2. Move templates from `openspec/schemas/opsx-enhanced/templates/` to `openspec/templates/`, converting each to Smart Template format (add YAML frontmatter with `id`, `description`, `generates`, `requires`, `instruction` fields from schema.yaml artifact definitions)
3. Rename `openspec/constitution.md` to `openspec/CONSTITUTION.md` if the lowercase version exists
4. Remove `openspec/schemas/` directory and `openspec/config.yaml`
5. Report: "Legacy layout migrated to WORKFLOW.md + Smart Templates."

If both `openspec/WORKFLOW.md` and `openspec/schemas/` exist (partial manual migration), preserve WORKFLOW.md and skip migration.

### 1. Copy Smart Templates from plugin

```bash
mkdir -p openspec/templates/specs openspec/templates/docs
cp -r "${CLAUDE_PLUGIN_ROOT}/openspec/templates/." openspec/templates/
```

### 2. Create WORKFLOW.md (skip if exists)

Only if `openspec/WORKFLOW.md` does **not** already exist, create it with this content:

```markdown
---
templates_dir: openspec/templates
pipeline: [research, proposal, specs, design, preflight, tasks]

apply:
  requires: [tasks]
  tracks: tasks.md
  instruction: |
    Read context files, work through pending tasks, mark complete as you go.
    Pause if you hit blockers or need clarification.

    Standard Tasks (post-implementation section) are NOT part of apply.
    They are tracked in tasks.md for auditability but executed separately
    after apply completes.

    Post-apply workflow: /opsx:verify → /opsx:archive →
    /opsx:changelog → /opsx:docs → commit → execute constitution
    pre-merge standard tasks. Never skip steps.
    IMPORTANT: /opsx:verify MUST run before /opsx:sync or /opsx:archive.
    Never sync baseline specs before implementation is verified.

    Constitution standard tasks are split into pre-merge and post-merge.
    Only pre-merge tasks are executed during post-apply workflow.
    Post-merge tasks remain as unchecked reminders in tasks.md —
    they are executed manually after the PR is merged.

    Before committing, mark all standard task checkboxes in tasks.md
    as complete — including the commit step itself — EXCEPT post-merge
    tasks, which remain unchecked.

post_artifact: |
  After creating any artifact, commit and push the change:
  1. If not on a feature branch (i.e., on main): `git checkout -b <change-name>`
  2. Stage change artifacts: `git add openspec/changes/<change-name>/`
  3. Commit: `git commit -m "WIP: <change-name> — <artifact-id>"`
  4. Push: `git push -u origin <change-name>`
  5. On FIRST push only (no existing PR for this branch):
     `gh pr create --draft --title "<Change Name>" --body "WIP: <change-name>"`

  If `gh` CLI is unavailable or not authenticated, skip PR creation.
  If the branch already exists, switch to it (`git checkout <change-name>`).
  If push fails, continue with local commit — do not block the pipeline.

context: |
  Always read and follow openspec/CONSTITUTION.md before proceeding.
  All workflow artifacts (research, proposal, specs, design, preflight, tasks)
  must be written in English regardless of docs_language.

# docs_language: English
---

# Workflow

Research → Propose → Specs → Design → Pre-Flight → Tasks → Apply → QA → Sync → Archive
```

If it already exists, report: "WORKFLOW.md already exists — preserved."

### 3. Create CONSTITUTION.md placeholder (skip if exists)

Only if `openspec/CONSTITUTION.md` does **not** already exist, create it:

```markdown
# Project Constitution

> Run `/opsx:bootstrap` to generate project-specific rules from your codebase.
```

If it already exists, report: "CONSTITUTION.md already exists — preserved."

### 4. Validate

Verify that:
- `openspec/WORKFLOW.md` exists and is readable (read its first few lines)
- `openspec/templates/` directory exists and contains Smart Template files
- `openspec/CONSTITUTION.md` exists

If any check fails, report which specific validation failed.

## Output

Report a summary:
- Smart Templates installed at `openspec/templates/`
- WORKFLOW.md status (created or preserved)
- CONSTITUTION.md status (created or preserved)
- Migration status (if legacy layout was detected)
- Suggest: "Run `/opsx:bootstrap` to scan your codebase and generate the project constitution."

Do not run `/opsx:bootstrap` automatically — let the user decide when to proceed.
