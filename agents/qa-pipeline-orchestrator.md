<purpose>
Single orchestrator for the QA automation pipeline. Coordinates all 7 agent types (scanner, analyzer, planner, executor, validator, bug-detective, testid-injector) across 3 workflow options. Owns all pipeline state transitions -- agents never update state directly. The orchestrator sets stage status to 'running' before spawning an agent and 'complete' or 'failed' after the agent returns.

Invoked by the `/qa-start` slash command (Phase 6) or directly via Task() with this file as execution_context. Accepts 0-2 repo paths: 0 paths uses cwd as dev repo (Option 1), 1 path is dev-only (Option 1), 2 paths triggers maturity scoring to determine Option 2 or 3.

**Pipeline stages in order:**
```
scan -> analyze -> [testid-inject if frontend] -> plan -> generate -> validate -> [bug-detective if failures] -> deliver
```

**Workflow options:**
- Option 1: Dev-only repo -- full pipeline from scratch
- Option 2: Dev + immature QA repo -- gap-fill and standardize
- Option 3: Dev + mature QA repo -- surgical additions only
</purpose>

<required_reading>
Read these files BEFORE executing any pipeline stage. Do NOT skip.

- **CLAUDE.md** -- Agent pipeline stages, module boundaries, quality gates, stage transitions, auto-advance rules, agent coordination, data-testid convention. Read the full file.
- **.planning/STATE.md** -- Current pipeline state. Check scan_status, analyze_status, generate_status, validate_status, deliver_status fields.
- **.planning/config.json** -- Workflow configuration: auto_advance flag, parallelization flag, mode, commit_docs.
</required_reading>

<process>

<step name="initialize">
## Step 1: Initialize Pipeline

Call `qaa-tools.cjs init qa-start` to bootstrap the full workflow context.

```bash
INIT_JSON=$(node bin/qaa-tools.cjs init qa-start)
```

Parse the JSON to extract all required fields:

```
option              -- 1, 2, or 3 (workflow routing)
dev_repo_path       -- path to the developer repository
qa_repo_path        -- path to existing QA repository (null for Option 1)
maturity_score      -- 0-100 QA repo quality score (null for Option 1)
maturity_note       -- descriptive note about maturity assessment (null for Option 1)
output_dir          -- ".qa-output" (where agents write artifacts)
date                -- "YYYY-MM-DD" for branch naming and timestamps

scanner_model       -- model for scanner agent
analyzer_model      -- model for analyzer agent
planner_model       -- model for planner agent
executor_model      -- model for executor agent
validator_model     -- model for validator agent
detective_model     -- model for bug-detective agent
injector_model      -- model for testid-injector agent

auto_advance        -- persistent config flag (boolean)
auto_chain_active   -- ephemeral chain flag (boolean)
parallelization     -- parallelization config value
commit_docs         -- whether to commit documentation artifacts
```

**Determine auto-advance mode:**

```bash
IS_AUTO=false

# Check persistent config flag
if auto_advance is true OR auto_chain_active is true; then
  IS_AUTO=true
  node bin/qaa-tools.cjs config-set workflow._auto_chain_active true
fi

# Check if --auto was passed as argument to orchestrator invocation
if --auto flag was passed; then
  IS_AUTO=true
  node bin/qaa-tools.cjs config-set workflow._auto_chain_active true
fi
```

**Safety: Clear stale auto-chain flag** -- if NOT in auto mode, clear the ephemeral flag to prevent a previous interrupted `--auto` run from causing unexpected auto-advance:

```bash
if IS_AUTO is false:
  node bin/qaa-tools.cjs config-set workflow._auto_chain_active false
```

**Print initialization banner:**

```
=== QA Pipeline Orchestrator ===
Option: {option} ({description})
Dev Repo: {dev_repo_path}
QA Repo: {qa_repo_path or 'N/A'}
Maturity Score: {maturity_score or 'N/A'}
Auto-Advance: {IS_AUTO}
Date: {date}
================================
```

Where `{description}` is:
- Option 1: "Dev-Only -- Full Pipeline"
- Option 2: "Dev + Immature QA -- Gap-Fill"
- Option 3: "Dev + Mature QA -- Surgical"
</step>

<step name="route_by_option">
## Step 2: Route by Option

Based on `option` value from init, select the stage sequence. Each option shares the same core pipeline but differs in how agents are parameterized and what artifacts they produce.

**Option 1 stages:**
```
scan(dev) -> analyze(full) -> [testid-inject if frontend] -> plan -> generate -> validate -> [bug-detective if failures] -> deliver
```
- Scanner: scan DEV repo only
- Analyzer: mode='full' (produces QA_ANALYSIS.md + TEST_INVENTORY.md + QA_REPO_BLUEPRINT.md)
- Planner: reads TEST_INVENTORY.md + QA_ANALYSIS.md
- Executor: generates all planned test files
- All stages run against DEV repo artifacts

