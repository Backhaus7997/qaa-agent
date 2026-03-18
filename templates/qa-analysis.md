---
template_name: qa-analysis
version: "1.0"
artifact_type: analysis
produces: QA_ANALYSIS.md
producer_agent: qa-analyzer
consumer_agents:
  - qa-planner
  - qa-executor
required_sections:
  - architecture-overview
  - external-dependencies
  - risk-assessment
  - top-10-unit-targets
  - api-contract-targets
  - recommended-testing-pyramid
example_domain: shopflow
---

# QA_ANALYSIS.md Template

**Purpose:** Comprehensive testability report for a codebase. Provides downstream agents with a complete understanding of the application architecture, risk areas, priority test targets, and recommended testing strategy. This is the primary analysis artifact that drives all test planning and generation decisions.

**Producer:** `qa-analyzer` agent
**Consumers:** `qa-planner` (reads targets and pyramid to create generation plan), `qa-executor` (reads architecture and risks to write informed tests)

**Input required:** `SCAN_MANIFEST.md` must exist before this artifact is produced. The analyzer reads the file list, testable surfaces, and project detection data from the scan manifest.

---

## Required Sections

### Section 1: Architecture Overview

**Description:** System-level summary of the application under analysis. Provides the foundational context that all other sections reference. Must be specific to the actual codebase -- never generic.

#### Properties Table

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| system_type | string | YES | Application category (e.g., REST API, monolith, microservice, SPA, full-stack) |
| language | string | YES | Primary language and version |
| runtime | string | YES | Runtime environment and version |
| framework | string | YES | Primary framework and version |
| database | string | YES | Database technology and access layer (e.g., PostgreSQL 15 via Prisma 5.7) |
| authentication | string | YES | Auth mechanism (e.g., JWT, session-based, OAuth2, API key) |
| integrations | string | NO | External service integrations (e.g., Stripe, SendGrid, S3) |
| deployment | string | NO | Deployment target (e.g., Docker + AWS ECS, Vercel, Railway) |

#### Entry Points Table

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| route_file | string | YES | Path to the route definition file |
| base_path | string | YES | URL prefix for this route group |
| methods | string | YES | HTTP methods and endpoint names handled |
| auth_required | string | YES | Which endpoints require authentication |

#### Internal Layers

**Description:** Directory structure showing the application's layered architecture. Each directory listed with its purpose and relationship to other layers. Show the data flow direction (routes -> controllers -> services -> models).

---

### Section 2: External Dependencies

**Description:** Third-party libraries and services that the application depends on, each assessed for testing risk. HIGH-risk dependencies handle money, authentication, or critical data. MEDIUM-risk dependencies are important but failures are recoverable. LOW-risk dependencies are utilities.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| dependency | string | YES | Package or service name with version |
| purpose | string | YES | What the application uses it for |
| risk_level | enum | YES | `HIGH`, `MEDIUM`, or `LOW` |
| justification | string | YES | Why this risk level -- specific to how the app uses it |

**Risk classification rules:**
- **HIGH:** Handles payments, authentication, sensitive data encryption, critical business rules, or data persistence. Failure = data loss, security breach, or revenue impact.
- **MEDIUM:** Important functionality but recoverable. Email sending, file uploads, caching, logging. Failure = degraded experience but no data loss.
- **LOW:** Utility functions, formatting, development tooling. Failure = minor inconvenience.

---

### Section 3: Risk Assessment

**Description:** Prioritized list of specific risks identified in the codebase. Every risk MUST reference actual code, files, or patterns found during analysis. Generic risks without evidence are not acceptable.

**Fields per risk:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| risk_id | string | YES | Format: `RISK-NNN` (e.g., RISK-001) |
| area | string | YES | Module or feature area (e.g., "Payment Processing", "Order State Machine") |
| severity | enum | YES | `HIGH`, `MEDIUM`, or `LOW` |
| description | string | YES | What could go wrong, specifically |
| evidence | string | YES | Code file, function, or pattern that demonstrates this risk |
| testing_implication | string | YES | What tests are needed to mitigate this risk |

**Anti-pattern:** "SQL injection is possible" without pointing to a specific vulnerable query is NOT acceptable. Risks must cite specific files and patterns.

---

### Section 4: Top 10 Unit Test Targets

