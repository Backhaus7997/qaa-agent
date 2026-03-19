# Phase 5: Workflow Orchestration - Research

**Researched:** 2026-03-19
**Domain:** Agent orchestration, pipeline state management, workflow routing
**Confidence:** HIGH

## Summary

Phase 5 builds the single orchestrator file (`agents/qa-pipeline-orchestrator.md`) that coordinates the entire QA automation pipeline. The orchestrator routes between 3 workflow options based on automated maturity scoring, manages strictly sequential stage execution, handles checkpoints with safe/risky distinction, and drives auto-advance behavior. It also requires a new `cmdInitQaStart` function in `bin/lib/init.cjs` and pipeline state updates through the existing `qaa-tools.cjs state` commands.

The research examined all 7 existing agent `.md` files (3,399 total lines), the GSD execute-phase orchestration workflow and checkpoint reference, the init system (12 existing variants), and the state management module. The agents have well-defined interfaces with structured return formats (`SCANNER_COMPLETE`, `ANALYZER_COMPLETE`, `PLANNER_COMPLETE`, `EXECUTOR_COMPLETE`, `VALIDATOR_COMPLETE`, `DETECTIVE_COMPLETE`, `INJECTOR_COMPLETE`/`INJECTOR_SKIPPED`). The state module already tracks pipeline stages (scan/analyze/generate/validate/deliver) via frontmatter. The init module follows a consistent pattern that the new `qa-start` variant can replicate.

**Primary recommendation:** Follow the GSD execute-phase pattern (init once, route by option, spawn agents sequentially via Task(), update state before/after each spawn), but simplify by removing wave-based parallelism at the orchestrator level. Implement maturity scoring as a pure function within the orchestrator itself (no external dependency), and use the existing `qaa-tools.cjs state update` command for pipeline stage tracking.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Auto-advance enabled via config.json `workflow.auto_advance = true` (persists) or per-run `--auto` flag (override)
- In auto mode: auto-approve safe checkpoints (scanner framework detection, analyzer assumptions), ALWAYS pause for risky checkpoints (validator escalation with unresolved issues)
- On stage failure in auto mode: stop pipeline entirely, report which stage failed and why. No partial PR. User must intervene.
- Full progress banners shown even in auto mode -- user sees pipeline flowing in terminal
- Strictly sequential stages: scanner -> analyzer -> [testid-injector if frontend] -> planner -> executor -> validator -> [bug-detective if failures] -> deliver
- No parallel stages -- each waits for the previous
- Wave-based parallelism applies within a stage only if the planner creates multiple generation plans (executor runs them in parallel)
- QA repo maturity determined by automated scoring (0-100): below 30 = immature (Option 2), above 70 = mature (Option 3)
- Score based on: POM usage, assertion quality, CI/CD integration, fixture management
- Analyzer handles both modes via 'mode' parameter: 'full' (Option 1) or 'gap' (Options 2 & 3) -- no separate gap-analyzer agent
- Option 3: executor checks existing test files itself before generating -- skips tests that already exist (by test ID)
- Single orchestrator file: `agents/qa-pipeline-orchestrator.md` with internal routing for all 3 options
- Lives in `agents/` directory alongside agent files
- Takes 'option' parameter, routes to appropriate stage sequence. Shared stages (scan, validate, deliver) defined once.
- Fresh agent with explicit state for resume (like GSD): spawn new agent with what's done, what's pending, user's response. No serialization.
- Orchestrator is the checkpoint owner -- agents return structured checkpoint data, orchestrator presents to user and spawns continuation
- Single init variant: `qaa-tools.cjs init qa-start` returns everything -- detected option, repo paths, models, state, config
- Orchestrator calls init once at startup, parses JSON, routes based on option
- Orchestrator owns all QA_STATE.md pipeline stage updates
- Sets stage to 'running' before spawning agent, 'complete' or 'failed' after agent returns
- Agents do NOT update pipeline state themselves -- only the orchestrator
- State updates via `qaa-tools.cjs state` commands

