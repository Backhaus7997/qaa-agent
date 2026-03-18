---
template_name: gap-analysis
version: "1.0"
artifact_type: gap-analysis
produces: GAP_ANALYSIS.md
producer_agent: qa-analyzer
consumer_agents:
  - qa-planner
  - qa-executor
required_sections:
  - coverage-map
  - missing-tests
  - broken-tests
  - quality-assessment
  - existing-test-inventory
  - recommendations
example_domain: shopflow
---

# GAP_ANALYSIS.md Template

**Purpose:** Identifies what tests exist, what is missing, and what is broken in an existing QA repository. Provides a complete picture of test coverage gaps, quality issues, and prioritized improvement actions.

**Producer:** `qa-analyzer` (Option 2/3 workflow -- when a QA repo already exists alongside the dev repo)
**Consumers:** `qa-planner` (uses gaps to prioritize test generation), `qa-executor` (uses missing test specs to write new tests)

---

## Required Sections

### Section 1: Coverage Map

**Description:** Matrix showing test coverage across modules/features and test pyramid tiers. Reveals which areas have adequate coverage and which have critical gaps.

**Matrix Format:**

| Column | Description |
|--------|-------------|
| Module/Feature | Business domain area (e.g., Auth, Products, Orders, Payments) |
| Unit | Count of existing unit tests for this module, or `NONE` |
| Integration | Count of existing integration tests, or `NONE` |
| API | Count of existing API tests, or `NONE` |
| E2E | Count of existing E2E tests, or `NONE` |
| Coverage | Percentage of recommended tests that exist for this module |

**Symbol Key:**
- Number (e.g., `3`) = tests exist and are counted
- `NONE` = zero tests exist for this module at this tier -- this is a gap
- Summary row shows totals per tier
- Summary column shows per-module coverage percentage

---

### Section 2: Missing Tests

**Description:** Prioritized list of test cases that DO NOT exist yet but SHOULD exist based on the codebase analysis. Each entry is a complete test specification ready for implementation.

**Per-Entry Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| test_id | string | YES | Following standard convention: `UT-MODULE-NNN`, `API-MODULE-NNN`, `INT-MODULE-NNN`, `E2E-FLOW-NNN` |
| target | string | YES | What should be tested: file path + function, or HTTP method + endpoint |
| tier | string | YES | Pyramid level: Unit, Integration, API, or E2E |
| why_missing | string | YES | What gap this fills (e.g., "No unit tests for payment calculation logic") |
| priority | string | YES | P0 (blocks release), P1 (should fix), P2 (nice to have) |
| estimated_effort | string | YES | S (< 1 hour), M (1-4 hours), L (4+ hours) |

**Grouping:** Entries are grouped by priority (P0 first, then P1, then P2).

---

### Section 3: Broken Tests

**Description:** Tests that EXIST in the repository but FAIL when executed. Each entry identifies the failure, diagnoses the root cause, and estimates fix effort.

**Per-Entry Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| test_file | string | YES | Path to the test file |
| test_name | string | YES | Name of the failing test case |
| failure_reason | string | YES | Specific error message or assertion failure |
| root_cause | string | YES | One of: stale selector, outdated assertion, missing fixture, environment dependency, code change, flaky timing |
| fix_effort | string | YES | S (quick fix), M (moderate rework), L (significant refactor) |
| fix_priority | string | YES | One of: immediate, next sprint, backlog |

---

### Section 4: Quality Assessment

**Description:** Four quality dimensions evaluated across all existing tests to assess the overall health of the test suite beyond just coverage counts.

**Dimension 1: Locator Tier Distribution**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| tier_1_count | integer | YES | `data-testid` and ARIA role selectors |
| tier_2_count | integer | YES | Labels, placeholders, text content |
| tier_3_count | integer | YES | Alt text, title attributes |
| tier_4_count | integer | YES | CSS selectors, XPath |
| tier_1_percent | percentage | YES | Tier 1 / total locators * 100 |
| tier_4_percent | percentage | YES | Tier 4 / total locators * 100 |

