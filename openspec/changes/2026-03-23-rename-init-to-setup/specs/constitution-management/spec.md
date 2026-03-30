## MODIFIED Requirements

No requirement-level changes. The only change is in the Assumptions section below.

## Edge Cases

No changes to edge cases.

## Assumptions

- The constitution file is always located at `openspec/constitution.md` relative to the project root. <!-- ASSUMPTION: Fixed path convention established by the plugin -->
- The `config.yaml` workflow rules are configured during `/opsx:setup` to reference the constitution. <!-- ASSUMPTION: Setup skill sets up the config correctly -->
- Constitution updates during design are immediately visible to subsequent skill invocations within the same session. <!-- ASSUMPTION: File system writes are synchronous and the agent re-reads context files -->
