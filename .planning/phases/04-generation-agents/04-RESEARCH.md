# Phase 4: Generation Agents - Research

**Researched:** 2026-03-19
**Domain:** Agent workflow markdown files -- 5 generation/validation agents following established patterns
**Confidence:** HIGH

## Summary

Phase 4 builds 5 agent workflow markdown files (`qaa-planner.md`, `qaa-executor.md`, `qaa-validator.md`, `qaa-testid-injector.md`, `qaa-bug-detective.md`) in the `agents/` directory. These agents follow the exact same XML-tagged structure established by the 2 existing agents (`qaa-scanner.md` at 422 lines, `qaa-analyzer.md` at 508 lines) built in Phase 3. The agent files are pure markdown workflow definitions -- no JavaScript, no tests, no library dependencies. Each agent is a prompt specification that tells Claude Code how to perform a specific QA pipeline stage.

The research confirms all 5 agents have well-defined inputs, outputs, and behavioral contracts already specified across CONTEXT.md (14 locked decisions), CLAUDE.md (module boundaries, verification commands, read-before-write rules), skill files (4 SKILL.md files detailing execution steps), and templates (3 output format templates). The primary research task was to extract the exact structural pattern from existing agents and map each new agent's specific requirements, cross-dependencies, and quality gate checks.

**Primary recommendation:** Build each agent as a standalone markdown file following the exact `<purpose>`, `<required_reading>`, `<process>` (with `<step>` elements), `<output>`, `<quality_gate>`, `<success_criteria>` XML structure. Each agent's content is defined by its corresponding SKILL.md + template + CLAUDE.md sections + CONTEXT.md locked decisions. The 5 agents have no code dependencies on each other -- they communicate exclusively through file-based artifacts at runtime.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Validator self-fixes issues (does not send back to executor)
- 4 layers run sequentially, fail-fast: Layer 1 (syntax) -> Layer 2 (structure) -> Layer 3 (dependencies) -> Layer 4 (logic). Fix Layer 1 before checking Layer 2.
- Max 3 fix loops. After 3 loops with unresolved issues: escalate to user (interactive checkpoint showing remaining issues, user decides to fix manually or accept)
- Scope: generated files only (listed in generation plan), NOT pre-existing test files
- Layer 4 includes cross-check: scan existing test files for duplicate IDs and overlapping selectors to prevent collisions
- Fix confidence levels: HIGH (auto-apply: import paths, syntax), MEDIUM (flag for review: assertion values), LOW (flag for review: logic restructure). Only HIGH fixes applied automatically.
- VALIDATION_REPORT.md includes full fix history: each loop logged with issue found, fix attempted, result
- Validator does NOT commit fixes -- leaves them in working tree for orchestrator to commit once validation passes
- Planner groups test files by feature (auth tests together: unit+API+E2E), not by pyramid level
- Planner creates generation plan with task breakdown, dependencies between tasks, file assignments
- Planner reads TEST_INVENTORY.md as input, produces plan files that qaa-executor consumes
- Executor: one test file per commit: 'test(auth): add login.e2e.spec.ts'. Maximum traceability.
- Executor creates BasePage.ts only if missing -- extends existing if found. Respects existing QA repo structure.
- Executor writes actual test files following CLAUDE.md standards (Tier 1 locators, POM rules, concrete assertions)
- Testid-injector injects on a separate branch: `qa/testid-inject-{date}`. Working copy stays clean. User merges if approved.
- Default: inject P0 elements only (buttons, inputs, forms, links, modals). P1-P2 offered as optional follow-up.
- Audit-first workflow: Phase 1 produces TESTID_AUDIT_REPORT with proposed values -> user reviews -> Phase 2 injects only approved items
- Existing data-testid values: preserved as-is. Non-compliant existing IDs reported in audit with offer to rename (user decides per ID).
- Bug detective never touches application code. Only modifies test files. Application bugs are always report-only.
- Bug detective actually runs the test suite (not static analysis). Captures real output, classifies real failures. Requires test environment.
- Classification: APP BUG / TEST CODE ERROR / ENV ISSUE / INCONCLUSIVE with evidence and confidence levels

### Claude's Discretion
- Internal prompt structure within each agent .md
- How planner determines task dependencies
- How executor handles framework-specific config generation
- Bug detective's exact test runner detection logic

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| AGENT-03 | qa-planner agent creates test generation plans with task breakdown, dependencies, and file assignments | Planner reads TEST_INVENTORY.md + QA_ANALYSIS.md, groups by feature, produces generation plan. SKILL: qa-template-engine defines generation patterns. CLAUDE.md Module Boundaries defines reads/produces. |
| AGENT-04 | qa-executor agent writes actual test files (POM, specs, fixtures, config) following CLAUDE.md standards | Executor reads generation plan + TEST_INVENTORY.md + CLAUDE.md. SKILL: qa-template-engine defines POM rules, test templates, locator priority. Templates: qa-repo-blueprint.md defines folder structure. |
| AGENT-05 | qa-validator agent runs 4-layer validation (syntax, structure, dependencies, logic) with max 3 fix loops | Validator reads generated files + CLAUDE.md. SKILL: qa-self-validator defines 4 layers + fix loop protocol. Template: validation-report.md defines output format. 14 CONTEXT.md decisions lock behavior. |
| AGENT-06 | qa-testid-injector agent scans frontend code, audits missing data-testid, injects following naming convention | Injector reads SCAN_MANIFEST.md + source files + CLAUDE.md data-testid Convention. SKILL: qa-testid-injector defines 4 phases. Template: testid-audit-report.md defines output format. data-testid-SKILL.md has full naming rules. |
| AGENT-07 | qa-bug-detective agent classifies test failures as APP BUG / TEST ERROR / ENV ISSUE / INCONCLUSIVE with evidence | Detective reads test output + test files + CLAUDE.md. SKILL: qa-bug-detective defines decision tree + confidence levels. Template: failure-classification.md defines output format with 4 required sections. |
</phase_requirements>

