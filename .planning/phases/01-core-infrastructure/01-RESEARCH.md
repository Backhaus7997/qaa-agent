# Phase 1: Core Infrastructure - Research

**Researched:** 2026-03-18
**Domain:** CLI tooling, configuration management, state machine, frontmatter parsing, workflow initialization (full port of GSD tooling to QA automation domain)
**Confidence:** HIGH

## Summary

This phase is a full port of the GSD (Get Shit Done) CLI tooling system into a QA Automation (QAA) equivalent. The source implementation consists of 13 CommonJS files totaling approximately 250KB of JavaScript: one CLI router (`gsd-tools.cjs`, 604 lines) and 12 library modules (`bin/lib/*.cjs`). The port involves copying every module, renaming internal references from `gsd` to `qaa`, replacing the GSD agent type registry with 7 QA-specific agent types, and adapting configuration defaults to the QA pipeline domain (scan, analyze, generate, validate, deliver).

The architecture is well-defined because the reference implementation is complete, stable, and thoroughly used in production. The research focus is therefore on documenting the exact API surface, command inventory, module dependencies, and rename scope so the planner can create precise, file-by-file implementation tasks. There are no library selection decisions -- everything uses Node.js built-in modules (fs, path, child_process, os) with zero external dependencies.

**Primary recommendation:** Port file-by-file in dependency order (model-profiles -> core -> frontmatter -> config -> state -> remaining modules -> CLI router), renaming `gsd` to `qaa` in identifiers, paths, branch templates, and user-facing strings. The 7 QA agent types replace all 14 GSD agent types in model-profiles.cjs.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Full port of gsd-tools.cjs -- copy all 100+ commands, rename gsd->qaa where applicable
- Tool named `qaa-tools.cjs` (QA Automation tools)
- Agent type prefix: `qaa-` (qaa-scanner, qaa-analyzer, qaa-executor, etc.)
- Library files keep same names as GSD (core.cjs, config.cjs, state.cjs, phase.cjs, etc.)
- Located at `bin/qaa-tools.cjs` + `bin/lib/*.cjs` at project root
- Per-project state tracking (one QA_STATE.md per project directory, like GSD)
- Full stage tracking -- each pipeline stage (scan, analyze, generate, validate, deliver) has its own status (pending/running/complete/failed)
- Can re-run any stage independently
- State persists across multiple runs within same project
- Mirror all 12+ GSD init variants: init new-project, init plan-phase, init execute-phase, init quick, init resume, etc.
- Full parity with GSD's init system at v1
- Port all 12 GSD lib modules as-is: core.cjs, config.cjs, state.cjs, phase.cjs, roadmap.cjs, frontmatter.cjs, template.cjs, milestone.cjs, verify.cjs, commands.cjs, init.cjs, model-profiles.cjs
- Rename internal references from gsd->qaa
- Keep same file structure and API patterns
- The 7 QA agent types for model-profiles.cjs: qaa-scanner, qaa-analyzer, qaa-planner, qaa-executor, qaa-validator, qaa-testid-injector, qaa-bug-detective

### Claude's Discretion
- Internal error handling and logging patterns
- Temp file handling for large JSON payloads
- Exact command help text and usage messages

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| INFRA-01 | qa-tools.cjs CLI accepts init, state, config, commit commands with JSON output | Full command inventory documented below (100+ commands across all switch/case branches in gsd-tools.cjs). CLI router pattern is async main() with switch/case dispatch. |
| INFRA-02 | Model profiles system resolves agent-specific models from quality/balanced/budget/inherit profiles | model-profiles.cjs is 69 lines. Needs new MODEL_PROFILES map with 7 QA agent types replacing 14 GSD types. Same 3 profiles (quality/balanced/budget) plus inherit. |
| INFRA-03 | Config system reads/writes .planning/config.json with mode, granularity, parallelization, workflow flags | config.cjs is 308 lines with ensureConfigFile, setConfigValue, cmdConfigSet, cmdConfigGet, cmdConfigSetModelProfile. Config defaults need qaa- branch templates. |
| INFRA-04 | State management creates and updates QA_STATE.md tracking scan->analyze->generate->validate->deliver pipeline | state.cjs is 723 lines. QA pipeline stages (scan/analyze/generate/validate/deliver) replace GSD's planning/executing/verifying states. Frontmatter sync, progression engine, field extraction all port directly. |
| INFRA-05 | Frontmatter parser reads/writes YAML frontmatter in all QA artifacts | frontmatter.cjs is 300 lines with extractFrontmatter, reconstructFrontmatter, spliceFrontmatter, parseMustHavesBlock, and 4 CRUD commands. Custom YAML parser (no external deps). Ports as-is. |
| INFRA-06 | Atomic commit system stages specific files and commits with descriptive messages | cmdCommit in commands.cjs (lines 217-263). Checks commit_docs config, gitignore status, stages files, commits, returns hash. Direct port. |
| INFRA-07 | Init system returns all workflow context as single JSON (models, paths, flags, state) | init.cjs is 783 lines with 12 init variants. Each gathers context and returns single JSON. Agent type references in resolveModelInternal calls need gsd->qaa rename. |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Node.js | 18+ (built-in) | Runtime | Same as GSD -- no external dependencies |
| fs | built-in | File I/O | All state/config/frontmatter operations |
| path | built-in | Path manipulation | Cross-platform path resolution |
| child_process | built-in | Git operations | execSync, spawnSync for git commands |
| os | built-in | System info | tmpdir for large payloads, homedir for defaults |

