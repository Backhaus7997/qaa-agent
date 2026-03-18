---
template_name: qa-repo-blueprint
version: "1.0"
artifact_type: blueprint
produces: QA_REPO_BLUEPRINT.md
producer_agent: qa-analyzer
consumer_agents:
  - qa-planner
  - qa-executor
required_sections:
  - project-info
  - folder-structure
  - recommended-stack
  - config-files
  - execution-scripts
  - ci-cd-strategy
  - definition-of-done
example_domain: shopflow
---

# QA_REPO_BLUEPRINT.md Template

**Purpose:** Defines the complete structure, tooling, configuration, and setup for a new QA test repository. This blueprint is the single source of truth for how the test project is organized, what tools it uses, and how tests are executed locally and in CI.

**Producer:** qa-analyzer (when no QA repo exists for the target dev repo)
**Consumers:** qa-planner (to plan test generation work), qa-executor (to scaffold the repo and write tests in the correct locations)

---

## Required Sections

### Section 1: Project Info

**Description:** Identifies the QA project and its relationship to the development repository.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Suggested Repo Name | string | YES | Pattern: `{project}-qa-tests` |
| Relationship | enum | YES | `separate-repo` or `subdirectory` |
| Target Dev Repo | URL/path | YES | The repository being tested |
| Framework Rationale | text | YES | Why this test framework was chosen for this specific dev repo |

---

### Section 2: Folder Structure

**Description:** Complete directory tree for the QA repository with a one-line explanation per directory. Every directory that agents will write files into must appear here.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Directory Tree | code block | YES | Full tree output with all directories |
| Per-Directory Explanation | text per entry | YES | What goes in each directory |

Must include at minimum:
- `tests/e2e/smoke/` -- P0 critical path tests run on every PR
- `tests/e2e/regression/` -- Full E2E suite run nightly
- `tests/api/` -- API-level tests
- `tests/unit/` -- Unit tests for business logic
- `pages/base/` -- Base page object with shared methods
- `pages/{feature}/` -- Feature-specific page objects
- `pages/components/` -- Reusable UI component objects
- `fixtures/` -- Test data and factories
- `config/` -- Test configuration files (if separate from root)
- `reports/` -- Generated reports (gitignored)
- `.github/workflows/` -- CI/CD pipeline definitions

---

### Section 3: Recommended Stack

**Description:** Technology recommendations specific to the target dev repo's language and framework.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Component | string | YES | What role (test framework, runner, assertion, reporter, mocking, API testing, CI) |
| Recommended Tool | string | YES | Specific tool name |
| Version | string | YES | Pinned version |
| Why Chosen | text | YES | Rationale tied to the dev repo's stack |

---

### Section 4: Config Files

**Description:** Complete, ready-to-use configuration files for the QA project. Each file is shown as a full code block -- not a snippet, the entire file.

Must include:
- Test framework config (e.g., `playwright.config.ts`)
- TypeScript config for the test project (`tsconfig.json`)
- Environment template (`.env.example`) with all required variables
- Gitignore additions (`.gitignore`)
- Package scripts section (`package.json` scripts)

---

### Section 5: Execution Scripts

**Description:** npm scripts table defining how to run each test suite.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Script Name | string | YES | npm script name |
| Command | string | YES | Actual command executed |
| When to Run | string | YES | PR gate, nightly, manual, etc. |
| What It Does | text | YES | One-line description |

Must include at minimum:
- `test:smoke` -- PR gate, critical path only
- `test:regression` -- Nightly, full E2E suite
- `test:api` -- API tests only
- `test:unit` -- Unit tests only
- `test:report` -- Generate HTML report
- `test:ci` -- Full CI run (all suites + report)

---

### Section 6: CI/CD Strategy

**Description:** Complete GitHub Actions workflow YAML defining the CI/CD pipeline for the QA repo.

Must include:
- Smoke tests on pull request (triggers on PR to main)
- Regression tests on schedule (nightly)
- Report artifact upload
- Failure notification

---

### Section 7: Definition of Done