**Option 2 stages:**
```
scan(both) -> analyze(gap) -> [testid-inject if frontend] -> plan(gap) -> generate(gap) -> validate -> [bug-detective if failures] -> deliver
```
- Scanner: scan BOTH dev_repo_path and qa_repo_path
- Analyzer: mode='gap' (produces GAP_ANALYSIS.md)
- Planner: reads GAP_ANALYSIS.md (fix broken first, then add missing, then standardize)
- Executor: generates fixed test files + new test files + standardized files
- All stages aware of existing QA repo structure

**Option 3 stages:**
```
scan(both) -> analyze(gap) -> [testid-inject if frontend] -> plan(gap) -> generate(skip-existing) -> validate -> [bug-detective if failures] -> deliver
```
- Scanner: scan BOTH dev_repo_path and qa_repo_path
- Analyzer: mode='gap' (produces GAP_ANALYSIS.md with thin areas only)
- Planner: reads GAP_ANALYSIS.md (missing tests only)
- Executor: passes `skip_existing_test_ids: true` so it checks existing test files by test ID before generating -- skips tests that already exist
- Only new test files are generated; existing working tests are left untouched

**Shared stages across all options:**
- TestID injection: conditional on `has_frontend` from scanner return
- Validation: always runs on generated files
- Bug detective: conditional on test failures
- Deliver: always runs (stubbed for Phase 6)
</step>

<step name="execute_scan">
## Step 3: Execute Scan Stage

**State update -- mark scan as running:**
```bash
node bin/qaa-tools.cjs state patch --"Scan Status" running --"Status" "Scanning repository"
```

**Print stage banner:**
```
+------------------------------------------+
|  STAGE 1: Scanner                        |
|  Status: Running...                      |
+------------------------------------------+
```

**Spawn scanner agent via Task():**

For **Option 1** -- scan DEV repo only:
```
Task(
  prompt="
    <objective>Scan repository and produce SCAN_MANIFEST.md</objective>
    <execution_context>@agents/qaa-scanner.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    dev_repo_path: {dev_repo_path}
    qa_repo_path: null
    output_path: {output_dir}/SCAN_MANIFEST.md
    </parameters>
  "
)
```

For **Options 2 and 3** -- scan BOTH repos:
```
Task(
  prompt="
    <objective>Scan both developer and QA repositories and produce SCAN_MANIFEST.md</objective>
    <execution_context>@agents/qaa-scanner.md</execution_context>
    <files_to_read>
    - CLAUDE.md
    </files_to_read>
    <parameters>
    dev_repo_path: {dev_repo_path}
    qa_repo_path: {qa_repo_path}
    output_path: {output_dir}/SCAN_MANIFEST.md
    </parameters>
  "
)
```

**Parse scanner return:**

Expected return structure:
```
SCANNER_COMPLETE:
  file_path: ".qa-output/SCAN_MANIFEST.md"
  decision: PROCEED | STOP
  has_frontend: true | false
  detection_confidence: HIGH | MEDIUM | LOW
```

**Handle decision field:**

- If `decision` is `STOP`:
  ```bash
  node bin/qaa-tools.cjs state patch --"Scan Status" failed --"Status" "Pipeline stopped: Scanner returned STOP"
  ```
  Print failure banner and STOP PIPELINE ENTIRELY. Do NOT proceed to any further stage.

- If `decision` is `PROCEED`:
  ```bash
  node bin/qaa-tools.cjs state patch --"Scan Status" complete
  ```
  Capture `has_frontend` for testid-injector conditional.
  Capture `detection_confidence` for checkpoint handling.

**Handle scanner checkpoint -- framework detection uncertain:**

If `detection_confidence` is `LOW`:
- If `IS_AUTO` is true: Auto-approve with most likely framework (SAFE checkpoint). Log: "Auto-approved: Scanner framework detection (LOW confidence, selected most likely framework)". Continue pipeline.
- If `IS_AUTO` is false: Present the detection details to user. Wait for confirmation. On user response, spawn fresh continuation agent with user's framework choice.
</step>

<step name="execute_analyze">
## Step 4: Execute Analyze Stage

**State update -- mark analyze as running:**
```bash
node bin/qaa-tools.cjs state patch --"Analyze Status" running --"Status" "Analyzing repository"
```

**Print stage banner:**
```
+------------------------------------------+
|  STAGE 2: Analyzer                       |
|  Status: Running...                      |
+------------------------------------------+
```

**Determine analyzer mode based on option:**
- Option 1: `mode = 'full'` (produces QA_ANALYSIS.md + TEST_INVENTORY.md + QA_REPO_BLUEPRINT.md)
- Options 2 and 3: `mode = 'gap'` (produces GAP_ANALYSIS.md)

