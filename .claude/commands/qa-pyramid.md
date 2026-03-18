# Test Pyramid Analysis

Analyze a project's test distribution against the ideal testing pyramid and produce a plan to reach the target distribution.

## Instructions

### Step 1: Gather Input

Ask the user for:
1. Path to the DEV repo
2. Path to the QA/test directory

### Step 2: Count Current Tests

Categorize every test file and test case:

| Level | Files | Test Cases | % of Total |
|-------|-------|-----------|------------|
| Unit | ... | ... | ...% |
| Integration | ... | ... | ...% |
| API | ... | ... | ...% |
| E2E | ... | ... | ...% |

### Step 3: Compare to Target

From CLAUDE.md:
```
         /  E2E  \        3-5%
        /  API    \       20-25%
       / Integration\     10-15%
      /    Unit      \    60-70%
```

Adjust target based on app architecture:
- API-only app: More API tests, fewer E2E
- Frontend-heavy: More E2E, more integration
- Microservices: More contract tests
- Data-heavy: More unit tests on transformations

### Step 4: Produce PYRAMID_ANALYSIS.md

```markdown
# Testing Pyramid Analysis

## Current Distribution
[Table + visual pyramid with actual %]

## Target Distribution
[Table + visual pyramid with target %]

## Gap
| Level | Current | Target | Delta | Priority |
|-------|---------|--------|-------|----------|
| Unit | X% | 60-70% | +N% | ... |
| ... | ... | ... | ... | ... |

## Action Plan
### To reach target:
1. Add [N] unit tests for: [specific modules]
2. Add [N] API tests for: [specific endpoints]
3. [Optionally reduce] E2E tests by converting to API-level
4. Add [N] integration tests for: [specific interactions]

## Estimated Effort
[Prioritized list with rough sizing]
```

$ARGUMENTS
