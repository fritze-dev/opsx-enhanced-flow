## Review: Custom Actions

### Summary

| Dimension | Status |
|-----------|--------|
| Tasks | 4/4 complete |
| Requirements | 8/8 verified |
| Scenarios | 10/10 covered |
| Scope | Clean — 0 untraced files |

### Task-Diff Mapping

| Task | Diff Evidence |
|------|--------------|
| 1.1. CONSTITUTION.md Architecture Rules | `openspec/CONSTITUTION.md` line 15: "4 actions: init, propose, apply, finalize" changed to "4 built-in actions (init, propose, apply, finalize) + consumer-defined custom actions" |
| 2.1. SKILL.md Step 1 dynamic validation | `src/skills/workflow/SKILL.md` Step 1: hardcoded action list replaced with `actions` array from WORKFLOW.md frontmatter + fallback to built-in actions |
| 2.2. SKILL.md Step 5 custom action dispatch | `src/skills/workflow/SKILL.md` Step 5: new "Custom Action — Direct Execution" block added after `init` dispatch |
| 2.3. Consumer template comment | `src/templates/workflow.md`: YAML comment added after `actions` line explaining custom action usage |

### Requirement Verification

| Requirement | Spec | Status |
|-------------|------|--------|
| Inline Action Definitions | workflow-contract | PASS — SKILL.md now validates against `actions` array and dispatches custom actions via generic fallback |
| Router Dispatch Pattern | workflow-contract | PASS — Step 1 validates against `actions` array, Step 5 has generic fallback for custom actions, fallback to built-in list when WORKFLOW.md missing |
| WORKFLOW.md Pipeline Orchestration | workflow-contract | PASS — `actions` array semantics preserved, no pipeline changes |
| Router + Actions Layer | three-layer-architecture | PASS — CONSTITUTION.md updated to reflect "4 built-in actions + consumer-defined custom actions" |
| Layer Separation | three-layer-architecture | PASS — custom actions are defined in WORKFLOW.md, no router modification needed to add them |
| Constitution Layer | three-layer-architecture | PASS — Architecture Rules updated, no structural changes |
| Schema Layer | three-layer-architecture | PASS — no changes to pipeline or Smart Templates |
| Automation Configuration | workflow-contract | PASS — not affected by this change |

### Scenario Coverage

| Scenario | Status |
|----------|--------|
| Router executes custom action as sub-agent (workflow-contract) | PASS — Step 5 generic fallback reads `## Action: <name>` and executes directly |
| Actions are not pipeline steps (workflow-contract) | PASS — pipeline array unchanged, actions and pipeline remain separate |
| Router dispatches custom action via generic fallback (workflow-contract) | PASS — Step 5 validates action, reads instruction, executes directly |
| Router rejects action not in actions array (workflow-contract) | PASS — Step 1 validates against `actions` array, lists available actions if unrecognized |
| Router dispatches to custom actions (three-layer-architecture) | PASS — generic fallback block handles any non-built-in action |
| Adding a custom action does not require router changes (three-layer-architecture) | PASS — consumer adds to `actions` array + `## Action:` section, no SKILL.md changes needed |
| Custom action without body section (workflow-contract edge case) | PASS — Step 3 of generic fallback: "If the `## Action: <name>` section is missing: report the error and stop" |
| Router detects change from branch (workflow-contract) | PASS — unchanged, not affected |
| Router dispatches propose to pipeline traversal (workflow-contract) | PASS — unchanged, not affected |
| Router dispatches apply to sub-agent (workflow-contract) | PASS — unchanged, not affected |

### Design Adherence

| Decision | Adherence |
|----------|-----------|
| Generic fallback in Step 5 rather than refactoring all 4 actions | PASS — fallback block added after `init`, does not modify existing dispatch blocks |
| Execute instruction directly instead of forcing sub-agent | PASS — instruction says "the agent decides whether to handle inline or spawn a sub-agent" |
| Custom actions go through change context detection | PASS — no skip added for custom actions in Step 3 |
| Validate against `actions` array, fall back to built-in list if WORKFLOW.md missing | PASS — Step 1 reads array from WORKFLOW.md, falls back to built-in actions |

### Scope Control

All changed files trace to implementation tasks:
- `openspec/CONSTITUTION.md` — Task 1.1
- `src/skills/workflow/SKILL.md` — Tasks 2.1, 2.2
- `src/templates/workflow.md` — Task 2.3
- `openspec/changes/2026-04-10-custom-actions/tasks.md` — progress tracking

No untraced files. Spec changes (`openspec/specs/workflow-contract/spec.md`, `openspec/specs/three-layer-architecture/spec.md`) were made during the propose phase, not during apply.

### Preflight Cross-Check

The preflight identified one action item: "Update CONSTITUTION.md Architecture Rules line referencing '4 actions' during implementation." This was addressed by Task 1.1. All side-effect assessments remain valid — no regressions detected.

### Findings

#### CRITICAL

(none)

#### WARNING

(none)

#### SUGGESTION

(none)

### Verdict

**PASS**