**Description:** Checklist of 10-12 conditions that must all be true before the QA repo is considered ready for use. Covers structure, test execution, CI integration, and baseline quality.

---

## Worked Example (ShopFlow E-Commerce API)

Below is a complete, filled QA_REPO_BLUEPRINT.md for the ShopFlow e-commerce platform.

---

### Project Info

| Property | Value |
|----------|-------|
| **Suggested Repo Name** | `shopflow-qa-tests` |
| **Relationship** | Separate repository |
| **Target Dev Repo** | `https://github.com/shopflow/shopflow-api` |
| **Dev Stack** | Node.js 20, TypeScript 5.3, Express 4.18, PostgreSQL 15 (Prisma 5.7), Stripe SDK |
| **Framework Rationale** | Playwright chosen because ShopFlow has both a REST API and a React frontend. Playwright handles browser E2E, API testing, and has built-in TypeScript support -- matching the dev repo's language. Single framework for all test tiers reduces context switching and dependency surface. |

---

### Folder Structure

```
shopflow-qa-tests/
  tests/
    e2e/
      smoke/                    # P0 critical path tests -- run on every PR
        login.e2e.spec.ts       # Auth flow smoke test
        checkout.e2e.spec.ts    # Purchase flow smoke test
      regression/               # Full E2E suite -- run nightly
        product-browse.e2e.spec.ts
        order-management.e2e.spec.ts
        payment-flow.e2e.spec.ts
        user-profile.e2e.spec.ts
        inventory-alerts.e2e.spec.ts
    api/                        # API-level tests (no browser)
      auth.api.spec.ts          # Register, login, refresh, logout
      products.api.spec.ts      # CRUD + search + filtering
      orders.api.spec.ts        # Create, status transitions, history
      payments.api.spec.ts      # Charge, refund, webhook verification
      inventory.api.spec.ts     # Stock queries, reservation
    unit/                       # Unit tests for business logic
      priceCalculator.unit.spec.ts
      orderStateMachine.unit.spec.ts
      validators.unit.spec.ts
      authToken.unit.spec.ts
  pages/
    base/
      BasePage.ts               # Shared methods: navigation, screenshots, waits, common assertions setup
    auth/
      LoginPage.ts              # Login page: email input, password input, submit, error display
      RegisterPage.ts           # Registration form page object
    products/
      ProductListPage.ts        # Product listing with filters and search
      ProductDetailPage.ts      # Single product view with add-to-cart
    checkout/
      CartPage.ts               # Shopping cart with item management
      CheckoutPage.ts           # Multi-step checkout (address, payment, confirm)
    orders/
      OrderHistoryPage.ts       # Order list and status display
      OrderDetailPage.ts        # Single order with tracking
    components/
      NavigationBar.ts          # Top nav: logo, search, cart icon, user menu
      ProductCard.ts            # Reusable product card (list and grid views)
      Pagination.ts             # Shared pagination controls
      Toast.ts                  # Notification toast component
  fixtures/
    auth-data.ts                # Test user credentials, tokens
    product-data.ts             # Sample product objects (with SKUs, prices, images)
    order-data.ts               # Order payloads at various states
    payment-data.ts             # Stripe test tokens, webhook payloads
  config/
    global-setup.ts             # Database seeding, auth token acquisition
    global-teardown.ts          # Cleanup: remove test data, close connections
  reports/                      # Generated reports -- gitignored
    html/
    json/
    screenshots/
  .github/
    workflows/
      qa-smoke.yml              # PR trigger: smoke tests only
      qa-regression.yml         # Nightly schedule: full regression
  playwright.config.ts          # Main test framework configuration
  tsconfig.json                 # TypeScript config for test project
  package.json                  # Dependencies and scripts
  .env.example                  # Required environment variables
  .gitignore                    # Ignore reports, node_modules, .env
```

**Directory Purposes:**