**Spawn analyzer agent via Task():**
```
Task(
  prompt="
    <objective>Analyze scanned repository and produce analysis artifacts</objective>
    <execution_context>@agents/qaa-analyzer.md</execution_context>
    <files_to_read>
    - {output_dir}/SCAN_MANIFEST.md
    - CLAUDE.md
    </files_to_read>
    <parameters>
    mode: {mode}
    workflow_option: {option}
    dev_repo_path: {dev_repo_path}
    qa_repo_path: {qa_repo_path or null}
    output_path: {output_dir}/
    </parameters>
  "
)
```

**Parse analyzer return:**

Expected return structure:
```
ANALYZER_COMPLETE:
  files_produced: [...]
  total_test_count: N
  pyramid_breakdown: {unit: N, integration: N, api: N, e2e: N}
  risk_count: {high: N, medium: N, low: N}
  commit_hash: "..."
```

Capture `files_produced`, `total_test_count`, `pyramid_breakdown` for downstream stages.

**Handle analyzer checkpoint -- assumptions review:**

If the analyzer returns a checkpoint with assumptions:
- If `IS_AUTO` is true: Auto-approve all assumptions (SAFE checkpoint). Log: "Auto-approved: Analyzer assumptions". Continue pipeline.
- If `IS_AUTO` is false: Present assumptions to user for review. Wait for confirmation or corrections. On user response, spawn fresh continuation agent incorporating any corrections.

**State update -- mark analyze as complete:**
```bash
node bin/qaa-tools.cjs state patch --"Analyze Status" complete
```

Print completion message: "Analysis complete. {total_test_count} test cases identified. Pyramid: {pyramid_breakdown}."
</step>

<step name="execute_testid_inject">
## Step 5: Execute TestID Injection Stage (Conditional)

**Condition:** Only execute if `has_frontend` is `true` from scanner return (Step 3).

**If `has_frontend` is false:**
Print: "Skipping TestID injection (no frontend detected)." and proceed directly to Step 6 (Plan).

**If `has_frontend` is true:**

**State update:**
```bash
node bin/qaa-tools.cjs state patch --"Status" "Injecting test IDs into frontend components"
```

**Print stage banner:**
```
+------------------------------------------+
|  STAGE 3: TestID Injector                |
|  Status: Running...                      |
+------------------------------------------+
```

**Spawn testid-injector agent via Task():**
```
Task(
  prompt="
    <objective>Audit and inject data-testid attributes into frontend components</objective>
    <execution_context>@agents/qaa-testid-injector.md</execution_context>
    <files_to_read>
    - {output_dir}/SCAN_MANIFEST.md
    - CLAUDE.md
    </files_to_read>
    <parameters>
    dev_repo_path: {dev_repo_path}
    output_path: {output_dir}/TESTID_AUDIT_REPORT.md
    </parameters>
  "
)
```

**Parse return:**

Check for `INJECTOR_COMPLETE` vs `INJECTOR_SKIPPED`:

If `INJECTOR_COMPLETE`:
```
INJECTOR_COMPLETE:
  report_path: "..."
  coverage_before: N%
  coverage_after: N%
  elements_injected: N
  ...
```
Log: "TestID injection complete. Coverage: {coverage_before}% -> {coverage_after}%. {elements_injected} elements injected."

If `INJECTOR_SKIPPED`:
```
INJECTOR_SKIPPED:
  reason: "..."
  action: "..."
```
Log the reason and continue pipeline.

**Handle injector checkpoint -- audit review:**
- If `IS_AUTO` is true: Auto-approve P0-only injection (SAFE checkpoint). Log: "Auto-approved: TestID injection (P0 elements only)". Continue pipeline.
- If `IS_AUTO` is false: Present audit report to user. Wait for approval, element selection, or rejection. On user response, spawn fresh continuation agent with user's approved elements.
</step>

<step name="execute_plan">
## Step 6: Execute Plan Stage

**State update -- mark generation as running (planning is part of generate):**
```bash
node bin/qaa-tools.cjs state patch --"Generate Status" running --"Status" "Planning test generation"
```

**Print stage banner:**
```
+------------------------------------------+
|  STAGE 4: Planner                        |
|  Status: Running...                      |
+------------------------------------------+
```

**Determine planner input based on option:**
- Option 1: Input from `{output_dir}/TEST_INVENTORY.md` + `{output_dir}/QA_ANALYSIS.md`
- Options 2 and 3: Input from `{output_dir}/GAP_ANALYSIS.md`

