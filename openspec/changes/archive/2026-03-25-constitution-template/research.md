# Research: Constitution Template Extraction

## 1. Current State

The constitution structure is hardcoded inline in `skills/bootstrap/SKILL.md` (lines 47-69) as part of Step 2. The bootstrap skill generates these sections:

- `## Tech Stack` — Language, Runtime, Framework, Database, Testing, Package Manager
- `## Architecture Rules` — Architectural patterns, module boundaries, dependency direction
- `## Code Style` — Coding conventions, formatting, naming patterns
- `## Constraints` — Limits, requirements, compatibility rules
- `## Conventions` — Naming, commits, branching, file organization
- `## Standard Tasks` — Project-specific post-implementation steps (with HTML comment explaining purpose)

All other generated artifacts already have dedicated template files under `openspec/schemas/opsx-enhanced/templates/`:
- `tasks.md`, `design.md`, `proposal.md`, `research.md`, `preflight.md`
- `specs/spec.md`, `docs/readme.md`, `docs/adr.md`, `docs/capability.md`

The constitution is referenced downstream by:
- `docs/readme.md` template — pulls Tech Stack and Conventions sections
- `schema.yaml` task generation — appends constitution's Standard Tasks to universal steps
- All skills — read constitution via `config.yaml` context

## 2. External Research

N/A — purely internal refactoring.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Extract sections into `templates/constitution.md`, bootstrap reads it | Consistent with existing template pattern; single source of truth for section structure; enables per-schema constitution variants | Requires bootstrap skill to resolve template path from schema; slightly more complex bootstrap logic |
| B: Keep inline but reference a shared constant/section list | Minimal change to bootstrap flow | Doesn't follow existing template pattern; no per-schema support; still hardcoded |

**Recommendation**: Approach A — aligns with the existing template system and fulfills the issue's goal.

## 4. Risks & Constraints

- **Low risk**: The constitution template defines structure only (section headings + guidance comments), not content. The bootstrap skill already fills in content by analyzing the project.
- **No breaking change**: Existing constitutions are unaffected; the template is only used during bootstrap (first-run or re-sync).
- **Dependency**: The bootstrap skill must resolve the correct schema's template directory. Currently it uses `openspec schemas --json` or defaults to the configured schema — this path is already available.
- **REVIEW markers**: The bootstrap REVIEW-marker resolution flow (Step 2b) is independent of where sections are defined. No impact.

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Extract hardcoded sections from bootstrap into a template file |
| Behavior | Clear | Bootstrap reads template instead of inline definition; output unchanged |
| Data Model | Clear | New file `templates/constitution.md` with section structure |
| UX | Clear | No user-facing change; bootstrap flow identical |
| Integration | Clear | Bootstrap skill references template; downstream consumers unchanged |
| Edge Cases | Clear | First-run vs re-sync both use same bootstrap flow |
| Constraints | Clear | Must preserve existing section order and Standard Tasks placement |
| Terminology | Clear | "Constitution template" vs "constitution" (generated output) is unambiguous |
| Non-Functional | Clear | No performance impact |

All categories are Clear — no open questions needed.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Extract to `templates/constitution.md` | Consistent with existing template pattern; enables per-schema variants | Keep inline (rejected: inconsistent) |
| 2 | Template contains section headings + guidance comments only | Bootstrap fills in content by analyzing project; template is structure, not content | Include sample content (rejected: would conflict with observed-pattern-only principle) |
| 3 | Bootstrap reads template from schema's template directory | Schema already resolved during bootstrap; natural extension | Hardcoded path (rejected: defeats per-schema purpose) |