## Standard Stack

This phase produces no code artifacts -- only markdown files. There are no library dependencies.

### Core
| Asset | Location | Purpose | Why Standard |
|-------|----------|---------|--------------|
| Agent .md format | `agents/*.md` | XML-tagged workflow definition | Established in Phase 3 (scanner + analyzer). All 7 agents use same structure. |
| SKILL.md files | `.claude/skills/*/SKILL.md` | Behavioral specifications per agent | Define execution steps, decision trees, quality gates that agent .md files encode |
| Templates | `templates/*.md` | Output format contracts | Define exact section structure, field requirements, worked examples for agent output |
| CLAUDE.md | `CLAUDE.md` | QA standards + module boundaries | Defines reads/produces per agent, verification commands, data-testid convention |

### Supporting
| Asset | Location | Purpose | When to Use |
|-------|----------|---------|-------------|
| `data-testid-SKILL.md` | root | Full naming convention | Testid-injector agent references for injection rules |
| `bin/qaa-tools.cjs` | `bin/` | CLI commit helper | Agents reference for commit commands in write_output steps |
| `bin/lib/model-profiles.cjs` | `bin/lib/` | Model assignment per agent | Confirms all 7 agent types are registered |

### Alternatives Considered
Not applicable -- this phase produces markdown workflow files, not code.

## Architecture Patterns

### Established Agent .md Structure (from Phase 3)

Every agent .md file follows this exact XML-tagged structure:

```xml
<purpose>
[1-2 paragraph description of what this agent does, what it reads, what it produces,
how it fits in the pipeline, and how it's spawned by the orchestrator]
</purpose>

<required_reading>
[List of files the agent MUST read before producing output.
Each file gets a description of what to extract from it.
References templates and CLAUDE.md sections explicitly.]
</required_reading>

<process>

<step name="step_name" priority="first|normal">
[Detailed instructions for this step.
Includes: what to read, what to compute, what to produce.
Includes decision gates and CHECKPOINT_RETURN blocks where needed.]
</step>

<step name="next_step">
[...]
</step>

[... more steps ...]

</process>

<output>
[Description of artifacts produced.
Lists file paths, section counts, return values to orchestrator.
Includes structured return format (e.g., ANALYZER_COMPLETE: ...)]
</output>

<quality_gate>
[Checklist of ALL verification items.
Includes items from template quality gates (verbatim).
Includes agent-specific additional checks.
Every item is a checkbox: - [ ] description]
</quality_gate>

<success_criteria>
[Numbered list of conditions that must ALL be true for the agent to be complete.
Includes: artifacts exist, sections populated, quality gate passes, committed, return values provided.]
</success_criteria>
```

### Key Structural Patterns Observed in Existing Agents

**Pattern 1: Required Reading is Prescriptive**

The `<required_reading>` section names exact files and exact sections within those files. It does not say "read CLAUDE.md" -- it says "read CLAUDE.md -- focus on these sections: Module Boundaries, Verification Commands, Framework Detection, Read-Before-Write Rules, data-testid Convention."

**Pattern 2: Steps Include Decision Points and Checkpoints**

Steps contain inline `CHECKPOINT_RETURN:` blocks for cases where human input is needed. Format:
```
CHECKPOINT_RETURN:
completed: "description of what was done"
blocking: "what blocks progress"
details: "specific data about the situation"
awaiting: "what the agent needs from the user or orchestrator"
```

**Pattern 3: Quality Gate Embeds Template Quality Gates Verbatim**

The scanner agent's quality gate says "From templates/scan-manifest.md quality gate (all 10 items -- VERBATIM):" and then lists all 10 items from the template, plus agent-specific additional checks. This is the established convention.

**Pattern 4: Steps Reference Concrete Tools and Commands**

Steps reference exact CLI commands (`node bin/qaa-tools.cjs commit`), exact Glob patterns, exact file paths. They do not use abstract "scan the files" language -- they specify exactly which tool calls to make.

**Pattern 5: Output Section Includes Structured Return to Orchestrator**

Each agent ends with a structured data block that the orchestrator parses. Scanner returns `file_path, decision, has_frontend, detection_confidence`. Analyzer returns `ANALYZER_COMPLETE:` with file paths, counts, breakdown.

