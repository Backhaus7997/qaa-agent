---
template_name: test-inventory
version: "1.0"
artifact_type: inventory
produces: TEST_INVENTORY.md
producer_agent: qa-analyzer
consumer_agents:
  - qa-planner
  - qa-executor
required_sections:
  - summary
  - unit-tests
  - integration-tests
  - api-tests
  - e2e-smoke-tests
example_domain: shopflow
---

# TEST_INVENTORY.md Template

**Purpose:** Complete, pyramid-based test case inventory with every test specified to the level of detail needed for automated generation. Every test case has a unique ID, specific target, concrete inputs, and an explicit expected outcome. This inventory is the single source of truth for what tests will be generated.

**Producer:** `qa-analyzer` agent
**Consumers:** `qa-planner` (reads inventory to create generation plan with task breakdown and file assignments), `qa-executor` (reads individual test cases to write actual test code)

**Input required:** `QA_ANALYSIS.md` must exist before this artifact is produced. The analyzer uses the top 10 unit targets, API targets, risk assessment, and testing pyramid from the analysis to populate this inventory.

---

## Required Sections

### Section 1: Summary

**Description:** High-level overview of the complete test inventory. Provides counts and distributions that downstream agents use to estimate effort and validate completeness.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| total_tests | number | YES | Total number of test cases across all tiers |
| unit_count | number | YES | Number of unit tests |
| unit_percent | number | YES | Percentage of total (target: 60-70%) |
| integration_count | number | YES | Number of integration tests |
| integration_percent | number | YES | Percentage of total (target: 10-15%) |
| api_count | number | YES | Number of API tests |
| api_percent | number | YES | Percentage of total (target: 20-25%) |
| e2e_count | number | YES | Number of E2E smoke tests |
| e2e_percent | number | YES | Percentage of total (target: 3-5%) |
| p0_count | number | YES | Number of P0 (blocks release) tests |
| p1_count | number | YES | Number of P1 (should fix) tests |
| p2_count | number | YES | Number of P2 (nice to have) tests |
| coverage_narrative | string | YES | 2-3 sentence assessment of what this inventory covers and any known gaps |

---

### Section 2: Unit Tests (60-70%)

**Description:** Tests for individual functions, methods, and modules in isolation. Each test case targets a specific function with concrete inputs and an explicit expected outcome. This is the largest tier and covers all business logic, validation, and utility functions.

**Per test case -- ALL fields are MANDATORY:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| test_id | string | YES | Format: `UT-MODULE-NNN` (e.g., `UT-PRICE-001`) |
| target | string | YES | Format: `file_path:function_name` (e.g., `src/utils/priceCalculator.ts:calculateOrderTotal`) |
| what_to_validate | string | YES | One-sentence description of the behavior being tested |
| concrete_inputs | string | YES | Actual values to pass -- NOT "valid data" or "correct input" |
| mocks_needed | string | YES | List of dependencies to mock, or "None (pure function)" |
| expected_outcome | string | YES | Exact return value, exact error message, or exact state change |
| priority | enum | YES | `P0` (blocks release), `P1` (should fix), `P2` (nice to have) |

**CRITICAL ANTI-PATTERN:**

> "Returns correct value" is **NOT** an expected outcome.
> "Returns 239.47" **IS** an expected outcome.
>
> "Handles error correctly" is **NOT** an expected outcome.
> "Throws InvalidTransitionError with message 'Cannot transition from delivered to pending'" **IS** an expected outcome.
>
> Every expected outcome must contain a **concrete value, specific error, or measurable state change**.

---

### Section 3: Integration/Contract Tests (10-15%)

**Description:** Tests verifying that two or more modules interact correctly. These test the contracts between components -- not internal logic (that's unit tests) and not HTTP contracts (that's API tests). Focus on database interactions, service-to-service calls, and cross-module state flows.

