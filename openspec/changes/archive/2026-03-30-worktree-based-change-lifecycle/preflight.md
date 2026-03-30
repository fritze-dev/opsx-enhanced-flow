# Pre-Flight Check: Worktree-Based Change Lifecycle

## A. Traceability Matrix

- [x] Create Worktree-Based Workspace → Scenario: Create worktree when enabled → `src/skills/new/SKILL.md`
- [x] Create Worktree-Based Workspace → Scenario: Worktree already exists → `src/skills/new/SKILL.md`
- [x] Create Worktree-Based Workspace → Scenario: Worktree disabled falls back → `src/skills/new/SKILL.md`
- [x] Worktree Context Detection → Scenario: Auto-detect from worktree → `src/skills/ff/SKILL.md`, `apply`, `verify`, `archive`, `sync`, `discover`, `preflight`
- [x] Worktree Context Detection → Scenario: Fall through when not in worktree → same 7 skills
- [x] Worktree Context Detection → Scenario: Fall through when directory missing → same 7 skills
- [x] Worktree Context Detection → Scenario: Explicit argument overrides → same 7 skills
- [x] Worktree Cleanup After Archive → Scenario: Auto-cleanup → `src/skills/archive/SKILL.md`
- [x] Worktree Cleanup After Archive → Scenario: Manual cleanup instructions → `src/skills/archive/SKILL.md`
- [x] Worktree Cleanup After Archive → Scenario: Not in worktree — no cleanup → `src/skills/archive/SKILL.md`
- [x] Create Change Workspace (MODIFIED) → All scenarios → `src/skills/new/SKILL.md`
- [x] WORKFLOW.md Owns Pipeline Configuration (MODIFIED) → Scenario: worktree config → `src/templates/workflow.md`, `openspec/WORKFLOW.md`
- [x] Post-Artifact Commit and PR Integration (MODIFIED) → Scenario: Worktree skips branch → `openspec/WORKFLOW.md`
- [x] Install OpenSpec Workflow (MODIFIED) → Scenario: Copy from template → `src/skills/setup/SKILL.md`, `src/templates/workflow.md`
- [x] Install OpenSpec Workflow (MODIFIED) → Scenario: Worktree opt-in → `src/skills/setup/SKILL.md`
- [x] WORKFLOW.md Template File → Scenario: Template contains config → `src/templates/workflow.md`
- [x] Environment Checks During Setup → Scenarios: gh CLI, git version, gitignore → `src/skills/setup/SKILL.md`
- [x] GitHub Merge Strategy Configuration → Scenarios: configure, failure → `src/skills/setup/SKILL.md`

## B. Gap Analysis

- **No gaps found.** All requirements have scenarios, all scenarios map to components.
- Edge cases covered: branch already exists, dirty worktree removal, no gh CLI, git version too old, missing gitignore entry, worktree path exists but not a worktree, worktree config absent, invalid path_pattern.

## C. Side-Effect Analysis

| Affected System | Risk | Mitigation |
|----------------|------|------------|
| `src/skills/new/SKILL.md` | New worktree creation step changes flow | Gated by `worktree.enabled`; falls back to existing behavior when disabled |
| `src/skills/ff/SKILL.md` | New detection preamble runs before existing logic | Preamble is additive — falls through to existing detection if not in worktree |
| `src/skills/apply/SKILL.md` | Same as ff | Same mitigation |
| `src/skills/verify/SKILL.md` | Changes "Do NOT auto-select" guardrail | Only overridden for worktree context (explicit isolation = known change) |
| `src/skills/archive/SKILL.md` | Same guardrail change + new cleanup step | Cleanup only runs in worktree; non-worktree behavior unchanged |
| `src/skills/sync/SKILL.md` | Same guardrail change | Same mitigation as verify |
| `src/skills/discover/SKILL.md` | New detection preamble | Falls through to existing logic |
| `src/skills/preflight/SKILL.md` | New detection preamble | Falls through to existing logic |
| `src/skills/setup/SKILL.md` | WORKFLOW.md generation changed from inline to template copy; new environment checks and opt-in question | Template fallback to inline if template missing; checks are non-blocking |
| `openspec/WORKFLOW.md` | New `worktree:` section; updated `post_artifact` | Worktree section commented out by default; post_artifact change is backward compatible |
| `src/templates/workflow.md` | New file | No impact on existing systems |
| `.gitignore` | May be modified during setup | Only if user opts in and entry is missing; user is asked first |

**No regressions expected**: All changes are either gated by `worktree.enabled`, additive preambles that fall through, or backward-compatible post_artifact updates.

## D. Constitution Check

No constitution update needed. The change does not introduce new technologies, architectural patterns, or code style conventions. The three-layer architecture is preserved — worktree config lives in WORKFLOW.md (schema layer), detection logic lives in skills (skills layer).

Note: The `three-layer-architecture` spec mentions "12 skills" but there are currently 13 (docs-verify was added). This is a pre-existing drift, not caused by this change. No new skills are added in this change.

## E. Duplication & Consistency

- **Worktree detection preamble**: Identical text inserted into 7 skills. This is intentional — each skill is a standalone SKILL.md file and must be self-contained per the skill immutability rule. No shared include mechanism exists.
- **No contradictions** between the 3 delta specs. `change-workspace` owns creation/detection/cleanup, `artifact-pipeline` owns WORKFLOW.md config and post_artifact, `project-setup` owns template and environment checks.
- **Consistent with existing specs**: No overlap or contradiction with `workflow-contract`, `spec-sync`, `task-implementation`, `quality-gates`, or other unchanged specs.

## F. Assumption Audit

| Source | Assumption | Tag | Rating |
|--------|-----------|-----|--------|
| artifact-pipeline/spec.md | gh CLI authenticated and has PR permission | gh CLI authentication | Acceptable Risk — graceful degradation documented |
| project-setup/spec.md | gh --version returns exit 0 when installed | gh version check | Acceptable Risk — standard CLI behavior |
| project-setup/spec.md | gh auth status returns exit 0 when authenticated | gh auth check | Acceptable Risk — standard CLI behavior |
| project-setup/spec.md | git --version output contains parseable version number | git version parseable | Acceptable Risk — universal git behavior |
| design.md | ${CLAUDE_PLUGIN_ROOT} resolves correctly from worktree CWD | Plugin root resolution | Acceptable Risk — plugin root is plugin-relative, not CWD-relative |

All assumptions rated **Acceptable Risk**. No blocking or needs-clarification items.

## G. Review Marker Audit

No `<!-- REVIEW -->` or `<!-- REVIEW: ... -->` markers found in any artifact.

---

**Verdict: PASS**
