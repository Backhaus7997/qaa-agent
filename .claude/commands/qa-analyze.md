# QA Repository Analysis

Quick analysis-only mode. Reads repo(s) and produces QA assessment documents without generating test files or creating PRs.

## Instructions

Analyze the target repository following ALL standards in CLAUDE.md.

### Step 1: Gather Input

Ask the user for:
1. Path to the DEV repo (required)
2. Path to the QA repo (optional)
3. Any specific areas of concern?

### Step 2: Repository Scan

Read the DEV repo thoroughly:
1. Root files (README, package.json/pyproject.toml/*.csproj, Dockerfile, CI configs)
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

### Step 3: Produce QA_ANALYSIS.md

Create `QA_ANALYSIS.md` with ALL these sections:
- **Architecture Overview**: system type, language, runtime, entry points table, internal layers, external dependencies with risk levels
- **Risk Assessment**: HIGH / MEDIUM / LOW items with justification
- **Top 10 Unit Test Targets**: table with module/function and rationale
- **Recommended Testing Pyramid**: percentages adjusted to this specific app
- **External Dependencies**: table with purpose and risk level

### Step 4: Produce TEST_INVENTORY.md

Create `TEST_INVENTORY.md` with concrete test cases following the testing pyramid.
Every test case MUST have: unique ID, exact target, concrete inputs, explicit expected outcome, priority.

### Step 5: Gap or Blueprint

- If QA repo provided: produce `GAP_ANALYSIS.md`
- If no QA repo: produce `QA_REPO_BLUEPRINT.md`

Output all files to the current directory. No git operations.

$ARGUMENTS
