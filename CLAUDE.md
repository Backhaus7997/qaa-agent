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

**Tier 1 -- BEST (always try these first):**
- Test IDs: `data-testid`, `data-cy`, `data-test` (adapt to framework)
- Semantic roles: ARIA roles + accessible name

**Tier 2 -- GOOD (when Tier 1 not available):**
- Form labels, placeholders, visible text content

**Tier 3 -- ACCEPTABLE (when Tier 1-2 not available):**
- Alt text, title attributes

**Tier 4 -- LAST RESORT (always add a TODO comment):**
- CSS selectors, XPath -- mark with `// TODO: Request test ID for this element`

### Framework-Specific Examples

**Playwright:**
```typescript
page.getByTestId('submit')           // Tier 1
page.getByRole('button', {name: 'Log in'})  // Tier 1
page.getByLabel('Email')             // Tier 2
page.locator('.btn')                 // Tier 4 -- add TODO
```

**Cypress:**
```typescript
cy.get('[data-cy="submit"]')         // Tier 1
cy.findByRole('button', {name: 'Log in'})  // Tier 1 (with testing-library)
cy.get('[data-testid="submit"]')     // Tier 1
cy.contains('Submit')                // Tier 2
cy.get('.btn')                       // Tier 4 -- add TODO
```

**Selenium / other:**
```
driver.findElement(By.cssSelector('[data-testid="submit"]'))  // Tier 1
driver.findElement(By.className('btn'))  // Tier 4 -- add TODO
```

## Page Object Model Rules

These rules apply regardless of framework:

1. **One class/object per page or view** -- no god objects
2. **No assertions in page objects** -- assertions belong ONLY in test specs
3. **Locators are properties** -- defined in constructor or as class fields
4. **Actions return void or the next page** -- for fluent chaining
5. **State queries return data** -- let the test file decide what to assert
6. **Every POM extends a shared base** -- shared navigation, screenshots, waits

### POM File Structure
```
[pages or page-objects or support/page-objects]/
  base/
    BasePage.[ext]       -- shared methods
  [feature]/
    [Feature]Page.[ext]  -- one file per page
  components/
    [Component].[ext]    -- reusable UI components
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

Recommended structure -- adapt to match what the project already has:

```
tests/ or cypress/ or __tests__/
  e2e/
    smoke/              # P0 critical path (every PR)
    regression/         # Full suite (nightly)
  api/                    # API-level tests
  unit/                   # Unit tests

pages/ or page-objects/ or support/page-objects/
  base/
  [feature]/
  components/

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
- Organized by pyramid level (unit -> integration -> API -> E2E)
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

---

## Agent Pipeline

The QA automation system runs agents in a defined pipeline. Each stage produces artifacts consumed by the next stage.

### Pipeline Stages

```
scan -> analyze -> [testid-inject if frontend] -> plan -> generate -> validate -> deliver
```

### Workflow Options

**Option 1: Dev-Only Repo (no existing QA repo)**
Full pipeline from scratch:
```
scan -> analyze -> [testid-inject if frontend] -> plan -> generate -> validate -> deliver
```
Produces: SCAN_MANIFEST.md -> QA_ANALYSIS.md + TEST_INVENTORY.md + QA_REPO_BLUEPRINT.md -> [TESTID_AUDIT_REPORT.md] -> generation plan -> test files + POMs + fixtures + configs -> VALIDATION_REPORT.md -> branch + PR

**Option 2: Dev + Immature QA Repo (existing QA repo with low coverage or quality)**
Gap-fill and standardize:
```
scan both repos -> gap analysis -> fix broken tests -> add missing coverage -> standardize existing -> validate -> deliver
```
Produces: SCAN_MANIFEST.md (both repos) -> GAP_ANALYSIS.md -> fixed test files -> new test files -> standardized files -> VALIDATION_REPORT.md -> branch + PR

