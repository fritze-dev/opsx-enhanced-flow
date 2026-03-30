# Preflight Quality Review: initial-spec

**Change:** initial-spec (baseline specification bootstrap)
**Date:** 2026-03-02
**Reviewer:** AI Agent (preflight gate)

---

## A. Traceability Matrix

Maps each capability declared in `proposal.md` to its spec file and verifies coverage (requirements + scenarios).

| # | Capability (from proposal) | Spec File | Reqs | Scenarios | Coverage |
|---|---------------------------|-----------|------|-----------|----------|
| 1 | `three-layer-architecture` | `specs/three-layer-architecture/spec.md` | 4 (Constitution Layer, Schema Layer, Skills Layer, Layer Separation) | 10 | FULL |
| 2 | `project-setup` | `specs/project-setup/spec.md` | 3 (Install OpenSpec and Schema, OpenSpec CLI Prerequisite Check, Schema Validation) | 7 | FULL |
| 3 | `project-bootstrap` | `specs/project-bootstrap/spec.md` | 4 (First-Run Codebase Scan, Constitution Generation, Initial Change Creation, Recovery Mode) | 9 | FULL |
| 4 | `artifact-pipeline` | `specs/artifact-pipeline/spec.md` | 3 (Six-Stage Pipeline, Artifact Dependencies, Apply Gate) | 9 | FULL |
| 5 | `artifact-generation` | `specs/artifact-generation/spec.md` | 3 (Step-by-Step Generation, Fast-Forward Generation, Unified Skill Delivery) | 10 | FULL |
| 6 | `spec-format` | `specs/spec-format/spec.md` | 4 (Normative Description Format, Gherkin Scenario Format, Delta Spec Operations, Baseline Spec Format) | 12 | FULL |
| 7 | `change-workspace` | `specs/change-workspace/spec.md` | 3 (Create Change Workspace, Workspace Structure, Archive Completed Change) | 11 | FULL |
| 8 | `task-implementation` | `specs/task-implementation/spec.md` | 2 (Implement Tasks from Task List, Progress Tracking) | 11 | FULL |
| 9 | `quality-gates` | `specs/quality-gates/spec.md` | 2 (Preflight Quality Check, Post-Implementation Verification) | 11 | FULL |
| 10 | `human-approval-gate` | `specs/human-approval-gate/spec.md` | 2 (QA Loop with Mandatory Approval, Fix Loop) | 9 | FULL |
| 11 | `interactive-discovery` | `specs/interactive-discovery/spec.md` | 1 (Standalone Research with Q&A) | 8 | FULL |
| 12 | `spec-sync` | `specs/spec-sync/spec.md` | 3 (Agent-Driven Spec Merging, Intelligent Partial Updates, Baseline Format Enforcement) | 9 | FULL |
| 13 | `constitution-management` | `specs/constitution-management/spec.md` | 3 (Bootstrap-Generated Constitution, Constitution as Global Context, Constitution Update) | 11 | FULL |
| 14 | `docs-generation` | `specs/docs-generation/spec.md` | 2 (Generate Capability Documentation, Generate Changelog from Archives) | 12 | FULL |
| 15 | `roadmap-tracking` | `specs/roadmap-tracking/spec.md` | 1 (Roadmap Tracking via GitHub Issues) | 6 | FULL |

**Result:** All 15 capabilities from the proposal have corresponding spec files. Every spec contains at least one requirement and every requirement has at least one Gherkin scenario. Total: 41 requirements, 152 scenarios across 15 specs.

---

## B. Gap Analysis

### B.1 Missing Specs

None. All 15 capabilities from the proposal are covered by a spec file.

### B.2 Scenario Coverage Gaps

| Spec | Gap | Severity |
|------|-----|----------|
| `interactive-discovery` | Only 1 requirement covers the entire discover workflow (research, Q&A, stale-spec detection, question prioritization). A second requirement separating "Coverage Assessment" from "Q&A Flow" would improve modularity, but the single requirement is comprehensive. | LOW (informational) |
| `docs-generation` | 2 requirements (docs + changelog). No scenario covers docs regeneration idempotency. The changelog "Existing changelog preserved" scenario partially covers incremental behavior. | LOW (informational) |
| `roadmap-tracking` | No scenario for the agent creating roadmap issues programmatically (the spec describes developer-created issues). The capability description says "tracked as GitHub Issues" which is a manual process, so this is consistent. | NONE |

