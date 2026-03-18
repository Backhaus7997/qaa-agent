# Update & Improve Existing Tests

Improve existing test files without breaking what already works. Surgical: add, fix, improve — never replace.

## Core Rule

**NEVER delete or rewrite working tests without user approval.**

## Instructions

### Step 1: Determine Scope

The user will specify what to improve:
- Fix broken tests (locators, imports, config)
- Improve quality (assertions, POM structure, naming)
- Add missing coverage (new test cases for uncovered flows)
- Full audit (review everything, suggest all improvements)

### Step 2: Audit Existing Tests

Produce `TEST_AUDIT.md` with:
- Total test files and test cases
- POM usage assessment (YES / NO / PARTIAL)
- Locator quality breakdown (% per tier from CLAUDE.md)
- Issues table: file, issue, severity, suggested fix
- Prioritized recommendations

**Present the audit and WAIT for user approval before making any changes.**

### Step 3: Apply Approved Changes

Based on user approval:

**Fix Locators:** Upgrade Tier 3-4 locators to Tier 1-2. Add traceability comments.

**Fix POM Structure:** Move assertions out of page objects, add BasePage inheritance, add page navigation chaining, convert state checks to data-returning queries.

**Improve Assertions:** Upgrade vague assertions (toBeTruthy, toBeDefined) to specific ones (toBe(200), toHaveText('Expected')).

**Add Missing Tests:** Only add new files — never modify passing tests. Follow existing structure and conventions.

### Step 4: Report

Produce `UPDATE_REPORT.md` with:
- Files modified and added
- Locators upgraded (count per tier change)
- Assertions improved
- Test cases added
- Remaining gaps

$ARGUMENTS
