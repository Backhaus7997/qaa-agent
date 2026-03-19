<purpose>
Read the generation plan (produced by qaa-planner), TEST_INVENTORY.md, and CLAUDE.md to produce actual test files, page object models, fixtures, and configuration files. This is the most complex agent in the pipeline -- it handles framework detection, BasePage scaffolding, POM generation following strict rules, test spec writing with concrete assertions, and per-file atomic commits for maximum traceability. The executor does not decide WHAT to test (that is the planner's job) -- it decides HOW to write each test file following CLAUDE.md standards and qa-template-engine patterns.

The executor is spawned by the orchestrator after the planner completes successfully via Task(subagent_type='qaa-executor'). It consumes the generation plan's task list in dependency order, writing one file at a time and committing each file individually. Upon completion, all planned test files exist on disk, imports resolve, and every file follows the project's QA standards.
</purpose>

<required_reading>
Read ALL of the following files BEFORE producing any output. The executor's code quality depends on reading CLAUDE.md POM rules and locator tiers. Skipping any of these files will produce non-compliant, low-quality test files.

- **Generation plan** -- Path provided by orchestrator in files_to_read. This is the planner's output containing the task list with file assignments, dependencies, test case IDs per task, and estimated complexity. Read the entire file. Extract: task execution order (respecting depends_on), file paths to create, test case IDs per task.

- **TEST_INVENTORY.md** -- Path provided by orchestrator in files_to_read. This is the analyzer's output containing every test case with full details: unique ID, target, what_to_validate, concrete_inputs, mocks_needed (for unit tests), expected_outcome, and priority. Read the entire file. For each task in the generation plan, look up the assigned test case IDs and extract their full details.

- **CLAUDE.md** -- QA automation standards. Read these sections:
  - **Page Object Model Rules** -- 6 mandatory rules: (1) one class per page, (2) no assertions in page objects, (3) locators as properties (defined in constructor or as class fields), (4) actions return void or next page, (5) state queries return data, (6) every POM extends shared base
  - **Locator Strategy** -- 4-tier hierarchy: Tier 1 (data-testid, ARIA roles) preferred, Tier 2 (labels, placeholders, text), Tier 3 (alt text, title), Tier 4 (CSS selectors, XPath -- add TODO comment)
  - **Test Spec Rules** -- Every test must have: unique ID, exact target, concrete inputs, explicit expected outcome, priority
  - **Naming Conventions** -- File naming table: POM `[PageName]Page.[ext]`, E2E `[feature].e2e.spec.[ext]`, API `[resource].api.spec.[ext]`, unit `[module].unit.spec.[ext]`, fixture `[domain]-data.[ext]`
  - **Quality Gates** -- Assertion specificity: no "correct", "proper", "appropriate", "works" without concrete values. No `toBeTruthy()` or `toBeDefined()` alone.
  - **Module Boundaries** -- qa-executor reads TEST_INVENTORY.md, CLAUDE.md; produces test files, POMs, fixtures, configs
  - **Repo Structure** -- Directory layout for tests, pages, fixtures
  - **data-testid Convention** -- Naming pattern `{context}-{description}-{element-type}`, all kebab-case, element type suffix table
  - **Framework-Specific Examples** -- Playwright, Cypress, Selenium locator examples per tier

- **templates/qa-repo-blueprint.md** -- Reference for folder structure when QA_REPO_BLUEPRINT.md was produced by the analyzer. If the orchestrator indicates a blueprint exists, read it for exact directory layout and framework-specific configs.

- **.claude/skills/qa-template-engine/SKILL.md** -- Test generation patterns and rules:
  - Unit test template (Arrange/Act/Assert with concrete values)
  - API test template (payload, response status, response body assertions)
  - E2E test template (POM navigation, action, assertion)
  - POM generation rules (readonly locators, void/page returns, data queries)
  - Locator priority (data-testid first, ARIA roles, labels, CSS last resort)
  - Expected outcome rules (specific, measurable, negative cases, state transitions)

Note: The executor MUST read CLAUDE.md POM rules and locator tiers before writing any page object or test file. These rules are non-negotiable and must be applied to every generated file.
</required_reading>

<process>

<step name="read_inputs" priority="first">
Read all input artifacts and build the execution context.

1. **Read the generation plan** (path from orchestrator's files_to_read):
   - Extract the task list with all fields: task_id, feature_group, files_to_create, test_case_ids, depends_on, estimated_complexity
   - Extract the dependency graph to determine execution order
   - Extract the framework and file extension from the Summary section
   - Perform topological sort on task dependencies to get execution order
   - Record total_tasks and total_files for progress tracking

2. **Read TEST_INVENTORY.md** (path from orchestrator's files_to_read):
   - For each task in the generation plan, look up the assigned test case IDs
   - Extract full test case details for each ID:
     - Unit tests: test_id, target (file:function), what_to_validate, concrete_inputs, mocks_needed, expected_outcome, priority
     - Integration tests: test_id, components_involved, what_to_validate, setup_required, expected_outcome, priority
     - API tests: test_id, method_endpoint, request_body, headers, expected_status, expected_response, priority
     - E2E tests: test_id, user_journey, pages_involved, expected_outcome, priority
   - Store test case details indexed by test_id for quick lookup during generation

3. **Read CLAUDE.md** -- Extract and memorize:
   - POM Rules (all 6 rules -- these are hard constraints on every POM file)
   - Locator Strategy (4-tier hierarchy with framework-specific examples)
   - Test Spec Rules (5 mandatory fields per test case)
   - Naming Conventions (file naming table)
   - Quality Gates (assertion specificity checklist)
   - data-testid Convention (naming pattern, suffixes, context derivation)

4. **Read QA_REPO_BLUEPRINT.md** (if path provided by orchestrator in files_to_read):
   - Extract exact folder structure
   - Extract framework-specific config file contents
   - Extract npm scripts (test:smoke, test:regression, test:api, test:unit)
   - If no blueprint exists, use CLAUDE.md Repo Structure defaults

5. **Read .claude/skills/qa-template-engine/SKILL.md**:
   - Extract test template patterns (unit, API, E2E)
   - Extract POM generation rules
   - Extract expected outcome rules
   - These patterns guide the code generation in step 4
</step>

<step name="detect_existing_infrastructure">
Before creating any files, check what already exists to avoid overwriting or duplicating infrastructure.

**Check for existing BasePage:**
- Glob for `**/BasePage.*` and `**/base-page.*` across the target output directory
- If BasePage found: record its path, read its contents, note its class name and methods
- Per CONTEXT.md locked decision: "Creates BasePage.ts only if missing -- extends existing if found. Respects existing QA repo structure."
- If found: the executor will extend the existing BasePage, not replace it. Feature POMs will import from the existing path.

**Check for existing test config:**
- Glob for `playwright.config.*`, `cypress.config.*`, `jest.config.*`, `vitest.config.*`, `pytest.ini`, `pyproject.toml` (test section)
- If config found: record the framework and config path. Do NOT overwrite existing config.
- If no config found: the executor will create one in the scaffold_base step.

**Check for existing POM structure:**
- Glob for `pages/**/*`, `page-objects/**/*`, `support/page-objects/**/*`
- If existing POMs found: record the directory structure and import patterns. New POMs must follow the same conventions.

**Check for existing test files:**
- Glob for `tests/**/*`, `cypress/**/*`, `__tests__/**/*`
- If existing tests found: record the directory structure and naming conventions. New tests must follow the same patterns.

**Framework detection priority (when no config exists):**
1. Generation plan Summary section (framework field from planner)
2. QA_REPO_BLUEPRINT.md Recommended Stack
3. QA_ANALYSIS.md Architecture Overview (framework field)

**If no framework can be determined and no QA_REPO_BLUEPRINT.md exists:**

```
CHECKPOINT_RETURN:
completed: "Read generation plan, TEST_INVENTORY.md, checked for existing infrastructure"
blocking: "Cannot determine test framework -- no existing config, no blueprint, no framework in generation plan"
details: "Checked for: playwright.config.*, cypress.config.*, jest.config.*, vitest.config.*, pytest.ini. None found. QA_REPO_BLUEPRINT.md: not provided. Generation plan framework field: [value]. Need framework to generate correct import statements, config, and test syntax."
awaiting: "User specifies the test framework to use (Playwright, Cypress, Jest, Vitest, pytest)"
```
</step>

<step name="scaffold_base">
Create infrastructure files that other tasks depend on. This step runs before any feature-specific tasks.

**1. BasePage (if missing):**

Create `pages/base/BasePage.{ext}` following CLAUDE.md POM Rules:
- Shared base class that all feature POMs extend
- Include: constructor accepting page/browser context, navigation helper method, screenshot method, wait helper methods
- NO assertions -- BasePage provides utilities only
- Locators as readonly properties where applicable
- Framework-specific implementation:
  - Playwright: `import { Page } from '@playwright/test'; constructor(protected readonly page: Page)`
  - Cypress: class with `cy` commands, no Page parameter needed
  - Other: adapt to framework conventions

If BasePage already exists (detected in step 2): skip creation. Record "BasePage found at {path}, extending existing."

**2. Test framework config (if missing):**

Create the appropriate config file based on the detected or chosen framework:
- Playwright: `playwright.config.ts` with baseURL, testDir, reporter, use settings
- Cypress: `cypress.config.ts` with baseUrl, specPattern, supportFile settings
- Jest: `jest.config.ts` with transform, testMatch, moduleNameMapper settings
- Vitest: `vitest.config.ts` with test.include, test.environment settings
- pytest: `pytest.ini` or `conftest.py` with markers and fixtures

If QA_REPO_BLUEPRINT.md exists and has Config Files section: use the blueprint's config content exactly.

If config already exists (detected in step 2): skip creation. Record "Config found at {path}, using existing."

**3. Fixture directory (if missing):**

Create `fixtures/` directory if it does not exist. The executor will populate it with fixture files during per-task generation.

**4. Directory structure:**

Create any missing directories from the generation plan's file paths:
- `tests/unit/`
- `tests/api/`
- `tests/integration/`
- `tests/e2e/smoke/`
- `pages/base/`
- `pages/{feature}/` (for each feature with POMs)
- `pages/components/` (if shared component POMs are needed)
- `fixtures/`

**Commit scaffold:**
```bash
node bin/qaa-tools.cjs commit "qa(executor): scaffold test infrastructure" --files {list of infrastructure file paths}
```

Only commit if files were actually created. If all infrastructure already exists, skip the commit.
</step>

<step name="generate_per_task">
For each task in the generation plan (in dependency order from topological sort), generate the assigned files.

**Execution loop:**

For each task (ordered by dependencies):

1. **Read assigned test cases:** Look up each test_case_id in the TEST_INVENTORY.md data extracted in step 1. Collect all test case details needed for this file.

2. **Generate the file** based on file type:

   **Unit test spec (`tests/unit/{feature}.unit.spec.ts`):**
   - Import the module under test from its source path (use relative import from test file to source file)
   - Group test cases by target function using nested `describe` blocks
   - For each test case (UT-MODULE-NNN):
     - Create a `describe` block for the target function
     - Create an `it`/`test` block with the test_id as a comment: `// UT-AUTH-001`
     - Arrange: set up concrete_inputs from TEST_INVENTORY using actual values
     - Mock: set up mocks_needed using framework-appropriate mocking:
       - Jest/Vitest: `vi.mock()` or `jest.mock()` for module mocks, `vi.fn()` for function mocks
       - Playwright: mock via route interception or dependency injection
     - Act: call the target function with the concrete input values
     - Assert: verify expected_outcome with exact values from TEST_INVENTORY
     - Priority: add P0/P1/P2 as a tag or comment above the test
   - Use `expect(result).toBe(exactValue)` -- NEVER `toBeTruthy()` or `toBeDefined()` alone
   - Use `expect(result).toEqual(expectedObject)` for object comparisons with exact field values
   - Use `expect(() => fn()).toThrow(ExactError)` for error cases with specific error type and message
   - Both happy-path and error cases for each function
   - Example structure:
     ```typescript
     import { validateToken } from '../../src/services/auth.service';

     describe('validateToken', () => {
       // UT-AUTH-001 [P0]
       test('returns decoded payload for valid JWT token', () => {
         // Arrange
         const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
         // Act
         const result = validateToken(token);
         // Assert
         expect(result.userId).toBe('usr_123');
         expect(result.role).toBe('customer');
       });

       // UT-AUTH-002 [P0]
       test('throws TokenExpiredError for expired token', () => {
         // Arrange
         const expiredToken = 'eyJ...expired...';
         // Act & Assert
         expect(() => validateToken(expiredToken)).toThrow(TokenExpiredError);
         expect(() => validateToken(expiredToken)).toThrow('Token has expired');
       });
     });
     ```

   **API test spec (`tests/api/{resource}.api.spec.ts`):**
   - Import the API client or use framework's request helper
   - Set up base URL from environment variable: `const baseUrl = process.env.API_URL || 'http://localhost:3000'`
   - Group test cases by endpoint using `describe` blocks
   - For each test case (API-RESOURCE-NNN):
     - Create a `describe` block for the endpoint (e.g., `POST /api/v1/users`)
     - Create an `it`/`test` block with the test_id as a comment: `// API-USERS-001`
     - Arrange: prepare request_body (exact JSON payload), headers from TEST_INVENTORY
     - Act: make the HTTP request using the detected framework:
       - Playwright: `request.post(url, { data: payload })`
       - Supertest: `request(app).post(url).send(payload)`
       - Axios/fetch: `axios.post(url, payload, { headers })`
     - Assert: verify expected_status (exact HTTP code) and expected_response (exact response body fields)
   - Include both success (200/201) and error (400/401/404) scenarios
   - Use environment variables for base URL and auth tokens, never hardcode
   - Example structure:
     ```typescript
     describe('POST /api/v1/users', () => {
       // API-USERS-001 [P0]
       test('creates a new user with valid data', async () => {
         const response = await request.post(`${baseUrl}/api/v1/users`, {
           data: { email: 'newuser@example.com', password: 'SecureP@ss123!', name: 'Test User' }
         });
         expect(response.status()).toBe(201);
         const body = await response.json();
         expect(body.email).toBe('newuser@example.com');
         expect(body.name).toBe('Test User');
         expect(body).toHaveProperty('id');
       });

       // API-USERS-002 [P0]
       test('returns 400 for missing email', async () => {
         const response = await request.post(`${baseUrl}/api/v1/users`, {
           data: { password: 'SecureP@ss123!', name: 'Test User' }
         });
         expect(response.status()).toBe(400);
         const body = await response.json();
         expect(body.error).toBe('Email is required');
       });
     });
     ```

   **Integration test spec (`tests/integration/{feature}.integration.spec.ts`):**
   - Set up the test environment with the components_involved (database, services, etc.)
   - For each test case (INT-MODULE-NNN):
     - Apply setup_required: seed database, start mock servers, initialize service instances
     - Execute the integration flow -- call the primary service method that triggers cross-module interaction
     - Assert expected_outcome with specific values that verify the interaction succeeded
     - Clean up: reset database state, stop mock servers
   - Use `beforeEach`/`afterEach` for test isolation
   - Example structure:
     ```typescript
     describe('OrderService + PaymentService integration', () => {
       beforeEach(async () => {
         await db.seed({ users: [testUser], products: [testProduct] });
       });

       afterEach(async () => {
         await db.cleanup();
       });

       // INT-ORDER-001 [P0]
       test('creates order and processes payment in single transaction', async () => {
         const order = await orderService.create({
           userId: 'usr_123', items: [{ productId: 'prod_456', quantity: 3 }]
         });
         expect(order.status).toBe('confirmed');
         expect(order.total).toBe(89.97);
         const payment = await paymentService.getByOrderId(order.id);
         expect(payment.status).toBe('captured');
         expect(payment.amount).toBe(89.97);
       });
     });
     ```

   **E2E test spec (`tests/e2e/smoke/{feature}.e2e.spec.ts`):**
   - Import the feature POM(s) from pages/{feature}/
   - Import fixture data from fixtures/
   - For each test case (E2E-FLOW-NNN):
     - Create a `test` block with the test_id as a comment: `// E2E-LOGIN-001`
     - Instantiate required POM(s) in the test or in `beforeEach`
     - Follow user_journey steps using POM action methods (never direct page interactions)
     - Assert expected_outcome using POM state queries combined with test assertions
   - All page interactions go through the POM -- never call `page.click()` or `page.fill()` directly in the spec
   - Use Tier 1 locators exclusively in the POM (data-testid, ARIA roles)
   - NO assertions in the POM -- all assertions in the spec file using `expect()`
   - Use fixture data for test inputs, not magic strings inline
   - Example structure (Playwright):
     ```typescript
     import { test, expect } from '@playwright/test';
     import { LoginPage } from '../../pages/auth/LoginPage';
     import { DashboardPage } from '../../pages/dashboard/DashboardPage';
     import { testUser } from '../../fixtures/auth-data';

     test.describe('Login Flow', () => {
       // E2E-LOGIN-001 [P0]
       test('user can log in with valid credentials and see dashboard', async ({ page }) => {
         const loginPage = new LoginPage(page);
         const dashboardPage = new DashboardPage(page);

         await loginPage.navigateTo();
         await loginPage.login(testUser.email, testUser.password);

         await expect(dashboardPage.welcomeMessage).toHaveText('Welcome, Test User');
         await expect(page).toHaveURL('/dashboard');
       });
     });
     ```
   - Example structure (Cypress):
     ```typescript
     import { LoginPage } from '../../pages/auth/LoginPage';
     import { DashboardPage } from '../../pages/dashboard/DashboardPage';
     import { testUser } from '../../fixtures/auth-data';

     describe('Login Flow', () => {
       const loginPage = new LoginPage();
       const dashboardPage = new DashboardPage();

       // E2E-LOGIN-001 [P0]
       it('user can log in with valid credentials and see dashboard', () => {
         loginPage.navigateTo();
         loginPage.login(testUser.email, testUser.password);

         dashboardPage.getWelcomeText().should('eq', 'Welcome, Test User');
         cy.url().should('include', '/dashboard');
       });
     });
     ```

   **Feature POM (`pages/{feature}/{Feature}Page.ts`):**
   - Extend BasePage (import from the base directory)
   - Constructor accepts the framework's page/browser context
   - Define ALL locators as readonly properties at the class level (never inline in methods):
     ```typescript
     // Playwright POM example
     import { Page } from '@playwright/test';
     import { BasePage } from '../base/BasePage';

     export class LoginPage extends BasePage {
       // Locators -- Tier 1 (data-testid and ARIA roles)
       readonly emailInput = this.page.getByTestId('login-email-input');
       readonly passwordInput = this.page.getByTestId('login-password-input');
       readonly submitButton = this.page.getByRole('button', { name: 'Log in' });
       readonly errorMessage = this.page.getByTestId('login-error-alert');

       // Locators -- Tier 2 (label/placeholder, only when Tier 1 unavailable)
       readonly rememberMeCheckbox = this.page.getByLabel('Remember me');

       constructor(page: Page) {
         super(page);
       }

       // Actions -- return void or next page
       async navigateTo(): Promise<void> {
         await this.page.goto('/login');
       }

       async login(email: string, password: string): Promise<void> {
         await this.emailInput.fill(email);
         await this.passwordInput.fill(password);
         await this.submitButton.click();
       }

       // State queries -- return data, NO assertions
       async getErrorText(): Promise<string> {
         return await this.errorMessage.textContent() ?? '';
       }

       async isFormVisible(): Promise<boolean> {
         return await this.emailInput.isVisible();
       }
     }
     ```
   - Cypress POM example:
     ```typescript
     import { BasePage } from '../base/BasePage';

     export class LoginPage extends BasePage {
       // Locators -- Tier 1
       readonly emailInput = '[data-testid="login-email-input"]';
       readonly passwordInput = '[data-testid="login-password-input"]';
       readonly submitButton = '[data-testid="login-submit-btn"]';
       readonly errorMessage = '[data-testid="login-error-alert"]';

       navigateTo(): void {
         cy.visit('/login');
       }

       login(email: string, password: string): void {
         cy.get(this.emailInput).type(email);
         cy.get(this.passwordInput).type(password);
         cy.get(this.submitButton).click();
       }

       getErrorText(): Cypress.Chainable<string> {
         return cy.get(this.errorMessage).invoke('text');
       }
     }
     ```
   - If Tier 1 locators not available, fall back to Tier 2 (labels, text), then Tier 3 (alt, title)
   - If forced to use Tier 4 (CSS/XPath): add `// TODO: Request test ID for this element` comment
   - POM locators are readonly properties, NOT inline strings scattered in methods
   - One POM class per page or view -- no god objects combining multiple pages

   **Fixture data file (`fixtures/{domain}-data.ts`):**
   - Export typed test data objects with realistic but fake values
   - Reference concrete_inputs from TEST_INVENTORY test cases -- these are the values tests will use
   - Use environment variables with fallbacks for any sensitive or environment-specific values
   - Organize by domain: auth fixtures in auth-data, product fixtures in product-data
   - Example structure:
     ```typescript
     // fixtures/auth-data.ts
     export const testUser = {
       email: process.env.TEST_EMAIL || 'test@example.com',
       password: process.env.TEST_PASSWORD || 'SecureP@ss123!',
       name: 'Test User',
     };

     export const adminUser = {
       email: process.env.ADMIN_EMAIL || 'admin@example.com',
       password: process.env.ADMIN_PASSWORD || 'AdminP@ss456!',
       name: 'Admin User',
       role: 'admin',
     };

     export const invalidCredentials = {
       email: 'nonexistent@example.com',
       password: 'WrongPassword123!',
     };
     ```
   - NEVER hardcode real credentials, API keys, or secrets
   - Each domain gets its own fixture file following `{domain}-data.{ext}` naming

3. **Apply CLAUDE.md standards** to every generated file:
   - Tier 1 locators preferred (data-testid, ARIA roles) -- always try these first
   - No assertions inside page objects -- page objects return data, tests make assertions
   - Concrete assertion values -- exact status codes, exact text content, exact return values
   - No vague words in assertions: "correct", "proper", "appropriate", "works" MUST have a concrete value
   - Unique test IDs following naming convention (UT-MODULE-NNN, API-RESOURCE-NNN, etc.)
   - Correct file naming convention from CLAUDE.md Naming Conventions table
   - No hardcoded credentials -- use environment variables with test fallbacks
   - Priority (P0/P1/P2) tagged on every test case as a comment

4. **Anti-pattern verification per file** (check BEFORE committing):
   - Scan the generated file for BAD assertion patterns:
     - `toBeTruthy()` without a preceding specific check -- REPLACE with `toBe(expectedValue)`
     - `toBeDefined()` alone -- REPLACE with `toBe(expectedValue)` or `toEqual(expectedObject)`
     - `.should('exist')` without content check -- ADD content assertion
   - Scan for inline locators in POM action methods -- MOVE to class-level readonly properties
   - Scan for assertions inside POM files -- MOVE to test spec files
   - Scan for hardcoded URLs -- REPLACE with environment variables
   - Scan for magic string test data -- REPLACE with fixture imports

5. **Commit one test file per commit** (per CONTEXT.md locked decision: "One test file per commit: 'test(auth): add login.e2e.spec.ts'. Maximum traceability."):
   ```bash
   node bin/qaa-tools.cjs commit "test({feature}): add {filename}" --files {file_path}
   ```

   Replace `{feature}` with the feature_group name (e.g., "auth", "product", "order").
   Replace `{filename}` with the actual filename (e.g., "login.e2e.spec.ts", "auth.unit.spec.ts").
   Replace `{file_path}` with the full path to the file.

   **Important:** Commit one file at a time. Do NOT batch multiple files in a single commit. The one-file-per-commit pattern provides maximum traceability -- every file change can be traced to a specific commit, reviewed independently, and reverted without affecting other files.

6. **Track progress:** After each task, record: task_id, files_created (with paths), commit_hash, test_case_count.
</step>

<step name="verify_output">
After all tasks are complete, verify the output is correct and complete.

**1. File existence check:**
For every file path listed in the generation plan's files_to_create fields, verify the file exists on disk:
```
[ -f "{file_path}" ] && echo "FOUND: {file_path}" || echo "MISSING: {file_path}"
```
If any file is missing, generate it now and commit.

**2. Import resolution check:**
For each generated file, verify that its imports reference files that exist:
- POM imports of BasePage: verify BasePage file exists at the import path
- E2E spec imports of POMs: verify POM files exist at the import paths
- Test spec imports of fixtures: verify fixture files exist at the import paths
- Test spec imports of source modules: verify source modules exist (these are in the DEV repo, not generated)

If any import cannot resolve to an existing file (among generated files), fix the import path and re-commit.

**3. No skipped tasks:**
Compare the list of completed tasks against the generation plan's task list. Every task must be completed. If any task was skipped, execute it now.

**4. Commit count verification:**
Count the total commits made during generation. This should approximately match the total_files count from the generation plan (one commit per file, plus the scaffold commit).
</step>

</process>

<output>
The executor agent produces multiple artifacts:

**Infrastructure (if missing):**
- `pages/base/BasePage.{ext}` -- Shared base page object (only if not already present)
- Test framework config file (only if not already present)
- Directory structure for tests, pages, fixtures

**Per-feature test files:**
- Unit test specs: `tests/unit/{feature}.unit.spec.{ext}`
- API test specs: `tests/api/{resource}.api.spec.{ext}`
- Integration test specs: `tests/integration/{feature}.integration.spec.{ext}`
- E2E smoke test specs: `tests/e2e/smoke/{feature}.e2e.spec.{ext}`
- Feature POMs: `pages/{feature}/{Feature}Page.{ext}`
- Component POMs: `pages/components/{Component}.{ext}` (if needed)
- Fixture data files: `fixtures/{domain}-data.{ext}`

All files are written to paths defined in the generation plan and follow CLAUDE.md standards.

**Return to orchestrator:**

After all tasks complete and verification passes, return these values:

```
EXECUTOR_COMPLETE:
  files_created:
    - path: "{file_path_1}"
      type: "{unit_spec|api_spec|e2e_spec|pom|fixture|config}"
    - path: "{file_path_2}"
      type: "{type}"
    [... one entry per file created ...]
  total_files: {N}
  commit_count: {N}
  features_covered:
    - "{feature_1}"
    - "{feature_2}"
    [... one entry per feature group ...]
  test_case_count: {N}
```
</output>

<quality_gate>
Before considering the executor's work complete, verify ALL of the following.

**From CLAUDE.md Quality Gates (verbatim):**

- [ ] Every test case has an explicit expected outcome with a concrete value
- [ ] No outcome says "correct", "proper", "appropriate", or "works" without defining what that means
- [ ] All locators follow the tier hierarchy (Tier 1 preferred: data-testid, ARIA roles)
- [ ] No assertions inside page objects (assertions belong ONLY in test specs)
- [ ] No hardcoded credentials (use environment variables with test fallbacks)
- [ ] File naming follows the project's existing conventions (or CLAUDE.md standards if none exist)
- [ ] Test IDs are unique and follow naming convention (UT-MODULE-NNN, API-RESOURCE-NNN, E2E-FLOW-NNN)
- [ ] Priority assigned to every test case (P0, P1, or P2)
- [ ] Framework matches what the project already uses

**Additional executor-specific checks:**

- [ ] All planned files exist on disk (every file_path from generation plan verified)
- [ ] Imports resolve (no broken references between generated files)
- [ ] BasePage check performed before creating one (only if missing -- extends existing if found)
- [ ] One commit per test file (not batch commits -- each file has its own commit)
- [ ] Framework config matches detected or user-specified framework
- [ ] POM locators are readonly properties, not inline strings in methods
- [ ] POM actions return void or next page (no other return types)
- [ ] POM state queries return data (no assertions inside queries)
- [ ] Every POM extends BasePage (or the project's existing shared base)
- [ ] Tier 1 locators used wherever possible (data-testid, getByRole)
- [ ] Tier 4 locators (CSS/XPath) have `// TODO: Request test ID for this element` comment
- [ ] Unit tests use Arrange/Act/Assert pattern
- [ ] API tests verify exact status code AND response body fields
- [ ] E2E tests follow user journey steps from TEST_INVENTORY
- [ ] Fixture data uses realistic fake data (no real credentials, no generic placeholders)
- [ ] Commit messages follow `test({feature}): add {filename}` format
- [ ] No generated file references a non-existent import

If any check fails, fix the issue before returning EXECUTOR_COMPLETE. Do not proceed with a failing quality gate.
</quality_gate>

<success_criteria>
The executor agent has completed successfully when:

1. All planned files from the generation plan exist on disk at their assigned paths
2. Every file was committed individually with message format `test({feature}): add {filename}` via `node bin/qaa-tools.cjs commit`
3. BasePage check was performed -- created only if missing, extended existing if found
4. All imports between generated files resolve correctly (POM -> BasePage, E2E spec -> POM, spec -> fixture)
5. Every generated test file follows CLAUDE.md standards:
   - Tier 1 locators preferred (data-testid, ARIA roles)
   - No assertions in page objects
   - Concrete assertion values (exact status codes, exact response fields, exact text content)
   - Unique test IDs following naming convention
   - Priority tagged on every test case
6. Every POM follows all 6 POM rules from CLAUDE.md
7. No hardcoded credentials in any file (environment variables with fallbacks used instead)
8. All quality gate checks pass
9. Return values provided to orchestrator: files_created, total_files, commit_count, features_covered, test_case_count
</success_criteria>
