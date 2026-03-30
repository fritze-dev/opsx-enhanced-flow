# Research: Fix init skill discovery and execution

## 1. Current State

The `/opsx:init` skill (`skills/init/SKILL.md`) is the one-time setup command that installs OpenSpec and the opsx-enhanced schema into a target project. It is the entry point for new users.

**Affected files:**
- `skills/init/SKILL.md` — the skill definition
- `openspec/constitution.md` — documents init as non-model-invocable (line 18)

**Current bugs:**
1. `disable-model-invocation: true` in frontmatter makes the skill invisible to `/opsx:init` — it cannot be invoked at all, not even manually.
2. Step 2 (`openspec init --tools claude`) creates 6 duplicate skills in `.claude/skills/` (`openspec-apply-change`, `openspec-archive-change`, etc.) that conflict with the plugin's `/opsx:*` skills.
3. Step 4 (`cp -r`) has no `mkdir -p` safety — could fail if directory doesn't exist yet.

**Verified by testing:**
- Plugin installed and enabled in test project (`divine`), cache correct, but `/opsx:init` not found while other `/opsx:*` skills (e.g. `/opsx:new`) work fine.
- `openspec schema init` works without prior `openspec init` — tested in clean `/tmp` directory.
- `openspec init --tools claude` creates `.claude/skills/openspec-*` that duplicate plugin functionality.

## 2. External Research

- `CLAUDE_PLUGIN_ROOT` is an official Claude Code environment variable (documented in plugins-reference.md). It resolves correctly in bash commands within skills. No issue there.
- `disable-model-invocation: true` is documented to prevent auto-invocation by Claude, but in practice it also prevents manual `/` invocation. This appears to be current Claude Code behavior (not just a documentation gap).

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Set `disable-model-invocation: false` | Skill becomes discoverable and invocable | Claude could theoretically auto-invoke it (mitigated by clear description) |
| Remove `openspec init --tools claude` step entirely | No duplicate skills, cleaner setup | Users don't get openspec's built-in skills (but they have the plugin's skills instead) |
| Change to `openspec init --tools none` | Might initialize base structure | Tested: creates nothing useful that `schema init` doesn't already handle |

## 4. Risks & Constraints

- Changing `disable-model-invocation` to `false` means Claude could auto-invoke the init skill. Low risk — the description clearly states "Run once per project" and the init steps are idempotent (`--force`, `mkdir -p`, skip-if-exists).
- Removing `openspec init --tools claude` means the `openspec/` base directory isn't created by that command. But `openspec schema init` creates it independently — verified.
- Constitution line 18 states "All skills are model-invocable except `init`" — needs updating to match new behavior.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 3 bugs in one SKILL.md + constitution update |
| Behavior | Clear | Tested all steps in isolation |
| Data Model | Clear | No data model changes |
| UX | Clear | Skill becomes invocable, no duplicate skills |
| Integration | Clear | CLAUDE_PLUGIN_ROOT works, openspec CLI tested |
| Edge Cases | Clear | mkdir -p handles missing dirs, --force handles re-runs |
| Constraints | Clear | Backward compatible — init is idempotent |
| Terminology | Clear | |
| Non-Functional | Clear | |

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Set `disable-model-invocation: false` | Only way to make skill discoverable in current Claude Code | None viable — the flag hides the skill completely |
| 2 | Remove `openspec init --tools claude` entirely | Creates duplicate skills; `schema init` handles directory creation | `--tools none` — tested, adds nothing useful |
| 3 | Add `mkdir -p` before `cp -r` | Safety for edge case where schema init fails silently | Rely on schema init alone — fragile |
| 4 | Update constitution line 18 | Must match actual behavior | Leave stale — confusing |
