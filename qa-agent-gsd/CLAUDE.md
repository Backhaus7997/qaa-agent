# QA Automation Standards

This project follows strict QA automation standards. Every test, page object, and analysis produced MUST follow these rules.

## Framework Detection

Before generating any code, **detect what the project already uses**:

1. Check for existing test config files: `cypress.config.ts`, `playwright.config.ts`, `jest.config.ts`, `vitest.config.ts`, `pytest.ini`, etc.
2. Check `package.json` or `requirements.txt` for test dependencies
3. Check existing test files for patterns and conventions
4. **Always match the project's existing framework, language, and conventions**

If no framework exists yet, ask the user which one to use. Never assume.

## Testing Pyramid

Target distribution for every project:

```
         /  E2E  \        3-5%   (critical path smoke only)
        /  API    \       20-25% (endpoints + contracts)
       / Integration\     10-15% (component interactions)
      /    Unit      \    60-70% (business logic, pure functions)
```

Adjust percentages based on the actual app architecture.

## Locator Strategy

All UI test locators MUST follow this priority order. Never skip to a lower tier without written justification.

**Tier 1 — BEST (always try these first):**
- Test IDs: `data-testid`, `data-cy`, `data-test` (adapt to framework)
- Semantic roles: ARIA roles + accessible name

**Tier 2 — GOOD (when Tier 1 not available):**
- Form labels, placeholders, visible text content

**Tier 3 — ACCEPTABLE (when Tier 1-2 not available):**
- Alt text, title attributes

**Tier 4 — LAST RESORT (always add a TODO comment):**
- CSS selectors, XPath — mark with `// TODO: Request test ID for this element`

### Framework-Specific Examples

**Playwright:**
```typescript
page.getByTestId('submit')           // Tier 1
page.getByRole('button', {name: 'Log in'})  // Tier 1
page.getByLabel('Email')             // Tier 2
page.locator('.btn')                 // Tier 4 — add TODO
```

**Cypress:**
```typescript
cy.get('[data-cy="submit"]')         // Tier 1
cy.findByRole('button', {name: 'Log in'})  // Tier 1 (with testing-library)
cy.get('[data-testid="submit"]')     // Tier 1
cy.contains('Submit')                // Tier 2
cy.get('.btn')                       // Tier 4 — add TODO
```

**Selenium / other:**
```
driver.findElement(By.cssSelector('[data-testid="submit"]'))  // Tier 1
driver.findElement(By.className('btn'))  // Tier 4 — add TODO
```

## Page Object Model Rules

These rules apply regardless of framework:

1. **One class/object per page or view** — no god objects
2. **No assertions in page objects** — assertions belong ONLY in test specs
3. **Locators are properties** — defined in constructor or as class fields
4. **Actions return void or the next page** — for fluent chaining
5. **State queries return data** — let the test file decide what to assert
6. **Every POM extends a shared base** — shared navigation, screenshots, waits

### POM File Structure
```
[pages or page-objects or support/page-objects]/
├── base/
│   └── BasePage.[ext]       ← shared methods
├── [feature]/
│   └── [Feature]Page.[ext]  ← one file per page
└── components/
    └── [Component].[ext]    ← reusable UI components
```

Adapt folder location to match the project's existing conventions.

## Test Spec Rules

### Every test case MUST have:
- **Unique ID**: `UT-MODULE-001`, `API-AUTH-001`, `E2E-FLOW-001`
- **Exact target**: file path + function name, or HTTP method + endpoint
- **Concrete inputs**: actual values, not "valid data"
- **Explicit expected outcome**: exact assertion, not "works correctly"
- **Priority**: P0 (blocks release), P1 (should fix), P2 (nice to have)

### BAD assertions (never do this):
```
expect(response.status).toBeTruthy()
expect(data).toBeDefined()
cy.get('.result').should('exist')  // what should it contain?
```

### GOOD assertions (always do this):
```
expect(response.status).toBe(200)
expect(data.name).toBe('Test User')
cy.get('[data-cy="result"]').should('have.text', 'Todo created successfully')
```

## Naming Conventions

Adapt file extensions to match the project's language:

| Type | Pattern | Example (.ts) | Example (.cy.ts) |
|------|---------|---------------|-------------------|
| Page Object | `[PageName]Page.[ext]` | `LoginPage.ts` | `LoginPage.ts` |
| Component POM | `[ComponentName].[ext]` | `NavigationBar.ts` | `NavigationBar.ts` |
| E2E test | `[feature].e2e.[ext]` | `login.e2e.spec.ts` | `login.e2e.cy.ts` |
| API test | `[resource].api.[ext]` | `users.api.spec.ts` | `users.api.cy.ts` |
| Unit test | `[module].unit.[ext]` | `validate.unit.spec.ts` | `validate.test.ts` |
| Fixture | `[domain]-data.[ext]` | `auth-data.ts` | `auth-data.json` |

If the project already has naming conventions, **follow those instead**.

## Repo Structure

Recommended structure — adapt to match what the project already has:

```
tests/ or cypress/ or __tests__/
├── e2e/
│   ├── smoke/              # P0 critical path (every PR)
│   └── regression/         # Full suite (nightly)
├── api/                    # API-level tests
└── unit/                   # Unit tests

pages/ or page-objects/ or support/page-objects/
├── base/
├── [feature]/
└── components/

fixtures/                   # Test data & factories
config/                     # Test configs (if separate from root)
reports/                    # Generated reports (gitignored)
```

## Test Data Rules

- **NEVER** hardcode real credentials
- Use environment variables with test fallbacks
- Fixtures go in dedicated folder
- Each domain gets its own fixture file

## Analysis Documents

When analyzing a repository, produce these documents:

### QA_ANALYSIS.md must include:
- Architecture overview (system type, language, runtime, entry points, dependencies)
- Risk assessment (HIGH / MEDIUM / LOW with justification)
- Top 10 unit test targets with rationale
- Recommended testing pyramid with percentages adjusted to this app
- External dependencies with risk levels

### TEST_INVENTORY.md must include:
- Every test case with ID, target, inputs, expected outcome, priority
- Organized by pyramid level (unit → integration → API → E2E)
- No test case without an explicit expected outcome

## Quality Gates

Before delivering ANY QA artifact, verify:
- [ ] Framework matches what the project already uses
- [ ] Every test case has an explicit expected outcome with a concrete value
- [ ] No outcome says "correct", "proper", "appropriate", or "works" without defining what that means
- [ ] All locators follow the tier hierarchy
- [ ] No assertions inside page objects
- [ ] No hardcoded credentials
- [ ] File naming follows the project's existing conventions (or the standards above if none exist)
- [ ] Test IDs are unique and follow naming convention
- [ ] Priority assigned to every test case
