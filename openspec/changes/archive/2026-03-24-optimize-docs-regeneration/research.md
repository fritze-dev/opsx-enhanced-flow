# Research: Optimize Docs Regeneration

## 1. Current State

The `/opsx:docs` Step 1 (change detection) scans **all capabilities against all archives** to determine which docs need regeneration. For 18 capabilities × 19 archives, this requires reading 18 frontmatter files + 18 glob operations. This is O(capabilities × archives) and grows with project history.

**The bottleneck:** In the post-archive workflow (`/opsx:verify` → `/opsx:archive` → `/opsx:changelog` → `/opsx:docs`), we already know which capabilities were affected — they're in the just-archived change's `specs/` directory. The full archive scan is redundant.

**Affected files:**
- `skills/docs/SKILL.md` — Step 1 change detection logic + Input section
- `openspec/specs/user-docs/spec.md` — Incremental Capability Documentation Generation requirement

## 2. External Research

No external dependencies. Internal optimization only.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A. Accept comma-separated capability list as argument | Explicit, simple, works in any context | User must know affected capabilities; doesn't auto-detect from archive |
| B. Accept change name as argument, extract capabilities from archive | Fully automatic, uses existing archive data | Only works post-archive; needs archive parsing |
| C. Combine: multi-capability argument mode | Extends existing single-capability mode naturally; caller (agent or user) passes known capabilities | Simple extension of existing behavior; no archive parsing needed |

**Selected: Approach C** — extend the existing single-capability argument to accept multiple capabilities. The post-archive workflow already knows which capabilities were affected and can pass them directly.

## 4. Risks & Constraints

- Must remain backward-compatible: no argument = full scan, single capability = existing behavior
- Multi-capability mode should skip the archive date scan (same as single-capability mode: always regenerate)
- ADR and README steps still use their own detection logic — only capability docs are affected

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | Extend argument parsing + skip archive scan for listed capabilities |
| Behavior | Clear | Multi-capability = union of single-capability runs |
| Data Model | Clear | No data model changes |
| UX | Clear | Comma-separated list or space-separated |
| Integration | Clear | Post-archive workflow passes capabilities directly |
| Edge Cases | Clear | Empty list = full scan; single = existing behavior |
| Constraints | Clear | Backward compatible |
| Terminology | Clear | "multi-capability mode" |
| Non-Functional | Clear | Performance improvement is the goal |

All categories Clear.

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Extend argument to accept multiple capability names | Simplest change; natural extension of existing single-capability mode | Change name argument (too coupled to archive), automatic detection from conversation context (too implicit) |
| 2 | Modified Capabilities: `user-docs` only | Docs skill is a thin wrapper; spec owns the incremental generation logic | artifact-generation (not relevant — docs is independent of pipeline generation) |