### Supporting
No external packages. This is intentional -- the entire GSD tooling runs with zero npm dependencies, and the QAA port must maintain this property.

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Custom YAML parser | js-yaml npm package | GSD uses a custom 84-line parser specifically tailored for frontmatter. No npm dependency needed. Port as-is. |
| Manual CLI arg parsing | commander/yargs npm package | GSD uses manual args parsing (process.argv.slice(2)). Simple switch/case is sufficient for internal tooling. Port as-is. |

**Installation:**
```bash
# No installation needed -- zero npm dependencies
# Just create the files in bin/qaa-tools.cjs and bin/lib/*.cjs
```

## Architecture Patterns

### Recommended Project Structure
```
bin/
  qaa-tools.cjs          # Main CLI router (port of gsd-tools.cjs)
  lib/
    model-profiles.cjs    # Agent-to-model mapping (7 QA agent types)
    core.cjs              # Shared utilities, output, paths, phase math
    frontmatter.cjs       # YAML frontmatter parser/serializer
    config.cjs            # Config CRUD operations
    state.cjs             # QA_STATE.md operations, progression engine
    phase.cjs             # Phase CRUD, discovery, lifecycle
    roadmap.cjs           # ROADMAP.md parsing and updates
    template.cjs          # Template selection and fill
    milestone.cjs         # Milestone archiving, requirements marking
    verify.cjs            # Verification suite, health checks
    commands.cjs          # Standalone utility commands
    init.cjs              # Compound init commands for workflow bootstrapping
```

### Pattern 1: CLI Router (async main + switch/case)
**What:** Single entry point dispatches to library modules based on first positional arg, with sub-commands via nested switch/case.
**When to use:** Every CLI invocation flows through this pattern.
**Example:**
```javascript
// Source: gsd-tools.cjs lines 145-603
async function main() {
  const args = process.argv.slice(2);
  // --cwd override parsing
  // --raw flag extraction
  const command = args[0];
  switch (command) {
    case 'state': {
      const subcommand = args[1];
      if (subcommand === 'json') state.cmdStateJson(cwd, raw);
      else if (subcommand === 'update') state.cmdStateUpdate(cwd, args[2], args[3]);
      // ... more subcommands
      break;
    }
    case 'init': {
      const workflow = args[1];
      switch (workflow) {
        case 'execute-phase': init.cmdInitExecutePhase(cwd, args[2], raw); break;
        // ... 11 more init variants
      }
      break;
    }
    // ... 20+ top-level commands
  }
}
main();
```

### Pattern 2: Output/Error Protocol
**What:** All commands produce JSON output via `output()` helper. Large payloads (>50KB) are written to tmpfile with `@file:` prefix. Errors go to stderr and exit(1).
**When to use:** Every command function must use `output()` for success and `error()` for failure.
**Example:**
```javascript
// Source: core.cjs lines 19-40
function output(result, raw, rawValue) {
  if (raw && rawValue !== undefined) {
    process.stdout.write(String(rawValue));
  } else {
    const json = JSON.stringify(result, null, 2);
    if (json.length > 50000) {
      const tmpPath = path.join(require('os').tmpdir(), `qaa-${Date.now()}.json`);
      fs.writeFileSync(tmpPath, json, 'utf-8');
      process.stdout.write('@file:' + tmpPath);
    } else {
      process.stdout.write(json);
    }
  }
  process.exit(0);
}

function error(message) {
  process.stderr.write('Error: ' + message + '\n');
  process.exit(1);
}
```

