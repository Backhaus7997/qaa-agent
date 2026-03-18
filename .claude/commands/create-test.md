# Create Automated Tests

Generate production-ready test files with POM pattern for a specific feature or module. Follow all standards in CLAUDE.md.

## Instructions

### Step 1: Understand the Feature

The user will specify which feature to test (e.g., "login", "checkout", "user API").
If QA_ANALYSIS.md and TEST_INVENTORY.md exist, use them as source of truth.

Read all source files related to the target feature:
- Routes/controllers
- Service/business logic
- Data models and validation
- Frontend components (if applicable)
- Existing tests (if any)

Identify: pages/views involved, API endpoints, business rules, error states, edge cases, auth requirements.

### Step 2: Detect Framework

Before generating any code, detect the project's existing test framework:
1. Check for config files: playwright.config.ts, cypress.config.ts, jest.config.ts, vitest.config.ts, pytest.ini
2. Check package.json/requirements.txt for test dependencies
3. Check existing test files for patterns
4. Match the project's existing framework, language, and conventions

If no framework exists, ask the user which to use.

### Step 3: Create Repo Structure (if needed)

If the test structure doesn't exist yet, create it following CLAUDE.md standards:
- tests/ with e2e/smoke, e2e/regression, api, unit subdirectories
- pages/ with base/ and feature-specific folders
- fixtures/ for test data

### Step 4: Create Page Objects (for E2E tests)

For each page/view involved:
1. Create BasePage if it doesn't exist
2. Create feature-specific POM:
   - Locators follow the tier hierarchy (data-testid first)
   - No assertions in POM
   - Actions return void or next page
   - State queries return data

### Step 5: Create Test Specs

For each feature, create at minimum:
- 1 happy path test (P0)
- 1 error/negative test (P0)
- 1 edge case test (P1)

Every test MUST have: unique ID, explicit assertions with concrete values, no hardcoded credentials.

### Step 6: Validate

- Run syntax check (tsc --noEmit if TypeScript)
- Verify all CLAUDE.md quality gates pass
- List all created files with summary

$ARGUMENTS