### Claude's Discretion
- Exact maturity scoring algorithm weights
- How orchestrator passes option parameter to agents
- Internal routing logic structure within the orchestrator .md
- How to handle edge case: user provides 2 repos but QA repo is empty (score = 0)

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| FLOW-01 | Option 1 workflow (dev-only): scan -> analyze -> [testid-inject if frontend] -> plan -> generate -> validate -> deliver | Agent interfaces documented with input/output contracts; stage sequence maps directly to agent spawn order |
| FLOW-02 | Option 2 workflow (dev + immature QA): scan both -> gap analysis -> fix broken -> add missing -> standardize -> validate -> deliver | Analyzer's 'mode' parameter ('gap') produces GAP_ANALYSIS.md; executor handles fix-before-add in gap mode |
| FLOW-03 | Option 3 workflow (dev + mature QA): scan both -> identify thin coverage -> add only missing -> validate -> deliver | Executor's existing-test-ID check skips duplicates; analyzer gap mode with mature filter |
| FLOW-04 | Wave-based parallel execution spawns independent agents simultaneously | GSD execute-phase wave pattern documented; applies within executor stage only (planner may create parallel generation tasks) |
| FLOW-05 | Init system bootstraps workflow context in single command | New `cmdInitQaStart` function documented with exact return schema and integration points |
| FLOW-06 | Auto-advance chain runs full pipeline without interaction | GSD auto-advance pattern (config flag + per-run flag + chain flag), safe/risky checkpoint distinction documented |
| FLOW-07 | Checkpoint system pauses execution for human decisions and resumes with context | GSD checkpoint patterns (human-verify, decision, human-action) mapped to QA pipeline checkpoints |
</phase_requirements>

## Standard Stack

### Core
| Library/Tool | Version | Purpose | Why Standard |
|-------------|---------|---------|--------------|
| qaa-tools.cjs CLI | 1.0 | Init, state, commit, config commands | Already built in Phase 1; all agents use it |
| Claude Code Task() | Native | Subagent spawning with model selection | GSD pattern; fresh 200k context per agent |
| .planning/config.json | 1.0 | Persistent workflow flags (auto_advance) | Existing config system from Phase 1 |
| QA_STATE.md | 1.0 | Pipeline stage tracking via frontmatter | Built in Phase 1 with scan/analyze/generate/validate/deliver stages |

### Supporting
| Library/Tool | Version | Purpose | When to Use |
|-------------|---------|---------|-------------|
| node bin/qaa-tools.cjs state update | 1.0 | Update STATE.md fields | Before/after each agent spawn |
| node bin/qaa-tools.cjs state patch | 1.0 | Batch update STATE.md fields | When updating multiple fields at once |
| node bin/qaa-tools.cjs config-get | 1.0 | Read config values | Check auto_advance, _auto_chain_active |
| node bin/qaa-tools.cjs config-set | 1.0 | Write config values | Set _auto_chain_active ephemeral flag |
| node bin/qaa-tools.cjs commit | 1.0 | Atomic commits | Post-validation commit of all artifacts |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|-----------|-----------|----------|
| Single orchestrator .md | Separate workflows/ directory | Single file keeps routing together; locked decision |
| Maturity function in orchestrator | Separate scoring tool | Scoring is lightweight enough to live inline in the orchestrator |
| Pipeline frontmatter fields | Dedicated pipeline state file | Frontmatter in STATE.md already exists; no new infrastructure needed |

## Architecture Patterns

### Recommended File Structure
```
agents/
  qa-pipeline-orchestrator.md     # NEW -- single orchestrator (this phase)
  qaa-scanner.md                  # Existing
  qaa-analyzer.md                 # Existing
  qaa-planner.md                  # Existing
  qaa-executor.md                 # Existing
  qaa-validator.md                # Existing
  qaa-bug-detective.md            # Existing
  qaa-testid-injector.md          # Existing
bin/
  lib/
    init.cjs                      # MODIFIED -- add cmdInitQaStart
  qaa-tools.cjs                   # MODIFIED -- add 'qa-start' case to init router
```

### Pattern 1: Sequential Stage Pipeline with State Ownership

**What:** Orchestrator owns all state transitions. Before spawning an agent, it sets the pipeline stage to 'running'. After the agent returns, it sets the stage to 'complete' or 'failed'. Agents never touch pipeline state.

**When to use:** Every agent spawn in every workflow option.

**State update commands:**
```bash
# Before spawning scanner
node bin/qaa-tools.cjs state patch --"Scan Status" running --"Status" "Scanning repository"

# After scanner returns successfully
node bin/qaa-tools.cjs state patch --"Scan Status" complete --"Status" "Scan complete, starting analysis"

# After scanner fails
node bin/qaa-tools.cjs state patch --"Scan Status" failed --"Status" "Scan failed: {reason}"
```

Note: The state module's `cmdStatePatch` function uses the `--field value` pattern. Pipeline stage fields in STATE.md frontmatter are `scan_status`, `analyze_status`, `generate_status`, `validate_status`, `deliver_status` -- but the `buildStateFrontmatter` function reads them from the markdown body as "Scan Status", "Analyze Status", etc. The orchestrator should update the body fields (which auto-sync to frontmatter).

### Pattern 2: Option Routing via Internal Sections

**What:** The orchestrator .md file uses XML-tagged sections for shared logic and option-specific logic. A single `<process>` tag contains the main flow, with internal branching based on the `option` parameter.

**When to use:** For the orchestrator's internal structure.