**Dimension 2: Assertion Quality**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| concrete_count | integer | YES | Assertions with specific expected values (toBe, toEqual, toHaveText with value) |
| vague_count | integer | YES | Assertions without specific values (toBeTruthy, toBeDefined, should('exist')) |
| concrete_percent | percentage | YES | Concrete / total assertions * 100 |
| examples_of_bad | list | YES | Up to 5 examples of vague assertions found in the codebase |

**Dimension 3: POM Compliance**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| total_page_objects | integer | YES | Count of page object files |
| assertions_in_poms | integer | YES | Count of page objects containing assertions (violation) |
| extends_base | integer | YES | Count of page objects that extend a shared BasePage |
| compliance_percent | percentage | YES | Fully compliant POMs / total POMs * 100 |

**Dimension 4: Naming Convention**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| files_following_convention | integer | YES | Test files named correctly (e.g., `*.e2e.spec.ts`, `*.api.spec.ts`) |
| files_not_following | integer | YES | Test files with non-standard names |
| test_ids_correct | integer | YES | Test IDs following `UT-MODULE-NNN` pattern |
| test_ids_incorrect | integer | YES | Test IDs with incorrect format or missing |
| naming_percent | percentage | YES | Compliant / total * 100 |

---

### Section 5: Existing Test Inventory

**Description:** Comprehensive inventory of what IS covered and working. Establishes the baseline before improvements are applied.

**Summary Table Columns:**

| Column | Description |
|--------|-------------|
| Test File | Path to the test file |
| Test Count | Number of test cases in the file |
| Tier | Unit, Integration, API, or E2E |
| Status | PASS (all tests pass), FAIL (some tests fail), ERROR (file does not execute) |
| Last Run | Date of the most recent test execution |

**Summary Statistics:**
- Total test files
- Total test cases
- Tests by status: PASS / FAIL / ERROR
- Tests by tier: Unit / Integration / API / E2E

---

### Section 6: Recommendations

**Description:** Prioritized action list for improving the test suite, ordered by ROI (impact vs effort). Actions are numbered and can be used directly as a work plan.

**Standard Recommendation Order:**
1. Fix broken tests first (highest ROI -- these were already written)
2. Add missing P0 tests (critical gaps that block release confidence)
3. Improve locator quality (migrate Tier 4 selectors to Tier 1)
4. Fix POM violations (remove assertions from page objects, add base class)
5. Add missing P1 tests (important gaps for regression coverage)
6. Address naming convention issues (consistency improvements)

**Per-Recommendation Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| action | string | YES | What to do |
| impact | string | YES | What improves (e.g., "Fixes 3 broken tests, restoring 20% coverage") |
| effort | string | YES | S/M/L |
| priority | string | YES | 1 (do first) through 6 (do last) |

---

## Worked Example (ShopFlow E-Commerce API)

### Coverage Map

| Module/Feature | Unit | Integration | API | E2E | Coverage |
|---------------|------|-------------|-----|-----|----------|
| Auth (login, register, refresh, logout) | 3 | NONE | 2 | 1 | 60% |
| Products (CRUD, search, categories) | 2 | NONE | 1 | NONE | 25% |
| Orders (create, status transitions, history) | NONE | NONE | NONE | NONE | 0% |
| Payments (charge, refund, webhook) | NONE | NONE | NONE | NONE | 0% |
| Inventory (stock, reservations, alerts) | NONE | NONE | NONE | NONE | 0% |
| **Totals** | **5** | **0** | **3** | **1** | **--** |

**Summary:** 9 tests exist across 6 test files, covering 2 of 5 modules. Orders, Payments, and Inventory have zero test coverage at any tier. No integration tests exist for any module. The existing test suite covers approximately 17% of the recommended test surface.

*Note: An additional 6 tests exist in utility files (validators, helpers) bringing the total to 15 tests across the repo.*

### Missing Tests

