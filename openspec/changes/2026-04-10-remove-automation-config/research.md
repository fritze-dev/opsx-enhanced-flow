# Research: Remove Automation Config

## 1. Current State

The `automation` section in WORKFLOW.md frontmatter configures CI-triggered finalize via GitHub Actions. The pipeline.yml workflow triggers on `pull_request_review` (approved), reads `automation.post_approval` config, and executes `/opsx:workflow finalize` automatically.

**Affected files (10 locations):**

| File | Content |
|------|---------|
| `openspec/WORKFLOW.md` (lines 17-23) | Active `automation:` frontmatter block |
| `src/templates/workflow.md` (lines 17-23) | Commented-out `automation:` template block |
| `openspec/specs/workflow-contract/spec.md` (lines 168-182) | "Automation Configuration" requirement + 2 scenarios |
| `src/skills/workflow/SKILL.md` (line 22) | `automation` in frontmatter extraction list |
| `.github/workflows/pipeline.yml` (entire file) | GitHub Actions workflow implementing CI finalize |
| `docs/capabilities/workflow-contract.md` (lines 27, 57-59) | Feature + behavior documentation |
| `docs/README.md` (lines 8-9) | "automation config" in architecture description |
| `README.md` (lines 71, 176, 222) | CLI examples + tree structure references |
| `openspec/CONSTITUTION.md` (line 42) | Template sync convention mentioning `automation` |
| `openspec/changes/2026-04-09-skill-consolidation/` | Historical change artifacts (design, proposal, research) |

## 2. External Research

No external dependencies. The automation feature uses:
- GitHub Actions (`pull_request_review` event)
- `anthropics/claude-code-action@v1` (Claude Code GitHub Action)
- GitHub labels for state tracking

All of these are external to the plugin itself and only relevant when CI automation is active.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Remove all automation references | Clean surface area, simpler mental model, no dead code | Consumers who set up CI automation would need to re-add it |
| B: Remove active config, keep spec as "deprecated" | Backward compatibility signal | Adds complexity, dead spec requirement |
| C: Move to optional addon/extension | Keeps functionality available | Over-engineering for a feature nobody uses |

**Recommendation: Approach A** — clean removal. The feature was never adopted by consumers and adds unnecessary conceptual overhead.

## 4. Risks & Constraints

- **No breaking change for consumers**: The automation section was commented out in the consumer template, meaning no consumer project has active automation config.
- **Historical change artifacts**: References in `openspec/changes/2026-04-09-skill-consolidation/` are historical records. These should NOT be edited — they document what was true at the time of that change.
- **CI workflow deletion**: Removing `.github/workflows/pipeline.yml` means the project itself loses CI finalize. Since local finalize works reliably, this is acceptable.
- **Spec modification**: The workflow-contract spec loses a requirement, reducing its scope slightly. The spec remains substantial with its other requirements.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Issue #100 lists exactly what to remove |
| Behavior | Clear | Remove config + CI workflow, local finalize unchanged |
| Data Model | Clear | YAML frontmatter field removal |
| UX | Clear | No user-facing command changes |
| Integration | Clear | Only CI integration removed |
| Edge Cases | Clear | Consumer template already had it commented out |
| Constraints | Clear | Don't edit historical change artifacts |
| Terminology | Clear | "automation" term removed from docs |
| Non-Functional | Clear | Reduces complexity |

## 6. Open Questions

All categories are Clear — no questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Clean removal (Approach A) | Simplest, no consumers depend on it | Keep as deprecated, move to extension |
| 2 | Do not edit historical change artifacts | They document what was true at that time | Edit them for consistency |
