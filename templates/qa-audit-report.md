---
template_name: qa-audit-report
version: "1.0"
artifact_type: audit
produces: QA_AUDIT_REPORT.md
producer_agent: qa-validator
consumer_agents:
  - human-reviewer
  - qa-executor
required_sections:
  - executive-summary
  - six-dimension-scoring
  - critical-issues
  - improvement-recommendations
  - test-file-inventory
  - detailed-findings
example_domain: shopflow
---

# QA_AUDIT_REPORT.md Template

**Purpose:** Comprehensive quality audit of an existing test suite across 6 dimensions, producing a quantified health score and actionable improvement plan. This is the most detailed assessment artifact in the QA pipeline.

**Producer:** `qa-validator` (audit mode -- invoked via `/qa-audit` or as part of Option 2/3 workflow)
**Consumers:** `human-reviewer` (evaluates test suite quality and decides on improvements), `qa-executor` (implements recommended fixes)

---

## Required Sections

### Section 1: Executive Summary

**Description:** High-level assessment with an overall health score, key strengths, weaknesses, and a pass/fail recommendation.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| overall_score | integer (0-100) | YES | Weighted average across all 6 dimensions |
| letter_grade | string | YES | A (90-100), B (80-89), C (70-79), D (60-69), F (< 60) |
| assessment | string | YES | One-paragraph summary of the test suite health |
| key_strengths | list | YES | 2-3 bullet points of what the test suite does well |
| key_weaknesses | list | YES | 2-3 bullet points of the most impactful problems |
| recommendation | string | YES | `PASS -- ready for CI` or `NEEDS IMPROVEMENT -- address critical issues first` |

**Grade Scale:**

| Grade | Score Range | Meaning |
|-------|------------|---------|
| A | 90 - 100 | Excellent -- test suite is production-ready, minimal improvements needed |
| B | 80 - 89 | Good -- minor quality issues, safe for CI with improvements tracked |
| C | 70 - 79 | Acceptable -- notable quality gaps, address before scaling test suite |
| D | 60 - 69 | Below Standard -- significant issues, prioritize fixes before adding new tests |
| F | < 60 | Failing -- critical problems must be resolved before test suite is reliable |

---

### Section 2: 6-Dimension Scoring

**Description:** Quantified assessment across 6 quality dimensions, each with an independent score, weight, and key finding. The weighted total produces the overall health score.

**Scoring Table Columns:**

| Column | Description |
|--------|-------------|
| Dimension | Name of the quality dimension |
| Score | Independent score (0-100) for this dimension |
| Grade | Letter grade for this dimension's score |
| Weight | How much this dimension contributes to the overall score (percentages must sum to 100%) |
| Weighted Score | Score * Weight (used in overall calculation) |
| Key Finding | One-sentence summary of the most important finding for this dimension |

**The 6 Dimensions:**

#### Dimension 1: Locator Quality (Weight: 20%)

Measures how resilient test selectors are to UI changes.

| Score Range | Criteria |
|-------------|----------|
| 90-100 | > 90% Tier 1+2 locators, zero Tier 4 without TODO comments |
| 70-89 | > 70% Tier 1+2, Tier 4 locators all have TODO comments |
| 50-69 | 50-70% Tier 1+2, some Tier 4 without TODO |
| 30-49 | < 50% Tier 1+2, heavy Tier 4 usage |
| 0-29 | Almost all Tier 4 CSS/XPath selectors, no test IDs |

**Deductions:** -5 points for each Tier 4 locator without a `// TODO: Request test ID` comment.

#### Dimension 2: Assertion Specificity (Weight: 20%)

Measures how precisely tests validate expected behavior.

| Score Range | Criteria |
|-------------|----------|
| 90-100 | > 95% concrete assertions with specific expected values |
| 70-89 | 80-95% concrete, few vague assertions |
| 50-69 | 60-80% concrete, notable vague assertions |
| 30-49 | 40-60% concrete, many `toBeTruthy`/`toBeDefined`/`should('exist')` |
| 0-29 | < 40% concrete, most assertions are vague |

