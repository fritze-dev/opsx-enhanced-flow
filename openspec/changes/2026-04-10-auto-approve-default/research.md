# Research: Auto-Approve as Default Behavior

## 1. Current State

`auto_approve` is defined in WORKFLOW.md frontmatter (line 15) as `# auto_approve: true` — commented out. The consumer template (`src/templates/workflow.md:15`) mirrors this. When absent or commented out, the pipeline pauses at every checkpoint:
- Design review (after design artifact)
- Preflight warnings acknowledgment
- Post-apply approval (after review.md PASS)

The setting is referenced in:
- **Spec:** `openspec/specs/workflow-contract/spec.md:24` — defined as optional boolean
- **Spec:** `openspec/specs/artifact-pipeline/spec.md:305` — "Propose as Single Entry Point" requirement references `auto_approve` for checkpoint behavior
- **Spec:** `openspec/specs/human-approval-gate/spec.md` — QA Loop with Mandatory Approval (no direct auto_approve reference; approval is always required)
- **Docs:** `docs/capabilities/human-approval-gate.md:29,63` — documents auto-approve skipping post-PASS pause
- **Docs:** `docs/capabilities/artifact-pipeline.md:18` — mentions auto_approve in WORKFLOW.md structure
- **SKILL.md:** `src/skills/workflow/SKILL.md:22` — listed as extracted frontmatter field

Key behavior: FAIL verdicts always stop regardless of `auto_approve`. The setting only skips pauses on PASS/success paths.

## 2. External Research

Not applicable — this is an internal configuration change.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Uncomment in WORKFLOW.md + template, update specs to say "defaults to true" | Minimal change, clear intent | Users who want checkpoints must explicitly opt out |
| B: Keep commented but change spec to say "absent defaults to true" | No file change needed for project | Confusing — commented-out line says `true` but behavior changes meaning |
| C: Uncomment only in project WORKFLOW.md, keep template commented | Project gets auto-approve, consumers keep opt-in | Inconsistent defaults between project and consumers |

**Recommended: Approach A** — uncomment in both files, update spec language to reflect the new default.

## 4. Risks & Constraints

- **Low risk:** FAIL always stops — the safety net is preserved
- **Design review checkpoint:** Constitution says "always pause after design for user alignment" — this is a constitutional requirement independent of `auto_approve`. Need to verify auto_approve doesn't override this.
- **Consumer impact:** Consumers using the template will get auto-approve on next init/update. This is a behavior change but opt-out is easy (`auto_approve: false`).
- **Template synchronization:** Constitution requires WORKFLOW.md and template to stay in sync for this field.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Two files to change, two specs to update, docs regenerated via finalize |
| Behavior | Clear | Uncomment = enable, FAIL still stops, design checkpoint is constitutional |
| Data Model | Clear | Single boolean field, already defined in specs |
| UX | Clear | Less friction for default flow, opt-out for cautious users |
| Integration | Clear | No external integrations affected |
| Edge Cases | Clear | FAIL always stops; design checkpoint is constitutional, not auto_approve-gated |
| Constraints | Clear | Template sync required per constitution |
| Terminology | Clear | `auto_approve` naming unchanged |
| Non-Functional | Clear | No performance or security implications |

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use Approach A: uncomment + update spec default | Clearest intent, consistent across project and consumers | B (confusing semantics), C (inconsistent) |
| 2 | Design review checkpoint stays mandatory regardless | Constitutional requirement, not auto_approve-gated | Making it auto_approve-gated (would violate constitution) |