### Pattern 3: Module Dependency Graph
**What:** Modules have a strict dependency order. The planner MUST respect this for wave ordering.
**Dependency tree (leaf nodes first):**
```
model-profiles.cjs    -> (none)
core.cjs              -> model-profiles.cjs
frontmatter.cjs       -> core.cjs (safeReadFile, output, error)
config.cjs            -> core.cjs, model-profiles.cjs
state.cjs             -> core.cjs, frontmatter.cjs
phase.cjs             -> core.cjs, frontmatter.cjs, state.cjs
roadmap.cjs           -> core.cjs
template.cjs          -> core.cjs, frontmatter.cjs
milestone.cjs         -> core.cjs, frontmatter.cjs, state.cjs
verify.cjs            -> core.cjs, frontmatter.cjs, state.cjs
commands.cjs          -> core.cjs, frontmatter.cjs, model-profiles.cjs
init.cjs              -> core.cjs
qaa-tools.cjs         -> ALL lib modules
```

### Pattern 4: State Frontmatter Sync
**What:** Every write to STATE.md (via `writeStateMd`) automatically rebuilds YAML frontmatter from the markdown body, keeping machine-readable frontmatter and human-readable markdown in sync.
**When to use:** All state mutations must go through `writeStateMd()`, never direct `fs.writeFileSync`.

### Anti-Patterns to Avoid
- **Direct fs.writeFileSync for STATE.md:** Always use `writeStateMd()` to maintain frontmatter sync
- **Adding npm dependencies:** The zero-dependency design is intentional and must be preserved
- **Changing the output protocol:** All callers expect JSON on stdout, @file: for large payloads, error text on stderr
- **Breaking the --raw flag contract:** Raw mode returns a single plain-text value for simple shell consumption
- **Renaming module filenames:** Library files keep same names (core.cjs, config.cjs, etc.) as locked in decisions

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| YAML parsing | Full YAML parser | GSD's custom 84-line frontmatter extractor in frontmatter.cjs | Only handles frontmatter (key: value, arrays, 2-level nesting). Full YAML is overkill. |
| CLI argument parsing | Argument parser library | GSD's manual process.argv + indexOf pattern | Internal tooling called by agents, not humans. No need for --help, validation, etc. |
| Phase number comparison | Naive string compare | GSD's `comparePhaseNum()` function | Handles integers, letters (12A, 12B), decimals (12.1, 12.2), and hybrid (12A.1). |
| Git operations | Shell command strings | GSD's `execGit()` wrapper with spawnSync | Safe argument passing, cross-platform, structured return (exitCode, stdout, stderr). |
| Config file management | Manual JSON read/write | GSD's `loadConfig()` with defaults + migration | Handles missing fields, deprecated key migration, nested section support. |

**Key insight:** Everything in this phase is a port, not a design problem. The implementation patterns are battle-tested in GSD. The risk is in renaming scope, not in architecture decisions.

## Common Pitfalls

### Pitfall 1: Incomplete gsd-to-qaa Renaming
**What goes wrong:** Leftover `gsd` references in branch templates, tmpfile prefixes, directory names, error messages, or help text cause confusion and potential path conflicts.
**Why it happens:** The string "gsd" appears in 100+ places across the codebase -- not just identifiers but also in string literals, comments, paths, and config defaults.
**How to avoid:** Create a systematic rename checklist:
- `gsd-tools.cjs` -> `qaa-tools.cjs` (filename)
- `gsd-tools` -> `qaa-tools` (usage text, error messages)
- `gsd-` agent prefix -> `qaa-` (MODEL_PROFILES keys)
- `gsd/phase-{phase}-{slug}` -> `qaa/phase-{phase}-{slug}` (branch templates)
- `gsd/{milestone}-{slug}` -> `qaa/{milestone}-{slug}` (branch templates)
- `.gsd/` -> `.qaa/` (home directory for defaults, brave API key)
- `gsd-${Date.now()}.json` -> `qaa-${Date.now()}.json` (tmpfile prefix)
- `gsd_state_version` -> `qaa_state_version` (frontmatter key)
- `'gsd-executor'` etc. -> `'qaa-executor'` etc. in init.cjs resolveModelInternal calls
**Warning signs:** Tests or callers getting "unknown agent type" errors from resolveModel.

