# Tasks: Optimize Docs Regeneration

## 1. Update Docs Skill — Input Section

- [x] In `skills/docs/SKILL.md`, update the Input section to document multi-capability mode: comma-separated list of capability names (e.g., `/opsx:docs artifact-pipeline,artifact-generation`)

## 2. Update Docs Skill — Step 1 Change Detection

- [x] In `skills/docs/SKILL.md`, add multi-capability argument handling to Step 1: parse comma-separated list, trim whitespace, deduplicate, validate each against `openspec/specs/`, mark all listed capabilities for regeneration (skip date scan), warn and skip nonexistent capabilities

## 3. QA Loop

- [x] PASS/FAIL: Input section documents multi-capability mode
- [x] PASS/FAIL: Step 1 handles comma-separated list with skip-date-scan behavior
- [x] PASS/FAIL: Backward compatible (no argument = full scan, single = existing)
- [x] Human approval gate
