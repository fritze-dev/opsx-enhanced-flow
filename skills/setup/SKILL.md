---
name: setup
description: Install the opsx-enhanced schema into the current project. Run once per project before using any other /opsx commands.
disable-model-invocation: false
---

# /opsx:setup — Project Setup

> Install the opsx-enhanced schema into the current project.

Run this **once per project** before using `/opsx:bootstrap` or any other `/opsx:*` commands.

## Instructions

Execute these steps in order. Report each result to the user. Stop on any failure and report what went wrong.

### 1. Copy schema files from plugin

```bash
mkdir -p openspec/schemas/opsx-enhanced
cp -r "${CLAUDE_PLUGIN_ROOT}/openspec/schemas/opsx-enhanced/." openspec/schemas/opsx-enhanced/
```

### 2. Create workflow config (skip if exists)

Only if `openspec/config.yaml` does **not** already exist, create it with this minimal bootstrap:

```yaml
schema: opsx-enhanced

# docs_language: English

context: |
  Always read and follow the project constitution at
  openspec/constitution.md before proceeding.
  All workflow artifacts (research, proposal, specs, design, preflight, tasks)
  must be written in English regardless of docs_language.
```

If it already exists, report: "config.yaml already exists — preserved."

### 3. Create constitution placeholder (skip if exists)

Only if `openspec/constitution.md` does **not** already exist, create it:

```markdown
# Project Constitution

> Run `/opsx:bootstrap` to generate project-specific rules from your codebase.
```

If it already exists, report: "constitution.md already exists — preserved."

### 4. Validate

Verify that `openspec/schemas/opsx-enhanced/schema.yaml` exists and is readable by reading its first few lines. If the file is missing or unreadable, tell the user to check the schema copy step.

## Output

Report a summary:
- Schema files installed at `openspec/schemas/opsx-enhanced/`
- Config status (created or preserved)
- Constitution status (created or preserved)
- Suggest: "Run `/opsx:bootstrap` to scan your codebase and generate the project constitution."

Do not run `/opsx:bootstrap` automatically — let the user decide when to proceed.
