# QA Automation — Full Pipeline

Main entry point for the QA automation agent. Orchestrates the entire flow from repo scanning through test generation to PR creation.

## Instructions

You are the QA Team Lead orchestrator. Follow this sequence:

### Step 1: Gather Input

Ask the user:
1. How many repos? (1 = dev only, 2 = dev + QA repo)
2. Path(s) to the repo(s)
3. Any specific focus areas or constraints?

### Step 2: Determine Workflow Option

- **Option 1 (Dev only)**: No QA repo exists — full analysis + test generation + blueprint
- **Option 2 (Dev + Immature QA)**: QA repo exists but is crude — gap analysis + augmentation
- **Option 3 (Dev + Mature QA)**: QA repo is professional — surgical additions only

To determine maturity (if 2 repos provided):
- Check for POM structure, fixture management, CI/CD integration
- Check assertion quality (vague vs concrete)
- Check for hardcoded secrets, broken imports, missing configs
- Immature: <30% of quality checks pass
- Mature: >70% of quality checks pass

### Step 3: Execute Pipeline

**For Option 1:**
1. Run `qa-repo-analyzer` skill — produces QA_ANALYSIS.md + TEST_INVENTORY.md + QA_REPO_BLUEPRINT.md
2. If frontend detected, run `qa-testid-injector` skill — injects data-testid attributes
3. Run `qa-template-engine` skill — generates test files following POM pattern
4. Run `qa-self-validator` skill — validates generated tests (max 3 fix loops)
5. Synthesize results

**For Option 2:**
1. Scan both repos
2. Run gap analysis — compare existing QA against CLAUDE.md standards
3. Fix broken tests (imports, selectors, configs)
4. Add missing test cases
5. Standardize structure
6. Run `qa-self-validator` skill

**For Option 3:**
1. Scan both repos
2. Identify thin coverage areas (new features, edge cases, missing negative tests)
3. Add ONLY missing tests — respect existing conventions
4. Run `qa-self-validator` skill
5. Produce coverage delta report

### Step 4: Deliver

1. Create feature branch: `qa/auto-{project}-{date}`
2. Commit all artifacts with descriptive messages
3. Push and create PR via `gh pr create`
4. Output summary to terminal

Always follow CLAUDE.md standards for every artifact produced.

$ARGUMENTS
