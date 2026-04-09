---
name: docs-verify
description: Verify generated documentation (capability docs, ADRs, README) against current specs for drift. Use when the user wants to check if docs are still in sync with specs.
disable-model-invocation: false
---

Verify that generated documentation accurately reflects the current state of specs.

**Input**: No arguments. Operates on the entire project — checks all specs, capability docs, ADRs, and README.

**Steps**

1. **Prerequisite check**

   Check that `openspec/WORKFLOW.md` exists. If missing, tell the user to run `/opsx:setup` first and stop.

2. **Discovery**

   Gather all source and target files:

   - **Specs**: Glob `openspec/specs/*/spec.md` to find all capabilities. The directory name is the capability ID.
   - **Capability docs**: Glob `docs/capabilities/*.md`. If `docs/capabilities/` does not exist, note it and treat all capabilities as missing docs.
   - **ADRs**: Glob `docs/decisions/adr-*.md`. Separate generated ADRs (`adr-[0-9]*.md`) from manual ADRs (`adr-M*.md`). If `docs/decisions/` does not exist, note it.
   - **Completed changes**: Glob `openspec/changes/*/design.md` to find design decisions from completed changes (proposal frontmatter `status: completed`, or fallback: all tasks checked in tasks.md). For each design.md, check frontmatter `has_decisions` field — if `false` or absent, skip (no decisions to verify). If no completed changes with decisions exist, note it.
   - **README**: Check if `docs/README.md` exists.
   - **Constitution**: Read `openspec/CONSTITUTION.md` for README architecture checks.

   Initialize an empty findings list with three categories: CRITICAL, WARNING, INFO.

3. **Dimension A: Capability Docs vs Specs**

   For each spec found in `openspec/specs/*/spec.md`:

   **Existence check:**
   - Check if `docs/capabilities/<capability-name>.md` exists.
   - If no matching file by name: check all capability doc files for a frontmatter `capability` field or first heading that matches. If still no match → add CRITICAL: "Missing capability doc for `<capability-name>`" with reference to `openspec/specs/<capability-name>/spec.md`. Recommend: "Run `/opsx:docs <capability-name>` to generate."

   **Empty doc check:**
   - If the capability doc exists but has fewer than 10 lines of content (excluding frontmatter), add WARNING: "Capability doc for `<capability-name>` appears empty" with reference to `docs/capabilities/<capability-name>.md`.

   **Requirement coverage check:**
   - Read the spec and extract all requirement names from `### Requirement: <name>` headers.
   - Read the capability doc and search for each requirement name (or a close derivative) in the doc's content — check headings, feature bullets, and behavior sections.
   - For each requirement not found in the capability doc, add WARNING: "Capability doc for `<capability-name>` missing requirement: `<requirement-name>`" with references to both the spec and the doc file. Recommend: "Run `/opsx:docs <capability-name>` to regenerate."

   **Purpose alignment check:**
   - Read the spec's `## Purpose` section and the capability doc's Purpose section (or first paragraph after the title).
   - If the doc's Purpose appears to describe something substantially different from the spec's Purpose, add WARNING: "Capability doc Purpose may have drifted for `<capability-name>`" with references to both files.

4. **Dimension B: ADRs vs Design Decisions**

   If no completed changes with `design.md` exist, skip this dimension and note: "No design decisions to verify against."

   For each completed change's `design.md`:

   **Decisions table discovery:**
   - Look for a markdown table under a heading containing "Decisions" (e.g., `## Decisions`).
   - The table must have columns including "Decision" and "Rationale".
   - If the section contains only prose (e.g., "No architectural changes"), no table, or a non-Decisions table — skip this change.

   **ADR cross-check:**
   - For each decision row in the table, search the existing generated ADR files (`adr-[0-9]*.md`) for content that matches the decision text (check the `## Decision` section of each ADR).
   - Also check each ADR's References section for a `[Change: ...]` backlink matching the current change directory name.
   - If a decision has no matching ADR, add WARNING: "Missing ADR for design decision: `<decision-text-summary>`" with reference to the change's `design.md`. Recommend: "Run `/opsx:docs` to generate missing ADRs."

   **Manual ADR handling:**
   - Files matching `adr-M*.md` are manual ADRs. Do NOT check them against change Decisions tables. Do NOT flag them as unmatched.

   **Consolidation awareness:**
   - If a change has 3+ decision rows that map to a single consolidated ADR, count that as covered (not as missing ADRs).

