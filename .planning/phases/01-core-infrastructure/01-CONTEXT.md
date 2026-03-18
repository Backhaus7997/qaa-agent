# Phase 1: Core Infrastructure - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Build the foundational CLI tooling (qaa-tools.cjs) that all agents and workflows depend on. This includes the command router, library modules, config system, state management, frontmatter parser, commit system, init system, and model profiles. No agents or workflows — just the tools they need.

</domain>

<decisions>
## Implementation Decisions

### GSD Mirroring Depth
- Full port of gsd-tools.cjs — copy all 100+ commands, rename gsd→qaa where applicable
- Tool named `qaa-tools.cjs` (QA Automation tools)
- Agent type prefix: `qaa-` (qaa-scanner, qaa-analyzer, qaa-executor, etc.)
- Library files keep same names as GSD (core.cjs, config.cjs, state.cjs, phase.cjs, etc.)
- Located at `bin/qaa-tools.cjs` + `bin/lib/*.cjs` at project root

### Pipeline State Machine
- Per-project state tracking (one QA_STATE.md per project directory, like GSD)
- Full stage tracking — each pipeline stage (scan, analyze, generate, validate, deliver) has its own status (pending/running/complete/failed)
- Can re-run any stage independently
- State persists across multiple runs within same project

### Init Variants
- Mirror all 12+ GSD init variants: init new-project, init plan-phase, init execute-phase, init quick, init resume, etc.
- Full parity with GSD's init system at v1

### Module Library Design
- Port all 12 GSD lib modules as-is: core.cjs, config.cjs, state.cjs, phase.cjs, roadmap.cjs, frontmatter.cjs, template.cjs, milestone.cjs, verify.cjs, commands.cjs, init.cjs, model-profiles.cjs
- Rename internal references from gsd→qaa
- Keep same file structure and API patterns

### Claude's Discretion
- Internal error handling and logging patterns
- Temp file handling for large JSON payloads
- Exact command help text and usage messages

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### GSD Source (reference implementation)
- `C:/Users/mrrai/.claude/get-shit-done/bin/gsd-tools.cjs` — Main CLI router, ~600 lines, command dispatch pattern
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/core.cjs` — Shared utilities: paths, output, phase math (19KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/config.cjs` — Config.json CRUD (9.7KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/state.cjs` — STATE.md operations (31KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/phase.cjs` — Phase discovery, numbering, completion (31KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/roadmap.cjs` — ROADMAP.md parsing (11KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/frontmatter.cjs` — YAML frontmatter parsing/serialization (12KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/template.cjs` — Template filling (7.1KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/milestone.cjs` — Milestone archiving (8.6KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/verify.cjs` — Verification suite (32KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/commands.cjs` — Atomic commands, git integration (24KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/init.cjs` — Workflow initialization (26KB)
- `C:/Users/mrrai/.claude/get-shit-done/bin/lib/model-profiles.cjs` — AI model assignments (3.3KB)

### QA Standards
- `CLAUDE.md` (at project root via qa-agent-gsd/CLAUDE.md) — QA standards that all downstream agents must follow

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- No JavaScript/CJS files exist yet — greenfield build
- 6 SKILL.md files in `.claude/skills/` define agent capabilities (reference for model-profiles agent registry)
- 13 slash commands in `.claude/commands/` define user entry points (reference for init variants)

### Established Patterns
- GSD's pattern: async main() with switch/case router, JSON output (large payloads → tmpfile as `@file:`), lib modules delegating to specialists
- GSD's init pattern: one compound command per workflow that gathers all context into single JSON

### Integration Points
- qaa-tools.cjs will be called from workflow markdown files via `node "bin/qaa-tools.cjs" <command>`
- Config at `.planning/config.json` — same location as GSD
- State at `.planning/STATE.md` — same location as GSD

</code_context>

<specifics>
## Specific Ideas

- Full port from GSD means the researcher/planner should READ the actual GSD source files listed in canonical_refs to understand the exact API and patterns being replicated
- The 7 QA agent types for model-profiles.cjs: qaa-scanner, qaa-analyzer, qaa-planner, qaa-executor, qaa-validator, qaa-testid-injector, qaa-bug-detective

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-core-infrastructure*
*Context gathered: 2026-03-18*
