---
name: qa-testid-injector
description: QA Test ID Injector agent. Scans application source code to identify interactive UI elements missing test hooks (data-testid attributes) and generates a precise injection plan or applies changes directly. Use this skill whenever the user wants to add test IDs to a codebase, improve testability of UI components, audit a repo for missing test hooks, prepare a codebase for E2E automation, or needs data-testid attributes added before writing Playwright/Cypress tests. Triggers on phrases like "add test IDs", "add data-testid", "test hooks", "missing testid", "testability audit", "prepare for automation", "inject test attributes", "selector strategy", "make components testable", or any request where the user needs stable, automation-friendly selectors added to HTML/JSX/TSX/Vue components. This skill is designed to run BEFORE test generation — it ensures the codebase has the hooks the tests will target.
---

# QA Test ID Injector

## Purpose

Scan application source code, identify interactive UI elements that lack stable test selectors, and inject `data-testid` attributes following a consistent naming convention. This skill runs as **Step 0** in the QA automation pipeline — before any test generation happens.

## Core Rule

**Every interactive element in the UI MUST have a stable, unique `data-testid` before E2E tests are generated against it.**

If tests are written using CSS classes or DOM structure, they break when designers restyle. `data-testid` attributes decouple test selectors from visual implementation.

## When This Skill Runs in the Pipeline

```
┌──────────────────────────┐
│  STEP 0: TESTID INJECTOR │ ◄── THIS SKILL
│  Scan → Audit → Inject   │
└───────────┬──────────────┘
            ▼
┌──────────────────────────┐
│  STEP 1: REPO ANALYSIS   │ (qa-workflow-documenter)
│  Structure, tech stack    │
└───────────┬──────────────┘
            ▼
┌──────────────────────────┐
│  STEP 2: TEST GENERATION  │ (qa-template-engine)
│  Cases use data-testid    │
└───────────┬──────────────┘
            ▼
┌──────────────────────────┐
│  STEP 3: VALIDATION       │ (qa-self-validator)
│  Verify tests + selectors │
└───────────┬──────────────┘
            ▼
┌──────────────────────────┐
│  STEP 4: EXECUTION        │ (qa-bug-detective)
│  Run and classify results │
└──────────────────────────┘
```

## Naming Convention

All `data-testid` values follow this pattern:

```
{context}-{description}-{element-type}
```

### Element Type Suffixes

| Element            | Suffix      | Example                          |
|--------------------|-------------|----------------------------------|
| `<button>`         | `-btn`      | `login-submit-btn`               |
| `<input>`          | `-input`    | `login-email-input`              |
| `<select>`         | `-select`   | `settings-language-select`       |
| `<textarea>`       | `-textarea` | `feedback-comment-textarea`      |
| `<a>` (link)       | `-link`     | `navbar-profile-link`            |
| `<form>`           | `-form`     | `checkout-payment-form`          |
| `<img>`            | `-img`      | `product-hero-img`               |
| `<table>`          | `-table`    | `users-list-table`               |
| `<tr>` (row)       | `-row`      | `users-item-row`                 |
| `<dialog>/<modal>` | `-modal`    | `confirm-delete-modal`           |
| `<div>` container  | `-container`| `dashboard-stats-container`      |
| `<ul>/<ol>` list   | `-list`     | `notifications-list`             |
| `<li>` item        | `-item`     | `notifications-item`             |
| dropdown menu      | `-dropdown` | `navbar-user-dropdown`           |
| tab                | `-tab`      | `settings-security-tab`          |
| checkbox           | `-checkbox` | `terms-accept-checkbox`          |
| radio              | `-radio`    | `shipping-express-radio`         |
| toggle/switch      | `-toggle`   | `notifications-enabled-toggle`   |
| badge/chip         | `-badge`    | `cart-count-badge`               |
| alert/toast        | `-alert`    | `error-validation-alert`         |

### Context Derivation Rules

1. **Page-level context**: Derived from the component file name or route  
   - `LoginPage.tsx` → context = `login`
   - `src/pages/checkout/Payment.vue` → context = `checkout-payment`

2. **Component-level context**: Derived from the component name  
   - `<UserProfileCard>` → context = `user-profile`
   - `<NavBar>` → context = `navbar`

3. **Nested context**: Use parent → child hierarchy  
   - A button inside `<CheckoutForm>` inside `<PaymentPage>` → `checkout-form-submit-btn`
   - Max depth: 3 levels. Beyond that, use the most specific 2 levels.

4. **Dynamic/list items**: Use a generic name + note that runtime `key` should be appended  
   - `data-testid={`product-${product.id}-card`}` for items in a `.map()`

### Naming Rules

- **kebab-case only**: `login-submit-btn`, never `loginSubmitBtn` or `login_submit_btn`
- **No framework-specific prefixes**: No `cy-`, `pw-`, `qa-` — just `data-testid`
- **Unique per page**: No two elements on the same rendered page share a `data-testid`
- **Descriptive over short**: `checkout-credit-card-number-input` > `cc-input`
- **English only**: Even for i18n projects, test IDs are always in English

