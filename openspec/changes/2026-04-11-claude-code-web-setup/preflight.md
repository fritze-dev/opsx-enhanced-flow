# Pre-Flight Check: Claude Code Web Setup

## A. Traceability Matrix

- [x] Claude Code Web Settings Generation → Scenario: Fresh init generates settings → `.claude/settings.json`, `scripts/setup-remote.sh`
- [x] Claude Code Web Settings Generation → Scenario: Gitignore updated → `.gitignore`
- [x] Claude Code Web Settings Generation → Scenario: Gitignore already has negation → `.gitignore` (skip path)
- [x] Claude Code Web Settings Generation → Scenario: Settings.json already exists → skip path
- [x] Claude Code Web Settings Generation → Scenario: Setup script already exists → skip path

All scenarios traced to concrete files and components.

## B. Gap Analysis

No gaps identified:
- Idempotency covered (skip if exists)
- `.gitignore` edge cases covered (missing file, existing negation)
- `scripts/` directory creation covered in edge cases
- `GH_TOKEN` absence handled gracefully (warning, not failure)

## C. Side-Effect Analysis

- **`.gitignore` modification**: Adding `!/.claude/settings.json` negation has no effect on existing ignored files. Only `.claude/settings.json` becomes tracked. Low risk.
- **SessionStart hook on local**: Script exits immediately when `CLAUDE_CODE_REMOTE` is not `true`. No side effect.
- **Existing `.claude/settings.local.json`**: Unaffected — different file, remains gitignored.
- **devcontainer.json**: Unaffected — parallel setup path for Codespaces.

No regression risks identified.

## D. Constitution Check

No constitution update needed. The change adds infrastructure files, not new architectural patterns or conventions. The existing convention "Local development: Developers register the local repo as marketplace via `claude plugin marketplace add`" remains valid alongside the new declarative approach for Claude Code Web.

## E. Duplication & Consistency

- No duplication with existing specs. The `project-init` spec already handles environment checks and `.gitignore` — the new requirement follows the same pattern.
- No contradictions with existing specs or constitution.

## F. Assumption Audit

| # | Assumption | Source | Rating |
|---|-----------|--------|--------|
| 1 | `gh --version` returns exit 0 when installed | spec.md | Acceptable Risk (pre-existing, well-tested) |
| 2 | `gh auth status` returns exit 0 when authenticated | spec.md | Acceptable Risk (pre-existing) |
| 3 | `git --version` output parseable | spec.md | Acceptable Risk (pre-existing) |
| 4 | Static analysis sufficient for codebase scan | spec.md | Acceptable Risk (pre-existing) |
| 5 | Structural comparison for drift detection | spec.md | Acceptable Risk (pre-existing) |
| 6 | Capability doc naming convention | spec.md | Acceptable Risk (pre-existing) |
| 7 | README table parseable format | spec.md | Acceptable Risk (pre-existing) |
| 8 | Design decisions table format | spec.md | Acceptable Risk (pre-existing) |
| 9 | `CLAUDE_CODE_REMOTE=true` in cloud sessions | spec.md | Acceptable Risk (confirmed in official docs) |
| 10 | Declarative plugin install via settings.json | spec.md | Acceptable Risk (confirmed in official docs) |
| 11 | `apt` works in cloud sessions | design.md | Acceptable Risk (docs confirm root on Ubuntu 24.04) |
| 12 | Marketplace source format `github`/`repo` | design.md | Acceptable Risk (confirmed in official docs) |

All assumptions rated Acceptable Risk. No blocking or unclear assumptions.

## G. Review Marker Audit

No `<!-- REVIEW -->` markers found in spec.md or design.md.

---

**Verdict: PASS** — All checks clear, no gaps, no blocking assumptions, no review markers.
