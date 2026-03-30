# Tasks: Initial Project Specification

> Documentation-only bootstrap — no code implementation needed.

## 1. Sync & Archive

- [x] 1.1 Run `/opsx:sync` to merge all 15 delta specs into `openspec/specs/` baselines
- [x] 1.2 Verify all 15 baseline specs exist in `openspec/specs/`
- [x] 1.3 Validate baselines: every spec has `## Purpose` + `## Requirements` (no ADDED prefix)

## 2. QA Loop & Human Approval

- [x] 2.1 Metric: All 15 spec files pass `openspec validate` — PASS
- [x] 2.2 Metric: Every skill's core behavior covered by at least one Gherkin scenario — PASS (152 total scenarios across 15 specs)
- [x] 2.3 Metric: Specs are self-contained (no cross-spec duplication) — PASS (41 unique requirements, no overlap)
- [x] 2.4 Metric: Archive produces clean baselines via `/opsx:sync` (no manual fixups) — PASS (all 15 baselines validated without fixups)
- [x] 2.5 Auto-Verify: Run `/opsx:verify` — 0 CRITICAL, 2 WARNING (stale 16→15 refs in design.md/preflight.md)
- [x] 2.6 User Testing: Approved
- [x] 2.7 Fix Loop: Fixed 2 warnings (stale 16→15 refs in design.md and preflight.md)
- [x] 2.8 Approval: Approved
