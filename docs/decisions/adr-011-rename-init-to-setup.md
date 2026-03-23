# ADR-011: Rename Init to Setup

## Status

Accepted — 2026-03-23

## Context

The `init` skill name conflicts with Claude Code's built-in `/init` command, which creates `CLAUDE.md`. This conflict makes `/opsx:init` unavailable to users — while all other `/opsx:*` skills work fine, only `init` is affected. The skill lives at `skills/init/SKILL.md` with frontmatter `name: init` and is referenced in 8 baseline specs, 6 other skill files, the project README, schema README, docs index, and 5 capability docs — approximately 50 references total across active files. Research confirmed this is a pure rename with no logic, behavior, or schema changes required, and that `setup` is the most descriptive alternative (as opposed to `install`, which is too narrow for a skill that does more than installation). Historical records — archives, CHANGELOG, and ADRs — must remain unchanged because they document what was true at the time of their creation.

## Decision

1. **Use `setup` as the new skill name** — Descriptive, avoids the conflict with the built-in `/init` command, and was proposed in the originating issue #31.
2. **Leave archive files unchanged** — Historical records should reflect the state at the time of creation; rewriting them would distort the project history.
3. **Leave CHANGELOG unchanged** — CHANGELOG entries describe what happened at the time; rewriting them would be misleading.
4. **Leave ADRs unchanged** — Decision records are point-in-time documents; updating them would lose historical context.
5. **Use `git mv` for the directory rename** — Preserves git history for the skill file, maintaining traceability of changes over time.

## Alternatives Considered

- Use `install` as the new name (rejected: too narrow — the skill does more than install)
- Keep `init` and request an upstream fix from the Claude Code team (rejected: depends on external team with indefinite timeline)
- Update all files including archives, CHANGELOG, and ADRs (rejected: rewrites history, distorts point-in-time records)
- Use `rm` + `mkdir` + `cp` instead of `git mv` (rejected: loses git history for the file)

## Consequences

### Positive

- `/opsx:setup` is available to users without conflict with the built-in `/init` command
- Git history is preserved through `git mv`, maintaining full traceability
- Historical records remain accurate, reflecting the state at the time they were created
- All active references are updated consistently across specs, skills, and docs

### Negative

- Breaking change for existing users who have memorized `/opsx:init` (mitigated: the README and docs guide users to the new name, and `/opsx:setup` is discoverable via the plugin system)
- Risk of missed references during the rename (mitigated: grep-based success metrics catch any remaining `/opsx:init` or `skills/init` references)

## References

- [Archive: rename-init-to-setup](../../openspec/changes/archive/2026-03-23-rename-init-to-setup/)
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [ADR-M001: Setup is model-invocable](adr-M001-init-model-invocable.md)
- [GitHub Issue #31](https://github.com/fritze-dev/opsx-enhanced-flow/issues/31)