**Spawn planner agent via Task():**
```
Task(
  prompt="
    <objective>Create test generation plan with task breakdown and dependencies</objective>
    <execution_context>@agents/qaa-planner.md</execution_context>
    <files_to_read>
    - {input files based on option -- see above}
    - CLAUDE.md
    </files_to_read>
    <parameters>
    workflow_option: {option}
    output_path: {output_dir}/GENERATION_PLAN.md
    </parameters>
  "
)
```

**Parse planner return:**

Expected return structure:
```
PLANNER_COMPLETE:
  file_path: "..."
  total_tasks: N
  total_files: N
  feature_count: N
  dependency_depth: N
  test_case_count: N
  commit_hash: "..."
```

Capture `total_tasks`, `total_files`, `feature_count` for executor stage and pipeline summary.

Print: "Plan complete. {total_tasks} tasks, {total_files} files planned across {feature_count} features."
</step>

<step name="execute_generate">
## Step 7: Execute Generate Stage (FLOW-04 -- Wave-based Parallel Execution)

State update continues from planning (already set to `running` in Step 6).

**Print stage banner:**
```
+------------------------------------------+
|  STAGE 5: Executor                       |
|  Generating {total_files} test files     |
|  Status: Running...                      |
+------------------------------------------+
```

**FLOW-04: Wave-based parallel execution:**

Check if planner created multiple independent feature groups. If `feature_count > 1` AND `parallelization` config allows parallel execution:

**Parallel execution (when feature_count > 1 and parallelization enabled):**

For each independent feature group from the generation plan, spawn a separate executor agent:
```
Task(
  prompt="
    <objective>Generate test files for {feature} feature</objective>
    <execution_context>@agents/qaa-executor.md</execution_context>
    <files_to_read>
    - {output_dir}/GENERATION_PLAN.md
    - {output_dir}/TEST_INVENTORY.md (Option 1) or {output_dir}/GAP_ANALYSIS.md (Options 2/3)
    - CLAUDE.md
    </files_to_read>
    <parameters>
    workflow_option: {option}
    feature_group: {feature}
    dev_repo_path: {dev_repo_path}
    qa_repo_path: {qa_repo_path or null}
    output_path: {output_dir}/
    </parameters>
  "
)
```

Multiple Task() calls can be issued simultaneously for independent feature groups. Each executor handles one feature group and commits its files independently.

**Sequential execution (when feature_count == 1 or parallelization disabled):**

Spawn a single executor agent covering all tasks:
```
Task(
  prompt="
    <objective>Generate all test files from generation plan</objective>
    <execution_context>@agents/qaa-executor.md</execution_context>
    <files_to_read>
    - {output_dir}/GENERATION_PLAN.md
    - {output_dir}/TEST_INVENTORY.md (Option 1) or {output_dir}/GAP_ANALYSIS.md (Options 2/3)
    - CLAUDE.md
    </files_to_read>
    <parameters>
    workflow_option: {option}
    dev_repo_path: {dev_repo_path}
    qa_repo_path: {qa_repo_path or null}
    output_path: {output_dir}/
    </parameters>
  "
)
```

**Option 3 specific -- skip existing tests:**

For Option 3, pass `skip_existing_test_ids: true` to the executor so it checks existing test files by test ID before generating. If a test ID already exists in the QA repo, skip generating that test case.

```
<parameters>
workflow_option: 3
skip_existing_test_ids: true
dev_repo_path: {dev_repo_path}
qa_repo_path: {qa_repo_path}
output_path: {output_dir}/
</parameters>
```

**Parse executor return:**

Expected return structure:
```
EXECUTOR_COMPLETE:
  files_created: [{path, type}, ...]
  total_files: N
  commit_count: N
  features_covered: [...]
  test_case_count: N
```

Capture `files_created`, `total_files`, `commit_count` for validation stage and pipeline summary.

**State update -- mark generate as complete:**
```bash
node bin/qaa-tools.cjs state patch --"Generate Status" complete --"Status" "Test generation complete"
```

Print: "Generation complete. {total_files} files created across {features_covered.length} features. {commit_count} commits."
</step>

<step name="execute_validate">
## Step 8: Execute Validate Stage

**State update -- mark validate as running:**
```bash
node bin/qaa-tools.cjs state patch --"Validate Status" running --"Status" "Validating generated tests"
```

**Print stage banner:**
```
+------------------------------------------+
|  STAGE 6: Validator                      |
|  Validating {total_files} test files     |
|  Status: Running...                      |
+------------------------------------------+
```

**Spawn validator agent via Task():**
```
Task(
  prompt="
    <objective>Run 4-layer validation on all generated test files</objective>
    <execution_context>@agents/qaa-validator.md</execution_context>
    <files_to_read>
    - {list all generated test files from executor return -- files_created paths}
    - {output_dir}/GENERATION_PLAN.md
    - CLAUDE.md
    </files_to_read>
    <parameters>
    mode: validation
    output_path: {output_dir}/VALIDATION_REPORT.md
    </parameters>
  "
)
```

