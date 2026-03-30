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
cp -r "${CLAUDE_PLUGIN_ROOT}/templates/." openspec/templates/
```

### 2. Create WORKFLOW.md (skip if exists)

Only if `openspec/WORKFLOW.md` does **not** already exist:

1. Copy the workflow template from the plugin: `cp "${CLAUDE_PLUGIN_ROOT}/templates/workflow.md" openspec/WORKFLOW.md`
2. If the template file does not exist at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`, report an error and suggest reinstalling the plugin.

If it already exists, report: "WORKFLOW.md already exists — preserved."

### 3. Create CONSTITUTION.md placeholder (skip if exists)

Only if `openspec/CONSTITUTION.md` does **not** already exist, create it:

```markdown
# Project Constitution

> Run `/opsx:bootstrap` to generate project-specific rules from your codebase.
```

If it already exists, report: "CONSTITUTION.md already exists — preserved."

### 4. Environment checks

Run these checks and report results:

1. **Git version**: Run `git --version` and parse the version number. Report whether git 2.5+ is available (required for worktree support). If below 2.5, note that worktree mode is unavailable.

2. **gh CLI**: Run `gh --version`. If available, run `gh auth status` to check authentication. Report one of:
   - "gh CLI: available and authenticated"
   - "gh CLI: installed but not authenticated"
   - "gh CLI: not found"

3. **.gitignore**: Check if `.gitignore` contains a `/.claude/` entry. Report whether it is present.

### 5. Worktree opt-in (conditional)

Only if **both** git 2.5+ and gh CLI are available and authenticated:

1. Use **AskUserQuestion tool** to ask: "Enable worktree-based change isolation? Each `/opsx:new` will create an isolated git worktree with its own feature branch."
   - Options: "Yes (Recommended)" / "No"

2. If the user opts in:
   - Read `openspec/WORKFLOW.md` and uncomment the `worktree:` section, setting `enabled: true`:
     ```yaml
     worktree:
       enabled: true
       path_pattern: .claude/worktrees/{change}
       auto_cleanup: false
     ```
   - If `.gitignore` does not contain `/.claude/`, ask the user whether to add it. If they agree, append `/.claude/` to `.gitignore`.
   - Use **AskUserQuestion tool** to ask: "Configure GitHub repository for rebase-merge strategy? This keeps linear history and reduces merge conflicts with worktrees."
     - Options: "Yes (Recommended)" / "No"
   - If the user opts in to rebase-merge: Run `gh api repos/{owner}/{repo} -X PATCH -f allow_rebase_merge=true`. Report success or failure. If the API call fails (e.g., insufficient permissions), report the error and continue.

3. If the user declines or conditions are not met: Skip silently. The `worktree:` section remains commented out in WORKFLOW.md.

### 6. Validate

Verify that:
- `openspec/WORKFLOW.md` exists and is readable (read its first few lines)
- `openspec/templates/` directory exists and contains Smart Template files
- `openspec/CONSTITUTION.md` exists

If any check fails, report which specific validation failed.

## Output

Report a summary:
- Smart Templates installed at `openspec/templates/`
- WORKFLOW.md status (created from template or preserved)
- CONSTITUTION.md status (created or preserved)
- Migration status (if legacy layout was detected)
- Environment: git version, gh CLI status, .gitignore status
- Worktree mode: enabled or disabled
- Merge strategy: configured or skipped
- Suggest: "Run `/opsx:bootstrap` to scan your codebase and generate the project constitution."

Do not run `/opsx:bootstrap` automatically — let the user decide when to proceed.