**Per test case -- ALL fields are MANDATORY:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| test_id | string | YES | Format: `INT-MODULE-NNN` (e.g., `INT-ORDER-001`) |
| components_involved | string | YES | Which modules interact (e.g., "orderService + inventoryService + Prisma") |
| what_to_validate | string | YES | The interaction contract being tested |
| setup_required | string | YES | Database state, mock services, or seed data needed before the test |
| expected_outcome | string | YES | Specific behavior when components interact correctly |
| priority | enum | YES | `P0`, `P1`, or `P2` |

---

### Section 4: API Tests (20-25%)

**Description:** HTTP-level tests verifying request/response contracts for each endpoint. These ensure the API surface area behaves as documented -- correct status codes, response shapes, error formats, and auth enforcement.

**Per test case -- ALL fields are MANDATORY:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| test_id | string | YES | Format: `API-RESOURCE-NNN` (e.g., `API-AUTH-001`) |
| method_endpoint | string | YES | HTTP method + path (e.g., `POST /api/v1/auth/login`) |
| request_body | string | YES | Exact JSON payload or "N/A" for GET requests |
| headers | string | YES | Required headers (e.g., `Authorization: Bearer {token}`) or "None" |
| expected_status | number | YES | Exact HTTP status code (200, 201, 400, 401, 404, etc.) |
| expected_response | string | YES | Key fields in response body with types or exact values |
| priority | enum | YES | `P0`, `P1`, or `P2` |

---

### Section 5: E2E Smoke Tests (3-5%)

**Description:** End-to-end tests covering the most critical user journeys. These are the minimum set of tests that MUST pass before any release. Maximum 3-8 tests -- each one a multi-step user flow that exercises the full stack.

**Per test case -- ALL fields are MANDATORY:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| test_id | string | YES | Format: `E2E-FLOW-NNN` (e.g., `E2E-FLOW-001`) |
| user_journey | string | YES | Step-by-step description of what the user does |
| pages_involved | string | YES | List of views/routes the user navigates through |
| expected_outcome | string | YES | Final state the user observes after completing the journey |
| priority | enum | YES | Always `P0` -- E2E tests are release-blocking by definition |

---

## Worked Example (ShopFlow E-Commerce API)

> The following is a complete, filled TEST_INVENTORY.md for the ShopFlow e-commerce application. This example demonstrates the expected depth, specificity, and concrete values required in every test case.

### Summary

| Metric | Value |
|--------|-------|
| **Total Tests** | 45 |
| **Unit Tests** | 28 (62%) |
| **Integration Tests** | 7 (16%) |
| **API Tests** | 8 (18%) |
| **E2E Smoke Tests** | 2 (4%) |
| **P0 (blocks release)** | 15 |
| **P1 (should fix)** | 20 |
| **P2 (nice to have)** | 10 |

**Coverage narrative:** This inventory covers all business-critical logic (price calculation, order state machine, payment processing, authentication), the complete API contract surface, key integration points (order-to-inventory, payment-to-order), and the two most critical user journeys (purchase flow and registration). Known gap: admin-only endpoints (product CRUD) are covered at P1 level only -- no E2E test for admin flows since admin UI is out of current scope.

---

### Unit Tests (28 tests -- 62%)

#### Price Calculation Module

##### UT-PRICE-001: Calculate Order Total with Multiple Items
- **Target:** `src/utils/priceCalculator.ts:calculateOrderTotal`
- **What to validate:** Correctly sums line items with quantity multiplication
- **Concrete inputs:** `[{sku: 'WIDGET-001', qty: 3, unitPrice: 29.99}, {sku: 'GADGET-002', qty: 1, unitPrice: 149.50}]`
- **Mocks needed:** None (pure function)
- **Expected outcome:** Returns `239.47` (29.99 * 3 + 149.50)
- **Priority:** P0

##### UT-PRICE-002: Apply Percentage Discount
- **Target:** `src/utils/priceCalculator.ts:applyDiscount`
- **What to validate:** Applies percentage discount correctly and rounds to 2 decimal places
- **Concrete inputs:** `{subtotal: 239.47, discountCode: 'SAVE10', discountPercent: 10}`
- **Mocks needed:** None (pure function)
- **Expected outcome:** Returns `215.52` (239.47 * 0.90, rounded to 2 decimals)
- **Priority:** P1

