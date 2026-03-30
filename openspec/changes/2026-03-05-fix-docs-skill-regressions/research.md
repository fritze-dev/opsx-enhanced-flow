# Research: Fix Docs Skill Quality Regressions

## 1. Current State

A full docs regeneration test (delete all docs → `/opsx:docs` → `git diff`) revealed 11 regressions, 7 improvements, and 6 optimization opportunities. The improvements confirm that templates and guardrails fundamentally work. The regressions come from edge cases not yet covered in SKILL.md or templates.

**Affected files:**
- `skills/docs/SKILL.md` — Core generation instructions (208 lines)
- `openspec/schemas/opsx-enhanced/templates/docs/capability.md` — Capability doc template (87 lines)
- `openspec/schemas/opsx-enhanced/templates/docs/adr.md` — ADR template (47 lines)
- `openspec/schemas/opsx-enhanced/templates/docs/readme.md` — README template (47 lines)
- Three specs: `user-docs`, `architecture-docs`, `decision-docs`

**Stale-spec risks:**
- `decision-docs` spec has an "Empty Decisions table" edge case but does NOT cover design.md with prose-only Decisions sections (the R1 root cause). It also has no concept of manual ADRs (R2) and an imprecise slug algorithm (R4).
- `user-docs` spec lacks guidance on Rationale tense (R10), behavior header format (R9), and has a thin initial-spec fallback (R11).
- `architecture-docs` spec has no mention of manual ADRs in the README table (R2), no description length constraint (R6), and thin trade-offs guidance (R8).

## 2. External Research

Not applicable — this is an internal quality fix for existing skill/template/spec artifacts. No external APIs, libraries, or reference implementations involved.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Fix SKILL.md + templates only (no spec changes) | Minimal change surface; fixes agent behavior directly | Specs drift from implementation; future regenerations may reintroduce regressions if agent reads specs |
| B: Fix specs + SKILL.md + templates together | Specs stay authoritative; complete consistency across all layers | Larger change; more artifacts to review |
| C: Fix specs only, let SKILL.md derive from specs | Spec-driven purity | SKILL.md is what the agent actually reads at runtime; spec changes alone won't fix the behavior |

**Recommended: Approach B** — Both specs and SKILL.md/templates need updates. The specs define WHAT should happen; SKILL.md defines HOW to do it. Both must agree.

### Regression-to-fix mapping

| # | Severity | Regression | Fix Location |
|---|----------|-----------|--------------|
| R1 | CRITICAL | ADR fabricated from archive without Decisions table | SKILL.md Step 4, decision-docs spec |
| R2 | CRITICAL | Non-archive ADR lost on regeneration | SKILL.md Steps 4/5/6, decision-docs + architecture-docs specs, new `docs/decisions/manual/` dir |
| R3 | HIGH | ADR numbering shifted | Auto-fixed by R1 |
| R4 | MEDIUM | ADR slugs non-deterministic | SKILL.md Step 4, decision-docs spec |
| R5 | MEDIUM | ADR References use raw paths | ADR template |
| R6 | MEDIUM | README capability descriptions too verbose | README template, architecture-docs spec |
| R7 | LOW | Future Enhancements lost on full regeneration | No fix needed (expected behavior) |
| R8 | LOW | Notable Trade-offs reduced | README template, architecture-docs spec |
| R9 | LOW | Behavior headers lost command references | Capability template, user-docs spec |
| R10 | MEDIUM | Rationale drifts into change-history | Capability template, user-docs spec |
| R11 | MEDIUM | Initial-spec Rationale too aggressively omitted | SKILL.md Step 2, user-docs spec |

### R2 Design: Manual ADR preservation

Three options were considered:

| Option | Pro | Contra |
|--------|-----|--------|
| (a) `docs/decisions/manual/` subdirectory | Clean separation by directory | Requires README to discover two locations; unnecessary if naming alone distinguishes |
| (b) `adr-MNNN-slug.md` naming convention in same directory | No new directory; naming alone distinguishes manual from generated; single glob location | None significant — the M prefix is unambiguous |
| (c) SKILL.md preservation rule for unmatched ADRs | No new convention | Fuzzy matching; numbering conflicts with generated `adr-NNN` range |

**Chosen: Option (b)** — Manual ADRs live in `docs/decisions/` alongside generated ADRs, using the `adr-MNNN-slug.md` naming convention (M prefix + 3-digit zero-padded number). The SKILL.md cleanup rule simply preserves files matching `adr-M*.md` during regeneration.

### R4 Design: Deterministic slug algorithm

Current rule is underspecified ("lowercase, replace spaces with hyphens"). Different runs produce different slugs for dots, parens, slashes.

**Deterministic algorithm:**
1. Lowercase the entire string
2. Replace any character NOT in `[a-z0-9]` with a hyphen
3. Collapse consecutive hyphens into one
4. Trim leading/trailing hyphens
5. Truncate to 50 characters
6. Trim trailing hyphens again

## 4. Risks & Constraints

- **Slug change causes file rename churn**: The new deterministic algorithm will produce different filenames for some existing ADRs. All README links regenerate to match, so no broken links. Git will show renames.
- **Manual ADR content recovery**: The lost ADR-034 content is recoverable from git history (commit `3689c3e`).
- **No code changes**: All fixes are to markdown files (skill prompts, templates, specs). No runtime dependencies affected.
- **Verification requires full regeneration cycle**: The only reliable test is delete → regenerate → diff, which depends on `/opsx:docs` agent behavior.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 9 regressions to fix (R7 expected, R3 auto-fixed by R1) |
| Behavior | Clear | Each regression has a specific root cause and fix location |
| Data Model | Clear | No data model changes — only markdown structure |
| UX | Clear | End-user docs quality improves; no UX surface changes |
| Integration | Clear | No integration points beyond existing `/opsx:docs` skill |
| Edge Cases | Clear | The regressions themselves ARE the edge cases being fixed |
| Constraints | Clear | Must preserve existing doc structure; manual ADRs use separate numbering |
| Terminology | Clear | `adr-MNNN` convention for manual ADRs established |
| Non-Functional | Clear | No performance or scalability concerns |

All categories are Clear. No open questions.

## 6. Open Questions

All categories are Clear — no open questions.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Manual ADRs use `adr-MNNN-slug.md` naming in `docs/decisions/` (same directory as generated ADRs) | No extra directory; M prefix unambiguously distinguishes from generated `adr-NNN`; single glob location for README discovery | Separate `manual/` subdirectory (unnecessary complexity); unnumbered slugs (no ordering); `adr-000` range (collision risk) |
| 3 | Fix both specs AND SKILL.md/templates | Specs define requirements; SKILL.md defines execution; both must agree to prevent future drift | SKILL.md-only (specs drift); specs-only (agent doesn't read specs at runtime) |
| 4 | Deterministic slug: replace non-`[a-z0-9]` with hyphen | Handles all special chars uniformly; no ambiguity about dots, parens, slashes | Keep current underspecified rule (non-deterministic); add special-case rules per character type (complex) |
