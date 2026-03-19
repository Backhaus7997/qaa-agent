# QA Status Report

Generate a summary report of current QA status for a project. Adapts detail level to audience: team (file-level details), management (high-level metrics), or client (coverage summary).

## Usage

/qa-report <path-to-tests> [--dev-repo <path>] [--audience <team|management|client>]

- path-to-tests: directory containing test files
- --dev-repo: path to developer repository (for coverage calculation)
- --audience: report detail level (default: team)

## What It Produces

- QA_STATUS_REPORT.md -- metrics, testing pyramid distribution, risk areas, recommendations

## Instructions

1. Read `CLAUDE.md` -- testing pyramid targets, quality gates.
2. Invoke analyzer agent for status reporting:

Task(
  prompt="
    <objective>Produce QA_STATUS_REPORT.md with current test suite metrics and coverage</objective>
    <execution_context>@agents/qaa-analyzer.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    mode: status-report
    </parameters>
  "
)

3. Present report to user.

$ARGUMENTS