##### UT-PRICE-003: Calculate Tax
- **Target:** `src/utils/priceCalculator.ts:calculateTax`
- **What to validate:** Applies state tax rate correctly
- **Concrete inputs:** `{subtotal: 215.52, state: 'CA', taxRate: 0.0875}`
- **Mocks needed:** None (pure function)
- **Expected outcome:** Returns `18.86` (215.52 * 0.0875, rounded to 2 decimals)
- **Priority:** P1

##### UT-PRICE-004: Calculate Shipping by Weight
- **Target:** `src/utils/priceCalculator.ts:calculateShipping`
- **What to validate:** Returns correct shipping cost based on weight tiers
- **Concrete inputs:** `{totalWeight: 4.5, shippingMethod: 'standard'}`
- **Mocks needed:** None (pure function)
- **Expected outcome:** Returns `8.99` (standard rate for 2-5 kg tier)
- **Priority:** P2

##### UT-PRICE-005: Calculate Order Total with Zero Items
- **Target:** `src/utils/priceCalculator.ts:calculateOrderTotal`
- **What to validate:** Returns 0 for empty cart
- **Concrete inputs:** `[]`
- **Mocks needed:** None (pure function)
- **Expected outcome:** Returns `0.00`
- **Priority:** P1

#### Authentication Module

##### UT-AUTH-001: Hash Password with bcrypt
- **Target:** `src/services/authService.ts:hashPassword`
- **What to validate:** Produces a bcrypt hash that validates against the original password
- **Concrete inputs:** `'SecureP@ss123!'`
- **Mocks needed:** None
- **Expected outcome:** `bcrypt.compare('SecureP@ss123!', result)` returns `true`; result starts with `$2b$`
- **Priority:** P0

##### UT-AUTH-002: Verify Password -- Correct Password
- **Target:** `src/services/authService.ts:verifyPassword`
- **What to validate:** Returns true for correct password against stored hash
- **Concrete inputs:** `{password: 'SecureP@ss123!', hash: '$2b$10$...' (pre-computed valid hash)}`
- **Mocks needed:** None
- **Expected outcome:** Returns `true`
- **Priority:** P0

##### UT-AUTH-003: Verify Password -- Wrong Password
- **Target:** `src/services/authService.ts:verifyPassword`
- **What to validate:** Returns false for incorrect password
- **Concrete inputs:** `{password: 'WrongPassword!', hash: '$2b$10$...' (hash of 'SecureP@ss123!')}`
- **Mocks needed:** None
- **Expected outcome:** Returns `false`
- **Priority:** P0

##### UT-AUTH-004: Generate JWT Token with Correct Claims
- **Target:** `src/services/authService.ts:generateToken`
- **What to validate:** Generates a JWT with correct user ID, email, and expiration
- **Concrete inputs:** `{userId: 'usr_abc123', email: 'test@shopflow.com', role: 'customer'}`
- **Mocks needed:** Mock `jwt.sign` to capture payload
- **Expected outcome:** Token payload contains `{sub: 'usr_abc123', email: 'test@shopflow.com', role: 'customer', exp: <now + 15min>}`
- **Priority:** P0

##### UT-AUTH-005: Reject Expired Token
- **Target:** `src/services/authService.ts:verifyToken`
- **What to validate:** Throws error when token has expired
- **Concrete inputs:** JWT token with `exp` set to 1 hour ago
- **Mocks needed:** None (use real jwt.verify with expired token)
- **Expected outcome:** Throws `TokenExpiredError` with message "jwt expired"
- **Priority:** P0

#### Order Management Module

