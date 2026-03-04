---
title: "Quality Gates"
capability: "quality-gates"
description: "Pre-implementation preflight checks and post-implementation verification"
order: 10
lastUpdated: "2026-03-04"
---

# Quality Gates

Two quality gates protect your implementation: `/opsx:preflight` checks specs and design before task creation, and `/opsx:verify` validates implementation against specs after coding is complete.

## Features

- Pre-implementation preflight check across six quality dimensions
- Post-implementation verification for completeness, correctness, and coherence
- Actionable findings with severity levels (CRITICAL, WARNING, SUGGESTION)
- Specific recommendations with file and line references where applicable
- Graceful degradation when some artifacts are missing

## Behavior

### Preflight Quality Check

When you run `/opsx:preflight`, the system reviews your specs and design across six dimensions:
- **Traceability Matrix** — maps every requirement to scenarios and components
- **Gap Analysis** — identifies missing edge cases, error handling, and empty states
- **Side-Effect Analysis** — assesses impact on existing systems and regression risks
- **Constitution Check** — verifies consistency with project rules
- **Duplication and Consistency** — detects overlaps and contradictions across specs
- **Assumption Audit** — rates every `<!-- ASSUMPTION -->` marker as Acceptable Risk, Needs Clarification, or Blocking

The result is a preflight.md artifact with a verdict of PASS, PASS WITH WARNINGS, or BLOCKED. Issues are reported for you to resolve — the system does not auto-fix them. If blockers are found, task creation is halted until they are resolved.

### Post-Implementation Verification

When you run `/opsx:verify`, the system checks your implementation across three dimensions:
- **Completeness** — task completion and spec coverage
- **Correctness** — requirement implementation accuracy and scenario coverage
- **Coherence** — design adherence and code pattern consistency

Each issue is classified as CRITICAL (must fix before archive), WARNING (should fix), or SUGGESTION (nice to fix). The report includes a summary scorecard, issues grouped by priority, and specific actionable recommendations. When uncertain about severity, the system errs on the side of lower severity.

### Stateless Verification

`/opsx:verify` always checks the current state of code and artifacts. It serves as both the initial verification and the final verification in the QA loop — no special flags or modes are needed.

## Edge Cases

- If no change name is provided and multiple changes exist, the system prompts you to select one. For preflight, auto-selection is allowed with only one change; for verify, the system always asks.
- If preflight is run on a change with no specs, it aborts and reports that specs must be created first.
- If verify is run on a change with no tasks, it reports the missing artifact and suggests generating it.
- If a change has tasks but no delta specs (e.g., documentation-only), verify skips requirement-level verification and focuses on task completion and code pattern coherence.
- If required artifacts are missing when running preflight, the system aborts and suggests running `/opsx:continue` or `/opsx:ff` to generate them.
- If a requirement keyword matches unrelated code during verification, the system prefers SUGGESTION severity to avoid false critical issues.
- On very large codebases, verification focuses on files referenced in design.md and recently modified files rather than scanning exhaustively.