**Concrete examples:** `toBe(200)`, `toEqual({name: 'Test'})`, `toHaveText('Login successful')`
**Vague examples:** `toBeTruthy()`, `toBeDefined()`, `not.toBeNull()`, `should('exist')`

#### Dimension 3: POM Compliance (Weight: 15%)

Measures adherence to Page Object Model rules.

**6 POM Rules checked per page object:**
1. One class/object per page or view
2. No assertions in page objects (assertions belong in test specs only)
3. Locators defined as properties (in constructor or as class fields)
4. Actions return void or the next page (fluent chaining)
5. State queries return data (let the test decide what to assert)
6. Extends a shared BasePage class

| Score Range | Criteria |
|-------------|----------|
| 90-100 | All POMs pass all 6 rules |
| 70-89 | Minor violations (1-2 rules broken in 1-2 POMs) |
| 50-69 | Moderate violations (assertions in POMs, or no BasePage) |
| 30-49 | Multiple POMs break multiple rules |
| 0-29 | No POMs exist, or all POMs violate core rules |

#### Dimension 4: Test Coverage (Weight: 20%)

Measures how well the test suite covers the application, considering both pyramid distribution and module completeness.

| Score Range | Criteria |
|-------------|----------|
| 90-100 | All modules covered, pyramid distribution within 10% of recommended |
| 70-89 | Most modules covered, pyramid roughly correct |
| 50-69 | Some modules uncovered, pyramid distribution off by > 20% |
| 30-49 | Multiple critical modules uncovered |
| 0-29 | Minimal coverage, critical business logic untested |

**Sub-scores:** Pyramid distribution match (50%) + module coverage completeness (50%).

#### Dimension 5: Naming Convention (Weight: 15%)

Measures consistency of file names, test IDs, and fixture names against project standards.

| Score Range | Criteria |
|-------------|----------|
| 90-100 | > 95% of files, test IDs, and fixtures follow conventions |
| 70-89 | > 80% compliant, minor inconsistencies |
| 50-69 | 60-80% compliant, notable deviations |
| 30-49 | < 60% compliant, no consistent naming pattern |
| 0-29 | No naming convention followed |

**Conventions checked:**
- Test files: `[feature].e2e.spec.ts`, `[module].unit.spec.ts`, `[resource].api.spec.ts`
- Test IDs: `UT-MODULE-NNN`, `API-RESOURCE-NNN`, `E2E-FLOW-NNN`, `INT-MODULE-NNN`
- Page objects: `[PageName]Page.ts`
- Fixtures: `[domain]-data.ts` or `[domain]-data.json`

#### Dimension 6: Test Data Management (Weight: 10%)

Measures how test data is handled -- security, organization, and maintainability.

| Score Range | Criteria |
|-------------|----------|
| 90-100 | No hardcoded credentials, fixtures in dedicated folder, env vars with fallbacks, per-domain fixtures |
| 70-89 | Minor issues (missing .env.example, one fixture in wrong location) |
| 50-69 | Some hardcoded values, fixtures partially organized |
| 30-49 | Hardcoded credentials found, no fixture organization |
| 0-29 | Credentials in test files, no fixture strategy |

**Checks:**
- No hardcoded passwords, API keys, or tokens in test files
- Environment variables used with test fallback values
- Fixtures organized in a dedicated `fixtures/` directory
- Each business domain has its own fixture file (auth-data, product-data, etc.)
- `.env.example` or `.env.test` exists documenting required test env vars

**Overall Score Formula:**
```
Overall Score = (Locator * 0.20) + (Assertion * 0.20) + (POM * 0.15) +
               (Coverage * 0.20) + (Naming * 0.15) + (TestData * 0.10)
```

---

### Section 3: Critical Issues

**Description:** Issues with BLOCKER severity that must be fixed immediately. These prevent the test suite from being reliable in CI or production use.

**Per-Issue Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| file_path | string | YES | Path to the file containing the issue |
| line_number | integer | YES | Specific line number where the issue occurs |
| issue | string | YES | Description of the problem |
| why_critical | string | YES | Why this blocks CI/delivery |
| suggested_fix | string | YES | Specific action to resolve the issue |
| dimension | string | YES | Which of the 6 dimensions this relates to |