**Option 3: Dev + Mature QA Repo (existing QA repo with solid coverage)**
Surgical additions only:
```
scan both repos -> identify thin coverage -> add only missing tests -> validate -> deliver
```
Produces: SCAN_MANIFEST.md (both repos) -> GAP_ANALYSIS.md (thin areas only) -> new test files (targeted) -> VALIDATION_REPORT.md -> branch + PR

### Stage Transitions

| From | To | Condition |
|------|----|-----------|
| scan | analyze | SCAN_MANIFEST.md exists with > 0 testable surfaces |
| analyze | testid-inject | QA_ANALYSIS.md exists AND frontend components detected |
| analyze | plan | QA_ANALYSIS.md + TEST_INVENTORY.md exist (skip testid-inject if no frontend) |
| testid-inject | plan | TESTID_AUDIT_REPORT.md exists with coverage score calculated |
| plan | generate | Generation plan approved (or auto-approved in auto-advance mode) |
| generate | validate | All planned test files exist on disk |
| validate | deliver | VALIDATION_REPORT.md shows PASS or max fix loops (3) exhausted |

---

## Module Boundaries

Each agent owns specific artifacts. No agent may produce artifacts assigned to another agent.

| Agent | Reads | Produces | Template |
|-------|-------|----------|----------|
| qa-scanner | repo source files, package.json, file tree | SCAN_MANIFEST.md | templates/scan-manifest.md |
| qa-analyzer | SCAN_MANIFEST.md, CLAUDE.md | QA_ANALYSIS.md, TEST_INVENTORY.md, QA_REPO_BLUEPRINT.md (Option 1) or GAP_ANALYSIS.md (Option 2/3) | templates/qa-analysis.md, templates/test-inventory.md, templates/qa-repo-blueprint.md, templates/gap-analysis.md |
| qa-planner | TEST_INVENTORY.md, QA_ANALYSIS.md | Generation plan (internal) | -- |
| qa-executor | TEST_INVENTORY.md, CLAUDE.md | test files, POMs, fixtures, configs | qa-template-engine patterns |
| qa-validator | generated test files, CLAUDE.md | VALIDATION_REPORT.md (validation mode) or QA_AUDIT_REPORT.md (audit mode) | templates/validation-report.md, templates/qa-audit-report.md |
| qa-testid-injector | repo source files, SCAN_MANIFEST.md, CLAUDE.md | TESTID_AUDIT_REPORT.md, modified source files with data-testid attributes | templates/scan-manifest.md, templates/testid-audit-report.md |
| qa-bug-detective | test execution results, test source files, CLAUDE.md | FAILURE_CLASSIFICATION_REPORT.md | templates/failure-classification.md |

**Rule:** An agent MUST NOT produce artifacts assigned to another agent.

**Rule:** An agent MUST read all artifacts listed in its "Reads" column before producing output.

---

## Verification Commands

Every artifact must pass verification before the pipeline advances. Below are the validation rules per artifact type.

### SCAN_MANIFEST.md
- Has > 0 files in File List table
- Project Detection section is populated (framework, language, component patterns)
- Testable Surfaces has at least 1 category with entries
- File priority ordering is present (HIGH/MEDIUM/LOW)

### QA_ANALYSIS.md
- All 6 sections present: Architecture Overview, External Dependencies, Risk Assessment, Top 10 Unit Test Targets, API/Contract Test Targets, Recommended Testing Pyramid
- Top 10 has exactly 10 entries with module, rationale, and complexity
- Testing pyramid percentages sum to 100%
- Risk assessment uses only HIGH/MEDIUM/LOW with justification per item

### TEST_INVENTORY.md
- Every test case has all mandatory fields: ID, target, inputs, expected outcome, priority
- IDs are unique across the entire document (no duplicates)
- IDs follow naming convention: UT-MODULE-NNN, INT-MODULE-NNN, API-RESOURCE-NNN, E2E-FLOW-NNN
- Pyramid tier counts match the summary table
- No expected outcome says "correct", "proper", "appropriate", or "works" without concrete value

