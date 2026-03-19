# Phase 5: Workflow Orchestration - Context

**Gathered:** 2026-03-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Build the orchestrator workflow that coordinates the full QA pipeline: user provides repo(s) → system detects workflow option → spawns agents in sequence → manages checkpoints → delivers results. Also: init integration, auto-advance chain, and checkpoint/resume system. One orchestrator file with internal routing for all 3 options.

</domain>

<decisions>
## Implementation Decisions

### Auto-Advance Behavior
- Auto-advance enabled via config.json `workflow.auto_advance = true` (persists) or per-run `--auto` flag (override)
- In auto mode: auto-approve safe checkpoints (scanner framework detection, analyzer assumptions), ALWAYS pause for risky checkpoints (validator escalation with unresolved issues)
- On stage failure in auto mode: stop pipeline entirely, report which stage failed and why. No partial PR. User must intervene.
- Full progress banners shown even in auto mode — user sees pipeline flowing in terminal (stage banners, agent spawning indicators, completion messages)

### Pipeline Execution Model
- Strictly sequential stages: scanner → analyzer → [testid-injector if frontend] → planner → executor → validator → [bug-detective if failures] → deliver
- No parallel stages — each waits for the previous. Simpler, more predictable.
- Wave-based parallelism applies within a stage only if the planner creates multiple generation plans (executor runs them in parallel)

### Workflow Option Routing
- QA repo maturity determined by automated scoring (0-100): below 30 = immature (Option 2), above 70 = mature (Option 3)
- Score based on: POM usage, assertion quality, CI/CD integration, fixture management
- Analyzer handles both modes via 'mode' parameter: 'full' (Option 1) or 'gap' (Options 2 & 3) — no separate gap-analyzer agent
- Option 3: executor checks existing test files itself before generating — skips tests that already exist (by test ID)

### Workflow File Structure
- Single orchestrator file: `agents/qa-pipeline-orchestrator.md` with internal routing for all 3 options
- Lives in `agents/` directory alongside agent files (not a separate workflows/ dir)
- Takes 'option' parameter, routes to appropriate stage sequence. Shared stages (scan, validate, deliver) defined once.

### Checkpoint System
- Fresh agent with explicit state for resume (like GSD): spawn new agent with what's done, what's pending, user's response. No serialization.
- Orchestrator is the checkpoint owner — agents return structured checkpoint data, orchestrator presents to user and spawns continuation

### Init System Integration
- Single init variant: `qaa-tools.cjs init qa-start` returns everything — detected option, repo paths, models, state, config
- Orchestrator calls init once at startup, parses JSON, routes based on option

### State Tracking
- Orchestrator owns all QA_STATE.md pipeline stage updates
- Sets stage to 'running' before spawning agent, 'complete' or 'failed' after agent returns
- Agents do NOT update pipeline state themselves — only the orchestrator
- State updates via `qaa-tools.cjs state` commands

### Claude's Discretion
- Exact maturity scoring algorithm weights
- How orchestrator passes option parameter to agents
- Internal routing logic structure within the orchestrator .md
- How to handle edge case: user provides 2 repos but QA repo is empty (score = 0)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing Agents (orchestrator spawns these)
- `agents/qaa-scanner.md` — Scanner agent (422 lines, 7 steps)
- `agents/qaa-analyzer.md` — Analyzer agent (508 lines, 7 steps, mode parameter)
- `agents/qaa-planner.md` — Planner agent (374 lines, 7 steps)
- `agents/qaa-executor.md` — Executor agent (618 lines, 5 steps)
- `agents/qaa-validator.md` — Validator agent (450 lines, 8 steps)
- `agents/qaa-bug-detective.md` — Bug detective (444 lines, 8 steps)
- `agents/qaa-testid-injector.md` — Testid injector (583 lines, 8 steps)

### Infrastructure
- `bin/qaa-tools.cjs` — CLI with init, state, commit commands
- `bin/lib/init.cjs` — Init system (12 variants, needs qa-start variant)
- `bin/lib/state.cjs` — State management with pipeline stage tracking
- `bin/lib/model-profiles.cjs` — Agent model resolution

### GSD Orchestration Patterns (reference)
- `C:/Users/mrrai/.claude/get-shit-done/workflows/execute-phase.md` — GSD's wave-based execution orchestrator
- `C:/Users/mrrai/.claude/get-shit-done/references/checkpoints.md` — Checkpoint handling patterns

### Standards
- `CLAUDE.md` — Agent pipeline rules, module boundaries, agent coordination
- `templates/gap-analysis.md` — Gap analysis output format (Options 2 & 3)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- 7 agent .md files ready to be spawned (total 3,399 lines)
- `bin/lib/init.cjs` has 12 init variants — needs `cmdInitQaStart` added
- `bin/lib/state.cjs` has `buildStateFrontmatter` with pipeline stages (scan/analyze/generate/validate/deliver)
- qaa-tools.cjs routes all commands — `init qa-start` just needs a new case

### Established Patterns
- GSD's execute-phase.md: init → discover plans → group waves → spawn agents → spot-check → aggregate → verify
- Checkpoint pattern: agent returns structured state, orchestrator presents, spawns fresh continuation agent
- Auto-advance: config flag + per-run flag, chain flag in config._auto_chain_active

### Integration Points
- Orchestrator calls `qaa-tools.cjs init qa-start` at startup
- Orchestrator calls `qaa-tools.cjs state update` before/after each stage
- Orchestrator calls `qaa-tools.cjs commit` after successful pipeline
- Slash commands (/qa-start) invoke this orchestrator

</code_context>

<specifics>
## Specific Ideas

- The maturity scoring should check: does POM exist (BasePage?), are assertions concrete (not toBeTruthy), does CI/CD exist, are fixtures separated, is naming consistent
- The orchestrator should print a pipeline summary at the end: stages completed, artifacts produced, time taken
- For Option 2 "fix broken tests": the executor in gap mode should attempt to fix imports, selectors, and config issues before adding new tests

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-workflow-orchestration*
*Context gathered: 2026-03-19*
