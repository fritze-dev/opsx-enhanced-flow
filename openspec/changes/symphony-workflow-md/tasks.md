# Implementation Tasks: Symphony WORKFLOW.md Repository Contract

## 1. Foundation: WORKFLOW.md Template

- [ ] 1.1. Create `WORKFLOW.md` template content for new projects — YAML front matter with `schema: opsx-enhanced`, commented `project.name` and `docs_language` fields, plus markdown body with English-enforcement rule and behavioral guidance placeholder
- [ ] 1.2. [P] Update `openspec/schemas/opsx-enhanced/templates/` to include `WORKFLOW.md` template (verify if a templates directory for init scaffolding exists, or document where init reads its template from in `skills/init/SKILL.md`)

## 2. Init Skill: WORKFLOW.md Generation

- [ ] 2.1. Update `skills/init/SKILL.md` Step 4 (create workflow config): change from creating `openspec/config.yaml` to creating `WORKFLOW.md` at the project root; keep `openspec/config.yaml` as a legacy fallback option with a note
- [ ] 2.2. Add Step 4b in `skills/init/SKILL.md`: detect legacy setup (has `openspec/config.yaml` + `openspec/constitution.md` but no `WORKFLOW.md`) and provide migration guidance — generate `WORKFLOW.md` merging existing content, inform user that legacy files are superseded but retained
- [ ] 2.3. Update Step 5 in `skills/init/SKILL.md` (constitution placeholder): skip if `WORKFLOW.md` was generated (constitution is now the WORKFLOW.md markdown body)
- [ ] 2.4. Update the `skills/init/SKILL.md` Output section: add `WORKFLOW.md` status to the reported summary

## 3. Config: Agent Context Routing

- [ ] 3.1. Update the generated `openspec/config.yaml` template in `skills/init/SKILL.md` — change the `context` field to instruct the agent to prefer `WORKFLOW.md` over `openspec/constitution.md`:

  ```yaml
  schema: opsx-enhanced

  # docs_language: English

  context: |
    If WORKFLOW.md exists at the project root, read it as the primary project workflow
    contract: parse the YAML front matter for settings, and use the markdown body as
    behavioral context. Apply template variables {{ change.name }} and {{ change.stage }}
    if an active change is present.
    If WORKFLOW.md is absent, fall back to openspec/constitution.md for project rules.
    All workflow artifacts (research, proposal, specs, design, preflight, tasks)
    must be written in English regardless of docs_language.
  ```

- [ ] 3.2. [P] Update the plugin's own `openspec/config.yaml` to use the new context routing instruction (so the opsx-enhanced-flow project itself uses WORKFLOW.md convention)

## 4. WORKFLOW.md for This Repository

- [ ] 4.1. Create `WORKFLOW.md` at the opsx-enhanced-flow project root with the generated template content, replacing `openspec/constitution.md` as the primary context source
- [ ] 4.2. Migrate content from `openspec/constitution.md` to the WORKFLOW.md markdown body (preserve all existing rules verbatim)
- [ ] 4.3. [P] Verify agent reads WORKFLOW.md correctly by running a quick `/opsx:new test-workflow-md-check` and confirming the agent acknowledges the WORKFLOW.md as its context source (then delete the test change)

## QA Loop

### Success Metrics (from design.md)
- [ ] PASS/FAIL: `WORKFLOW.md` exists at project root after fresh `/opsx:init` — verify with `test -f WORKFLOW.md`
- [ ] PASS/FAIL: Agent confirms it reads `WORKFLOW.md` as primary context when both `WORKFLOW.md` and `constitution.md` are present
- [ ] PASS/FAIL: Existing project without `WORKFLOW.md` behaves identically to pre-change behavior (no regression)
- [ ] PASS/FAIL: YAML front matter `schema`, `project.name`, and `docs_language` fields applied by agent
- [ ] PASS/FAIL: Template variable `{{ change.name }}` resolves to current change name during a spec skill invocation
- [ ] PASS/FAIL: `/opsx:init` on a legacy project (has `constitution.md`, no `WORKFLOW.md`) shows migration guidance and generates `WORKFLOW.md`

### Human Approval Gate
- [ ] Review generated `WORKFLOW.md` content for completeness and correctness
- [ ] Confirm backward compatibility: legacy project (constitution.md only) still works without regressions
- [ ] Confirm the migrated opsx-enhanced-flow project constitution reads correctly from `WORKFLOW.md`
- [ ] **HUMAN APPROVAL**: ✅ Approve to proceed to `/opsx:verify` and `/opsx:archive`
