# Spec: Update & Improve Existing Tests

## Goal
Improve existing test files without breaking what already works. Follow all standards defined in CLAUDE.md. Only run this spec when explicitly asked by the user.

## Core Rule
**NEVER delete or rewrite working tests without user approval.** This spec is surgical: add, fix, improve — not replace.

## Input
The user will specify what to improve:
- Fix broken tests (locators, imports, config)
- Improve quality (assertions, POM structure, naming)
- Add missing coverage (new test cases for uncovered flows)
- Full audit (review everything, suggest all improvements)

## Milestones

### Milestone 1: Audit Existing Tests
Produce `TEST_AUDIT.md` with:
- Total test files and test cases
- POM usage assessment (YES / NO / PARTIAL)
- Locator quality breakdown (% per tier)
- Issues table: file, issue, severity, suggested fix
- Prioritized recommendations

**Present the audit to the user and WAIT for approval before making any changes.**

### Milestone 2: Fix Locators (if approved)
Upgrade Tier 3-4 locators to Tier 1-2 following CLAUDE.md hierarchy.
Add traceability comments: `// Upgraded from: page.locator('.old-selector')`

### Milestone 3: Fix POM Structure (if approved)
- Move assertions out of page objects
- Add BasePage inheritance where missing
- Add page navigation chaining (return next page)
- Convert state checks to data-returning queries

### Milestone 4: Improve Assertions (if approved)
Upgrade vague assertions to specific ones following CLAUDE.md rules.

### Milestone 5: Add Missing Tests (if approved)
Only add new test files — never modify passing tests without asking.
Follow the same structure and conventions as existing tests.

### Milestone 6: Report
Produce `UPDATE_REPORT.md` with:
- Files modified and added
- Locators upgraded (count per tier change)
- Assertions improved
- Test cases added
- Remaining gaps

## Definition of Done
- [ ] No working test was deleted or broken
- [ ] All changes were approved by the user
- [ ] All modifications follow CLAUDE.md standards
- [ ] UPDATE_REPORT.md documents every change
