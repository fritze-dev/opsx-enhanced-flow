## Why

The opsx-enhanced-flow plugin has been built and is functional, but lacks formal specifications. Without baseline specs, there is no foundation for spec-driven feature development — changes cannot be tracked as delta specs, verify cannot check implementation against specs, and drift detection has no reference point. This initial-spec change establishes the baseline by documenting every capability as a formal specification.

## What Changes

- Create baseline specs for all existing capabilities of the plugin
- Each capability gets its own `specs/<name>/spec.md` with Purpose, Requirements (SHALL/MUST), and Gherkin scenarios
- No code changes — this is a documentation-only bootstrap

## Capabilities

### New Capabilities

- `three-layer-architecture`: Constitution, Schema, and Skills layers — their responsibilities, separation rules, and interaction patterns
- `project-setup`: `/opsx:init` — one-time project initialization with OpenSpec CLI auto-install
- `project-bootstrap`: `/opsx:bootstrap` — codebase scan, constitution generation, initial change creation, and recovery mode
- `artifact-pipeline`: Schema-defined 6-stage pipeline (research → proposal → specs → design → preflight → tasks) with dependency gating
- `artifact-generation`: Step-by-step (`/opsx:continue`) and fast-forward (`/opsx:ff`) artifact creation
- `spec-format`: Requirement format rules — normative descriptions, User Stories, Gherkin scenarios, delta operations
- `change-workspace`: Change lifecycle — creation (`/opsx:new`), workspace structure, archiving (`/opsx:archive`)
- `task-implementation`: `/opsx:apply` — working through task checklists with progress tracking
- `quality-gates`: `/opsx:preflight` and `/opsx:verify` — pre-implementation quality checks and post-implementation verification
- `human-approval-gate`: QA loop with mandatory explicit approval before archiving
- `interactive-discovery`: `/opsx:discover` — standalone research with Q&A for complex features
- `spec-sync`: `/opsx:sync` — agent-driven delta spec merging into baseline specs
- `constitution-management`: Constitution generation, update rules, and recovery conventions
- `docs-generation`: `/opsx:docs` and `/opsx:changelog` — user-facing capability documentation from merged specs and release notes from archived specs
- `roadmap-tracking`: Planned improvements tracked as GitHub Issues with roadmap label

### Modified Capabilities

(none — no existing specs)

## Impact

- Creates `openspec/specs/` directory with 15 capability specs
- Enables spec-driven feature development going forward
- Provides baseline for drift detection and verify checks

## Scope & Boundaries

**In scope:**
- Formal specification of all existing plugin capabilities
- Gherkin scenarios covering core behavior and key edge cases

**Out of scope:**
- Code changes or new features
- Implementation tasks (tasks.md will be empty — no code to write)
- CI/CD or automated testing setup
