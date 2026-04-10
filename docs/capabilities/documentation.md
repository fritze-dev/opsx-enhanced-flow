---
title: "Documentation"
capability: "documentation"
description: "Capability docs, ADRs, and consolidated README generated from specs and change artifacts"
lastUpdated: "2026-04-10"
---

# Documentation

Generates all user-facing documentation from specs and completed change artifacts via `/opsx:workflow finalize`: enriched capability docs, Architecture Decision Records, and a consolidated README with architecture overview.

## Purpose

Specs and design artifacts contain valuable information, but their normative language and structured format are not user-friendly. Without generated documentation, users must read raw specs to understand what the system does, and design decisions remain buried in change directories. Documentation bridges this gap by transforming specs into clear explanations and surfacing decisions as formal ADRs.

## Rationale

Capability docs are generated per-spec rather than per-change because users think in terms of capabilities, not changes. Incremental generation uses the spec's `lastModified` frontmatter field compared against the doc's `lastUpdated` to avoid regenerating unchanged docs. ADRs are consolidated when multiple decisions from the same change share the same context, producing one coherent record instead of fragments. The README serves as a single entry point combining architecture overview, capabilities table, and design decisions, eliminating the need for multiple index files. Language-aware generation lets non-English teams use the system without translation overhead.

## Features

- **Enriched capability docs** -- one doc per spec at `docs/capabilities/<name>.md`, with Purpose, Rationale, Features, Behavior, Known Limitations, Future Enhancements, and Edge Cases sections derived from specs and change artifacts
- **Incremental generation** -- compares spec `lastModified` against doc `lastUpdated` to skip unchanged capabilities; content-aware writes prevent false timestamp bumps
- **Single-capability and multi-capability modes** -- target specific capabilities for regeneration, bypassing date checks
- **ADR generation** -- formal Architecture Decision Records from design.md Decisions tables, with inline rationale, alternatives, consequences, and validated references
- **ADR consolidation** -- related decisions from the same change grouped into a single ADR with numbered sub-decisions
- **Manual ADR preservation** -- files matching `adr-M*.md` are never overwritten or renumbered
- **ADR change backlinks** -- every generated ADR links back to its source change directory
- **Reference validation** -- spec and change links in ADRs are verified via glob; broken links are auto-resolved or resolved via user prompt
- **Consolidated README** -- `docs/README.md` combines System Architecture, Tech Stack, Key Design Decisions (ADR-sourced), Conventions, and a category-grouped capabilities table
- **Conditional README regeneration** -- README is only regenerated when capability docs, ADRs, or constitution content change
- **Language-aware generation** -- respects `docs_language` from WORKFLOW.md; translates headings and content while preserving product names, commands, and file paths

## Behavior

### Capability Doc Generation (`/opsx:workflow finalize`)

For each spec, the system reads the spec and looks up completed changes whose proposal lists the capability. It enriches the doc with Purpose (problem-framing from the spec), Rationale (design context from research and design artifacts), Known Limitations (from design Non-Goals and risks), and Future Enhancements (deferred items from Non-Goals). Behavior subsections map one-to-one to Gherkin scenario groups. Normative language is replaced with natural user-facing explanations. The capability doc template at `openspec/templates/docs/capability.md` defines the structural format.

### Incremental Detection

Before generating each doc, the system compares the spec's `lastModified` field against the doc's `lastUpdated` frontmatter. If the spec is older, the capability is skipped entirely. After generation, the content is compared against the existing file (excluding `lastUpdated`); if identical, the file is not written and the timestamp is not bumped.

### ADR Generation (`/opsx:workflow finalize`)

For each completed change with `has_decisions: true` in its design.md frontmatter, the system reads the Decisions table and generates ADRs. Each ADR includes Status, Context (at least 4-6 sentences), Decision (with inline rationale via em-dash pattern), Alternatives Considered, Consequences (Positive/Negative), and References. The slug is derived deterministically from the decision text. Cross-references to related ADRs are added when clear thematic relationships exist.

### ADR Consolidation

When multiple decisions from the same change share the same motivation, they are consolidated into a single ADR with numbered sub-decisions. Single-topic changes with 3+ decision rows are consolidated by default. Decisions addressing different concerns remain separate.

### README Generation (`/opsx:workflow finalize`)

The README is built from the constitution (System Architecture, Tech Stack, Conventions), all ADR files (Key Design Decisions table with Notable Trade-offs), and all capability docs (grouped by spec `category` frontmatter, ordered by `order` field). Capability descriptions are concise (max 80 characters or 15 words). The README template at `openspec/templates/docs/readme.md` defines the format.

### Language-Aware Generation

When `docs_language` is set to a non-English value in WORKFLOW.md, all headings and content are translated. YAML frontmatter keys, product names, commands, and file paths remain in English. A language change triggers full regeneration rather than incremental updates.

## Known Limitations

- Capability doc enrichment depends on completed change artifacts existing; capabilities with no change data get spec-only docs without Rationale or Known Limitations.
- ADR consolidation heuristics may misjudge grouping in edge cases; conservative rules minimize false consolidation.
- Translation quality varies by language; major languages work well, exotic languages may need review.

## Edge Cases

- If no completed changes exist for a capability, the system falls back to a spec-only doc without enriched sections.
- If a spec has no `lastModified` field, it is always treated as needing regeneration.
- If `docs/capabilities/` does not exist, it is created automatically.
- Stale files from previous runs (`docs/architecture-overview.md`, `docs/decisions/README.md`) are deleted automatically.
- If a listed capability in multi-capability mode does not exist in specs, the system warns and skips it.