| Directory | Purpose |
|-----------|---------|
| `tests/e2e/smoke/` | P0 critical path tests that gate every pull request. Max 5-8 tests, must complete in under 2 minutes. |
| `tests/e2e/regression/` | Comprehensive E2E tests covering all user flows. Runs nightly. No time constraint. |
| `tests/api/` | API-level tests hitting REST endpoints directly. No browser. Validates contracts, status codes, response shapes. |
| `tests/unit/` | Pure business logic tests. No network, no browser. Tests price calculations, state machines, validators. |
| `pages/base/` | BasePage class with shared methods inherited by all page objects (goto, screenshot, waitForLoad). |
| `pages/{feature}/` | One page object per page/view, grouped by feature area. |
| `pages/components/` | Reusable component objects shared across multiple pages (nav bar, product card, pagination). |
| `fixtures/` | Test data factories and static test payloads. One file per domain (auth, product, order, payment). |
| `config/` | Global setup/teardown scripts for test infrastructure (DB seeding, auth tokens). |
| `reports/` | Generated HTML/JSON reports and failure screenshots. Entirely gitignored. |
| `.github/workflows/` | CI/CD pipeline definitions for smoke (PR) and regression (nightly) runs. |

---

### Recommended Stack

| Component | Recommended Tool | Version | Why Chosen |
|-----------|-----------------|---------|------------|
| Test Framework | Playwright | 1.40.x | Supports browser E2E + API testing in one framework. Built-in TypeScript. Matches ShopFlow's TS stack. |
| Test Runner | @playwright/test | 1.40.x | Native Playwright runner with parallel execution, retries, and built-in assertions. |
| Assertion Library | @playwright/test (expect) | 1.40.x | Built-in web-first assertions (toBeVisible, toHaveText) + standard expect for API/unit. |
| HTML Reporter | @playwright/test html | 1.40.x | Zero-config HTML report with traces, screenshots, and video on failure. |
| CI Reporter | Allure | 2.25.x | Rich CI reporting with history trends, categories, and Slack integration. |
| API Mocking | MSW (Mock Service Worker) | 2.1.x | Intercepts HTTP at the network level. Useful for isolating frontend tests from real API. |
| Linting | ESLint + @typescript-eslint | 6.x | Catches no-floating-promises, unused variables, and enforces test code quality. |
| CI Platform | GitHub Actions | N/A | Matches ShopFlow's existing CI. Native artifact upload and caching support. |

---

### Config Files

**playwright.config.ts**

```typescript
import { defineConfig, devices } from '@playwright/test';
import dotenv from 'dotenv';

dotenv.config();

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 2 : undefined,
  reporter: [
    ['html', { outputFolder: 'reports/html', open: 'never' }],
    ['json', { outputFile: 'reports/json/results.json' }],
    ...(process.env.CI ? [['allure-playwright' as const]] : []),
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'smoke',
      testDir: './tests/e2e/smoke',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'regression-chromium',
      testDir: './tests/e2e/regression',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'regression-firefox',
      testDir: './tests/e2e/regression',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'api',
      testDir: './tests/api',
      use: {
        baseURL: process.env.API_URL || 'http://localhost:3000/api/v1',
      },
    },
    {
      name: 'unit',
      testDir: './tests/unit',
    },
  ],
  globalSetup: './config/global-setup.ts',
  globalTeardown: './config/global-teardown.ts',
});
```

**tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "outDir": "./dist",
    "rootDir": ".",
    "baseUrl": ".",
    "paths": {
      "@pages/*": ["pages/*"],
      "@fixtures/*": ["fixtures/*"],
      "@config/*": ["config/*"]
    }
  },
  "include": ["tests/**/*.ts", "pages/**/*.ts", "fixtures/**/*.ts", "config/**/*.ts"],
  "exclude": ["node_modules", "reports", "dist"]
}
```

**.env.example**

```bash
# ShopFlow QA Test Configuration
# Copy to .env and fill in values

# Application URLs
BASE_URL=http://localhost:3000
API_URL=http://localhost:3000/api/v1

# Test User Credentials (use test/staging accounts only)
TEST_USER_EMAIL=test@shopflow.dev
TEST_USER_PASSWORD=TestP@ss123!

# Admin User Credentials (for admin-only test flows)
TEST_ADMIN_EMAIL=admin@shopflow.dev
TEST_ADMIN_PASSWORD=AdminP@ss456!

