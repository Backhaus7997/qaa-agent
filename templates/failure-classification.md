---
template_name: failure-classification
version: "1.0"
artifact_type: classification
produces: FAILURE_CLASSIFICATION_REPORT.md
producer_agent: qa-bug-detective
consumer_agents:
  - human-reviewer
  - qa-validator
required_sections:
  - summary
  - detailed-analysis
  - auto-fix-log
  - recommendations
example_domain: shopflow
---

# FAILURE_CLASSIFICATION_REPORT.md Template

**Purpose:** Classifies every test failure into one of four actionable categories (APPLICATION BUG, TEST CODE ERROR, ENVIRONMENT ISSUE, INCONCLUSIVE) with evidence, confidence levels, and auto-fix results. Enables reviewers to immediately focus on real application bugs rather than wasting time investigating test infrastructure issues.

**Producer:** qa-bug-detective (runs generated tests and classifies every failure)
**Consumers:** human-reviewer (reviews application bugs and unresolved issues), qa-validator (consumes auto-fix results to update validation status)

---

## Classification Categories

| Category | Description | Auto-Fix Allowed | Action |
|----------|-------------|-----------------|--------|
| APPLICATION BUG | Error manifests in production code. Behavior contradicts requirements or API contracts. | NEVER | Report for human review. Include evidence from production code. |
| TEST CODE ERROR | Error in the test itself: wrong selector, missing await, incorrect assertion, bad import path. | YES (HIGH confidence only) | Auto-fix if HIGH confidence. Report if MEDIUM or lower. |
| ENVIRONMENT ISSUE | External dependency failure: database down, connection refused, missing env var, timeout. | NEVER | Report with suggested resolution steps. |
| INCONCLUSIVE | Cannot determine root cause. Ambiguous error, multiple possible causes, insufficient data. | NEVER | Report with what is known and what additional information would help classify. |

---

## Classification Decision Tree

```
Test fails
  |
  +-- Is the error a syntax/import error in the TEST file?
  |     YES --> TEST CODE ERROR
  |
  +-- Does the error occur in a PRODUCTION code path (src/, app/, lib/)?
  |     |
  |     +-- Is this a known bug or unexpected behavior per requirements?
  |     |     YES --> APPLICATION BUG
  |     |
  |     +-- Does the code work as designed, but the test expectation is wrong?
  |           YES --> TEST CODE ERROR
  |
  +-- Is it a connection refused, timeout, or missing env var?
  |     YES --> ENVIRONMENT ISSUE
  |
  +-- Cannot determine?
        --> INCONCLUSIVE
```

---

## Required Sections

### Section 1: Summary

**Description:** Aggregated counts by classification category showing the distribution of failures and what was auto-fixed.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Classification | enum | YES | APPLICATION BUG, TEST CODE ERROR, ENVIRONMENT ISSUE, or INCONCLUSIVE |
| Count | integer | YES | Number of failures in this category |
| Auto-Fixed | integer | YES | Number auto-fixed (only TEST CODE ERROR can be > 0) |
| Needs Attention | integer | YES | Count - Auto-Fixed = items requiring human review |

Additional summary fields:
- Total failures analyzed
- Total auto-fixed
- Total requiring human attention

---

### Section 2: Detailed Analysis

**Description:** Per-failure analysis with ALL mandatory fields. Every single failure must have a complete entry -- no fields may be omitted.

**Mandatory fields per failure:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Test Name | string | YES | The failing test case name with its ID (e.g., `E2E-CHECKOUT-001: Complete purchase flow`) |
| Classification | enum | YES | One of the 4 categories |
| Confidence | enum | YES | HIGH, MEDIUM-HIGH, MEDIUM, or LOW |
| File | path:line | YES | Exact file path and line number where the error occurs |
| Error Message | text | YES | Complete error text -- not a summary, the actual error |
| Evidence | code + text | YES | Code snippet showing the issue PLUS reasoning for why this classification was chosen over others |
| Action Taken | enum | YES | "Auto-fixed" or "Reported for human review" |
| Resolution | text | YES | If auto-fixed: what was changed. If reported: what the human needs to investigate and suggested approach. |

**Classification reasoning requirement:** Each failure must include a brief explanation of why THIS category was chosen and not another. Example: "Classified as APPLICATION BUG (not TEST CODE ERROR) because the stack trace originates in orderService.ts:47, not in the test file, and the behavior contradicts the order state machine spec."

---

### Section 3: Auto-Fix Log

**Description:** Record of every auto-fix applied, with the original error, fix details, and post-fix verification result. Only TEST CODE ERROR failures with HIGH confidence are eligible for auto-fix.

