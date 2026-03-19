# QA Automation Agent

## What This Is

A multi-agent QA automation system built by cloning GSD's proven architecture (CLI tooling, markdown workflows, parallel agent spawning, state tracking) and specializing it for QA tasks: repository analysis, test generation, test ID injection, validation, and PR delivery. Each QA engineer runs it locally via Claude Code against any client repo.

## Core Value

Any QA engineer can point the agent at a client repo and get a complete, standards-compliant test suite — analysis, test cases, page objects, validation — committed as a reviewable PR, without needing to understand the agent's internals.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] CLI tooling (qa-tools.cjs) with init, state, config, commit commands
- [ ] Agent type registry with model profiles (qa-scanner, qa-analyzer, qa-planner, qa-executor, qa-validator, qa-testid-injector, qa-bug-detective)
- [ ] Workflow orchestration for 3 options (dev-only, dev+immature-QA, dev+mature-QA)
- [ ] State management via QA_STATE.md (scan → analyze → generate → validate → deliver)
- [ ] Repository scanning workflow (builds file tree, detects framework/stack, maps testable surfaces)
- [ ] Analysis workflow (produces QA_ANALYSIS.md + TEST_INVENTORY.md)
- [ ] Test ID injection workflow (scan → audit → inject → validate data-testid attributes)
- [ ] Test generation workflow (POM architecture, Tier 1 locators, concrete assertions)
- [ ] Validation loop (4 layers: syntax, structure, dependencies, logic — max 3 fix loops)
- [ ] Bug detective workflow (classify failures: APP BUG / TEST ERROR / ENV ISSUE / INCONCLUSIVE)
- [ ] Gap analysis workflow (compare DEV repo vs existing QA repo)
- [ ] Blueprint generation (QA_REPO_BLUEPRINT.md for repos without QA)
- [ ] PR delivery (branch creation, atomic commits, gh pr create)
- [ ] Templates for all QA artifacts (analysis, inventory, blueprint, audit, gap, validation, classification reports)
- [ ] CLAUDE.md with full QA standards (pyramid, locators, POM, assertions, naming)
- [ ] Slash commands as user entry points (/qa-start, /qa-analyze, /qa-validate, etc.)

### Out of Scope

- External frameworks (no Ruflo, no Claude Flow, no LangGraph) — Claude Code native only
- Cloud deployment — local only, each engineer runs from their terminal
- Real-time collaboration — one agent per engineer per run
- Test execution against live environments — agent generates and validates code, not runtime behavior
- Custom UI/dashboard — all interaction via Claude Code terminal

## Context

- **Team**: QA engineers
- **Goal**: AI-powered QA process that can be iterated, repeated, and standardized
- **Architecture model**: Cloned from GSD (get-shit-done) v1.25.1 — proven multi-agent orchestration with ~22,000 LOC across CLI tooling, workflows, templates, and references
- **Agent Teams**: Claude Code experimental feature enabled (CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1, requires Opus 4.6)
- **Existing work**: 6 SKILL.md files, 11 slash commands, 3 spec files, CLAUDE.md with QA standards — all created but need integration into the cloned architecture
- **Sample test repos**: ShopFlow (Node/Express), TaskHive (Python/FastAPI), MedPortal (.NET 8) — open source repos for testing each workflow option

## Constraints

- **Platform**: Claude Code local only — no external orchestration frameworks
- **Model requirement**: Opus 4.6 for Agent Teams, Sonnet for most subagents
- **Git dependency**: gh CLI must be installed and authenticated for PR creation
- **Architecture**: Must mirror GSD's patterns — init system, frontmatter metadata, files-as-state, markdown workflows, atomic commits
- **Standards**: All generated QA artifacts must comply with CLAUDE.md (testing pyramid, locator tiers, POM rules, assertion specificity)
- **Language**: All code and documentation in English

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Clone GSD architecture rather than build from scratch | Proven system with ~22K LOC, handles multi-agent orchestration, state management, parallel execution | — Pending |
| qa-tools.cjs as central CLI | Single entry point for all operations, same pattern as gsd-tools.cjs | — Pending |
| 7 agent types (scanner, analyzer, planner, executor, validator, testid-injector, bug-detective) | Maps to QA pipeline stages, each gets fresh 200k context | — Pending |
| 3 workflow options based on repo maturity | Covers all client scenarios: no QA, immature QA, mature QA | — Pending |
| Frontmatter in all artifacts | Machine-readable metadata for state tracking, same as GSD | — Pending |
| PR as final deliverable | Team reviews agent output before merging — human approval gate | — Pending |

---
*Last updated: 2026-03-18 after initialization*