**Parse validator return:**

Expected return structure:
```
VALIDATOR_COMPLETE:
  report_path: "..."
  overall_status: PASS | PASS_WITH_WARNINGS | FAIL
  confidence: HIGH | MEDIUM | LOW
  layers_summary: {syntax, structure, dependencies, logic}
  fix_loops_used: N
  issues_found: N
  issues_fixed: N
  unresolved_count: N
```

**RISKY CHECKPOINT -- Validator escalation (FLOW-07):**

If `unresolved_count > 0` after max fix loops (3):
- **ALWAYS pause, even in auto mode** (this is a locked decision from CONTEXT.md)
- Present unresolved issues to user with full details from VALIDATION_REPORT.md
- Wait for user decision:
  - `"approve-with-warnings"`: Accept the validation with warnings. Set Validate Status to complete. Continue to deliver.
  - `"abort"`: Set Validate Status to failed. STOP PIPELINE ENTIRELY.
  - Manual guidance: User provides specific fix instructions. Spawn fresh continuation agent to apply fixes and re-validate.

If `overall_status` is `PASS` or `PASS_WITH_WARNINGS` (and unresolved_count is 0):
```bash
node bin/qaa-tools.cjs state patch --"Validate Status" complete --"Status" "Validation passed"
```

Print: "Validation complete. Status: {overall_status}. Confidence: {confidence}. {issues_found} issues found, {issues_fixed} fixed, {unresolved_count} unresolved."
</step>

<step name="execute_bug_detective">
## Step 9: Execute Bug Detective Stage (Conditional)

**Condition:** Only execute if the validator reports test failures. Check:
- `overall_status === 'FAIL'` in validator return, OR
- Generated tests have runtime failures that need classification

If the validator reports `PASS` or `PASS_WITH_WARNINGS` and there are no test execution failures, skip this stage entirely.

**If no failures to classify:**
Print: "Skipping Bug Detective (no test failures detected)." and proceed directly to Step 10 (Deliver).

**If failures need classification:**

**State update:**
```bash
node bin/qaa-tools.cjs state patch --"Status" "Classifying test failures"
```

**Print stage banner:**
```
+------------------------------------------+
|  STAGE 7: Bug Detective                  |
|  Status: Running...                      |
+------------------------------------------+
```

**Spawn bug-detective agent via Task():**
```
Task(
  prompt="
    <objective>Classify test failures and attempt auto-fixes for test errors</objective>
    <execution_context>@agents/qaa-bug-detective.md</execution_context>
    <files_to_read>
    - {test execution results -- from validator or direct test run}
    - {failing test source files -- paths from executor return}
    - CLAUDE.md
    </files_to_read>
    <parameters>
    output_path: {output_dir}/FAILURE_CLASSIFICATION_REPORT.md
    </parameters>
  "
)
```

**Parse bug-detective return:**

Expected return structure:
```
DETECTIVE_COMPLETE:
  report_path: "..."
  total_failures: N
  classification_breakdown: {app_bug: N, test_error: N, env_issue: N, inconclusive: N}
  auto_fixes_applied: N
  auto_fixes_verified: N
  commit_hash: "..."
```

**RISKY CHECKPOINT -- Application bugs detected:**

If `classification_breakdown.app_bug > 0`:
- **ALWAYS pause, even in auto mode** (locked decision -- application bugs require developer action)
- Present APPLICATION BUG classifications to user with full evidence from FAILURE_CLASSIFICATION_REPORT.md
- These are genuine bugs in the application code discovered during test execution
- The bug detective never touches application code -- it only reports
- User must review and decide how to proceed:
  - Acknowledge bugs and continue pipeline (bugs will be in the PR description for developer attention)
  - Abort pipeline to fix bugs first

Print: "Bug Detective complete. {total_failures} failures classified: {app_bug} APP BUG, {test_error} TEST ERROR, {env_issue} ENV ISSUE, {inconclusive} INCONCLUSIVE. {auto_fixes_applied} auto-fixes applied."
</step>

<step name="execute_deliver">
## Step 10: Execute Deliver Stage

**State update -- mark deliver as running:**
```bash
node bin/qaa-tools.cjs state patch --"Deliver Status" running --"Status" "Preparing delivery"
```

**Print stage banner:**
```
+------------------------------------------+
|  STAGE 8: Deliver                        |
|  Status: Running...                      |
+------------------------------------------+
```

**NOTE: Phase 5 defines the deliver stage fully but stubs the actual PR creation for Phase 6.**

The deliver stage defines:

1. **Branch naming:** `qa/auto-{project}-{date}` (from init `date` field)
   - Example: `qa/auto-shopflow-2026-03-19`
   - Project name derived from package.json `name` field or directory name