**Description:** The ten highest-priority modules or functions for unit testing, ranked by a composite score of business impact, code complexity, and change frequency. These targets drive the bulk of the test inventory.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| rank | number | YES | 1-10 priority ranking |
| module_path | string | YES | File path relative to project root |
| function_or_method | string | YES | Specific function or method name to test |
| why_high_priority | string | YES | Business justification for testing this target |
| complexity | string | YES | Assessment: lines of code, branch count, dependency count |
| suggested_test_count | number | YES | Estimated number of test cases needed |

**Ranking criteria:** business_impact (40%) x complexity (30%) x change_frequency (30%). Business impact means: what breaks if this function has a bug? Complexity means: how many code paths exist? Change frequency means: how often is this file modified?

---

### Section 5: API/Contract Test Targets

**Description:** HTTP endpoints that need contract testing to ensure request/response shapes are maintained. Grouped by resource. Each entry defines the expected request and response contract.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| endpoint | string | YES | HTTP method + path (e.g., `POST /api/v1/orders`) |
| request_contract | string | YES | Expected request params, body shape, and content type |
| response_contract | string | YES | Expected status code + response body shape (key fields and types) |
| auth_required | boolean | YES | Whether this endpoint requires authentication |
| test_priority | enum | YES | `P0` (blocks release), `P1` (should fix), `P2` (nice to have) |

**Grouping:** Organize endpoints by resource (e.g., Auth, Products, Orders, Payments). Within each group, list by HTTP method order: POST (create) -> GET (read) -> PUT/PATCH (update) -> DELETE (remove).

---

### Section 6: Recommended Testing Pyramid

**Description:** Testing strategy with percentage allocations tailored to THIS specific application's architecture. Must justify any deviation from the standard 65/15/15/5 distribution.

**Format:**

1. ASCII pyramid visualization with percentages
2. Table with tier, percentage, count, and rationale specific to this app
3. Justification paragraph explaining why these percentages were chosen

**Fields per tier:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| tier | string | YES | Unit, Integration, API, or E2E |
| percentage | number | YES | Percentage of total test count |
| test_count | number | YES | Estimated number of tests at this tier |
| rationale | string | YES | Why this percentage for THIS app (not generic) |

---

## Worked Example (ShopFlow E-Commerce API)

> The following is a complete, filled QA_ANALYSIS.md for the ShopFlow e-commerce application. This example demonstrates the expected depth, specificity, and quality level.

### Architecture Overview

| Property | Value |
|----------|-------|
| System Type | REST API with React SPA (monolith) |
| Language | TypeScript 5.3 |
| Runtime | Node.js 20 LTS |
| Framework | Express 4.18 (backend), React 18.2 (frontend) |
| Database | PostgreSQL 15 via Prisma 5.7 ORM |
| Authentication | JWT (jsonwebtoken 9.x + bcrypt 5.x) |
| Integrations | Stripe SDK 14.x (payments), Resend (transactional email) |
| Deployment | Docker + AWS ECS (production), Docker Compose (local dev) |

#### Entry Points

| Route File | Base Path | Methods | Auth Required |
|------------|-----------|---------|---------------|
| src/routes/api/v1/auth.ts | /api/v1/auth | POST register, POST login, POST refresh, POST logout | No (register, login), Yes (refresh, logout) |
| src/routes/api/v1/products.ts | /api/v1/products | GET list, GET :id, POST create, PUT :id, DELETE :id | No (GET), Yes (POST, PUT, DELETE) |
| src/routes/api/v1/orders.ts | /api/v1/orders | GET list, GET :id, POST create, PATCH :id/status | Yes (all) |
| src/routes/api/v1/payments.ts | /api/v1/payments | POST charge, POST refund, POST webhook | Yes (charge, refund), No (webhook) |

#### Internal Layers

```
src/
  routes/        -> HTTP routing, input validation, request parsing
  controllers/   -> Request/response handling, calls services, formats output
  services/      -> Business logic, state transitions, external API calls
  models/        -> Prisma schema definitions, custom model methods
  middleware/    -> Auth (JWT verify), rate limiting, error handler, CORS
  utils/         -> Price calculator, validators, date helpers, formatters
```

Data flow: `Routes -> Controllers -> Services -> Models (Prisma) -> PostgreSQL`

---

### External Dependencies