### QA_REPO_BLUEPRINT.md
- Folder structure tree is present with explanations per directory
- Config files section has actual content (not placeholders)
- npm scripts defined for smoke, regression, and API test runs
- CI/CD strategy section includes PR-gate and nightly run configurations
- Definition of Done checklist is present

### VALIDATION_REPORT.md
- All 4 layers reported per file: Syntax, Structure, Dependencies, Logic
- Each layer shows PASS or FAIL with details
- Confidence level assigned: HIGH (all layers pass), MEDIUM (1-2 minor issues), LOW (structural problems)
- Fix loop log shows iteration count and what was found/fixed per loop
- Unresolved issues section documents anything not auto-fixed

### FAILURE_CLASSIFICATION_REPORT.md
- Every failure has classification: APPLICATION BUG, TEST CODE ERROR, ENVIRONMENT ISSUE, or INCONCLUSIVE
- Every failure has confidence level: HIGH, MEDIUM-HIGH, MEDIUM, or LOW
- Every failure has evidence: code snippet + reasoning explaining the classification
- No APPLICATION BUG is marked as auto-fixed (application bugs require developer action)
- Auto-fix log documents what was fixed and at what confidence level

### TESTID_AUDIT_REPORT.md
- Coverage score calculated: existing data-testid count / total interactive elements
- All proposed data-testid values follow `{context}-{description}-{element-type}` naming convention
- No duplicate data-testid values within the same page/route scope
- Elements classified by priority: P0 (form inputs, buttons), P1 (links, images), P2 (containers, decorative)
- Decision gate threshold applied: >90% SELECTIVE, 50-90% TARGETED, <50% FULL PASS, 0% P0 FIRST

### GAP_ANALYSIS.md
- Coverage map shows all modules from SCAN_MANIFEST.md
- Missing tests have IDs following naming convention and priorities assigned
- Broken tests have failure reasons documented with file path and error
- Quality assessment includes locator tier distribution and assertion quality rating
- Recommendations are prioritized: fix broken first, then add P0, then P1

### QA_AUDIT_REPORT.md
- All 6 dimensions scored: Locator Quality, Assertion Specificity, POM Compliance, Test Coverage, Naming Convention, Test Data Management
- Weights sum to 100%: Locator 20%, Assertion 20%, POM 15%, Coverage 20%, Naming 15%, Test Data 10%
- Overall score matches weighted calculation of dimension scores
- Critical issues listed with file path, line number, and description
- Each recommendation has effort estimate: S (small), M (medium), L (large)

---

## Git Workflow

All QA automation output follows these git conventions.

### Branch Naming

```
qa/auto-{project}-{date}
```

Examples:
- `qa/auto-shopflow-2026-03-18`
- `qa/auto-acme-api-2026-04-01`

### Commit Message Format

```
qa({agent}): {description}
```

Examples:
- `qa(scanner): produce SCAN_MANIFEST.md for shopflow`
- `qa(analyzer): produce QA_ANALYSIS.md and TEST_INVENTORY.md`
- `qa(executor): generate 24 test files with POMs and fixtures`
- `qa(validator): validate generated tests - PASS with HIGH confidence`
- `qa(testid-injector): inject 47 data-testid attributes across 12 components`
- `qa(bug-detective): classify 5 failures - 2 APP BUG, 2 TEST ERROR, 1 ENV ISSUE`

### Commit Conventions

- One commit per agent stage (scanner produces one commit, analyzer produces one commit, etc.)
- Descriptive messages that include artifact names and counts
- Never commit .env files, credentials, or secrets
- Include modified file count in commit body when relevant

### PR Template

PR description must include:
- Analysis summary (architecture type, framework, risk areas)
- Test counts by pyramid level (unit: N, integration: N, API: N, E2E: N)
- Coverage metrics (modules covered, estimated line coverage)
- Validation pass/fail status with confidence level
- Link to VALIDATION_REPORT.md in the PR files

