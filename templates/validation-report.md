---
template_name: validation-report
version: "1.0"
artifact_type: validation
produces: VALIDATION_REPORT.md
producer_agent: qa-validator
consumer_agents:
  - qa-bug-detective
  - human-reviewer
required_sections:
  - summary
  - file-details
  - unresolved-issues
  - fix-loop-log
  - confidence-level
example_domain: shopflow
---

# VALIDATION_REPORT.md Template

**Purpose:** Documents the results of 4-layer validation (Syntax, Structure, Dependencies, Logic) applied to generated test code. Tracks what was found, what was auto-fixed, what remains unresolved, and the overall confidence that the test suite is ready for delivery.

**Producer:** qa-validator (runs after test code generation, before delivery)
**Consumers:** qa-bug-detective (uses validation results to focus failure investigation), human-reviewer (reviews overall quality and unresolved issues)

---

## Required Sections

### Section 1: Summary

**Description:** High-level overview of validation results across all 4 layers, aggregated across all validated files.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Layer | enum | YES | Syntax, Structure, Dependencies, or Logic |
| Status | enum | YES | PASS or FAIL (final status after fix loops) |
| Issues Found | integer | YES | Total issues discovered in this layer |
| Issues Fixed | integer | YES | Issues auto-fixed during fix loops |

Additional summary fields:
- Total files validated
- Total issues found (across all layers)
- Total issues fixed
- Fix loops used (1, 2, or 3)
- Overall status (PASS / PASS WITH WARNINGS / FAIL)

---

### Section 2: File Details

**Description:** Per-file breakdown showing every validation layer's result. Each validated file gets its own subsection with a table showing all 4 layers.

**Fields per file:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Filename | path | YES | Full relative path to the validated file |
| Layer | enum | YES | Syntax, Structure, Dependencies, or Logic |
| Status | enum | YES | PASS or FAIL |
| Details | text | YES | What passed, what failed, specific error messages. Never just "PASS" or "FAIL" without context. |

**Rule:** Report EVERY layer for EVERY file, even if all layers pass. A file with all PASS still shows 4 rows in its table.

---

### Section 3: Unresolved Issues

**Description:** Issues that could NOT be auto-fixed after the maximum 3 fix loops. Each unresolved issue gets detailed documentation to help human reviewers understand what went wrong and what to do about it.

**Fields per unresolved issue:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| File | path | YES | Path to the affected file |
| Layer | enum | YES | Which validation layer detected the issue |
| Issue Description | text | YES | What the issue is, in specific terms |
| Attempted Fix | text | YES | What auto-fix was tried (or "No fix attempted" if issue type is not auto-fixable) |
| Why It Failed | text | YES | Why the auto-fix did not resolve the issue |
| Suggested Resolution | text | YES | What a human should do to resolve this |

If there are no unresolved issues, this section states: **"None -- all issues resolved within fix loops."**

---

### Section 4: Fix Loop Log

**Description:** Chronological record of each fix loop iteration showing progressive issue resolution. Essential for debugging validation failures and understanding the auto-fix progression.

**Fields per loop:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Loop Number | integer | YES | 1, 2, or 3 |
| Issues Found | integer | YES | How many issues were detected in this loop |
| Issues Description | text | YES | What specific issues were found |
| Fixes Applied | text | YES | What fixes were applied |
| Verification Result | text | YES | Did the fixes resolve the issues? What remains? |

---

### Section 5: Confidence Level

**Description:** Overall confidence assessment that the validated test code is ready for delivery. Based on quantitative criteria, not subjective judgment.

**Confidence Criteria Table:**

| Level | All Layers PASS | Unresolved Issues | Fix Loops Used | Description |
|-------|----------------|-------------------|----------------|-------------|
| HIGH | Yes | 0 | 0-1 | All validations pass with minimal or no fixes needed. Code is ready for delivery. |
| MEDIUM | Yes (after fixes) | 0-2 minor | 2-3 | All layers eventually pass, but required multiple fix rounds. Minor issues may exist. |
| LOW | No (any FAIL) | Any critical | 3 (max) | At least one layer still fails, or critical issues remain unresolved. Human review required before delivery. |

**Confidence statement format:** `[LEVEL]: [one-sentence reasoning referencing specific metrics from the summary]`

---

## Worked Example (ShopFlow E-Commerce API)

Below is a complete, filled VALIDATION_REPORT.md for ShopFlow test code validation.

---

# Validation Report

**Generated:** 2026-03-18T14:30:00Z
**Validator:** qa-validator v1.0
**Target:** shopflow-qa-tests (4 files)

## Summary

| Layer | Status | Issues Found | Issues Fixed |
|-------|--------|-------------|-------------|
| Syntax | PASS | 0 | 0 |
| Structure | PASS | 1 | 1 |
| Dependencies | PASS | 0 | 0 |
| Logic | PASS | 2 | 2 |

- **Total files validated:** 4
- **Total issues found:** 3
- **Total issues fixed:** 3
- **Fix loops used:** 2
- **Overall status:** PASS

## File Details

### tests/unit/priceCalculator.unit.spec.ts

| Layer | Status | Details |
|-------|--------|---------|
| Syntax | PASS | TypeScript compilation clean (`tsc --noEmit` exit 0). No ESLint errors. |
| Structure | PASS | Correct directory placement (`tests/unit/`). Naming follows convention (`*.unit.spec.ts`). Contains 4 test functions in 2 describe blocks. No hardcoded credentials. |
| Dependencies | PASS | All imports resolve: `priceCalculator` found at `src/utils/priceCalculator.ts`. No external packages needed beyond `@playwright/test`. |
| Logic | PASS | All 4 tests have concrete assertions (`toBe(89.97)`, `toBe(215.52)`). Happy path tests use `toBe`/`toEqual`. No vague assertions (no `toBeTruthy()` or `toBeDefined()`). Each test has at least one assertion. |

