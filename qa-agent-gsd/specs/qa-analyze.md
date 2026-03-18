# Spec: QA Repository Analysis

## Goal
Analyze a developer repository and produce a complete QA assessment. Follow all standards defined in CLAUDE.md.

## Input
The user will provide one or two repository paths:
- **DEV repo** (always) — the application source code
- **QA repo** (optional) — existing test suite if one exists

## Milestones

### Milestone 1: Repository Scan
Read the DEV repo thoroughly:
1. Root files (README, package.json, Dockerfile, CI configs)
2. Entry points (controllers, routes, handlers, main files)
3. Business logic (services, models, utils, middleware)
4. Data layer (ORM, DB configs, migrations, schemas)
5. Config/infra (env files, deploy configs, docker-compose)
6. Existing tests (test folders, test configs, coverage)

If a QA repo was provided, also scan:
1. Folder structure and naming conventions
2. Test case count, coverage areas, assertion quality
3. POM structure and locator strategies
4. Framework config and CI integration
5. Test data management (fixtures, factories, env vars)

**Output**: Mental model of what the app does, its tech stack, critical paths, and risks.

### Milestone 2: Produce QA_ANALYSIS.md
Create `QA_ANALYSIS.md` with ALL these sections:

- **Architecture Overview**: system type, language, runtime, entry points table, internal layers, external dependencies with risk levels
- **Risk Assessment**: HIGH / MEDIUM / LOW items with justification
- **Top 10 Unit Test Targets**: table with module/function and rationale
- **Recommended Testing Pyramid**: percentages adjusted to this specific app
- **External Dependencies**: table with purpose and risk level

### Milestone 3: Produce TEST_INVENTORY.md
Create `TEST_INVENTORY.md` with concrete test cases following the pyramid.

Every test case MUST have: unique ID, exact target, concrete inputs, explicit expected outcome, priority. Follow the rules in CLAUDE.md — no vague assertions.

### Milestone 4: Gap Report (only if QA repo was provided)
If the user provided an existing QA repo:
- Produce `GAP_ANALYSIS.md` showing what exists vs what should exist
- List specific missing test cases
- Rate existing test quality (locator tiers, assertion quality, POM compliance)
- Do NOT modify existing tests — only report findings

If no QA repo was provided:
- Produce `QA_REPO_BLUEPRINT.md` describing the recommended repo structure
- Follow the structure defined in CLAUDE.md

## Definition of Done
- [ ] QA_ANALYSIS.md exists with all required sections
- [ ] TEST_INVENTORY.md has at least 10 test cases with explicit expected outcomes
- [ ] All test cases have unique IDs following naming convention
- [ ] Risks are categorized as HIGH/MEDIUM/LOW with justification
- [ ] Gap report or blueprint produced (depending on scenario)
