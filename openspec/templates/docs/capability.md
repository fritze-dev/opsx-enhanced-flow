---
id: docs-capability
description: Capability documentation template
generates: "docs/capabilities/*.md"
requires: []
instruction: |
  Generate user-facing capability documentation from merged baseline specs.
  Derive Purpose from spec Purpose using problem-framing.
  Derive Rationale from research.md and design.md in archives.
  Write in present tense — describe current design, not change history.
  OMIT empty optional sections entirely.
---
---
title: "[Capability Title]"
capability: "[capability-id]"
description: "[One-line summary of what this capability does]"
lastUpdated: "[YYYY-MM-DD]"
---

# [Capability Title]

[1-2 sentence overview derived from user stories or requirements.]

## Purpose

[1-3 sentences describing what problem this capability solves.
 ALWAYS frame as the capability's purpose, never as motivation for a specific change.
 Derive from spec Purpose section using problem-framing.
 Archive proposals may provide additional context but must not replace
 the capability-level purpose with change-level motivation.]

<!-- How to write Purpose:

BAD (restating what it is): "A consistent spec format is essential for both human
readability and system automation."

BAD (change motivation): "The first workflow run revealed rules were scattered
across three files."

GOOD (capability purpose via problem-framing): "Without a consistent spec format,
scenarios break automated parsing, normative language becomes ambiguous, and delta
specs can't be reliably merged into baselines."

Guidelines:
- Frame as what goes wrong WITHOUT this capability
- Use the spec's User Stories ("so that...") for motivation
- Keep concise: max 3 sentences
-->

## Rationale

[3-5 sentences of design context: key decisions, alternatives explored,
 why this specific approach was chosen.
 For enriched capabilities: derived from research.md and design.md.
 For initial-spec-only: derived from spec requirements, scenarios, and assumptions.
 OMIT this section if no useful design context available.]

<!-- Rationale guardrail:
     Describe the CURRENT design and why it works this way. Write in present tense.
     Do NOT narrate the change history ("was later added", "initially... then...",
     "a subsequent change introduced..."). Every sentence should answer "why does it
     work this way?" not "how did it get this way?"

     BAD: "The initial design used X. A later change added Y to address Z."
     GOOD: "X handles the common case. Y covers edge cases where Z occurs." -->

## Features

- [Bullet list of what users can do — derived from stories/requirements]

## Behavior

<!-- For capabilities that involve multiple commands or phases
     (e.g., quality-gates covers /opsx:preflight and /opsx:verify),
     add a brief workflow sequence note at the TOP of this section:
     "Run /opsx:preflight before tasks (pre-implementation).
      Run /opsx:verify after implementation (post-implementation)."
-->

<!-- For multi-command capabilities, include the command name in behavior subsection
     headers for quick scanning.
     Example: "### Step-by-Step Generation (/opsx:continue)" rather than just
     "### Step-by-Step Generation". This helps users find the command they need. -->

### [Feature Group]

[Plain-language description of key scenarios. Derived from Gherkin scenario
 titles and WHEN/THEN structure. Group related scenarios.]

## Known Limitations

- [design.md Non-Goals rewritten as "Does not support X"]
- [design.md Risks rewritten as user-relevant limitations]
- [preflight.md assumptions rated "Acceptable Risk" that affect users]
[Max 5 bullets. OMIT this section entirely if empty.]

## Future Enhancements

- [Deferred Non-Goals: items explicitly marked "(deferred)" or "(separate feature)"]
- [Sensible Non-Goals: out-of-scope items that are natural extensions of this capability]
- [Link to GitHub Issue if one exists: "Tracked in #N"]
[Max 5 bullets. OMIT this section entirely if no actionable future ideas.
 Do NOT include items that are just scope boundaries for a specific change.
 Only include items that would genuinely improve this capability.]

## Edge Cases

<!-- ONLY include surprising states, error conditions, or non-obvious interactions.
     Normal flow variants and expected UX behaviors belong in Behavior.
     Test: would a user be SURPRISED by this behavior? If not, it's Behavior. -->

- [Edge case description]