##### UT-ORDER-001: Transition Order Status -- Valid Transition (pending -> confirmed)
- **Target:** `src/services/orderService.ts:transitionOrderStatus`
- **What to validate:** Accepts valid state transition and returns new status
- **Concrete inputs:** `{orderId: 'ord_123', currentStatus: 'pending', newStatus: 'confirmed'}`
- **Mocks needed:** Mock Prisma `order.update` to return updated record
- **Expected outcome:** Returns `{orderId: 'ord_123', status: 'confirmed', updatedAt: <timestamp>}`
- **Priority:** P0

##### UT-ORDER-002: Transition Order Status -- Invalid Transition (delivered -> pending)
- **Target:** `src/services/orderService.ts:transitionOrderStatus`
- **What to validate:** Rejects invalid state transition with descriptive error
- **Concrete inputs:** `{orderId: 'ord_456', currentStatus: 'delivered', newStatus: 'pending'}`
- **Mocks needed:** Mock Prisma `order.findUnique` to return order with status 'delivered'
- **Expected outcome:** Throws `InvalidTransitionError` with message "Cannot transition from delivered to pending"
- **Priority:** P0

##### UT-ORDER-003: Transition Order Status -- Cancel from Pending
- **Target:** `src/services/orderService.ts:transitionOrderStatus`
- **What to validate:** Allows cancellation from pending status
- **Concrete inputs:** `{orderId: 'ord_789', currentStatus: 'pending', newStatus: 'cancelled'}`
- **Mocks needed:** Mock Prisma `order.update` to return updated record
- **Expected outcome:** Returns `{orderId: 'ord_789', status: 'cancelled', updatedAt: <timestamp>}`
- **Priority:** P0

##### UT-ORDER-004: Transition Order Status -- Cancel from Shipped (should fail)
- **Target:** `src/services/orderService.ts:transitionOrderStatus`
- **What to validate:** Rejects cancellation after shipment
- **Concrete inputs:** `{orderId: 'ord_012', currentStatus: 'shipped', newStatus: 'cancelled'}`
- **Mocks needed:** Mock Prisma `order.findUnique` to return order with status 'shipped'
- **Expected outcome:** Throws `InvalidTransitionError` with message "Cannot cancel an order that has been shipped"
- **Priority:** P1

#### Payment Module

##### UT-PAY-001: Charge Customer -- Success
- **Target:** `src/services/paymentService.ts:chargeCustomer`
- **What to validate:** Creates a Stripe charge and returns payment confirmation
- **Concrete inputs:** `{orderId: 'ord_123', amount: 25846, currency: 'usd', paymentMethodId: 'pm_test_visa'}`
- **Mocks needed:** Mock `stripe.paymentIntents.create` to return `{id: 'pi_abc', status: 'succeeded', amount: 25846}`
- **Expected outcome:** Returns `{paymentId: 'pi_abc', status: 'succeeded', amount: 258.46}`
- **Priority:** P0

##### UT-PAY-002: Charge Customer -- Card Declined
- **Target:** `src/services/paymentService.ts:chargeCustomer`
- **What to validate:** Handles Stripe card decline gracefully
- **Concrete inputs:** `{orderId: 'ord_456', amount: 15000, currency: 'usd', paymentMethodId: 'pm_test_declined'}`
- **Mocks needed:** Mock `stripe.paymentIntents.create` to throw `StripeCardError` with code 'card_declined'
- **Expected outcome:** Throws `PaymentFailedError` with message "Card was declined" and does NOT update order status
- **Priority:** P0

##### UT-PAY-003: Handle Webhook -- Valid Signature
- **Target:** `src/services/paymentService.ts:handleWebhook`
- **What to validate:** Processes webhook with valid Stripe signature
- **Concrete inputs:** `{rawBody: '{"type":"payment_intent.succeeded",...}', signature: 'valid_sig_hash'}`
- **Mocks needed:** Mock `stripe.webhooks.constructEvent` to return parsed event
- **Expected outcome:** Returns `{processed: true, eventType: 'payment_intent.succeeded'}`
- **Priority:** P0