### Pitfall 2: Agent Type Mismatch in init.cjs
**What goes wrong:** init.cjs hardcodes GSD agent type strings like `'gsd-executor'`, `'gsd-planner'`, `'gsd-verifier'` in 30+ resolveModelInternal() calls. Missing even one causes silent fallback to 'sonnet'.
**Why it happens:** The agent type strings are scattered across all 12 init functions, not centralized.
**How to avoid:** Before writing init.cjs, catalog every resolveModelInternal() call in the GSD source and map each GSD agent type to its QAA equivalent:
- `gsd-executor` -> `qaa-executor`
- `gsd-planner` -> `qaa-planner`
- `gsd-verifier` -> `qaa-validator`
- `gsd-phase-researcher` -> `qaa-planner` (or keep as-is if used)
- `gsd-project-researcher` -> `qaa-scanner` (or keep as-is)
- `gsd-research-synthesizer` -> `qaa-analyzer` (or keep as-is)
- `gsd-roadmapper` -> `qaa-planner` (or keep as-is)
- `gsd-plan-checker` -> `qaa-validator` (or keep as-is)
- `gsd-codebase-mapper` -> `qaa-scanner` (or keep as-is)

Note: The 7 QA agent types (qaa-scanner, qaa-analyzer, qaa-planner, qaa-executor, qaa-validator, qaa-testid-injector, qaa-bug-detective) may not cover all GSD agent roles 1:1. The planner must decide the mapping.
**Warning signs:** `resolve-model` command returning `'sonnet'` with `unknown_agent: true`.

### Pitfall 3: State Machine Stage Differences
**What goes wrong:** GSD's state machine tracks planning phases (planning -> executing -> verifying -> complete). QAA needs a different pipeline (scan -> analyze -> generate -> validate -> deliver) but the state.cjs code is tightly coupled to GSD's field names.
**Why it happens:** STATE.md body content uses specific field names like "Current Phase", "Current Plan", "Status" that are matched by regex.
**How to avoid:** The port needs to:
1. Keep the generic state field infrastructure (stateExtractField, stateReplaceField, writeStateMd)
2. Adapt buildStateFrontmatter() to recognize QAA pipeline stages
3. Add stage-specific status tracking (per-stage pending/running/complete/failed)
**Warning signs:** State updates silently failing because field names don't match.

### Pitfall 4: Circular Module Dependencies
**What goes wrong:** state.cjs imports from frontmatter.cjs, and phase.cjs imports from state.cjs. If a port introduces an accidental circular require, Node.js returns partially-initialized modules.
**Why it happens:** The GSD module graph is carefully designed to be acyclic. Any import reordering during the port can break this.
**How to avoid:** Follow the exact dependency graph documented above. Test each module independently after porting.
**Warning signs:** "Cannot read property of undefined" errors at require() time.

### Pitfall 5: Windows Path Handling
**What goes wrong:** GSD uses `toPosixPath()` to normalize paths for JSON output. Missing this on Windows causes backslash paths in JSON that break callers expecting forward slashes.
**Why it happens:** The project runs on Windows (confirmed by environment context).
**How to avoid:** Port `toPosixPath()` exactly and ensure all path output uses it.
**Warning signs:** Paths in JSON output containing backslashes on Windows.

## Code Examples

### Complete Command Inventory (from gsd-tools.cjs)

The CLI router has 26 top-level commands. Each must be ported to qaa-tools.cjs:

**Atomic Commands (10):**
1. `state` (12 subcommands: load, json, update, get, patch, advance-plan, record-metric, update-progress, add-decision, add-blocker, resolve-blocker, record-session)
2. `resolve-model <agent-type>`
3. `find-phase <phase>`
4. `commit <message> [--files f1 f2] [--amend]`
5. `generate-slug <text>`
6. `current-timestamp [format]`
7. `list-todos [area]`
8. `verify-path-exists <path>`
9. `config-ensure-section`
10. `config-set <key> <value>`
11. `config-set-model-profile <profile>`
12. `config-get <key>`
13. `history-digest`
14. `summary-extract <path> [--fields]`
15. `state-snapshot`
16. `phase-plan-index <phase>`
17. `websearch <query> [--limit N] [--freshness]`

**Phase Operations (5 subcommands):**
18. `phase next-decimal <phase>`
19. `phase add <description>`
20. `phase insert <after> <description>`
21. `phase remove <phase> [--force]`
22. `phase complete <phase>`