# Database (for direct DB setup/teardown)
DATABASE_URL=postgresql://test:test@localhost:5432/shopflow_test

# Stripe Test Keys (for payment flow tests)
STRIPE_TEST_SECRET_KEY=sk_test_...
STRIPE_TEST_WEBHOOK_SECRET=whsec_test_...

# CI Configuration
CI=false
HEADLESS=true
```

**.gitignore additions**

```
# Test reports
reports/
allure-results/
allure-report/

# Test artifacts
test-results/
playwright-report/
screenshots/

# Environment
.env
.env.local

# Dependencies
node_modules/

# Build
dist/

# OS
.DS_Store
Thumbs.db
```

**package.json scripts**

```json
{
  "name": "shopflow-qa-tests",
  "version": "1.0.0",
  "description": "QA test suite for ShopFlow e-commerce API and frontend",
  "scripts": {
    "test:smoke": "playwright test --project=smoke",
    "test:regression": "playwright test --project=regression-chromium --project=regression-firefox",
    "test:api": "playwright test --project=api",
    "test:unit": "playwright test --project=unit",
    "test:report": "playwright show-report reports/html",
    "test:ci": "playwright test --project=smoke --project=api --project=unit && playwright test --project=regression-chromium",
    "lint": "eslint tests/ pages/ fixtures/ --ext .ts",
    "lint:fix": "eslint tests/ pages/ fixtures/ --ext .ts --fix"
  },
  "devDependencies": {
    "@playwright/test": "^1.40.0",
    "allure-playwright": "^2.25.0",
    "dotenv": "^16.3.1",
    "eslint": "^8.56.0",
    "@typescript-eslint/eslint-plugin": "^6.19.0",
    "@typescript-eslint/parser": "^6.19.0",
    "typescript": "^5.3.0"
  }
}
```

---

### Execution Scripts

| Script | Command | When to Run | What It Does |
|--------|---------|-------------|-------------|
| `test:smoke` | `playwright test --project=smoke` | Every PR (CI gate) | Runs P0 critical path E2E tests in Chrome only. Must pass before merge. Target: under 2 minutes. |
| `test:regression` | `playwright test --project=regression-chromium --project=regression-firefox` | Nightly (scheduled) | Full E2E regression across Chrome and Firefox. Catches cross-browser issues. |
| `test:api` | `playwright test --project=api` | Every PR + nightly | API contract tests. No browser. Validates endpoints, status codes, response shapes. |
| `test:unit` | `playwright test --project=unit` | Every PR + nightly | Pure business logic tests. Fastest suite. Validates calculations, state machines, validators. |
| `test:report` | `playwright show-report reports/html` | After any test run (local) | Opens the HTML report in the default browser for visual review of results. |
| `test:ci` | `playwright test --project=smoke --project=api --project=unit && playwright test --project=regression-chromium` | Full CI run | Runs all suites sequentially: smoke + API + unit first (fast feedback), then full regression. |

---

### CI/CD Strategy

**qa-smoke.yml** (PR gate)

```yaml
name: QA Smoke Tests

on:
  pull_request:
    branches: [main]

jobs:
  smoke-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 10

    steps:
      - name: Checkout QA repo
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps chromium

      - name: Run smoke tests
        run: npm run test:smoke
        env:
          BASE_URL: ${{ secrets.STAGING_BASE_URL }}
          API_URL: ${{ secrets.STAGING_API_URL }}
          TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
          TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}
          CI: true

      - name: Run API tests
        run: npm run test:api
        env:
          API_URL: ${{ secrets.STAGING_API_URL }}
          TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
          TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}
          CI: true

      - name: Run unit tests
        run: npm run test:unit
        env:
          CI: true

      - name: Upload test report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: smoke-report-${{ github.run_number }}
          path: reports/
          retention-days: 7
```

**qa-regression.yml** (Nightly)

```yaml
name: QA Regression Suite

on:
  schedule:
    - cron: '0 2 * * *'  # Every night at 2:00 AM UTC
  workflow_dispatch:        # Allow manual trigger

