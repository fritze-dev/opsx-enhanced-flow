---
name: bootstrap
description: Bootstrap a project with OpenSpec or re-sync when code and specs have drifted. Use for initial project setup or recovery after hotfixes/dependency updates.
disable-model-invocation: false
---

# /opsx:bootstrap — Bootstrap & Recovery

> Run to initialize a project OR to re-sync when code and specs have drifted.

## Instructions

### Step 0: Verify Setup

Check that `openspec/config.yaml` and `openspec/schemas/opsx-enhanced/schema.yaml` both exist. If either is missing, tell the user to run `/opsx:setup` first and stop.

### Step 0b: Detect Mode

Check if `openspec/constitution.md` contains actual content (not just the starter template) AND `openspec/specs/` has at least one spec file.

- **No specs/constitution:** → First Run (Steps 1–6)
- **Specs exist:** → Re-Run (Steps 7–9)

---

## First Run

### Step 1: Full Codebase Scan

Analyze the entire project:
- **Tech stack:** Languages, frameworks, runtimes, package managers
- **Architecture:** Directory structure, module boundaries, entry points
- **APIs:** Endpoints, contracts, external integrations
- **Dependencies:** Key libraries, their versions, any constraints
- **Testing:** Test frameworks, coverage patterns, CI/CD setup
- **Conventions:** Naming patterns, code style, commit conventions

### Step 2: Generate Constitution

Write the project constitution to `openspec/constitution.md`.

Use the constitution template from the schema's template directory as a starting structure:
- Read `openspec/schemas/opsx-enhanced/templates/constitution.md` for the recommended sections and guidance comments

Adapt the sections to fit the project — add sections the project needs, omit sections that don't apply, rename or restructure as appropriate. Fill in each section based on **observed patterns** in the codebase — do not invent rules
- Mark uncertain items with `<!-- REVIEW -->` for the user to confirm

### Step 2b: Resolve REVIEW Markers

After generating the constitution, iterate through all `<!-- REVIEW -->` markers:

1. For each marker, present the uncertain item to the user with context (e.g., "Indentation convention unclear — both tabs and spaces observed. Which should be the standard?")
2. Wait for the user's response
3. Update the constitution entry with the user's decision
4. Remove the `<!-- REVIEW -->` marker

Continue until zero `<!-- REVIEW -->` markers remain in the constitution. Do not proceed to Step 3 until all markers are resolved.

### Step 3: Create Initial Change

```bash
mkdir -p openspec/changes/initial-spec
```

### Step 4: Hand Off

Tell the user:
1. Review `openspec/constitution.md` — all uncertain items have been resolved, but a final review is recommended
2. The initial change workspace is ready at `openspec/changes/initial-spec/`
3. Continue with the standard pipeline:
   - `/opsx:continue` — generate one artifact at a time (recommended for first bootstrap, allows review between steps)
   - `/opsx:ff` — generate all artifacts in one go
4. After all artifacts are complete, run `/opsx:apply` to execute the QA loop (this is a docs-only change — no code tasks, just quality checks)
5. When approved, run `/opsx:sync` to merge delta specs into baseline specs at `openspec/specs/`
6. Then run `/opsx:archive` to finalize and move the change to archive
7. The project is then ready for feature development with `/opsx:new`

**Hint for the research artifact:** This is a full-project bootstrap, not a single feature. Cover the entire project — identify capabilities at multiple levels:
- **Design Concepts** — Principles, quality practices, architectural patterns, methodology decisions
- **Structural Components** — Architecture layers, module boundaries, data model
- **Operational Features** — Commands, workflows, user-facing functionality

Each identified capability becomes its own spec file during archive.

---

## Re-Run (Recovery & Consistency)

### Step 7: Drift Detection

1. Read `openspec/constitution.md` and all specs in `openspec/specs/`.
2. Scan the codebase for changes not reflected in specs:
   - New files/modules without corresponding specs
   - Modified APIs or interfaces that specs still describe in the old way
   - Removed features still documented in specs
3. Report drift findings to the user.

### Step 8: Update Constitution & Specs

Based on drift findings:
- Update `openspec/constitution.md` if tech stack, patterns, or conventions changed.
- Create delta-spec changes for drifted capabilities via `/opsx:new`.

### Step 9: Consistency Passes

Run 3 passes across all specs in `openspec/specs/`:

1. **Terminology Pass:** Same concept under different names across specs?
2. **Boundary Pass:** Scope overlaps between specs?
3. **Dependency Pass:** Cross-spec references still valid?

Report findings. User decides which to fix.

> **When to re-run:** After hotfixes, dependency updates, or any code changes made outside the spec process. Also useful periodically for consistency checks on growing spec bases.
