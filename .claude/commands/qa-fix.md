# Fix Broken Tests

Diagnose and fix broken test files. Classifies each failure as APPLICATION BUG, TEST CODE ERROR, ENVIRONMENT ISSUE, or INCONCLUSIVE. Auto-fixes only TEST CODE ERRORS. Never touches application code -- only reports APP BUGs for developer attention.

## Usage

/qa-fix <path-to-tests> [error output]

- path-to-tests: directory or specific test files with failures
- error output: paste test runner output (optional -- agent will run tests if not provided)

## What It Produces

- FAILURE_CLASSIFICATION_REPORT.md -- per-failure classification with evidence, confidence, and auto-fix log

## Instructions

1. Read `CLAUDE.md` -- classification rules, locator tiers, assertion quality.
2. Invoke bug-detective agent:

Task(
  prompt="
    <objective>Run tests, classify failures, and auto-fix TEST CODE ERRORS</objective>
    <execution_context>@agents/qaa-bug-detective.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    </parameters>
  "
)

3. Present results. APPLICATION BUGs are reported for developer action, not auto-fixed.

$ARGUMENTS
