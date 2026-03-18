# Spec: Create Automated Tests

## Goal
Generate production-ready Playwright test files with POM pattern for a specific feature or module. Follow all standards defined in CLAUDE.md.

## Input
The user will specify which feature to test (e.g., "login", "checkout", "user API").
If QA_ANALYSIS.md and TEST_INVENTORY.md exist, use them as the source of truth.

## Milestones

### Milestone 1: Understand the Feature
Read all source files related to the target feature:
- Routes/controllers
- Service/business logic
- Data models and validation
- Frontend components (if applicable)
- Existing tests (if any)

Identify: pages/views involved, API endpoints, business rules, error states, edge cases, auth requirements.

### Milestone 2: Create Repo Structure
If the test structure doesn't exist yet, create it following CLAUDE.md standards:
- `tests/` with e2e/smoke, e2e/regression, api, unit subdirectories
- `pages/` with base/ and feature-specific folders
- `fixtures/` for test data
- `playwright.config.ts`

### Milestone 3: Create Page Objects
For each page/view involved:
1. Create BasePage.ts if it doesn't exist (use template from CLAUDE.md)
2. Create feature-specific POM following CLAUDE.md rules:
   - Locators follow the tier hierarchy
   - No assertions in POM
   - Readonly locator properties
   - Actions return void or next page
   - State queries return data

### Milestone 4: Create Test Specs
For each feature, create at minimum:
- 1 happy path test (P0)
- 1 error/negative test (P0)
- 1 edge case test (P1)

Follow CLAUDE.md rules:
- Explicit assertions with concrete values
- Unique test IDs following naming convention
- No hardcoded credentials

### Milestone 5: Create Fixtures & Config
- Test data files in `fixtures/` using env vars with fallbacks
- `playwright.config.ts` if it doesn't exist

### Milestone 6: Validate
Before delivering:
- Run `npx tsc --noEmit` if tsconfig exists
- Verify all CLAUDE.md quality gates pass
- List all created files with summary

## Definition of Done
- [ ] All POM files follow CLAUDE.md rules (no assertions, tier hierarchy, BasePage)
- [ ] All test specs have explicit expected outcomes
- [ ] Test IDs are unique and follow naming convention
- [ ] No hardcoded credentials anywhere
- [ ] Playwright config exists
- [ ] File naming follows CLAUDE.md conventions
