## Why

The QA loop runs `/opsx:verify` once (step 3.2), then enters the Fix Loop (3.4) where code, specs, or design may be modified. After fixes, the user proceeds directly to Approval (3.5) without a final verification pass. This means post-fix changes go unverified before archiving. In practice (observed during `fix-workflow-friction`), teams naturally re-verify after fixes — but the template doesn't formalize this as a checkpoint.

## What Changes

- **Add "Final Verify" step (3.5) to the tasks.md template:** A new checkbox between Fix Loop and Approval that requires running `/opsx:verify` one final time after all fixes are applied.
- **Renumber Approval to 3.6:** The existing approval step moves from 3.5 to 3.6.
- **Update specs to require final verification:** The human-approval-gate spec gains a scenario formalizing that approval requires a clean final verify.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `human-approval-gate`: Add requirement that approval is gated by a final verify pass after the fix loop.
- `quality-gates`: Add scenario for final verify as a distinct checkpoint in the QA loop.

## Impact

- `openspec/schemas/opsx-enhanced/templates/tasks.md` — Add step 3.5, renumber 3.5 → 3.6
- `openspec/specs/human-approval-gate/spec.md` — Add final verify requirement/scenario
- `openspec/specs/quality-gates/spec.md` — Add final verify scenario

## Scope & Boundaries

**In scope:**
- tasks.md template modification
- Spec updates for human-approval-gate and quality-gates

**Out of scope:**
- Skill changes (verify skill works as-is)
- Schema changes (no new artifacts or dependencies)
- Apply skill changes