#### P0 -- Must Have (Blocks Release)

**UT-ORDER-001: Order state transition validation**
- **Target:** `src/services/orderService.ts:transitionOrderStatus`
- **Tier:** Unit
- **Why missing:** No unit tests exist for the order module. State machine logic (pending -> confirmed -> shipped -> delivered) is critical business logic with no validation.
- **Priority:** P0
- **Estimated effort:** M

**UT-PAY-001: Payment amount calculation with tax**
- **Target:** `src/services/paymentService.ts:calculateChargeAmount`
- **Tier:** Unit
- **Why missing:** Payment calculation affects revenue. No tests verify correct tax application or rounding behavior.
- **Priority:** P0
- **Estimated effort:** S

**API-PAY-001: Stripe charge endpoint**
- **Target:** `POST /api/v1/payments/charge`
- **Tier:** API
- **Why missing:** Payment endpoints have zero test coverage. Charge endpoint handles real money and must validate amounts, error responses, and Stripe error handling.
- **Priority:** P0
- **Estimated effort:** M

**API-PAY-002: Stripe webhook signature verification**
- **Target:** `POST /api/v1/payments/webhook`
- **Tier:** API
- **Why missing:** Webhooks are the only way to confirm payment status. Invalid signature handling and event processing must be tested.
- **Priority:** P0
- **Estimated effort:** M

**UT-ORDER-002: Order creation with inventory check**
- **Target:** `src/services/orderService.ts:createOrder`
- **Tier:** Unit
- **Why missing:** Order creation must check inventory availability. No tests verify the reservation-before-create flow.
- **Priority:** P0
- **Estimated effort:** M

#### P1 -- Should Have (Important for Regression)

**API-PROD-001: Product search with filters**
- **Target:** `GET /api/v1/products?category=electronics&sort=price`
- **Tier:** API
- **Why missing:** Product search is user-facing. Only basic GET exists in tests; no filter/sort/pagination tests.
- **Priority:** P1
- **Estimated effort:** S

**INT-INV-001: Inventory reservation during order placement**
- **Target:** `orderService.createOrder` -> `inventoryService.reserveStock`
- **Tier:** Integration
- **Why missing:** No integration tests exist. The order-inventory interaction is a critical cross-service boundary.
- **Priority:** P1
- **Estimated effort:** L

**API-ORDER-001: Order status transition endpoint**
- **Target:** `PATCH /api/v1/orders/:id/status`
- **Tier:** API
- **Why missing:** Order status changes affect fulfillment workflow. No API tests verify valid/invalid transitions or authorization.
- **Priority:** P1
- **Estimated effort:** M

#### P2 -- Nice to Have (Completeness)

**E2E-CHECKOUT-001: Complete checkout flow**
- **Target:** Browse -> Add to cart -> Checkout -> Payment -> Confirmation
- **Tier:** E2E
- **Why missing:** No E2E test covers the full purchase flow. Only auth E2E exists.
- **Priority:** P2
- **Estimated effort:** L

**UT-INV-001: Low stock alert threshold calculation**
- **Target:** `src/services/inventoryService.ts:checkLowStockAlert`
- **Tier:** Unit
- **Why missing:** Low stock alerts are a secondary feature. Business logic exists but has no test coverage.
- **Priority:** P2
- **Estimated effort:** S

### Broken Tests

| # | Test File | Test Name | Failure Reason | Root Cause | Fix Effort | Fix Priority |
|---|-----------|-----------|----------------|------------|------------|--------------|
| 1 | `tests/e2e/auth/login.e2e.spec.ts` | "should login with valid credentials" | `Error: locator('.login-btn') not found` | **Stale selector**: Login button was restyled from `className="login-btn"` to `className="btn btn-primary"` in a recent UI update. No `data-testid` on the element. | S | Immediate |
| 2 | `tests/api/products/products.api.spec.ts` | "should return product list" | `Expected: 10, Received: 15` | **Outdated assertion**: Test was written when seed data had 10 products. New products were added to the seed, but the assertion was not updated to use dynamic expectations. | S | Immediate |
| 3 | `tests/unit/auth/tokenRefresh.unit.spec.ts` | "should refresh expired token" | `Error: JWT_SECRET is not defined` | **Environment dependency**: Test requires `JWT_SECRET` env var but no `.env.test` file or fallback exists. Works locally for original author but fails in CI and for other developers. | S | Immediate |