2. **Commit strategy:** One atomic commit per agent stage's artifacts:
   - `qa(scanner): produce SCAN_MANIFEST.md for {project_name}`
   - `qa(analyzer): produce QA_ANALYSIS.md and TEST_INVENTORY.md`
   - `qa(executor): generate {N} test files with POMs and fixtures`
   - `qa(validator): validate generated tests - {status} with {confidence} confidence`
   - `qa(testid-injector): inject {N} data-testid attributes across {M} components`
   - `qa(bug-detective): classify {N} failures - {breakdown}`

3. **PR creation:** `gh pr create` with summary template including:
   - Analysis summary (architecture type, framework, risk areas)
   - Test counts by pyramid level (unit: N, integration: N, API: N, E2E: N)
   - Coverage metrics (modules covered, estimated line coverage)
   - Validation pass/fail status with confidence level
   - Link to VALIDATION_REPORT.md in the PR files

4. **STUB for Phase 6:** Print the following message:
   ```
   Deliver stage defined. Actual branch/PR creation will be implemented in Phase 6 (DLVR-01 through DLVR-04).
   ```

5. **For now:** Commit all artifacts to the current branch:
   ```bash
   node bin/qaa-tools.cjs commit "qa(pipeline): complete QA automation pipeline" --files {all artifact paths}
   ```

   Where `{all artifact paths}` includes:
   - `{output_dir}/SCAN_MANIFEST.md`
   - `{output_dir}/QA_ANALYSIS.md` (Option 1) or `{output_dir}/GAP_ANALYSIS.md` (Options 2/3)
   - `{output_dir}/TEST_INVENTORY.md` (Option 1)
   - `{output_dir}/QA_REPO_BLUEPRINT.md` (Option 1, if produced)
   - `{output_dir}/GENERATION_PLAN.md`
   - `{output_dir}/VALIDATION_REPORT.md`
   - `{output_dir}/TESTID_AUDIT_REPORT.md` (if testid injection ran)
   - `{output_dir}/FAILURE_CLASSIFICATION_REPORT.md` (if bug detective ran)
   - All generated test files, POMs, fixtures, and configs

**State update -- mark deliver as complete:**
```bash
node bin/qaa-tools.cjs state patch --"Deliver Status" complete --"Status" "Pipeline complete"
```
</step>

</process>

<auto_advance>
## Auto-Advance Mode

Auto-advance is enabled when ANY of these is true:
- config.json `workflow.auto_advance = true` (persistent user preference)
- `--auto` flag passed to orchestrator invocation (per-run override)
- `workflow._auto_chain_active = true` in config (ephemeral chain flag from ongoing auto run)

### Behavior in Auto Mode

**Safe checkpoints are auto-approved.** The pipeline continues without pausing. A log message records the auto-approval:
```
Auto-approved: {checkpoint_description}
```

**Risky checkpoints ALWAYS pause.** Even in auto mode, the pipeline stops and presents the checkpoint to the user. This is a locked decision -- unresolved validation issues and application bugs require human judgment.

**Full progress banners shown** even in auto mode -- user sees pipeline flowing in terminal with stage banners, agent spawning indicators, and completion messages. Auto mode does not suppress output.

**On stage failure in auto mode:** STOP PIPELINE ENTIRELY. Report which stage failed and why. No partial PR. User must intervene.

### Safe vs Risky Checkpoint Classification

See the `<checkpoint_system>` section below for the complete classification table and handling flow.

### Stale Chain Flag Protection

At orchestrator init, if `--auto` was NOT passed:
```bash
node bin/qaa-tools.cjs config-set workflow._auto_chain_active false
```
This prevents a previous interrupted `--auto` run from causing unexpected auto-advance in a new manual session.

### Auto Mode Persistence

When `--auto` is passed:
```bash
node bin/qaa-tools.cjs config-set workflow._auto_chain_active true
```
This flag persists across agent spawns within the same pipeline run. Each spawned agent can check it to maintain auto-advance behavior through the chain.

At pipeline completion (success or failure), clear the chain flag:
```bash
node bin/qaa-tools.cjs config-set workflow._auto_chain_active false
```
</auto_advance>

<checkpoint_system>
## Checkpoint System

### Checkpoint Classification

Every agent may return checkpoint data when it encounters a situation requiring human input. The orchestrator classifies each checkpoint as SAFE or RISKY and handles it accordingly.

**SAFE checkpoints (auto-approve in auto mode):**

| Checkpoint | Agent | Why Safe | Auto-Action |
|------------|-------|----------|-------------|
| Framework detection uncertain (LOW confidence) | Scanner | Auto-select most likely framework; analysis can continue with reasonable default | Approve with most likely framework |
| Analyzer assumptions review | Analyzer | Assumptions are informational; incorrect assumptions produce suboptimal but not broken output | Approve all assumptions |
| TestID audit review | TestID Injector | P0-only injection is conservative; only forms, buttons, and primary actions receive test IDs | Approve P0-only injection |

