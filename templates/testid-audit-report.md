---
template_name: testid-audit-report
version: "1.0"
artifact_type: audit
produces: TESTID_AUDIT_REPORT.md
producer_agent: qa-testid-injector
consumer_agents:
  - qa-executor
  - human-reviewer
required_sections:
  - summary
  - coverage-score
  - file-details
  - naming-convention-compliance
  - decision-gate
example_domain: shopflow
---

# TESTID_AUDIT_REPORT.md Template

**Purpose:** Audit of `data-testid` coverage across frontend component files, identifying interactive elements that lack stable test selectors and proposing injection values following a consistent naming convention.

**Producer:** `qa-testid-injector` (Phase 2: AUDIT step)
**Consumers:** `qa-executor` (uses proposed test IDs when writing E2E tests), `human-reviewer` (reviews proposed values before injection)

---

## Required Sections

### Section 1: Summary

**Description:** High-level counts of scanned files, interactive elements found, and breakdown of missing `data-testid` attributes by priority.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| files_scanned | integer | YES | Total number of component files scanned |
| total_interactive_elements | integer | YES | Total interactive elements found across all files |
| elements_with_testid | integer | YES | Elements that already have a `data-testid` attribute |
| elements_missing_testid | integer | YES | Elements that need a `data-testid` injected |
| p0_missing | integer | YES | P0 (must have): form inputs, submit buttons, primary actions |
| p1_missing | integer | YES | P1 (should have): navigation links, secondary actions, feedback elements |
| p2_missing | integer | YES | P2 (nice to have): decorative images, static containers showing dynamic data |

**Priority Definitions:**

| Priority | Label | Elements |
|----------|-------|----------|
| P0 | Must Have | Form `<input>`, `<select>`, `<textarea>`, submit `<button>`, primary action buttons, `<form>` tags |
| P1 | Should Have | Navigation `<a>` links, secondary buttons, error/alert messages, toggle/checkbox/radio |
| P2 | Nice to Have | Images showing product data, badges, decorative containers with dynamic content |

---

### Section 2: Coverage Score

**Description:** Quantified coverage percentage with interpretation and projected post-injection score.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| current_coverage | percentage | YES | `elements_with_testid / total_interactive_elements * 100` |
| projected_coverage | percentage | YES | Coverage percentage after all proposed injections are applied |
| score_interpretation | string | YES | One of: EXCELLENT, GOOD, NEEDS WORK, CRITICAL |

**Formula:**
```
Current Coverage = (elements_with_testid / total_interactive_elements) * 100
Projected Coverage = ((elements_with_testid + elements_missing_testid) / total_interactive_elements) * 100
```

**Interpretation Thresholds:**

| Score Range | Interpretation | Meaning |
|-------------|---------------|---------|
| > 90% | EXCELLENT | Most elements already have test IDs; selective injection only |
| 50% - 90% | GOOD | Decent baseline; targeted injection pass needed |
| 1% - 49% | NEEDS WORK | Significant gaps; full injection pass required |
| 0% | CRITICAL | No test IDs exist; P0-first strategy recommended |

---

### Section 3: File Details

**Description:** Per-component file audit showing every interactive element, its current selector state, and the proposed `data-testid` value.

**Per-File Structure:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| file_path | string | YES | Full path to the component file |
| component_name | string | YES | Name of the React/Vue/Angular component |
| element_count | integer | YES | Total interactive elements in this file |

**Per-Element Table Columns:**

| Column | Description |
|--------|-------------|
| Line | Line number in the source file where the element appears |
| Element | HTML tag and type (e.g., `<input type="email">`, `<button type="submit">`) |
| Current Selector | What exists now: `data-testid="value"`, `className="..."`, `name="..."`, or `none` |
| Proposed data-testid | The proposed value following `{context}-{description}-{element-type}` convention, or `EXISTING -- no change` if already has a `data-testid` |
| Priority | P0, P1, or P2 |

