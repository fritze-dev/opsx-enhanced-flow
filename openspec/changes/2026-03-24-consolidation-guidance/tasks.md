# Tasks: Consolidation Guidance

## 1. Schema Proposal Instruction — Add Capability Granularity Rules

- [x] In `openspec/schemas/opsx-enhanced/schema.yaml`, add capability granularity rules to the proposal `instruction` field (after the Scope & Boundaries bullet, before the IMPORTANT paragraph). Include: capability definition, feature detail definition, merge heuristic (shared actor/trigger/data), minimum scope heuristic (<100 lines → fold into existing)

## 2. Schema Proposal Instruction — Add Consolidation Check

- [x] In `openspec/schemas/opsx-enhanced/schema.yaml`, replace the existing IMPORTANT paragraph (lines 46-48) with expanded version including mandatory consolidation check steps: (1) list existing specs and read Purpose sections, (2) check each new capability for domain overlap, (3) check pairs of new capabilities for shared actor/trigger/data, (4) verify 3+ requirements per capability

## 3. Proposal Template — Add Consolidation Check Section

- [x] In `openspec/schemas/opsx-enhanced/templates/proposal.md`, add `### Consolidation Check` section between Modified Capabilities and `## Impact` with instructions for documenting: existing specs reviewed, overlap assessment per new capability, merge assessment for capability pairs

## 4. Schema Specs Instruction — Add Overlap Verification

- [x] In `openspec/schemas/opsx-enhanced/schema.yaml`, insert overlap verification step at the beginning of the specs `instruction` field (before "Create one spec file per capability"): (1) read proposal's Consolidation Check, (2) scan existing specs for overlap, (3) if overlap found → reclassify as Modified and update proposal

## 5. Continue Skill — Add Consolidation Awareness

- [x] In `skills/continue/SKILL.md`, update the specs creation guideline (line 104) to add consolidation-awareness note: "Before creating, verify the proposal's Consolidation Check confirms no overlap with existing specs."

## 6. QA Loop

- [x] PASS/FAIL: proposal instruction contains capability granularity rules (capability vs feature detail, merge heuristic, minimum scope)
- [x] PASS/FAIL: proposal instruction contains mandatory consolidation check with 4 steps
- [x] PASS/FAIL: proposal template contains `### Consolidation Check` section
- [x] PASS/FAIL: specs instruction contains overlap verification step before "Create one spec file per capability"
- [x] PASS/FAIL: continue skill's specs guideline mentions consolidation check verification
- [x] Schema validation passes: `openspec schema validate opsx-enhanced`
- [x] Human approval gate
