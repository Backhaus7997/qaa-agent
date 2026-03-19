# Phase 6: Delivery and User Experience - Research

**Researched:** 2026-03-19
**Domain:** Orchestrator deliver stage, slash commands, PR creation, documentation
**Confidence:** HIGH

## Summary

Phase 6 completes the QA Automation Agent system by wiring up the deliver stage in the orchestrator (branch creation, atomic commits, PR via gh CLI), rewriting all 13 slash commands to use the real agent pipeline, creating the PR template, and writing a junior-friendly README. After this phase, any QA engineer can run `/qa-start` and get a PR.

The codebase is well-structured with clear integration points. The orchestrator's deliver stage (Step 10) is explicitly stubbed with a "Phase 6 will implement" note. All 13 slash commands exist but contain generic instructions that reference old "skill" terminology rather than the real agent pipeline. No PR template exists yet. No README exists yet. The `cmdCommit` function in `bin/lib/commands.cjs` provides atomic commit capability, and `gh pr create` provides all needed flags (--draft, --label, --assignee, --base, --title, --body).

**Primary recommendation:** Structure this phase as 3 plans: (1) Deliver stage implementation in orchestrator + PR template, (2) Slash command rewrites for all 13 commands, (3) README documentation.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Full summary PR description (50-100 lines): analysis highlights, test counts by pyramid level, coverage metrics, validation pass/fail, list of generated files
- Reviewer checklist included: [ ] Test IDs unique, [ ] Assertions concrete, [ ] POM no assertions, [ ] No hardcoded credentials, etc.
- Labels: 'qa-automation', 'auto-generated'. Assigned to the QA engineer who ran the agent.
- Created as draft PR -- QA engineer reviews artifacts, marks ready when satisfied
- Targets main/master (default branch)
- All PR content in English
- Rewrite ALL 13 commands to reference the real pipeline (orchestrator + agents)
- /qa-start is THE primary command -- full pipeline, one-command experience
- Commands organized in 3 tiers:
  - Tier 1 (daily): /qa-start
  - Tier 2 (common): /qa-analyze, /qa-validate, /qa-testid
  - Tier 3 (specialized): /qa-fix, /qa-pom, /qa-audit, /qa-gap, /qa-blueprint, /qa-report, /qa-pyramid, /create-test, /update-test
- Junior-friendly README: step-by-step setup, detailed prerequisites, troubleshooting section
- Includes full example terminal output showing a successful /qa-start run (user input -> agent banners -> PR link)
- Quick-start section for seniors + detailed walkthrough for juniors

### Claude's Discretion
- Exact PR template markdown structure
- README section ordering
- How secondary commands reference agents internally
- Troubleshooting section content

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| DLVR-01 | Agent creates feature branch following naming convention qa/auto-{project}-{date} | Orchestrator Step 10 already defines branch naming; `git checkout -b` or `git switch -c` needed. Project name derived from target repo's package.json name field or directory basename. |
| DLVR-02 | Agent commits all artifacts atomically with descriptive messages | `cmdCommit` in bin/lib/commands.cjs provides atomic staging. Orchestrator Step 10 already defines commit message format per agent stage: `qa({agent}): {description}`. |
| DLVR-03 | Agent pushes branch and creates PR via gh CLI with summary template | `gh pr create --draft --title "..." --body "..." --label qa-automation --label auto-generated --assignee @me --base main`. HEREDOC for body. |
| DLVR-04 | PR template includes analysis summary, test counts, coverage metrics, validation status | PR template file `templates/pr-template.md` does not exist yet. Template structure defined in CLAUDE.md Git Workflow section. |
| UX-01 | /qa-start slash command orchestrates full pipeline based on repo count (1 or 2) | Current qa-start.md has generic instructions. Must be rewritten to invoke `@agents/qa-pipeline-orchestrator.md` via Task(). |
| UX-02 | /qa-analyze slash command runs analysis-only (no test generation, no PR) | Current qa-analyze.md has generic instructions. Must invoke scanner + analyzer agents directly, skip executor/validator/deliver stages. |
| UX-03 | /qa-validate slash command validates existing test files and classifies failures | Current qa-validate.md has generic instructions. Must invoke validator + bug-detective agents directly. |
| UX-04 | Additional slash commands for focused tasks | 10 remaining commands (qa-testid, qa-fix, qa-pom, qa-audit, qa-gap, qa-blueprint, qa-report, qa-pyramid, create-test, update-test) each need rewriting to invoke specific agents. |
| UX-05 | README.md explains installation, configuration, and usage for any QA engineer | No README exists yet. Must cover prerequisites, setup, all 13 commands, workflow options, troubleshooting. |
</phase_requirements>

