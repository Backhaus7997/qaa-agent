---
name: qa-template-engine
description: QA Template Engine. Creates production-ready test files with POM pattern, explicit assertions, and proper structure. Use when user wants to generate test files, create test templates, write test code, scaffold test suites, produce executable tests, or create test specs from an inventory. Triggers on "generate tests", "create test files", "write tests", "scaffold tests", "test templates", "produce test code", "executable tests", "create test spec".
---

# QA Template Engine

## Purpose

Create definitive, production-ready test files with explicit expected outcomes, proper POM architecture, and framework-specific best practices.

## Core Rule

**NO test case is complete without an expected outcome that a junior QA engineer could verify without asking questions.**

## Framework Detection

Before generating ANY code:
1. Check for existing config: playwright.config.ts, cypress.config.ts, jest.config.ts, vitest.config.ts, pytest.ini
2. Check package.json/requirements.txt for test dependencies
3. Check existing test files for patterns and conventions
4. **Always match the project's existing framework**

If no framework exists, ask the user.

## Test Template Categories

### Unit Test Template
```
Test ID: UT-[MODULE]-[NNN]
Target: [file]:[function]
Priority: P[0-2]

// Arrange
const input = [concrete value];
const expected = [concrete value];

// Act
const result = functionUnderTest(input);

// Assert
expect(result).toBe(expected); // NEVER toBeTruthy/toBeDefined
```

### API Test Template
```
Test ID: API-[RESOURCE]-[NNN]
Target: [METHOD] [endpoint]
Priority: P[0-2]

// Arrange
const payload = { [concrete data] };

// Act
const response = await api.[method]('[endpoint]', payload);

// Assert
expect(response.status).toBe([exact code]);
expect(response.body.[field]).toBe('[exact value]');
```

### E2E Test Template (Playwright)
```
Test ID: E2E-[FLOW]-[NNN]
Target: [user flow description]
Priority: P[0-2]

// Arrange
await loginPage.navigate();

// Act
await loginPage.login('[email]', '[password]');

// Assert
await expect(dashboardPage.welcomeMessage).toHaveText('Welcome, Test User');
```

## POM Generation Rules

Following CLAUDE.md strictly:
1. One class per page — no god objects
2. No assertions in page objects — assertions in test specs ONLY
3. Locators as readonly properties — Tier 1 preferred (data-testid, ARIA roles)
4. Actions return void or next page
5. State queries return data
6. Every POM extends BasePage

## Locator Priority

Always use this order:
1. data-testid: `page.getByTestId('login-submit-btn')`
2. ARIA role: `page.getByRole('button', { name: 'Log in' })`
3. Label/placeholder: `page.getByLabel('Email')`
4. CSS selector: `page.locator('.btn')` + `// TODO: Request test ID`

## Expected Outcome Rules

- **Be specific**: Exact values, status codes, text content
- **Be measurable**: Timing thresholds, counts, lengths
- **Be negative too**: What should NOT happen
- **Include state transitions**: Before/after states
- **Reference test data**: Use fixture values, not magic strings

## Quality Gate

- [ ] Every test has explicit expected outcome with concrete value
- [ ] No vague words: "correct", "proper", "appropriate", "works"
- [ ] All locators follow tier hierarchy
- [ ] No assertions inside page objects
- [ ] No hardcoded credentials
- [ ] File naming follows project conventions
- [ ] Test IDs are unique and follow convention
- [ ] Priority (P0/P1/P2) assigned to every test
