---
name: init
description: Install OpenSpec and the opsx-enhanced schema into the current project. Run once per project before using any other /opsx commands.
disable-model-invocation: false
---

# /opsx:init — Project Setup

> Install OpenSpec and the opsx-enhanced schema into the current project.

Run this **once per project** before using `/opsx:bootstrap` or any other `/opsx:*` commands.

## Instructions

Execute these steps in order. Report each result to the user. Stop on any failure and report what went wrong.

### 1. Check OpenSpec CLI

```bash
openspec --version
```

**If the command succeeds:** Report the version and continue.

**If the command fails (not found):** Install it automatically:

1. Check that `npm` is available:
   ```bash
   npm --version
   ```
   If `npm` is not found either, **stop** and tell the user:
   > OpenSpec CLI requires Node.js. Install Node.js (which includes npm) from https://nodejs.org, then run `/opsx:init` again.

2. Install OpenSpec CLI with a pinned compatible version:
   ```bash
   npm install -g @fission-ai/openspec@^1.2.0
   ```

3. If the install fails (e.g., permission denied), **stop** and tell the user:
   > OpenSpec CLI installation failed. This is usually a permissions issue. Try one of:
   > - `sudo npm install -g @fission-ai/openspec@^1.2.0`
   > - Configure npm to use a local prefix: `npm config set prefix ~/.npm-global` and add `~/.npm-global/bin` to your PATH

4. Verify the installation succeeded:
   ```bash
   openspec --version
   ```

### 2. Register the schema

```bash
openspec schema init opsx-enhanced --force
```

### 3. Copy schema files from plugin

```bash
mkdir -p openspec/schemas/opsx-enhanced
cp -r "${CLAUDE_PLUGIN_ROOT}/openspec/schemas/opsx-enhanced/." openspec/schemas/opsx-enhanced/
```

### 4. Create workflow config (skip if exists)

Only if `openspec/config.yaml` does **not** already exist, create it with this minimal bootstrap:

```yaml
schema: opsx-enhanced

context: |
  Always read and follow the project constitution at
  openspec/constitution.md before proceeding.
```

If it already exists, report: "config.yaml already exists — preserved."

### 5. Create constitution placeholder (skip if exists)

Only if `openspec/constitution.md` does **not** already exist, create it:

```markdown
# Project Constitution

> Run `/opsx:bootstrap` to generate project-specific rules from your codebase.
```

If it already exists, report: "constitution.md already exists — preserved."

### 6. Validate

```bash
openspec schema validate opsx-enhanced
```

If validation fails, tell the user to check `openspec/schemas/opsx-enhanced/schema.yaml`.

## Output

Report a summary:
- OpenSpec CLI version (installed or already present)
- Schema installed and validated
- Config status (created or preserved)
- Constitution status (created or preserved)
- Suggest: "Run `/opsx:bootstrap` to scan your codebase and generate the project constitution."

Do not run `/opsx:bootstrap` automatically — let the user decide when to proceed.
