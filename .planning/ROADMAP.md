# Roadmap: QA Automation Agent

## Overview

This roadmap delivers a multi-agent QA automation system that any QA engineer can run locally via Claude Code against a client repo to produce a complete, standards-compliant test suite as a reviewable PR. The build progresses from foundational CLI tooling, through templates and agent implementations, to workflow orchestration and user-facing delivery -- each phase delivering a verifiable capability that enables the next.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Core Infrastructure** - CLI tooling, config system, state management, frontmatter parsing, and init bootstrapping
- [ ] **Phase 2: QA Standards and Templates** - All artifact templates and CLAUDE.md standards that agents reference when producing output
- [ ] **Phase 3: Discovery Agents** - Scanner and analyzer agents that read a repo and produce analysis artifacts
- [ ] **Phase 4: Generation Agents** - Planner, executor, validator, test-ID injector, and bug detective agents that produce and validate test suites
- [x] **Phase 5: Workflow Orchestration** - Three workflow options, parallel execution, auto-advance pipeline, and checkpoint system
- [ ] **Phase 6: Delivery and User Experience** - Branch/PR creation, slash commands, and documentation for end-to-end usage

## Phase Details

### Phase 1: Core Infrastructure
**Goal**: QA engineer can initialize a project, manage configuration, track pipeline state, and commit artifacts through a single CLI entry point
**Depends on**: Nothing (first phase)
**Requirements**: INFRA-01, INFRA-02, INFRA-03, INFRA-04, INFRA-05, INFRA-06, INFRA-07
**Success Criteria** (what must be TRUE):
  1. Running `qa-tools.cjs init` returns JSON with all workflow context (models, paths, flags, state)
  2. Running `qa-tools.cjs config` reads and writes .planning/config.json with mode, granularity, parallelization, and workflow flags
  3. Running `qa-tools.cjs state` creates QA_STATE.md and tracks pipeline progression through scan, analyze, generate, validate, deliver stages
  4. Running `qa-tools.cjs commit` stages specific files and commits with descriptive messages without staging unrelated changes
  5. Frontmatter parser correctly reads and writes YAML frontmatter blocks in markdown files
**Plans**: 5 plans

Plans:
- [x] 01-01-PLAN.md — Foundation modules: model-profiles, core, frontmatter
- [x] 01-02-PLAN.md — Config and state management modules
- [x] 01-03-PLAN.md — Mid-tier modules: roadmap, template, milestone
- [x] 01-04-PLAN.md — Phase CRUD and standalone commands (commit system)
- [x] 01-05-PLAN.md — Verify suite, init system, and CLI router

### Phase 2: QA Standards and Templates
**Goal**: Every QA artifact the system produces has a defined template with required sections, and all generated output conforms to documented QA standards
**Depends on**: Phase 1
**Requirements**: TMPL-01, TMPL-02, TMPL-03, TMPL-04, TMPL-05, TMPL-06, TMPL-07, TMPL-08, TMPL-09, TMPL-10
**Success Criteria** (what must be TRUE):
  1. Each template file exists with frontmatter metadata, required section headers, and placeholder content that agents can fill
  2. CLAUDE.md contains complete QA standards covering testing pyramid distribution, locator tier hierarchy, POM rules, assertion specificity rules, naming conventions, and quality gates
  3. Templates for analysis (QA_ANALYSIS.md), inventory (TEST_INVENTORY.md), scan manifest (SCAN_MANIFEST.md), and blueprint (QA_REPO_BLUEPRINT.md) each define the exact sections agents must populate
  4. Templates for validation, failure classification, test-ID audit, gap analysis, and QA audit reports each define structured output formats with scoring/classification fields
**Plans**: 4 plans

Plans:
- [x] 02-01-PLAN.md — Analysis-pipeline templates: SCAN_MANIFEST, QA_ANALYSIS, TEST_INVENTORY
- [x] 02-02-PLAN.md — Blueprint and validation templates: QA_REPO_BLUEPRINT, VALIDATION_REPORT, FAILURE_CLASSIFICATION
- [x] 02-03-PLAN.md — Audit and gap templates: TESTID_AUDIT_REPORT, GAP_ANALYSIS, QA_AUDIT_REPORT
- [x] 02-04-PLAN.md — Enhanced CLAUDE.md with QA standards and agent coordination rules

### Phase 3: Discovery Agents
**Goal**: QA engineer can point the scanner at any supported repo and get a complete analysis of its architecture, risks, testable surfaces, and prioritized test cases
**Depends on**: Phase 1, Phase 2
**Requirements**: AGENT-01, AGENT-02
**Success Criteria** (what must be TRUE):
  1. Scanner agent reads a repo, detects its framework/stack (Node, Python, .NET, etc.), builds a file tree, and produces a SCAN_MANIFEST.md with testable surfaces identified
  2. Analyzer agent consumes SCAN_MANIFEST.md and produces QA_ANALYSIS.md with architecture overview, risk assessment (HIGH/MEDIUM/LOW), top 10 unit test targets, API targets, and testing pyramid distribution adjusted to the repo
  3. Analyzer agent produces TEST_INVENTORY.md with pyramid-based test cases (unit, integration, API, E2E) where every test case has a unique ID, target, concrete inputs, explicit expected outcome, and priority
  4. Both agents write output conforming to their respective templates from Phase 2
**Plans**: 2 plans

