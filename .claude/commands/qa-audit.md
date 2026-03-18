# Full QA Audit

Comprehensive quality audit of a test suite against CLAUDE.md standards. Produces a detailed report with scores and actionable recommendations.

## Instructions

### Step 1: Gather Input

Ask the user for:
1. Path to the QA/test repository or test directory
2. Path to the DEV repository (for cross-reference)

### Step 2: Structure Audit

Evaluate the test suite structure:
- Directory organization (follows testing pyramid?)
- File naming conventions
- POM structure (base class, feature pages, components)
- Fixture/test data management
- Configuration files
- CI/CD integration

### Step 3: Quality Audit

For each test file, evaluate:
- **Locator Quality**: Score each selector by CLAUDE.md tier (1-4)
- **Assertion Quality**: Concrete values vs vague (toBeTruthy, toBeDefined)
- **Test Independence**: Each test can run standalone?
- **Data Management**: Hardcoded values vs fixtures/env vars
- **Error Handling**: Negative tests exist? Edge cases covered?
- **ID Convention**: All tests have unique IDs?

### Step 4: Coverage Audit

Cross-reference with DEV repo:
- Which business logic has unit tests?
- Which API endpoints have test coverage?
- Which user flows have E2E coverage?
- Map actual vs recommended testing pyramid

### Step 5: Produce QA_AUDIT_REPORT.md

```markdown
# QA Audit Report

## Scores
| Dimension | Score | Details |
|-----------|-------|---------|
| Structure | X/10 | ... |
| Locators  | X/10 | ... |
| Assertions| X/10 | ... |
| Coverage  | X/10 | ... |
| Data Mgmt | X/10 | ... |
| CI/CD     | X/10 | ... |
| **Overall** | **X/10** | ... |

## Critical Issues (fix immediately)
...

## Recommendations (prioritized)
...

## Coverage Map
...
```

$ARGUMENTS
