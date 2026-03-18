---
template_name: scan-manifest
version: "1.0"
artifact_type: scan
produces: SCAN_MANIFEST.md
producer_agent: qa-scanner
consumer_agents:
  - qa-analyzer
  - qa-testid-injector
required_sections:
  - project-detection
  - file-list
  - summary-statistics
  - testable-surfaces
  - decision-gate
example_domain: shopflow
---

# SCAN_MANIFEST.md Template

**Purpose:** Comprehensive inventory of all source files relevant to testing, with framework detection, interaction density classification, and testable surface categorization. This is the first artifact produced in the QA pipeline and feeds all downstream agents.

**Producer:** `qa-scanner` agent
**Consumers:** `qa-analyzer` (reads file list and surfaces to prioritize analysis), `qa-testid-injector` (reads component files to audit for missing `data-testid` attributes)

---

## Required Sections

### Section 1: Project Detection

**Description:** Framework, language, runtime, and tooling detected from package files, config files, and file extension analysis. This section tells downstream agents what technology stack they are dealing with.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| framework | string | YES | Primary framework detected (e.g., React, Vue, Angular, Express, NestJS, Django) |
| language | string | YES | Primary language (e.g., TypeScript, JavaScript, Python, C#) |
| runtime | string | YES | Runtime environment (e.g., Node.js 20, Python 3.11, .NET 8) |
| component_pattern | string | YES | File extension pattern for components (e.g., `*.tsx`, `*.vue`, `*.component.ts`) |
| package_manager | string | YES | Package manager detected (e.g., npm, yarn, pnpm, pip, dotnet) |
| build_tool | string | NO | Build tool if detected (e.g., Vite, Webpack, esbuild, Turbopack) |
| test_framework_existing | string | NO | Existing test framework if detected (e.g., Jest, Vitest, Playwright, Cypress) |
| database | string | NO | Database technology if detected from ORM config or connection strings |
| css_approach | string | NO | CSS strategy if detected (e.g., Tailwind, CSS Modules, styled-components) |

**Detection sources:** `package.json`, `requirements.txt`, `*.csproj`, config files (`tsconfig.json`, `vite.config.ts`, `next.config.js`), file extension frequency analysis.

---

### Section 2: File List

**Description:** All source files relevant to testing, ordered by interaction density priority. Each file is classified by type and assigned a priority based on how much user-facing or business-critical behavior it contains.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| file_path | string | YES | Relative path from project root (e.g., `src/services/orderService.ts`) |
| component_name | string | YES | Human-readable name extracted from filename or default export |
| type | enum | YES | One of: `page`, `component`, `service`, `utility`, `model`, `middleware`, `route`, `controller`, `config` |
| interaction_density | enum | YES | `HIGH` (forms, checkout, auth), `MEDIUM` (display, navigation), `LOW` (footer, static, utility) |
| priority_order | number | YES | Integer rank (1 = highest priority). Ordered by: interaction density, then business criticality |
| line_count | number | NO | Approximate line count for complexity estimation |
| exports_count | number | NO | Number of exported functions/classes for test target estimation |

**Inclusion rules:**
- Include: All source files that could have tests written against them
- Exclude: `node_modules/`, `dist/`, `build/`, `.next/`, `coverage/`, test files (`*.test.*`, `*.spec.*`, `*.stories.*`), config-only files, lockfiles, static assets

**Priority ordering rules:**
- Forms and interactive components with user input: HIGH
- Pages and views with conditional rendering: MEDIUM to HIGH
- Services with business logic: HIGH
- API route handlers and controllers: MEDIUM to HIGH
- Static display components: LOW to MEDIUM
- Pure utility functions: LOW to MEDIUM
- Models and type definitions: LOW

---

### Section 3: Summary Statistics

**Description:** Aggregate counts providing a quick overview of the scanned codebase. Used by downstream agents to estimate scope and allocate testing effort.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| total_files | number | YES | Total files in the file list |
| files_by_type | object | YES | Count per type (e.g., `{page: 4, component: 8, service: 5, ...}`) |
| files_by_priority | object | YES | Count per interaction density (e.g., `{HIGH: 7, MEDIUM: 9, LOW: 6}`) |
| total_line_count | number | NO | Sum of all file line counts |
| frameworks_detected | list | NO | All frameworks/libraries detected (e.g., `[React, Express, Prisma]`) |

---

### Section 4: Testable Surfaces

**Description:** Categorized groupings of testable entry points. Each category helps downstream agents focus on the right testing strategy (unit, integration, API, or E2E).

**Categories:**

1. **Pages/Views** -- User-facing routes or screens. Each entry: route path, component file, description.
2. **Forms** -- Data input surfaces requiring validation testing. Each entry: form name, component file, fields list, submission endpoint.
3. **API Endpoints** -- HTTP routes that accept requests. Each entry: method, path, controller/handler file, auth required (yes/no).
4. **Business Logic Modules** -- Pure functions and services containing domain rules. Each entry: module file, key functions, why testable (state transitions, calculations, validations).
5. **Middleware** -- Cross-cutting concerns applied to requests. Each entry: middleware file, what it does, routes it applies to.

---

### Section 5: Decision Gate

**Description:** Go/no-go decision based on scan results. This gate prevents downstream agents from running on repos that have no testable content.

**Rules:**
- If total files = 0: **STOP** with reason "No source files found"
- If 0 component files AND project type suggests frontend: **STOP** with reason "Expected frontend components but found none -- verify project structure"
- If backend-only detected (no component files, only services/routes): **PROCEED** with note "Skip testid-inject, proceed to analyze"
- If mixed frontend + backend: **PROCEED** with note "Full pipeline -- include testid-inject for frontend components"
- If only config/utility files found: **STOP** with reason "No testable surfaces detected -- only configuration files present"

**Output format:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| decision | enum | YES | `PROCEED` or `STOP` |
| reason | string | YES | Why this decision was made |
| pipeline_note | string | NO | Guidance for downstream agents (e.g., "skip testid-inject") |
| confidence | enum | YES | `HIGH` (clear detection), `MEDIUM` (some ambiguity), `LOW` (uncertain stack) |

---

## Worked Example (ShopFlow E-Commerce API)

> The following is a complete, filled SCAN_MANIFEST.md for a hypothetical ShopFlow e-commerce application. This example demonstrates the expected depth, format, and quality level.

### Project Detection

| Property | Value |
|----------|-------|
| Framework | React 18.2 + Express 4.18 |
| Language | TypeScript 5.3 |
| Runtime | Node.js 20 LTS |
| Component Pattern | `*.tsx` (frontend), `*.ts` (backend) |
| Package Manager | npm 10.x |
| Build Tool | Vite 5.0 |
| Test Framework (existing) | None detected |
| Database | PostgreSQL 15 via Prisma 5.7 |
| CSS Approach | Tailwind CSS 3.4 |

**Detection sources:** `package.json` (dependencies: react, express, prisma, stripe), `tsconfig.json` (strict mode, paths configured), `vite.config.ts` (React plugin), `prisma/schema.prisma` (PostgreSQL datasource).

---

### File List

| # | File Path | Component Name | Type | Interaction Density | Priority |
|---|-----------|---------------|------|---------------------|----------|
| 1 | src/components/checkout/CheckoutForm.tsx | CheckoutForm | component | HIGH | 1 |
| 2 | src/components/auth/LoginForm.tsx | LoginForm | component | HIGH | 2 |
| 3 | src/components/auth/RegisterForm.tsx | RegisterForm | component | HIGH | 3 |
| 4 | src/services/orderService.ts | OrderService | service | HIGH | 4 |
| 5 | src/services/paymentService.ts | PaymentService | service | HIGH | 5 |
| 6 | src/utils/priceCalculator.ts | PriceCalculator | utility | HIGH | 6 |
| 7 | src/controllers/orderController.ts | OrderController | controller | HIGH | 7 |
| 8 | src/controllers/paymentController.ts | PaymentController | controller | HIGH | 8 |
| 9 | src/services/authService.ts | AuthService | service | HIGH | 9 |
| 10 | src/controllers/authController.ts | AuthController | controller | MEDIUM | 10 |
| 11 | src/controllers/productController.ts | ProductController | controller | MEDIUM | 11 |
| 12 | src/services/inventoryService.ts | InventoryService | service | MEDIUM | 12 |
| 13 | src/middleware/authMiddleware.ts | AuthMiddleware | middleware | MEDIUM | 13 |
| 14 | src/components/products/ProductCard.tsx | ProductCard | component | MEDIUM | 14 |
| 15 | src/components/products/ProductList.tsx | ProductList | component | MEDIUM | 15 |
| 16 | src/pages/HomePage.tsx | HomePage | page | MEDIUM | 16 |
| 17 | src/pages/ProductDetailPage.tsx | ProductDetailPage | page | MEDIUM | 17 |
| 18 | src/pages/CartPage.tsx | CartPage | page | MEDIUM | 18 |
| 19 | src/pages/OrderHistoryPage.tsx | OrderHistoryPage | page | MEDIUM | 19 |
| 20 | src/utils/validators.ts | Validators | utility | LOW | 20 |
| 21 | src/middleware/rateLimiter.ts | RateLimiter | middleware | LOW | 21 |
| 22 | src/middleware/errorHandler.ts | ErrorHandler | middleware | LOW | 22 |
| 23 | src/components/layout/Navbar.tsx | Navbar | component | LOW | 23 |
| 24 | src/components/layout/Footer.tsx | Footer | component | LOW | 24 |
| 25 | src/models/Product.ts | Product | model | LOW | 25 |
| 26 | src/models/Order.ts | Order | model | LOW | 26 |
| 27 | src/models/User.ts | User | model | LOW | 27 |
| 28 | src/models/Payment.ts | Payment | model | LOW | 28 |
| 29 | src/routes/api/v1/auth.ts | AuthRoutes | route | LOW | 29 |
| 30 | src/routes/api/v1/products.ts | ProductRoutes | route | LOW | 30 |
| 31 | src/routes/api/v1/orders.ts | OrderRoutes | route | LOW | 31 |
| 32 | src/routes/api/v1/payments.ts | PaymentRoutes | route | LOW | 32 |

---

### Summary Statistics

| Metric | Value |
|--------|-------|
| **Total Files Scanned** | 32 |
| **Files by Type** | page: 4, component: 7, service: 4, utility: 2, model: 4, middleware: 3, route: 4, controller: 4 |
| **Files by Interaction Density** | HIGH: 9, MEDIUM: 10, LOW: 13 |
| **Total Estimated Lines** | ~4,200 |
| **Frameworks Detected** | React 18.2, Express 4.18, Prisma 5.7, Stripe SDK 14.x |

---

### Testable Surfaces

#### Pages/Views (4)

| Route | Component File | Description |
|-------|---------------|-------------|
| `/` | src/pages/HomePage.tsx | Landing page with featured products and category navigation |
| `/products/:id` | src/pages/ProductDetailPage.tsx | Single product view with add-to-cart action |
| `/cart` | src/pages/CartPage.tsx | Shopping cart with quantity editing and checkout trigger |
| `/orders` | src/pages/OrderHistoryPage.tsx | User order history with status tracking |

#### Forms (3)

| Form Name | Component File | Fields | Submission Endpoint |
|-----------|---------------|--------|---------------------|
| Login Form | src/components/auth/LoginForm.tsx | email, password | POST /api/v1/auth/login |
| Registration Form | src/components/auth/RegisterForm.tsx | name, email, password, confirmPassword | POST /api/v1/auth/register |
| Checkout Form | src/components/checkout/CheckoutForm.tsx | shippingAddress, cardNumber, cardExpiry, cardCvc | POST /api/v1/payments/charge |

#### API Endpoints (12)

| Method | Path | Handler File | Auth |
|--------|------|-------------|------|
| POST | /api/v1/auth/register | src/controllers/authController.ts | No |
| POST | /api/v1/auth/login | src/controllers/authController.ts | No |
| POST | /api/v1/auth/refresh | src/controllers/authController.ts | Yes |
| POST | /api/v1/auth/logout | src/controllers/authController.ts | Yes |
| GET | /api/v1/products | src/controllers/productController.ts | No |
| GET | /api/v1/products/:id | src/controllers/productController.ts | No |
| POST | /api/v1/products | src/controllers/productController.ts | Yes |
| PUT | /api/v1/products/:id | src/controllers/productController.ts | Yes |
| DELETE | /api/v1/products/:id | src/controllers/productController.ts | Yes |
| POST | /api/v1/orders | src/controllers/orderController.ts | Yes |
| PATCH | /api/v1/orders/:id/status | src/controllers/orderController.ts | Yes |
| POST | /api/v1/payments/charge | src/controllers/paymentController.ts | Yes |

#### Business Logic Modules (6)

| Module File | Key Functions | Why Testable |
|------------|---------------|--------------|
| src/utils/priceCalculator.ts | calculateOrderTotal, applyDiscount, calculateTax, calculateShipping | Pure functions with arithmetic -- ideal unit test targets |
| src/services/orderService.ts | createOrder, transitionOrderStatus, cancelOrder, getOrderHistory | State machine transitions with validation rules |
| src/services/paymentService.ts | chargeCustomer, processRefund, handleWebhook | Stripe integration with error handling and idempotency |
| src/services/authService.ts | hashPassword, verifyPassword, generateToken, refreshToken | Security-critical functions with cryptographic operations |
| src/services/inventoryService.ts | reserveStock, releaseStock, checkAvailability | Concurrent access patterns with race condition potential |
| src/utils/validators.ts | validateEmail, validatePassword, validateAddress, validateCardNumber | Input validation with edge cases |

#### Middleware (3)

| Middleware File | Purpose | Applied To |
|----------------|---------|-----------|
| src/middleware/authMiddleware.ts | JWT token verification and user context injection | All routes except auth/register, auth/login, products (GET), payments/webhook |
| src/middleware/rateLimiter.ts | Rate limiting by IP and user ID | All routes (100 req/min general, 5 req/min for auth) |
| src/middleware/errorHandler.ts | Global error handling with structured JSON responses | All routes (catch-all) |

---

### Decision Gate

| Field | Value |
|-------|-------|
| **Decision** | **PROCEED** |
| **Reason** | 32 testable files found across frontend components and backend services |
| **Pipeline Note** | Full pipeline -- include testid-inject for 7 frontend components and 4 pages |
| **Confidence** | HIGH -- React + Express clearly detected from package.json and file extensions |

---

## Guidelines

### DO

- **DO** include every source file that could have tests written against it -- services, controllers, components, utilities, middleware, models
- **DO** prioritize forms and interactive components as HIGH interaction density -- they have the most user-facing behavior
- **DO** list all API endpoints discovered from route files, including method, path, and auth requirements
- **DO** record the actual detection sources (which files told you the framework, runtime, etc.)
- **DO** order the file list by priority so downstream agents process the most important files first
- **DO** include line count estimates when available -- they help estimate test generation effort

### DON'T

- **DON'T** include `node_modules/`, `dist/`, `build/`, `.next/`, `coverage/`, or other build artifacts
- **DON'T** include test files (`*.test.*`, `*.spec.*`, `*.stories.*`) -- those are analyzed separately
- **DON'T** include lockfiles (`package-lock.json`, `yarn.lock`) or config-only files (`eslint.config.js`)
- **DON'T** mark utility-only files (pure functions, type definitions) as HIGH interaction density
- **DON'T** mark static display components (Footer, badges, icons) as HIGH interaction density
- **DON'T** guess the framework -- if detection is ambiguous, mark confidence as LOW and list what was found
- **DON'T** include files from dependency directories or generated code

---

## Quality Gate

Before delivering this artifact, verify all of the following:

- [ ] Project Detection section has all 5 required fields populated (framework, language, runtime, component_pattern, package_manager)
- [ ] File List contains every source file relevant to testing (no business logic files omitted)
- [ ] File List excludes all test files, build artifacts, node_modules, and config-only files
- [ ] Every file in the File List has a type, interaction density, and priority order assigned
- [ ] Priority ordering puts forms and interactive components before static/utility files
- [ ] Summary Statistics counts match the actual File List entries
- [ ] Testable Surfaces section covers all 5 categories (pages, forms, API endpoints, business logic, middleware)
- [ ] API Endpoints list matches the route files found in the File List
- [ ] Decision Gate has a clear PROCEED or STOP with justification
- [ ] No duplicate file paths in the File List