## Execution Workflow

### Phase 1: SCAN — Identify Files to Process

**Actor**: AI Agent  
**Input**: Repository root path  
**Action**:
1. Detect the framework by scanning `package.json`, file extensions, and directory structure
2. Identify all component files:
   - React: `**/*.{jsx,tsx}` (excluding `*.test.*`, `*.spec.*`, `*.stories.*`)
   - Vue: `**/*.vue`
   - Angular: `**/*.component.html`
   - Plain HTML: `**/*.html` (excluding `node_modules`, `dist`, `build`)
3. Prioritize files by interaction density (forms > pages > layouts > utilities)

**Output**: `SCAN_MANIFEST.md` — List of files to process with priority order

**Decision Gate**: If 0 component files found → STOP and report "No UI components detected"

### Phase 2: AUDIT — Identify Missing Test IDs

**Actor**: AI Agent  
**Input**: Files from SCAN_MANIFEST  
**Action**:
For each file, parse and identify elements that:
1. Are interactive (buttons, inputs, links, forms, selects, textareas)
2. Are containers for significant content (modals, dropdowns, alerts, cards)
3. Are data display elements that tests might need to read (tables, lists, badges)
4. Already have `data-testid` → record as EXISTING (don't modify)
5. Are missing `data-testid` → record as MISSING with proposed value

**Classification**:
- **P0 — Must have**: buttons, inputs, forms, links used for navigation, modals
- **P1 — Should have**: dropdowns, tabs, alerts, toggle switches, data tables
- **P2 — Nice to have**: containers, images, decorative elements with semantic meaning

**Output**: `TESTID_AUDIT_REPORT.md`

```markdown
# Test ID Audit Report

## Summary
- Files scanned: [N]
- Elements with existing data-testid: [N]
- Elements missing data-testid: [N]
  - P0 (must have): [N]
  - P1 (should have): [N]
  - P2 (nice to have): [N]

## Coverage Score
- Current: [N]% ([existing] / [total interactive elements])
- After injection: 100%

## File Details

### [filename.tsx] — [ComponentName]
| Line | Element | Current Selector | Proposed data-testid | Priority |
|------|---------|-----------------|----------------------|----------|
| 24   | `<button>` | class="btn-primary" | login-submit-btn | P0 |
| 31   | `<input type="email">` | none | login-email-input | P0 |
| 45   | `<a href="/forgot">` | none | login-forgot-password-link | P1 |
```

**Decision Gate**: 
- If coverage is already >90% → Report only gaps, suggest selective injection
- If coverage is <50% → Full injection pass recommended
- If coverage is 0% → Start with P0 elements first, iterate

### Phase 3: INJECT — Apply Test IDs

**Actor**: AI Agent  
**Input**: TESTID_AUDIT_REPORT + source files  
**Action**:

For each file with missing test IDs:

1. **Read** the current file content
2. **Parse** and locate each element flagged in the audit
3. **Inject** `data-testid` as the LAST attribute before the closing `>` of the opening tag
4. **Preserve** all existing formatting, indentation, and whitespace
5. **Do not change** any other code — only add the `data-testid` attribute

**Injection Rules by Framework**:

#### React (JSX/TSX)
```jsx
// BEFORE
<button className="btn" onClick={handleSubmit}>Submit</button>

// AFTER
<button className="btn" onClick={handleSubmit} data-testid="checkout-submit-btn">Submit</button>
```

For dynamic lists:
```jsx
// BEFORE
{items.map(item => (
  <div key={item.id} className="card">{item.name}</div>
))}

// AFTER
{items.map(item => (
  <div key={item.id} className="card" data-testid={`product-${item.id}-card`}>{item.name}</div>
))}
```

Spread props pattern (respect existing spreads):
```jsx
// BEFORE
<Input {...field} placeholder="Email" />

// AFTER
<Input {...field} placeholder="Email" data-testid="login-email-input" />
```

#### Vue (.vue)
```html
<!-- BEFORE -->
<button class="btn" @click="handleSubmit">Submit</button>

<!-- AFTER -->
<button class="btn" @click="handleSubmit" data-testid="checkout-submit-btn">Submit</button>
```

Dynamic in Vue:
```html
<!-- BEFORE -->
<div v-for="item in items" :key="item.id" class="card">{{ item.name }}</div>

<!-- AFTER -->
<div v-for="item in items" :key="item.id" class="card" :data-testid="`product-${item.id}-card`">{{ item.name }}</div>
```

#### Angular (.component.html)
```html
<!-- BEFORE -->
<button class="btn" (click)="handleSubmit()">Submit</button>

<!-- AFTER -->
<button class="btn" (click)="handleSubmit()" data-testid="checkout-submit-btn">Submit</button>
```

#### Plain HTML
```html
<!-- BEFORE -->
<button class="btn" onclick="handleSubmit()">Submit</button>

<!-- AFTER -->
<button class="btn" onclick="handleSubmit()" data-testid="checkout-submit-btn">Submit</button>
```

**Output**: Modified source files + `INJECTION_CHANGELOG.md`

```markdown
# Injection Changelog

## Summary
- Files modified: [N]
- Test IDs added: [N]
- Test IDs already present (preserved): [N]

## Changes Per File

### [filename.tsx]
| Line | Element | data-testid Added | Priority |
|------|---------|-------------------|----------|
| 24   | button  | login-submit-btn  | P0       |
| 31   | input   | login-email-input | P0       |
```

### Phase 4: VALIDATE — Verify Injections

**Actor**: AI Agent  
**Input**: Modified files  
**Action**:
1. **Syntax check**: Run the appropriate linter/compiler to verify no syntax errors were introduced
2. **Uniqueness check**: Verify no duplicate `data-testid` values within the same component tree
3. **Convention check**: Verify all values follow the naming convention
4. **Non-interference check**: Verify no other code was modified (diff against original)

**Output**: `INJECTION_VALIDATION.md`

**Decision Gate**:
- All checks pass → DELIVER
- Syntax error → FIX (revert specific injection, re-apply correctly)
- Duplicate found → RENAME with more specific context
- Convention violation → RENAME to comply

## Production Stripping (Optional)

For teams that don't want `data-testid` in production bundles:

### Babel Plugin (React)
```json
// babel.config.json — production only
{
  "env": {
    "production": {
      "plugins": ["babel-plugin-react-remove-properties", { "properties": ["data-testid"] }]
    }
  }
}
```

### Webpack / Vite
```js
// For HTML templates — use a custom plugin or post-process step
// Regex-based removal (simple projects only):
html.replace(/\s*data-testid="[^"]*"/g, '')
```

### Vue
```js
// vite.config.js
export default {
  vue: {
    template: {
      compilerOptions: {
        nodeTransforms: process.env.NODE_ENV === 'production'
          ? [(node) => { /* remove data-testid */ }]
          : []
      }
    }
  }
}
```

## Third-Party Component Strategy

When components come from UI libraries (MUI, Ant Design, Chakra, shadcn/ui):

1. **Wrapper approach** (preferred):
```jsx
// BEFORE
<MuiButton variant="contained" onClick={submit}>Submit</MuiButton>

// AFTER — wrapper div
<div data-testid="checkout-submit-btn">
  <MuiButton variant="contained" onClick={submit}>Submit</MuiButton>
</div>
```

2. **Props passthrough** (if the library supports it):
```jsx
// Many libraries pass unknown props to the root element
<MuiButton variant="contained" onClick={submit} data-testid="checkout-submit-btn">Submit</MuiButton>
```

3. **inputProps / slotProps** (MUI-specific):
```jsx
<TextField
  label="Email"
  inputProps={{ 'data-testid': 'login-email-input' }}
/>
```

**Decision**: Check library docs first. If props pass through → use direct. If not → use wrapper.

## Edge Cases

### Conditional Rendering
```jsx
// data-testid goes on the conditional element itself, not the wrapper
{isLoggedIn && <button data-testid="dashboard-logout-btn">Logout</button>}
```

### Portals / Teleport (React Portals, Vue Teleport)
```jsx
// data-testid still applies — the element renders in a different DOM location but the attribute persists
createPortal(
  <div data-testid="confirm-delete-modal">...</div>,
  document.body
)
```

### Server Components (Next.js RSC)
```jsx
// data-testid works in both server and client components — it's just an HTML attribute
// No special handling needed
```

### Fragments
```jsx
// Cannot add data-testid to fragments — add to the meaningful children instead
<>
  <h1 data-testid="page-title">Dashboard</h1>
  <div data-testid="dashboard-content-container">...</div>
</>
```

## Integration with Other QA Skills

- **qa-template-engine**: After injection, templates reference `data-testid` selectors in the `Locator/Target` column
- **qa-self-validator**: Validates that generated tests use `getByTestId()` selectors that match actual `data-testid` values in the codebase
- **qa-workflow-documenter**: Documents the injection step as Step 0 in the workflow
- **qa-bug-detective**: When tests fail on selectors, checks if the `data-testid` was removed or renamed

## Output Artifacts

Every run of this skill produces:

1. **SCAN_MANIFEST.md** — Files identified for processing
2. **TESTID_AUDIT_REPORT.md** — Full audit with proposed values
3. **INJECTION_CHANGELOG.md** — Exact changes made
4. **INJECTION_VALIDATION.md** — Proof that injections are valid
5. **Modified source files** — The actual code changes (or a patch/diff file)

## Quality Gate

Before delivering, verify ALL of these:

- [ ] Every interactive element has a `data-testid`
- [ ] All values follow `{context}-{description}-{element-type}` convention
- [ ] No duplicate `data-testid` values in the same page/route scope
- [ ] No existing code was modified beyond adding the attribute
- [ ] Syntax validation passes on all modified files
- [ ] Dynamic list items use template literals with unique keys
- [ ] Third-party components are handled appropriately (wrapper or passthrough)
