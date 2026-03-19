# QA Gap Analysis

Compare a developer repository against its QA repository to identify coverage gaps. Requires both repo paths. Produces a detailed gap report showing missing tests, broken tests, and quality assessment.

## Usage

/qa-gap --dev-repo <path> --qa-repo <path>

- --dev-repo: path to the developer repository (required)
- --qa-repo: path to the existing QA repository (required)

## What It Produces

- SCAN_MANIFEST.md -- scan of both repositories
- GAP_ANALYSIS.md -- coverage map, missing tests with IDs, broken tests, quality assessment

## Instructions

1. Read `CLAUDE.md` -- testing pyramid, test spec rules, quality gates.
2. Invoke scanner agent to scan both repositories:

Task(
  prompt="
    <objective>Scan both developer and QA repositories and produce SCAN_MANIFEST.md</objective>
    <execution_context>@agents/qaa-scanner.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    </parameters>
  "
)

3. Invoke analyzer agent in gap mode:

Task(
  prompt="
    <objective>Produce GAP_ANALYSIS.md comparing dev repo against QA repo</objective>
    <execution_context>@agents/qaa-analyzer.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    - .qa-output/SCAN_MANIFEST.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    mode: gap
    </parameters>
  "
)

4. Present results. No test generation. No git operations.

$ARGUMENTS
