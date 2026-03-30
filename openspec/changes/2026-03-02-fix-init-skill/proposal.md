## Why

The `/opsx:init` skill — the entry point for new users — is completely broken. It cannot be invoked because `disable-model-invocation: true` hides it from Claude Code's skill discovery. Additionally, the init steps create duplicate skills that conflict with the plugin's own commands.

## What Changes

- Fix skill discovery so `/opsx:init` can be invoked manually
- Remove `openspec init --tools claude` step that creates 6 conflicting duplicate skills
- Add `mkdir -p` safety before file copy operations
- Update constitution to reflect that init is now model-invocable
- Reduce init from 7 steps to 6 steps (cleaner, no redundant initialization)

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `project-setup`: Fix `disable-model-invocation` flag, remove duplicate skill creation step, add directory safety, update step numbering

## Impact

- `skills/init/SKILL.md` — frontmatter fix + step restructuring
- `openspec/constitution.md` — line 18 update (remove init exception)
- No API changes, no dependency changes
- Backward compatible: init is idempotent, re-running is safe

## Scope & Boundaries

**In scope:**
- Fix the 3 bugs in init SKILL.md
- Update constitution to match new behavior

**Out of scope:**
- Changing other skills' `disable-model-invocation` settings
- Modifying the openspec CLI behavior
- Changing the plugin installation/marketplace flow