**BLOCKER Criteria:**
- Assertions inside page objects (POM violation)
- Hardcoded real credentials in test files (security)
- Tier 4 locators on critical user flows without TODO (fragility)
- Tests that always pass regardless of application state (false positives)
- Missing error handling that masks test failures

---

### Section 4: Improvement Recommendations

**Description:** Prioritized improvement actions, grouped by effort level, with estimated score impact for each recommendation.

**Per-Recommendation Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| recommendation | string | YES | What to do |
| dimension | string | YES | Which quality dimension this improves |
| effort | string | YES | S (< 1 hour), M (1-4 hours), L (4+ hours) |
| score_impact | string | YES | Expected improvement (e.g., "+8 points to Locator Quality") |
| priority | integer | YES | Execution order (1 = do first) |

**Grouping:** Quick wins (S effort) first, then medium effort, then large effort.

---

### Section 5: Test File Inventory

**Description:** Complete inventory of all test files with counts, tiers, and status.

**Summary Statistics:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| total_test_files | integer | YES | Count of all test files |
| total_test_cases | integer | YES | Count of all individual test cases |
| unit_count | integer | YES | Unit test count |
| integration_count | integer | YES | Integration test count |
| api_count | integer | YES | API test count |
| e2e_count | integer | YES | E2E test count |

**Per-File Table Columns:**

| Column | Description |
|--------|-------------|
| File Path | Path to the test file |
| Tier | Unit, Integration, API, or E2E |
| Test Count | Number of test cases in the file |
| Status | PASS / FAIL / ERROR |
| Last Modified | Date the file was last changed |

---

### Section 6: Detailed Findings

**Description:** Per-test-file breakdown of every issue found during the audit. This is the most granular section, providing line-level detail for each finding.

**Per-File Structure:**

```markdown
#### {file_path}

| Line | Issue | Severity | Dimension | Description | Suggested Fix |
|------|-------|----------|-----------|-------------|---------------|
```

**Severity Levels:**

| Severity | Meaning | Action |
|----------|---------|--------|
| BLOCKER | Must fix immediately -- blocks CI/delivery | Also listed in Critical Issues section |
| WARNING | Should fix soon -- degrades quality | Include in improvement plan |
| INFO | Nice to improve -- minor quality enhancement | Address when convenient |

---

## Worked Example (ShopFlow E-Commerce API)

### Executive Summary

**Overall Score: 62/100 (Grade: D)**

The ShopFlow test suite has a solid foundation with good API test coverage for the authentication module and reasonable assertion specificity (70% concrete). However, the test suite is held back by heavy reliance on fragile CSS selectors (60% Tier 4 locators), POM violations with assertions found in page objects, and hardcoded test credentials. Two of five business modules (Orders, Payments) have zero test coverage.

**Key Strengths:**
- Auth module has tests across unit, API, and E2E tiers -- best-covered module
- API tests use concrete assertions with specific status codes and response shapes
- Test pyramid distribution roughly follows the recommended pattern (60% unit)

**Key Weaknesses:**
- 60% of locators are Tier 4 CSS selectors -- already caused a broken E2E test
- Assertions found inside 2 of 4 page objects (LoginPage.ts, ProductPage.ts)
- Hardcoded email `admin@shopflow.com` and password `TestPass123!` found in test files

**Recommendation: NEEDS IMPROVEMENT -- address 3 critical issues (POM assertions, hardcoded credentials, fragile locators) before adding new tests or integrating into CI.**

### 6-Dimension Scoring

| Dimension | Score | Grade | Weight | Weighted Score | Key Finding |
|-----------|-------|-------|--------|----------------|-------------|
| Locator Quality | 45 | F | 20% | 9.00 | 9 of 15 locators are Tier 4 CSS selectors with no TODO comments |
| Assertion Specificity | 70 | C | 20% | 14.00 | 5 vague assertions found (toBeTruthy, should('exist')) across 3 files |
| POM Compliance | 55 | F | 15% | 8.25 | Assertions found in LoginPage.ts and ProductPage.ts; 2 of 4 POMs lack BasePage |
| Test Coverage | 80 | B | 20% | 16.00 | Auth and Products well covered; Orders, Payments, Inventory have zero tests |
| Naming Convention | 65 | D | 15% | 9.75 | 3 files do not follow naming pattern; 4 test IDs use non-standard format |
| Test Data Management | 60 | D | 10% | 6.00 | 2 hardcoded emails found; no .env.example or .env.test file exists |