**Phases query:**
23. `phases list [--type plans|summaries] [--phase N] [--include-archived]`

**Roadmap Operations (3 subcommands):**
24. `roadmap get-phase <phase>`
25. `roadmap analyze`
26. `roadmap update-plan-progress <N>`

**Requirements:**
27. `requirements mark-complete <ids>`

**Milestone:**
28. `milestone complete <version> [--name] [--archive-phases]`

**Validation (2 subcommands):**
29. `validate consistency`
30. `validate health [--repair]`

**Verify Suite (6 subcommands):**
31. `verify plan-structure <file>`
32. `verify phase-completeness <phase>`
33. `verify references <file>`
34. `verify commits <h1> [h2]...`
35. `verify artifacts <plan-file>`
36. `verify key-links <plan-file>`

**Frontmatter CRUD (4 subcommands):**
37. `frontmatter get <file> [--field k]`
38. `frontmatter set <file> --field k --value v`
39. `frontmatter merge <file> --data '{json}'`
40. `frontmatter validate <file> --schema plan|summary|verification`

**Template (2 subcommands):**
41. `template select <plan-path>`
42. `template fill summary|plan|verification --phase N [options]`

**Progress/Stats/Todo:**
43. `progress [json|table|bar]`
44. `stats [json|table]`
45. `todo complete <filename>`

**Scaffold (4 types):**
46. `scaffold context --phase N`
47. `scaffold uat --phase N`
48. `scaffold verification --phase N`
49. `scaffold phase-dir --phase N --name <name>`

**Init (12 variants):**
50. `init execute-phase <phase>`
51. `init plan-phase <phase>`
52. `init new-project`
53. `init new-milestone`
54. `init quick <description>`
55. `init resume`
56. `init verify-work <phase>`
57. `init phase-op <phase>`
58. `init todos [area]`
59. `init milestone-op`
60. `init map-codebase`
61. `init progress`

### Module Export Surfaces

**model-profiles.cjs (4 exports):**
```javascript
module.exports = {
  MODEL_PROFILES,              // Object: agent-type -> {quality, balanced, budget}
  VALID_PROFILES,              // Array: ['quality', 'balanced', 'budget']
  formatAgentToModelMapAsTable, // Function: (map) -> string table
  getAgentToModelMapForProfile, // Function: (profile) -> {agent: model}
};
```

**core.cjs (17 exports):**
```javascript
module.exports = {
  output, error, safeReadFile, loadConfig,
  isGitIgnored, execGit,
  escapeRegex, normalizePhaseName, comparePhaseNum,
  searchPhaseInDir, findPhaseInternal, getArchivedPhaseDirs,
  getRoadmapPhaseInternal, resolveModelInternal,
  pathExistsInternal, generateSlugInternal,
  getMilestoneInfo, getMilestonePhaseFilter,
  stripShippedMilestones, replaceInCurrentMilestone, toPosixPath,
};
```

**frontmatter.cjs (7 exports):**
```javascript
module.exports = {
  extractFrontmatter, reconstructFrontmatter, spliceFrontmatter,
  parseMustHavesBlock, FRONTMATTER_SCHEMAS,
  cmdFrontmatterGet, cmdFrontmatterSet, cmdFrontmatterMerge, cmdFrontmatterValidate,
};
```

**config.cjs (4 exports):**
```javascript
module.exports = {
  cmdConfigEnsureSection, cmdConfigSet, cmdConfigGet, cmdConfigSetModelProfile,
};
```

**state.cjs (13 exports):**
```javascript
module.exports = {
  stateExtractField, stateReplaceField, writeStateMd,
  cmdStateLoad, cmdStateGet, cmdStatePatch, cmdStateUpdate,
  cmdStateAdvancePlan, cmdStateRecordMetric, cmdStateUpdateProgress,
  cmdStateAddDecision, cmdStateAddBlocker, cmdStateResolveBlocker,
  cmdStateRecordSession, cmdStateSnapshot, cmdStateJson,
};
```

**phase.cjs (8 exports):**
```javascript
module.exports = {
  cmdPhasesList, cmdPhaseNextDecimal, cmdFindPhase, cmdPhasePlanIndex,
  cmdPhaseAdd, cmdPhaseInsert, cmdPhaseRemove, cmdPhaseComplete,
};
```

**roadmap.cjs (3 exports):**
```javascript
module.exports = {
  cmdRoadmapGetPhase, cmdRoadmapAnalyze, cmdRoadmapUpdatePlanProgress,
};
```