---

## Team Settings

Configuration for multi-agent pipeline execution.

### Concurrent Execution

Agents in the same pipeline stage can run in parallel when their inputs are independent. Examples:
- qa-testid-injector and qa-analyzer can run simultaneously after scan completes (both read SCAN_MANIFEST.md)
- Multiple qa-executor instances can generate tests for different modules in parallel

Agents in different pipeline stages MUST respect stage ordering. A downstream agent cannot start until all its required inputs exist on disk.

### Worktree Isolation

Each agent operates on the same branch. No worktree splits are needed for this system. Agents coordinate through file-based artifacts -- each agent writes its own files and reads other agents' files.

### Dependency Ordering

Respect stage transitions from the Agent Pipeline section:
1. qa-scanner runs first (no dependencies)
2. qa-analyzer and qa-testid-injector run after scanner (both depend on SCAN_MANIFEST.md)
3. qa-planner runs after analyzer (depends on QA_ANALYSIS.md + TEST_INVENTORY.md)
4. qa-executor runs after planner (depends on generation plan)
5. qa-validator runs after executor (depends on generated test files)
6. qa-bug-detective runs after test execution (depends on test results)

### Auto-Advance Mode

When auto-advance is enabled, pipeline stages advance automatically when:
1. The previous stage completes
2. All output artifacts from the previous stage exist on disk
3. All output artifacts pass their verification commands (from Verification Commands section)

No human confirmation is needed between stages in auto-advance mode. The pipeline pauses only at explicit checkpoint tasks or when verification fails.

---

## Agent Coordination

Rules governing how agents communicate and hand off work through artifacts.

### Read-Before-Write Rules

Every agent MUST read its required inputs before producing any output. Failure to read inputs produces low-quality, inconsistent artifacts.

| Agent | MUST Read Before Producing Output |
|-------|-----------------------------------|
| qa-scanner | package.json (or equivalent), folder tree structure, all source file extensions to detect framework and language |
| qa-analyzer | SCAN_MANIFEST.md (complete, verified), CLAUDE.md (all QA standards sections) |
| qa-planner | TEST_INVENTORY.md (all test cases), QA_ANALYSIS.md (architecture and risk context) |
| qa-executor | TEST_INVENTORY.md (test cases to implement), CLAUDE.md (POM rules, locator hierarchy, assertion rules, naming conventions, quality gates) |
| qa-validator | CLAUDE.md (quality gates, locator tiers, assertion rules), all generated test files to validate |
| qa-testid-injector | SCAN_MANIFEST.md (component file list), CLAUDE.md (data-testid Convention section for naming rules) |
| qa-bug-detective | Test execution output (stdout/stderr, exit codes), test source files (to read the failing code), CLAUDE.md (classification rules) |

### Handoff Patterns

Agents communicate exclusively through file-based artifacts:

1. **Producer writes** -- Agent completes its task and writes output artifact(s) to disk
2. **Pipeline verifies** -- Output artifacts pass verification commands before advancing
3. **Consumer reads** -- Next agent reads the artifact(s) as its first action
4. **No direct communication** -- Agents never pass data in memory or through environment variables between stages

### Quality Gates Per Artifact

Before the pipeline advances past any stage, the produced artifact(s) must pass verification:

| Stage Complete | Artifact | Gate |
|----------------|----------|------|
| scan | SCAN_MANIFEST.md | > 0 files listed, project detection populated |
| analyze | QA_ANALYSIS.md + TEST_INVENTORY.md | All sections present, IDs unique, pyramid sums to 100% |
| testid-inject | TESTID_AUDIT_REPORT.md | Coverage score calculated, naming convention compliant |
| plan | Generation plan | Test cases mapped to output files, no unassigned cases |
| generate | Test files + POMs | All planned files exist, imports resolve, syntax valid |
| validate | VALIDATION_REPORT.md | All 4 layers checked per file, confidence level assigned |
| deliver | Branch + PR | Branch pushed, PR created with required description sections |

