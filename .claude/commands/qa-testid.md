# Inject Test IDs

Scan source code, identify interactive UI elements missing `data-testid` attributes, and inject them following the naming convention. This runs as Step 0 — before any test generation.

## Instructions

Use the `qa-testid-injector` skill to execute the full pipeline:

### Step 1: Get Target

Ask the user for the path to the frontend source code to scan.

### Step 2: SCAN — Identify Files

1. Detect framework (React, Vue, Angular, HTML) from package.json and file extensions
2. List all component files (excluding test/spec/stories files)
3. Prioritize by interaction density (forms > pages > layouts)
4. Produce SCAN_MANIFEST.md

### Step 3: AUDIT — Find Missing Test IDs

For each file, identify elements that:
- Are interactive (buttons, inputs, links, forms, selects)
- Are containers (modals, dropdowns, alerts)
- Are data display (tables, lists, badges)
- Already have data-testid (preserve these)
- Are missing data-testid (propose values)

Classify as P0 (must have), P1 (should have), P2 (nice to have).
Produce TESTID_AUDIT_REPORT.md.

### Step 4: INJECT — Apply Test IDs

Follow naming convention: `{context}-{description}-{element-type}` in kebab-case.
Inject data-testid as the LAST attribute before closing `>`.
Preserve all existing formatting. Only add the attribute — change nothing else.
Produce INJECTION_CHANGELOG.md.

### Step 5: VALIDATE

1. Syntax check all modified files
2. Uniqueness check (no duplicate testids per page)
3. Convention compliance check
4. Produce INJECTION_VALIDATION.md

$ARGUMENTS
