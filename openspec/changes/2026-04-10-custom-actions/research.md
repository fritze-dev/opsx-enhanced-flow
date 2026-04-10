# Research: Custom Actions

## 1. Current State

The router SKILL.md dispatches to 4 hardcoded actions: `init`, `propose`, `apply`, `finalize`. The dispatch logic in Step 5 has:
- `propose` — unique Pipeline Traversal pattern (iterates templates, generates artifacts, commits per step)
- `apply`, `finalize`, `init` — identical Sub-Agent Execution pattern (read artifacts, spawn sub-agent with instruction + requirements)

The `actions` array in WORKFLOW.md frontmatter (`actions: [init, propose, apply, finalize]`) is read by the router in Step 2 but only used descriptively — Step 1 hardcodes the valid action list, and Step 5 hardcodes dispatch per action.

Three specs explicitly constrain the system to 4 actions:
- **workflow-contract/spec.md** — "Inline Action Definitions" requirement: "The system SHALL support these actions: init, propose, apply, finalize."
- **workflow-contract/spec.md** — "Router Dispatch Pattern" requirement: "The router SHALL support 4 commands: init, propose, apply, finalize."
- **three-layer-architecture/spec.md** — "Router + Actions Layer" requirement: "The 4 commands are: init, propose, apply, finalize."

The `actions` frontmatter field is already documented in the workflow-contract spec (WORKFLOW.md Pipeline Orchestration requirement) as a structured config field, but its scope is limited to listing the 4 built-in actions.

## 2. External Research

N/A — this is an internal architecture extension. The design pattern (open action registry with fallback dispatch) is a standard plugin/hook pattern.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Generic fallback in router for unknown actions | Minimal change (~5 lines router, spec edits). Reuses existing Sub-Agent pattern. Consumer defines actions purely via WORKFLOW.md. | Router SKILL.md must be edited (but change is generic, not project-specific). Custom actions lack requirement links from SKILL.md. |
| B: Lifecycle hooks (pre/post-action) in WORKFLOW.md | No router Step 1/5 changes. Hooks wrap around existing actions. | Over-engineered for the use case. Adds a new concept (hooks) instead of reusing existing concept (actions). Consumer still can't define standalone actions. |
| C: Consumer wrapper skills that call /opsx:workflow internally | Zero plugin changes. | Breaks single-entry-point pattern. Consumer reinvents orchestration. |

**Selected: Approach A** — discussed and confirmed with user during planning.

## 4. Risks & Constraints

- **Router immutability rule**: CONSTITUTION.md states the router "MUST NOT be modified for project-specific behavior." The proposed change is generic (not project-specific) — it enables any consumer to define any action. This is analogous to the existing worktree/automation config handling.
- **No requirement links for custom actions**: Built-in actions get curated spec requirement links (Step 4 in SKILL.md). Custom actions don't have these — their instruction text in WORKFLOW.md must be self-contained. This is acceptable because custom actions are consumer-defined and don't have plugin-level specs.
- **Propose is special**: The `propose` action has unique Pipeline Traversal logic that cannot be generalized. Custom actions will always use the Sub-Agent Execution pattern (like apply/finalize/init).
- **Change context detection**: Custom actions will go through the same change context detection as apply/finalize (Step 3). This is correct — most custom actions need to know which change they operate on.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Open the `actions` array + generic dispatch fallback |
| Behavior | Clear | Custom actions use Sub-Agent pattern with instruction from WORKFLOW.md |
| Data Model | Clear | No new data model — reuses existing WORKFLOW.md frontmatter + body sections |
| UX | Clear | `/opsx:workflow <custom-action>` — same pattern as built-in actions |
| Integration | Clear | 3 specs need updates, router Step 1 + Step 5 need edits |
| Edge Cases | Clear | Missing instruction section, empty actions array, WORKFLOW.md fallback |
| Constraints | Clear | Router immutability satisfied (generic change, not project-specific) |
| Terminology | Clear | "Custom action" = any action in the `actions` array not in [init, propose, apply, finalize] |
| Non-Functional | Clear | No performance impact — one additional array lookup in Step 1 |

All categories Clear — no open questions.