**Fields per fix:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Failure ID | string | YES | Reference to the failure in Detailed Analysis |
| Original Error | text | YES | The error before the fix |
| Fix Applied | text | YES | Exactly what was changed (before -> after) |
| Confidence at Fix | enum | YES | Must be HIGH |
| Verification Result | enum | YES | PASS (fix resolved the failure) or FAIL (fix did not resolve) |

If no auto-fixes were applied, state: **"No auto-fixes applied. No TEST CODE ERROR failures with HIGH confidence were found."**

---

### Section 4: Recommendations

**Description:** Actionable next steps grouped by classification category. Not generic advice -- specific to the failures found in this run.

**Structure:** One subsection per category that had failures:

- **APPLICATION BUG recommendations:** Which bugs to prioritize (by severity), suggested investigation steps, affected code paths
- **TEST CODE ERROR recommendations:** Patterns to improve across the test suite (e.g., "3 tests had missing await -- add ESLint rule for no-floating-promises"), preventive measures
- **ENVIRONMENT ISSUE recommendations:** Environment setup improvements, Docker/CI configuration changes
- **INCONCLUSIVE recommendations:** What additional information or debugging would help classify these failures

---

## Worked Example (ShopFlow E-Commerce API)

Below is a complete, filled FAILURE_CLASSIFICATION_REPORT.md for ShopFlow test execution results.

---

# Failure Classification Report

**Generated:** 2026-03-18T15:45:00Z
**Agent:** qa-bug-detective v1.0
**Test Run:** shopflow-qa-tests (42 tests executed, 5 failures)

## Summary

| Classification | Count | Auto-Fixed | Needs Attention |
|---------------|-------|-----------|----------------|
| APPLICATION BUG | 2 | 0 | 2 |
| TEST CODE ERROR | 2 | 2 | 0 |
| ENVIRONMENT ISSUE | 1 | 0 | 1 |
| INCONCLUSIVE | 0 | 0 | 0 |

- **Total failures analyzed:** 5
- **Total auto-fixed:** 2
- **Total requiring human attention:** 3

## Detailed Analysis

### Failure 1: API-ORDER-003 -- Order status transition allows invalid CANCELLED to SHIPPED

- **Classification:** APPLICATION BUG
- **Confidence:** HIGH
- **File:** `src/services/orderService.ts:47`
- **Error Message:**
  ```
  Error: expect(received).rejects.toThrow(InvalidTransitionError)

  Expected: InvalidTransitionError
  Received: undefined (no error thrown)

  Test: PATCH /api/v1/orders/ord_123/status with body { status: "SHIPPED" }
  Order current status: CANCELLED
  ```
- **Evidence:**
  ```typescript
  // src/services/orderService.ts:42-55
  async transitionStatus(orderId: string, newStatus: OrderStatus): Promise<Order> {
    const order = await this.prisma.order.findUniqueOrThrow({ where: { id: orderId } });
    // BUG: No guard clause checking valid transitions
    // The state machine should reject CANCELLED -> SHIPPED
    // Valid transitions from CANCELLED: none (terminal state)
    const updated = await this.prisma.order.update({
      where: { id: orderId },
      data: { status: newStatus, updatedAt: new Date() },
    });
    return updated;
  }
  ```
  **Reasoning:** Classified as APPLICATION BUG (not TEST CODE ERROR) because the stack trace originates in `orderService.ts`, not in the test file. The test correctly expects `InvalidTransitionError` per the order state machine specification (CANCELLED is a terminal state), but the production code lacks the guard clause to enforce it.
- **Action Taken:** Reported for human review
- **Resolution:** Add a state transition validation map to `orderService.transitionStatus()`. Suggested approach: create a `VALID_TRANSITIONS` const map defining allowed `fromStatus -> toStatus[]` pairs, and throw `InvalidTransitionError` if the requested transition is not in the map.

### Failure 2: API-PAY-002 -- Payment webhook handler missing Stripe signature verification

- **Classification:** APPLICATION BUG
- **Confidence:** MEDIUM-HIGH
- **File:** `src/controllers/paymentController.ts:89`
- **Error Message:**
  ```
  Error: expect(received).toBe(expected)

  Expected: 401
  Received: 200

  Test: POST /api/v1/payments/webhook with invalid Stripe signature header
  ```
- **Evidence:**
  ```typescript
  // src/controllers/paymentController.ts:85-98
  async handleWebhook(req: Request, res: Response): Promise<void> {
    // BUG: No signature verification
    // Should call stripe.webhooks.constructEvent(req.body, sig, webhookSecret)
    // Without this, anyone can send fake webhook events
    const event = req.body;
    await this.processWebhookEvent(event);
    res.status(200).json({ received: true });
  }
  ```
  **Reasoning:** Classified as APPLICATION BUG (not TEST CODE ERROR) because the test sends a request with an intentionally invalid Stripe signature header and correctly expects a 401 rejection. The production code at `paymentController.ts:89` processes the webhook without calling `stripe.webhooks.constructEvent()`, accepting any payload. Confidence is MEDIUM-HIGH rather than HIGH because the webhook endpoint might be in a development/test mode where signature verification is intentionally skipped -- this should be confirmed.