| Dependency | Purpose | Version | Risk Level | Justification |
|-----------|---------|---------|------------|---------------|
| express | HTTP server framework | 4.18.x | MEDIUM | Core routing -- well-tested library but misconfiguration possible |
| @prisma/client | Database ORM | 5.7.x | HIGH | All data persistence flows through Prisma -- query bugs = data corruption |
| stripe | Payment processing | 14.x | HIGH | Handles real money -- charge errors = revenue loss, webhook failures = order stuck |
| jsonwebtoken | JWT token signing/verification | 9.x | HIGH | Authentication barrier -- token bugs = unauthorized access |
| bcrypt | Password hashing | 5.x | HIGH | Password security -- weak hashing = credential exposure |
| zod | Input validation schemas | 3.22.x | MEDIUM | Request validation -- bypass = invalid data reaching services |
| resend | Transactional email | 2.x | LOW | Order confirmation emails -- failure = no email, order still processes |
| helmet | Security headers | 7.x | MEDIUM | HTTP security headers -- misconfiguration = XSS/clickjacking risk |
| cors | Cross-origin resource sharing | 2.x | MEDIUM | Frontend access -- misconfiguration = blocked requests or open access |
| winston | Structured logging | 3.x | LOW | Logging -- failure = no logs, app still works |

---

### Risk Assessment

#### RISK-001: Stripe Webhook Signature Verification
- **Area:** Payment Processing
- **Severity:** HIGH
- **Description:** Stripe webhooks deliver payment status updates (succeeded, failed, refunded). If webhook signature verification is bypassed or incorrectly implemented, an attacker could forge webhook events to mark unpaid orders as paid.
- **Evidence:** `src/controllers/paymentController.ts:handleWebhook` calls `stripe.webhooks.constructEvent()` -- must verify the raw body is passed (not parsed JSON) and the signing secret matches the environment variable.
- **Testing Implication:** Need integration tests that send webhooks with valid and invalid signatures, plus unit tests for the webhook handler logic with mocked Stripe responses.

#### RISK-002: Order State Machine Transition Logic
- **Area:** Order Management
- **Severity:** HIGH
- **Description:** Orders follow a state machine (pending -> confirmed -> shipped -> delivered, with cancel possible from pending/confirmed). Invalid transitions (e.g., delivered -> pending) could corrupt order history and trigger incorrect refunds.
- **Evidence:** `src/services/orderService.ts:transitionOrderStatus` contains a transition map -- every valid from/to pair must be explicitly tested, including boundary cases.
- **Testing Implication:** Unit tests for every valid transition, every invalid transition (expect error), and edge cases (cancelling a shipped order). Minimum 8-10 test cases for this function alone.

#### RISK-003: JWT Token Expiry and Refresh Race Condition
- **Area:** Authentication
- **Severity:** MEDIUM
- **Description:** If access tokens expire during a multi-step checkout flow, the refresh endpoint must issue new tokens without losing the user's cart state. Concurrent refresh requests from multiple tabs could invalidate tokens unexpectedly.
- **Evidence:** `src/services/authService.ts:refreshToken` reads the refresh token from the database -- concurrent calls could race on token rotation, leaving one tab with an invalidated token.
- **Testing Implication:** Unit tests for token generation and validation, integration tests for the refresh flow, and a concurrency test for simultaneous refresh requests.

#### RISK-004: Inventory Reservation Without Release on Payment Failure
- **Area:** Inventory Management
- **Severity:** HIGH
- **Description:** When a customer starts checkout, inventory is reserved. If payment fails, reserved stock must be released. A bug in the release path leads to phantom reservations that reduce available stock permanently.
- **Evidence:** `src/services/inventoryService.ts:reserveStock` decrements available count, but `releaseStock` is only called in the payment failure handler in `src/services/paymentService.ts:chargeCustomer` -- if chargeCustomer throws before reaching the release call, stock is permanently locked.
- **Testing Implication:** Integration tests for the full checkout-to-payment flow, specifically testing the failure path. Unit tests for reserveStock and releaseStock independently.

#### RISK-005: Price Calculation Floating-Point Precision
- **Area:** Pricing
- **Severity:** MEDIUM
- **Description:** JavaScript floating-point arithmetic can produce rounding errors in price calculations (e.g., 0.1 + 0.2 = 0.30000000000000004). If the price calculator does not round correctly, customers could be charged incorrect amounts.
- **Evidence:** `src/utils/priceCalculator.ts:calculateOrderTotal` multiplies quantity by unit price and sums -- without explicit rounding to 2 decimal places, accumulated errors across multiple line items could produce incorrect totals.
- **Testing Implication:** Unit tests with known inputs that trigger floating-point edge cases (e.g., quantities with prices like $19.99, $9.95). Verify outputs are rounded to exactly 2 decimal places.

