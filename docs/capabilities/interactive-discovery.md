---
title: "Interactive Discovery"
capability: "interactive-discovery"
description: "Provides standalone interactive research with targeted Q&A for complex features, generating research.md with coverage assessment and clarification questions."
lastUpdated: "2026-03-25"
---

# Interactive Discovery

Provides a dedicated research phase where you can explore complex features interactively, review existing architectural decisions, answer targeted questions, and resolve ambiguities before the artifact pipeline generates specs and design.

## Purpose

Jumping straight into spec and design generation for a complex feature often produces artifacts full of assumptions and gaps. Interactive Discovery gives you a structured way to surface unknowns early: it assesses coverage across key categories, asks targeted questions only where information is missing, and records your decisions with rationale -- all before any downstream artifacts are created.

## Rationale

Discovery operates independently from the artifact pipeline, producing only `research.md` and then pausing. This separation ensures that research is thorough and deliberate rather than rushed as a side effect of artifact generation. Questions are limited to a maximum of five, prioritized by impact multiplied by uncertainty, so that you focus on the highest-value unknowns first. The system also checks existing baseline specs against the codebase to flag potential staleness, catching drift that could undermine the new change.

## Features

- **Standalone research session** via `/opsx:discover` -- generates `research.md` without advancing the pipeline.
- **Coverage assessment** -- rates nine categories (Scope, Behavior, Data Model, UX, Integration, Edge Cases, Constraints, Terminology, Non-Functional) as Clear, Partial, or Missing.
- **Targeted Q&A** -- generates up to 5 clarification questions, only for Partial or Missing categories, prioritized by impact and uncertainty.
- **ADR awareness** -- reads `docs/decisions.md` to identify relevant existing decisions, then deep-dives into specific ADR files for full context.
- **Stale-spec detection** -- compares existing baseline specs against the codebase and flags potential drift.
- **Decision recording** -- captures your answers as numbered decisions with rationale and alternatives considered.

## Behavior

### Running a Discovery Session

When you run `/opsx:discover`, the system reads the constitution, checks `docs/decisions.md` for relevant existing architectural decisions, reads the current change directory, and reviews existing baseline specs. It then generates `research.md` with findings about the domain relevant to your change and rates coverage across nine categories.

### ADR Awareness

The system reads `docs/decisions.md` as a lightweight index to scan decision titles and rationale. Based on thematic relevance to the current change, it identifies specific ADR files and reads them for full Decision and Consequences context. Only relevant ADRs are read — not all of them. If `docs/decisions.md` does not exist (for example, before the first `/opsx:docs` run), ADR awareness is skipped and discovery proceeds with constitution and specs context only. Relevant ADR context is captured in the "Related Decisions" section of research.md.

If all categories are rated Clear, the system states that no questions are needed, saves `research.md`, and suggests running `/opsx:ff` to proceed. If any categories are Partial or Missing, the system presents targeted questions (up to five) and pauses for your answers.

### Answering Questions and Recording Decisions

After you provide answers, the system records each as a decision in the Decisions section of `research.md`, including the decision text, rationale, and alternatives considered. The system then saves the file and stops -- it does not generate proposal, specs, design, or any other artifacts.

### Stale-Spec Detection

If baseline specs reference functions, modules, or patterns that no longer match the codebase, the system notes these as stale-spec risks in the coverage assessment. This helps you identify specs that may need updating as part of the current change.

### Prerequisite Checks

The system verifies that a change workspace exists before starting discovery. If no active change is found, it suggests running `/opsx:new` first. If the OpenSpec CLI or schema is not available, it directs you to run `/opsx:setup`.

## Known Limitations

- Stale-spec detection is heuristic (keyword-based) and may not catch all cases of code-spec drift.
- The 5-question limit means exceptionally complex changes may require multiple discovery rounds.

## Edge Cases

- If you answer only some questions, the system records decisions for the answered ones and marks unanswered questions as "Deferred -- no answer provided."
- If your answers contradict each other, the system flags the contradiction and asks for clarification before recording.
- If `research.md` already exists from a previous session, the system overwrites it with fresh research after warning you.
- If no baseline specs exist (e.g., during a bootstrap), discovery proceeds without stale-spec analysis.
- If you run discovery on a change with all artifacts already complete, the system allows it but warns that re-running research may invalidate downstream artifacts.
- If `docs/decisions.md` exists but is empty or malformed, ADR awareness is skipped.
- If an ADR file referenced in `docs/decisions.md` no longer exists, that ADR is skipped and discovery continues with the remaining relevant ADRs.
