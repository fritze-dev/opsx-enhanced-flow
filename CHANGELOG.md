# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/).

## 2026-04-10 — Init Health Check Fixes (v2.0.2)

### Fixed
- Three-layer-architecture spec: "6-stage" → "7-stage" pipeline and added "review" to the artifact ID list in Schema Layer requirement and scenario
- Upstreamed `tasks.md` template customizations (Pre-Merge/Post-Merge subsection handling, Section 5) to `src/templates/tasks.md` with template-version bump to v2
- Upstreamed `specs/spec.md` template customization (implementation-detail prohibition) to `src/templates/specs/spec.md` with template-version bump to v2
- Added missing custom action hint comments to `openspec/WORKFLOW.md` after `actions:` array

## 2026-04-10 — Custom Actions (v2.0.1)

### Added
- Consumer-defined custom actions in WORKFLOW.md — projects can extend the workflow by adding action names to the `actions` array and providing `## Action: <name>` body sections with self-contained instructions
- Generic fallback dispatch in the router — custom actions are validated against the `actions` array and executed directly, with the agent deciding whether to handle inline or spawn a sub-agent
- Graceful degradation when WORKFLOW.md is missing — the router falls back to the 4 built-in actions (init, propose, apply, finalize) so that init works without a pre-existing WORKFLOW.md

### Changed
- Router Step 1 now validates actions dynamically against the `actions` array from WORKFLOW.md instead of a hardcoded list
- CONSTITUTION.md Architecture Rules updated from "4 actions" to "4 built-in actions + consumer-defined custom actions"
- Consumer WORKFLOW.md template includes a comment explaining custom action usage

## 2026-04-09 — Skill Consolidation (v2.0.0)

### Added
- Single workflow skill (`/opsx:workflow <action>`) replaces 11 separate skill files — 4 actions: `init`, `propose`, `apply`, `finalize`
- `review.md` pipeline artifact — verification report persisted in the change directory, visible in PRs, not skippable
- 7-stage pipeline: research → proposal → specs → design → preflight → tasks → review
- Inline action definitions in WORKFLOW.md body with clickable requirement links to specs in the skill
- `auto_approve` config in WORKFLOW.md for fully autonomous pipeline execution
- GitHub Actions CI pipeline (`.github/workflows/pipeline.yml`) — triggers finalize automatically on PR approval
- `project-init` spec (merges project-setup + project-bootstrap)
- `documentation` spec (merges user-docs + architecture-docs + decision-docs)

### Changed
- **BREAKING**: 13 commands consolidated to 4 (`/opsx:workflow init`, `propose`, `apply`, `finalize`)
- **BREAKING**: WORKFLOW.md template-version 1 → 3 with actions array and action body sections
- Architecture Layer 3 updated from "11 Skills" to "single workflow skill with 4 actions"
- Post-artifact commit logic moved from WORKFLOW.md body to skill internals

### Removed
- 10 standalone skill files (new, ff, verify, discover, preflight, changelog, docs, docs-verify, bootstrap, setup)
- `interactive-discovery` spec (0/49 usage — discover was never adopted)
- 5 merged specs (project-setup, project-bootstrap, artifact-generation, user-docs, architecture-docs, decision-docs)

## 2026-04-09 — Worktree Fetch Latest Main

