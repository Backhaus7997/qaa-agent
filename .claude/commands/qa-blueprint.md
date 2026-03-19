# QA Repository Blueprint

Generate a complete QA repository structure blueprint for a project that has no existing QA repo. Includes recommended stack, folder structure, config files, CI/CD pipeline, and definition of done.

## Usage

/qa-blueprint [--dev-repo <path>]

- No arguments: analyzes current directory
- --dev-repo: explicit path to developer repository

## What It Produces

- SCAN_MANIFEST.md -- dev repo scan with framework detection
- QA_REPO_BLUEPRINT.md -- folder structure, recommended stack, config files, CI/CD strategy

## Instructions

1. Read `CLAUDE.md` -- repo structure, naming conventions, testing pyramid.
2. Invoke scanner agent:

Task(
  prompt="
    <objective>Scan developer repository and produce SCAN_MANIFEST.md</objective>
    <execution_context>@agents/qaa-scanner.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    </parameters>
  "
)

3. Invoke analyzer agent in full mode (blueprint):

Task(
  prompt="
    <objective>Produce QA_REPO_BLUEPRINT.md with complete repository structure</objective>
    <execution_context>@agents/qaa-analyzer.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    - .qa-output/SCAN_MANIFEST.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    mode: full
    </parameters>
  "
)

4. Present blueprint to user. No git operations.

$ARGUMENTS
