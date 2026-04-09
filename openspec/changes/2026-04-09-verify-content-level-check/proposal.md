## Why

The `/opsx:verify` skill uses shallow keyword matching (grep for term presence) instead of content-level comparison when checking implementation against specs. This caused a false-pass during the spec-frontmatter-tracking change — verify reported 0 issues while a stale heading ("Worktree context detection" instead of "Change context detection") went undetected. Keyword search found the words but missed the semantic mismatch.

## What Changes

- **Enhance verify skill instructions** to replace vague "search for keywords" guidance with explicit read-then-compare methodology in steps 5 (Completeness), 6 (Correctness), and 7 (Coherence)
- Add explicit instructions for **terminology cross-referencing**: extract key terms from spec requirements and verify they appear in the correct context in implementation files
- Add instructions for **stale terminology detection**: compare headings, field names, and normative language between specs and implementation
- Replace the generic "search codebase for implementation evidence" pattern with "read the implementation file, locate the relevant section, compare content against each spec requirement"

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `quality-gates`: No spec-level requirement changes needed. The spec already requires "accuracy" and has scenarios for divergence detection. The change is to the verify skill instructions (implementation), not to spec requirements.

### Removed Capabilities

(none)

### Consolidation Check

1. Existing specs reviewed: quality-gates, task-implementation, artifact-pipeline, workflow-contract, spec-format
2. Overlap assessment: quality-gates is the only spec governing verify behavior. No other spec covers post-implementation verification.
3. Merge assessment: N/A — no new capabilities proposed.

## Impact

- **Primary**: `src/skills/verify/SKILL.md` — skill instruction text in steps 5, 6, 7, and Verification Heuristics section
- **No spec changes**: quality-gates spec already defines the required behavior; the skill just under-delivers
- **No template changes**: verify is a skill, not a pipeline artifact
- **All consumers benefit**: this is a generic skill improvement, not project-specific

## Scope & Boundaries

**In scope:**
- Rewriting verify skill steps 5-7 to use read-then-compare instead of keyword grep
- Adding terminology cross-referencing instructions
- Adding stale terminology detection instructions
- Updating the Verification Heuristics section to reflect the new methodology

**Out of scope:**
- Changing the quality-gates spec requirements
- Adding new verification dimensions beyond the existing three
- Changing the report format or severity classification
- Performance optimization for large codebases (existing "focus on referenced files" constraint remains)
