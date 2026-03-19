# QA Repository Analysis

Analysis-only mode. Scans a repository, detects framework and stack, and produces QA assessment documents. No test generation. No PR creation.

## Usage

/qa-analyze [--dev-repo <path>] [--qa-repo <path>]

- No arguments: analyzes current directory
- --dev-repo: explicit path to developer repository
- --qa-repo: path to existing QA repository (produces gap analysis instead of blueprint)

## What It Produces

- SCAN_MANIFEST.md -- file tree, framework detection, testable surfaces
- QA_ANALYSIS.md -- architecture overview, risk assessment, testing pyramid
- TEST_INVENTORY.md -- prioritized test cases with IDs and explicit outcomes
- QA_REPO_BLUEPRINT.md (if no QA repo) or GAP_ANALYSIS.md (if QA repo provided)

## Instructions

1. Read `CLAUDE.md` -- all QA standards.
2. Initialize pipeline context:
   ```bash
   node bin/qaa-tools.cjs init qa-start [user arguments]
   ```
3. Invoke scanner agent:

Task(
  prompt="
    <objective>Scan repository and produce SCAN_MANIFEST.md</objective>
    <execution_context>@agents/qaa-scanner.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    </parameters>
  "
)

4. Invoke analyzer agent:

Task(
  prompt="
    <objective>Analyze repository and produce QA_ANALYSIS.md, TEST_INVENTORY.md, and blueprint or gap analysis</objective>
    <execution_context>@agents/qaa-analyzer.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    - .qa-output/SCAN_MANIFEST.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    </parameters>
  "
)

5. Present results to user. No git operations. No test generation.

$ARGUMENTS
