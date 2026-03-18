# QA Gap Analysis

Compare a DEV repo against its QA repo and identify coverage gaps. Produces a detailed gap report showing what's missing, what's broken, and what needs updating.

## Instructions

### Step 1: Gather Input

Ask the user for:
1. Path to the DEV repo
2. Path to the QA repo
3. Any recent changes or features to focus on?

### Step 2: Scan Both Repos

**DEV repo**: Map all testable surfaces:
- API endpoints (routes, controllers)
- Business logic (services, utils)
- Data models and validation rules
- Frontend pages and components
- Authentication/authorization flows
- Error handling paths

**QA repo**: Map existing test coverage:
- What's tested (file → feature mapping)
- Test quality (assertion specificity, locator tiers)
- Framework and tooling status
- Broken or skipped tests

### Step 3: Cross-Reference

For each testable surface in DEV, check if QA has:
- At least one happy-path test
- At least one negative/error test
- Edge case coverage where applicable

### Step 4: Produce GAP_ANALYSIS.md

```markdown
# Gap Analysis Report

## Summary
- Testable surfaces in DEV: [N]
- Covered by QA tests: [N] (X%)
- Missing coverage: [N] (Y%)
- Broken/skipped tests: [N]

## Coverage Map
| Feature | Endpoints/Functions | Unit Tests | API Tests | E2E Tests | Gap |
|---------|--------------------:|:----------:|:---------:|:---------:|:---:|
| Auth    | 5                  | 2          | 1         | 0         | HIGH |
| ...     | ...                | ...        | ...       | ...       | ... |

## Missing Test Cases (prioritized)
### P0 — Must Add
...
### P1 — Should Add
...
### P2 — Nice to Have
...

## Broken Tests
...

## Recommendations
...
```

$ARGUMENTS
