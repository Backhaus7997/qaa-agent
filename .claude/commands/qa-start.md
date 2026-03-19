# QA Automation -- Full Pipeline

Run the complete QA automation pipeline. Analyzes a repository, generates a standards-compliant test suite, validates it, and delivers everything as a draft PR.

## Usage

/qa-start [--dev-repo <path>] [--qa-repo <path>] [--auto]

- No arguments: uses current directory as dev repo (Option 1)
- --dev-repo: explicit path to developer repository
- --qa-repo: path to existing QA repository (triggers Option 2 or 3)
- --auto: enable auto-advance mode (no pauses at safe checkpoints)

## Instructions

1. Read `CLAUDE.md` -- all QA standards that govern the pipeline.
2. Read `agents/qa-pipeline-orchestrator.md` -- the pipeline controller.
3. Invoke the orchestrator:

Task(
  prompt="
    <objective>Run complete QA automation pipeline</objective>
    <execution_context>@agents/qa-pipeline-orchestrator.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    </parameters>
  "
)

$ARGUMENTS