Plans:
- [ ] 03-01-PLAN.md — Scanner agent workflow: repo scanning, framework detection, SCAN_MANIFEST.md production
- [ ] 03-02-PLAN.md — Analyzer agent workflow: QA_ANALYSIS.md, TEST_INVENTORY.md, and optional QA_REPO_BLUEPRINT.md production

### Phase 4: Generation Agents
**Goal**: QA engineer gets a validated, standards-compliant test suite generated from analysis, with test IDs injected into frontend code and failures classified with evidence
**Depends on**: Phase 3
**Requirements**: AGENT-03, AGENT-04, AGENT-05, AGENT-06, AGENT-07
**Success Criteria** (what must be TRUE):
  1. Planner agent reads TEST_INVENTORY.md and produces a generation plan with task breakdown, dependencies between tasks, and file assignments for each test file to be created
  2. Executor agent writes actual test files (page objects, specs, fixtures, configs) following CLAUDE.md standards: Tier 1 locators, POM rules (no assertions in page objects), concrete assertion values, correct naming conventions
  3. Validator agent runs 4-layer validation (syntax, structure, dependencies, logic) on generated test files and performs up to 3 fix loops to resolve issues, producing a VALIDATION_REPORT.md with pass/fail per file per layer
  4. Test-ID injector agent scans frontend source code, audits missing data-testid attributes, injects them following naming conventions, and produces TESTID_AUDIT_REPORT.md with coverage score
  5. Bug detective agent classifies test failures as APP BUG, TEST ERROR, ENV ISSUE, or INCONCLUSIVE with supporting evidence and confidence levels in FAILURE_CLASSIFICATION_REPORT.md
**Plans**: 3 plans

Plans:
- [ ] 04-01-PLAN.md — Planner and executor agent workflows: generation plan creation and test file writing
- [ ] 04-02-PLAN.md — Validator and bug detective agent workflows: 4-layer validation and failure classification
- [ ] 04-03-PLAN.md — Test-ID injector agent workflow: audit, injection, and validation on separate branch

### Phase 5: Workflow Orchestration
**Goal**: QA engineer selects a workflow option matching their repo situation and the system executes the correct agent pipeline automatically, with parallel execution and human checkpoints where needed
**Depends on**: Phase 4
**Requirements**: FLOW-01, FLOW-02, FLOW-03, FLOW-04, FLOW-05, FLOW-06, FLOW-07
**Success Criteria** (what must be TRUE):
  1. Option 1 workflow (dev-only repo) runs the full pipeline: scan, analyze, testid-inject (if frontend), plan, generate, validate, deliver -- producing a complete test suite from scratch
  2. Option 2 workflow (dev + immature QA repo) scans both repos, performs gap analysis, fixes broken tests, adds missing coverage, standardizes existing tests, validates, and delivers
  3. Option 3 workflow (dev + mature QA repo) scans both repos, identifies thin coverage areas, adds only missing tests, validates, and delivers without modifying working tests
  4. Independent agents within a pipeline stage execute in parallel (wave-based), and the init command bootstraps all workflow context in a single call
  5. Auto-advance chain runs the full pipeline without manual interaction, and checkpoint system can pause for human decisions and resume with full context preserved
**Plans**: 2 plans

Plans:
- [x] 05-01-PLAN.md — Init qa-start function and CLI integration for workflow bootstrapping
- [x] 05-02-PLAN.md — QA pipeline orchestrator with 3 workflow options, auto-advance, and checkpoint system

### Phase 6: Delivery and User Experience
**Goal**: QA engineer runs a single slash command, the system executes the appropriate workflow, and delivers the result as a PR ready for team review
**Depends on**: Phase 5
**Requirements**: DLVR-01, DLVR-02, DLVR-03, DLVR-04, UX-01, UX-02, UX-03, UX-04, UX-05
**Success Criteria** (what must be TRUE):
  1. /qa-start slash command detects repo count (1 or 2), selects the correct workflow, and orchestrates the full pipeline end to end
  2. Agent creates a feature branch (qa/auto-{project}-{date}), commits all artifacts atomically with descriptive messages, pushes, and creates a PR via gh CLI
  3. PR description includes analysis summary, test counts by pyramid level, coverage metrics, and validation pass/fail status
  4. /qa-analyze runs analysis-only (no generation, no PR), /qa-validate validates existing tests and classifies failures, and additional slash commands (/qa-testid, /qa-fix, /qa-pom, /qa-audit, /qa-gap, /qa-blueprint, /qa-report, /qa-pyramid) each perform their focused task
  5. README.md explains installation, configuration, workflow options, and usage so any QA engineer can start using the system without assistance
**Plans**: 3 plans

Plans:
- [x] 06-01-PLAN.md — Deliver stage implementation in orchestrator + PR template
- [x] 06-02-PLAN.md — Rewrite all 13 slash commands to invoke real agent pipeline
- [ ] 06-03-PLAN.md — README.md with installation, commands, workflow options, and troubleshooting

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Core Infrastructure | 5/5 | Complete | 2026-03-18 |
| 2. QA Standards and Templates | 4/4 | Complete | 2026-03-18 |
| 3. Discovery Agents | 2/2 | Complete | 2026-03-19 |
| 4. Generation Agents | 2/3 | In Progress | - |
| 5. Workflow Orchestration | 2/2 | Complete | 2026-03-19 |
| 6. Delivery and User Experience | 2/3 | In Progress | - |