**template.cjs (2 exports):**
```javascript
module.exports = { cmdTemplateSelect, cmdTemplateFill };
```

**milestone.cjs (2 exports):**
```javascript
module.exports = { cmdRequirementsMarkComplete, cmdMilestoneComplete };
```

**verify.cjs (9 exports):**
```javascript
module.exports = {
  cmdVerifySummary, cmdVerifyPlanStructure, cmdVerifyPhaseCompleteness,
  cmdVerifyReferences, cmdVerifyCommits, cmdVerifyArtifacts, cmdVerifyKeyLinks,
  cmdValidateConsistency, cmdValidateHealth,
};
```

**commands.cjs (13 exports):**
```javascript
module.exports = {
  cmdGenerateSlug, cmdCurrentTimestamp, cmdListTodos, cmdVerifyPathExists,
  cmdHistoryDigest, cmdResolveModel, cmdCommit, cmdSummaryExtract,
  cmdWebsearch, cmdProgressRender, cmdTodoComplete, cmdScaffold, cmdStats,
};
```

**init.cjs (12 exports):**
```javascript
module.exports = {
  cmdInitExecutePhase, cmdInitPlanPhase, cmdInitNewProject, cmdInitNewMilestone,
  cmdInitQuick, cmdInitResume, cmdInitVerifyWork, cmdInitPhaseOp,
  cmdInitTodos, cmdInitMilestoneOp, cmdInitMapCodebase, cmdInitProgress,
};
```

### QAA Model Profiles (New)

The 7 QA agent types replace the 14 GSD agent types:

```javascript
// Source: User decision in CONTEXT.md + SKILL.md files
const MODEL_PROFILES = {
  'qaa-scanner':          { quality: 'opus',   balanced: 'sonnet', budget: 'haiku' },
  'qaa-analyzer':         { quality: 'opus',   balanced: 'sonnet', budget: 'haiku' },
  'qaa-planner':          { quality: 'opus',   balanced: 'opus',   budget: 'sonnet' },
  'qaa-executor':         { quality: 'opus',   balanced: 'sonnet', budget: 'sonnet' },
  'qaa-validator':        { quality: 'sonnet', balanced: 'sonnet', budget: 'haiku' },
  'qaa-testid-injector':  { quality: 'sonnet', balanced: 'sonnet', budget: 'haiku' },
  'qaa-bug-detective':    { quality: 'opus',   balanced: 'sonnet', budget: 'sonnet' },
};
```

Rationale for model assignments:
- `qaa-planner`: opus for balanced because planning test suites requires high reasoning (matching GSD planner pattern)
- `qaa-scanner`/`qaa-analyzer`: sonnet for balanced is sufficient for file tree building and analysis
- `qaa-executor`: sonnet for balanced since code generation is well-constrained by templates
- `qaa-validator`: sonnet for all since validation is pattern-matching
- `qaa-bug-detective`: opus for quality since failure classification requires deep reasoning

### Rename Scope: GSD -> QAA

**Config defaults that change:**
```javascript
// core.cjs loadConfig defaults
phase_branch_template: 'qaa/phase-{phase}-{slug}',  // was: 'gsd/phase-{phase}-{slug}'
milestone_branch_template: 'qaa/{milestone}-{slug}', // was: 'gsd/{milestone}-{slug}'

// config.cjs ensureConfigFile
const braveKeyFile = path.join(homedir, '.qaa', 'brave_api_key'); // was: '.gsd'
const globalDefaultsPath = path.join(homedir, '.qaa', 'defaults.json'); // was: '.gsd'

// core.cjs output
const tmpPath = path.join(require('os').tmpdir(), `qaa-${Date.now()}.json`); // was: 'gsd-'

// state.cjs buildStateFrontmatter
fm.qaa_state_version = '1.0'; // was: 'gsd_state_version'
```

**Error messages and usage text:**
```javascript
// qaa-tools.cjs (was gsd-tools.cjs)
error('Usage: qaa-tools <command> [args] [--raw] [--cwd <path>]\\n...');
// All /gsd: references in template.cjs, scaffold output -> /qa: or /qaa:
```

**Places where gsd appears but should NOT be renamed:**
- Comments referencing the GSD source (can be kept as documentation of origin)
- The file path `C:/Users/mrrai/.claude/get-shit-done/` (only in CONTEXT.md references, not in ported code)

### Init Command Agent Type Mapping

