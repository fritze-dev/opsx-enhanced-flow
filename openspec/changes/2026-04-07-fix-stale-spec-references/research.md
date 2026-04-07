# Research: Fix Stale Spec References

## 1. Current State

PR #77 ("Eliminate Delta-Specs, Sync & Archive") removed `config.yaml`, `schema.yaml`, and the `openspec/schemas/` directory. However, ~57 references in capability specs still point to these eliminated paths.

**Stale reference categories found via grep:**

| Category | Count | Affected Specs |
|----------|-------|----------------|
| `config.yaml` → `WORKFLOW.md` | 18 | decision-docs, user-docs, release-workflow, constitution-management, interactive-discovery, architecture-docs |
| `openspec/schemas/…/templates/` → `openspec/templates/` | 14 | decision-docs, user-docs, constitution-management, architecture-docs, interactive-discovery |
| `openspec/constitution.md` → `CONSTITUTION.md` | 20 | constitution-management (11), architecture-docs (5), project-bootstrap (3), release-workflow (1) |
| `schema.yaml` → `WORKFLOW.md` | 2 | constitution-management, task-implementation |
| `.claude-plugin/plugin.json` → `src/.claude-plugin/plugin.json` | 3 | release-workflow (auto-bump requirement) |

**Intentional legacy references (NOT to be changed):**
- `workflow-contract/spec.md` — describes WORKFLOW.md as replacement for config.yaml/schema.yaml (correct historical context)
- `artifact-pipeline/spec.md` — user story motivation text (correct context)
- `project-setup/spec.md` — migration detection scenarios (must reference old paths)

## 2. External Research

N/A — purely internal spec consistency fix.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| Mechanical find-and-replace per category | Fast, low risk, easy to verify | Must be careful not to change intentional legacy references |
| Manual line-by-line review | Highest precision | Slower, error-prone for 57 edits |

**Recommended:** Mechanical replacement with per-file exclusion lists for legacy-context references.

## 4. Risks & Constraints

- **False positives:** workflow-contract, artifact-pipeline, and project-setup specs contain intentional legacy references that must NOT be changed.
- **Semantic changes:** constitution-management spec line 69 uses "config.yaml workflow rules" — needs semantic rewrite to "WORKFLOW.md context field", not just path swap.
- **Plugin.json path:** The auto-bump requirement incorrectly references `.claude-plugin/plugin.json` (doesn't exist) — must change to `src/.claude-plugin/plugin.json`.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 8 specs need fixes, 3 specs intentionally excluded |
| Behavior | Clear | No behavioral changes — spec text corrections only |
| Data Model | Clear | N/A — no data model involved |
| UX | Clear | N/A — no user-facing changes |
| Integration | Clear | No cross-spec dependency issues |
| Edge Cases | Clear | Legacy migration references in project-setup must be preserved |
| Constraints | Clear | Must not break intentional legacy references |
| Terminology | Clear | `config.yaml` → `WORKFLOW.md`, `schemas/` → `templates/`, `constitution.md` → `CONSTITUTION.md` |
| Non-Functional | Clear | N/A |

## 6. Open Questions

All categories are Clear. No questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Mechanical replacement with exclusion list | All changes are well-defined path swaps; the issue documents every instance | Manual line-by-line editing (slower, same result) |
| 2 | Preserve legacy references in workflow-contract, artifact-pipeline, project-setup | These specs describe the migration FROM old paths — changing them would be incorrect | Change everything uniformly (would break migration context) |
| 3 | Rewrite constitution-management "config.yaml workflow rules" semantically | The concept changed from "config.yaml workflow rules" to "WORKFLOW.md context field" — not just a path swap | Simple path swap (would be semantically wrong) |