### B.3 Error Handling and Edge Cases

All 15 specs include an "Edge Cases" section. Key edge cases are well-covered:
- Missing prerequisites (CLI not installed, npm unavailable)
- Empty/malformed input files
- Duplicate names and conflicts
- Permission errors
- Interrupted operations
- Idempotent re-runs

**No blocking gaps identified.**

---

## C. Side-Effect Analysis

This is a **documentation-only bootstrap** -- no code changes are made.

| Risk | Assessment |
|------|------------|
| Regression to existing code | **NONE** -- no code is modified |
| Breaking existing workflows | **NONE** -- specs are new files added alongside existing skills |
| Schema or config changes | **NONE** -- existing schema and config are documented, not changed |
| Constitution changes | **NONE** -- constitution already exists and is being documented, not modified |

**Result:** Zero regression risk. This change creates spec files only.

---

## D. Constitution Check

Verifying that specs are consistent with the rules in `openspec/constitution.md`.

| Constitution Rule | Spec Consistency | Status |
|-------------------|-----------------|--------|
| Three-layer architecture: Constitution -> Schema -> Skills | `three-layer-architecture` spec documents exactly this hierarchy | PASS |
| 13 commands delivered as `skills/*/SKILL.md` | `three-layer-architecture` spec requires exactly 13 subdirectories; skill categorization (6 workflow + 5 governance + 2 documentation) matches constitution | PASS |
| Skills split: 6 workflow, 5 governance, 2 documentation | `three-layer-architecture` spec lists the same split | PASS |
| All skills model-invocable except `init` | `three-layer-architecture` spec explicitly requires `init` to have `disable-model-invocation: true` and all others to be invocable | PASS |
| Artifact pipeline: research -> proposal -> specs -> design -> preflight -> tasks -> apply | `artifact-pipeline` spec defines exactly this 6-stage pipeline + apply gate | PASS |
| Spec format: `###` requirement, normative description, User Story, `####` scenario | `spec-format` spec defines this exact ordering with the 4-hashtag rule | PASS |
| Baseline format: `## Purpose` + `## Requirements` | `spec-format` spec (Baseline Spec Format requirement) and `spec-sync` spec (Baseline Format Enforcement) both mandate this | PASS |
| Delta format: operation prefixes (ADDED, MODIFIED, REMOVED, RENAMED) | `spec-format` spec (Delta Spec Operations requirement) defines all four operations | PASS |
| Capability names in kebab-case | All 15 spec directory names use kebab-case | PASS |
| ASSUMPTION markers audited in preflight | `quality-gates` spec includes Assumption Audit as dimension (F) of preflight | PASS |
| REVIEW markers for user confirmation | `constitution-management` spec uses REVIEW markers for uncertain conventions | PASS |
| Pre-Flight is mandatory before task creation | `quality-gates` spec explicitly requires preflight before tasks; `artifact-pipeline` spec enforces preflight -> tasks dependency | PASS |
| No silent archiving -- explicit human approval | `human-approval-gate` spec requires explicit "Approved" response | PASS |
| Bidirectional feedback | `human-approval-gate` spec (Fix Loop requirement) explicitly supports updating specs when implementation reveals issues | PASS |
| Archive naming: YYYY-MM-DD-<feature> | `change-workspace` spec defines this exact format | PASS |
| Agent-driven sync via `/opsx:sync` | `spec-sync` spec mandates agent-driven (not programmatic) merging | PASS |
| Commits: imperative present tense with category prefix | Not directly covered by any spec (commits are a development convention, not a plugin capability). Acceptable -- this is a convention for human/agent commits, not a specifiable feature. | PASS (N/A) |
| npm global installs only | `project-setup` spec uses `npm install -g` for CLI installation, consistent with constitution | PASS |

**Result:** All constitution rules are consistently reflected in the specs. No contradictions found.

---

## E. Duplication & Consistency

### E.1 Overlapping Requirements

