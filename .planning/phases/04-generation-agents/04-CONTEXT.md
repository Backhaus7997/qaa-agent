# Phase 4: Generation Agents - Context

**Gathered:** 2026-03-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Build 5 generation/validation agents: qaa-planner (creates test generation plans from TEST_INVENTORY), qaa-executor (writes actual test files), qaa-validator (4-layer validation with fix loop), qaa-testid-injector (injects data-testid into DEV repo), qaa-bug-detective (runs tests and classifies failures). Same format as Phase 3 agents: markdown workflow files in `agents/`.

</domain>

<decisions>
## Implementation Decisions

### Validation Fix Loop (qaa-validator)
- Validator self-fixes issues (does not send back to executor)
- 4 layers run sequentially, fail-fast: Layer 1 (syntax) → Layer 2 (structure) → Layer 3 (dependencies) → Layer 4 (logic). Fix Layer 1 before checking Layer 2.
- Max 3 fix loops. After 3 loops with unresolved issues: escalate to user (interactive checkpoint showing remaining issues, user decides to fix manually or accept)
- Scope: generated files only (listed in generation plan), NOT pre-existing test files
- Layer 4 includes cross-check: scan existing test files for duplicate IDs and overlapping selectors to prevent collisions
- Fix confidence levels: HIGH (auto-apply: import paths, syntax), MEDIUM (flag for review: assertion values), LOW (flag for review: logic restructure). Only HIGH fixes applied automatically.
- VALIDATION_REPORT.md includes full fix history: each loop logged with issue found, fix attempted, result
- Validator does NOT commit fixes — leaves them in working tree for orchestrator to commit once validation passes

### Planner Agent (qaa-planner)
- Groups test files by feature (auth tests together: unit+API+E2E), not by pyramid level
- Creates generation plan with task breakdown, dependencies between tasks, file assignments
- Reads TEST_INVENTORY.md as input, produces plan files that qaa-executor consumes

### Executor Agent (qaa-executor)
- One test file per commit: 'test(auth): add login.e2e.spec.ts'. Maximum traceability.
- Creates BasePage.ts only if missing — extends existing if found. Respects existing QA repo structure.
- Writes actual test files following CLAUDE.md standards (Tier 1 locators, POM rules, concrete assertions)

### Test-ID Injection (qaa-testid-injector)
- Injects on a separate branch: `qa/testid-inject-{date}`. Working copy stays clean. User merges if approved.
- Default: inject P0 elements only (buttons, inputs, forms, links, modals). P1-P2 offered as optional follow-up.
- Audit-first workflow: Phase 1 produces TESTID_AUDIT_REPORT with proposed values → user reviews → Phase 2 injects only approved items
- Existing data-testid values: preserved as-is. Non-compliant existing IDs reported in audit with offer to rename (user decides per ID).

### Bug Detective (qaa-bug-detective)
- Never touches application code. Only modifies test files. Application bugs are always report-only.
- Actually runs the test suite (not static analysis). Captures real output, classifies real failures. Requires test environment.
- Classification: APP BUG / TEST CODE ERROR / ENV ISSUE / INCONCLUSIVE with evidence and confidence levels

### Claude's Discretion
- Internal prompt structure within each agent .md
- How planner determines task dependencies
- How executor handles framework-specific config generation
- Bug detective's exact test runner detection logic

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing Agent Files (follow same format)
- `agents/qaa-scanner.md` — Reference for agent .md structure (422 lines, 7 steps, quality gate pattern)
- `agents/qaa-analyzer.md` — Reference for checkpoint pattern and template referencing (508 lines)

### Templates (agents must reference these for output format)
- `templates/validation-report.md` — Validator output format
- `templates/failure-classification.md` — Bug detective output format
- `templates/testid-audit-report.md` — Testid-injector output format
- `templates/qa-repo-blueprint.md` — For planner reference (optional blueprint)

### Skills (define agent capabilities)
- `.claude/skills/qa-self-validator/SKILL.md` — Validator execution steps and layers
- `.claude/skills/qa-bug-detective/SKILL.md` — Classification decision tree
- `.claude/skills/qa-testid-injector/SKILL.md` — Injection phases and naming convention
- `.claude/skills/qa-template-engine/SKILL.md` — Executor test generation patterns

### Standards
- `CLAUDE.md` — Module boundaries, POM rules, locator tiers, assertion rules, naming conventions
- `data-testid-SKILL.md` — Full naming convention for testid-injector

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `agents/qaa-scanner.md` and `agents/qaa-analyzer.md` — Proven agent .md format to replicate (purpose, required_reading, process with steps, output, quality_gate, success_criteria)
- `bin/lib/model-profiles.cjs` — Has all 7 qaa- agent types with model mappings
- `bin/qaa-tools.cjs` — CLI for commits, state, templates
- 9 templates in `templates/` — Define output format for all artifacts

### Established Patterns
- Agent .md uses XML tags: `<purpose>`, `<required_reading>`, `<process>`, `<step name="...">`, `<output>`, `<quality_gate>`, `<success_criteria>`
- Checkpoint returns use `CHECKPOINT_RETURN` structured format
- File-based handoff via `<files_to_read>` blocks

### Integration Points
- Planner reads TEST_INVENTORY.md (from qaa-analyzer) → produces generation plan
- Executor reads generation plan → writes test files → validator reads test files
- Testid-injector reads SCAN_MANIFEST.md has_frontend flag → injects data-testid
- Bug detective reads test files + runs them → produces FAILURE_CLASSIFICATION_REPORT

</code_context>

<specifics>
## Specific Ideas

- All 5 agents follow the exact same .md structure as qaa-scanner.md and qaa-analyzer.md
- Validator's fix loop should log each attempt clearly so the VALIDATION_REPORT history section is useful for debugging
- Testid-injector's branch approach means it needs to `git checkout -b qa/testid-inject-{date}` before modifying files
- Bug detective should detect the test runner from package.json/pyproject.toml before attempting to run tests

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 04-generation-agents*
*Context gathered: 2026-03-19*