**Overall Score Calculation:**
```
Overall = (45 * 0.20) + (70 * 0.20) + (55 * 0.15) + (80 * 0.20) + (65 * 0.15) + (60 * 0.10)
        = 9.00 + 14.00 + 8.25 + 16.00 + 9.75 + 6.00
        = 63.00
```

**Rounded: 63/100 -- Grade D (Below Standard)**

*Note: The Executive Summary reports 62 due to rounding at the dimension level. The dimension-level calculation yields 63 from the rounded inputs shown above. Either value falls within Grade D.*

### Critical Issues

| # | File Path | Line | Issue | Why Critical | Suggested Fix | Dimension |
|---|-----------|------|-------|-------------|---------------|-----------|
| 1 | `pages/LoginPage.ts` | 34 | `expect(this.errorMessage).toBeVisible()` -- assertion inside page object | Violates POM rule #2. Page objects must not contain assertions. This couples the page object to specific test expectations, making it impossible to reuse for different assertion scenarios. | Move assertion to the test spec. Replace with a state query method: `async getErrorMessage(): Promise<string>` that returns the text content. | POM Compliance |
| 2 | `tests/e2e/auth/login.e2e.spec.ts` | 15 | Hardcoded password: `const password = 'TestPass123!'` | Credentials in source code are a security risk. This file is committed to git, making the test password visible in repo history. If this matches any real password, it's a breach. | Move to `.env.test` file: `process.env.TEST_PASSWORD` with fallback. Add `.env.test` to `.gitignore`. | Test Data Management |
| 3 | `tests/e2e/auth/login.e2e.spec.ts` | 22 | `page.locator('.login-form .btn-primary')` -- Tier 4 CSS selector on critical login flow | Login is the most critical user flow. A CSS selector on this path has already broken once (see broken tests). This will break again on any UI restyling. | Replace with `page.getByTestId('login-submit-btn')` after testid-injector adds the attribute. Add `// TODO: Request test ID for this element` as interim fix. | Locator Quality |

### Improvement Recommendations

#### Quick Wins (S effort)

| # | Recommendation | Dimension | Effort | Score Impact |
|---|---------------|-----------|--------|-------------|
| 1 | Move assertions out of LoginPage.ts (line 34) and ProductPage.ts (line 48) into their respective test specs | POM Compliance | S | +20 points to POM Compliance (55 -> 75) |
| 2 | Replace 2 hardcoded emails with `process.env.TEST_EMAIL` and add `.env.test` file | Test Data Management | S | +15 points to Test Data (60 -> 75) |
| 3 | Rename `login-test.spec.ts` to `login.e2e.spec.ts` and `product-tests.spec.ts` to `products.api.spec.ts` | Naming Convention | S | +10 points to Naming (65 -> 75) |
| 4 | Fix 4 non-standard test IDs (T-001 through T-004) to follow UT-MODULE-NNN pattern | Naming Convention | S | +5 points to Naming (75 -> 80) |

#### Medium Effort (M)

| # | Recommendation | Dimension | Effort | Score Impact |
|---|---------------|-----------|--------|-------------|
| 5 | Replace 5 vague assertions with concrete values (see Detailed Findings for each) | Assertion Specificity | M | +10 points to Assertion (70 -> 80) |
| 6 | Add BasePage class and update LoginPage.ts and OrderPage.ts to extend it | POM Compliance | M | +15 points to POM Compliance (75 -> 90) |
| 7 | Migrate 9 Tier 4 locators to Tier 1 (data-testid) -- coordinate with testid-injector | Locator Quality | M | +35 points to Locator (45 -> 80) |

#### Large Effort (L)

| # | Recommendation | Dimension | Effort | Score Impact |
|---|---------------|-----------|--------|-------------|
| 8 | Add unit and API tests for Orders and Payments modules (5+ test cases) | Test Coverage | L | +10 points to Coverage (80 -> 90) |

**Projected score after all improvements:** ~84/100 (Grade B)