##### UT-PAY-004: Handle Webhook -- Invalid Signature
- **Target:** `src/services/paymentService.ts:handleWebhook`
- **What to validate:** Rejects webhook with invalid or missing Stripe signature
- **Concrete inputs:** `{rawBody: '{"type":"payment_intent.succeeded",...}', signature: 'invalid_sig'}`
- **Mocks needed:** Mock `stripe.webhooks.constructEvent` to throw `SignatureVerificationError`
- **Expected outcome:** Throws `WebhookVerificationError` with message "Invalid webhook signature"
- **Priority:** P0

#### Inventory Module

##### UT-INV-001: Reserve Stock -- Sufficient Inventory
- **Target:** `src/services/inventoryService.ts:reserveStock`
- **What to validate:** Decrements available stock when sufficient inventory exists
- **Concrete inputs:** `{productId: 'prod_001', quantity: 3, currentStock: 10}`
- **Mocks needed:** Mock Prisma `product.update` to return updated stock
- **Expected outcome:** Returns `{productId: 'prod_001', reserved: 3, remainingStock: 7}`
- **Priority:** P0

##### UT-INV-002: Reserve Stock -- Insufficient Inventory
- **Target:** `src/services/inventoryService.ts:reserveStock`
- **What to validate:** Rejects reservation when insufficient stock
- **Concrete inputs:** `{productId: 'prod_002', quantity: 5, currentStock: 2}`
- **Mocks needed:** Mock Prisma `product.findUnique` to return product with stock 2
- **Expected outcome:** Throws `InsufficientStockError` with message "Only 2 units available for prod_002, requested 5"
- **Priority:** P0

##### UT-INV-003: Release Stock on Payment Failure
- **Target:** `src/services/inventoryService.ts:releaseStock`
- **What to validate:** Increments available stock when releasing a reservation
- **Concrete inputs:** `{productId: 'prod_001', quantity: 3, currentStock: 7}`
- **Mocks needed:** Mock Prisma `product.update` to return updated stock
- **Expected outcome:** Returns `{productId: 'prod_001', released: 3, availableStock: 10}`
- **Priority:** P1

#### Validation Module

##### UT-VAL-001: Validate Email -- Valid Format
- **Target:** `src/utils/validators.ts:validateEmail`
- **What to validate:** Accepts valid email format
- **Concrete inputs:** `'user@shopflow.com'`
- **Mocks needed:** None (pure function)
- **Expected outcome:** Returns `true`
- **Priority:** P1

##### UT-VAL-002: Validate Email -- Invalid Format
- **Target:** `src/utils/validators.ts:validateEmail`
- **What to validate:** Rejects invalid email format
- **Concrete inputs:** `'not-an-email'`
- **Mocks needed:** None (pure function)
- **Expected outcome:** Returns `false`
- **Priority:** P1

##### UT-VAL-003: Validate Password -- Meets Requirements
- **Target:** `src/utils/validators.ts:validatePassword`
- **What to validate:** Accepts password meeting minimum requirements (8+ chars, 1 uppercase, 1 number, 1 special)
- **Concrete inputs:** `'SecureP@ss123!'`
- **Mocks needed:** None (pure function)
- **Expected outcome:** Returns `{valid: true, errors: []}`
- **Priority:** P1

##### UT-VAL-004: Validate Password -- Too Short
- **Target:** `src/utils/validators.ts:validatePassword`
- **What to validate:** Rejects password under minimum length
- **Concrete inputs:** `'Ab1!'`
- **Mocks needed:** None (pure function)
- **Expected outcome:** Returns `{valid: false, errors: ['Password must be at least 8 characters']}`
- **Priority:** P1

#### Auth Middleware

##### UT-MID-001: Auth Middleware -- Valid Token
- **Target:** `src/middleware/authMiddleware.ts:verifyToken`
- **What to validate:** Attaches decoded user to request when valid token provided
- **Concrete inputs:** `{headers: {authorization: 'Bearer <valid-jwt>'}, decoded: {sub: 'usr_abc123', email: 'test@shopflow.com'}}`
- **Mocks needed:** Mock `jwt.verify` to return decoded payload
- **Expected outcome:** `req.user` is set to `{id: 'usr_abc123', email: 'test@shopflow.com'}`, `next()` is called
- **Priority:** P0

