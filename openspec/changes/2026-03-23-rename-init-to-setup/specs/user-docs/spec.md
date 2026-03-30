## MODIFIED Requirements

No requirement-level changes. The only change is in the Assumptions section below.

## Edge Cases

No changes to edge cases.

## Assumptions

- Baseline specs in `openspec/specs/` are the source of truth for documentation generation. <!-- ASSUMPTION: Docs generated after sync -->
- Archived changes follow `YYYY-MM-DD-<feature-name>` naming under `openspec/changes/archive/`. <!-- ASSUMPTION: Archive naming enforced by archive skill -->
- The `initial-spec` archive is a bootstrap change whose proposal "Why" describes spec creation, not individual capability motivations. <!-- ASSUMPTION: Based on observed archive content -->
- Doc templates at `openspec/schemas/opsx-enhanced/templates/docs/` are available in consumer projects after `/opsx:setup` copies the schema. <!-- ASSUMPTION: Schema copy includes subdirectories -->
- Per-section maximum limits (Purpose max 3 sentences, Known Limitations max 5 bullets, etc.) are sufficient to prevent doc bloat without needing a priority-based section-dropping rule. <!-- ASSUMPTION: Based on observed doc lengths -- no capability doc exceeds 1.3 pages even with all sections -->