### Test File Inventory

**Summary:** 6 test files, 15 test cases

| Tier | File Count | Test Count | Percentage |
|------|-----------|------------|------------|
| Unit | 4 | 9 | 60% |
| Integration | 0 | 0 | 0% |
| API | 1 | 5 | 33% |
| E2E | 1 | 1 | 7% |
| **Total** | **6** | **15** | **100%** |

| File Path | Tier | Test Count | Status | Last Modified |
|-----------|------|------------|--------|---------------|
| `tests/unit/auth/auth.unit.spec.ts` | Unit | 3 | PASS | 2026-03-10 |
| `tests/unit/auth/tokenRefresh.unit.spec.ts` | Unit | 1 | FAIL | 2026-03-08 |
| `tests/unit/products/products.unit.spec.ts` | Unit | 2 | PASS | 2026-03-12 |
| `tests/unit/utils/validators.unit.spec.ts` | Unit | 3 | PASS | 2026-03-14 |
| `tests/api/auth/auth.api.spec.ts` | API | 3 | PASS | 2026-03-11 |
| `tests/api/products/products.api.spec.ts` | API | 2 | FAIL (1 of 2) | 2026-03-09 |
| `tests/e2e/auth/login.e2e.spec.ts` | E2E | 1 | FAIL | 2026-03-07 |

### Detailed Findings

#### tests/unit/auth/auth.unit.spec.ts

| Line | Issue | Severity | Dimension | Description | Suggested Fix |
|------|-------|----------|-----------|-------------|---------------|
| 45 | Vague assertion | WARNING | Assertion Specificity | `expect(data).toBeDefined()` -- does not check what `data` contains | Replace with `expect(data).toEqual({id: expect.any(String), email: 'test@shopflow.com'})` |
| 62 | Vague assertion | WARNING | Assertion Specificity | `expect(user).toBeTruthy()` -- does not verify user properties | Replace with `expect(user.email).toBe('test@shopflow.com')` and `expect(user.id).toMatch(/^usr_/)` |
| 15 | Hardcoded email | INFO | Test Data Management | `const email = 'admin@shopflow.com'` -- hardcoded test email | Move to fixture file or env variable with fallback |

#### tests/unit/auth/tokenRefresh.unit.spec.ts

| Line | Issue | Severity | Dimension | Description | Suggested Fix |
|------|-------|----------|-----------|-------------|---------------|
| 8 | Missing env fallback | BLOCKER | Test Data Management | `process.env.JWT_SECRET` used without fallback -- test fails if env not set | Add fallback: `const secret = process.env.JWT_SECRET ?? 'test-jwt-secret-for-testing'` |
| 30 | Vague assertion | WARNING | Assertion Specificity | `expect(token).not.toBeNull()` -- does not validate token format | Replace with `expect(token).toMatch(/^eyJ/)` to verify JWT format |
| 1 | Naming convention | INFO | Naming Convention | Test ID `T-001` does not follow `UT-AUTH-NNN` convention | Rename to `UT-AUTH-003` |

#### tests/e2e/auth/login.e2e.spec.ts

| Line | Issue | Severity | Dimension | Description | Suggested Fix |
|------|-------|----------|-----------|-------------|---------------|
| 15 | Hardcoded password | BLOCKER | Test Data Management | `const password = 'TestPass123!'` -- credential in source code | Move to `.env.test`: `process.env.TEST_PASSWORD ?? 'FallbackTestPass1!'` |
| 22 | Tier 4 locator | BLOCKER | Locator Quality | `page.locator('.login-form .btn-primary')` -- fragile CSS selector on critical path | Replace with `page.getByTestId('login-submit-btn')` after test ID injection |
| 28 | Tier 4 locator | WARNING | Locator Quality | `page.locator('.login-form input[name="email"]')` -- Tier 4 attribute selector | Replace with `page.getByTestId('login-email-input')` |
| 34 | Tier 4 locator | WARNING | Locator Quality | `page.locator('.login-form input[name="password"]')` -- Tier 4 attribute selector | Replace with `page.getByTestId('login-password-input')` |
| 52 | Vague assertion | WARNING | Assertion Specificity | `cy.get('.result').should('exist')` -- does not check content | Replace with `page.getByTestId('login-success-alert').toHaveText('Welcome back!')` |
| 1 | File name | INFO | Naming Convention | File could be at `tests/e2e/auth/login.e2e.spec.ts` (already correct) | No action needed |