##### UT-MID-002: Auth Middleware -- Missing Token
- **Target:** `src/middleware/authMiddleware.ts:verifyToken`
- **What to validate:** Returns 401 when no Authorization header present
- **Concrete inputs:** `{headers: {}}`
- **Mocks needed:** None
- **Expected outcome:** Response status `401`, body `{error: 'Authentication required'}`
- **Priority:** P0

---

### Integration Tests (7 tests -- 16%)

##### INT-ORDER-001: Order Creation Reserves Inventory
- **Components involved:** orderService + inventoryService + Prisma (PostgreSQL)
- **What to validate:** Creating an order automatically reserves stock for each line item
- **Setup required:** Seed database with Product (id: 'prod_001', stock: 10) and authenticated User (id: 'usr_001')
- **Expected outcome:** After `orderService.createOrder({userId: 'usr_001', items: [{productId: 'prod_001', qty: 2}]})`, product stock is decremented to 8 in database, order status is 'pending'
- **Priority:** P0

##### INT-ORDER-002: Payment Success Updates Order Status
- **Components involved:** paymentService + orderService + Prisma (PostgreSQL)
- **What to validate:** Successful payment charge transitions order from pending to confirmed
- **Setup required:** Seed database with Order (id: 'ord_001', status: 'pending', total: 259.47). Mock Stripe to return successful charge.
- **Expected outcome:** After `paymentService.chargeCustomer({orderId: 'ord_001', ...})`, order status in database is 'confirmed', payment record exists with status 'succeeded'
- **Priority:** P0

##### INT-ORDER-003: Payment Failure Releases Inventory
- **Components involved:** paymentService + inventoryService + orderService + Prisma (PostgreSQL)
- **What to validate:** Failed payment releases reserved stock and keeps order in pending
- **Setup required:** Seed database with Order (id: 'ord_002', status: 'pending'), Product (id: 'prod_001', stock: 8, reserved: 2). Mock Stripe to throw card_declined.
- **Expected outcome:** After payment failure, product stock is restored to 10 in database, order status remains 'pending'
- **Priority:** P0

##### INT-ORDER-004: Webhook Updates Order After Async Payment
- **Components involved:** paymentController (webhook handler) + orderService + Prisma (PostgreSQL)
- **What to validate:** Stripe webhook event triggers order status update
- **Setup required:** Seed database with Order (id: 'ord_003', status: 'pending'). Construct valid webhook payload with Stripe test signing secret.
- **Expected outcome:** After webhook delivery with event type 'payment_intent.succeeded', order status in database is 'confirmed'
- **Priority:** P0

##### INT-AUTH-001: Auth Middleware Blocks Unauthorized Routes
- **Components involved:** authMiddleware + orderController + Express routing
- **What to validate:** Protected routes return 401 without valid JWT
- **Setup required:** Express app with routes mounted, no auth token in request
- **Expected outcome:** GET /api/v1/orders returns `401 {error: 'Authentication required'}`, POST /api/v1/orders returns `401 {error: 'Authentication required'}`
- **Priority:** P1

##### INT-AUTH-002: Refresh Token Rotation
- **Components involved:** authService + authController + Prisma (PostgreSQL)
- **What to validate:** Refreshing a token invalidates the old refresh token and issues a new pair
- **Setup required:** Seed database with User and valid refresh token record
- **Expected outcome:** After POST /api/v1/auth/refresh with old token, response contains new access token and new refresh token, old refresh token is marked invalid in database
- **Priority:** P1

##### INT-DB-001: Prisma Transaction Rollback on Error
- **Components involved:** orderService + Prisma (PostgreSQL) transaction
- **What to validate:** If any step in order creation fails, the entire transaction rolls back
- **Setup required:** Seed database with Product (stock: 1). Attempt to create order with qty: 2 (should fail on inventory check).
- **Expected outcome:** No order created in database, product stock unchanged at 1, `InsufficientStockError` thrown
- **Priority:** P1

