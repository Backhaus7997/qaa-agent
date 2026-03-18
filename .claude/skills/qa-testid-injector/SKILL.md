---
name: qa-testid-injector
description: QA Test ID Injector. Scans source code to find interactive UI elements missing data-testid attributes and injects them following naming convention. Use when user wants to add test IDs, improve testability, audit missing test hooks, prepare for E2E automation, or add data-testid attributes before writing Playwright/Cypress tests. Triggers on "add test IDs", "add data-testid", "test hooks", "missing testid", "testability audit", "prepare for automation", "inject test attributes", "make components testable".
---

# QA Test ID Injector

## Purpose

Scan application source code, identify interactive UI elements lacking stable test selectors, and inject `data-testid` attributes following a consistent naming convention. Runs as **Step 0** — before any test generation.

## Core Rule

**Every interactive element MUST have a stable, unique `data-testid` before E2E tests are generated against it.**

## Naming Convention

Pattern: `{context}-{description}-{element-type}` in kebab-case.

### Element Type Suffixes

| Element | Suffix | Example |
|---------|--------|---------|
| button | -btn | login-submit-btn |
| input | -input | login-email-input |
| select | -select | settings-language-select |
| textarea | -textarea | feedback-comment-textarea |
| link | -link | navbar-profile-link |
| form | -form | checkout-payment-form |
| img | -img | product-hero-img |
| table | -table | users-list-table |
| row | -row | users-item-row |
| modal | -modal | confirm-delete-modal |
| container | -container | dashboard-stats-container |
| list | -list | notifications-list |
| item | -item | notifications-item |
| dropdown | -dropdown | navbar-user-dropdown |
| tab | -tab | settings-security-tab |
| checkbox | -checkbox | terms-accept-checkbox |
| radio | -radio | shipping-express-radio |
| toggle | -toggle | notifications-enabled-toggle |
| badge | -badge | cart-count-badge |
| alert | -alert | error-validation-alert |

### Context Derivation

1. **Page-level**: From component filename or route (LoginPage.tsx -> login)
2. **Component-level**: From component name (<NavBar> -> navbar)
3. **Nested**: Parent -> child hierarchy, max 3 levels deep
4. **Dynamic lists**: Use template literals with unique keys

## Execution Phases

### Phase 1: SCAN
- Detect framework (React/Vue/Angular/HTML) from package.json and file extensions
- List all component files (exclude test/spec/stories)
- Prioritize by interaction density (forms > pages > layouts)
- Output: SCAN_MANIFEST.md

### Phase 2: AUDIT
- For each file, identify interactive elements
- Classify: P0 (must have), P1 (should have), P2 (nice to have)
- Record existing data-testid as EXISTING (don't modify)
- Record missing as MISSING with proposed value
- Output: TESTID_AUDIT_REPORT.md

### Phase 3: INJECT
- Add data-testid as LAST attribute before closing >
- Preserve all existing formatting
- Only add the attribute — change nothing else
- Framework-specific handling (JSX, Vue, Angular, HTML)
- Output: INJECTION_CHANGELOG.md + modified source files

### Phase 4: VALIDATE
- Syntax check all modified files
- Uniqueness check (no duplicate testids per page)
- Convention compliance check
- Output: INJECTION_VALIDATION.md

## Third-Party Components

1. Props passthrough (if library supports it) — direct data-testid
2. Wrapper div (if no passthrough) — wrap with data-testid div
3. inputProps/slotProps (MUI-specific) — use component-specific prop APIs

## Quality Gate

- [ ] Every interactive element has a data-testid
- [ ] All values follow {context}-{description}-{element-type} convention
- [ ] No duplicate data-testid values in same page/route scope
- [ ] No existing code modified beyond adding the attribute
- [ ] Syntax validation passes on all modified files
- [ ] Dynamic list items use template literals with unique keys
