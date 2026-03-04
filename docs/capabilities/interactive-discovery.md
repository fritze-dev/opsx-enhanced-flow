---
title: "Interactive Discovery"
capability: "interactive-discovery"
description: "Standalone research phase with targeted Q&A for complex features"
order: 8
lastUpdated: "2026-03-04"
---

# Interactive Discovery

Run a dedicated research phase with `/opsx:discover` to explore complex features thoroughly. The system generates research findings, assesses coverage across key categories, and asks targeted questions only where ambiguity exists — then pauses for your answers.

## Features

- Standalone research session independent from the artifact pipeline
- Coverage assessment rating each category as Clear, Partial, or Missing
- Targeted clarification questions limited to a maximum of 5, prioritized by impact and uncertainty
- Stale-spec risk detection when code and specs have drifted
- Decisions recorded with rationale and alternatives considered

## Behavior

### Discovery Session

When you run `/opsx:discover`, the system reads the constitution, the current change directory, and existing baseline specs. It checks whether existing specs reflect the current codebase and notes stale-spec risks. It then generates research.md with findings and a coverage assessment.

### Coverage Assessment

Each research category is rated as Clear, Partial, or Missing. Categories include Scope, Behavior, Data Model, UX, Integration, Edge Cases, Constraints, Terminology, and Non-Functional. Questions are generated only for Partial or Missing categories.

### Targeted Questions

At most 5 questions are presented, prioritized by impact multiplied by uncertainty. If all categories are Clear, no questions are asked and the system suggests proceeding with `/opsx:ff`. Lower-priority questions are omitted or noted as "covered if time permits."

### Recording Decisions

After you provide answers, each decision is recorded in the Decisions section of research.md with a number, the decision text, rationale, and alternatives considered. The system then stops without generating further artifacts.

### Stale-Spec Detection

If existing baseline specs reference code elements that have changed (e.g., a function was renamed), the system notes the stale-spec risk in the coverage assessment.

## Edge Cases

- If you answer some questions but not all, decisions are recorded for answered questions and unanswered ones are noted as "Deferred — no answer provided."
- If your answers contradict each other, the system flags the contradiction and asks for clarification before recording.
- If research.md already exists, it is overwritten with fresh research (with a warning).
- If no baseline specs exist, the system proceeds without stale-spec analysis and notes this.
- If you run discover on a completed change, the system allows it but warns that re-running research may invalidate downstream artifacts.
- If no active change exists, the system asks you to run `/opsx:new` first.
- If multiple active changes exist and no name is provided, the system lists them and asks you to select one.
