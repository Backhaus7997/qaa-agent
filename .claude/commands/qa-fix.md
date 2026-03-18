# Fix Broken Tests

Diagnose and fix broken test files. Classifies each failure, then auto-fixes TEST CODE ERRORS while flagging APPLICATION BUGS.

## Instructions

### Step 1: Gather Input

Ask the user for:
1. Path to the test file(s) or folder with broken tests
2. Error output (if they have it) or should the agent run the tests?

### Step 2: Run Tests

Execute the test suite and capture output:
- Identify which tests pass and which fail
- Capture error messages, stack traces, screenshots

### Step 3: Classify Failures

For each failing test, determine:

| Classification | Criteria | Action |
|---------------|----------|--------|
| **TEST CODE ERROR** | Syntax/import error in test file | Auto-fix |
| **APPLICATION BUG** | Error in production code path | Report only |
| **ENVIRONMENT ISSUE** | Connection refused, timeout, missing env | Report + suggest fix |
| **INCONCLUSIVE** | Can't determine root cause | Report + request more info |

Evidence requirements: file path, line number, error message, specific code proving the classification.

### Step 4: Auto-Fix TEST CODE ERRORS

Only fix with HIGH confidence:
- Import path corrections
- Selector updates (match current DOM)
- Assertion value updates (match current behavior)
- Config fixes (baseURL, timeout, etc.)
- Missing await keywords

**NEVER auto-fix APPLICATION BUGS** — only report them.

### Step 5: Re-run and Report

After fixes:
1. Re-run the fixed tests
2. Produce FAILURE_CLASSIFICATION_REPORT.md with:
   - Summary table (pass/fail/classification)
   - Detailed analysis per failure
   - What was fixed
   - What needs human attention
   - Confidence level for each classification

$ARGUMENTS