**Rules:**
- Elements with an EXISTING `data-testid` are marked `EXISTING -- no change` and are never modified
- Elements missing `data-testid` receive a proposed value following `{context}-{description}-{element-type}` naming convention
- Context is derived from the component filename (e.g., `LoginPage.tsx` -> `login`, `CheckoutForm.tsx` -> `checkout`)

---

### Section 4: Naming Convention Compliance

**Description:** Audit of existing `data-testid` values against the `{context}-{description}-{element-type}` naming pattern.

**Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| total_existing | integer | YES | Count of elements with existing `data-testid` |
| compliant_count | integer | YES | Count that follow the naming convention |
| non_compliant_count | integer | YES | Count that violate the naming convention |

**Per-Value Table Columns:**

| Column | Description |
|--------|-------------|
| Existing Value | The current `data-testid` value |
| Compliant | YES or NO |
| Issue | If non-compliant: what is wrong (e.g., "missing element-type suffix", "camelCase instead of kebab-case") |
| Suggested Rename | If non-compliant: the corrected value following convention |

**Convention Rules:**
- All values MUST be kebab-case: `login-submit-btn`, never `loginSubmitBtn` or `login_submit_btn`
- All values MUST end with an element-type suffix: `-btn`, `-input`, `-link`, `-form`, `-img`, etc.
- All values MUST start with a context prefix derived from the component name
- No framework-specific prefixes: no `cy-`, `pw-`, `qa-` prefixes

---

### Section 5: Decision Gate

**Description:** Automated recommendation based on coverage score that determines the injection strategy.

**Decision Matrix:**

| Coverage | Decision | Strategy |
|----------|----------|----------|
| > 90% | SELECTIVE | Inject only P0 missing elements |
| 50% - 90% | TARGETED | Inject P0 and P1 missing elements |
| 1% - 49% | FULL PASS | Inject all P0, P1, P2 elements |
| 0% | P0 FIRST | Inject P0 elements only, then re-audit after |
| 0 files scanned | STOP | No frontend component files detected -- abort injection |

**Output Format:**
```
DECISION: {decision_type}
REASON: Current coverage {X}%, {explanation}
ACTION: {what the injector should do next}
FILES: {count} files to process
ELEMENTS: {count} elements to inject
```

---

## Worked Example (ShopFlow E-Commerce API)

### Summary

| Metric | Count |
|--------|-------|
| Files Scanned | 6 |
| Total Interactive Elements | 42 |
| Elements with Existing data-testid | 8 |
| Elements Missing data-testid | 34 |
| P0 Missing (must have) | 18 |
| P1 Missing (should have) | 12 |
| P2 Missing (nice to have) | 4 |

### Coverage Score

```
Current Coverage  = 8 / 42 * 100 = 19.05%
Projected Coverage = 42 / 42 * 100 = 100%
```

**Score: 19% -- NEEDS WORK**

Current coverage is well below the 50% threshold. A full injection pass is recommended to bring all interactive elements up to testability standards before E2E test generation.

### File Details

#### LoginPage.tsx -- LoginPage Component

**Path:** `src/components/auth/LoginPage.tsx`
**Interactive elements:** 8 (4 P0, 3 P1, 1 P2)

| Line | Element | Current Selector | Proposed data-testid | Priority |
|------|---------|-----------------|----------------------|----------|
| 18 | `<form>` | `className="login-form"` | `login-form` | P0 |
| 22 | `<input type="email">` | `name="email"` | `login-email-input` | P0 |
| 28 | `<input type="password">` | `name="password"` | `login-password-input` | P0 |
| 34 | `<button type="submit">` | `className="btn-primary"` | `login-submit-btn` | P0 |
| 40 | `<a href="/forgot-password">` | none | `login-forgot-password-link` | P1 |
| 45 | `<a href="/register">` | none | `login-register-link` | P1 |
| 50 | `<div className="error">` | `className="error-message"` | `login-error-alert` | P1 |
| 55 | `<img>` | `className="logo"` | `login-logo-img` | P2 |

#### CheckoutForm.tsx -- CheckoutForm Component

**Path:** `src/components/checkout/CheckoutForm.tsx`
**Interactive elements:** 10 (6 P0, 3 P1, 1 P2)

