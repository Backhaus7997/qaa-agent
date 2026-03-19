# QAA -- QA Automation Agent

Multi-agent QA automation system for Claude Code. Point it at any repository -- it analyzes the codebase, generates a standards-compliant test suite, validates everything, and delivers the result as a draft PR. Built for QA engineers at Capmation. Runs locally via Claude Code.

No manual test writing. No guessing what to cover. One command, full pipeline.

## Quick Start

Prerequisites: Node.js 18+, Claude Code (Pro or Max plan), gh CLI (authenticated), Git.

```bash
# 1. Clone this repo alongside your project
git clone <this-repo-url> qa-agent

# 2. Open Claude Code in the qa-agent directory

# 3. Run the full pipeline against your dev repo
/qa-start --dev-repo /path/to/your-project

# 4. Wait for the pipeline to complete, then review the draft PR
```

For an existing QA repository:

```bash
/qa-start --dev-repo /path/to/dev-repo --qa-repo /path/to/qa-repo
```

For fully unattended execution (auto-approve safe checkpoints):

```bash
/qa-start --dev-repo /path/to/your-project --auto
```

## Prerequisites

Every tool below must be installed and working before running the pipeline.

- **Node.js 18+** -- Runtime for CLI tooling. The pipeline uses Node for configuration management and artifact validation.
- **Claude Code** (Anthropic) -- The AI coding assistant that executes the agents. You must have a **Pro or Max plan** for access to the Opus model, which all agents require.
- **gh CLI** -- GitHub's official command-line tool for creating pull requests. Install from https://cli.github.com and authenticate before first use.
- **Git** -- Version control. The target repository must have a remote origin configured for PR delivery.

### Verifying Prerequisites

Run each command and confirm the expected output:

```bash
node --version          # Must show v18.x.x or higher
claude --version        # Must show Claude Code version
gh auth status          # Must show "Logged in to github.com"
git --version           # Must show git version 2.x+
```

If any command fails, install the missing tool before proceeding.

## Installation

1. Clone or copy this repository into a local directory:
   ```bash
   git clone <this-repo-url> qa-agent
   cd qa-agent
   ```

2. Verify the setup is healthy:
   ```bash
   node bin/qaa-tools.cjs validate health
   ```

3. Open Claude Code in this directory. The `.claude/commands/` directory provides all 13 slash commands automatically -- no additional setup needed.

## Configuration

The pipeline behavior is controlled by `.planning/config.json`. Default values work for most projects.

| Setting | Options | Default | Description |
|---------|---------|---------|-------------|
| `mode` | `quality`, `balanced`, `budget` | `quality` | Controls which AI models agents use |
| `granularity` | `coarse`, `standard`, `fine` | `standard` | Detail level of analysis and generation |
| `parallelization` | `true`, `false` | `true` | Enable wave-based parallel agent execution |
| `workflow.auto_advance` | `true`, `false` | `false` | Auto-approve safe checkpoints without pausing |

Set values via CLI:

```bash
node bin/qaa-tools.cjs config set mode balanced
node bin/qaa-tools.cjs config set workflow.auto_advance true
```

Or edit `.planning/config.json` directly.

## Commands

All commands are available as slash commands in Claude Code. They are organized into three tiers by frequency of use.

### /qa-start -- Full Pipeline (Tier 1: Daily Use)

The primary command. Runs the entire QA automation pipeline from scan to PR delivery.

```
/qa-start [--dev-repo <path>] [--qa-repo <path>] [--auto]
```

**Arguments:**
- No arguments: uses current directory as the dev repo (Option 1: dev-only)
- `--dev-repo`: explicit path to the developer repository
- `--qa-repo`: path to an existing QA repository (triggers Option 2 or 3 based on maturity score)
- `--auto`: enable auto-advance mode (skips safe checkpoint pauses)

**What happens:**
1. Scans the repository -- detects framework, language, testable surfaces
2. Analyzes architecture -- produces risk assessment, test inventory, blueprint
3. Injects test IDs (if frontend components detected)
4. Plans test generation -- groups test cases by feature domain
5. Generates test files -- unit, API, integration, E2E with Page Object Models
6. Validates generated tests -- 4-layer validation with auto-fix (up to 3 loops)
7. Classifies any remaining failures (if present)
8. Delivers everything as a draft PR on a `qa/auto-{project}-{date}` branch