---

### API Tests (8 tests -- 18%)

##### API-AUTH-001: Login with Valid Credentials
- **Method + Endpoint:** `POST /api/v1/auth/login`
- **Request body:** `{"email": "customer@shopflow.com", "password": "SecureP@ss123!"}`
- **Headers:** `Content-Type: application/json`
- **Expected status:** 200
- **Expected response:** `{token: string (JWT format), refreshToken: string (UUID format), user: {id: string, name: "Test Customer", email: "customer@shopflow.com"}}`
- **Priority:** P0

##### API-AUTH-002: Login with Invalid Password
- **Method + Endpoint:** `POST /api/v1/auth/login`
- **Request body:** `{"email": "customer@shopflow.com", "password": "WrongPassword"}`
- **Headers:** `Content-Type: application/json`
- **Expected status:** 401
- **Expected response:** `{error: "Invalid email or password"}`
- **Priority:** P0

##### API-AUTH-003: Register New User
- **Method + Endpoint:** `POST /api/v1/auth/register`
- **Request body:** `{"name": "New User", "email": "newuser@shopflow.com", "password": "SecureP@ss123!"}`
- **Headers:** `Content-Type: application/json`
- **Expected status:** 201
- **Expected response:** `{id: string (UUID), email: "newuser@shopflow.com", token: string (JWT format)}`
- **Priority:** P0

##### API-ORDER-001: Create Order with Valid Items
- **Method + Endpoint:** `POST /api/v1/orders`
- **Request body:** `{"items": [{"productId": "prod_001", "qty": 2}], "shippingAddress": {"street": "123 Main St", "city": "San Francisco", "state": "CA", "zip": "94102"}}`
- **Headers:** `Authorization: Bearer {valid_token}`, `Content-Type: application/json`
- **Expected status:** 201
- **Expected response:** `{orderId: string (UUID), status: "pending", total: number (> 0), items: [{productId: "prod_001", qty: 2, unitPrice: number}]}`
- **Priority:** P0

##### API-ORDER-002: Create Order Without Auth Token
- **Method + Endpoint:** `POST /api/v1/orders`
- **Request body:** `{"items": [{"productId": "prod_001", "qty": 1}], "shippingAddress": {...}}`
- **Headers:** None (no Authorization header)
- **Expected status:** 401
- **Expected response:** `{error: "Authentication required"}`
- **Priority:** P0

##### API-ORDER-003: Update Order Status
- **Method + Endpoint:** `PATCH /api/v1/orders/ord_001/status`
- **Request body:** `{"status": "confirmed"}`
- **Headers:** `Authorization: Bearer {valid_token}`, `Content-Type: application/json`
- **Expected status:** 200
- **Expected response:** `{orderId: "ord_001", status: "confirmed", updatedAt: string (ISO date)}`
- **Priority:** P0

##### API-PAY-001: Charge Payment for Order
- **Method + Endpoint:** `POST /api/v1/payments/charge`
- **Request body:** `{"orderId": "ord_001", "paymentMethodId": "pm_test_visa"}`
- **Headers:** `Authorization: Bearer {valid_token}`, `Content-Type: application/json`
- **Expected status:** 200
- **Expected response:** `{paymentId: string, status: "succeeded", amount: number (matches order total)}`
- **Priority:** P0

##### API-PROD-001: List Products with Pagination
- **Method + Endpoint:** `GET /api/v1/products?page=1&limit=10`
- **Request body:** N/A
- **Headers:** None (public endpoint)
- **Expected status:** 200
- **Expected response:** `{products: [{id: string, name: string, price: number, sku: string, category: string}], total: number, page: 1}`
- **Priority:** P1

---

### E2E Smoke Tests (2 tests -- 4%)

