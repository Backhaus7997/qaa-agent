# Update and Improve Existing Tests

Audit existing test files and apply targeted improvements. NEVER deletes or rewrites working tests without user approval. Surgical: add, fix, improve -- never replace.

## Usage

/update-test <path-to-tests> [--scope fix|improve|add|full]

- path-to-tests: directory or specific test files to improve
- --scope: what to do (default: full)
  - fix: repair broken tests only
  - improve: upgrade locators, assertions, POM structure
  - add: add missing test cases without modifying existing
  - full: audit everything, then improve with approval

## What It Produces

- QA_AUDIT_REPORT.md -- current quality assessment
- Improved test files (after user approval of audit findings)

## Instructions

1. Read `CLAUDE.md` -- quality gates, locator tiers, assertion rules, POM rules.
2. Invoke validator agent in audit mode first:

Task(
  prompt="
    <objective>Audit existing test quality and produce QA_AUDIT_REPORT.md</objective>
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

3. Present audit results and wait for user approval.
4. Invoke executor agent to apply approved improvements:

Task(
  prompt="
    <objective>Apply approved improvements to existing tests without deleting working tests</objective>
    <execution_context>@agents/qaa-executor.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    - .qa-output/QA_AUDIT_REPORT.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    mode: update
    </parameters>
  "
)

$ARGUMENTS