### Recommended File Sizes (Based on Existing Agents)

| Agent | Expected Size | Reasoning |
|-------|--------------|-----------|
| qaa-planner.md | ~350-450 lines | Simpler than analyzer (fewer output artifacts), but needs dependency logic |
| qaa-executor.md | ~500-600 lines | Most complex -- framework detection, POM generation, test writing, per-file commits |
| qaa-validator.md | ~450-550 lines | 4 validation layers + fix loop logic + confidence calculation |
| qaa-testid-injector.md | ~500-600 lines | 4 phases (scan, audit, inject, validate) + framework-specific injection rules |
| qaa-bug-detective.md | ~400-500 lines | Decision tree + classification + evidence requirements + auto-fix rules |

### Anti-Patterns to Avoid

- **Vague step instructions:** "Analyze the code" is wrong. "Read each test file. For each file, check Layer 1 (syntax) by running `tsc --noEmit`. If exit code != 0, record the error in the Syntax column." is correct.
- **Missing required_reading entries:** Every template and CLAUDE.md section the agent references MUST be listed in `<required_reading>`. If an agent references `templates/validation-report.md` in a step, it must also appear in required_reading.
- **Quality gate that doesn't match template:** The quality gate MUST include all items from the corresponding template's quality gate section, verbatim.
- **Steps that skip CHECKPOINT_RETURN for blocking situations:** If a step can reach a state where it cannot proceed (e.g., no test files found, framework unknown), it MUST include a CHECKPOINT_RETURN block.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Agent .md structure | Custom format | Exact XML tags from scanner/analyzer | Orchestrator parses these tags. Custom format breaks spawning. |
| Commit logic | Custom git commands | `node bin/qaa-tools.cjs commit` | CLI handles staging, message format, error handling |
| Output format | Freeform markdown | Template-matching structure | Downstream agents and human reviewers expect exact section names and field names |
| Test ID naming | Ad-hoc names | CLAUDE.md data-testid Convention | 20+ element-type suffixes, context derivation rules, max 3 levels -- too many rules to inline |

## Common Pitfalls

### Pitfall 1: Planner Grouping by Pyramid Level Instead of Feature
**What goes wrong:** Test files for the same feature (e.g., auth unit tests, auth API tests, auth E2E tests) get scattered across separate task groups, losing the ability to validate cross-tier consistency for a feature.
**Why it happens:** Natural tendency to group by test type since TEST_INVENTORY.md is organized by pyramid tier.
**How to avoid:** Planner MUST reorganize TEST_INVENTORY test cases by feature. "auth" group contains UT-AUTH-*, API-AUTH-*, INT-AUTH-*, E2E-LOGIN-*. CONTEXT.md locks this decision.
**Warning signs:** Plan output has groups named "Unit Tests", "API Tests" instead of "Auth Feature", "Checkout Feature".

### Pitfall 2: Validator Checking Pre-Existing Test Files
**What goes wrong:** Validator reports issues in files that were not generated by this pipeline, creating noise and potentially breaking existing tests.
**Why it happens:** Without explicit scoping, a "validate all test files" approach picks up everything.
**How to avoid:** CONTEXT.md locks scope to "generated files only (listed in generation plan)". Validator step 1 MUST read the generation plan to get the exact file list, then validate ONLY those files.
**Warning signs:** Validation report contains entries for files not in the generation plan.

### Pitfall 3: Testid-Injector Modifying Existing data-testid Values
**What goes wrong:** Existing test IDs that working tests depend on get renamed, breaking those tests.
**Why it happens:** Naming convention audit finds non-compliant existing IDs and auto-renames them.
**How to avoid:** CONTEXT.md locks: "Existing data-testid values: preserved as-is." Non-compliant existing IDs are REPORTED in the audit with an OFFER to rename, but the user decides per ID. No auto-rename.
**Warning signs:** Modified source files show changed data-testid values that already existed before the injection run.

### Pitfall 4: Bug Detective Modifying Application Code
**What goes wrong:** Detective auto-fixes a failure by changing production code, introducing bugs or breaking existing functionality.
**Why it happens:** Classification determines "APPLICATION BUG" but the auto-fix logic applies a change anyway.
**How to avoid:** CONTEXT.md locks: "Never touches application code. Only modifies test files." The auto-fix rules in SKILL.md limit auto-fixes to TEST CODE ERROR at HIGH confidence only. No other classification gets auto-fixed.
**Warning signs:** Git diff shows changes in `src/` or `app/` directories after bug detective runs.

### Pitfall 5: Executor Not Checking for Existing BasePage
**What goes wrong:** A new BasePage.ts overwrites the existing one, losing project-specific shared methods (custom waits, screenshots, auth helpers).
**Why it happens:** Executor blindly creates BasePage.ts as part of scaffolding.
**How to avoid:** CONTEXT.md locks: "Creates BasePage.ts only if missing -- extends existing if found." Executor step must glob for `**/BasePage.*` or `**/base-page.*` before writing.
**Warning signs:** BasePage.ts is in the commit diff when one already existed in the QA repo.