## Standard Stack

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| gh CLI | 2.x | PR creation, label assignment, draft marking | Official GitHub CLI; `gh pr create` supports all required flags |
| git | 2.x | Branch creation, commits, push | Standard VCS; project already uses git via `execGit` in core.cjs |
| Node.js | 18+ | CLI tooling runtime | Project's existing runtime for all bin/ tooling |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| qaa-tools.cjs | local | State management, config, commits | Every pipeline stage transition in orchestrator |
| cmdCommit | local | Atomic git staging and commit | Each agent stage's artifacts commit |

### Alternatives Considered
None -- the stack is fully determined by the existing project infrastructure.

## Architecture Patterns

### Current Slash Command Pattern (to maintain)
```
.claude/commands/
  qa-start.md         -- Tier 1 (daily)
  qa-analyze.md        -- Tier 2 (common)
  qa-validate.md       -- Tier 2 (common)
  qa-testid.md         -- Tier 2 (common)
  qa-fix.md            -- Tier 3 (specialized)
  qa-pom.md            -- Tier 3 (specialized)
  qa-audit.md          -- Tier 3 (specialized)
  qa-gap.md            -- Tier 3 (specialized)
  qa-blueprint.md      -- Tier 3 (specialized)
  qa-report.md         -- Tier 3 (specialized)
  qa-pyramid.md        -- Tier 3 (specialized)
  create-test.md       -- Tier 3 (specialized)
  update-test.md       -- Tier 3 (specialized)
```

### Pattern 1: Slash Command Structure (Agent-Referencing)
**What:** Each slash command is a markdown file in `.claude/commands/` that Claude Code reads when the user types the command name. The rewritten commands must reference the actual agent files and pipeline.
**When to use:** All 13 commands.
**Example:**
```markdown
# QA Automation -- Full Pipeline

Run the complete QA automation pipeline against a target repository.

## Instructions

Read `CLAUDE.md` for all QA standards, then invoke the pipeline orchestrator:

Task(
  prompt="
    <objective>Run QA automation pipeline</objective>
    <execution_context>@agents/qa-pipeline-orchestrator.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    user_input: $ARGUMENTS
    </parameters>
  "
)
```

### Pattern 2: Orchestrator Deliver Stage (Branch + PR)
**What:** The deliver stage creates a branch, commits artifacts per-stage, pushes, and creates a draft PR.
**When to use:** Final stage of the orchestrator pipeline.
**Key sequence:**
```
1. Derive project name from target repo (package.json name or dir basename)
2. Create branch: git checkout -b qa/auto-{project}-{date}
3. Commit artifacts per stage (scanner, analyzer, executor, validator, etc.)
4. Push branch: git push -u origin qa/auto-{project}-{date}
5. Create PR: gh pr create --draft --title "..." --body "..." --label qa-automation --label auto-generated --assignee @me
6. Update state: deliver_status = complete
7. Print PR URL in pipeline summary
```

### Pattern 3: PR Template (Markdown in templates/)
**What:** A markdown template file that the orchestrator uses to build the PR body, with placeholders for dynamic content.
**When to use:** During PR creation in the deliver stage.
**Structure:**
```markdown
## QA Automation Report

### Analysis Summary
{analysis_summary}

### Test Suite
| Level | Count |
|-------|-------|
| Unit | {unit_count} |
| Integration | {integration_count} |
| API | {api_count} |
| E2E | {e2e_count} |
| **Total** | **{total_count}** |

### Coverage Metrics
{coverage_metrics}

### Validation Status
{validation_status}

### Generated Files
{file_list}

### Reviewer Checklist
- [ ] Test IDs are unique across all files
- [ ] Assertions use concrete values (no toBeTruthy/toBeDefined)
- [ ] Page objects contain no assertions
- [ ] No hardcoded credentials or secrets
- [ ] Locators follow tier hierarchy (data-testid first)
- [ ] Naming conventions match CLAUDE.md standards
- [ ] Testing pyramid distribution is reasonable for this project

---
Generated by QAA (QA Automation Agent)
```

