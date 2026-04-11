# Research: Tool-Agnostic GitHub Operations

## 1. Current State

The plugin hardcodes `gh` CLI commands in 5 locations across specs, skills, and docs. While graceful degradation exists (operations skip when `gh` is unavailable), the instructions couple to a specific tool rather than describing intent.

**Affected files:**

| File | Line(s) | gh command | Purpose |
|------|---------|------------|---------|
| `src/skills/workflow/SKILL.md` | 105 | `gh pr create --draft` | Draft PR on first push |
| `openspec/CONSTITUTION.md` | 58 | `gh pr ready && gh pr edit` | Pre-merge standard task |
| `openspec/specs/artifact-pipeline/spec.md` | 131-156 | `gh pr create --draft` | Requirement + 4 scenarios |
| `openspec/specs/change-workspace/spec.md` | 175-177, 242-251, 252-261 | `gh pr view`, `gh pr merge` | Cleanup detection + post-merge |
| `README.md` | 299-309 | `gh` install instructions | Setup documentation |

**Not affected (out of scope):**

| File | Reason |
|------|--------|
| `.github/workflows/release.yml` | CI runs on GitHub Actions where `gh` is pre-installed — correct tool for CI |
| `docs/decisions/adr-028,031,035,039` | Historical ADRs documenting why decisions were made — stay as-is |
| `CHANGELOG.md` | Historical entries |
| `openspec/changes/*/tests.md` | Test artifacts for prior changes reference `gh` in scenario context — already merged |

## 2. External Research

**Claude Code Web environment:**
- Ships with built-in GitHub MCP tools for PR creation, viewing, editing, issue management
- No `gh` CLI pre-installed; `git push/pull` works via GitHub Proxy
- MCP tools are automatically available — no setup needed

**Claude Code Desktop/CLI:**
- May or may not have `gh` CLI installed
- Uses bash commands directly when `gh` is available
- Falls back gracefully when not

**Key insight:** By describing intent ("create a draft PR") instead of the tool (`gh pr create --draft`), Claude will automatically pick the best available method — MCP tools in Web, `gh` CLI locally, or skip gracefully if neither is available.

## 3. Approaches

| Approach | Pro | Contra |
|----------|-----|--------|
| A: Replace `gh` commands with intent-based language | Works everywhere, future-proof, simple | Loses explicit command examples |
| B: Add MCP alternatives alongside `gh` commands | Explicit about both options | Verbose, harder to maintain, couples to two tools instead of one |
| C: Keep `gh` but improve fallback documentation | Minimal change | Still couples to `gh` as primary, doesn't leverage Web MCP |

**Recommended: Approach A** — Replace tool-specific commands with intent-based descriptions. This is the simplest and most future-proof approach.

## 4. Risks & Constraints

- **No behavioral change**: Only text/documentation changes — the actual runtime behavior is already tool-agnostic (Claude picks the tool)
- **Spec version bumps**: Modified specs need `lastModified` and potentially `version` updates
- **Assumption section**: `artifact-pipeline/spec.md` line 352 has an assumption about `gh` CLI that needs updating
- **Existing tests.md files**: Prior change test artifacts reference `gh` CLI in scenarios — these are historical and should not be modified

## 5. Coverage Assessment

| Category | Status | Notes |
|----------|--------|-------|
| Scope | Clear | 5 files, text-only changes |
| Behavior | Clear | No behavioral changes — runtime already tool-agnostic |
| Data Model | Clear | N/A — no data model |
| UX | Clear | Better UX on Web, same on Desktop |
| Integration | Clear | MCP tools are automatic, no config needed |
| Edge Cases | Clear | Graceful degradation stays the same |
| Constraints | Clear | Must go through opsx:workflow, ADRs untouched |
| Terminology | Clear | "GitHub tooling" covers gh CLI, MCP tools, API |
| Non-Functional | Clear | N/A |

## 7. Decisions

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| 1 | Use "available GitHub tooling" as umbrella term | Covers gh CLI, MCP tools, REST API without coupling to any | "GitHub API", "PR tooling" |
| 2 | Keep `git branch -d` fallback wording as-is | It's the fallback for when *no* GitHub tooling works — already tool-agnostic | N/A |
| 3 | ADRs stay untouched | Historical records of decisions made at a point in time | Update ADRs to match new wording |
| 4 | CI workflow stays untouched | `gh` is the correct tool on GitHub Actions runners | Replace with REST API calls |