5. **Dimension C: README vs Current State**

   If `docs/README.md` does not exist, add a single CRITICAL: "Missing `docs/README.md`" and skip the rest of this dimension. Recommend: "Run `/opsx:docs` to generate."

   **Capabilities table check:**
   - Read `docs/README.md` and locate the capabilities table (look for a Markdown table or structured list under a heading containing "Capabilities").
   - Extract capability names from the table.
   - For each spec in `openspec/specs/*/`, check if the capability appears in the README table.
   - For each missing capability, add CRITICAL: "README capabilities table missing: `<capability-name>`" with reference to `docs/README.md`. Recommend: "Run `/opsx:docs` to regenerate the README."

   **Key Design Decisions table check:**
   - Locate the Key Design Decisions table in the README (look for a heading containing "Design Decisions" and a Markdown table with ADR links).
   - Extract all ADR file references from the table (e.g., `adr-001-slug.md`).
   - For each ADR reference, check if the file exists in `docs/decisions/`.
   - For each stale reference (file does not exist), add WARNING: "README references non-existent ADR: `<adr-filename>`" with reference to `docs/README.md`.

   **Architecture overview consistency:**
   - Read the constitution's Tech Stack and Architecture Rules sections.
   - Read the README's architecture overview section (look for headings like "System Architecture", "Tech Stack", "Architecture").
   - Compare key terms: if the constitution mentions technologies, patterns, or rules not reflected in the README overview, add WARNING: "README architecture overview may have drifted from constitution" with references to both files.
   - Only flag substantive discrepancies (missing technologies, contradictory statements), not minor phrasing differences.

6. **Generate Report**

   **Summary scorecard:**
   ```
   ## Documentation Drift Report

   ### Summary
   | Dimension | Status |
   |-----------|--------|
   | Capability Docs | N specs checked, M issues |
   | ADRs | N changes checked, M issues |
   | README | Checked / Missing |

   | Severity | Count |
   |----------|-------|
   | CRITICAL | N |
   | WARNING | N |
   | INFO | N |
   ```

   **Findings by dimension:**

   Group all findings under their dimension heading (A, B, C). Within each dimension, list findings by severity (CRITICAL first, then WARNING, then INFO). Each finding includes:
   - Severity tag: `**CRITICAL**`, `**WARNING**`, or `**INFO**`
   - Description of the issue
   - File reference(s): `spec: openspec/specs/<name>/spec.md`, `doc: docs/capabilities/<name>.md`
   - Recommendation (what command to run to fix)

   **Verdict:**
   - If any CRITICAL findings: **"OUT OF SYNC"** — "N critical issue(s) found. Run `/opsx:docs` to regenerate documentation."
   - If WARNING findings but no CRITICAL: **"DRIFTED"** — "No critical issues. N warning(s) detected. Consider running `/opsx:docs` to update."
   - If no CRITICAL and no WARNING: **"CLEAN"** — "All documentation is in sync with specs."

   If INFO findings exist in a CLEAN verdict, still show them under an "Observations" section but keep the CLEAN verdict.

**Verification Heuristics**

- **Existence checks**: Exact filename match first, then frontmatter/heading fallback for capability docs.
- **Requirement matching**: Search for the requirement name text within the capability doc. Use case-insensitive matching. A requirement is "covered" if its name (or a recognizable derivative) appears in a heading, bullet, or bold text within the doc.
- **Purpose alignment**: Compare the core subject matter, not exact wording. Flag only if the doc describes a fundamentally different capability than the spec.
- **ADR matching**: Match by decision text keywords in the ADR's Decision section, or by change backlink in References.
- **README capability matching**: Match by capability name (kebab-case) appearing in the table. Case-insensitive.
- **Constitution consistency**: Compare key terms and technology names, not prose structure.
- **False positive avoidance**: When uncertain whether something is drift or intentional, prefer INFO over WARNING, WARNING over CRITICAL.

**Graceful Degradation**

- If `docs/capabilities/` does not exist: report all specs as missing docs (CRITICAL), continue to other dimensions.
- If `docs/decisions/` does not exist: skip Dimension B, note "No ADR directory found."
- If `docs/README.md` does not exist: report as single CRITICAL, skip README sub-checks.
- If no completed changes exist: skip Dimension B, note "No design decisions to verify against."
- If no specs exist: report "No specs found in `openspec/specs/`. Nothing to verify." and stop.
- Always report which dimensions were checked and which were skipped.

**Output Format**

Use clear markdown with:
- Tables for summary scorecard
- Grouped lists for findings (CRITICAL → WARNING → INFO)
- File references as relative paths
- Specific, actionable recommendations (always include the exact `/opsx:docs` command to run)
- No vague suggestions like "consider reviewing"
