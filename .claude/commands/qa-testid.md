# Inject Test IDs

Scan frontend source code, audit missing data-testid attributes, and inject them following the naming convention in CLAUDE.md. Creates a separate branch for the changes.

## Usage

/qa-testid <path-to-frontend-source>

- path-to-frontend-source: directory containing React/Vue/Angular/HTML components

## What It Produces

- TESTID_AUDIT_REPORT.md -- coverage score, missing elements, proposed values by priority
- Modified source files with data-testid attributes injected

## Instructions

1. Read `CLAUDE.md` -- data-testid Convention section for naming rules.
2. Initialize context:
   ```bash
   node bin/qaa-tools.cjs init qa-start --dev-repo [user path]
   ```
3. Invoke scanner to identify component files:

Task(
  prompt="
    <objective>Scan repository to identify frontend component files</objective>
    <execution_context>@agents/qaa-scanner.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    </parameters>
  "
)

4. Invoke testid-injector agent:

Task(
  prompt="
    <objective>Audit missing data-testid attributes and inject following naming convention</objective>
    <execution_context>@agents/qaa-testid-injector.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    - .qa-output/SCAN_MANIFEST.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    </parameters>
  "
)

$ARGUMENTS