##### E2E-FLOW-001: Complete Purchase Flow
- **User journey:**
  1. User navigates to homepage (`/`)
  2. User clicks a product card to view product detail (`/products/:id`)
  3. User clicks "Add to Cart" button
  4. User navigates to cart page (`/cart`)
  5. User verifies item in cart with correct price and quantity
  6. User clicks "Checkout" button
  7. User fills checkout form (shipping address + payment card)
  8. User clicks "Place Order" button
  9. User sees order confirmation with order ID and "pending" status
- **Pages involved:** HomePage, ProductDetailPage, CartPage, CheckoutForm, OrderConfirmationPage
- **Expected outcome:** Order confirmation page displays with a valid order ID (UUID format), status shows "pending", order total matches the product price, and the user can navigate to order history (`/orders`) to see the new order listed
- **Priority:** P0

##### E2E-FLOW-002: User Registration to First Order
- **User journey:**
  1. User navigates to registration page (`/register`)
  2. User fills registration form (name: "E2E Test User", email: "e2e-test@shopflow.com", password: "SecureP@ss123!")
  3. User clicks "Create Account" button
  4. User is redirected to homepage, logged in (sees user name in navbar)
  5. User adds a product to cart
  6. User completes checkout flow
  7. User navigates to order history (`/orders`)
  8. User sees the new order with correct status
- **Pages involved:** RegisterPage, HomePage, ProductDetailPage, CartPage, CheckoutForm, OrderConfirmationPage, OrderHistoryPage
- **Expected outcome:** Order history page shows exactly 1 order with status "pending", the navbar displays "E2E Test User", and the user can log out and log back in successfully
- **Priority:** P0

---

## Guidelines

### DO

- **DO** use concrete values in every input and expected outcome field -- `239.47`, not "the correct total"
- **DO** include both happy-path and error cases for each module (at minimum 1 success + 1 failure per function)
- **DO** specify exact error types and messages in expected outcomes -- `Throws InvalidTransitionError` is better than `Throws an error`
- **DO** fill in the Mocks field for every test case -- "None (pure function)" is a valid and useful answer
- **DO** group unit tests by module with clear section headers
- **DO** ensure test IDs are unique across the entire inventory -- no duplicate `UT-PRICE-001` in different sections
- **DO** match test targets to the Top 10 Unit Test Targets from `QA_ANALYSIS.md`
- **DO** include the exact JSON payload for API test request bodies

### DON'T

- **DON'T** write "returns correct data" as an expected outcome -- specify the exact data
- **DON'T** write "handles error properly" -- specify what "properly" means (status code, error message, state change)
- **DON'T** skip the Mocks field -- downstream agents need to know what to mock
- **DON'T** use "valid data" or "correct input" as concrete inputs -- use actual values
- **DON'T** assign P2 to payment or authentication tests -- those are always P0
- **DON'T** include more than 8 E2E tests -- if you need more, some should be API or integration tests instead
- **DON'T** create test IDs that don't follow the naming convention (UT-MODULE-NNN, INT-MODULE-NNN, API-RESOURCE-NNN, E2E-FLOW-NNN)

---

## Quality Gate

Before delivering this artifact, verify all of the following:

- [ ] Every test case has a unique ID following the naming convention
- [ ] Every test case has an explicit expected outcome with a concrete value (not "works correctly")
- [ ] Every unit test has all 7 mandatory fields filled (ID, target, what to validate, inputs, mocks, outcome, priority)
- [ ] Every API test includes exact HTTP method, endpoint, request body, and expected status code
- [ ] Summary counts match the actual number of test cases in each section
- [ ] Summary percentages approximately match the testing pyramid (60-70% unit, 10-15% integration, 20-25% API, 3-5% E2E)
- [ ] Priority is assigned to every test case (P0, P1, or P2)
- [ ] No expected outcome contains vague words: "correct", "proper", "appropriate", "valid", or "works" without defining what those mean
- [ ] Test targets reference file paths and function names from `QA_ANALYSIS.md`
- [ ] Both happy-path and error cases are included for critical modules (auth, payments, orders)
