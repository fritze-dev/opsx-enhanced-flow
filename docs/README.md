# Documentation

| Capability | Description |
|---|---|
| [Three-Layer Architecture](capabilities/three-layer-architecture.md) | Constitution, Schema, and Skills layers with distinct responsibilities and independent modifiability |
| [Project Setup](capabilities/project-setup.md) | One-time project initialization with /opsx:init including CLI installation, config template, and validation |
| [Project Bootstrap](capabilities/project-bootstrap.md) | Initial codebase scanning, constitution generation, change creation, and drift recovery |
| [Artifact Pipeline](capabilities/artifact-pipeline.md) | 6-stage pipeline (research through tasks) with strict dependency gating and clean rule ownership |
| [Artifact Generation](capabilities/artifact-generation.md) | Step-by-step (/opsx:continue) and fast-forward (/opsx:ff) artifact creation |
| [Spec Format](capabilities/spec-format.md) | Requirement format rules including normative descriptions, Gherkin scenarios, and delta operations |
| [Change Workspace](capabilities/change-workspace.md) | Change lifecycle: creation with /opsx:new, workspace structure, and archiving with /opsx:archive |
| [Task Implementation](capabilities/task-implementation.md) | Working through task checklists with /opsx:apply and progress tracking |
| [Quality Gates](capabilities/quality-gates.md) | Pre-implementation preflight checks and post-implementation verification |
| [Human Approval Gate](capabilities/human-approval-gate.md) | Mandatory explicit approval before archiving with fix-verify loop support |
| [Interactive Discovery](capabilities/interactive-discovery.md) | Standalone research with targeted Q&A for complex features using /opsx:discover |
| [Spec Sync](capabilities/spec-sync.md) | Agent-driven delta spec merging into baseline specs with /opsx:sync |
| [Constitution Management](capabilities/constitution-management.md) | Constitution generation from codebase, automatic updates during design, global enforcement, and friction tracking |
| [Docs & Changelog Generation](capabilities/docs-generation.md) | User-facing documentation from specs (/opsx:docs) and release notes from archives (/opsx:changelog) |
| [Release Workflow](capabilities/release-workflow.md) | Automatic patch versioning on archive, manual minor/major releases, and consumer update process |
| [Roadmap Tracking](capabilities/roadmap-tracking.md) | Planned improvements tracked as GitHub Issues with roadmap label |