| Line | Element | Current Selector | Proposed data-testid | Priority |
|------|---------|-----------------|----------------------|----------|
| 12 | `<form>` | `className="checkout-form"` | `checkout-form` | P0 |
| 18 | `<input type="email">` | `data-testid="email"` | EXISTING -- no change | P0 |
| 24 | `<input type="text">` (card number) | `name="cardNumber"` | `checkout-card-number-input` | P0 |
| 30 | `<input type="text">` (expiry) | `name="expiry"` | `checkout-expiry-input` | P0 |
| 36 | `<input type="text">` (CVV) | `name="cvv"` | `checkout-cvv-input` | P0 |
| 42 | `<button type="submit">` | `data-testid="submitBtn"` | EXISTING -- no change | P0 |
| 48 | `<select>` (country) | `name="country"` | `checkout-country-select` | P1 |
| 54 | `<input type="text">` (promo code) | none | `checkout-promo-code-input` | P1 |
| 60 | `<span>` (total display) | `className="order-total"` | `checkout-total-text` | P1 |
| 66 | `<img>` (card brand icon) | `className="card-icon"` | `checkout-card-brand-img` | P2 |

#### ProductCard.tsx -- ProductCard Component

**Path:** `src/components/products/ProductCard.tsx`
**Interactive elements:** 5 (2 P0, 2 P1, 1 P2)

| Line | Element | Current Selector | Proposed data-testid | Priority |
|------|---------|-----------------|----------------------|----------|
| 10 | `<button>` (add to cart) | `data-testid="add-cart"` | EXISTING -- no change | P0 |
| 16 | `<a>` (product detail link) | `className="product-link"` | `product-detail-link` | P0 |
| 22 | `<span>` (product name) | `data-testid="product_name"` | EXISTING -- no change | P1 |
| 28 | `<span>` (price display) | `className="price"` | `product-price-text` | P1 |
| 34 | `<img>` (product image) | `data-testid="productImg"` | EXISTING -- no change | P2 |

#### NavigationBar.tsx -- NavigationBar Component

**Path:** `src/components/layout/NavigationBar.tsx`
**Interactive elements:** 7 (1 P0, 5 P1, 1 P2)

| Line | Element | Current Selector | Proposed data-testid | Priority |
|------|---------|-----------------|----------------------|----------|
| 8 | `<a>` (logo/home link) | `className="brand"` | `navbar-home-link` | P0 |
| 14 | `<a>` (products link) | none | `navbar-products-link` | P1 |
| 20 | `<a>` (orders link) | none | `navbar-orders-link` | P1 |
| 26 | `<a>` (cart link) | `data-testid="cart-link"` | EXISTING -- no change | P1 |
| 32 | `<button>` (user menu toggle) | none | `navbar-user-menu-btn` | P1 |
| 38 | `<a>` (logout link) | none | `navbar-logout-link` | P1 |
| 44 | `<span>` (cart count badge) | `data-testid="cartCount"` | EXISTING -- no change | P2 |

#### OrderHistory.tsx -- OrderHistory Component

**Path:** `src/components/orders/OrderHistory.tsx`
**Interactive elements:** 6 (2 P0, 2 P1, 2 P2)

| Line | Element | Current Selector | Proposed data-testid | Priority |
|------|---------|-----------------|----------------------|----------|
| 10 | `<table>` | `className="orders-table"` | `order-history-table` | P0 |
| 15 | `<button>` (view details) | `className="btn-sm"` | `order-view-details-btn` | P0 |
| 22 | `<select>` (status filter) | `name="statusFilter"` | `order-status-filter-select` | P1 |
| 28 | `<input type="text">` (search) | `name="search"` | `order-search-input` | P1 |
| 34 | `<span>` (order status badge) | `className="status-badge"` | `order-status-badge` | P2 |
| 40 | `<span>` (order total) | `className="order-amount"` | `order-total-text` | P2 |

#### UserProfilePage.tsx -- UserProfilePage Component

**Path:** `src/components/user/UserProfilePage.tsx`
**Interactive elements:** 6 (3 P0, 2 P1, 1 P2)

