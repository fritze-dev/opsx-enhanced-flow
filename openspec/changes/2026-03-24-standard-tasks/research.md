# Research: Standard-Tasks — Trackbare Post-Implementation-Schritte

## 1. Current State

**Affected files:**
- `openspec/constitution.md` — Lines 36: Post-archive conventions defined as prose ("version bump → changelog → push → plugin update")
- `openspec/schemas/opsx-enhanced/schema.yaml` — Lines 193-218: Task instruction with "Do NOT include sync or archive as tasks" rule; Lines 220-231: Apply instruction with post-apply workflow guidance
- `openspec/schemas/opsx-enhanced/templates/tasks.md` — 3-section structure (Foundation, Implementation, QA Loop)

**How tasks flow through the system:**
1. `/opsx:continue` or `/opsx:ff` reads schema task instruction + template → generates `tasks.md`
2. `/opsx:apply` reads `tasks.md`, works through `- [ ]` checkboxes sequentially
3. Post-apply: user manually invokes `/opsx:verify` → `/opsx:archive` → `/opsx:changelog` → `/opsx:docs` → push

**Constitution reading pattern:** Skills like `/opsx:preflight` and `/opsx:discover` already read `openspec/constitution.md` as a first step. The `config.yaml` context field points agents to the constitution.

**Relevant specs (verified current):**
- `task-implementation` — Defines apply behavior, checkbox parsing, progress tracking. No mention of post-implementation task sections.
- `release-workflow` — Defines post-archive auto-bump, next steps display, changelog generation. These are the conventions currently defined as prose.
- `artifact-pipeline` — Defines 6-stage pipeline, apply gate, schema-owned workflow rules. Tasks instruction includes DoD rule and post-apply sequence.

**Spec staleness check:** All three specs align with the current codebase. No drift detected.

## 2. External Research

Not applicable — this is an internal workflow enhancement with no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Constitution `## Standard Tasks` + schema instruction update** (proposed in issue) | Pragmatic, project-specific, no schema restructuring, agent reads constitution via existing pattern | Soft enforcement (agent compliance), no machine-readable format |
| **B: `config.yaml` `standardTasks` key** | Structured, machine-readable, could be validated by CLI | Requires schema support for new config key, OpenSpec CLI changes, overkill for current need |
| **C: Hardcoded in schema task instruction** | Always present, no constitution dependency | Not project-specific, every project using the schema gets the same tasks |

**Recommendation:** Approach A. It leverages the existing constitution-reading pattern, requires no CLI changes, and is immediately implementable. The issue's own proposal aligns with this.

## 4. Risks & Constraints

- **Soft enforcement:** Apply skill processes all `- [ ]` checkboxes without section awareness. The schema apply instruction must explicitly tell the agent to skip Standard Tasks (section 4). This is consistent with how all existing conventions work (agent reads instructions, follows them).
- **Progress counting:** Standard tasks will be included in "N/M tasks complete" counts. This is actually desirable — archive already checks for incomplete tasks, and the count reflects the full workflow state.
- **Skill immutability:** Per constitution line 17, skills MUST NOT be modified for project-specific behavior. All changes go through constitution + schema — no skill files touched.
- **Backward compatibility:** Archived `tasks.md` files are historical records, unaffected. Only new changes generated after this implementation will include the standard tasks section.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 4 files: constitution, schema.yaml (2 spots), template |
| Behavior | Clear | Standard tasks copied verbatim from constitution into tasks.md; not executed by apply |
| Data Model | Clear | No new data — extends existing markdown checkbox format |
| UX | Clear | New section 4 in tasks.md, visible in progress counts |
| Integration | Clear | Leverages existing constitution-reading and task-generation patterns |
| Edge Cases | Clear | Projects without standard tasks: section omitted. Doc-only changes: standard tasks still apply. |
| Constraints | Clear | Skill immutability respected. No CLI changes needed. |
| Terminology | Clear | "Standard Tasks" as defined in issue #12 |
| Non-Functional | Clear | No performance impact — one additional section in a markdown file |

All categories Clear — no open questions needed.

## 6. Open Questions

All categories are Clear. No questions required.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Constitution-based standard tasks (Approach A) | Leverages existing patterns, project-specific, no CLI changes | config.yaml key (overkill), hardcoded in schema (not project-specific) |
| 2 | Literal checkbox format in constitution | Zero ambiguity — agent copies verbatim, project owner controls exact wording | Description format requiring agent interpretation |
| 3 | Apply skill skips section 4 via instruction | Consistent with existing soft enforcement pattern (e.g., "Do NOT include sync as tasks") | Hardcoded section parsing in skill (violates skill immutability) |
| 4 | Standard tasks counted in progress totals | Reflects full workflow state; archive's incomplete-task warning acts as safety net | Separate counting (over-engineering for current need) |
