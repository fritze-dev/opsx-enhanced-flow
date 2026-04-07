# Pre-Flight Check: Post-Merge Reminder Format

## A. Traceability Matrix

- [x] Constitution Post-Merge format → CONSTITUTION.md edit → 1 item
- [x] Spec post-merge references → task-implementation/spec.md edit → ~6 references
- [x] Template instruction → tasks.md template instruction update → 1 clarification

## B. Gap Analysis

No gaps found. All three affected files are addressed.

## C. Side-Effect Analysis

- **Progress counts**: Future tasks.md files will have lower totals (post-merge items not counted). This is intentional — correct behavior.
- **Apply skill behavior**: No change. The apply skill only processes checkboxes; plain bullets are already ignored.
- **Existing tasks.md**: Immutable. No migration needed.

No regression risks.

## D. Constitution Check

This change modifies the constitution itself. The change is additive (refining format) and does not conflict with any existing rules.

## E. Duplication & Consistency

- Pre-merge tasks remain `- [ ]` checkboxes (consistent with universal standard tasks)
- Post-merge items become `- ` plain bullets (consistent with their "reminder" role)
- No contradictions.

## F. Assumption Audit

No assumptions in spec or design.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found.

**Verdict: PASS**
