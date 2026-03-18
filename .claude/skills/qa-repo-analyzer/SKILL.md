---
name: qa-repo-analyzer
description: QA Repository Analyzer. Analyzes a dev repository and produces a complete QA baseline package including testability report, test inventory, and repo blueprint. Use when user wants to analyze a repo for testing, assess testability, generate test inventory, create QA baseline, understand test coverage needs, evaluate a codebase for QA, or produce a testing strategy. Triggers on "analyze repo", "testability report", "test inventory", "QA analysis", "QA baseline", "coverage assessment", "what should we test", "testing strategy".
---

# QA Repository Analyzer

## Purpose

Analyze a developer repository and produce a complete QA baseline package: Testability Report, Test Inventory (pyramid-based), and QA Repo Blueprint.

## Core Rule

**Every analysis must be specific to the actual codebase — never generic advice. Every test case must have an explicit expected outcome.**

## Execution Steps

### Step 0: Collect Repo Context

Scan the repository systematically:
- Folder tree (entry points, structure)
- Package files (dependencies, scripts, framework detection)
- Service/controller files (API surface area)
- Model files (data structures, validation)
- Database layer (ORM, migrations, schemas)
- External integrations (payment, email, storage, queues)
- Existing test coverage (test files, config, CI)
- Configuration (env vars, feature flags)

### Step 1: Pre-Analysis — Assumptions & Questions

Before generating deliverables, list:
- **Assumptions**: What you're inferring from the code (e.g., "Auth uses JWT based on middleware")
- **Questions**: What's ambiguous (e.g., "Is the Stripe integration in production or test mode?")

Present to user for confirmation before proceeding.

### Step 2: Deliverable A — QA_ANALYSIS.md (Testability Report)

Produce with ALL these sections:
- **Architecture Overview**: System type, language, runtime, entry points table, internal layers
- **External Dependencies**: Table with purpose and risk level (HIGH/MEDIUM/LOW)
- **Risk Assessment**: Prioritized risks with justification
- **Top 10 Unit Test Targets**: Table with module/function, why it's high-priority, complexity assessment
- **API/Contract Test Targets**: Endpoints that need contract testing
- **Recommended Testing Pyramid**: Percentages adjusted to this specific app's architecture

### Step 3: Deliverable B — TEST_INVENTORY.md (Test Cases)

Generate pyramid-based test inventory:

**Unit Tests** (60-70%): For each target:
- Test ID (UT-MODULE-NNN)
- Target (file path + function)
- What to validate
- Concrete inputs
- Mocks needed
- Explicit expected outcome

**Integration/Contract Tests** (10-15%): Component interactions, API contracts

**API Tests** (20-25%): For each endpoint:
- Test ID (API-RESOURCE-NNN)
- Method + endpoint
- Request body/params
- Expected status + response shape

**E2E Smoke Tests** (3-5%): Max 3-8 critical user paths

### Step 4: QA_REPO_BLUEPRINT.md

If no QA repo exists, generate:
- Suggested repo name and folder structure
- Recommended stack (framework, runner, reporter)
- Config files needed
- Execution scripts (npm scripts, CI commands)
- CI/CD strategy (smoke on PR, regression nightly)
- Definition of Done checklist

## Quality Gate

- [ ] Architecture overview matches actual codebase (not generic)
- [ ] Every test case has explicit expected outcome with concrete values
- [ ] No vague assertions ("works correctly", "returns proper data")
- [ ] Test IDs follow naming convention
- [ ] Priority (P0/P1/P2) assigned to every test case
- [ ] Risks are specific with evidence from the code
- [ ] Testing pyramid percentages are justified for this architecture