### Quality Assessment

#### Locator Tier Distribution

| Tier | Count | Percentage | Examples |
|------|-------|------------|----------|
| Tier 1 (data-testid, ARIA roles) | 6 | 40% | `[data-testid="login-form"]`, `getByRole('button')` |
| Tier 2 (labels, text) | 0 | 0% | -- |
| Tier 3 (alt text, title) | 0 | 0% | -- |
| Tier 4 (CSS selectors, XPath) | 9 | 60% | `.login-btn`, `.product-card`, `#order-table` |

**Assessment:** 60% of locators are Tier 4 CSS selectors, making the E2E tests fragile to UI restyling. The broken login test (`locator('.login-btn')`) is a direct consequence of this. Migration to Tier 1 (`data-testid`) selectors is recommended.

#### Assertion Quality

| Type | Count | Percentage |
|------|-------|------------|
| Concrete assertions | 21 | 70% |
| Vague assertions | 9 | 30% |

**Examples of vague assertions found:**
1. `expect(response.status).toBeTruthy()` -- in `products.api.spec.ts` line 28 (should be `toBe(200)`)
2. `expect(data).toBeDefined()` -- in `auth.unit.spec.ts` line 45 (should check specific properties)
3. `cy.get('.result').should('exist')` -- in `login.e2e.spec.ts` line 52 (should check text content)
4. `expect(token).not.toBeNull()` -- in `tokenRefresh.unit.spec.ts` line 30 (should verify token format)
5. `expect(user).toBeTruthy()` -- in `auth.unit.spec.ts` line 62 (should verify user properties)

#### POM Compliance

| Check | Result |
|-------|--------|
| Total page objects | 4 |
| One class per page | 4/4 (PASS) |
| No assertions in POMs | 2/4 (FAIL) -- assertions found in LoginPage.ts and ProductPage.ts |
| Locators as properties | 3/4 (PASS) -- OrderPage.ts uses inline selectors |
| Actions return void/page | 4/4 (PASS) |
| Extends shared base | 2/4 (FAIL) -- LoginPage.ts and OrderPage.ts do not extend BasePage |
| **Compliance** | **50%** (2 of 4 fully compliant) |

**Violations:**
- `LoginPage.ts` line 34: `expect(this.errorMessage).toBeVisible()` -- assertion in page object
- `ProductPage.ts` line 48: `expect(this.productList.count()).toBeGreaterThan(0)` -- assertion in page object

#### Naming Convention

| Check | Compliant | Non-Compliant |
|-------|-----------|---------------|
| File names | 4 | 2 |
| Test IDs | 8 | 4 |
| **Overall** | **65%** | **35%** |

**Issues:**
- `tests/e2e/login-test.spec.ts` should be `login.e2e.spec.ts` (missing `.e2e.` tier indicator)
- `tests/api/product-tests.spec.ts` should be `products.api.spec.ts` (wrong naming pattern)
- Test IDs `T-001`, `T-002`, `T-003`, `T-004` should follow `UT-AUTH-001`, `API-PROD-001` pattern

### Existing Test Inventory

**Summary:** 15 tests across 6 files. 12 passing, 3 failing.