**What it produces:**
- SCAN_MANIFEST.md, QA_ANALYSIS.md, TEST_INVENTORY.md, QA_REPO_BLUEPRINT.md
- Generated test files, POMs, fixtures, and config files
- VALIDATION_REPORT.md with confidence level (HIGH/MEDIUM/LOW)
- A draft pull request with full analysis summary

### Analysis Commands (Tier 2: Common Use)

#### /qa-analyze -- Repository Analysis

Scan and analyze a repository without generating tests. Produces assessment documents only.

```
/qa-analyze [--dev-repo <path>] [--qa-repo <path>]
```

Produces: SCAN_MANIFEST.md, QA_ANALYSIS.md, TEST_INVENTORY.md, and either QA_REPO_BLUEPRINT.md (no QA repo) or GAP_ANALYSIS.md (QA repo provided).

#### /qa-validate -- Test Validation

Validate existing test files against QA standards. Runs 4-layer checks (syntax, structure, dependencies, logic) and classifies failures.

```
/qa-validate <path-to-tests> [--framework <name>]
```

Produces: VALIDATION_REPORT.md. If failures are found, also produces FAILURE_CLASSIFICATION_REPORT.md.

#### /qa-testid -- Test ID Injection

Scan frontend source code, audit missing `data-testid` attributes, and inject them using the project naming convention. Creates a separate branch for changes.

```
/qa-testid <path-to-frontend-source>
```

Produces: TESTID_AUDIT_REPORT.md and modified source files with `data-testid` attributes.

### Specialized Commands (Tier 3)

| Command | Purpose | Usage |
|---------|---------|-------|
| `/qa-fix` | Diagnose and fix broken test files | `/qa-fix <path-to-tests> [error output]` |
| `/qa-pom` | Generate Page Object Model files | `/qa-pom <path-to-pages> [--framework <name>]` |
| `/qa-audit` | Full 6-dimension quality audit of a test suite | `/qa-audit <path-to-tests> [--dev-repo <path>]` |
| `/qa-gap` | Gap analysis between dev and QA repos | `/qa-gap --dev-repo <path> --qa-repo <path>` |
| `/qa-blueprint` | Generate QA repository structure blueprint | `/qa-blueprint [--dev-repo <path>]` |
| `/qa-report` | Generate QA status report (team/management/client) | `/qa-report <path-to-tests> [--audience <level>]` |
| `/qa-pyramid` | Analyze test distribution vs. ideal pyramid | `/qa-pyramid <path-to-tests> [--dev-repo <path>]` |
| `/create-test` | Generate tests for a specific feature | `/create-test <feature-name> [--dev-repo <path>]` |
| `/update-test` | Improve existing tests without rewriting them | `/update-test <path-to-tests> [--scope <type>]` |

## Workflow Options

The pipeline automatically selects the right workflow based on the repositories you provide.

### Option 1: Dev-Only Repository

**When to use:** The project has no existing QA repository. You are starting QA from scratch.

**Trigger:** Run `/qa-start --dev-repo <path>` with no `--qa-repo` argument.

**What happens:** Full pipeline -- scan, analyze, plan, generate, validate, deliver. Produces a complete test suite with POMs, fixtures, config files, and a QA repository blueprint. The draft PR contains everything needed to bootstrap a QA repo.

### Option 2: Dev + Immature QA Repository

**When to use:** A QA repo exists but has low coverage, inconsistent patterns, or broken tests. Maturity score below 70%.

**Trigger:** Run `/qa-start --dev-repo <path> --qa-repo <path>` where the QA repo scores below the maturity threshold.

**What happens:** Scans both repos, runs gap analysis, fixes broken tests, adds missing coverage, standardizes existing tests to match CLAUDE.md conventions. Produces a PR that improves the existing test suite rather than replacing it.

### Option 3: Dev + Mature QA Repository

**When to use:** A solid QA repo already exists with good coverage and patterns. Maturity score 70% or above.

**Trigger:** Run `/qa-start --dev-repo <path> --qa-repo <path>` where the QA repo scores at or above the maturity threshold.

**What happens:** Scans both repos, identifies only thin coverage areas, adds surgical test additions without touching existing working tests. Produces a minimal PR with targeted additions.

## Example Output

The following shows a typical `/qa-start` run against a Next.js e-commerce project:

```
> /qa-start --dev-repo ./shopflow --auto

+------------------------------------------+
|  QA Automation Pipeline                  |
|  Option: 1 (Dev-only)                   |
|  Target: shopflow                        |
+------------------------------------------+

+------------------------------------------+
|  STAGE 1: Scan                           |
|  Status: Running...                      |
+------------------------------------------+
Scanner complete. 847 files scanned, 32 testable surfaces identified.
Output: .qa-output/SCAN_MANIFEST.md

+------------------------------------------+
|  STAGE 2: Analyze                        |
|  Status: Running...                      |
+------------------------------------------+
Architecture: Next.js 14, TypeScript, Prisma ORM, REST API
Risk areas: authentication (HIGH), payment processing (HIGH), cart logic (MEDIUM)
Output: .qa-output/QA_ANALYSIS.md, .qa-output/TEST_INVENTORY.md, .qa-output/QA_REPO_BLUEPRINT.md

+------------------------------------------+
|  STAGE 3: Test ID Injection              |
|  Status: Running...                      |
+------------------------------------------+
Frontend detected. Auditing data-testid coverage...
Coverage: 12% (18 of 147 interactive elements have data-testid)
Injected 94 data-testid attributes across 23 components.
Output: .qa-output/TESTID_AUDIT_REPORT.md

+------------------------------------------+
|  STAGE 4: Plan                           |
|  Status: Running...                      |
+------------------------------------------+
Grouped 42 test cases into 6 feature domains: auth, products, cart, checkout, orders, admin.

+------------------------------------------+
|  STAGE 5: Generate                       |
|  Status: Running...                      |
+------------------------------------------+
Generated 38 test files: 24 unit, 8 API, 4 integration, 2 E2E
Created 6 Page Object Models, 4 fixture files, 2 config files.

+------------------------------------------+
|  STAGE 6: Validate                       |
|  Status: Running...                      |
+------------------------------------------+
Validation loop 1: 3 issues found, 3 auto-fixed.
Validation loop 2: all files PASS.
Confidence: HIGH

+------------------------------------------+
|  STAGE 7: Deliver                        |
|  Status: Running...                      |
+------------------------------------------+
Branch created: qa/auto-shopflow-2026-03-19
PR created: https://github.com/client/shopflow/pull/42

+------------------------------------------+
|  PIPELINE COMPLETE                       |
|  Tests: 24 unit, 8 API, 4 integration,  |
|         2 E2E (38 total)                 |
|  Validation: PASS (HIGH confidence)      |
|  PR: https://github.com/client/shopflow  |
|      /pull/42                            |
+------------------------------------------+
```

## Troubleshooting

### "gh: not authenticated"

The gh CLI needs to be authenticated before the pipeline can create PRs. Run:

```bash
gh auth login
```

Select GitHub.com, HTTPS protocol, and authenticate via browser. After login, verify with `gh auth status`.

### "No git remote found"

The target repository must have a remote origin configured for the deliver stage to push and create a PR. Add one:

```bash
cd /path/to/target-repo
git remote add origin https://github.com/org/repo.git
```

If you only want local output without a PR, the pipeline will fall back gracefully -- all artifacts are still written to `.qa-output/`.

### "A branch named 'qa/auto-...' already exists"

A pipeline was previously run on the same day against the same project. The system automatically appends a numeric suffix (`-2`, `-3`, etc.) to avoid collisions. If you want to clean up old branches:

```bash
git branch -D qa/auto-shopflow-2026-03-19
```

### Pipeline stalls at a checkpoint

Some pipeline stages have verification checkpoints that pause for your input. Type your response in the Claude Code terminal to continue. To skip safe checkpoints automatically, use the `--auto` flag:

```
/qa-start --dev-repo <path> --auto
```

Or enable auto-advance globally:

```bash
node bin/qaa-tools.cjs config set workflow.auto_advance true
```

### Tests fail validation after 3 fix loops

The validator attempted 3 automatic fix cycles but could not resolve all issues. Review the details in `.qa-output/VALIDATION_REPORT.md` to understand what failed and why. Fix the remaining issues manually, then re-validate:

```
/qa-validate <path-to-test-files>
```

### Claude Code says "model not available"

You need a Pro or Max plan for Opus model access. Check your plan at https://console.anthropic.com. The pipeline requires Opus for all agent operations.

## Project Structure