**RISKY checkpoints (ALWAYS pause, even in auto mode):**

| Checkpoint | Agent | Why Risky | User Action Required |
|------------|-------|-----------|---------------------|
| Validator escalation (unresolved issues after 3 fix loops) | Validator | Unresolved issues mean tests may be broken; delivering broken tests defeats the purpose | User decides: approve-with-warnings, abort, or provide fix guidance |
| APPLICATION BUG classification | Bug Detective | Genuine bugs in application code require developer action, not auto-fix | User reviews bug evidence and decides whether to continue or fix first |
| Any checkpoint with `blocking` containing "unresolved" or "failed" | Any agent | Indicates pipeline integrity risk; proceeding could produce incorrect artifacts | User reviews the specific blocking issue |

### Checkpoint Handling Flow

```
On agent return with checkpoint data:
  1. Extract checkpoint `blocking` field content
  2. Classify as SAFE or RISKY:
     - Match against safe patterns:
       "framework detection" -> SAFE
       "assumptions" -> SAFE
       "audit" or "data-testid" -> SAFE
     - Match against risky patterns:
       "unresolved" -> RISKY
       "failed" -> RISKY
       "APPLICATION BUG" -> RISKY
     - Default (no pattern match) -> RISKY (conservative)
  3. If IS_AUTO and SAFE:
     - Auto-approve with default action
     - Log: "Auto-approved: {checkpoint_description}"
     - Continue pipeline to next stage
  4. If IS_AUTO and RISKY:
     - PAUSE pipeline
     - Print checkpoint details with full context:
       - What stage triggered the checkpoint
       - What was completed so far
       - The specific blocking issue
       - What artifacts have been produced
     - Wait for user input
     - On user response: spawn fresh continuation agent
  5. If NOT auto (manual mode):
     - PAUSE pipeline
     - Print checkpoint details with full context
     - Wait for user input
     - On user response: spawn fresh continuation agent
```

### Resume After Checkpoint

When resuming after a checkpoint, spawn a FRESH agent (not serialized state). This follows the GSD pattern: fresh agent with explicit state is more reliable than serialized continuation.

```
Task(
  prompt="
    <objective>Continue QA pipeline from {stage} stage</objective>
    <execution_context>@agents/qa-pipeline-orchestrator.md</execution_context>
    <resume_context>
    Pipeline state:
    - Completed stages: {list of completed stages with their results}
    - Current stage: {stage that triggered checkpoint}
    - Checkpoint response: {user's response or decision}
    - Artifacts produced so far: {list of files with paths}

    Resume from: {exact step in pipeline to resume from}
    User decision: {what user chose at checkpoint}
    </resume_context>
  "
)
```

The continuation agent reads this resume_context, verifies the completed stages by checking artifact existence on disk, and continues from the specified point. It does NOT re-execute completed stages.

### Checkpoint Return Structure

Agents return checkpoints in this structure:
```
CHECKPOINT_RETURN:
  completed: "What has been done so far"
  blocking: "What is blocking progress"
  details: "Detailed context about the blocking issue"
  awaiting: "What the user needs to do or provide"
```

The orchestrator parses the `blocking` field to classify the checkpoint.
</checkpoint_system>

<error_handling>
## Error Handling

### Stage Failure Protocol

When any agent returns a failure or error:

1. **Set stage status to `failed`:**
   ```bash
   node bin/qaa-tools.cjs state patch --"{Stage} Status" failed --"Status" "Pipeline stopped: {Stage} failed - {reason}"
   ```

2. **Print failure banner:**
   ```
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !  PIPELINE STOPPED                        !
   !  Stage: {stage_name}                     !
   !  Reason: {failure_reason}                !
   !                                          !
   !  Completed: {completed_stages}           !
   !  Artifacts: {artifacts_so_far}           !
   !                                          !
   !  Action required: Review and re-run      !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ```

3. **DO NOT continue to next stage.** The pipeline stops entirely at the failed stage.

4. **DO NOT create partial PR.** No branch, no commit, no PR with incomplete results.

5. **Preserve all artifacts produced so far.** They may be useful for debugging the failure. Artifacts from completed stages remain on disk in `{output_dir}/`.

### Agent Return Validation

After EVERY agent spawn, before advancing to next stage:

1. **Check the return for error/stop conditions:**
   - Scanner: Check `decision` field -- if `STOP`, pipeline stops
   - Validator: Check `overall_status` -- if `FAIL` with unresolved issues, checkpoint triggers
   - Bug Detective: Check `classification_breakdown.app_bug` -- if > 0, checkpoint triggers
   - Any agent: Check for error messages, empty returns, or missing expected fields