Every `resolveModelInternal()` call in init.cjs needs mapping:

| init.cjs Function | GSD Agent Type | QAA Agent Type |
|-------------------|---------------|---------------|
| cmdInitExecutePhase | gsd-executor | qaa-executor |
| cmdInitExecutePhase | gsd-verifier | qaa-validator |
| cmdInitPlanPhase | gsd-phase-researcher | qaa-analyzer |
| cmdInitPlanPhase | gsd-planner | qaa-planner |
| cmdInitPlanPhase | gsd-plan-checker | qaa-validator |
| cmdInitNewProject | gsd-project-researcher | qaa-scanner |
| cmdInitNewProject | gsd-research-synthesizer | qaa-analyzer |
| cmdInitNewProject | gsd-roadmapper | qaa-planner |
| cmdInitNewMilestone | gsd-project-researcher | qaa-scanner |
| cmdInitNewMilestone | gsd-research-synthesizer | qaa-analyzer |
| cmdInitNewMilestone | gsd-roadmapper | qaa-planner |
| cmdInitQuick | gsd-planner | qaa-planner |
| cmdInitQuick | gsd-executor | qaa-executor |
| cmdInitQuick | gsd-plan-checker | qaa-validator |
| cmdInitQuick | gsd-verifier | qaa-validator |
| cmdInitVerifyWork | gsd-planner | qaa-planner |
| cmdInitVerifyWork | gsd-plan-checker | qaa-validator |
| cmdInitMapCodebase | gsd-codebase-mapper | qaa-scanner |
| cmdInitProgress | gsd-executor | qaa-executor |
| cmdInitProgress | gsd-planner | qaa-planner |

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| GSD 14 agent types | QAA 7 agent types | This port | Focused model allocation for QA domain |
| GSD planning state (plan/execute/verify) | QAA pipeline state (scan/analyze/generate/validate/deliver) | This port | State machine needs pipeline-stage-level tracking |
| `.gsd/` home directory | `.qaa/` home directory | This port | Global defaults and API keys stored under new prefix |
| `gsd_state_version` frontmatter | `qaa_state_version` frontmatter | This port | Machine-readable state format for QA pipeline |

**Deprecated/outdated:**
- GSD's `depth` config key was already deprecated in favor of `granularity` (migration exists in loadConfig and ensureConfigFile). The port inherits this migration.

## File Size Reference

For the planner to estimate task sizes:

| Module | Lines | KB | Complexity |
|--------|-------|-----|-----------|
| model-profiles.cjs | 69 | 3.3 | Low -- data + 2 utility functions |
| core.cjs | 497 | 19 | Medium -- 17 utility functions, no commands |
| frontmatter.cjs | 300 | 12 | Medium -- parser, serializer, 4 CRUD commands |
| config.cjs | 308 | 9.7 | Medium -- 4 commands, config validation |
| state.cjs | 723 | 31 | High -- 13 exports, frontmatter sync, progression engine |
| phase.cjs | 911 | 31 | High -- 8 commands, phase CRUD with renumbering |
| roadmap.cjs | 307 | 11 | Medium -- 3 commands, roadmap parsing |
| template.cjs | 223 | 7.1 | Low -- 2 commands, template fill |
| milestone.cjs | 242 | 8.6 | Medium -- 2 commands, archiving |
| verify.cjs | 843 | 32 | High -- 9 commands, health checks with repair |
| commands.cjs | 710 | 24 | High -- 13 standalone commands |
| init.cjs | 783 | 26 | High -- 12 init variants with context gathering |
| qaa-tools.cjs | 604 | ~20 | Medium -- router only, no business logic |
| **TOTAL** | ~6,520 | ~235 | |

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Node.js built-in test runner or manual smoke tests |
| Config file | none -- see Wave 0 |
| Quick run command | `node bin/qaa-tools.cjs state --help 2>&1; echo $?` |
| Full suite command | Manual: run each command category and verify JSON output |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| INFRA-01 | CLI accepts init, state, config, commit commands | smoke | `node bin/qaa-tools.cjs state 2>&1 && node bin/qaa-tools.cjs config-get model_profile 2>&1` | Wave 0 |
| INFRA-02 | Model profiles resolve agent models | unit | `node bin/qaa-tools.cjs resolve-model qaa-executor --raw` | Wave 0 |
| INFRA-03 | Config reads/writes config.json | smoke | `node bin/qaa-tools.cjs config-ensure-section && node bin/qaa-tools.cjs config-get model_profile` | Wave 0 |
| INFRA-04 | State management tracks pipeline | smoke | `node bin/qaa-tools.cjs state json` (after STATE.md exists) | Wave 0 |
| INFRA-05 | Frontmatter parser reads/writes YAML | unit | `node bin/qaa-tools.cjs frontmatter get <test-file>` | Wave 0 |
| INFRA-06 | Atomic commit system | smoke | `node bin/qaa-tools.cjs commit "test" --files .planning/config.json` (in git repo) | Wave 0 |
| INFRA-07 | Init returns workflow context JSON | smoke | `node bin/qaa-tools.cjs init phase-op 1` | Wave 0 |