```
qa-agent-gsd/
  agents/                          -- Agent workflow definitions
    qa-pipeline-orchestrator.md    --   Main pipeline controller (3 options)
    qaa-scanner.md                 --   Repository scanner agent
    qaa-analyzer.md                --   Architecture analyzer agent
    qaa-planner.md                 --   Test generation planner agent
    qaa-executor.md                --   Test file generator agent
    qaa-validator.md               --   Test validation agent
    qaa-testid-injector.md         --   Test ID injection agent
    qaa-bug-detective.md           --   Failure classification agent
  bin/                             -- CLI tooling
    qaa-tools.cjs                  --   Main CLI entry point
    lib/                           --   CLI module library
  templates/                       -- Output artifact templates (9 templates + PR template)
    scan-manifest.md               --   Scan output template
    qa-analysis.md                 --   Analysis output template
    test-inventory.md              --   Test inventory template
    qa-repo-blueprint.md           --   Repository blueprint template
    gap-analysis.md                --   Gap analysis template
    validation-report.md           --   Validation report template
    failure-classification.md      --   Failure classification template
    testid-audit-report.md         --   Test ID audit template
    qa-audit-report.md             --   Quality audit template
    pr-template.md                 --   Pull request body template
  .claude/commands/                -- Slash commands (13 commands, auto-detected by Claude Code)
    qa-start.md                    --   Tier 1: full pipeline
    qa-analyze.md                  --   Tier 2: analysis only
    qa-validate.md                 --   Tier 2: test validation
    qa-testid.md                   --   Tier 2: test ID injection
    qa-fix.md                      --   Tier 3: fix broken tests
    qa-pom.md                      --   Tier 3: generate POMs
    qa-audit.md                    --   Tier 3: quality audit
    qa-gap.md                      --   Tier 3: gap analysis
    qa-blueprint.md                --   Tier 3: repo blueprint
    qa-report.md                   --   Tier 3: status report
    qa-pyramid.md                  --   Tier 3: pyramid analysis
    create-test.md                 --   Tier 3: create tests for a feature
    update-test.md                 --   Tier 3: improve existing tests
  CLAUDE.md                        -- QA standards, agent coordination, quality gates
  .planning/                       -- Planning artifacts and project state
    config.json                    --   Pipeline configuration
  .qa-output/                      -- Generated artifacts (created during pipeline run)
```

## Pipeline Stages

The full pipeline follows this sequence:

```
scan -> analyze -> [testid-inject if frontend] -> plan -> generate -> validate -> [bug-detective if failures] -> deliver
```

| Stage | Agent | Input | Output |
|-------|-------|-------|--------|
| Scan | qa-scanner | Repository source files | SCAN_MANIFEST.md |
| Analyze | qa-analyzer | SCAN_MANIFEST.md | QA_ANALYSIS.md, TEST_INVENTORY.md, blueprint or gap analysis |
| Test ID Inject | qa-testid-injector | Frontend source files | TESTID_AUDIT_REPORT.md, modified source files |
| Plan | qa-planner | TEST_INVENTORY.md, QA_ANALYSIS.md | Generation plan (internal) |
| Generate | qa-executor | Generation plan, TEST_INVENTORY.md | Test files, POMs, fixtures, configs |
| Validate | qa-validator | Generated test files | VALIDATION_REPORT.md |
| Bug Detective | qa-bug-detective | Test execution results | FAILURE_CLASSIFICATION_REPORT.md |
| Deliver | orchestrator | All artifacts | Git branch + draft PR |

Each stage produces artifacts consumed by the next. The pipeline will not advance to the next stage until the current stage's artifacts pass verification.

## Output Artifacts

All artifacts are written to the `.qa-output/` directory during a pipeline run:

| Artifact | Description |
|----------|-------------|
| SCAN_MANIFEST.md | File tree, framework detection, testable surfaces, file priority |
| QA_ANALYSIS.md | Architecture overview, risk assessment, top 10 unit targets, testing pyramid |
| TEST_INVENTORY.md | Every test case with ID, target, inputs, expected outcome, priority |
| QA_REPO_BLUEPRINT.md | Recommended QA repo structure, configs, CI/CD, definition of done |
| GAP_ANALYSIS.md | Coverage gaps between dev and QA repos (Option 2/3 only) |
| VALIDATION_REPORT.md | 4-layer validation results per file, confidence level, fix loop log |
| FAILURE_CLASSIFICATION_REPORT.md | Failure classification: APP BUG, TEST ERROR, ENV ISSUE, INCONCLUSIVE |
| TESTID_AUDIT_REPORT.md | data-testid coverage score, proposed values, decision gate |
| QA_AUDIT_REPORT.md | 6-dimension quality score with weighted calculation |

---

Built for Capmation QA engineers. Powered by Claude Code.