### tests/api/orders.api.spec.ts

| Layer | Status | Details |
|-------|--------|---------|
| Syntax | PASS | TypeScript compilation clean. No ESLint errors. |
| Structure | PASS | **Fixed in Loop 1.** Originally placed in `tests/e2e/` directory. Moved to `tests/api/` per naming convention (file is `*.api.spec.ts`, must be in `tests/api/`). After fix: correct placement, naming compliant. |
| Dependencies | PASS | All imports resolve. `auth-data` fixture found at `fixtures/auth-data.ts`. API client uses `request` from `@playwright/test`. |
| Logic | PASS | **Fixed in Loop 1.** Original test at line 34 had vague assertion: `expect(response.status).toBeTruthy()`. Fixed to: `expect(response.status).toBe(201)`. All 6 tests now have concrete assertions with specific values. |

### pages/auth/LoginPage.ts

| Layer | Status | Details |
|-------|--------|---------|
| Syntax | PASS | TypeScript compilation clean. No ESLint errors. |
| Structure | PASS | Correct directory placement (`pages/auth/`). Naming follows convention (`*Page.ts`). Extends BasePage. No assertions in page object (verified: 0 `expect()` calls). |
| Dependencies | PASS | All imports resolve. `BasePage` found at `pages/base/BasePage.ts`. Playwright `Page` and `Locator` types imported correctly. |
| Logic | PASS | All locators use Tier 1 selectors (`getByTestId`, `getByRole`). Actions return `void` or navigation promises. State query methods (`getErrorMessage()`, `isSubmitEnabled()`) return data without asserting. |

### tests/e2e/smoke/checkout.e2e.spec.ts

| Layer | Status | Details |
|-------|--------|---------|
| Syntax | PASS | TypeScript compilation clean. No ESLint errors. |
| Structure | PASS | Correct directory placement (`tests/e2e/smoke/`). Naming follows convention (`*.e2e.spec.ts`). Contains 3 test functions. No hardcoded credentials (uses `process.env` for test user). |
| Dependencies | PASS | All imports resolve. Page objects (`CartPage`, `CheckoutPage`, `LoginPage`) found at expected paths. Fixtures import resolves. |
| Logic | PASS | **Fixed in Loop 2.** Missing `await` on `page.click('[data-testid="checkout-submit-btn"]')` at line 45. Added `await` keyword. After fix: all async operations properly awaited. All assertions concrete (`toHaveText('Order confirmed')`, `toBeVisible()`). |

## Unresolved Issues

None -- all issues resolved within 2 fix loops.

## Fix Loop Log

### Loop 1

- **Issues found:** 2
  1. `tests/api/orders.api.spec.ts` placed in wrong directory (`tests/e2e/` instead of `tests/api/`)
  2. `tests/api/orders.api.spec.ts:34` has vague assertion: `expect(response.status).toBeTruthy()`
- **Fixes applied:**
  1. Moved file from `tests/e2e/orders.api.spec.ts` to `tests/api/orders.api.spec.ts`
  2. Changed assertion to `expect(response.status).toBe(201)` (verified against API spec: POST /orders returns 201)
- **Verification result:** Both fixes verified. Structure layer now PASS. Logic layer still has 1 remaining issue found in re-validation.

### Loop 2

- **Issues found:** 1
  1. `tests/e2e/smoke/checkout.e2e.spec.ts:45` missing `await` on `page.click()` call
- **Fixes applied:**
  1. Added `await` keyword: `await page.click('[data-testid="checkout-submit-btn"]')`
- **Verification result:** Fix verified. All 4 layers PASS across all 4 files. No remaining issues.

## Confidence Level

**HIGH:** All 4 validation layers pass across all 4 files. 3 issues were found and all 3 were auto-fixed within 2 fix loops. No unresolved issues. No guesses were made in fixes -- each fix was verified against project standards (directory convention, API spec, async requirements).

---

## Guidelines

**DO:**
- Report EVERY layer for EVERY file, even if all layers pass -- omitting passing layers makes it impossible to confirm they were actually checked
- Include the specific error message or code snippet in file details, not just "FAIL" -- reviewers need to understand what failed
- Show the before/after in fix loop entries -- what was the original issue and what was the fix
- Run verification AFTER each fix loop to confirm fixes work -- do not assume a fix resolves the issue
- Include timestamps and validator version in the report header for traceability

**DON'T:**
- Mark confidence HIGH if any fix was a guess or unverified -- confidence requires verified fixes
- Skip the fix loop log even if all layers pass on first check -- report "Loop 1: 0 issues found" to prove validation ran
- Combine multiple files into a single file details entry -- each file gets its own subsection
- Report Logic as PASS when assertions use `toBeTruthy()`, `toBeDefined()`, or `.should('exist')` without a concrete value -- these are vague assertions per CLAUDE.md standards
- Auto-fix more than 3 loops -- after 3 loops, document unresolved issues and deliver with LOW confidence

---

## Quality Gate

Before delivering a VALIDATION_REPORT.md, verify:

- [ ] All 5 required sections are present (Summary, File Details, Unresolved Issues, Fix Loop Log, Confidence Level)
- [ ] Summary table shows all 4 layers (Syntax, Structure, Dependencies, Logic) with counts
- [ ] Every validated file has its own File Details subsection with all 4 layers reported
- [ ] Unresolved Issues section is present (either with issues or "None" statement)
- [ ] Fix Loop Log documents every loop iteration with issues found, fixes applied, and verification result
- [ ] Confidence Level includes the criteria table and a specific confidence statement with reasoning
- [ ] No file details entry says just "PASS" or "FAIL" without explanatory details
