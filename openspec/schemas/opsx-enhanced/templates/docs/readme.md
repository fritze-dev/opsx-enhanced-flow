# Documentation

## System Architecture

[Describe the three-layer model from the three-layer-architecture spec.
 If that spec doesn't exist, derive from constitution Architecture Rules.]

## Tech Stack

[From constitution Tech Stack section. Present as a readable list.]

## Key Design Decisions

<!-- Aggregate notable decisions from all archived design.md Decisions tables.
     Deduplicate — if the same decision appears in multiple archives, include once.
     Include ALL decisions.
     The ADR column links directly to the corresponding ADR file.
     Surface notable trade-offs from ADR Consequences sections. -->

| Decision | Rationale | ADR |
|----------|-----------|-----|
| [Decision text] | [Rationale text] | [ADR-NNN](decisions/adr-NNN-slug.md) |

<!-- If any decisions have significant negative consequences,
     add a "Notable Trade-offs" subsection.
     Include trade-offs that affect documentation consumers or represent
     meaningful constraints on the system. Aim for completeness — every ADR
     with a substantive negative consequence should be represented. -->

### Notable Trade-offs

- **[Decision]**: [Brief trade-off from ADR Negative Consequences]

## Conventions

[From constitution Conventions section. Present as a readable list.]

## Capabilities

<!-- Group capabilities by `category` from baseline spec frontmatter.
     Render each category as a group header (title-case of kebab-case value).
     Within each group, order by `order` field (lower first).
     If a capability has no category, place in "Other" group. -->

### [Category Title]

| Capability | Description |
|---|---|
| [Capability Title](capabilities/<capability-id>.md) | [One-line summary: max 80 characters or 15 words. One short phrase, not a multi-clause sentence.] |
