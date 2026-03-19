# QA Test Validation

Validate existing test files against CLAUDE.md standards. Runs 4-layer validation (syntax, structure, dependencies, logic) and classifies any failures found.

## Usage

/qa-validate <path-to-tests> [--framework <name>]

- path-to-tests: directory or specific test files to validate
- --framework: override framework auto-detection (playwright, cypress, jest, etc.)

## What It Produces

- VALIDATION_REPORT.md -- pass/fail per file per validation layer, confidence level
- FAILURE_CLASSIFICATION_REPORT.md -- if failures found, classifies as APP BUG / TEST ERROR / ENV ISSUE / INCONCLUSIVE

## Instructions

1. Read `CLAUDE.md` -- quality gates, locator tiers, assertion rules.
2. Invoke validator agent:

Task(
  prompt="
    <objective>Validate test files with 4-layer validation and produce VALIDATION_REPORT.md</objective>
    <execution_context>@agents/qaa-validator.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    mode: validation
    </parameters>
  "
)

3. If failures detected, invoke bug-detective agent:

Task(
  prompt="
    <objective>Classify test failures and auto-fix TEST CODE ERRORS</objective>
    <execution_context>@agents/qaa-bug-detective.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    - .qa-output/VALIDATION_REPORT.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    </parameters>
  "
)

4. Present results. No git operations.

$ARGUMENTS
