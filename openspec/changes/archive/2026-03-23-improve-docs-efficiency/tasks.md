# Implementation Tasks: Improve Docs Efficiency

## 1. Foundation

- [x] 1.1. Read existing `skills/docs/SKILL.md` in full to understand current step structure and identify exact insertion points for new logic

## 2. Implementation

### Step 1: Change Detection (SKILL.md)
- [x] 2.1. Add change detection phase to Step 1 (Discover Specs): after discovering specs, read existing `docs/capabilities/<capability>.md` files, extract `lastUpdated`, compare against archive date prefixes, build regeneration list
- [x] 2.2. Add single-capability mode enforcement: when capability name argument provided, always regenerate that capability and only read its archives

### Step 3: Content-Aware Writes (SKILL.md)
- [x] 2.3. Modify Step 3 (Generate Capability Docs) to skip capabilities not marked for regeneration
- [x] 2.4. Add content comparison logic to Step 3: after generating each doc, compare body (excluding `lastUpdated`) against existing file; only write and bump timestamp if content differs
- [x] 2.5. Add tracking flag: record whether any capability doc was actually written to disk (needed for Step 5 conditional)

### Step 4: ADR Improvements (SKILL.md)
- [x] 2.6. Add incremental ADR detection to Step 4: count existing `adr-[0-9]*.md`, find highest number, check archive backlinks to identify already-processed archives, skip if no new Decisions tables
- [x] 2.7. Add consolidation heuristics to Step 4: when processing a Decisions table, apply 3+ rows + single-topic rule, generate consolidated ADR format with numbered sub-decisions
- [x] 2.8. Add archive backlink to Step 4 References: `[Archive: <short-name>](../../openspec/changes/archive/<dir>/)` as first reference in each ADR
- [x] 2.9. Add one-time full regeneration detection: if existing ADR count doesn't match expected consolidated count (first run after consolidation), regenerate all ADRs
- [x] 2.10. Add tracking flag: record whether any ADR was created (needed for Step 5 conditional)

### Step 5: Conditional README (SKILL.md)
- [x] 2.11. Modify Step 5 (Generate README) to check 4 conditions before regenerating: (1) capability doc written, (2) ADR created, (3) README doesn't exist, (4) constitution/three-layer-architecture content drifted from README
- [x] 2.12. Add constitution drift detection: read `openspec/constitution.md` and `openspec/specs/three-layer-architecture/spec.md`, compare key sections against corresponding README sections

### Step 6: Output (SKILL.md)
- [x] 2.13. Update Step 6 output format to show three categories: regenerated, skipped (unchanged content), skipped (no newer archives); report ADR and README status

### Guardrails and Cleanup (SKILL.md)
- [x] 2.14. Remove "ADRs are fully regenerated on each run" statement (~line 138)
- [x] 2.15. Remove "This file is fully regenerated on each run" statement (~line 162)
- [x] 2.16. Update guardrail about README always being regenerated (~line 222) to reference conditional regeneration

## 3. QA Loop & Human Approval

- [x] 3.1. Metric Check: Verify each Success Metric from design.md — all PASS (code review):
  - [x] `/opsx:docs` with no new archives → zero files modified — PASS (Step 1 skips, Step 4 skips, Step 5 skips)
  - [x] `/opsx:docs` after adding one archive → only affected capabilities and new ADRs regenerated — PASS (Step 1 date comparison)
  - [x] Capability doc `lastUpdated` NOT bumped when content identical — PASS (Step 3 content-aware writes)
  - [x] Every generated ADR has `[Archive: ...]` backlink in References — PASS (Step 4 References)
  - [x] Single-topic archive with 3+ decisions → 1 consolidated ADR (test with rename-init-to-setup) — PASS (Step 4 consolidation heuristics)
  - [x] README skipped when no docs/ADRs change and no constitution drift — PASS (Step 5 conditional)
- [x] 3.2. Auto-Verify: Run `/opsx:verify` (built-in OpenSpec command). — PASSED: 0 critical, 0 warnings, 0 suggestions
- [x] 3.3. User Testing: **Stop here!** Ask the user for manual approval.
- [x] 3.4. Fix Loop: Removed project-specific `three-layer-architecture` spec reference from condition 4 (SKILL.md, delta-spec, design, preflight). Constitution-only drift detection.
- [x] 3.5. Final Verify: Confirmed all artifacts consistent after fix.
- [x] 3.6. Approval: User approved.
