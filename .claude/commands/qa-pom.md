# Generate Page Object Models

Create or update Page Object Model files following CLAUDE.md POM rules. Checks for existing BasePage before creating one. Generates feature-specific POMs with Tier 1 locators, no assertions, and fluent action chaining.

## Usage

/qa-pom <path-to-pages> [--framework <name>]

- path-to-pages: directory containing page/view source files or URLs to model
- --framework: override framework auto-detection (playwright, cypress, selenium)

## What It Produces

- BasePage file (if not already present)
- Feature-specific POM files following `[PageName]Page.[ext]` naming convention

## Instructions

1. Read `CLAUDE.md` -- POM rules, locator tier hierarchy, naming conventions.
2. Invoke executor agent in POM-only mode:

Task(
  prompt="
    <objective>Generate Page Object Models following CLAUDE.md POM rules</objective>
    <execution_context>@agents/qaa-executor.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    mode: pom-only
    </parameters>
  "
)

$ARGUMENTS