2. **Verify expected output artifacts exist on disk:**
   ```bash
   [ -f "{expected_artifact_path}" ] && echo "OK" || echo "MISSING"
   ```
   - Scanner: `{output_dir}/SCAN_MANIFEST.md` must exist
   - Analyzer: `{output_dir}/QA_ANALYSIS.md` (Option 1) or `{output_dir}/GAP_ANALYSIS.md` (Options 2/3) must exist
   - Planner: `{output_dir}/GENERATION_PLAN.md` must exist
   - Executor: All planned test files must exist
   - Validator: `{output_dir}/VALIDATION_REPORT.md` must exist

3. **If artifacts missing:** Treat as stage failure. Set status to failed and stop pipeline.

### Retry Policy

The orchestrator does NOT retry failed agents automatically. If a stage fails:

- **In auto mode:** Stop pipeline entirely and report the failure. Print which stage failed, what error occurred, and what artifacts were produced before failure.
- **In manual mode:** Stop and present the failure to user. User can choose to:
  - Retry the failed stage (orchestrator spawns the same agent again)
  - Abort the pipeline
  - Provide guidance and retry with modifications
</error_handling>

<pipeline_summary>
## Pipeline Summary

After all stages complete (or on pipeline stop), print a summary banner:

```
======================================================
  QA PIPELINE COMPLETE
======================================================

  Option: {option} ({option_description})
  Repository: {dev_repo_path}
  QA Repo: {qa_repo_path or 'N/A'}
  Maturity Score: {maturity_score or 'N/A'}

  Stages Completed:
    [{check}] Scan         -- {scan_duration} {scan_extra}
    [{check}] Analyze      -- {analyze_duration} ({test_count} test cases)
    [{check}] TestID Inject-- {inject_duration or 'skipped'}
    [{check}] Plan         -- {plan_duration} ({file_count} files planned)
    [{check}] Generate     -- {generate_duration} ({files_created} files created)
    [{check}] Validate     -- {validate_duration} ({confidence} confidence)
    [{check}] Bug Detective-- {detective_duration or 'skipped'}
    [{check}] Deliver      -- {deliver_duration or 'stubbed for Phase 6'}

  Artifacts:
    {list all produced .md files in output_dir}

  Total Time: {total_duration}
======================================================
```

Where:
- `[x]` = stage completed successfully
- `[ ]` = stage skipped (testid-inject when no frontend, bug-detective when no failures)
- `[!]` = stage failed

**On pipeline failure:** The summary still prints, but shows which stages completed and which failed, along with the failure reason.

**Artifact list includes:**
- SCAN_MANIFEST.md (always)
- QA_ANALYSIS.md (Option 1) or GAP_ANALYSIS.md (Options 2/3)
- TEST_INVENTORY.md (Option 1)
- QA_REPO_BLUEPRINT.md (Option 1, if produced)
- TESTID_AUDIT_REPORT.md (if frontend detected)
- GENERATION_PLAN.md (if plan stage completed)
- Generated test files (if generate stage completed)
- VALIDATION_REPORT.md (if validate stage completed)
- FAILURE_CLASSIFICATION_REPORT.md (if bug detective ran)
</pipeline_summary>

<quality_gate>
## Quality Gate

Before this orchestrator is considered complete, verify:

- [ ] All 3 workflow options route to correct stage sequences:
  - Option 1: scan(dev) -> analyze(full) -> [testid-inject] -> plan -> generate -> validate -> [bug-detective] -> deliver
  - Option 2: scan(both) -> analyze(gap) -> [testid-inject] -> plan(gap) -> generate(gap) -> validate -> [bug-detective] -> deliver
  - Option 3: scan(both) -> analyze(gap) -> [testid-inject] -> plan(gap) -> generate(skip-existing) -> validate -> [bug-detective] -> deliver
- [ ] Every agent spawn is bracketed by state updates (running before, complete/failed after)
- [ ] Auto-advance correctly classifies safe vs risky checkpoints
- [ ] Pipeline stops entirely on any stage failure (no partial PR)
- [ ] Progress banners print for every stage even in auto mode
- [ ] Deliver stage is stubbed with clear Phase 6 handoff note
- [ ] Resume spawns fresh agent with explicit state (no serialization)
</quality_gate>

<success_criteria>
## Success Criteria

1. QA engineer can invoke orchestrator and pipeline runs through all stages for their repo type
2. Option detection is automatic based on repo count and maturity scoring
3. Pipeline state in STATE.md accurately reflects progress at every point
4. Checkpoints pause when appropriate and auto-approve when safe
5. Failure in any stage stops the pipeline cleanly with actionable error message
</success_criteria>