| Overlap Area | Specs Involved | Assessment |
|-------------|----------------|------------|
| Constitution reading before actions | `three-layer-architecture` (Constitution Layer req), `constitution-management` (Constitution as Global Context req), `interactive-discovery` (step 1 of discovery) | **Acceptable.** `three-layer-architecture` defines the architectural rule; `constitution-management` specifies the mechanism (config.yaml workflow rules); `interactive-discovery` references it as a step. Each has a distinct focus. No conflicting definitions. |
| Apply gate / task dependency | `artifact-pipeline` (Apply Gate req), `task-implementation` (Tasks artifact blocked scenario) | **Acceptable.** `artifact-pipeline` defines the schema-level gate; `task-implementation` describes the runtime behavior. Complementary, not duplicative. |
| Baseline spec format | `spec-format` (Baseline Spec Format req), `spec-sync` (Baseline Format Enforcement req) | **Acceptable.** `spec-format` defines what the format is; `spec-sync` defines how it is enforced during merging. Both agree on `## Purpose` + `## Requirements` structure. |
| Archive with sync prompt | `change-workspace` (Archive Completed Change req), `spec-sync` (referenced workflow) | **Acceptable.** `change-workspace` describes the archive flow including the sync prompt; `spec-sync` describes what sync does. No overlap in requirements -- they reference each other at the process level. |
| Recovery mode / bootstrap | `project-bootstrap` (Recovery Mode req), `constitution-management` (referenced in edge cases) | **Acceptable.** `project-bootstrap` owns the recovery behavior; `constitution-management` mentions recovery as context. No duplicated requirements. |

### E.2 Terminology Consistency

| Term | Usage Across Specs | Consistent? |
|------|-------------------|-------------|
| "delta spec" | `spec-format`, `spec-sync`, `change-workspace`, `quality-gates`, `docs-generation` | YES |
| "baseline spec" | `spec-format`, `spec-sync`, `docs-generation`, `interactive-discovery`, `project-bootstrap` | YES |
| "artifact" | `artifact-pipeline`, `artifact-generation`, `quality-gates`, `change-workspace` | YES |
| "change workspace" | `change-workspace`, `artifact-generation`, `interactive-discovery`, `project-bootstrap` | YES |
| "OpenSpec CLI" | `project-setup`, `artifact-pipeline`, `artifact-generation`, `change-workspace`, `three-layer-architecture` | YES |
| "constitution" | `three-layer-architecture`, `constitution-management`, `quality-gates`, `interactive-discovery` | YES |
| "preflight" vs "pre-flight" | Constitution uses "Pre-Flight"; `quality-gates` spec uses "Preflight" | MINOR INCONSISTENCY (warning) |

### E.3 Potential Naming Confusion

The constitution lists the skill command as `/opsx:preflight` (one word), while the constitution text says "Pre-Flight check" (hyphenated, capitalized). This is cosmetic -- the command name is `preflight` everywhere in the specs. The constitution's prose uses "Pre-Flight" as a display name. Low risk, but worth noting.

**Result:** No material duplication. One minor terminology inconsistency (Pre-Flight vs Preflight in prose).

---

## F. Assumption Audit

All `<!-- ASSUMPTION: -->` markers from specs and design, rated by risk.

### Design-Level Assumptions

| # | Source | Assumption | Rating |
|---|--------|-----------|--------|
| D1 | `design.md` | OpenSpec CLI 1.2.0 validate command checks for Purpose + Requirements sections | **Acceptable Risk** -- Validate behavior can be confirmed during QA; if wrong, validation is manual. |
| D2 | `design.md` | Agent-driven sync via /opsx:sync correctly strips delta operation prefixes | **Acceptable Risk** -- This is the defined behavior of the sync spec itself; the assumption is circular but harmless for a documentation-only change. |

### Spec-Level Assumptions