**Example structure:**
```markdown
<process>
  <step name="initialize">
    Call `qaa-tools.cjs init qa-start`
    Parse JSON for option, repo paths, models, config flags
    Route based on option value
  </step>

  <step name="scan">
    # Shared across all 3 options
    # Option 1: scan DEV repo only
    # Options 2/3: scan both DEV and QA repos
    Spawn scanner agent with appropriate repo path(s)
  </step>

  <step name="analyze">
    # Option 1: mode='full' (produces QA_ANALYSIS + TEST_INVENTORY + BLUEPRINT)
    # Options 2/3: mode='gap' (produces GAP_ANALYSIS.md)
    Spawn analyzer with mode parameter
  </step>

  <step name="testid_inject">
    # Only if has_frontend=true from scanner
    # All 3 options
    Spawn testid-injector
  </step>

  <step name="plan_and_generate">
    # Option 1: Full generation from TEST_INVENTORY
    # Option 2: Fix broken first, then add missing, then standardize
    # Option 3: Add only missing (executor checks existing by test ID)
    Spawn planner then executor with option context
  </step>

  <step name="validate">
    # Shared across all 3 options
    Spawn validator
    If failures: spawn bug-detective (conditional)
  </step>

  <step name="deliver">
    # Shared across all 3 options
    Create branch, commit, push, create PR
  </step>
</process>
```

### Pattern 3: Maturity Scoring Function

**What:** Automated scoring (0-100) to determine which workflow option applies when user provides 2 repos (dev + QA).

**When to use:** During initialization when 2 repo paths are detected.