- **Action Taken:** Reported for human review
- **Resolution:** Add Stripe webhook signature verification using `stripe.webhooks.constructEvent(req.body, req.headers['stripe-signature'], process.env.STRIPE_WEBHOOK_SECRET)`. Wrap in try/catch returning 401 on `StripeSignatureVerificationError`. This is a security-critical fix -- prioritize above the order state machine bug.

### Failure 3: E2E-LOGIN-001 -- Login form submit button selector mismatch

- **Classification:** TEST CODE ERROR
- **Confidence:** HIGH
- **File:** `tests/e2e/smoke/login.e2e.spec.ts:23`
- **Error Message:**
  ```
  Error: locator.click: Error: strict mode violation: locator('.submit-btn') resolved to 0 elements

  Waiting for locator('.submit-btn')
  ```
- **Evidence:**
  ```typescript
  // tests/e2e/smoke/login.e2e.spec.ts:23 (BEFORE fix)
  await page.locator('.submit-btn').click();

  // Actual DOM shows the button has data-testid:
  // <button type="submit" data-testid="login-submit-btn" class="btn-primary">Log in</button>

  // Fix: use Tier 1 selector (data-testid) instead of Tier 4 (CSS class)
  await page.getByTestId('login-submit-btn').click();
  ```
  **Reasoning:** Classified as TEST CODE ERROR (not APPLICATION BUG) because the login button exists and functions correctly in the DOM. The test used a CSS class selector (`.submit-btn`) that does not match the actual class (`btn-primary`). The element has a `data-testid` attribute available.
- **Action Taken:** Auto-fixed
- **Resolution:** Updated selector from `.submit-btn` (Tier 4 CSS, wrong class) to `getByTestId('login-submit-btn')` (Tier 1 test ID). The button has `data-testid="login-submit-btn"` in the DOM.

### Failure 4: E2E-CHECKOUT-002 -- Missing await on page.click in checkout flow

- **Classification:** TEST CODE ERROR
- **Confidence:** HIGH
- **File:** `tests/e2e/smoke/checkout.e2e.spec.ts:45`
- **Error Message:**
  ```
  Error: page.getByTestId('order-confirm-heading').toBeVisible: Timeout 5000ms exceeded.

  Waiting for getByTestId('order-confirm-heading') to be visible
  Note: Previous action page.click('[data-testid="checkout-submit-btn"]') may not have completed
  ```
- **Evidence:**
  ```typescript
  // tests/e2e/smoke/checkout.e2e.spec.ts:44-47 (BEFORE fix)
  page.click('[data-testid="checkout-submit-btn"]');  // Missing await
  await expect(page.getByTestId('order-confirm-heading')).toBeVisible();

  // Fix: Add await to the click action
  await page.click('[data-testid="checkout-submit-btn"]');
  await expect(page.getByTestId('order-confirm-heading')).toBeVisible();
  ```
  **Reasoning:** Classified as TEST CODE ERROR (not APPLICATION BUG) because the checkout submit button works correctly. The test failed because `page.click()` was called without `await`, so the assertion ran before the click completed and the confirmation page loaded. The Playwright error message hints at this with "Previous action may not have completed."
- **Action Taken:** Auto-fixed
- **Resolution:** Added `await` keyword before `page.click('[data-testid="checkout-submit-btn"]')` at line 45. The click must complete before asserting the next page's heading visibility.

### Failure 5: API-ORDER-001 -- Database connection timeout

- **Classification:** ENVIRONMENT ISSUE
- **Confidence:** HIGH
- **File:** `tests/api/orders.api.spec.ts:12`
- **Error Message:**
  ```
  Error: connect ECONNREFUSED 127.0.0.1:5432

  PrismaClientInitializationError: Can't reach database server at `localhost:5432`
  Please make sure your database server is running at `localhost:5432`.
  ```
- **Evidence:**
  ```
  The error occurs before any test logic executes -- during the global setup phase when
  Prisma attempts to connect to PostgreSQL. The error is ECONNREFUSED, indicating the
  database server is not running, not that the credentials are wrong (which would show
  EAUTH or similar).

  Environment check:
  - DATABASE_URL in .env: postgresql://test:test@localhost:5432/shopflow_test
  - PostgreSQL process: NOT RUNNING
  ```
  **Reasoning:** Classified as ENVIRONMENT ISSUE (not APPLICATION BUG) because the error is a TCP connection refusal to the database port, occurring before any application code executes. The database server is simply not running in the test environment.