### Sampling Rate
- **Per task commit:** Run smoke test for the specific module being ported
- **Per wave merge:** Run all smoke tests across all ported modules
- **Phase gate:** All 61 command variants return valid JSON without errors

### Wave 0 Gaps
- [ ] No test infrastructure exists -- tests are manual smoke tests via CLI invocation
- [ ] Consider adding a simple `bin/test-smoke.sh` script that runs each command category

*(Since this is CLI tooling called by agents, not a library, integration testing via actual CLI invocation is the appropriate test strategy)*

## Open Questions

1. **Agent type mapping for GSD roles without direct QAA equivalents**
   - What we know: GSD has 14 agent types, QAA has 7. The mapping for executor/planner/verifier is clear.
   - What's unclear: What QAA agent type should `gsd-roadmapper`, `gsd-research-synthesizer`, `gsd-codebase-mapper`, `gsd-ui-researcher` etc. map to? Some GSD agents have no QAA counterpart.
   - Recommendation: Map all GSD "research/planning" roles to `qaa-planner` or `qaa-analyzer`, all "scanning" roles to `qaa-scanner`, all "checking" roles to `qaa-validator`. The table in Code Examples section provides a reasonable mapping. The planner should finalize this.

2. **QAA pipeline state vs GSD phase state**
   - What we know: CONTEXT.md specifies per-stage tracking (scan/analyze/generate/validate/deliver), each with pending/running/complete/failed status.
   - What's unclear: How this maps to STATE.md body content. GSD uses "Current Phase", "Status", "Current Plan" fields. QAA needs different fields for pipeline stages.
   - Recommendation: Keep the STATE.md infrastructure (field extraction, replacement, frontmatter sync) but add QAA-specific pipeline stage fields in the body template. The `buildStateFrontmatter()` function needs adaptation.

3. **Slash command prefix in templates and scaffolds**
   - What we know: GSD templates reference `/gsd:plan-phase`, `/gsd:discuss-phase`, etc. in scaffold output.
   - What's unclear: Whether QAA uses `/qa:` or `/qaa:` prefix for its slash commands.
   - Recommendation: Use `/qa-` prefix based on REQUIREMENTS.md (UX-01 through UX-04 reference `/qa-start`, `/qa-analyze`, `/qa-validate`, etc.). Template text should reference `/qa-*` commands.

## Sources

### Primary (HIGH confidence)
- GSD source code at `C:/Users/mrrai/.claude/get-shit-done/bin/gsd-tools.cjs` -- complete CLI router, 604 lines
- GSD source code at `C:/Users/mrrai/.claude/get-shit-done/bin/lib/*.cjs` -- all 12 library modules, ~5,900 lines total
- `.planning/phases/01-core-infrastructure/01-CONTEXT.md` -- locked user decisions
- `.planning/REQUIREMENTS.md` -- INFRA-01 through INFRA-07 requirement definitions
- `.planning/ROADMAP.md` -- Phase 1 success criteria

### Secondary (MEDIUM confidence)
- `.claude/skills/*/SKILL.md` -- 6 skill definitions informing agent type mapping

### Tertiary (LOW confidence)
- Agent type model tier assignments (quality/balanced/budget) -- based on GSD patterns and reasoning about QA task complexity. May need tuning based on actual usage.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- zero-dependency Node.js, identical to GSD
- Architecture: HIGH -- direct port of proven GSD patterns, every module read and documented
- Pitfalls: HIGH -- derived from actual code analysis, not hypothetical
- Agent type mapping: MEDIUM -- 7 QAA types are specified, but mapping GSD's 14 roles to 7 QAA roles requires judgment calls

**Research date:** 2026-03-18
**Valid until:** Indefinite -- this is a port of stable source code, not an evolving ecosystem