#### RISK-006: Missing Rate Limiting on Auth Endpoints
- **Area:** Security
- **Severity:** MEDIUM
- **Description:** Login and registration endpoints without rate limiting are vulnerable to brute-force attacks and credential stuffing.
- **Evidence:** `src/middleware/rateLimiter.ts` exists but the limit configuration for auth endpoints needs verification -- the general limit (100 req/min) may be too permissive for login (should be 5-10 req/min).
- **Testing Implication:** Integration tests that verify rate limiting kicks in at the configured threshold for auth endpoints specifically.

---

### Top 10 Unit Test Targets

| Rank | Module Path | Function/Method | Why High-Priority | Complexity | Suggested Tests |
|------|------------|-----------------|-------------------|-----------|----------------|
| 1 | src/utils/priceCalculator.ts | calculateOrderTotal | Core revenue logic -- wrong totals = financial loss | 45 lines, 4 branches, 0 deps | 6 |
| 2 | src/utils/priceCalculator.ts | applyDiscount | Discount logic affects revenue -- percentage and fixed discounts | 30 lines, 3 branches, 0 deps | 5 |
| 3 | src/services/orderService.ts | transitionOrderStatus | State machine -- invalid transitions corrupt order history | 60 lines, 8 branches, 2 deps | 10 |
| 4 | src/services/authService.ts | hashPassword / verifyPassword | Security-critical -- weak hashing = credential exposure | 20 lines, 2 branches, 1 dep (bcrypt) | 4 |
| 5 | src/services/authService.ts | generateToken / refreshToken | Auth tokens -- wrong claims or expiry = security holes | 35 lines, 4 branches, 1 dep (jwt) | 6 |
| 6 | src/services/paymentService.ts | chargeCustomer | Stripe integration -- charge errors = lost revenue | 50 lines, 5 branches, 2 deps (stripe, orderService) | 7 |
| 7 | src/services/inventoryService.ts | reserveStock / releaseStock | Stock management -- reservation bugs = phantom inventory | 40 lines, 4 branches, 1 dep (prisma) | 6 |
| 8 | src/utils/validators.ts | validateEmail / validatePassword | Input validation -- bypasses = bad data in DB | 25 lines, 6 branches, 0 deps | 8 |
| 9 | src/services/orderService.ts | createOrder | Order creation orchestrates inventory + payment | 55 lines, 5 branches, 3 deps | 6 |
| 10 | src/middleware/authMiddleware.ts | verifyToken (middleware) | Auth gate -- bypass = unauthorized access to all protected routes | 30 lines, 4 branches, 1 dep (jwt) | 5 |

**Total suggested unit tests from top 10:** 63

---

### API/Contract Test Targets

#### Auth Resource

| Endpoint | Request Contract | Response Contract | Auth | Priority |
|----------|-----------------|-------------------|------|----------|
| POST /api/v1/auth/register | `{name: string, email: string, password: string}` | `201 {id: string, email: string, token: string}` | No | P0 |
| POST /api/v1/auth/login | `{email: string, password: string}` | `200 {token: string, refreshToken: string, user: {id, name, email}}` | No | P0 |
| POST /api/v1/auth/refresh | `{refreshToken: string}` | `200 {token: string, refreshToken: string}` | Yes | P1 |
| POST /api/v1/auth/logout | `{}` (token in Authorization header) | `200 {message: "Logged out"}` | Yes | P2 |

#### Products Resource

| Endpoint | Request Contract | Response Contract | Auth | Priority |
|----------|-----------------|-------------------|------|----------|
| GET /api/v1/products | `?page=1&limit=20&category=string` | `200 {products: [{id, name, price, sku, category, imageUrl}], total: number, page: number}` | No | P1 |
| GET /api/v1/products/:id | `params: {id: string}` | `200 {id, name, description, price, sku, category, imageUrl, stock}` or `404 {error: "Product not found"}` | No | P1 |
| POST /api/v1/products | `{name: string, description: string, price: number, sku: string, category: string, stock: number}` | `201 {id: string, name, price, sku, ...}` | Yes (admin) | P1 |

#### Orders Resource