**Scoring algorithm (Claude's discretion -- recommended weights):**

| Dimension | Weight | How to Score |
|-----------|--------|-------------|
| POM usage | 25% | Check for `pages/` or `page-objects/` dir with BasePage. 0 = no POMs, 50 = POMs exist but no BasePage, 100 = POMs with BasePage extending pattern |
| Assertion quality | 25% | Sample 10 test files, count concrete vs vague assertions. 0 = all vague, 100 = all concrete |
| CI/CD integration | 20% | Check for `.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml`, `azure-pipelines.yml`. 0 = none, 50 = exists but no test commands, 100 = exists with test run commands |
| Fixture management | 15% | Check for `fixtures/` dir with domain-separated files. 0 = no fixtures, 50 = fixtures exist but not organized, 100 = organized by domain |
| Naming convention | 15% | Sample 10 test files, check naming pattern compliance. 0 = no convention, 100 = all follow `*.e2e.spec.ts` / `*.api.spec.ts` / `*.unit.spec.ts` pattern |

**Thresholds:**
- Score < 30 = immature -> Option 2 (gap-fill and standardize)
- Score >= 30 and < 70 = ambiguous -> Option 2 (safer choice, includes standardization)
- Score >= 70 = mature -> Option 3 (surgical additions only)

**Edge case: QA repo is empty (score = 0):**
When user provides 2 repos but the QA repo has 0 test files, treat as Option 1 (dev-only). The QA repo path is still available but the scoring detects no test content, so a fresh pipeline runs against the DEV repo. Log: "QA repo at {path} is empty (score 0). Running Option 1 (full pipeline from scratch)."

### Pattern 4: Checkpoint Classification (Safe vs Risky)

**What:** In auto-advance mode, safe checkpoints auto-approve while risky checkpoints always pause.

**Safe checkpoints (auto-approve):**
- Scanner framework detection with LOW confidence -> auto-select most likely framework
- Analyzer assumptions checkpoint -> auto-approve all assumptions
- Testid-injector audit checkpoint -> auto-approve P0-only injection

**Risky checkpoints (always pause):**
- Validator escalation with unresolved issues after 3 fix loops
- Bug-detective with APPLICATION BUG classifications -> user must review
- Any checkpoint where the agent returned a `blocking` field containing "unresolved" or "failed"

**Implementation:** The orchestrator checks the checkpoint return's `blocking` field content. If it matches safe patterns, auto-approve. Otherwise, present to user.

### Pattern 5: Agent Spawning with Context Passing

**What:** How the orchestrator spawns each agent via Task() with the right parameters.

**When to use:** Every agent spawn.

**Template:**
```
Task(
  subagent_type="qaa-{agent-type}",
  model="{resolved_model}",
  prompt="
    <objective>
    {Stage-specific objective}
    </objective>

    <execution_context>
    @agents/qaa-{agent-type}.md
    </execution_context>

    <files_to_read>
    Read these files at execution start using the Read tool:
    - {input artifacts from previous stage}
    - CLAUDE.md
    - {relevant templates}
    </files_to_read>

    <parameters>
    workflow_option: {1|2|3}
    output_path: {where to write artifacts}
    dev_repo_path: {path}
    qa_repo_path: {path or null}
    mode: {full|gap}  (for analyzer)
    </parameters>
  "
)
```

### Anti-Patterns to Avoid
- **Agents updating pipeline state themselves:** Only the orchestrator updates STATE.md pipeline stages. Agents return structured data; orchestrator translates to state updates.
- **Resuming serialized agent state:** Fresh agent with explicit state is more reliable than trying to resume. Use the GSD continuation-prompt pattern.
- **Running stages in parallel:** All stages are strictly sequential (locked decision). Only within-stage parallelism is allowed (executor running multiple generation tasks).
- **Hardcoding artifact paths:** Orchestrator determines output paths and passes them to agents via prompt parameters.
- **Creating a separate gap-analyzer agent:** The analyzer agent already supports a 'mode' parameter. Use mode='gap' for Options 2/3.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Pipeline state tracking | Custom state file format | `qaa-tools.cjs state` commands with existing STATE.md frontmatter | Already built with pipeline stages (scan/analyze/generate/validate/deliver) |
| Model resolution | Hardcoded model names | `qaa-tools.cjs resolve-model {agent-type}` or init JSON | Model profiles system handles quality/balanced/budget profiles |
| Config flag reading | Direct file reads | `qaa-tools.cjs config-get workflow.auto_advance` | Config system handles defaults, nesting, type coercion |
| Atomic commits | Direct git commands | `qaa-tools.cjs commit "message" --files f1 f2` | Handles staging, message formatting, error recovery |
| Slug generation | Custom regex | `qaa-tools.cjs generate-slug "text"` | Handles edge cases (special chars, length limits) |
| Timestamp formatting | Manual date formatting | `qaa-tools.cjs current-timestamp [format]` | Consistent ISO format across all artifacts |

**Key insight:** Phase 1 built comprehensive CLI infrastructure specifically so orchestration code stays lean. Every utility operation has a CLI command. The orchestrator should be a coordination layer, not a reimplementation of existing tools.

## Common Pitfalls

### Pitfall 1: Stale Auto-Chain Flag
**What goes wrong:** A previous `--auto` run was interrupted, leaving `_auto_chain_active: true` in config. Next manual run auto-advances unexpectedly.
**Why it happens:** The ephemeral chain flag persists across sessions.
**How to avoid:** At orchestrator init, if `--auto` flag was NOT passed, clear the chain flag:
```bash
if [[ ! "$ARGUMENTS" =~ --auto ]]; then
  node bin/qaa-tools.cjs config-set workflow._auto_chain_active false 2>/dev/null
fi
```
**Warning signs:** Pipeline auto-advancing when user didn't request it.

### Pitfall 2: Forgetting to Set State Before Agent Spawn
**What goes wrong:** Agent fails, but pipeline state still shows previous stage as 'complete'. No way to know which stage was running.
**Why it happens:** Orchestrator forgets the state update before spawning.
**How to avoid:** Every agent spawn MUST be bracketed by state updates: `running` before, `complete`/`failed` after. Make this a rigid pattern in the orchestrator template.
**Warning signs:** STATE.md pipeline stages don't reflect actual progress.

### Pitfall 3: Option Detection Confusion with Empty QA Repo
**What goes wrong:** User provides 2 repo paths but QA repo is empty. Orchestrator tries gap analysis on nothing.
**Why it happens:** 2 repos detected = Options 2/3, but scoring returns 0 because QA repo has no tests.
**How to avoid:** Score = 0 special case: fall back to Option 1. Log the reason clearly.
**Warning signs:** Analyzer in 'gap' mode fails because there are no existing tests to compare against.

### Pitfall 4: Validator Checkpoint in Auto Mode
**What goes wrong:** Validator returns unresolved issues after 3 fix loops. Auto-mode tries to continue past the escalation.
**Why it happens:** Safe/risky checkpoint distinction not implemented correctly.
**How to avoid:** Validator escalation is ALWAYS a risky checkpoint. Check for `unresolved_count > 0` in validator return and always pause.
**Warning signs:** Pipeline continues to deliver stage with failing validation.

### Pitfall 5: Scanner Returning STOP
**What goes wrong:** Scanner decides STOP (no testable surfaces). Orchestrator tries to continue pipeline.
**Why it happens:** Scanner's `decision` return value not checked.
**How to avoid:** After every agent return, check the structured return for error/stop conditions before advancing.
**Warning signs:** Analyzer receives empty or missing SCAN_MANIFEST.md.

### Pitfall 6: Bug Detective Spawned When Not Needed
**What goes wrong:** Bug-detective spawned after every validation, even when all tests pass.
**Why it happens:** Conditional spawn logic missing.
**How to avoid:** Bug-detective is conditional: spawn ONLY if validator reports test failures or if the test suite execution has failing tests. Check validator return's `overall_status` field.
**Warning signs:** Unnecessary agent spawn consuming context and time.

### Pitfall 7: Init Function Not Registered in CLI Router
**What goes wrong:** `qaa-tools.cjs init qa-start` returns "Unknown init workflow" error.
**Why it happens:** New function added to init.cjs but not added to the switch case in qaa-tools.cjs.
**How to avoid:** Both files must be modified: init.cjs (function definition) AND qaa-tools.cjs (CLI router case).
**Warning signs:** Orchestrator fails at first init call.

## Code Examples

### Init System: cmdInitQaStart Return Schema

Based on the existing init variants pattern (cmdInitExecutePhase, cmdInitPlanPhase, etc.), the new `cmdInitQaStart` should return:

```javascript
// bin/lib/init.cjs -- new function
function cmdInitQaStart(cwd, raw) {
  const config = loadConfig(cwd);

  // Detect repo paths from arguments or working directory
  const devRepoPath = /* detect or receive as param */;
  const qaRepoPath = /* detect second repo if provided, null otherwise */;

  // Determine workflow option
  // 1 repo = Option 1
  // 2 repos = score QA repo maturity -> Option 2 or 3
  let option = 1;
  let maturityScore = null;
  if (qaRepoPath) {
    maturityScore = /* scoring logic or null for orchestrator to compute */;
    option = maturityScore >= 70 ? 3 : 2;
    if (maturityScore === 0) option = 1; // empty QA repo fallback
  }

  const result = {
    // Models for each agent
    scanner_model: resolveModelInternal(cwd, 'qaa-scanner'),
    analyzer_model: resolveModelInternal(cwd, 'qaa-analyzer'),
    planner_model: resolveModelInternal(cwd, 'qaa-planner'),
    executor_model: resolveModelInternal(cwd, 'qaa-executor'),
    validator_model: resolveModelInternal(cwd, 'qaa-validator'),
    detective_model: resolveModelInternal(cwd, 'qaa-validator'),  // bug-detective uses validator profile
    injector_model: resolveModelInternal(cwd, 'qaa-scanner'),     // testid-injector uses scanner profile

    // Workflow routing
    option,               // 1, 2, or 3
    maturity_score: maturityScore,

    // Repo paths
    dev_repo_path: devRepoPath,
    qa_repo_path: qaRepoPath,

    // Config flags
    auto_advance: config.workflow?.auto_advance || false,
    auto_chain_active: config.workflow?._auto_chain_active || false,
    commit_docs: config.commit_docs,
    parallelization: config.parallelization,

    // Pipeline state
    pipeline: {
      scan_status: 'pending',
      analyze_status: 'pending',
      generate_status: 'pending',
      validate_status: 'pending',
      deliver_status: 'pending',
    },

    // File existence
    state_exists: pathExistsInternal(cwd, '.planning/STATE.md'),
    config_exists: pathExistsInternal(cwd, '.planning/config.json'),

    // Output paths (where agents write artifacts)
    output_dir: '.qa-output',  // or orchestrator-determined path

    // Timestamps
    date: new Date().toISOString().split('T')[0],
    timestamp: new Date().toISOString(),
  };

  output(result, raw);
}
```

### CLI Router Addition

```javascript
// bin/qaa-tools.cjs -- add case in init switch
case 'qa-start':
  init.cmdInitQaStart(cwd, raw);
  break;
```

### State Pipeline Update Pattern

```bash
# Pattern the orchestrator uses before/after every agent spawn:

# === BEFORE agent spawn ===
node bin/qaa-tools.cjs state patch --"Scan Status" running
# Show banner
echo "
╔══════════════════════════════════════════╗
║  STAGE: Scanner                          ║
║  Status: Running...                      ║
╚══════════════════════════════════════════╝
"

# === Spawn agent ===
# Task(subagent_type="qaa-scanner", ...)

# === AFTER agent returns successfully ===
node bin/qaa-tools.cjs state patch --"Scan Status" complete

# === AFTER agent fails ===
node bin/qaa-tools.cjs state patch --"Scan Status" failed --"Status" "Pipeline stopped: Scanner failed"
# In auto mode: STOP ENTIRELY. Report failure. No partial PR.
```

### Auto-Advance Detection Pattern

```bash
# Read both the chain flag and user preference
AUTO_CHAIN=$(node bin/qaa-tools.cjs config-get workflow._auto_chain_active 2>/dev/null || echo "false")
AUTO_CFG=$(node bin/qaa-tools.cjs config-get workflow.auto_advance 2>/dev/null || echo "false")

# Check if --auto was passed
IS_AUTO=false
if [[ "$ARGUMENTS" =~ --auto ]] || [[ "$AUTO_CHAIN" == "true" ]] || [[ "$AUTO_CFG" == "true" ]]; then
  IS_AUTO=true
fi
```

### Checkpoint Handling in Orchestrator

```markdown
# After agent returns a CHECKPOINT_RETURN:

If IS_AUTO=true:
  Check checkpoint blocking field:
  - Contains "framework detection uncertain" -> SAFE: auto-approve with most likely framework
  - Contains "assumptions" -> SAFE: auto-approve all assumptions
  - Contains "data-testid" / "audit" -> SAFE: auto-approve P0-only injection
  - Contains "unresolved" or "failed" or "APPLICATION BUG" -> RISKY: present to user, wait
  - Default -> RISKY: present to user, wait

If IS_AUTO=false:
  Always present checkpoint to user, wait for response
  Then spawn continuation agent with fresh context + user's response
```

### Agent Return Parsing

Each agent returns a structured block that the orchestrator must parse:

```
# Scanner returns:
SCANNER_COMPLETE:  (not an actual return block name -- scanner returns 4 values)
  file_path: "..."
  decision: PROCEED | STOP
  has_frontend: true | false
  detection_confidence: HIGH | MEDIUM | LOW

# Analyzer returns:
ANALYZER_COMPLETE:
  files_produced: [...]
  total_test_count: N
  pyramid_breakdown: {unit: N, integration: N, api: N, e2e: N}
  risk_count: {high: N, medium: N, low: N}
  commit_hash: "..."

# Planner returns:
PLANNER_COMPLETE:
  file_path: "..."
  total_tasks: N
  total_files: N
  feature_count: N
  dependency_depth: N
  test_case_count: N
  commit_hash: "..."

# Executor returns:
EXECUTOR_COMPLETE:
  files_created: [{path, type}, ...]
  total_files: N
  commit_count: N
  features_covered: [...]
  test_case_count: N

# Validator returns:
VALIDATOR_COMPLETE:
  report_path: "..."
  overall_status: PASS | PASS_WITH_WARNINGS | FAIL
  confidence: HIGH | MEDIUM | LOW
  layers_summary: {syntax, structure, dependencies, logic}
  fix_loops_used: N
  issues_found: N
  issues_fixed: N
  unresolved_count: N

# Bug Detective returns:
DETECTIVE_COMPLETE:
  report_path: "..."
  total_failures: N
  classification_breakdown: {app_bug, test_error, env_issue, inconclusive}
  auto_fixes_applied: N
  auto_fixes_verified: N
  commit_hash: "..."

# TestID Injector returns:
INJECTOR_COMPLETE:
  report_path: "..."
  coverage_before: N%
  coverage_after: N%
  elements_injected: N
  ...
# OR:
INJECTOR_SKIPPED:
  reason: "..."
  action: "..."
```

### Stage Sequence Per Option

**Option 1 (dev-only, score N/A):**
```
1. init qa-start -> option=1
2. scan DEV repo -> SCAN_MANIFEST.md
3. analyze (mode='full') -> QA_ANALYSIS.md + TEST_INVENTORY.md + QA_REPO_BLUEPRINT.md
4. [if has_frontend] testid-inject -> TESTID_AUDIT_REPORT.md + modified source
5. plan -> Generation plan
6. generate (execute) -> test files, POMs, fixtures, configs
7. validate -> VALIDATION_REPORT.md
8. [if failures] bug-detective -> FAILURE_CLASSIFICATION_REPORT.md
9. deliver -> branch + PR
```

**Option 2 (dev + immature QA, score < 30):**
```
1. init qa-start -> option=2
2. scan BOTH repos -> SCAN_MANIFEST.md (combined)
3. analyze (mode='gap') -> GAP_ANALYSIS.md
4. [if has_frontend] testid-inject -> TESTID_AUDIT_REPORT.md + modified source
5. plan (from GAP_ANALYSIS) -> Generation plan (fix broken first, then add missing)
6. generate (gap mode) -> fixed test files + new test files + standardized files
7. validate -> VALIDATION_REPORT.md
8. [if failures] bug-detective -> FAILURE_CLASSIFICATION_REPORT.md
9. deliver -> branch + PR
```

**Option 3 (dev + mature QA, score >= 70):**
```
1. init qa-start -> option=3
2. scan BOTH repos -> SCAN_MANIFEST.md (combined)
3. analyze (mode='gap') -> GAP_ANALYSIS.md (thin areas only)
4. [if has_frontend] testid-inject -> TESTID_AUDIT_REPORT.md + modified source
5. plan (from GAP_ANALYSIS) -> Generation plan (missing tests only)
6. generate (skip existing by test ID) -> new test files only
7. validate -> VALIDATION_REPORT.md
8. [if failures] bug-detective -> FAILURE_CLASSIFICATION_REPORT.md
9. deliver -> branch + PR
```

### Maturity Scoring Implementation

```javascript
function scoreQaRepoMaturity(qaRepoPath) {
  let score = 0;

  // POM usage (25 points max)
  const hasPagesDir = fs.existsSync(path.join(qaRepoPath, 'pages')) ||
                      fs.existsSync(path.join(qaRepoPath, 'page-objects'));
  const hasBasePage = /* glob for **/BasePage.* */;
  if (hasPagesDir && hasBasePage) score += 25;
  else if (hasPagesDir) score += 12;

  // Assertion quality (25 points max)
  // Sample test files, count concrete (toBe, toEqual, toHaveText with value)
  // vs vague (toBeTruthy, toBeDefined, should('exist'))
  const concreteRatio = /* analyze */;
  score += Math.round(concreteRatio * 25);

  // CI/CD integration (20 points max)
  const hasCIConfig = /* check .github/workflows, Jenkinsfile, etc */;
  const hasTestCommands = /* check if CI config runs tests */;
  if (hasCIConfig && hasTestCommands) score += 20;
  else if (hasCIConfig) score += 10;

  // Fixture management (15 points max)
  const hasFixturesDir = fs.existsSync(path.join(qaRepoPath, 'fixtures'));
  const fixturesByDomain = /* check for domain-separated fixture files */;
  if (hasFixturesDir && fixturesByDomain) score += 15;
  else if (hasFixturesDir) score += 7;

  // Naming convention (15 points max)
  const namingRatio = /* sample test files, check pattern compliance */;
  score += Math.round(namingRatio * 15);

  return Math.min(100, score);
}
```

### Pipeline Summary Banner (End of Pipeline)

```
╔══════════════════════════════════════════════════════╗
║  QA PIPELINE COMPLETE                                ║
╠══════════════════════════════════════════════════════╣
║                                                      ║
║  Option: 1 (Dev-Only -- Full Pipeline)               ║
║  Repository: shopflow                                ║
║                                                      ║
║  Stages Completed:                                   ║
║    [x] Scan         -- 12s                           ║
║    [x] Analyze      -- 45s  (87 test cases)          ║
║    [x] TestID Inject-- 20s  (47 data-testid added)   ║
║    [x] Plan         -- 15s  (24 files planned)       ║
║    [x] Generate     -- 2m   (24 files created)       ║
║    [x] Validate     -- 30s  (HIGH confidence)        ║
║    [ ] Bug Detective-- skipped (all tests pass)      ║
║    [x] Deliver      -- 10s                           ║
║                                                      ║
║  Artifacts:                                          ║
║    SCAN_MANIFEST.md, QA_ANALYSIS.md,                 ║
║    TEST_INVENTORY.md, QA_REPO_BLUEPRINT.md,          ║
║    VALIDATION_REPORT.md, TESTID_AUDIT_REPORT.md      ║
║                                                      ║
║  Branch: qa/auto-shopflow-2026-03-19                 ║
║  PR: #42                                             ║
║  Total Time: 4m 12s                                  ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|-------------|------------------|--------------|--------|
| Separate workflow files per option | Single orchestrator with internal routing | Phase 5 design decision | Reduces maintenance; shared stages defined once |
| Manual option selection by user | Automated maturity scoring | Phase 5 design decision | User provides repos; system determines option |
| Parallel stages | Strictly sequential stages | Phase 5 design decision | Simpler, more predictable; parallelism only within executor |
| Agents own their state updates | Orchestrator owns all state updates | Phase 5 design decision | Single source of truth for pipeline progress |

## Open Questions

1. **Maturity scoring execution location**
   - What we know: Scoring needs to read the QA repo's file tree, check POM structure, sample assertions, check CI config, check fixtures, check naming
   - What's unclear: Should this be a function in init.cjs (Node.js) or should the orchestrator do it inline (Claude reading files)?
   - Recommendation: Implement basic structure checks in init.cjs (POM dir exists, CI config exists, fixtures dir exists) for fast scoring. Assertion quality sampling requires reading file contents which is better done inline by the orchestrator. Hybrid approach: init returns structural signals, orchestrator computes final score.

2. **Repo path detection mechanism**
   - What we know: User provides 1 or 2 repo paths when invoking `/qa-start`
   - What's unclear: How are paths passed -- as arguments to the slash command, or does the orchestrator prompt for them?
   - Recommendation: The `/qa-start` slash command passes repo paths as arguments. Init function receives them. If only 1 path, Option 1. If 2 paths, score the QA repo. If 0 paths, use cwd as dev repo.

3. **Deliver stage scope for Phase 5**
   - What we know: DLVR-01 through DLVR-04 are Phase 6 requirements (branch, commit, push, PR)
   - What's unclear: Does Phase 5's "deliver" stage implementation wait for Phase 6, or does it produce a stub?
   - Recommendation: Phase 5 should define the deliver stage in the orchestrator with the full flow described (branch naming, commit, push, PR via gh), but the actual slash commands and UX polish are Phase 6. The orchestrator's deliver step should be fully functional.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Node.js native (no test framework) |
| Config file | none -- manual verification |
| Quick run command | `node bin/qaa-tools.cjs init qa-start` (verify init returns valid JSON) |
| Full suite command | N/A -- orchestrator is a .md workflow file, not executable code |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FLOW-01 | Option 1 stage sequence | manual | Read orchestrator .md, verify stage order matches spec | N/A (workflow doc) |
| FLOW-02 | Option 2 stage sequence | manual | Read orchestrator .md, verify gap mode routing | N/A (workflow doc) |
| FLOW-03 | Option 3 stage sequence | manual | Read orchestrator .md, verify skip-existing logic | N/A (workflow doc) |
| FLOW-04 | Wave-based parallel execution | manual | Verify orchestrator allows executor parallelism | N/A (workflow doc) |
| FLOW-05 | Init qa-start returns valid JSON | unit-like | `node bin/qaa-tools.cjs init qa-start` | Needs cmdInitQaStart in init.cjs |
| FLOW-06 | Auto-advance reads config flags | unit-like | `node bin/qaa-tools.cjs config-get workflow.auto_advance` | Config system exists |
| FLOW-07 | Checkpoint patterns documented | manual | Read orchestrator .md, verify checkpoint handling | N/A (workflow doc) |

### Sampling Rate
- **Per task commit:** Verify init function returns valid JSON, verify orchestrator .md has required sections
- **Per wave merge:** Read full orchestrator, verify all 3 option paths complete
- **Phase gate:** Full review of orchestrator + init integration before Phase 6

### Wave 0 Gaps
- [ ] `bin/lib/init.cjs` -- add `cmdInitQaStart` function
- [ ] `bin/qaa-tools.cjs` -- add `qa-start` case to init router
- [ ] `agents/qa-pipeline-orchestrator.md` -- entire orchestrator file (does not exist yet)

## Sources

### Primary (HIGH confidence)
- `agents/qaa-scanner.md` (422 lines) -- Scanner agent interface, return values, checkpoint format
- `agents/qaa-analyzer.md` (508 lines) -- Analyzer agent interface, mode parameter, return values
- `agents/qaa-planner.md` (374 lines) -- Planner agent interface, generation plan format
- `agents/qaa-executor.md` (618 lines) -- Executor agent interface, per-file commit pattern
- `agents/qaa-validator.md` (450 lines) -- Validator agent interface, no-commit pattern, escalation
- `agents/qaa-bug-detective.md` (444 lines) -- Detective agent interface, classification categories
- `agents/qaa-testid-injector.md` (583 lines) -- Injector agent interface, branch pattern, skip logic
- `bin/lib/init.cjs` (782 lines) -- 12 existing init variants, consistent return schema pattern
- `bin/lib/state.cjs` (748 lines) -- Pipeline stage tracking, frontmatter sync, state update commands
- `bin/qaa-tools.cjs` (603 lines) -- CLI router with init switch case pattern
- `CLAUDE.md` (544 lines) -- Pipeline stages, stage transitions, auto-advance rules, agent coordination
- `.planning/phases/05-workflow-orchestration/05-CONTEXT.md` -- 12 locked decisions

### Secondary (MEDIUM confidence)
- `C:/Users/mrrai/.claude/get-shit-done/workflows/execute-phase.md` -- GSD orchestration pattern (reference for QAA orchestrator design)
- `C:/Users/mrrai/.claude/get-shit-done/references/checkpoints.md` -- Checkpoint type definitions and handling patterns

### Tertiary (LOW confidence)
- Maturity scoring algorithm weights -- recommended based on domain knowledge, not empirically validated

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all tools already exist in the project from Phase 1
- Architecture: HIGH -- follows established GSD orchestration pattern with project-specific adaptations
- Agent interfaces: HIGH -- all 7 agent files read in full, return formats documented verbatim
- Init system: HIGH -- 12 existing variants provide clear pattern for new qa-start variant
- State management: HIGH -- pipeline stages already in STATE.md frontmatter
- Maturity scoring: MEDIUM -- algorithm weights are discretionary; thresholds need real-world calibration
- Pitfalls: HIGH -- derived from GSD patterns, agent interface contracts, and locked decisions

**Research date:** 2026-03-19
**Valid until:** 2026-04-19 (stable -- all dependencies are project-internal)