### Pitfall 6: Validator Fix Confidence Mismatch
**What goes wrong:** A MEDIUM-confidence fix (changing an assertion value) gets auto-applied, and it's wrong -- the assertion was correct, the production code had a bug.
**Why it happens:** Fix confidence classification is too generous.
**How to avoid:** CONTEXT.md locks: "Only HIGH fixes applied automatically." HIGH is limited to: import paths, syntax errors (missing semicolons, brackets), missing await keywords. MEDIUM and LOW MUST be flagged for review, never auto-applied.
**Warning signs:** Auto-fix log shows assertion value changes applied without review.

## Code Examples

These are structural examples showing the exact format each agent .md file should follow. Source: existing `agents/qaa-scanner.md` and `agents/qaa-analyzer.md`.

### Example: Required Reading Section (from qaa-scanner.md)

```markdown
<required_reading>
Read these files BEFORE any scanning operation. Do NOT skip.

- `templates/scan-manifest.md` -- Output format contract. Defines the 5 required sections...

- `CLAUDE.md` -- QA automation standards. Read these sections:
  - **Framework Detection** -- Detection priority order and rules
  - **Module Boundaries** -- Scanner reads repo source files, package.json, file tree; produces SCAN_MANIFEST.md
  - **Verification Commands** -- SCAN_MANIFEST.md must have > 0 files in File List...
  - **Read-Before-Write Rules** -- Scanner MUST read package.json (or equivalent)...
  - **data-testid Convention** -- Understand naming convention...

Note: Read these files in full. Extract the required sections, field definitions, and quality gate checklist...
</required_reading>
```

### Example: Step with CHECKPOINT_RETURN (from qaa-analyzer.md)

```markdown
<step name="assumptions_checkpoint">
Before generating any analysis artifacts, produce an interactive checkpoint...

1. **Read SCAN_MANIFEST.md** completely...
2. **List 3-8 assumptions** about the codebase with evidence...
3. **List 0-3 questions** that genuinely affect analysis quality...
4. **Return checkpoint** with this exact structure:

CHECKPOINT_RETURN:
completed: "Read SCAN_MANIFEST.md, identified assumptions and questions"
blocking: "Need user confirmation on assumptions before generating analysis"
details:
  assumptions:
    - assumption: "[text describing what you assume about the codebase]"
      evidence: "[specific file, dependency, or pattern...]"
  questions:
    - "[question text -- only if the answer genuinely affects analysis]"
awaiting: "User confirms assumptions are correct or provides corrections."

**If running in auto-advance mode:** The orchestrator will auto-approve...
</step>
```

### Example: Quality Gate Section (from qaa-scanner.md)

```markdown
<quality_gate>
Before considering the scan complete, verify ALL of the following.

**From templates/scan-manifest.md quality gate (all 10 items -- VERBATIM):**

- [ ] Project Detection section has all 5 required fields populated...
- [ ] File List contains every source file relevant to testing...
[... all 10 template items ...]

**Additional scanner-specific checks:**

- [ ] has_frontend field present in Decision Gate (true/false)
- [ ] detection_confidence field present in Decision Gate (HIGH/MEDIUM/LOW)
[... agent-specific items ...]

If any check fails, fix the issue before writing the final output.
</quality_gate>
```

### Example: Structured Return to Orchestrator (from qaa-analyzer.md)

```markdown
ANALYZER_COMPLETE:
  files_produced:
    - path: "{qa_analysis_path}"
      artifact: "QA_ANALYSIS.md"
    - path: "{test_inventory_path}"
      artifact: "TEST_INVENTORY.md"
  total_test_count: {N}
  pyramid_breakdown:
    unit: {count}
    integration: {count}
    api: {count}
    e2e: {count}
  commit_hash: "{hash}"
```

## Agent-Specific Research Findings

### Agent 1: qaa-planner (AGENT-03)

**Reads:** TEST_INVENTORY.md, QA_ANALYSIS.md
**Produces:** Generation plan (internal artifact -- no template)
**CLAUDE.md Module Boundaries:** "qa-planner reads TEST_INVENTORY.md, QA_ANALYSIS.md; produces Generation plan (internal)"

**Key behaviors (from CONTEXT.md):**
1. Groups test cases by FEATURE, not pyramid tier
2. Creates task breakdown with dependencies between tasks
3. Creates file assignments (which test files will be written)