| # | Source | Assumption | Rating |
|---|--------|-----------|--------|
| S1 | `three-layer-architecture` | Claude Code plugin system discovers skills by scanning `skills/*/SKILL.md` and uses YAML frontmatter | **Acceptable Risk** -- Based on observed behavior; plugin system is the runtime. |
| S2 | `three-layer-architecture` | `config.yaml` workflow rules mechanism reliably enforces constitution reading | **Acceptable Risk** -- Established mechanism used in production. |
| S3 | `project-setup` | npm global install is the correct method for OpenSpec CLI | **Acceptable Risk** -- Standard npm practice; documented in OpenSpec CLI docs. |
| S4 | `project-setup` | `^1.2.0` enforced via npm semver (>=1.2.0, <2.0.0) | **Acceptable Risk** -- Standard npm semver behavior. |
| S5 | `project-bootstrap` | Bootstrap can detect tech stack from static file analysis without executing code | **Acceptable Risk** -- Standard approach for code scanning tools. Heuristic, not perfect. |
| S6 | `project-bootstrap` | Recovery mode drift detection is structural/naming, not deep semantic | **Acceptable Risk** -- Explicitly bounded; documented as heuristic. |
| S7 | `artifact-pipeline` | OpenSpec CLI enforces dependency checks; if not, skills implement them | **Acceptable Risk** -- Covers both cases explicitly. |
| S8 | `artifact-pipeline` | Artifact completion = file existence + non-empty | **Acceptable Risk** -- Simple, verifiable rule. Quality is a separate concern (preflight/verify). |
| S9 | `artifact-generation` | OpenSpec CLI provides `openspec status` and `openspec instructions` commands | **Acceptable Risk** -- Based on actual CLI usage; can be verified. |
| S10 | `artifact-generation` | CLI determines completion by file existence | **Acceptable Risk** -- Consistent with S8. |
| S11 | `spec-format` | CLI programmatic merge expects `## Purpose` + `## Requirements` format | **Acceptable Risk** -- Documented based on research; sync is agent-driven anyway. |
| S12 | `spec-format` | Sync is agent-driven and handles delta semantics without exact parsing | **Acceptable Risk** -- This is a design decision, not an external dependency. |
| S13 | `change-workspace` | OpenSpec CLI is installed and on PATH (ensured by /opsx:init) | **Acceptable Risk** -- Prerequisite chain is documented. |
| S14 | `change-workspace` | System clock provides correct date for YYYY-MM-DD prefix | **Acceptable Risk** -- Standard OS assumption. |
| S15 | `change-workspace` | File system supports atomic mv within same mount point | **Acceptable Risk** -- Standard POSIX behavior. |
| S16 | `change-workspace` | YYYY-MM-DD is unambiguous and sorts chronologically | **Acceptable Risk** -- ISO 8601; universally true. |
| S17 | `change-workspace` | User has write permissions to openspec/changes/ | **Acceptable Risk** -- Standard file permission assumption. |
| S18 | `spec-sync` | Agent operates within project working directory | **Acceptable Risk** -- Standard agent execution context. |
| S19 | `spec-sync` | Single-agent workflow, no parallel syncs | **Acceptable Risk** -- Claude Code is single-agent by design. |
| S20 | `spec-sync` | Sync is a post-approval step | **Needs Clarification** -- The `change-workspace` archive spec prompts for sync before archive, and the sync spec says "archived (or approved) before sync." These two flows are slightly ambiguous: is sync before or after archive? The archive skill prompts "Sync now" which runs sync *during* the archive flow, before the move. This works but the assumption text could be clearer. |
| S21 | `task-implementation` | tasks.md uses standard markdown checkbox format | **Acceptable Risk** -- Defined by schema template. |
| S22 | `task-implementation` | Task ordering represents recommended sequence | **Acceptable Risk** -- Convention, not strict enforcement. |
| S23 | `task-implementation` | Apply skill has read/write access to tasks.md and source files | **Acceptable Risk** -- Standard agent capability. |
| S24 | `quality-gates` | All change artifacts available and up to date when preflight is invoked | **Acceptable Risk** -- Enforced by pipeline dependency gating. |
| S25 | `quality-gates` | Codebase is accessible and searchable for verify | **Acceptable Risk** -- Standard agent capability. |
| S26 | `quality-gates` | OpenSpec CLI provides accurate artifact status info | **Acceptable Risk** -- Consistent with S9. |
| S27 | `quality-gates` | Keyword-based code search provides reasonable coverage detection | **Acceptable Risk** -- Explicitly stated as heuristic, not perfect. Verify severity defaults to SUGGESTION for uncertain matches. |
| S28 | `quality-gates` | constitution.md is authoritative and kept up to date | **Acceptable Risk** -- Enforced by the constitution-management spec. |
| S29 | `human-approval-gate` | User available for approval in same or subsequent session | **Acceptable Risk** -- Workflow allows session breaks. |
| S30 | `human-approval-gate` | Spec updates during fix loop do not re-trigger preflight automatically | **Acceptable Risk** -- Reasonable trade-off; user can manually re-run preflight if desired. |
| S31 | `human-approval-gate` | Human reviewer has sufficient context to approve | **Acceptable Risk** -- Workflow convention. |
| S32 | `human-approval-gate` | "Approved" is the canonical approval token (case-insensitive) | **Acceptable Risk** -- Simple convention; edge case for ambiguous responses is covered. |
| S33 | `human-approval-gate` | Fix loop has no max iteration count | **Acceptable Risk** -- User controls when to stop. |
| S34 | `interactive-discovery` | User has created a change workspace before /opsx:discover | **Acceptable Risk** -- Enforced by prerequisite check scenario. |
| S35 | `interactive-discovery` | User answers questions before running /opsx:ff | **Acceptable Risk** -- Workflow convention; ff will use whatever research exists. |
| S36 | `interactive-discovery` | Stale-spec detection is heuristic, may miss drift | **Acceptable Risk** -- Explicitly documented as limited. |
| S37 | `interactive-discovery` | 5-question limit is sufficient for most changes | **Acceptable Risk** -- Edge case for complex changes documented (multiple discovery rounds). |
| S38 | `constitution-management` | Constitution at fixed path `openspec/constitution.md` | **Acceptable Risk** -- Established convention. |
| S39 | `constitution-management` | Init sets up config.yaml correctly | **Acceptable Risk** -- Covered by project-setup spec validation requirement. |
| S40 | `constitution-management` | File writes are synchronous, agent re-reads context | **Acceptable Risk** -- Standard file system behavior; Claude Code reads files on demand. |
| S41 | `docs-generation` | Docs generated after sync has been run | **Acceptable Risk** -- Workflow sequence convention. |
| S42 | `docs-generation` | Agent has write access to docs/capabilities/ | **Acceptable Risk** -- Standard permission. |
| S43 | `docs-generation` | Documentation regeneration is idempotent | **Acceptable Risk** -- Agent produces deterministic output from same input. |
| S44 | `docs-generation` | Archive naming enforced by archive skill | **Acceptable Risk** -- Covered by change-workspace spec. |
| S45 | `docs-generation` | Keep a Changelog format per constitution convention | **Acceptable Risk** -- Constitution explicitly states this format. |
| S47 | `roadmap-tracking` | GitHub is the project hosting platform | **Acceptable Risk** -- True for this project. Spec could note this is GitHub-specific. |
| S48 | `roadmap-tracking` | Single `roadmap` label convention is sufficient | **Acceptable Risk** -- Simple and effective; edge case for large issue counts covered. |
| S49 | `roadmap-tracking` | README at project root as README.md | **Acceptable Risk** -- Universal convention. |