| Endpoint | Request Contract | Response Contract | Auth | Priority |
|----------|-----------------|-------------------|------|----------|
| POST /api/v1/orders | `{items: [{productId: string, qty: number}], shippingAddress: {street, city, state, zip}}` | `201 {orderId: string, status: "pending", total: number, items: [...]}` | Yes | P0 |
| GET /api/v1/orders/:id | `params: {id: string}` | `200 {orderId, status, items, total, createdAt, updatedAt}` or `404` | Yes | P1 |
| PATCH /api/v1/orders/:id/status | `{status: "confirmed" \| "shipped" \| "delivered" \| "cancelled"}` | `200 {orderId, status: newStatus, updatedAt}` or `400 {error: "Invalid transition"}` | Yes | P0 |

#### Payments Resource

| Endpoint | Request Contract | Response Contract | Auth | Priority |
|----------|-----------------|-------------------|------|----------|
| POST /api/v1/payments/charge | `{orderId: string, paymentMethodId: string}` | `200 {paymentId: string, status: "succeeded", amount: number}` or `402 {error: "Payment failed"}` | Yes | P0 |
| POST /api/v1/payments/webhook | `Stripe-Signature header + raw body` | `200 {received: true}` or `400 {error: "Invalid signature"}` | No (Stripe signature) | P0 |

---

### Recommended Testing Pyramid

```
         /  E2E   \          5%    (2 tests)
        /   API    \        20%    (8 tests)
       / Integration\       10%    (4 tests)
      /    Unit      \      65%    (28 tests)
     /________________\
```

| Tier | Percentage | Count | Rationale |
|------|-----------|-------|-----------|
| Unit | 65% | 28 | Heavy business logic in services layer (price calculation, order state machine, auth) -- pure functions and isolated logic are ideal unit test targets |
| Integration | 10% | 4 | Key integration points: order-creation-to-inventory, payment-to-order-status, auth-middleware-to-routes, webhook-to-order-update |
| API | 20% | 8 | 12 endpoints but grouped by resource -- test contracts for create/read/update on each resource plus error responses |
| E2E | 5% | 2 | Only 2 critical paths need full browser testing: complete purchase flow and user registration to first order |

**Total: 42 tests**

**Justification:** ShopFlow is a services-heavy API with React frontend. The majority of business logic lives in service modules (orderService, paymentService, priceCalculator) that are pure or near-pure functions -- ideal for unit testing. The API layer is a thin HTTP wrapper, so API contract tests verify shapes without duplicating business logic tests. Integration tests focus only on cross-service interactions (payment triggers order status change). E2E tests are limited to the 2 most critical user journeys since the React frontend is primarily data display with forms.

---

## Guidelines

### DO

- **DO** reference specific file paths and function names from the actual codebase in every section
- **DO** justify every risk level with evidence -- cite the file, function, or pattern that creates the risk
- **DO** rank unit test targets by business impact, not just code complexity
- **DO** include both happy-path and error-response contracts for API targets
- **DO** tailor the testing pyramid percentages to this specific application's architecture
- **DO** explain why integration tests target specific module interactions, not just "test integrations"
- **DO** list the actual entry points (route files with methods) -- downstream agents need this to plan test files

### DON'T

- **DON'T** use generic risks like "SQL injection" without pointing to a specific vulnerable query or ORM misuse
- **DON'T** recommend 50%+ E2E tests for API-heavy applications -- the pyramid should reflect where the logic lives
- **DON'T** list dependencies without justifying their risk level -- "express: HIGH" is wrong without an explanation
- **DON'T** include dependencies that are dev-only (eslint, prettier, typescript) in the external dependencies table
- **DON'T** rank test targets by alphabetical order -- rank by the composite score (impact x complexity x frequency)
- **DON'T** produce a testing pyramid with generic rationale ("unit tests are fast") -- rationale must reference this app

---

## Quality Gate

Before delivering this artifact, verify all of the following:

- [ ] Architecture Overview has all required fields populated with specific values (not placeholders)
- [ ] Entry Points table lists every route file with methods and auth requirements
- [ ] External Dependencies table includes every production dependency with risk justification
- [ ] Every risk in Risk Assessment cites a specific file or function as evidence
- [ ] Top 10 Unit Test Targets are ranked by composite score, not alphabetical
- [ ] Every unit test target has a specific function/method name (not just a file)
- [ ] API/Contract Test Targets include request and response shapes with specific field names
- [ ] Testing Pyramid percentages sum to 100%
- [ ] Testing Pyramid rationale references this specific application's architecture
- [ ] No risk, target, or dependency uses generic justification without evidence from the codebase
