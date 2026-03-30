## MODIFIED Requirements

No requirement-level changes. The only change is in the Edge Cases section below.

## Edge Cases

- If the project has no source code files (empty repository), bootstrap SHALL generate a minimal constitution with placeholder sections and inform the user to update it manually.
- If the codebase uses multiple languages or conflicting conventions, the constitution SHALL document the primary patterns and note the variations as exceptions.
- If `openspec/constitution.md` exists but `openspec/specs/` is empty, bootstrap SHALL treat this as a partial first-run and skip constitution generation while proceeding to initial change creation.
- If the OpenSpec CLI is not installed when bootstrap is invoked, bootstrap SHALL instruct the user to run `/opsx:setup` first.
- If the project has an extremely deep directory structure, the scan SHALL use reasonable depth limits to avoid performance issues.

## Assumptions

No assumptions changed.
