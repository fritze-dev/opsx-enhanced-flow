# Technical Design: Standard-Tasks

## Context

Post-implementation workflow steps (archive, changelog, docs, push, plugin update) are currently defined as prose in `openspec/constitution.md` line 36. The agent reads these conventions but they're not tracked as checkboxes, can be forgotten in long sessions, and leave no audit trail.

This change introduces a two-layer mechanism: universal post-implementation steps are hardcoded in the schema template (available to all opsx-enhanced projects), while the constitution can add project-specific extras. Both are included in every generated `tasks.md` as a final section after the QA Loop. Four files are affected; no skills are modified (skill immutability respected).

## Architecture & Components

### Files affected

| File | Change | Purpose |
|------|--------|---------|
| `openspec/schemas/opsx-enhanced/templates/tasks.md` | Add section 4 with universal standard tasks | Universal post-implementation steps for all projects |
| `openspec/schemas/opsx-enhanced/schema.yaml` (tasks instruction) | Add standard tasks directive; clarify sync/archive exclusion rule | Tell agent to include template steps + constitution extras |
| `openspec/schemas/opsx-enhanced/schema.yaml` (apply instruction) | Add scope clarification | Tell agent to skip standard tasks during apply |
| `openspec/constitution.md` | Add `## Standard Tasks` with project-specific extras; trim convention prose | Project-specific additions (plugin update) appended to universal steps |

### Data flow

```
Schema template (section 4: universal standard tasks)
        │
        ▼
Task generation (/opsx:continue or /opsx:ff)
  reads template → includes universal steps
  reads constitution → appends project-specific extras (if defined)
        │
        ▼
tasks.md (section 4: Standard Tasks Post-Implementation)
  = universal steps + constitution extras
        │
        ├──▶ /opsx:apply → processes sections 1-3 only, skips section 4
        │
        └──▶ /opsx:archive → warns if section 4 has unchecked items
```

### Universal standard tasks (in schema template)

```markdown
- [ ] Archive change (`/opsx:archive`)
- [ ] Generate changelog (`/opsx:changelog`)
- [ ] Generate/update docs (`/opsx:docs`)
- [ ] Commit and push to remote
```

### Project-specific extras (in constitution `## Standard Tasks`)

```markdown
- [ ] Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
```

### Convention prose trimming

The existing "Post-archive version bump" convention (line 36) currently mixes two concerns:
1. **Auto-bump mechanism** — how archive handles version incrementing (keep as convention)
2. **Next-steps workflow** — what to do after archive (moves to Standard Tasks)

The convention will be trimmed to retain only the auto-bump mechanism and version sync behavior. The "show next steps" and workflow sequence part is replaced by the Standard Tasks section.

## Goals & Success Metrics

- **M1**: Every newly generated `tasks.md` contains a "Standard Tasks (Post-Implementation)" section with universal steps from the template plus any constitution extras
- **M2**: `/opsx:apply` processes only sections 1-3 (Foundation, Implementation, QA Loop) and leaves section 4 untouched
- **M3**: Schema task instruction includes the standard tasks directive text
- **M4**: Schema apply instruction includes the scope clarification text

## Non-Goals

- Machine-readable task format in config.yaml (overkill)
- Section-aware progress counting that separates implementation vs standard tasks
- Consolidated Definition of Done checklist (#36)
- Auto GitHub Releases (#39)
- Skill file modifications

## Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Two-layer: schema (universal) + constitution (extras) | Universal steps available to all projects; project-specific extras stay flexible; no CLI changes | All in constitution (redundant across projects), all in schema (no project-specific steps possible) |
| Literal checkbox format | Zero ambiguity — template provides universal steps, constitution extras copied verbatim | Description format requiring agent interpretation |
| Apply skips via instruction | Consistent with existing soft enforcement (e.g., baseline spec exclusion) | Hardcoded section parsing in skill (violates immutability) |
| Standard tasks in progress totals | Reflects full workflow state; archive incomplete-task warning is the safety net | Separate counting (adds complexity for minimal benefit) |
| Template placeholder section | Makes section discoverable; gives agent clear structural anchor | Dynamic-only insertion (no template guidance) |

## Risks & Trade-offs

- **Soft enforcement** → The apply instruction tells the agent to skip standard tasks, but there's no hard gate. Mitigation: This is consistent with all existing enforcement in the system (e.g., "Do NOT include sync as tasks" is also instruction-based).
- **Progress count includes standard tasks** → Users see "5/8 complete" after apply finishes. Mitigation: This is actually desirable — it reflects the full workflow. Archive's incomplete-task warning catches forgotten steps.

## Open Questions

No open questions.

## Assumptions

<!-- ASSUMPTION: The agent reliably reads the constitution during task generation because config.yaml context already directs it there -->
<!-- ASSUMPTION: Section-based task categorization (by ## heading) is sufficient for the agent to distinguish implementation from standard tasks -->
