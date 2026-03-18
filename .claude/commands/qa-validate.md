# QA Test Validation

Run validation on existing test files. Checks syntax, structure, dependencies, and logic quality. Classifies any failures found.

## Instructions

### Step 1: Gather Input

Ask the user for:
1. Path to the test folder or specific test files to validate
2. Framework being used (or auto-detect from config files)

### Step 2: Run Validation Layers

Use the `qa-self-validator` skill to check:

**Layer 1 — Syntax:**
- TypeScript: `tsc --noEmit`
- JavaScript: `node --check`
- Python: `python -m py_compile`
- Run linter if configured

**Layer 2 — Structure:**
- Correct directory placement
- Naming convention compliance (CLAUDE.md standards)
- Has actual test functions (not empty files)
- Imports reference real modules
- No hardcoded secrets/credentials

**Layer 3 — Dependencies:**
- All imports resolvable
- Packages exist in package.json/requirements.txt
- No circular dependencies in test helpers

**Layer 4 — Logic:**
- Happy path has positive assertions
- Error tests have negative assertions
- Setup/teardown are symmetric
- No duplicate test IDs
- Assertions are concrete (not toBeTruthy/toBeDefined)

### Step 3: Classify Failures

If test execution failures are found, use the `qa-bug-detective` skill to classify each as:
- **APPLICATION BUG**: Error in production code path
- **TEST CODE ERROR**: Syntax/import error in test
- **ENVIRONMENT ISSUE**: Connection refused, timeout, missing env var
- **INCONCLUSIVE**: Can't determine

### Step 4: Report

Produce `VALIDATION_REPORT.md` with:
- Pass/fail per file per validation layer
- Summary table
- If failures: `FAILURE_CLASSIFICATION_REPORT.md` with detailed analysis

$ARGUMENTS