### Anti-Patterns to Avoid
- **Direct git commands in orchestrator without error handling:** Always check return codes from git operations (branch creation may fail if branch exists, push may fail if remote is unreachable).
- **Hardcoding PR assignee:** Use `@me` (resolves to whoever is authenticated with gh CLI) rather than hardcoding a username.
- **Monolithic commit:** Do NOT commit all files in a single commit. The orchestrator defines per-agent-stage commits for traceability.
- **Forgetting to clear auto-chain flag:** At pipeline completion, always run `config-set workflow._auto_chain_active false`.

## Detailed Analysis: Current Commands vs Required Changes

### Tier 1: /qa-start (FULL REWRITE)
**Current content:** Generic instructions that manually describe workflow steps, references "skills" (old terminology), asks user questions inline, manually describes Option 1/2/3 logic.
**Required change:** Must invoke `@agents/qa-pipeline-orchestrator.md` via Task() with user's `$ARGUMENTS` as parameters. The orchestrator handles all pipeline logic, option routing, and agent spawning. The command should be lean -- just set up the invocation and let the orchestrator handle everything.
**Key detail:** Must pass `$ARGUMENTS` so user can specify `--dev-repo <path>` and `--qa-repo <path>`. The init qa-start function (`cmdInitQaStart`) already parses these from `process.argv`.

### Tier 2: /qa-analyze (FULL REWRITE)
**Current content:** Generic instructions that manually describe scanning and analysis steps, references manual file reading.
**Required change:** Must invoke scanner agent (`@agents/qaa-scanner.md`) followed by analyzer agent (`@agents/qaa-analyzer.md`). No plan/generate/validate/deliver stages. Should still use `qaa-tools.cjs init qa-start` to get context, but only run the first 2 pipeline stages.
**Key detail:** This is analysis-only -- no git operations, no PR, no test generation.

### Tier 2: /qa-validate (FULL REWRITE)
**Current content:** Generic instructions describing manual validation layers and failure classification.
**Required change:** Must invoke validator agent (`@agents/qaa-validator.md`) and optionally bug-detective agent (`@agents/qaa-bug-detective.md`). User provides path to test files. No scanning, no generation.
**Key detail:** Validator runs in "validation" mode (not "audit" mode). Bug detective only runs if failures are detected.