| Test File | Test Count | Tier | Status | Last Run |
|-----------|------------|------|--------|----------|
| `tests/unit/auth/auth.unit.spec.ts` | 3 | Unit | PASS | 2026-03-15 |
| `tests/unit/auth/tokenRefresh.unit.spec.ts` | 1 | Unit | FAIL | 2026-03-15 |
| `tests/unit/products/products.unit.spec.ts` | 2 | Unit | PASS | 2026-03-15 |
| `tests/unit/utils/validators.unit.spec.ts` | 3 | Unit | PASS | 2026-03-15 |
| `tests/api/products/products.api.spec.ts` | 2 | API | FAIL (1 of 2) | 2026-03-15 |
| `tests/api/auth/auth.api.spec.ts` | 3 | API | PASS | 2026-03-15 |
| `tests/e2e/auth/login.e2e.spec.ts` | 1 | E2E | FAIL | 2026-03-15 |

**Tier Breakdown:**
- Unit: 9 tests (60%)
- Integration: 0 tests (0%)
- API: 5 tests (33%)
- E2E: 1 test (7%)

### Recommendations

| # | Action | Impact | Effort | Priority |
|---|--------|--------|--------|----------|
| 1 | **Fix 3 broken tests** (stale selector, outdated assertion, missing env var) | Restores 3 tests to passing. Increases pass rate from 80% to 100%. All are quick fixes. | S | Do first |
| 2 | **Add missing P0 tests** (5 tests: order state machine, payment calc, Stripe charge, webhook, order creation) | Covers the 2 most critical uncovered modules (Orders, Payments). Adds 5 tests to the highest-risk areas. | M | Do second |
| 3 | **Migrate Tier 4 locators to Tier 1** (9 CSS selectors to data-testid) | Eliminates fragile selectors. Prevents future breakage from UI restyling. Requires coordination with testid-injector. | M | Do third |
| 4 | **Fix POM violations** (remove assertions from LoginPage.ts and ProductPage.ts, add BasePage extension) | Brings POM compliance from 50% to 100%. Improves maintainability and follows standards. | S | Do fourth |
| 5 | **Add missing P1 tests** (3 tests: product search, inventory integration, order status API) | Fills secondary coverage gaps. Adds integration test coverage (currently 0%). | M | Do fifth |
| 6 | **Address naming convention issues** (rename 2 files, fix 4 test IDs) | Brings naming compliance from 65% to 100%. Improves discoverability and consistency. | S | Do sixth |

---

## Guidelines

**DO:**
- Be specific about WHICH modules have no coverage -- list them by name, not just "coverage is low"
- Show the coverage map as a clear matrix so gaps are visually obvious (look for `NONE` entries)
- Include specific file paths and line numbers for every broken test finding
- Provide concrete test IDs and targets for missing tests so the executor can implement them directly
- Count tests accurately -- run the test suite and verify counts match
- Distinguish between "no tests exist" (missing) and "tests exist but fail" (broken)

**DON'T:**
- Recommend rewriting working tests just for style issues -- fix locators and naming in place
- Mark all missing tests as P0 -- prioritize genuinely based on business risk (payment > search > alerts)
- Combine missing and broken tests into one section -- they require different actions (write new vs fix existing)
- Ignore the quality dimensions -- a test that passes with vague assertions still has a quality problem
- Skip the existing test inventory -- establishing the baseline is critical context for improvements
- Assume a module is covered because one test exists -- check the recommended pyramid distribution

---

## Quality Gate

Before delivering this artifact, verify:

- [ ] Coverage Map includes ALL modules identified in the codebase (not just covered ones)
- [ ] Every module with `NONE` coverage at any tier has corresponding entries in Missing Tests
- [ ] Missing Tests are grouped by priority with P0 first, and each has a complete test spec (ID, target, tier, effort)
- [ ] Broken Tests include specific error messages, root cause analysis, and fix effort estimates
- [ ] Quality Assessment covers all 4 dimensions: locator tiers, assertion quality, POM compliance, naming convention
- [ ] Existing Test Inventory matches the actual test file count and status from running the suite
- [ ] Recommendations are ordered by ROI (fix broken first, then P0 gaps, then quality improvements)
- [ ] No recommendation suggests rewriting working tests -- only additive or fixative changes

---

*Template version: 1.0*
*Producer: qa-analyzer*
*Last updated: {date}*