jobs:
  regression-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - name: Checkout QA repo
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run full regression
        run: npm run test:ci
        env:
          BASE_URL: ${{ secrets.STAGING_BASE_URL }}
          API_URL: ${{ secrets.STAGING_API_URL }}
          TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
          TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}
          STRIPE_TEST_SECRET_KEY: ${{ secrets.STRIPE_TEST_SECRET_KEY }}
          CI: true

      - name: Upload test report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: regression-report-${{ github.run_number }}
          path: reports/
          retention-days: 30

      - name: Upload Allure results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: allure-results-${{ github.run_number }}
          path: allure-results/
          retention-days: 30

      - name: Notify on failure
        if: failure()
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "text": "QA Regression FAILED: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_QA_WEBHOOK }}
```

---

### Definition of Done

The QA repository is ready for use when ALL of the following are true:

- [ ] Repository created with the exact folder structure defined above
- [ ] All configuration files committed (`playwright.config.ts`, `tsconfig.json`, `.env.example`, `.gitignore`)
- [ ] `npm install` completes without errors
- [ ] `npx playwright install` completes and browsers are available
- [ ] BasePage class exists in `pages/base/BasePage.ts` with shared methods (goto, screenshot, waitForLoad)
- [ ] At least one smoke test exists and passes: `npm run test:smoke` exits 0
- [ ] At least one API test exists and passes: `npm run test:api` exits 0
- [ ] At least one unit test exists and passes: `npm run test:unit` exits 0
- [ ] Fixtures directory has at least one fixture file with test data
- [ ] `.env.example` documents ALL required environment variables
- [ ] CI smoke workflow (`qa-smoke.yml`) runs successfully on a test PR
- [ ] CI regression workflow (`qa-regression.yml`) runs successfully on manual trigger

---

## Guidelines

**DO:**
- Match the test framework to the dev repo's language (TypeScript dev repo = TypeScript tests)
- Include the smoke/regression split for CI efficiency -- smoke gates PRs fast, regression catches everything nightly
- Pin dependency versions in package.json to avoid surprise breaking changes
- Include path aliases in tsconfig.json (`@pages/*`, `@fixtures/*`) for clean imports
- Include both Chrome and Firefox in regression projects for cross-browser coverage
- Put global setup/teardown in `config/` to keep it separate from test files
- Always include `.env.example` -- tests need configuration and new team members need to know what to set up

**DON'T:**
- Recommend Cypress for pure API testing -- use Playwright or a dedicated API testing tool. Cypress is browser-first and adds unnecessary overhead for API-only tests.
- Skip the `.env.example` file -- without it, no one knows which environment variables are required
- Put assertions in page objects -- assertions belong ONLY in test spec files
- Use a single "tests/" directory without e2e/api/unit separation -- this makes selective CI execution impossible
- Hardcode base URLs or credentials in config files -- always use environment variables
- Recommend more than one test framework unless the project genuinely needs it (e.g., Playwright for E2E + Vitest for isolated unit tests of shared utilities)

---

## Quality Gate

Before delivering a QA_REPO_BLUEPRINT.md, verify:

- [ ] All 7 required sections are present and filled (Project Info, Folder Structure, Recommended Stack, Config Files, Execution Scripts, CI/CD Strategy, Definition of Done)
- [ ] Folder structure includes all mandatory directories (tests/e2e/smoke, tests/e2e/regression, tests/api, tests/unit, pages/base, fixtures, reports, .github/workflows)
- [ ] Recommended stack tools are specific to the target dev repo's language and framework (not generic recommendations)
- [ ] Config files are complete and ready to use (not snippets -- full files)
- [ ] Execution scripts include all 6 required scripts (test:smoke, test:regression, test:api, test:unit, test:report, test:ci)
- [ ] CI/CD strategy includes both PR gate (smoke) and nightly schedule (regression)
- [ ] Definition of Done has 10+ checklist items covering structure, tests pass, CI green, and baseline quality
- [ ] No hardcoded credentials anywhere in config files -- all use environment variables