### Tier 2: /qa-testid (FULL REWRITE)
**Current content:** Generic instructions for scanning, auditing, injecting, and validating test IDs.
**Required change:** Must invoke testid-injector agent (`@agents/qaa-testid-injector.md`). Requires scanning first (invoke scanner), then inject.
**Key detail:** This modifies source code (the dev repo's frontend files). Must be clear about what it touches.

### Tier 3: /qa-fix (REWRITE)
**Current content:** Generic instructions for diagnosing and fixing broken tests.
**Required change:** Must invoke bug-detective agent (`@agents/qaa-bug-detective.md`). Bug detective classifies failures and auto-fixes TEST CODE ERRORS.
**Key detail:** Bug detective never touches application code -- only test code.

### Tier 3: /qa-pom (REWRITE)
**Current content:** Generic POM generation instructions with inline code examples.
**Required change:** Must invoke executor agent (`@agents/qaa-executor.md`) in POM-only mode. Executor already handles POM creation following CLAUDE.md rules.
**Key detail:** Should reference CLAUDE.md POM rules and the executor's existing BasePage check logic.

### Tier 3: /qa-audit (REWRITE)
**Current content:** Generic audit instructions with inline scoring table.
**Required change:** Must invoke validator agent (`@agents/qaa-validator.md`) in "audit" mode (produces QA_AUDIT_REPORT.md instead of VALIDATION_REPORT.md).
**Key detail:** Audit mode uses the 6-dimension scoring system from templates/qa-audit-report.md.

### Tier 3: /qa-gap (REWRITE)
**Current content:** Generic gap analysis instructions.
**Required change:** Must invoke scanner (both repos) then analyzer in "gap" mode. This is essentially Options 2/3 analysis stage without generation.
**Key detail:** Requires 2 repo paths (dev + QA). Produces GAP_ANALYSIS.md.

### Tier 3: /qa-blueprint (REWRITE)
**Current content:** Generic blueprint generation instructions.
**Required change:** Must invoke scanner then analyzer in "full" mode (Option 1), but only produce QA_REPO_BLUEPRINT.md. Or invoke analyzer directly if scan manifest already exists.
**Key detail:** Blueprint is Option 1 only -- no existing QA repo.

### Tier 3: /qa-report (REWRITE)
**Current content:** Generic status report instructions with audience-specific formatting.
**Required change:** Must invoke analyzer to produce a status report. Can reference existing analysis artifacts if available.
**Key detail:** This is a reporting/summary command, not a generation command.

### Tier 3: /qa-pyramid (REWRITE)
**Current content:** Generic pyramid analysis instructions.
**Required change:** Must invoke analyzer to produce pyramid analysis. Cross-references dev repo against existing tests.
**Key detail:** Analysis-only, no generation.

### Tier 3: /create-test (REWRITE)
**Current content:** Generic test creation instructions.
**Required change:** Must invoke executor agent for a specific feature. Should read existing analysis artifacts if available.
**Key detail:** Feature-focused -- user specifies which feature to test.

### Tier 3: /update-test (REWRITE)
**Current content:** Generic test improvement instructions.
**Required change:** Must invoke validator in audit mode to assess existing tests, then optionally executor to make improvements.
**Key detail:** Surgical -- never delete or rewrite working tests.

## Orchestrator Deliver Stage: Gap Analysis

The orchestrator's Step 10 (execute_deliver) at lines 673-737 of `qa-pipeline-orchestrator.md` currently:

**Has (from Phase 5):**
- Branch naming convention defined: `qa/auto-{project}-{date}`
- Commit strategy defined: per-agent-stage commits with specific message formats
- PR content requirements listed: analysis summary, test counts, coverage, validation status
- State updates: deliver_status running -> complete
- Stage banner printed
- Stub message: "Deliver stage defined. Actual branch/PR creation will be implemented in Phase 6"
- Fallback: commits all artifacts to current branch

**Needs (for Phase 6):**
1. Project name derivation logic (from target repo's package.json `name` field or directory basename)
2. Actual `git checkout -b qa/auto-{project}-{date}` execution
3. Per-stage artifact commits using the defined message format and `qaa-tools.cjs commit`
4. `git push -u origin {branch_name}` execution
5. `gh pr create --draft --title "..." --body "..." --label qa-automation --label auto-generated --assignee @me` execution
6. PR body construction from collected pipeline data (pyramid breakdown, test counts, validation status, file list)
7. Error handling for git/gh failures (branch exists, push fails, gh not authenticated)
8. PR URL capture and inclusion in pipeline summary banner
9. Replace the stub message and fallback commit with real implementation

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Git operations | Custom git wrapper | `execGit` from core.cjs | Already handles cwd, error capture, output parsing |
| Atomic commits | Manual git add/commit | `cmdCommit` via `qaa-tools.cjs commit` | Handles config checks, gitignore, staging, error states |
| PR creation | Custom HTTP API calls | `gh pr create` CLI | Handles auth, labels, assignees, draft mode, body formatting |
| Branch naming | Inline string building | Derive from init context `date` field + project name | Consistent with existing pattern in orchestrator |
| State transitions | Manual STATE.md editing | `qaa-tools.cjs state patch` | Handles frontmatter, field updates, state validation |

## Common Pitfalls

### Pitfall 1: gh CLI Not Authenticated
**What goes wrong:** `gh pr create` fails with authentication error when QA engineer hasn't run `gh auth login`.
**Why it happens:** gh CLI requires separate authentication from git.
**How to avoid:** README must list `gh auth login` as a prerequisite step. Deliver stage should check `gh auth status` before attempting PR creation and provide a clear error message.
**Warning signs:** "gh: not authenticated" or "gh: authorization required" in error output.

### Pitfall 2: Branch Already Exists
**What goes wrong:** `git checkout -b qa/auto-{project}-{date}` fails if branch already exists (e.g., re-running pipeline on same day).
**Why it happens:** Branch naming includes date but not a unique suffix.
**How to avoid:** Check if branch exists first; if it does, append a numeric suffix (e.g., `-2`) or delete the old branch. The orchestrator should handle this gracefully.
**Warning signs:** "fatal: A branch named 'qa/auto-...' already exists" error.

### Pitfall 3: Slash Command Too Verbose
**What goes wrong:** Commands that duplicate logic already in agents are fragile and diverge from agent behavior.
**Why it happens:** Temptation to put detailed step-by-step instructions in the slash command instead of delegating to the agent.
**How to avoid:** Slash commands should be thin wrappers -- gather user input, invoke the right agent(s) via Task(), let the agent handle the logic. The command file provides context and routing, not implementation.
**Warning signs:** Slash command file is more than 80 lines, contains hardcoded logic that duplicates agent steps.

### Pitfall 4: PR Body Exceeds GitHub Limits
**What goes wrong:** PR body with full file lists for large repos can exceed GitHub's 65,536 character limit.
**Why it happens:** Listing every generated file path in the PR body for a large project.
**How to avoid:** Summarize file counts by category rather than listing every file. Only list files when count is manageable (< 50). For larger counts, provide summary table.
**Warning signs:** `gh pr create` returns "body is too long" error.

### Pitfall 5: Default Branch Not `main`
**What goes wrong:** `--base main` fails if the repo's default branch is `master` or something else.
**Why it happens:** Hardcoding `main` instead of detecting the default branch.
**How to avoid:** Use `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'` to detect the default branch, or omit `--base` entirely (gh CLI defaults to the repo's default branch).
**Warning signs:** "no branch named 'main'" error.

### Pitfall 6: Orphan Commits When Creating New Branch
**What goes wrong:** Creating a branch from the wrong base (e.g., from an already-checked-out feature branch instead of main).
**Why it happens:** Not ensuring we're on the default branch before creating the feature branch.
**How to avoid:** The deliver stage should ensure it creates the branch from the default branch: `git checkout main && git checkout -b qa/auto-...`. Or use `git checkout -b qa/auto-... main` to specify the start point.
**Warning signs:** PR shows unexpected diff including unrelated changes.

## Code Examples

### Deriving Project Name
```bash
# From target repo's package.json
PROJECT_NAME=$(node -e "try { const p = require('${dev_repo_path}/package.json'); console.log(p.name || ''); } catch { console.log(''); }")

# Fallback to directory basename
if [ -z "$PROJECT_NAME" ]; then
  PROJECT_NAME=$(basename "${dev_repo_path}")
fi

# Sanitize for branch naming (kebab-case, no special chars)
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
```

### Branch Creation with Collision Handling
```bash
BRANCH="qa/auto-${PROJECT_NAME}-${DATE}"

# Check if branch exists locally or remotely
if git rev-parse --verify "$BRANCH" 2>/dev/null || git rev-parse --verify "origin/$BRANCH" 2>/dev/null; then
  # Append suffix
  SUFFIX=2
  while git rev-parse --verify "${BRANCH}-${SUFFIX}" 2>/dev/null; do
    SUFFIX=$((SUFFIX + 1))
  done
  BRANCH="${BRANCH}-${SUFFIX}"
fi

# Create from default branch
DEFAULT_BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || echo "main")
git checkout -b "$BRANCH" "$DEFAULT_BRANCH"
```

### Per-Stage Atomic Commits
```bash
# Scanner artifacts
node bin/qaa-tools.cjs commit "qa(scanner): produce SCAN_MANIFEST.md for ${PROJECT_NAME}" --files .qa-output/SCAN_MANIFEST.md

# Analyzer artifacts (Option 1)
node bin/qaa-tools.cjs commit "qa(analyzer): produce QA_ANALYSIS.md and TEST_INVENTORY.md" --files .qa-output/QA_ANALYSIS.md .qa-output/TEST_INVENTORY.md .qa-output/QA_REPO_BLUEPRINT.md

# Executor artifacts
node bin/qaa-tools.cjs commit "qa(executor): generate ${TOTAL_FILES} test files with POMs and fixtures" --files ${GENERATED_FILE_PATHS}

# Validator artifacts
node bin/qaa-tools.cjs commit "qa(validator): validate generated tests - ${STATUS} with ${CONFIDENCE} confidence" --files .qa-output/VALIDATION_REPORT.md
```

### PR Creation via gh CLI
```bash
gh pr create \
  --draft \
  --title "qa: automated test suite for ${PROJECT_NAME}" \
  --body "$(cat <<'PREOF'
## QA Automation Report

### Analysis Summary
- **Architecture:** ${ARCH_TYPE}
- **Framework:** ${FRAMEWORK}
- **Risk Areas:** ${RISK_COUNT_HIGH} HIGH, ${RISK_COUNT_MEDIUM} MEDIUM, ${RISK_COUNT_LOW} LOW

### Test Suite
| Level | Count |
|-------|-------|
| Unit | ${UNIT_COUNT} |
| Integration | ${INTEGRATION_COUNT} |
| API | ${API_COUNT} |
| E2E | ${E2E_COUNT} |
| **Total** | **${TOTAL_COUNT}** |

### Coverage Metrics
- Modules covered: ${MODULES_COVERED}
- Estimated coverage: ${COVERAGE_ESTIMATE}

### Validation Status
- **Result:** ${VALIDATION_STATUS}
- **Confidence:** ${CONFIDENCE}
- **Fix loops used:** ${FIX_LOOPS}
- **Issues found/fixed:** ${ISSUES_FOUND}/${ISSUES_FIXED}

### Generated Files
${FILE_LIST}

### Reviewer Checklist
- [ ] Test IDs are unique across all files
- [ ] Assertions use concrete values (no toBeTruthy/toBeDefined)
- [ ] Page objects contain no assertions
- [ ] No hardcoded credentials or secrets
- [ ] Locators follow tier hierarchy (data-testid first)
- [ ] Naming conventions match CLAUDE.md standards
- [ ] Testing pyramid distribution is reasonable

---
Generated by QAA (QA Automation Agent)
PREOF
)" \
  --label "qa-automation" \
  --label "auto-generated" \
  --assignee "@me"
```

### Slash Command Pattern: Tier 1 (qa-start)
```markdown
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
```

### Slash Command Pattern: Tier 2 (qa-analyze)
```markdown
# QA Repository Analysis

Analysis-only mode. Scans a repository, detects framework/stack, and produces QA assessment documents. No test generation. No PR.

## Usage

/qa-analyze [--dev-repo <path>] [--qa-repo <path>]

## Instructions

1. Read `CLAUDE.md` -- all QA standards.
2. Initialize context:
   node bin/qaa-tools.cjs init qa-start [user arguments]

3. Invoke scanner agent:
Task(
  prompt="<objective>Scan repository</objective>
  <execution_context>@agents/qaa-scanner.md</execution_context>
  ..."
)

4. Invoke analyzer agent:
Task(
  prompt="<objective>Analyze repository</objective>
  <execution_context>@agents/qaa-analyzer.md</execution_context>
  ..."
)

5. Present results to user. No git operations.

$ARGUMENTS
```

### Slash Command Pattern: Tier 3 (qa-fix)
```markdown
# Fix Broken Tests

Diagnose and fix broken test files. Classifies each failure, auto-fixes TEST CODE ERRORS, and flags APPLICATION BUGS.

## Usage

/qa-fix <path-to-tests> [error output]

## Instructions

1. Read `CLAUDE.md` -- classification rules and quality gates.
2. Invoke bug-detective agent:

Task(
  prompt="<objective>Classify and fix test failures</objective>
  <execution_context>@agents/qaa-bug-detective.md</execution_context>
  <files_to_read>
  - CLAUDE.md
  - {test files from user input}
  </files_to_read>
  <parameters>
  test_path: {from $ARGUMENTS}
  output_path: .qa-output/FAILURE_CLASSIFICATION_REPORT.md
  </parameters>
  "
)

$ARGUMENTS
```

## README Structure

The README must serve two audiences (per locked decision): seniors who want quick-start, and juniors who need step-by-step guidance.

### Recommended Section Order

```markdown
# QAA -- QA Automation Agent

## What This Does
[2-3 sentence overview]

## Quick Start (for experienced users)
[5-line setup + one command]

## Prerequisites
- Node.js 18+
- Claude Code (Anthropic) with Pro or Max plan
- gh CLI (authenticated)
- Git

## Installation
[Step by step]

## Configuration
[config.json options, model profiles]

## Usage

### /qa-start -- Full Pipeline (Tier 1)
[Detailed explanation + example output]

### Analysis Commands (Tier 2)
- /qa-analyze
- /qa-validate
- /qa-testid

### Specialized Commands (Tier 3)
[Brief description of each]

## Workflow Options
[Option 1, 2, 3 explanation]

## Example Output
[Full terminal session showing /qa-start run]

## Troubleshooting
[Common errors and fixes]

## Project Structure
[File tree of this repo]
```

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual verification (this is a documentation/configuration phase) |
| Config file | N/A |
| Quick run command | `node bin/qaa-tools.cjs validate health` |
| Full suite command | Manual: verify each slash command loads, orchestrator has no stub, PR template exists |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DLVR-01 | Branch creation with naming convention | manual | Verify orchestrator has `git checkout -b qa/auto-{project}-{date}` logic | N/A -- orchestrator file |
| DLVR-02 | Atomic commits per agent stage | manual | Verify orchestrator calls `qaa-tools.cjs commit` per stage | N/A -- orchestrator file |
| DLVR-03 | Push + PR creation via gh CLI | manual | Verify orchestrator has `gh pr create --draft` command | N/A -- orchestrator file |
| DLVR-04 | PR template with required sections | manual | `test -f templates/pr-template.md` | Wave 0 |
| UX-01 | /qa-start invokes orchestrator | manual | Verify `.claude/commands/qa-start.md` references `@agents/qa-pipeline-orchestrator.md` | Exists, needs rewrite |
| UX-02 | /qa-analyze runs analysis only | manual | Verify `.claude/commands/qa-analyze.md` references scanner + analyzer agents | Exists, needs rewrite |
| UX-03 | /qa-validate validates + classifies | manual | Verify `.claude/commands/qa-validate.md` references validator + bug-detective agents | Exists, needs rewrite |
| UX-04 | Additional focused commands | manual | Verify each of 10 remaining commands references correct agent(s) | Exist, need rewrite |
| UX-05 | README.md with full documentation | manual | `test -f README.md` | Wave 0 |

### Sampling Rate
- **Per task commit:** `node bin/qaa-tools.cjs validate health`
- **Per wave merge:** Manual review of each artifact
- **Phase gate:** All 13 commands reference real agents, orchestrator has no stubs, PR template exists, README exists

### Wave 0 Gaps
- [ ] `templates/pr-template.md` -- PR body template with placeholders
- [ ] `README.md` -- Project documentation

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| "Skills" terminology in commands | Agent invocation via Task() with execution_context | Phase 5 (orchestrator) | All commands must use `@agents/qaa-*.md` reference pattern |
| Manual pipeline steps in commands | Orchestrator handles all pipeline logic | Phase 5 | Slash commands become thin wrappers, not implementation |
| No deliver stage | Stubbed deliver in orchestrator | Phase 5 | Phase 6 replaces stub with real implementation |

## Open Questions

1. **How to handle repos without a remote origin?**
   - What we know: `git push` requires a remote. `gh pr create` requires a GitHub repo.
   - What's unclear: Should the deliver stage check for remote existence before attempting push?
   - Recommendation: Add a pre-flight check: `git remote get-url origin`. If no remote, print clear error message and skip PR creation. Still commit artifacts locally.

2. **Should per-stage commits happen during pipeline execution or batched at deliver?**
   - What we know: The orchestrator currently has each agent committing its own artifacts during execution. The deliver stage also commits.
   - What's unclear: Whether to re-commit in deliver stage or just push existing commits.
   - Recommendation: Agents commit during execution (already implemented). Deliver stage creates the branch, cherry-picks or re-bases existing commits onto the new branch, then pushes. Alternatively, deliver stage creates branch first, then agents commit onto it during pipeline execution. The latter is simpler -- create branch at pipeline start, not at deliver stage.

3. **gh pr create --assignee @me -- what if running in CI?**
   - What we know: `@me` resolves to the authenticated gh user. In CI, gh may be authenticated as a bot.
   - What's unclear: Should this be configurable?
   - Recommendation: Use `@me` as default. The user context specifies "Assigned to the QA engineer who ran the agent" -- `@me` fulfills this for local runs. CI is out of scope for v1.

## Sources

### Primary (HIGH confidence)
- `agents/qa-pipeline-orchestrator.md` -- Full orchestrator with deliver stage stub (1,027 lines)
- `bin/lib/commands.cjs` -- cmdCommit implementation (lines 217-263)
- `bin/lib/init.cjs` -- cmdInitQaStart implementation (lines 622-826)
- `CLAUDE.md` -- Git Workflow section, Module Boundaries, Quality Gates
- `.claude/commands/*.md` -- All 13 current slash command files
- `gh pr create` official docs at https://cli.github.com/manual/gh_pr_create

### Secondary (MEDIUM confidence)
- GitHub PR body character limit (65,536) -- widely documented

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all tools are already in the project or standard CLI tools
- Architecture: HIGH -- patterns are extensions of existing project patterns
- Pitfalls: HIGH -- based on direct codebase analysis and known gh CLI behaviors
- Deliver stage gaps: HIGH -- direct comparison of stub vs requirements
- Slash command analysis: HIGH -- read all 13 files and compared to agent inventory

**Research date:** 2026-03-19
**Valid until:** 2026-04-19 (stable -- all tools and patterns are established)
