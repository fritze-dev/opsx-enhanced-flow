# Research: Fix Apply Baseline Edits

## 1. Current State

During `/opsx:apply`, the AI agent implements tasks from `tasks.md`. Nothing currently prevents tasks from including edits to baseline specs in `openspec/specs/`. The observed problem (issue #43): during `rename-init-to-setup`, both delta specs AND baseline specs were modified during apply — making the subsequent `/opsx:sync` redundant.

**Affected files:**

- `openspec/schemas/opsx-enhanced/schema.yaml` (lines 163–184) — task generation instruction. Already excludes sync/archive tasks but does NOT exclude baseline spec edits.
- `skills/apply/SKILL.md` — apply skill guardrails. No mention of baseline spec exclusion.
- `openspec/specs/task-implementation/spec.md` — task-implementation spec. No requirement about excluding spec files from implementation scope.

**Data flow (intended):**
```
delta spec (changes/<name>/specs/) → /opsx:sync → baseline spec (specs/<cap>/spec.md)
```

**Data flow (observed bug):**
```
tasks.md includes "update specs/..." → apply edits baseline directly → sync is redundant
```

## 2. External Research

N/A — this is an internal workflow concern with no external dependencies.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Add exclusion rule to schema task instruction only | Minimal change, single touch point | AI might still edit baselines during apply if task descriptions are ambiguous |
| B: Instruction + apply guardrail | Defense in depth — task gen excludes AND apply skill warns | Two files to change |
| C: B + spec requirement | Full traceability — requirement documents the rule formally | Three files to change (but all are small, surgical edits) |

**Recommendation: Approach C** — the instruction prevents bad tasks from being generated, the apply guardrail catches edge cases, and the spec documents the rule as a formal requirement.

## 4. Risks & Constraints

- **Low risk:** All changes are additive text in instructions/specs. No code logic changes.
- **Edge case:** Documentation-only changes where the "implementation" IS the spec. These are already handled — delta specs capture the changes, and sync applies them. The task instruction already says "For documentation-only changes, implementation sections may be empty."
- **No breaking changes:** Existing archived changes are unaffected.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Three files, additive text only |
| Behavior | Clear | Exclude baseline specs from task gen and apply scope |
| Data Model | Clear | No data model changes |
| UX | Clear | No user-facing changes — just prevents incorrect AI behavior |
| Integration | Clear | Schema instruction + apply skill + spec |
| Edge Cases | Clear | Doc-only changes already handled by existing instruction |
| Constraints | Clear | Must not break existing task generation for non-spec files |
| Terminology | Clear | "baseline specs" = `openspec/specs/`, "delta specs" = `openspec/changes/<name>/specs/` |
| Non-Functional | Clear | No performance or scaling implications |

## 7. Decisions

All categories are Clear — no open questions. Proceeding with Approach C.

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use Approach C (instruction + guardrail + spec) | Defense in depth with formal traceability | A (instruction only), B (instruction + guardrail) |
| 2 | Add to existing IMPORTANT block in schema.yaml | Keeps exclusion rules co-located | Separate instruction block |
| 3 | Add new requirement to task-implementation spec | Formally documents the baseline-spec exclusion rule | Only informal instruction |
