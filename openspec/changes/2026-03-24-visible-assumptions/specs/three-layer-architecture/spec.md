## Assumptions

- The Claude Code plugin system discovers skills by scanning `skills/*/SKILL.md` files and uses YAML frontmatter for configuration. This is based on observed Claude Code behavior. <!-- ASSUMPTION: Skill discovery mechanism -->
- The `config.yaml` workflow rules mechanism reliably enforces constitution reading before skill execution. <!-- ASSUMPTION: Config enforcement -->
No further assumptions beyond those marked above.
