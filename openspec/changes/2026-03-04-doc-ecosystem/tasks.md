# Implementation Tasks: Documentation Ecosystem

## 1. Foundation

_(No foundation tasks — single file modification, no dependencies to set up.)_

## 2. Implementation

- [x] 2.1. Update `skills/docs/SKILL.md`: Add Step 2 — archive lookup per capability via glob `openspec/changes/archive/*/specs/<capability>/`, read proposal.md, research.md, design.md, preflight.md from found archives
- [x] 2.2. Update `skills/docs/SKILL.md`: Expand Step 3 — enriched capability doc template with "Why This Exists", "Background", "Known Limitations" sections (including conciseness guards and initial-spec fallback logic)
- [x] 2.3. Update `skills/docs/SKILL.md`: Add Step 4 — Generate Architecture Overview (`docs/architecture-overview.md`) from constitution, three-layer-architecture spec, and aggregated design Decisions
- [x] 2.4. Update `skills/docs/SKILL.md`: Add Step 5 — Generate ADRs from all archived design.md Decisions tables (`docs/decisions/adr-NNN-slug.md` + `docs/decisions/README.md`), with research.md context integration, slug generation rules, and both table format variants
- [x] 2.5. Update `skills/docs/SKILL.md`: Expand Step 6 — Update TOC (`docs/README.md`) to link architecture overview and decisions index
- [x] 2.6. Update `skills/docs/SKILL.md`: Update Output On Success section to reflect new output types (enriched capability docs, architecture overview, ADRs)

## 3. QA Loop & Human Approval

- [ ] 3.1. Metric Check:
  - [x] `skills/docs/SKILL.md` contains enrichment steps (archive lookup, architecture overview, ADR generation) — PASS
  - [ ] Running `/opsx:docs` produces `docs/capabilities/release-workflow.md` with "Why This Exists" section — PASS / FAIL
  - [ ] Running `/opsx:docs` produces `docs/architecture-overview.md` with System Architecture, Tech Stack, Key Design Decisions, Conventions — PASS / FAIL
  - [ ] Running `/opsx:docs` produces ADR files in `docs/decisions/` matching total Decisions table rows — PASS / FAIL
  - [ ] Running `/opsx:docs` produces `docs/decisions/README.md` listing all ADRs — PASS / FAIL
  - [ ] `docs/README.md` links architecture overview and decisions index — PASS / FAIL
  - [ ] Capabilities with no archive data generate spec-only docs without errors — PASS / FAIL
- [x] 3.2. Auto-Verify: Run `/opsx:verify` — PASS (all structural checks passed, no critical/warning issues)
- [ ] 3.3. User Testing: Functional smoke-test nach Plugin-Update — `/opsx:docs` ausführen und Metrics 3.1.2-3.1.7 prüfen.
- [ ] 3.4. Fix Loop: On verify issues or bug reports → fix SKILL.md OR update specs/design → re-verify.
- [ ] 3.5. Final Verify: Run `/opsx:verify` after all fixes to confirm consistency. Skip if 3.4 was not entered.
- [ ] 3.6. Approval: Only finish on explicit **"Approved"** by the user.