| Line | Element | Current Selector | Proposed data-testid | Priority |
|------|---------|-----------------|----------------------|----------|
| 12 | `<form>` | `className="profile-form"` | `profile-form` | P0 |
| 18 | `<input type="text">` (name) | `name="displayName"` | `profile-name-input` | P0 |
| 24 | `<input type="email">` (email) | `name="email"` | `profile-email-input` | P0 |
| 30 | `<button type="submit">` | `className="save-btn"` | `profile-save-btn` | P1 |
| 36 | `<button>` (change password) | none | `profile-change-password-btn` | P1 |
| 42 | `<img>` (avatar) | `className="avatar"` | `profile-avatar-img` | P2 |

### Naming Convention Compliance

**Existing values audited:** 8

| Existing Value | Compliant | Issue | Suggested Rename |
|----------------|-----------|-------|-----------------|
| `cart-link` | YES | -- | -- |
| `cartCount` | NO | camelCase instead of kebab-case; missing element-type suffix | `navbar-cart-count-badge` |
| `email` | NO | Too generic; missing context prefix and element-type suffix | `checkout-email-input` |
| `submitBtn` | NO | camelCase instead of kebab-case; missing context prefix | `checkout-submit-btn` |
| `add-cart` | YES | -- | -- |
| `product_name` | NO | snake_case instead of kebab-case; missing element-type suffix | `product-name-text` |
| `productImg` | NO | camelCase instead of kebab-case; missing context in description | `product-image-img` |
| `cart-count-badge` | YES | -- | -- |

**Summary:** 3 of 8 existing `data-testid` values are compliant with the `{context}-{description}-{element-type}` naming convention. 5 values are non-compliant and should be renamed during the injection pass.

### Decision Gate

```
DECISION: FULL PASS
REASON: Current coverage 19% (8/42), well below the 50% threshold
ACTION: Inject all P0, P1, P2 elements across 6 component files
FILES: 6 files to process
ELEMENTS: 34 elements to inject
```

Additionally, 5 existing `data-testid` values should be renamed for naming convention compliance (coordinate with test files that reference old values).

---

## Guidelines

**DO:**
- Follow `{context}-{description}-{element-type}` pattern strictly for all proposed values
- Mark elements with existing `data-testid` as `EXISTING -- no change` -- never modify working test IDs without explicit approval
- Prioritize form inputs (`<input>`, `<select>`, `<textarea>`) and submit buttons as P0
- Derive context from the component filename: `LoginPage.tsx` becomes `login`, `CheckoutForm.tsx` becomes `checkout`
- Use the element-type suffix table from the naming convention (see SKILL.md)
- Include the line number for every element to enable precise injection
- Check for duplicate `data-testid` values within the same page scope before proposing

**DON'T:**
- Propose duplicate `data-testid` values within the same page or route scope
- Add `data-testid` to purely non-interactive elements (static `<div>`, `<span>`) unless they display dynamic data the tests need to read
- Use framework-specific prefixes: no `cy-`, `pw-`, `qa-` -- just the bare value
- Modify elements that already have a working `data-testid` -- flag for rename review only
- Skip the naming convention compliance check -- even "EXISTING" values should be audited
- Propose vague generic values like `input-1`, `button-2` -- always include semantic context and description

---

## Quality Gate

Before delivering this artifact, verify:

- [ ] Every interactive element across all scanned files has an entry in the File Details section
- [ ] All proposed `data-testid` values follow the `{context}-{description}-{element-type}` convention
- [ ] No duplicate `data-testid` values exist within the same page/route scope
- [ ] Coverage Score formula is shown explicitly with the correct calculation
- [ ] Decision Gate recommendation matches the coverage score thresholds
- [ ] All existing `data-testid` values are audited in the Naming Convention Compliance section
- [ ] Priority assignments are consistent: form inputs and submit buttons are P0, navigation and feedback are P1, decorative elements are P2
- [ ] Line numbers are included for every element in every File Details table

---

*Template version: 1.0*
*Producer: qa-testid-injector*
*Last updated: {date}*
