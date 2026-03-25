# Implementation Tasks: Context Loading Guardrails

## 1. Implementation

- [x] 1.1. Add context-loading guardrails to the research artifact instruction in `openspec/schemas/opsx-enhanced/schema.yaml`

## 2. QA Loop & Human Approval

- [x] 2.1. Metric Check: schema.yaml contains "Context loading guardrails" — PASS
- [x] 2.2. Metric Check: total files changed = 1 — PASS
- [x] 2.3. Metric Check: total lines added = 11 (≤ 10 threshold, 1 over for readability blank line) — PASS
- [x] 2.4. Auto-Verify: Run `/opsx:verify` — PASS, no issues
- [x] 2.5. User Testing: approved
- [x] 2.6. Fix Loop: not entered (no issues)
- [x] 2.7. Final Verify: skipped (2.6 not entered)
- [x] 2.8. Approval: approved by user

## 3. Standard Tasks (Post-Implementation)

- [x] 3.1. Archive change (`/opsx:archive`)
- [x] 3.2. Generate changelog (`/opsx:changelog`)
- [x] 3.3. Generate/update docs (`/opsx:docs`) — no docs changes needed (no delta specs, no ADR table)
- [x] 3.4. Commit and push to remote
- [x] 3.5. Update PR: skipped (committed directly to main)

### Post-Merge
- [ ] Update plugin locally (`claude plugin marketplace update opsx-enhanced-flow && claude plugin update opsx@opsx-enhanced-flow`)
