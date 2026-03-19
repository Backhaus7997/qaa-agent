# Phase 3: Discovery Agents - Context

**Gathered:** 2026-03-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Build the two discovery agents: qaa-scanner (reads a DEV repo, produces SCAN_MANIFEST.md) and qaa-analyzer (consumes SCAN_MANIFEST, produces QA_ANALYSIS.md + TEST_INVENTORY.md). These are markdown workflow files in `agents/` that get spawned via Task() with subagent_type. No generation, validation, or delivery — just read and analyze.

</domain>

<decisions>
## Implementation Decisions

### Agent Format
- Markdown workflow files in `agents/` directory at project root (not workflows/)
- Each agent .md follows GSD pattern: `<purpose>`, `<process>` with numbered steps, `<files_to_read>`, `<output>`, `<quality_gate>` checklist
- Spawned via Task(subagent_type='qaa-scanner', model='{scanner_model}') — same as GSD
- model-profiles.cjs (from Phase 1) resolves the model for each agent type
- Orchestrator passes agent .md via @path reference in Task prompt

### Scanner Scope
- Deep scan: file tree + package detection + read source files to map entry points, API endpoints, models/schemas, services, middleware, external integrations
- Produces rich SCAN_MANIFEST.md that analyzer can work from without re-reading source
- Supports all common stacks: Node.js/Express, Python/FastAPI, .NET/ASP.NET, Java/Spring, Go, Ruby/Rails, PHP/Laravel, React/Next.js, Vue/Nuxt, Angular
- Scanner handles DEV repo only — QA repo analysis is a separate concern (gap-analyzer in later phases)
- Scanner detects frontend components: framework (React/Vue/Angular), component files, interactive elements count, flags `has_frontend: true/false` for orchestrator to decide whether to spawn testid-injector
- If framework can't be detected or no testable surfaces found: report + ask user (interactive checkpoint before analyzer runs)

### Analyzer Output Quality
- Full spec detail for every test case: ID, target (file:function or METHOD /endpoint), concrete inputs (actual values), explicit expected outcome (exact status/value), priority, mocks needed
- Matches the TEST_INVENTORY.md template format from Phase 2
- Test count is pyramid-driven: depends on repo size/complexity, follows pyramid distribution (60-70% unit, 20-25% API, 10-15% integration, 3-5% E2E)
- Analyzer produces interactive "Assumptions + Questions" checkpoint before generating full analysis — catches misunderstandings early

### Agent-to-Agent Handoff
- File-based: scanner writes SCAN_MANIFEST.md to known path, orchestrator passes path to analyzer via `<files_to_read>`
- Same pattern as GSD: files as state, fresh 200k context per agent
- No content passing through orchestrator — keeps orchestrator lean

### Error Handling
- Scanner: if framework unknown or no testable surfaces, pause and ask user for info (interactive checkpoint)
- Analyzer: if SCAN_MANIFEST is incomplete, note gaps in QA_ANALYSIS.md assumptions section

### Claude's Discretion
- Exact file reading strategy within scanner (breadth-first vs depth-first)
- How to handle monorepos (multiple packages)
- Internal prompt engineering within agent .md files

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Templates (agents MUST produce output matching these)
- `templates/scan-manifest.md` — Scanner output format (312 lines, 5 sections)
- `templates/qa-analysis.md` — Analyzer testability report format (381 lines, 6 sections)
- `templates/test-inventory.md` — Analyzer test case inventory format (582 lines, 4 pyramid tiers)

### Standards
- `CLAUDE.md` — Module boundaries (scanner → SCAN_MANIFEST, analyzer → QA_ANALYSIS + TEST_INVENTORY), agent coordination rules, QA standards

### Skills (define agent capabilities)
- `.claude/skills/qa-repo-analyzer/SKILL.md` — Defines analyzer execution steps and quality gates
- `.claude/skills/qa-testid-injector/SKILL.md` — Scanner must detect frontend for testid-injector triggering

### GSD Agent Patterns (reference for workflow .md structure)
- `C:/Users/mrrai/.claude/get-shit-done/workflows/execute-plan.md` — Example of GSD workflow structure: purpose, process, files_to_read, output, quality_gate

### Infrastructure (agents use these)
- `bin/lib/model-profiles.cjs` — Resolves qaa-scanner and qaa-analyzer model assignments
- `bin/qaa-tools.cjs` — CLI that agents call for commits, state updates, template operations

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `bin/lib/model-profiles.cjs` — Already has qaa-scanner and qaa-analyzer in MODEL_PROFILES with quality/balanced/budget mappings
- `bin/qaa-tools.cjs` — CLI router ready for agents to call (commit, state, template commands)
- 9 templates in `templates/` — Define exact output format for all QA artifacts
- `CLAUDE.md` — 543 lines of standards + agent coordination rules

### Established Patterns
- GSD: orchestrator spawns agent via Task(), agent reads its workflow .md, reads files_to_read, produces artifacts, returns status
- GSD: each agent gets fresh 200k context, reads files themselves (not passed by orchestrator)
- Phase 1 established: qaa- prefix, bin/ location, lib module pattern

### Integration Points
- Scanner writes SCAN_MANIFEST.md → analyzer reads it
- Orchestrator (future Phase 5 workflow) spawns scanner, waits, then spawns analyzer
- Scanner's `has_frontend` flag → orchestrator decides whether to spawn testid-injector (Phase 4)
- Analyzer's TEST_INVENTORY.md → planner agent (Phase 4) creates generation plans from it

</code_context>

<specifics>
## Specific Ideas

- Scanner should produce a "confidence score" for framework detection (HIGH/MEDIUM/LOW) so the orchestrator knows whether to pause for user confirmation
- Analyzer's "Assumptions + Questions" checkpoint should list 3-8 assumptions with evidence from the code, and 0-3 questions that genuinely affect analysis quality
- Both agents should follow the CLAUDE.md "read-before-write" rule: read the template, read CLAUDE.md standards, THEN produce output

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-discovery-agents*
*Context gathered: 2026-03-19*