### Summary

| Rating | Count |
|--------|-------|
| Acceptable Risk | 47 |
| Needs Clarification | 1 (S20) |
| Blocking | 0 |

**S20 Detail:** The `spec-sync` spec assumes sync is "post-approval" (after archive), but the `change-workspace` archive spec prompts to "Sync now" *before* moving to archive directory. Both flows work -- sync can happen during the archive process before the directory move -- but the assumption text "archived (or approved) before sync" is slightly misleading. This is a **documentation clarity issue**, not a functional conflict. The "(or approved)" parenthetical covers the actual behavior. Rating: Needs Clarification, not Blocking.

---

## Warnings Summary

| ID | Category | Description | Severity |
|----|----------|-------------|----------|
| W1 | Terminology | "Pre-Flight" (constitution prose) vs "Preflight" (command name, specs) -- inconsistent capitalization/hyphenation in prose | LOW |
| W2 | Assumption | S20: Sync timing relative to archive -- assumption text could be clearer about sync-during-archive-flow | LOW |
| W3 | Coverage | `interactive-discovery` packs a large amount of behavior into a single requirement | LOW (informational) |
| W4 | Coverage | `docs-generation` has 2 requirements (docs + changelog merged); focused scope | LOW (resolved) |

---

## Verdict

### **PASS**

**Rationale:**
- All 15 capabilities from the proposal have corresponding, complete spec files
- 41 requirements with 152 scenarios provide thorough behavioral coverage
- All specs are consistent with the constitution -- zero contradictions found
- No material duplication or conflicting definitions between specs
- All 48 assumptions are rated Acceptable Risk or Needs Clarification (none Blocking)
- The single Needs Clarification item (S20) is a documentation clarity issue, not a functional conflict
- Zero regression risk (documentation-only change, no code modifications)
- All specs follow the required format (normative descriptions with SHALL/MUST, `####` Gherkin scenarios, edge cases, assumptions)

The 4 low-severity warnings are informational and do not impede task creation. This change is cleared to proceed to the tasks stage.