**Process steps (recommended, Claude's discretion on internal structure):**
1. `read_inputs` -- Read TEST_INVENTORY.md and QA_ANALYSIS.md
2. `analyze_features` -- Extract feature domains from test case IDs and targets (e.g., UT-AUTH-*, API-AUTH-* = "auth" feature)
3. `create_feature_groups` -- Group test cases by feature, include all pyramid tiers per feature
4. `determine_dependencies` -- Identify task ordering: BasePage before feature POMs, POMs before E2E specs, fixtures before tests, config before anything
5. `assign_files` -- Map test cases to output file paths following CLAUDE.md naming conventions
6. `produce_plan` -- Write generation plan with task list, dependencies, file assignments
7. `validate_plan` -- Verify all TEST_INVENTORY test cases are assigned, no duplicates, dependencies are acyclic

**Output structure (no template -- Claude's discretion):**
Generation plan should include per-task: task ID, feature group, file paths to create, test case IDs included, dependencies (which tasks must complete first), estimated complexity.

**Quality gate (from CLAUDE.md Verification Commands):**
- Test cases mapped to output files
- No unassigned cases
- No duplicate assignments

### Agent 2: qaa-executor (AGENT-04)

**Reads:** Generation plan (from planner), TEST_INVENTORY.md, CLAUDE.md
**Produces:** test files, POMs, fixtures, configs
**SKILL:** qa-template-engine -- POM rules, test templates, locator priority, assertion rules
**CLAUDE.md Module Boundaries:** "qa-executor reads TEST_INVENTORY.md, CLAUDE.md; produces test files, POMs, fixtures, configs"

**Key behaviors (from CONTEXT.md):**
1. One test file per commit: `test(auth): add login.e2e.spec.ts`
2. Creates BasePage.ts only if missing -- extends existing if found
3. Follows CLAUDE.md standards: Tier 1 locators, POM rules, concrete assertions, naming conventions

**Process steps:**
1. `read_inputs` -- Read generation plan, TEST_INVENTORY.md, CLAUDE.md (POM rules, locator tiers, naming, quality gates), QA_REPO_BLUEPRINT.md (if exists, for folder structure)
2. `detect_existing_infrastructure` -- Check for existing BasePage, existing test config, existing POM structure. Respect what exists.
3. `scaffold_base` -- If BasePage.ts missing, create it. If test config missing, create framework-specific config. If fixture directory missing, create it.
4. `generate_per_task` -- For each task in the generation plan (in dependency order):
   - Read the assigned test cases from TEST_INVENTORY.md
   - Generate the file following qa-template-engine patterns
   - Apply CLAUDE.md standards (locator hierarchy, assertion specificity, no POM assertions)
   - Commit: `node bin/qaa-tools.cjs commit "test({feature}): add {filename}" --files {path}`
5. `verify_output` -- All planned files exist, imports resolve

**Framework detection (Claude's discretion on exact logic):**
The executor must detect the test framework from existing config files or QA_REPO_BLUEPRINT.md. Priority: existing config > blueprint recommendation > ask user.

**Quality gate (from CLAUDE.md Verification Commands + Quality Gates):**
- All planned files exist
- Imports resolve
- Syntax valid
- Every test has unique ID, exact target, concrete inputs, explicit outcome, priority
- No assertions in page objects
- All locators follow tier hierarchy
- No hardcoded credentials
- File naming follows conventions

### Agent 3: qaa-validator (AGENT-05)

**Reads:** Generated test files, CLAUDE.md
**Produces:** VALIDATION_REPORT.md
**SKILL:** qa-self-validator -- 4 layers, fix loop protocol
**Template:** templates/validation-report.md -- 5 required sections (summary, file-details, unresolved-issues, fix-loop-log, confidence-level)
**CLAUDE.md Module Boundaries:** "qa-validator reads generated test files, CLAUDE.md; produces VALIDATION_REPORT.md"

**Key behaviors (from CONTEXT.md -- 8 locked decisions):**
1. Self-fixes issues (does not send back to executor)
2. 4 layers sequentially, fail-fast
3. Max 3 fix loops; after 3 with unresolved: escalate to user via CHECKPOINT_RETURN
4. Scope: generated files only
5. Layer 4 cross-checks existing test files for duplicate IDs and overlapping selectors
6. Fix confidence: HIGH=auto-apply, MEDIUM/LOW=flag for review
7. VALIDATION_REPORT.md includes full fix history
8. Does NOT commit -- leaves in working tree

**Process steps:**
1. `read_inputs` -- Read CLAUDE.md (quality gates, locator tiers, assertion rules), read generation plan (to get file list), read all generated test files
2. `validate_layer_1_syntax` -- Run tsc --noEmit (TS), node --check (JS), python -m py_compile (Python), or project linter. Record all errors.
3. `validate_layer_2_structure` -- Check: correct directory placement, naming convention, has test functions, imports reference real modules, no hardcoded secrets, POM structure compliance
4. `validate_layer_3_dependencies` -- Check: all imports resolvable, packages in package.json, no missing deps, no circular deps, fixtures reference existing files
5. `validate_layer_4_logic` -- Check: happy-path has positive assertions, error tests have negative assertions, setup/teardown symmetric, no duplicate test IDs (cross-check existing!), assertions concrete (reject toBeTruthy/toBeDefined), each test has >= 1 assertion
6. `fix_loop` -- If any layer FAIL: attempt fixes (HIGH confidence only), re-validate from failed layer. Repeat up to 3 times. After 3: CHECKPOINT_RETURN with remaining issues.
7. `produce_report` -- Write VALIDATION_REPORT.md matching template exactly (5 sections)
8. `return_results` -- Return structured result to orchestrator (do NOT commit)

**Confidence calculation (from template):**
- HIGH: All layers PASS, 0 unresolved, 0-1 fix loops
- MEDIUM: All layers PASS after fixes, 0-2 minor unresolved, 2-3 loops
- LOW: Any layer still FAIL, or critical unresolved, 3 loops exhausted

**Quality gate (from templates/validation-report.md -- 7 items verbatim):**
- [ ] All 5 required sections present (Summary, File Details, Unresolved Issues, Fix Loop Log, Confidence Level)
- [ ] Summary table shows all 4 layers with counts
- [ ] Every validated file has its own File Details subsection with all 4 layers reported
- [ ] Unresolved Issues section present (either with issues or "None" statement)
- [ ] Fix Loop Log documents every loop iteration
- [ ] Confidence Level includes criteria table and specific confidence statement
- [ ] No file details entry says just "PASS" or "FAIL" without explanatory details

**Additional validator-specific checks:**
- [ ] Only generated files validated (not pre-existing)
- [ ] Layer 4 cross-checked existing test files for duplicate IDs
- [ ] Fix confidence correctly classified (HIGH auto-applied, MEDIUM/LOW flagged)
- [ ] Fix loop count <= 3
- [ ] If 3 loops exhausted with unresolved: CHECKPOINT_RETURN provided

### Agent 4: qaa-testid-injector (AGENT-06)

**Reads:** SCAN_MANIFEST.md (for has_frontend flag + component file list), source files, CLAUDE.md (data-testid Convention)
**Produces:** TESTID_AUDIT_REPORT.md, modified source files with data-testid attributes
**SKILL:** qa-testid-injector -- 4 phases (scan, audit, inject, validate)
**Template:** templates/testid-audit-report.md -- 5 required sections (summary, coverage-score, file-details, naming-convention-compliance, decision-gate)
**CLAUDE.md Module Boundaries:** "qa-testid-injector reads repo source files, SCAN_MANIFEST.md, CLAUDE.md; produces TESTID_AUDIT_REPORT.md, modified source files"
**Additional:** data-testid-SKILL.md at project root -- full naming convention (20+ suffixes, context derivation, edge cases)

**Key behaviors (from CONTEXT.md -- 4 locked decisions):**
1. Injects on separate branch: `qa/testid-inject-{date}` -- working copy stays clean
2. Default: inject P0 elements only; P1-P2 offered as optional follow-up
3. Audit-first: Phase 2 produces TESTID_AUDIT_REPORT with proposed values -> user reviews -> Phase 3 injects only approved items
4. Existing data-testid preserved as-is; non-compliant reported with offer to rename

**Process steps (4 phases):**
1. `read_inputs` -- Read SCAN_MANIFEST.md (has_frontend check), CLAUDE.md (data-testid Convention), data-testid-SKILL.md (full rules), templates/testid-audit-report.md (output format)
2. `phase_1_scan` -- Detect framework from package.json/file extensions. List all component files (React: *.jsx/*.tsx, Vue: *.vue, Angular: *.component.html). Exclude test/spec/stories. Prioritize by interaction density.
3. `phase_2_audit` -- For each file: identify interactive elements, classify P0/P1/P2, record existing data-testid as EXISTING, record missing with proposed value following naming convention. Calculate coverage score. Apply decision gate thresholds. Produce TESTID_AUDIT_REPORT.md.
4. `audit_checkpoint` -- CHECKPOINT_RETURN with audit results. User reviews proposed values, approves/rejects per element. If running in auto-advance: proceed with P0 defaults.
5. `phase_3_inject` -- Create branch `qa/testid-inject-{date}`. For each approved element: add data-testid as last attribute before closing >. Framework-specific handling (JSX, Vue, Angular, HTML). Dynamic list items use template literals.
6. `phase_4_validate` -- Syntax check modified files. Uniqueness check (no duplicates per page). Convention compliance check. Non-interference check (no other code modified).
7. `produce_report` -- Write TESTID_AUDIT_REPORT.md matching template. Write INJECTION_CHANGELOG.md.
8. `return_results` -- Return structured result: file paths, coverage scores, branch name, element counts.

**Quality gate (from templates/testid-audit-report.md -- 8 items verbatim):**
- [ ] Every interactive element across all scanned files has an entry in File Details
- [ ] All proposed data-testid values follow {context}-{description}-{element-type} convention
- [ ] No duplicate data-testid values within same page/route scope
- [ ] Coverage Score formula shown with correct calculation
- [ ] Decision Gate recommendation matches coverage score thresholds
- [ ] All existing data-testid values audited in Naming Convention Compliance section
- [ ] Priority assignments consistent: form inputs/submit buttons are P0, navigation/feedback P1, decorative P2
- [ ] Line numbers included for every element in every File Details table

**Additional injector-specific checks:**
- [ ] Injection happens on separate branch (qa/testid-inject-{date})
- [ ] Existing data-testid values preserved (not modified)
- [ ] Only approved items injected (audit-first workflow)
- [ ] Framework-specific injection syntax correct (JSX vs Vue vs Angular)

### Agent 5: qaa-bug-detective (AGENT-07)

**Reads:** Test execution output (stdout/stderr, exit codes), test source files, CLAUDE.md
**Produces:** FAILURE_CLASSIFICATION_REPORT.md
**SKILL:** qa-bug-detective -- Decision tree, confidence levels, auto-fix rules
**Template:** templates/failure-classification.md -- 4 required sections (summary, detailed-analysis, auto-fix-log, recommendations)
**CLAUDE.md Module Boundaries:** "qa-bug-detective reads test execution results, test source files, CLAUDE.md; produces FAILURE_CLASSIFICATION_REPORT.md"

**Key behaviors (from CONTEXT.md -- 3 locked decisions):**
1. Never touches application code. Only modifies test files.
2. Actually RUNS the test suite -- captures real output, classifies real failures. Requires test environment.
3. Classification: APP BUG / TEST CODE ERROR / ENV ISSUE / INCONCLUSIVE with evidence and confidence

**Process steps:**
1. `read_inputs` -- Read CLAUDE.md (classification rules, quality gates), templates/failure-classification.md (output format)
2. `detect_test_runner` -- Detect framework from config files (playwright.config.*, cypress.config.*, jest.config.*, vitest.config.*, pytest.ini) and package.json scripts. Claude's discretion on exact detection logic.
3. `run_tests` -- Execute the test suite using detected runner. Capture stdout, stderr, exit code. Parse test results (pass/fail per test case).
4. `classify_failures` -- For each failure, apply decision tree:
   - Syntax/import error in TEST file? -> TEST CODE ERROR
   - Error in PRODUCTION code path? -> APPLICATION BUG (if unexpected) or TEST CODE ERROR (if test expectation wrong)
   - Connection refused / timeout / missing env var? -> ENVIRONMENT ISSUE
   - Cannot determine? -> INCONCLUSIVE
5. `collect_evidence` -- For each failure: exact file:line, complete error message, code snippet, confidence level (HIGH/MEDIUM-HIGH/MEDIUM/LOW), reasoning for classification choice
6. `auto_fix` -- For TEST CODE ERROR at HIGH confidence only: fix import paths, selectors, assertion values, missing await, config fixes, fixture paths. Verify each fix by re-running the specific test.
7. `produce_report` -- Write FAILURE_CLASSIFICATION_REPORT.md matching template (4 sections). Include recommendations grouped by category.
8. `return_results` -- Return structured result: classification counts, auto-fix counts, report path.

**Quality gate (from templates/failure-classification.md -- 8 items verbatim):**
- [ ] All 4 required sections present (Summary, Detailed Analysis, Auto-Fix Log, Recommendations)
- [ ] Summary table includes all 4 categories even if count is 0
- [ ] Every failure has ALL mandatory fields: test name, classification, confidence, file:line, error message, evidence, action taken, resolution
- [ ] Every failure includes classification reasoning
- [ ] No APPLICATION BUG was auto-fixed
- [ ] Auto-Fix Log entries include verification result (PASS/FAIL)
- [ ] Recommendations grouped by category and specific to failures found
- [ ] INCONCLUSIVE entries explain what information is missing

**Additional detective-specific checks:**
- [ ] Test suite was actually executed (not static analysis)
- [ ] Application code was NOT modified
- [ ] Auto-fixes limited to TEST CODE ERROR at HIGH confidence
- [ ] Each auto-fix verified by re-running the failing test

## Cross-Agent Dependencies (Runtime Pipeline)

These are runtime data flow dependencies -- not build-time dependencies for this phase. All 5 agents are built independently as .md files.

```
qaa-scanner --[SCAN_MANIFEST.md]--> qaa-testid-injector
                                 --> qaa-analyzer --[QA_ANALYSIS.md, TEST_INVENTORY.md]--> qaa-planner
                                                                                          |
                                                                         [generation plan]--> qaa-executor
                                                                                              |
                                                                              [test files]--> qaa-validator
                                                                                              |
                                                                       [validated tests]--> qaa-bug-detective
```

**Key insight:** These dependencies affect the CONTENT of each agent .md (what it reads, what it expects as input), but not the BUILD ORDER of the .md files themselves. All 5 .md files can be built in any order or in parallel -- they are independent artifacts.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual verification (markdown files, no executable code) |
| Config file | None -- no automated tests for markdown |
| Quick run command | Manual review against quality gate checklist |
| Full suite command | Manual review against all quality gate items per agent |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| AGENT-03 | qaa-planner.md follows XML structure, has correct required_reading, process steps, quality gate | manual-only | Visual diff against scanner/analyzer pattern | N/A -- markdown file |
| AGENT-04 | qaa-executor.md has POM rules, locator tiers, per-file commit, BasePage check | manual-only | Visual verification of all CONTEXT.md decisions embedded | N/A -- markdown file |
| AGENT-05 | qaa-validator.md has 4 layers, fail-fast, fix loop, confidence, no-commit | manual-only | Quality gate checklist matches template verbatim | N/A -- markdown file |
| AGENT-06 | qaa-testid-injector.md has 4 phases, branch strategy, audit-first, preserve existing | manual-only | Quality gate checklist matches template verbatim | N/A -- markdown file |
| AGENT-07 | qaa-bug-detective.md has test execution, decision tree, evidence, no-app-code-touch | manual-only | Quality gate checklist matches template verbatim | N/A -- markdown file |

### Sampling Rate
- **Per task commit:** Manual review that new .md file follows XML structure of existing agents
- **Per wave merge:** Verify all 5 agent .md files have matching patterns and consistent cross-references
- **Phase gate:** All 5 files exist in `agents/`, each has all 6 XML sections, quality gates embed template items verbatim

### Wave 0 Gaps
None -- this phase produces markdown files, not executable code. No test infrastructure needed.

## Verification Checklist for Each Agent .md

Every agent .md file produced in this phase MUST pass these structural checks:

1. **Has all 6 XML sections:** `<purpose>`, `<required_reading>`, `<process>`, `<output>`, `<quality_gate>`, `<success_criteria>`
2. **Purpose paragraph mentions:** what it reads, what it produces, where it fits in the pipeline, how the orchestrator spawns it
3. **Required_reading lists:** every template file referenced, every CLAUDE.md section used, input artifacts from upstream agents
4. **Process has named steps:** each `<step name="...">` with clear instructions, decision gates, CHECKPOINT_RETURN where blocking is possible
5. **Output section:** lists all artifacts produced, includes structured return format for orchestrator
6. **Quality gate:** includes template quality gate items VERBATIM plus agent-specific additional checks
7. **Success criteria:** numbered list of completion conditions
8. **CONTEXT.md locked decisions:** all relevant locked decisions from CONTEXT.md are encoded in the agent's steps (not just mentioned, but enforced in step logic)
9. **Commit command:** uses `node bin/qaa-tools.cjs commit` with correct message format (where applicable -- validator does NOT commit)
10. **Consistent with CLAUDE.md Module Boundaries:** agent reads only what its row says, produces only what its row says

## Open Questions

1. **Generation plan format (qaa-planner output)**
   - What we know: Planner produces a "generation plan" that executor consumes. CLAUDE.md Module Boundaries says "Generation plan (internal)" with no template.
   - What's unclear: Exact format of the generation plan markdown. No template exists for it.
   - Recommendation: Claude's discretion (per CONTEXT.md). Design a simple, structured format: task list with IDs, feature groups, file paths, test case IDs, dependencies. Document the format in qaa-planner.md's `<output>` section so qaa-executor knows what to parse.

2. **Executor commit message prefix**
   - What we know: CONTEXT.md says `test(auth): add login.e2e.spec.ts` -- using `test()` prefix.
   - What's unclear: Whether this should use `qa(executor):` (per CLAUDE.md Git Workflow) or `test({feature}):` (per CONTEXT.md example).
   - Recommendation: Use the CONTEXT.md example `test({feature}): add {filename}` since it was a locked decision with a specific example.

## Sources

### Primary (HIGH confidence)
- `agents/qaa-scanner.md` -- Exact agent .md structure (422 lines, 6 XML sections, 6 steps)
- `agents/qaa-analyzer.md` -- Exact agent .md structure (508 lines, 6 XML sections, 7 steps, checkpoint pattern)
- `.claude/skills/qa-self-validator/SKILL.md` -- Validator 4 layers, fix loop protocol, output format
- `.claude/skills/qa-bug-detective/SKILL.md` -- Classification decision tree, confidence levels, auto-fix rules
- `.claude/skills/qa-testid-injector/SKILL.md` -- 4 injection phases, naming convention, framework-specific rules
- `.claude/skills/qa-template-engine/SKILL.md` -- Test templates, POM rules, locator priority, assertion rules
- `templates/validation-report.md` -- 5 required sections, worked example, quality gate (7 items)
- `templates/failure-classification.md` -- 4 required sections, decision tree, worked example, quality gate (8 items)
- `templates/testid-audit-report.md` -- 5 required sections, worked example, quality gate (8 items)
- `templates/qa-repo-blueprint.md` -- 7 required sections, executor/planner reference
- `CLAUDE.md` -- Module boundaries, verification commands, read-before-write rules, data-testid convention, quality gates
- `data-testid-SKILL.md` -- Full naming convention (20+ suffixes, context derivation, edge cases, framework-specific injection syntax)
- `.planning/phases/04-generation-agents/04-CONTEXT.md` -- 14 locked decisions, 4 discretion areas

### Secondary (MEDIUM confidence)
- `bin/lib/model-profiles.cjs` -- Confirms all 7 agent types registered with model mappings

### Tertiary (LOW confidence)
None -- all findings are from project source files.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- All inputs are project files, no external dependencies
- Architecture: HIGH -- Exact XML structure extracted from 2 existing agents, pattern is clear and consistent
- Pitfalls: HIGH -- All pitfalls derived from specific locked decisions in CONTEXT.md with clear violation scenarios
- Agent-specific details: HIGH -- Each agent's behavior fully specified across SKILL.md + template + CLAUDE.md + CONTEXT.md

**Research date:** 2026-03-19
**Valid until:** Indefinite -- these are internal project patterns, not external libraries