#### tests/api/products/products.api.spec.ts

| Line | Issue | Severity | Dimension | Description | Suggested Fix |
|------|-------|----------|-----------|-------------|---------------|
| 28 | Vague assertion | WARNING | Assertion Specificity | `expect(response.status).toBeTruthy()` -- any non-zero status passes | Replace with `expect(response.status).toBe(200)` |
| 35 | Hardcoded count | WARNING | Assertion Specificity | `expect(data.length).toBe(10)` -- brittle to seed data changes | Replace with `expect(data.length).toBeGreaterThan(0)` and add schema validation for each item |
| 1 | File name | INFO | Naming Convention | File name `products.api.spec.ts` follows convention | No action needed |

#### pages/LoginPage.ts

| Line | Issue | Severity | Dimension | Description | Suggested Fix |
|------|-------|----------|-----------|-------------|---------------|
| 34 | Assertion in POM | BLOCKER | POM Compliance | `expect(this.errorMessage).toBeVisible()` -- page objects must not assert | Remove assertion. Add method: `async getErrorText(): Promise<string> { return this.errorMessage.textContent(); }` |
| 5 | No BasePage | WARNING | POM Compliance | Does not extend a shared BasePage class | Add `extends BasePage` and import shared base |
| 12 | Inline locator | INFO | POM Compliance | `this.page.locator('.error-message')` defined inline instead of as class property | Extract to class property: `readonly errorMessage = this.page.getByTestId('login-error-alert')` |

#### pages/ProductPage.ts

| Line | Issue | Severity | Dimension | Description | Suggested Fix |
|------|-------|----------|-----------|-------------|---------------|
| 48 | Assertion in POM | BLOCKER | POM Compliance | `expect(this.productList.count()).toBeGreaterThan(0)` -- assertion in page object | Remove assertion. Add method: `async getProductCount(): Promise<number> { return this.productList.count(); }` |
| 22 | Tier 4 locator | WARNING | Locator Quality | `this.page.locator('.product-card')` -- CSS class selector | Replace with `this.page.getByTestId('product-card')` after test ID injection |
| 30 | Tier 4 locator | WARNING | Locator Quality | `this.page.locator('.product-price')` -- CSS class selector | Replace with `this.page.getByTestId('product-price-text')` |

---

## Guidelines

**DO:**
- Calculate the weighted score explicitly -- show the math so reviewers can verify
- Provide exact line numbers for every finding in the Detailed Findings section
- Include specific suggested fixes, not just "improve this" -- show the replacement code or pattern
- Cross-reference Critical Issues with Detailed Findings (every BLOCKER appears in both sections)
- Show the projected score improvement for each recommendation

**DON'T:**
- Give a high score just because tests exist -- quality matters more than quantity
- Rate Locator Quality above 50 if more than half the locators are Tier 4
- Skip the formula calculation -- always show the weighted math explicitly
- List INFO-level issues as Critical -- only BLOCKER severity belongs in the Critical Issues section
- Combine findings from multiple files into one entry -- each file gets its own Detailed Findings table
- Ignore test data security -- hardcoded credentials are always BLOCKER severity

---

## Quality Gate

Before delivering this artifact, verify:

- [ ] Overall score matches the weighted calculation from the 6-Dimension table (show the math)
- [ ] Dimension weights sum to exactly 100% (20 + 20 + 15 + 20 + 15 + 10 = 100)
- [ ] Every BLOCKER in Detailed Findings also appears in Critical Issues section
- [ ] Every finding in Detailed Findings has a specific line number and suggested fix
- [ ] Improvement Recommendations include projected score impact for each action
- [ ] Test File Inventory matches the actual count of test files and test cases
- [ ] No real credentials, API keys, or secrets appear in the report itself
- [ ] Grade assignment matches the score range (verify against grade scale)

---

*Template version: 1.0*
*Producer: qa-validator*
*Last updated: {date}*
