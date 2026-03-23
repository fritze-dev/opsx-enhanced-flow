# ADR-002: Workflow Rule Ownership

## Status

Accepted — 2026-03-02

## Context

The first dogfooding run of the opsx-enhanced-flow plugin revealed significant friction caused by workflow rules being scattered across three locations — config.yaml, constitution, and schema — with heavy redundancy. A rule ownership audit (GitHub Issue #1) identified 12 rules in the constitution that duplicated schema instructions or templates, creating maintenance burden and drift risk. Four remaining friction points from GitHub Issue #6 (FP #4, #5, #7, #8) needed resolution alongside the audit. The research phase evaluated three approaches: using per-artifact config rules (chosen), creating a new `/opsx:status` skill (rejected — only shows info, does not enforce), and embedding enforcement in skill instructions only (rejected — not injected during artifact generation). The investigation confirmed that OpenSpec CLI's config.yaml supports per-artifact `rules` for targeted enforcement, and that the prompt injection order (`<context>` then `<rules>` then `<template>`) makes this the correct mechanism for workflow enforcement. The core insight was a clear separation of concerns: schema owns universal workflow rules that apply to all projects using opsx-enhanced, constitution owns project-specific rules, and config.yaml serves only as a bootstrap pointer.

## Decision

1. **Schema owns workflow rules** — The Definition-of-Done (DoD) rule and post-apply workflow sequence apply to ALL projects using the opsx-enhanced schema, so they belong in the shared schema instructions (`tasks.instruction` and `apply.instruction`), not in per-project config or constitution.

2. **Config.yaml reduced to bootstrap-only** — With workflow rules moved to schema and project-specific rules in constitution, config.yaml only needs to reference the schema and point to the constitution. This eliminates its previous role as a rules container (reduced from 9 global rules to a single constitution pointer).

3. **Remove 12 redundant constitution rules** — Twelve rules in the constitution duplicated schema instructions or templates. Single source of truth prevents drift and reduces constitution noise. The "defense in depth" argument was rejected because it creates a maintenance burden that outweighs the safety benefit.

4. **Init skill generates minimal config template** — The `/opsx:init` skill now generates a clean starting-point config template instead of copying the plugin's own project config, preventing project-specific rules from leaking into consumer projects.

## Alternatives Considered

- Keep rules in config.yaml (per-project duplication) — causes redundancy across consumer projects
- No config at all (remove config.yaml) — loses the constitution pointer mechanism
- Keep redundancies as "defense in depth" — causes maintenance burden and drift between duplicated sources
- Copy full project config in init — leaks project-specific content into consumer projects
- New `/opsx:status` skill for workflow enforcement — only shows info, does not enforce; adds maintenance burden
- Workflow enforcement in skill instructions only — easy to forget; not injected during artifact generation
- Add friction prompt to verify instead of archive — verify is an automated scorecard; archive is the workflow closure point with existing interactive prompts

## Consequences

### Positive

- Clear separation of concerns across the three-layer architecture: schema (universal rules), constitution (project-specific rules), config (bootstrap pointers)
- Single source of truth for each workflow rule eliminates drift between config, constitution, and schema
- Constitution becomes cleaner and more focused on project-specific content (tech stack, architecture, paths, conventions, constraints)
- Consumer projects get a clean starting point from init without inherited project-specific rules
- Friction tracking convention in constitution ensures workflow pain points are captured as GitHub Issues with a `friction` label

### Negative

- Reduced defense-in-depth: rules now live in one place instead of being duplicated across layers. This is an accepted trade-off because schema enforcement combined with skill guardrails provides sufficient coverage.

## References

- [Archive: fix-workflow-friction](../../openspec/changes/archive/2026-03-02-fix-workflow-friction/)
- [Spec: constitution-management](../../openspec/specs/constitution-management/spec.md)
- [Spec: artifact-pipeline](../../openspec/specs/artifact-pipeline/spec.md)
- [Spec: project-setup](../../openspec/specs/project-setup/spec.md)
- [GitHub Issue #1](https://github.com/fritze-dev/opsx-enhanced-flow/issues/1)
- [GitHub Issue #6](https://github.com/fritze-dev/opsx-enhanced-flow/issues/6)
- [ADR-001: Initial Spec Organization](adr-001-initial-spec-organization.md)
