---
id: constitution
template-version: 1
description: Project governance template for bootstrap
generates: CONSTITUTION.md
requires: []
instruction: |
  Generate project-specific rules from codebase analysis.
  Fill in each section based on what you discover in the code.
  Use REVIEW markers for items needing user confirmation.
---
# Project Constitution

## Tech Stack
(Language, Runtime, Framework, Database, Testing, Package Manager)

## Architecture Rules
(Architectural patterns, module boundaries, dependency direction)

## Code Style
(Coding conventions, formatting, naming patterns)

## Constraints
(Limits, requirements, compatibility rules)

## Conventions
(Naming, commits, branching, file organization)

## Standard Tasks

<!-- Project-specific extras appended to the universal standard tasks in the tasks template.
     Pre-merge items use checkbox format and are executed during post-apply workflow.
     Post-merge items use plain bullet format and are manual reminders after PR merge. -->

### Pre-Merge
<!-- - [ ] Example: Update PR body with summary -->

### Post-Merge
<!-- - Example: Run deployment script -->