- **Action Taken:** Reported for human review
- **Resolution:** Start PostgreSQL before running tests. Options: (1) Run `docker compose up -d postgres` if Docker Compose is configured, (2) Start the local PostgreSQL service: `sudo systemctl start postgresql`, (3) For CI: add a PostgreSQL service container to the GitHub Actions workflow.

## Auto-Fix Log

| Failure ID | Original Error | Fix Applied | Confidence | Verification |
|-----------|---------------|------------|------------|-------------|
| Failure 3 (E2E-LOGIN-001) | `locator('.submit-btn')` resolved to 0 elements | Changed `page.locator('.submit-btn').click()` to `page.getByTestId('login-submit-btn').click()` | HIGH | PASS -- login test completes successfully with updated selector |
| Failure 4 (E2E-CHECKOUT-002) | Timeout waiting for order-confirm-heading after unresolved click | Added `await` before `page.click('[data-testid="checkout-submit-btn"]')` | HIGH | PASS -- checkout test completes, confirmation heading visible after awaited click |

## Recommendations

### APPLICATION BUG (Priority Order)

1. **[CRITICAL] Add Stripe webhook signature verification** (`paymentController.ts:89`)
   - Security vulnerability: any HTTP client can trigger fake webhook events
   - Fix: Add `stripe.webhooks.constructEvent()` call with signature validation
   - Priority: Fix before next deployment -- this is a security hole

2. **[HIGH] Add order state machine guard clause** (`orderService.ts:47`)
   - Data integrity issue: orders can transition to invalid states (CANCELLED -> SHIPPED)
   - Fix: Create `VALID_TRANSITIONS` map and validate before updating
   - Priority: Fix in next sprint -- causes incorrect order states in production

### TEST CODE ERROR (Preventive Measures)

1. **Add ESLint rule `no-floating-promises`** to catch missing `await` keywords
   - 1 of 2 test code errors was a missing `await` -- this is a common async/await mistake
   - Add `@typescript-eslint/no-floating-promises: "error"` to `.eslintrc`
   - This would have caught Failure 4 at lint time

2. **Enforce Tier 1 locator usage** in code review and linting
   - 1 of 2 test code errors used a CSS class selector instead of `data-testid`
   - Consider an ESLint plugin or custom rule to warn on `page.locator('.')` patterns
   - Prefer `getByTestId()` and `getByRole()` per locator hierarchy standards

### ENVIRONMENT ISSUE (Infrastructure)

1. **Add Docker Compose for test database**
   - Create `docker-compose.test.yml` with PostgreSQL service
   - Add `pretest` script: `docker compose -f docker-compose.test.yml up -d`
   - Ensures database is always available before test execution

2. **Add PostgreSQL service to GitHub Actions**
   ```yaml
   services:
     postgres:
       image: postgres:15
       env:
         POSTGRES_USER: test
         POSTGRES_PASSWORD: test
         POSTGRES_DB: shopflow_test
       ports:
         - 5432:5432
   ```

---

## Guidelines

**DO:**
- Include the complete error message in every failure entry -- not a summary, the actual error output
- Show the code snippet that proves the classification -- reviewers need to see the evidence
- Include classification reasoning explaining why THIS category and not another
- Verify auto-fixes by re-running the test before marking the fix as PASS
- Group recommendations by category and prioritize within each group

**DON'T:**
- Auto-fix anything classified as APPLICATION BUG -- report only, never modify production code
- Auto-fix with confidence below HIGH -- report for human review instead
- Classify an error as INCONCLUSIVE without explaining what information is missing and what steps would help classify it
- Omit the file:line reference -- every failure must point to the exact location
- Combine multiple failures into a single entry -- each failure gets its own Detailed Analysis subsection

---

## Quality Gate

Before delivering a FAILURE_CLASSIFICATION_REPORT.md, verify:

- [ ] All 4 required sections are present (Summary, Detailed Analysis, Auto-Fix Log, Recommendations)
- [ ] Summary table includes all 4 categories (APPLICATION BUG, TEST CODE ERROR, ENVIRONMENT ISSUE, INCONCLUSIVE) even if count is 0
- [ ] Every failure has ALL mandatory fields: test name, classification, confidence, file:line, error message, evidence, action taken, resolution
- [ ] Every failure includes classification reasoning (why this category and not another)
- [ ] No APPLICATION BUG was auto-fixed (only TEST CODE ERROR with HIGH confidence)
- [ ] Auto-Fix Log entries include verification result (PASS/FAIL after fix)
- [ ] Recommendations are grouped by category and specific to the failures found (not generic advice)
- [ ] INCONCLUSIVE entries (if any) explain what information is missing
