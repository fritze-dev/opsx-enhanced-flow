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

### 1. Install Smart Templates (with merge detection)

```bash
mkdir -p openspec/templates/specs openspec/templates/docs
```

For each template file in `${CLAUDE_PLUGIN_ROOT}/templates/` (excluding `workflow.md`):

1. Read the plugin template's `template-version` field from YAML frontmatter.
2. Check if the corresponding local file exists at `openspec/templates/<path>`.
3. **Compare and decide:**
   - **Local file does not exist**: Copy the plugin template. Report: "Template `<name>` installed."
   - **Local `template-version` matches plugin AND content identical**: Skip. Report: "Template `<name>` up to date."
   - **Local `template-version` matches plugin BUT content differs**: User has customized. Keep local. Report: "Template `<name>` has local customizations — preserved."
   - **Plugin `template-version` is higher AND local content matches previous plugin version**: Update silently. Report: "Template `<name>` updated (v`<old>` → v`<new>`)."
   - **Plugin `template-version` is higher AND local content has been customized**: Present both versions to the user. Ask them to resolve differences (keep local, accept plugin, or merge manually). Report: "Template `<name>` has both local customizations and plugin updates — merge required."
   - **No local `template-version` field (legacy)**: Treat as version 0. Apply the same logic.
   - **Plugin `template-version` is lower**: Warn and skip (do not downgrade).

### 2. Install WORKFLOW.md (with merge detection)

Apply the same `template-version` merge detection as Step 1, but between `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md` and `openspec/WORKFLOW.md`:

- **Does not exist**: Copy from plugin template. Report: "WORKFLOW.md created from template."
- **Same version, same content**: Skip. Report: "WORKFLOW.md up to date."
- **Same version, different content**: User customized. Preserve. Report: "WORKFLOW.md has local customizations — preserved."
- **Plugin version higher, no customizations**: Update silently. Report: "WORKFLOW.md updated (v`<old>` → v`<new>`)."
- **Plugin version higher, with customizations**: Present both to user for merge. Report: "WORKFLOW.md needs merge."
- **No `template-version` (legacy)**: Treat as version 0.

If the plugin template file does not exist at `${CLAUDE_PLUGIN_ROOT}/templates/workflow.md`, report an error and suggest reinstalling the plugin.

### 3. Install/Update CONSTITUTION.md (with section-level merge)

1. If `openspec/CONSTITUTION.md` does **not** exist, create it from the plugin template with `template-version` frontmatter:
   ```markdown
   ---
   template-version: 1
   ---
   # Project Constitution

   > Run `/opsx:bootstrap` to generate project-specific rules from your codebase.
   ```

2. If `openspec/CONSTITUTION.md` **exists**, compare `template-version` fields:
   - **Same version**: Skip. Report: "CONSTITUTION.md up to date."
   - **Plugin version higher**: Compare section headings (e.g., `## Tech Stack`, `## Architecture Rules`) between the template and the local file. For each section in the template that is missing from the local file, offer to generate it interactively (read codebase for context, propose content, let user review). Preserve all existing sections and their content. Update `template-version` after merge. Report: "CONSTITUTION.md — N new sections offered."
   - **No `template-version` (legacy)**: Treat as version 0.

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
