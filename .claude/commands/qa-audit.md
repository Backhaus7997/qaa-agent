# Full QA Audit

Comprehensive quality audit of a test suite against CLAUDE.md standards. Scores across 6 dimensions: Locator Quality (20%), Assertion Specificity (20%), POM Compliance (15%), Test Coverage (20%), Naming Convention (15%), Test Data Management (10%).

## Usage

/qa-audit <path-to-tests> [--dev-repo <path>]

- path-to-tests: directory containing test files to audit
- --dev-repo: path to developer repository (for coverage cross-reference)

## What It Produces

- QA_AUDIT_REPORT.md -- 6-dimension scoring, critical issues list, prioritized recommendations with effort estimates

## Instructions

1. Read `CLAUDE.md` -- quality gates, locator tiers, assertion rules, POM rules, naming conventions.
2. Invoke validator agent in audit mode:

Task(
  prompt="
    <objective>Audit test suite quality and produce QA_AUDIT_REPORT.md with 6-dimension scoring</objective>
    <execution_context>@agents/qaa-validator.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    mode: audit
    </parameters>
  "
)

3. Present results with overall score and prioritized recommendations.

$ARGUMENTS
