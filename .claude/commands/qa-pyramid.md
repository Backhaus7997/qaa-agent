# Testing Pyramid Analysis

Analyze a project's test distribution against the ideal testing pyramid from CLAUDE.md. Compares actual percentages to targets and produces an action plan to reach the recommended distribution.

## Usage

/qa-pyramid <path-to-tests> [--dev-repo <path>]

- path-to-tests: directory containing test files
- --dev-repo: path to developer repository (for architecture-aware target adjustment)

## What It Produces

- PYRAMID_ANALYSIS.md -- current vs target distribution, gap table, prioritized action plan

## Instructions

1. Read `CLAUDE.md` -- testing pyramid target percentages.
2. Invoke analyzer agent for pyramid analysis:

Task(
  prompt="
    <objective>Produce PYRAMID_ANALYSIS.md comparing actual test distribution to target pyramid</objective>
    <execution_context>@agents/qaa-analyzer.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    mode: pyramid-analysis
    </parameters>
  "
)

3. Present analysis with action plan to user.

$ARGUMENTS
