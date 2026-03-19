# Create Automated Tests

Generate production-ready test files with POM pattern for a specific feature or module. Reads existing QA_ANALYSIS.md and TEST_INVENTORY.md if available.

## Usage

/create-test <feature-name> [--dev-repo <path>]

- feature-name: which feature to test (e.g., "login", "checkout", "user API")
- --dev-repo: path to developer repository (default: current directory)

## What It Produces

- Test spec files (unit, API, E2E as appropriate for the feature)
- Page Object Model files (for E2E tests)
- Fixture files (test data)

## Instructions

1. Read `CLAUDE.md` -- POM rules, locator tiers, assertion rules, naming conventions, quality gates.
2. Read existing analysis artifacts if available:
   - `.qa-output/QA_ANALYSIS.md` -- architecture context
   - `.qa-output/TEST_INVENTORY.md` -- pre-defined test cases for this feature
3. Invoke executor agent:

Task(
  prompt="
    <objective>Generate test files for the specified feature following CLAUDE.md standards</objective>
    <execution_context>@agents/qaa-executor.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    mode: feature-test
    </parameters>
  "
)

$ARGUMENTS
