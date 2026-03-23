# Research: Fix ADR Reference Quality

## 1. Current State

### Root Causes Found During ADR Audit (2026-03-23)

After generating 12 consolidated ADRs with the new incremental docs system, an audit revealed three categories of reference quality issues:

1. **Broken spec links**: ADR-001 referenced `openspec/specs/docs-generation/spec.md` which no longer exists — it was split into `user-docs`, `architecture-docs`, and `decision-docs` by the doc-ecosystem change. The SKILL.md has no validation step to check that spec links point to existing files.

2. **Wrong GitHub URL format**: 3 ADRs (006, 007, 012) used `github.com/robinfritze/` instead of `github.com/fritze-dev/`. The agent copied URLs from archive content where the wrong org was used. No URL validation or normalization in the skill.

3. **Missing cross-references**: 6 ADRs lacked back-references to thematically related ADRs. For example, ADR-003 (Documentation Ecosystem) didn't reference ADR-012 (Incremental Docs Generation) which supersedes its regeneration strategy. No guidance in SKILL.md about adding cross-references to related ADRs outside the same archive.

### Affected Code

- `skills/docs/SKILL.md` — Step 4 (ADR generation), References section instructions
- `openspec/specs/decision-docs/spec.md` — References determination requirement

## 2. External Research

No external dependencies. All fixes are additions to the SKILL.md prompt instructions.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| **A: Post-generation validation step** — After generating each ADR, verify all spec links exist and GitHub URLs use correct org | Catches errors after generation; simple to implement as agent instructions | Requires re-reading generated files; adds a verification pass |
| **B: Generation-time guardrails** — Add rules to the References section instructions in SKILL.md | Prevents errors at source; no extra pass needed | Agent may still make mistakes; longer prompt |
| **C: Both A + B** — Guardrails during generation plus a validation step | Defense in depth; catches anything guardrails miss | Slightly longer SKILL.md |

**Recommendation: Approach C** — guardrails prevent most issues, validation catches the rest.

## 4. Risks & Constraints

| Risk | Impact | Mitigation |
|------|--------|------------|
| Agent ignores validation step | Low — clear instructions with examples | Make validation a numbered sub-step, not just a note |
| Cross-reference heuristics too aggressive | Low — adds noise | Conservative: only link to ADRs that explicitly modify the same system |
| Longer SKILL.md prompt | Low — marginal increase | Keep additions concise |

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Three specific issues with known root causes |
| Behavior | Clear | Validation rules and cross-reference heuristics |
| Data Model | Clear | No data model changes |
| UX | Clear | No user-facing changes — agent-internal quality |
| Integration | Clear | Only modifies SKILL.md and decision-docs spec |
| Edge Cases | Clear | First run (no existing ADRs to cross-reference), manual ADRs |
| Constraints | Clear | Agent-executable instructions only |
| Terminology | Clear | "Validation", "cross-reference", "backlink" |
| Non-Functional | Clear | No performance impact |

## 6. Open Questions

All categories are Clear. No open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Add spec link validation to Step 4 | Prevents broken links to renamed/deleted specs; agent globs to verify existence | Manual review only (error-prone) |
| 2 | Add GitHub URL normalization rule | Prevents wrong org/repo format by specifying the canonical URL pattern | Hardcode URL in SKILL.md (too project-specific); skip (errors recur) |
| 3 | Add cross-reference guidance for related ADRs | Reduces missing back-links by instructing agent to check if new ADR modifies a system established by an earlier ADR | Fully automated graph (too complex for prompt); skip (quality degrades) |