### Changed
- `/opsx:new` now fetches the latest remote main before creating a worktree — new branches are based on `origin/main` instead of the potentially stale local HEAD, preventing avoidable merge conflicts (closes #95)

## 2026-04-09 — Verify Content-Level Check

### Changed
- `/opsx:verify` now reads implementation files and compares content against spec requirements instead of relying on shallow keyword matching — terminology mismatches, stale headings, and incomplete coverage are now detected by reading the relevant sections and comparing them against spec language (closes #93)
- Verification heuristics updated to prioritize content comparison over keyword search — keyword search is now used only for initial file discovery, not as the primary verification method

## 2026-04-08 — Spec Frontmatter Tracking

### Added
- Spec tracking frontmatter (`status`, `change`, `version`, `lastModified`) — skills now track which specs are being edited, by which change, and detect collisions when two changes touch the same spec
- Proposal frontmatter (`status`, `branch`, `worktree`, `capabilities`) — machine-readable change lifecycle metadata replaces fragile markdown section parsing across all skills
- Design frontmatter (`has_decisions`) — docs and docs-verify skip designs without decision tables instead of scanning for markdown tables
- Template versioning (`template-version` field) on all Smart Templates, WORKFLOW.md, and CONSTITUTION.md — enables merge detection during `/opsx:setup` (closes #67)
- Template merge on re-setup — customized local templates are preserved when the plugin updates, with interactive conflict resolution when both sides changed
- CONSTITUTION.md section-level merge — new template sections are offered for interactive generation while preserving user content
- Verify draft gate — specs with `status: draft` are blocked from reaching main, ensuring no incomplete edits are merged
- Preflight dimension G (Draft Spec Validation) — validates that draft specs belong to the current change

### Changed
- Change context detection now uses proposal `branch` field as primary lookup, falling back to worktree convention — more reliable across all 5 change-detecting skills (closes #78)
- Active/completed change detection now uses proposal `status` field instead of parsing tasks.md checkboxes — instant detection without file scanning
- Lazy worktree cleanup now checks proposal `status: completed` before falling back to GitHub API calls
- Docs incremental detection now uses spec `lastModified` instead of comparing directory-name dates against proposal Capabilities parsing
- Changelog completed-change detection uses proposal `status` instead of tasks.md checkbox parsing
- All capability-identifying skills (verify, preflight, docs, changelog, apply, docs-verify) now read proposal `capabilities` frontmatter instead of parsing `## Capabilities` markdown sections
- WORKFLOW.md setup behavior changed from skip-if-exists to version-based merge detection

## 2026-04-08 — Fix Workflow Friction Batch 2

### Changed
- Specs template now explicitly prohibits implementation details (concrete commands, file paths, API calls) — specs describe behavior only, implementation belongs in SKILL.md or design.md
- Apply workflow now enforces verify re-run after any fix-loop change — Final Verify (step 3.5) must not be skipped when the fix loop was entered
- Apply workflow now requires updating stale artifacts when a fix resolves a flagged issue — preflight verdicts and design notes must reflect current state
- Apply workflow now checks docs for stale terminology before user testing — when specs change terminology, docs and README references are flagged early instead of waiting for `/opsx:docs` regeneration

## 2026-04-08 — Diff-Based Verification

### Changed
- `/opsx:verify` now uses the branch diff as its **primary evidence source** — instead of only searching the codebase with keywords, verification reads the actual diff content to assess whether changes match requirement intent (closes #83)
- Verify flow restructured from 10 steps to 6 — three dimensions (Completeness, Correctness, Coherence) consolidated into two: **Implementation** (Completeness + Correctness) and **Scope** (Coherence + Side-Effects)
- Task-Diff Mapping now checks file paths AND diff content — a file-level match alone is no longer sufficient; the diff content must relate to the task description
- Requirement verification checks both existence and correctness in a single pass using diff evidence, with codebase keyword search as fallback for pre-existing code

### Added
- Diff Scope Check — flags files in the diff not covered by any task or design component as a grouped suggestion
- Task-Diff Mapping — detects tasks marked complete that produced no corresponding changes in the diff
- Graceful skip when no merge base is available (orphan branch, first commit) — diff checks are skipped with a note, keyword-based verification proceeds as normal

## 2026-04-08 — Fix Friction Batch

### Changed
- QA Loop's Metric Check and Auto-Verify steps are now explicitly marked as automated — the agent runs them without pausing for confirmation, only stopping at User Testing for human approval (closes #81)
- `/opsx:verify` now auto-fixes mechanically fixable WARNINGs (stale artifact cross-references, inconsistent naming) inline before presenting the report — judgment-required WARNINGs still require user resolution (closes #86)
- Post-merge worktree cleanup now happens immediately after a successful merge from within a worktree — the agent switches to the main worktree, removes the completed worktree, and deletes the branch instead of leaving cleanup for the next `/opsx:new` (closes #88)
- Consumer template `apply.instruction` synced with project WORKFLOW.md — pre-existing drift (missing "version bump" step, extra redundant verify reminder) resolved

### Added
- "Template synchronization" convention in the constitution — changes to WORKFLOW.md behavior fields must be mirrored to the consumer template at `src/templates/workflow.md` (closes #87)

## 2026-04-07 — Commit Before Approval

### Changed
- Implementation changes are now committed and pushed after `/opsx:verify` passes and before the user is asked for approval — the PR diff is available for review instead of asking the user to approve uncommitted local changes (closes #82)
- QA Loop steps in the human-approval-gate spec are now referenced by semantic name (Metric Check, Auto-Verify, User Testing, etc.) instead of hardcoded step numbers — template renumbering no longer requires spec updates

## 2026-04-07 — Post-Merge Reminder Format

### Changed
- Post-merge items in generated task lists now use plain bullet format instead of unchecked checkboxes — they are visual reminders, not tracked tasks, and no longer count toward progress totals
- Post-merge reminders appear in a dedicated "Post-Merge Reminders" section, separate from the Standard Tasks section
- Constitution and bootstrap templates updated with Pre-Merge / Post-Merge subsection structure

## 2026-04-07 — Fix Stale Spec References

### Fixed
- ~60 stale references across 10 spec files updated to reflect the current project structure after the schema directory elimination — `config.yaml` → `WORKFLOW.md`, `openspec/schemas/` → `openspec/templates/`, `constitution.md` → `CONSTITUTION.md`
- Auto-bump requirement now correctly references `src/.claude-plugin/plugin.json` instead of the nonexistent `.claude-plugin/plugin.json`
- Historical references to eliminated files removed from workflow-contract and artifact-pipeline specs — only project-setup retains old paths for its active legacy migration feature

## 2026-03-30 — Eliminate Delta-Specs, Sync & Archive

### Changed
- **BREAKING**: Specs are now edited directly at `openspec/specs/` during the specs stage — the delta spec format (ADDED/MODIFIED/REMOVED sections) has been eliminated entirely
- **BREAKING**: Post-apply workflow simplified to verify → changelog → docs — sync and archive steps are no longer needed
- Change directories now use a creation-date prefix (`YYYY-MM-DD-<name>`) and remain flat under `openspec/changes/` — no more archive subdirectory
- Active vs. completed changes are distinguished by tasks.md status (open checkboxes vs. all checked) instead of directory location
- Changelog and docs now read proposal.md and current baseline specs instead of archived delta specs
- Docs incremental detection uses proposal Capabilities section to identify affected capabilities
- Worktree cleanup moved to lazy detection at `/opsx:new` — stale worktrees from merged PRs are cleaned up automatically when creating new changes

### Removed
- `/opsx:sync` skill — agent-driven delta spec merging is no longer needed
- `/opsx:archive` skill — completed changes stay in place, no directory move required
- `spec-sync` capability spec — the entire domain (delta spec merging) has been eliminated

## 2026-03-30 — Fix Archive Unstaged Deletions

### Fixed
- `/opsx:archive` now stages the old change directory deletions after moving to archive — previously, the `mv` command left unstaged deletions in the working tree requiring a manual follow-up commit

## 2026-03-30 — Fix Background Sync Race Condition

### Fixed
- Spec sync during `/opsx:archive` no longer races with the archive commit — the sync subagent prompt now conveys that sync is a blocking prerequisite, preventing background or parallel execution
- Archive now validates that all delta spec capabilities have corresponding baseline specs before proceeding — if any are missing, archive is blocked and the missing capabilities are reported

## 2026-03-30 — Fix Issue Reference in PR Body

### Fixed
- PR body update during pre-merge standard task now explicitly requires including GitHub issue-closing keywords (`Closes #X`) when the change originated from a GitHub issue — previously, updating the PR body overwrote the initial `Closes #X` reference, leaving issues open after squash merge

## 2026-03-30 — Fix Squash Merge Cleanup

### Fixed
- Worktree branch deletion after archive no longer fails when the PR was squash-merged — the system now checks PR merge status via GitHub before deleting the branch, using force delete when the merge is confirmed
- Graceful fallback when `gh` CLI is unavailable or no PR exists — reverts to standard branch deletion to preserve existing behavior

## 2026-03-30 — Auto-Sync Before Archive

### Changed
- `/opsx:archive` now automatically syncs delta specs to baseline before archiving — the previous "Sync now / Archive without syncing" prompt has been removed, eliminating unnecessary friction in the post-apply workflow
- Sync summary is still displayed so users see what was applied to baseline specs
- If sync fails, archive is blocked and the error is reported — archiving with unsynced specs is no longer possible

## 2026-03-30 — Worktree-Based Change Lifecycle

### Added
- Git worktree isolation for parallel changes — `/opsx:new` creates a dedicated worktree with its own feature branch when worktree mode is enabled, eliminating merge conflicts between concurrent changes (closes #61, closes #59)
- Automatic worktree context detection — all change-detecting skills (`ff`, `apply`, `verify`, `archive`, `sync`, `discover`, `preflight`) derive the active change from the current branch when running inside a worktree
- Worktree cleanup after archive — `/opsx:archive` automatically removes the worktree and merged branch when `auto_cleanup` is enabled
- Environment checks during `/opsx:setup` — detects git version (2.5+ for worktree support), `gh` CLI availability and authentication, and `.gitignore` coverage for the `.claude/` directory
- GitHub merge strategy configuration — `/opsx:setup` offers to configure rebase-merge for cleaner linear history with worktree-based workflows
- WORKFLOW.md template file — pipeline configuration is now maintained as a template at `src/templates/workflow.md`, consistent with the constitution template pattern

### Changed
- `/opsx:setup` copies WORKFLOW.md from the plugin template instead of generating it inline — easier to maintain and update across versions
- Post-artifact commit hook is now worktree-aware — skips branch creation when already on a feature branch in a worktree
- WORKFLOW.md gains an optional `worktree:` configuration section with `enabled`, `path_pattern`, and `auto_cleanup` fields
- Skills layer spec no longer uses a hardcoded skill count — lists skill names without a fixed total to prevent drift when skills are added

## 2026-03-26 — Documentation Drift Verification

### Added
- `/opsx:docs-verify` command that checks generated documentation against current specs and reports drift — capability docs are verified against spec Purpose and Requirements, ADRs against archived design decisions, and the README against the constitution and capabilities list (closes #32)
- Three-level severity classification (CRITICAL/WARNING/INFO) with verdicts: CLEAN, DRIFTED, or OUT OF SYNC
- Graceful handling of missing documentation directories — the skill reports what's missing instead of erroring

### Changed
- Quality gates spec extended with a third gate — documentation drift verification joins preflight (pre-implementation) and verify (post-implementation) as the post-docs-generation quality check

## 2026-03-26 — Auto GitHub Releases

### Added
- Automatic GitHub Releases — a GitHub Action creates a git tag and release whenever a version bump is pushed to `main`, using the latest changelog entry as the release body
- Consumer version pinning — consumers can pin to a specific version when adding the marketplace (e.g., `#v1.0.30`)
- Local marketplace workflow for developers — register the local repo as marketplace source for live plugin development in VS Code and CLI
- Plugin source directory (`src/`) — plugin files (skills, templates, manifest) are separated from project files (docs, CI, specs); consumer caches contain only plugin files

### Changed
- **BREAKING**: Plugin source moved from repo root into `src/` — consumers need to run `plugin update` to switch to the new layout
- Marketplace source changed from `"./"` to `"./src"` — points to the plugin subdirectory
- `/opsx:setup` template path updated to `${CLAUDE_PLUGIN_ROOT}/templates/` (was `openspec/templates/`)
- DevContainer now uses local marketplace instead of GitHub clone for development
- Release process simplified — push triggers automatic tagging and release creation; manual `git tag` + `gh release create` no longer needed for patch releases

## 2026-03-26 — Verify Preflight Side-Effect Cross-Check

### Changed
- `/opsx:verify` now reads `preflight.md` and cross-checks side-effects from Section C against task entries and codebase evidence — side-effects that were documented in preflight but never captured as tasks are now caught as WARNING issues (closes #53)
- Verification report summary scorecard includes a new "Side-Effects" row showing how many were checked and how many remain unaddressed
- Side-effects assessed as "NONE" in the preflight are automatically filtered out — no false warnings for non-risks

## 2026-03-26 — Dissolve Schema Directory

### Added
- `openspec/WORKFLOW.md` — slim pipeline orchestration file with YAML frontmatter replacing `schema.yaml` and `config.yaml`
- Smart Templates — every template now carries its own instruction, output path, dependencies, and description in YAML frontmatter alongside the output structure
- Legacy migration in `/opsx:setup` — automatically detects old `schema.yaml` layout and converts to WORKFLOW.md + Smart Templates
- `/opsx:ff` now supports selecting existing changes (adopted from the removed `/opsx:continue`)

### Changed
- **BREAKING**: `openspec/schemas/opsx-enhanced/` directory dissolved — pipeline definition moves to WORKFLOW.md, artifact instructions move into Smart Template frontmatter
- **BREAKING**: `openspec/config.yaml` removed — settings absorbed into WORKFLOW.md frontmatter (`context`, `docs_language`)
- **BREAKING**: `openspec/constitution.md` renamed to `openspec/CONSTITUTION.md` (caps)
- **BREAKING**: `/opsx:continue` merged into `/opsx:ff` — ff is now the sole artifact generation command
- Three-layer architecture updated: CONSTITUTION.md → WORKFLOW.md + Smart Templates → Skills (previously Constitution → Schema → Skills)
- All 12 skills read WORKFLOW.md and Smart Templates instead of schema.yaml and config.yaml
- `/opsx:setup` generates WORKFLOW.md + copies Smart Templates instead of schema directory

### Removed
- `openspec/schemas/opsx-enhanced/` directory (schema.yaml, README.md, templates/)
- `openspec/config.yaml`
- `/opsx:continue` skill (merged into `/opsx:ff`)

## 2026-03-25 — Post-Artifact Commit and PR Integration

### Changed
- **BREAKING**: Draft PR is no longer created during the proposal step — instead, a schema-level `post_artifact` hook commits and pushes after every artifact, with the branch and draft PR created on the first commit (closes #51)
- **BREAKING**: Proposal template no longer includes a `## Pull Request` section — PR metadata is available on-demand via `gh pr view` from the current branch
- Every artifact now gets its own commit, providing granular git history and incremental visibility in the draft PR
- `/opsx:continue` and `/opsx:ff` now read and execute the schema's `post_artifact` instructions after each artifact creation

### Removed
- PR creation block from proposal instruction in the schema — replaced by the universal `post_artifact` hook
- `## Pull Request` section from the proposal template

## 2026-03-25 — Remove CLI Dependency

### Changed
- **BREAKING**: The OpenSpec CLI (`@fission-ai/openspec`) is no longer required — all skills now read the schema and templates directly from local files, eliminating the Node.js/npm prerequisite
- `/opsx:setup` no longer installs external tools — it only copies schema files into the project and creates the config
- Artifact status is now determined by checking whether output files exist, instead of querying a CLI command
- Change creation, listing, and archiving use standard filesystem operations (`mkdir`, directory listing, `mv`) instead of CLI wrappers

### Removed
- Node.js and npm are no longer prerequisites for using the plugin
- OpenSpec CLI prerequisite check removed from `/opsx:setup`
- Node.js feature removed from the development container configuration

## 2026-03-25 — Context Loading Guardrails

### Added
- Research phase now includes context-loading guardrails — explicit guidance on which artifacts to read (baseline specs, docs README), which to consult conditionally (ADRs via the Key Design Decisions index), and which to skip (archived changes, capability docs) to maximize context window efficiency (closes #17)

## 2026-03-25 — Add PR Step

### Added
- Draft pull request is automatically created during the proposal step — a feature branch is pushed and a draft PR opened via `gh` for early team visibility and review
- Proposal template now includes a Pull Request section recording the branch name, PR URL, and status
- Constitution standard tasks are split into pre-merge (executed automatically) and post-merge (manual reminders) categories

### Changed
- Post-apply workflow now executes constitution-defined pre-merge standard tasks after commit and push — post-merge tasks remain as unchecked reminders
- Graceful degradation when `gh` CLI is unavailable — branch is created but PR creation is skipped without blocking the pipeline

## 2026-03-25 — Constitution Template

### Changed
- Constitution section structure is now defined by a schema template instead of being hardcoded in the bootstrap skill — enables per-schema constitution variants and is consistent with the existing template system (closes #48)
- Bootstrap now uses the template as a flexible starting structure — sections can be added, omitted, or restructured to fit each project's needs

### Added
- Constitution template at `templates/constitution.md` in the schema directory with recommended sections (Tech Stack, Architecture Rules, Code Style, Constraints, Conventions, Standard Tasks)

## 2026-03-25 — Fix Standard Tasks Commit Order

### Fixed
- Standard task checkboxes (archive, changelog, docs, commit) are now marked complete before the final commit — the committed tasks.md reflects the fully-checked state, eliminating the extra follow-up commit (closes #49)

## 2026-03-25 — Bootstrap Standard Tasks Section

### Changed
- Bootstrap now generates a `## Standard Tasks` section in the constitution during first run — new projects are immediately aware of the feature and know where to define project-specific post-implementation steps (closes #47)
- Constitution management spec updated to recognize Standard Tasks as a retained section alongside Tech Stack, Architecture Rules, Code Style, Constraints, and Conventions

## 2026-03-24 — Visible Assumptions & REVIEW Auto-Resolution

### Changed
- Assumptions in specs are now always visible in Markdown preview — each assumption appears as a readable list item followed by a machine-parseable tag (closes #46)
- Preflight quality check now audits both assumption visibility and unresolved REVIEW markers — invisible assumptions and leftover REVIEW markers are flagged as blockers
- Bootstrap skill now actively resolves uncertain items during constitution generation — each `<!-- REVIEW -->` marker is presented to the user for confirmation and removed after the decision is documented
- Docs skill now actively resolves broken ADR references instead of leaving invisible markers — broken spec or archive links are fixed interactively with the user

### Added
- Assumption Marker Format requirement in the spec-format spec — defines the correct format and flags invisible assumptions as violations
- Review Marker Audit section in the preflight template — scans for unresolved `<!-- REVIEW -->` markers as a separate quality dimension
- REVIEW auto-resolution step in the bootstrap skill (Step 2b) — iterates markers, asks user, documents decisions, removes markers before proceeding

## 2026-03-24 — Standard Tasks

### Added
- Universal post-implementation steps (archive, changelog, docs, commit and push) are now included as trackable checkboxes in every generated task list — no more forgetting post-apply workflow steps (closes #12)
- Project-specific extras can be defined in the constitution's `## Standard Tasks` section and are appended after the universal steps
- Apply skill explicitly excludes standard tasks from implementation scope — they are tracked for auditability but executed separately after apply completes

### Changed
- Post-archive convention prose trimmed — "next steps" workflow replaced by the standard tasks section; auto-bump mechanism description preserved

## 2026-03-24 — Optimize Docs Regeneration

### Added
- `/opsx:docs` now accepts a comma-separated list of capability names (e.g., `/opsx:docs artifact-pipeline,artifact-generation`) — only the listed capabilities are regenerated, skipping the full archive date scan
- Multi-capability mode designed for the post-archive workflow where affected capabilities are already known, significantly reducing unnecessary archive scanning

### Changed
- Change detection in `/opsx:docs` now distinguishes three modes: no argument (full incremental scan), single capability (existing behavior), and multi-capability (new, skips date scan for unlisted capabilities)

## 2026-03-24 — Consolidation Guidance

### Added
- Capability granularity rules in proposal instructions — defines what constitutes a "capability" (cohesive behavior domain) vs. a "feature detail" (single behavior within an existing spec), with merge and minimum-scope heuristics (closes #45)
- Mandatory consolidation check before finalizing proposal capabilities — agents must verify overlap with existing specs, check pair-wise overlap between new capabilities, and confirm each capability has 3+ distinct requirements
- Consolidation Check section in the proposal template — makes the agent's consolidation reasoning visible and reviewable
- Overlap verification step in the specs creation instructions — catches any remaining overlap before spec files are created

### Changed
- `/opsx:continue` specs creation guideline now includes consolidation-awareness — verifies the proposal's Consolidation Check before creating spec files

## 2026-03-23 — Streamline ADR Format

### Changed
- ADR Decision section now includes rationale inline using the em-dash pattern — the separate Rationale section has been removed from the template (closes #24)
- ADR template formalized: both consolidated and single-decision ADRs use the same inline-rationale format
- Key Design Decisions table in the documentation README now sources all data directly from ADR files instead of archived design artifacts — ADRs are the single canonical source
- Language-aware ADR generation updated to 6 section headings (Rationale heading removed)

## 2026-03-23 — Smart Workflow Checkpoints

### Changed
- `/opsx:continue` now auto-continues through routine transitions (research→proposal→specs→design) without pausing — only stops at mandatory review checkpoints
- `/opsx:ff` now pauses on preflight PASS WITH WARNINGS and requires explicit user acknowledgment before generating tasks — warnings are no longer auto-accepted
- Post-apply workflow enforces verify-before-sync ordering — `/opsx:verify` must run before `/opsx:archive` to prevent baseline spec modification before validation

### Added
- Checkpoint model for workflow transitions classifying each step as auto-continue or mandatory-pause
- Mandatory-pause checkpoints: design review, preflight warnings, discovery Q&A
- Verify-before-sync guard in apply instruction

## 2026-03-23 — Fix Apply Baseline Edits

### Fixed
- Task generation no longer includes tasks that edit baseline specs (`openspec/specs/`) — spec changes now flow exclusively through delta specs and `/opsx:sync`
- Apply skill no longer modifies baseline spec files during implementation — a new guardrail prevents direct edits

### Added
- Baseline spec exclusion requirement in the task-implementation spec with formal Gherkin scenarios

## 2026-03-23 — Fix ADR Reference Quality

### Changed
- ADR References now contain only internal relative links (archive backlinks, spec links, ADR cross-references) — external URLs like GitHub issue links are no longer included, as the archive backlink provides traceability to issues via the archive's proposal.md
- ADR generation now validates all spec and archive links after writing — broken links to renamed or split specs are automatically replaced with successors

### Added
- Cross-reference heuristic for related ADRs — when an ADR modifies a system established by an earlier ADR, a back-reference is added automatically
- Reference validation catches broken spec links (e.g., renamed specs) and missing archive directories

## 2026-03-23 — Improve Docs Efficiency

### Changed
- `/opsx:docs` now runs incrementally by default — only capabilities with newer archives are regenerated, unchanged capabilities are skipped entirely (closes #22)
- ADR generation is now incremental — existing ADRs are preserved, only new archives produce new ADR files
- README is only regenerated when capability docs, ADRs, or constitution content actually changed
- Capability doc `lastUpdated` timestamps are no longer bumped when regeneration produces identical content (closes #42)
- Related decisions from the same archive are now consolidated into a single ADR with numbered sub-decisions instead of producing one ADR per table row (closes #44)

### Added
- ADR References now include a backlink to the source archive directory for traceability (closes #30)
- Constitution drift detection — README regenerates automatically when constitution content diverges from what's in the README
- Output summary now shows three categories: regenerated, skipped (unchanged content), and skipped (no newer archives)

## 2026-03-23 — Rename Init Skill to Setup

### Changed
- **BREAKING**: Project setup command renamed from `/opsx:init` to `/opsx:setup` — the previous name conflicted with Claude Code's built-in `/init` command and was unavailable to users (closes #31)
- All skill error messages, specs, and documentation now reference `/opsx:setup` instead of `/opsx:init`

## 2026-03-05 — Fix Docs Regeneration Quality

### Fixed
- ADR Context sections no longer lose depth when regenerated from scratch — Step 4 now independently reads full `design.md`, `research.md`, and `proposal.md` for each archive (closes #28)
- Capability docs no longer drop Known Limitations and Future Enhancements sections — "space-constrained" priority rule replaced with data-driven section inclusion (closes #29)

### Changed
- Each `/opsx:docs` step now reads its own source materials independently — no implicit dependencies between steps
- ADR generation explicitly reads archive Context, Architecture, and Risks sections for richer Consequences
- ADR References determined by checking each archive's `specs/` subdirectory for affected capabilities
- Behavior section depth now matches spec scenario count — distinct Gherkin scenario groups are not merged

## 2026-03-05 — Fix Docs Skill Regressions

### Fixed
- Phantom ADR no longer generated from archives with prose-only or non-Decisions tables in design.md
- Manual ADR (`adr-M001-init-model-invocable.md`) no longer lost during docs regeneration
- ADR slug generation is now deterministic — consistent file names across regeneration runs
- ADR references now use descriptive link text instead of raw file paths

### Changed
- Manual ADRs (`adr-MNNN-slug.md` naming) are now preserved during regeneration and included in the README design decisions table
- Capability doc Rationale sections use present tense and no longer narrate change history
- Multi-command capabilities now include command names in behavior section headers for quick scanning
- Initial-spec-only capabilities now derive Rationale from spec requirements when archive research data is thin
- README capability descriptions limited to 80 characters / 15 words for scannability
- Notable Trade-offs section now aims to represent every ADR with a substantive negative consequence

## 2026-03-05 — Configurable Docs Language

### Added
- Documentation language is now configurable via `docs_language` in `openspec/config.yaml` — set to any language name (e.g., "German", "French") and `/opsx:docs` generates all capability docs, ADRs, and the consolidated README in that language
- `/opsx:changelog` generates new entries in the configured language, including translated section headers (e.g., "Hinzugefügt" instead of "Added" for German)
- New projects created with `/opsx:init` include a commented-out `docs_language` field for discoverability
- Workflow artifacts (research, proposal, specs, design, preflight, tasks) are now explicitly enforced to be English via the config context field, regardless of documentation language

### Changed
- Init skill config template expanded with `docs_language` field and English-enforcement rule for internal artifacts
- `/opsx:docs` and `/opsx:changelog` now read the `docs_language` setting before generating output
- Product names (OpenSpec, Claude Code), commands, file paths, and YAML frontmatter keys remain in English regardless of configured language

## 2026-03-05 — Improve Docs Sections

### Added
- "Future Enhancements" section in capability docs for deferred features and tracked GitHub Issues, separate from Known Limitations
- "Read before write" guardrail — `/opsx:docs` now reads existing docs before regenerating, preserving established tone and quality
- Purpose BAD/GOOD examples in the capability doc template to prevent change-motivation from replacing capability-purpose

### Changed
- Capability doc headings unified: "Why This Exists" → "Purpose", "Background"/"Design Rationale" → "Rationale" across all 18 docs
- Purpose sections now always derive from the capability's spec Purpose using problem-framing, never from archive proposal "Why" sections
- Non-Goals from design artifacts are now classified into Known Limitations (current constraints) and Future Enhancements (deferred features)
- Enriched section order standardized: Overview, Purpose, Rationale, Features, Behavior, Known Limitations, Future Enhancements, Edge Cases

### Fixed
- 11 Rationale sections that had replaced design reasoning with change-event descriptions reverted to original content
- 4 Purpose sections that had been weakened during regeneration reverted to original content

## 2026-03-05 — Improve Docs Quality

### Added
- Doc templates for capability docs, ADRs, and consolidated README — `/opsx:docs` now reads templates at runtime instead of inlining format definitions
- "Design Rationale" section for initial-spec-only capability docs, derived from bootstrap research data
- Workflow sequence notes for multi-command capabilities (e.g., quality-gates explains when to use preflight vs. verify)
- `order` and `category` YAML frontmatter in baseline specs for deterministic, project-specific documentation ordering
- "Notable Trade-offs" subsection in the architecture overview, surfacing significant negative consequences from ADRs
- "References" section in ADRs linking to related specs and other ADRs

### Changed
- Architecture overview, capabilities table, and ADR index consolidated into a single `docs/README.md` entry point — `docs/architecture-overview.md` and `docs/decisions/README.md` are deleted on regeneration
- Capabilities in documentation are now grouped by workflow phase (Setup, Change Workflow, Development, etc.) and ordered by position within each phase
- ADR "Consequences" section split into "Positive" and "Negative" subsections for clearer trade-off visibility
- ADR "Context" sections now require at least 4-6 sentences covering motivation, investigation, and constraints
- Edge Cases in capability docs restricted to surprising states, error conditions, and non-obvious interactions — normal flow variants moved to Behavior
- Initial-spec "Why This Exists" sections now use problem-framing (what goes wrong without the capability) instead of restating the spec Purpose
- Project README shortened with links to `docs/README.md` for detailed documentation

## 2026-03-05 — Design Review Checkpoint

### Changed
- Design review is now governed by a constitution convention — agents pause after design in any multi-artifact workflow (including `/opsx:ff`) for user alignment

### Added
- "Design review checkpoint" convention in the project constitution — the design phase is the mandatory review point in every workflow
- "Design review mandatory" workflow principle in the README

## 2026-03-04 — Documentation Ecosystem

### Added
- Enriched capability docs — `/opsx:docs` now adds "Why This Exists", "Background", and "Known Limitations" sections by reading archived proposal, research, design, and preflight artifacts
- Architecture overview generation — `/opsx:docs` creates `docs/architecture-overview.md` from constitution, three-layer-architecture spec, and design decisions
- Architecture Decision Records (ADRs) — `/opsx:docs` generates formal ADRs from archived design.md Decisions tables with research context

### Changed
- `docs-generation` capability split into three focused capabilities: `user-docs`, `architecture-docs`, `decision-docs`
- Changelog generation moved from `docs-generation` to `release-workflow` capability
- Documentation table of contents now links architecture overview and decisions index

## 2026-03-04 — Release Workflow

### Added
- Automatic patch version bump on archive — plugin version in `plugin.json` and `marketplace.json` auto-increments after each `/opsx:archive`
- Skill immutability rule — skills are shared plugin code and must not be modified for project-specific behavior
- Release workflow spec covering auto-bump, manual minor/major releases, consumer update process, and end-to-end test checklist
- Documented consumer update process: marketplace refresh → plugin update → restart

### Fixed
- `marketplace.json` version synced to match `plugin.json` (was 3 patch versions behind)
- Manual version bump convention replaced with automatic post-archive bump — eliminates forgotten version bumps

### Changed
- "Updating the Plugin" section in README simplified to reflect automatic versioning

## 2026-03-02 — Final Verify Step

### Changed
- QA loop now includes a mandatory final verification step (3.5) after the fix loop, ensuring all post-fix changes are verified before approval
- Approval step renumbered from 3.5 to 3.6 to accommodate the new final verify step
- Approval is now gated by a clean final verify pass — if the fix loop introduced new issues, they must be resolved first
- If the initial verify was clean and no fixes were needed, the final verify step is automatically satisfied

## 2026-03-02 — Fix Workflow Friction

### Changed
- Workflow rules now live at their authoritative source — schema owns universal rules, constitution owns project-specific rules, config.yaml is just a bootstrap pointer
- Constitution cleaned up: 12 redundant rules removed that duplicated schema instructions and templates
- Init skill generates a minimal config template instead of copying the plugin's own config, preventing project-specific rules from leaking into consumer projects
- Development & Testing documentation simplified

### Added
- Friction tracking convention: workflow friction is now captured as GitHub Issues with the `friction` label
- Definition of Done rule embedded in the schema's task instruction
- Post-apply workflow sequence embedded in the schema's apply instruction

## 2026-03-02 — Fix Init Skill

### Fixed
- `/opsx:init` can now be invoked — was previously invisible due to `disable-model-invocation: true`

### Changed
- Init no longer creates duplicate built-in OpenSpec skills that conflict with the plugin's `/opsx:*` commands
- Init steps reduced from 7 to 6 (removed redundant `openspec init --tools claude`)
- Added directory safety (`mkdir -p`) before copying schema files

## 2026-03-02 — Initial Specification

### Added
- Formal baseline specifications for all 15 plugin capabilities
- Three-layer architecture spec covering Constitution, Schema, and Skills layers
- Project setup and bootstrap specs for initialization and codebase scanning
- Artifact pipeline spec defining the 6-stage workflow with dependency gating
- Artifact generation spec for step-by-step and fast-forward creation commands
- Spec format rules for normative descriptions, Gherkin scenarios, and delta operations
- Change workspace spec covering creation, structure, and archiving lifecycle
- Task implementation spec for working through checklists with progress tracking
- Quality gates spec for preflight checks and post-implementation verification
- Human approval gate spec with mandatory sign-off and fix-verify loop
- Interactive discovery spec for standalone research with targeted Q&A
- Spec sync spec for agent-driven delta merging into baselines
- Constitution management spec for generation, updates, and global enforcement
- Documentation generation spec for user-facing docs and changelog from specs
- Roadmap tracking spec for GitHub Issues with roadmap label
