# Pre-Flight Check: Symphony WORKFLOW.md Repository Contract

## A. Traceability Matrix

- [x] **WORKFLOW.md Repository Contract** (workflow-contract spec) → Scenario: "Agent reads WORKFLOW.md when present" → Agent Context Loader (config.yaml context field)
- [x] **WORKFLOW.md Repository Contract** (workflow-contract spec) → Scenario: "Fallback to constitution.md when WORKFLOW.md absent" → Agent Context Loader + init skill
- [x] **WORKFLOW.md Repository Contract** (workflow-contract spec) → Scenario: "WORKFLOW.md with YAML front matter only" → Agent Context Loader (front matter parser)
- [x] **WORKFLOW.md Repository Contract** (workflow-contract spec) → Scenario: "WORKFLOW.md with markdown body only" → Agent Context Loader (plain context mode)
- [x] **WORKFLOW.md YAML Front Matter Schema** (workflow-contract spec) → Scenarios: "Front matter sets schema reference", "project name", "unknown keys ignored", "malformed YAML fallback" → Agent YAML parser
- [x] **WORKFLOW.md Prompt Template Variables** (workflow-contract spec) → Scenarios: "variable resolves", "unavailable variable empty string", "unknown variable left as-is" → Template substitution component
- [x] **Install OpenSpec and Schema** (project-setup modified spec) → Scenario: "First-time project initialization generates WORKFLOW.md" → `/opsx:init` skill
- [x] **Install OpenSpec and Schema** (project-setup modified spec) → Scenario: "Idempotent re-initialization preserves WORKFLOW.md" → `/opsx:init` skill
- [x] **Install OpenSpec and Schema** (project-setup modified spec) → Scenario: "Legacy project without WORKFLOW.md migrated" → `/opsx:init` skill
- [x] **Install OpenSpec and Schema** (project-setup modified spec) → Scenario: "WORKFLOW.md generated from template, not copied" → `/opsx:init` skill + schema templates

## B. Gap Analysis

- **[No gap]** Backward compatibility: fallback to `constitution.md` is specified in both the spec (workflow-contract) and the design. Covered.
- **[No gap]** Empty WORKFLOW.md: covered under Edge Cases in the workflow-contract spec.
- **[No gap]** Malformed YAML: spec requires a parse warning + fallback to plain-body mode.
- **[Minor gap]** The project-setup spec does not explicitly specify how `/opsx:init` populates `project.name` in WORKFLOW.md front matter (auto-detect vs. placeholder). Noted as Open Question #1 in design. **Acceptable for roadmap stage** — implementation will resolve this.
- **[Minor gap]** The design notes that `openspec/schemas/opsx-enhanced/` template files may need updating but does not specify exactly which files. **Acceptable for roadmap stage** — implementation will identify the correct templates.
- **[No gap]** Both `constitution.md` and `WORKFLOW.md` present simultaneously: covered in workflow-contract spec Edge Cases.

## C. Side-Effect Analysis

- **`openspec/config.yaml`**: The `context` field update affects all skill invocations. No regression risk for projects without `WORKFLOW.md` (fallback is explicit). For projects with `WORKFLOW.md`, the behavior changes intentionally.
- **Existing skills**: No skill files are modified. Risk: zero.
- **OpenSpec CLI**: No CLI changes. The CLI is only used for schema/artifact management; WORKFLOW.md is purely agent-read.
- **`openspec/constitution.md`**: Superseded (not deleted). Existing projects keep working.
- **Schema templates in `openspec/schemas/opsx-enhanced/templates/`**: The `/opsx:init` skill reads these to scaffold new projects. Updating a template changes what new projects get on init; existing projects are unaffected.

## D. Assumption Audit

| # | Assumption | Source | Rating | Notes |
|---|-----------|--------|--------|-------|
| 1 | WORKFLOW.md placed at project root | workflow-contract spec | Acceptable Risk | Consistent with Symphony and standard conventions (README.md, CHANGELOG.md, etc.) |
| 2 | Agent parses YAML front matter natively | workflow-contract spec | Acceptable Risk | Claude reads files and processes YAML as part of its natural language capability; this is the same mechanism used for `openspec/config.yaml` today |
| 3 | Simple `{{ }}` substitution is sufficient | workflow-contract spec | Acceptable Risk | Covers the primary use cases; full Liquid is an enhancement path if needed |
| 4 | Agent reads files at paths specified in config.yaml context | design | Acceptable Risk | This mechanism is already proven — `constitution.md` is read via the same context field today |
| 5 | Updating config.yaml context field is sufficient to change agent behavior | design | Acceptable Risk | Verified by existing behavior: constitution.md is injected via this mechanism |
| 6 | Schema template files in `openspec/schemas/opsx-enhanced/` can be updated | design | Needs Clarification | Need to identify which template file generates the context field during `/opsx:init`. Implementation task: inspect `skills/init/SKILL.md` and `openspec/schemas/opsx-enhanced/templates/` to confirm. |

## E. Inconsistency Check

- **constitution.md vs. specs**: Constitution says "skills MUST NOT be modified for project-specific behavior". The project-setup spec MODIFIED requirement correctly routes the change through the init skill's template output and the config.yaml context field — no skill logic changes required. ✓ Consistent.
- **No ADR references in specs**: Specs do not reference any ADRs. ✓ Consistent.
- **RFC 2119 keywords**: All normative requirements in workflow-contract spec use SHALL/MUST correctly. ✓ Consistent.
- **Gherkin scenario format**: All scenarios use exactly 4 hashtags (`####`). ✓ Consistent.
- **Baseline spec format not used in delta**: Delta specs correctly use `## ADDED Requirements` and `## MODIFIED Requirements`. ✓ Consistent.

## F. Pre-Flight Verdict

**Status: READY for roadmap tracking. Implementation gate is OPEN.**

Blocking issues: None.
Clarification needed: One item (Assumption #6 — identify exact template files for `/opsx:init`) is a task-level implementation detail, not a design blocker. Acceptable to proceed to task creation.

This change is well-scoped with clear boundaries, full backward compatibility, no skill modifications, and a documented migration path. All requirements are traceable to scenarios and architecture components.
