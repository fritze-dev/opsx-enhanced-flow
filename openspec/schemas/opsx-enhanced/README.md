# OPSX Enhanced Schema

An OpenSpec custom schema for the OPSX Enhanced Flow — a spec-driven development workflow combining User Stories, BDD/Gherkin, and multi-pass quality gates.

## Artifact Pipeline

```
research → proposal → specs → design → preflight → tasks → [apply]
```

| Artifact | Output | Purpose |
|----------|--------|---------|
| research | `research.md` | Discovery: research documentation, coverage assessment, questions if needed |
| proposal | `proposal.md` | Problem statement, capabilities (new/modified), impact |
| specs | `spec.md` | User Stories + Gherkin scenarios (BDD), edge cases, assumptions |
| design | `design.md` | Context, architecture, success metrics, non-goals, open questions |
| preflight | `preflight.md` | Quality gate: traceability, gaps, side effects, consistency, assumption audit |
| tasks | `tasks.md` | Implementation checklist with QA loop |

## Installation

Use `/opsx:setup` — it copies the schema files into the project and creates the config. No external dependencies required.

## Related

- [OPSX Enhanced Flow](../../../../README.md) — Full workflow documentation
- [OpenSpec](https://github.com/Fission-AI/OpenSpec) — The spec-driven development framework
- [Spec-Kit](https://github.com/github/spec-kit) — Inspiration for quality practices
