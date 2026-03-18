# QA Status Report

Generate a summary report of the current QA status for a project. Useful for stakeholders, sprint reviews, and tracking progress.

## Instructions

### Step 1: Gather Input

Ask the user for:
1. Path to the QA repo (or test directory)
2. Path to the DEV repo (for coverage calculation)
3. Report audience (team, management, client)

### Step 2: Collect Metrics

Scan the test suite and calculate:
- Total test files by type (unit, API, E2E)
- Total test cases by priority (P0, P1, P2)
- Test pyramid distribution (actual vs target from CLAUDE.md)
- Locator quality distribution (% per tier)
- Assertion quality (% concrete vs vague)
- POM compliance score
- Broken/skipped test count
- Last modification dates

### Step 3: Calculate Coverage

Cross-reference with DEV repo:
- Business logic coverage (functions with unit tests)
- API endpoint coverage (endpoints with API tests)
- User flow coverage (critical paths with E2E tests)
- Overall coverage estimate

### Step 4: Produce QA_STATUS_REPORT.md

Adapt detail level to audience:

**For team**: Include file-level details, specific gaps, next actions
**For management**: High-level metrics, risk areas, recommendations
**For client**: Coverage summary, confidence level, next milestones

```markdown
# QA Status Report — [Project Name]
**Date**: [date]
**Author**: QA Automation Agent

## Executive Summary
[2-3 sentences on overall QA health]

## Metrics
| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| ...    | ...   | ...    | ...    |

## Testing Pyramid
[Actual vs target distribution]

## Risk Areas
[Areas with thin or no coverage]

## Recommendations
[Prioritized next steps]
```

$ARGUMENTS