### Error Recovery

If an agent fails or produces an artifact that does not pass verification:
1. Log the failure with the specific verification check that failed
2. Retry the agent (max 3 attempts per stage)
3. If still failing after 3 attempts, pause the pipeline and report the blocked stage
4. Do not advance to the next stage with a failed artifact

---

## data-testid Convention

All `data-testid` attributes injected by qa-testid-injector and referenced by generated tests MUST follow this naming convention.

### Naming Pattern

```
{context}-{description}-{element-type}
```

All values are **kebab-case**. No camelCase, no underscores, no periods.

### Context Derivation

1. **Page-level context**: Derived from the component filename or route
   - `LoginPage.tsx` -> context is `login`
   - `ProductDetailPage.tsx` -> context is `product-detail`
   - Route `/settings/profile` -> context is `settings-profile`

2. **Component-level context**: Derived from the component name
   - `<NavBar>` -> context is `navbar`
   - `<ShoppingCart>` -> context is `shopping-cart`
   - `<UserAvatar>` -> context is `user-avatar`

3. **Nested context**: Parent-child hierarchy, max 3 levels deep
   - `checkout-shipping-address-input` (page -> section -> field)
   - `dashboard-sidebar-nav-link` (page -> component -> element)
   - Never exceed 3 levels: `a-b-c-element` is the maximum depth

4. **Dynamic list items**: Use template literals with unique keys
   ```tsx
   data-testid={`product-${product.id}-card`}
   data-testid={`order-${order.id}-status-badge`}
   ```

### Element Type Suffix Table

Every `data-testid` value ends with a suffix indicating the element type:

| Element | Suffix | Example |
|---------|--------|---------|
| `<button>` | `-btn` | `login-submit-btn` |
| `<input>` | `-input` | `login-email-input` |
| `<select>` | `-select` | `settings-language-select` |
| `<textarea>` | `-textarea` | `feedback-comment-textarea` |
| `<a>` (link) | `-link` | `navbar-profile-link` |
| `<form>` | `-form` | `checkout-payment-form` |
| `<img>` | `-img` | `product-hero-img` |
| `<table>` | `-table` | `users-list-table` |
| `<tr>` (row) | `-row` | `users-item-row` |
| `<dialog>/<modal>` | `-modal` | `confirm-delete-modal` |
| `<div>` container | `-container` | `dashboard-stats-container` |
| `<ul>/<ol>` list | `-list` | `notifications-list` |
| `<li>` item | `-item` | `notifications-item` |
| dropdown menu | `-dropdown` | `navbar-user-dropdown` |
| tab | `-tab` | `settings-security-tab` |
| checkbox | `-checkbox` | `terms-accept-checkbox` |
| radio | `-radio` | `shipping-express-radio` |
| toggle/switch | `-toggle` | `notifications-enabled-toggle` |
| badge/chip | `-badge` | `cart-count-badge` |
| alert/toast | `-alert` | `error-validation-alert` |

### Third-Party Component Handling

When adding `data-testid` to third-party UI library components, use this priority order:

1. **Props passthrough** (preferred): If the library supports passing `data-testid` directly as a prop
   ```tsx
   <MuiButton data-testid="checkout-pay-btn">Pay</MuiButton>
   ```

2. **Wrapper div**: If the library does not support prop passthrough, wrap with a `<div>` that has the `data-testid`
   ```tsx
   <div data-testid="checkout-pay-container">
     <ThirdPartyButton>Pay</ThirdPartyButton>
   </div>
   ```

3. **inputProps / slotProps** (MUI-specific): Use component-specific prop APIs
   ```tsx
   <TextField inputProps={{ 'data-testid': 'login-email-input' }} />
   <Autocomplete slotProps={{ input: { 'data-testid': 'search-query-input' } }} />
   ```
