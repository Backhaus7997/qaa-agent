# Roadmap: Capmation QA Automation Agent

## Overview

This roadmap delivers a multi-agent QA automation system that any Capmation QA engineer can run locally via Claude Code against a client repo to produce a complete, standards-compliant test suite as a reviewable PR. The build progresses from foundational CLI tooling, through templates and agent implementations, to workflow orchestration and user-facing delivery -- each phase delivering a verifiable capability that enables the next.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Core Infrastructure** - CLI tooling, config system, state management, frontmatter parsing, and init bootstrapping
- [ ] **Phase 2: QA Standards and Templates** - All artifact templates and CLAUDE.md standards that agents reference when producing output
- [ ] **Phase 3: Discovery Agents** - Scanner and analyzer agents that read a repo and produce analysis artifacts
- [ ] **Phase 4: Generation Agents** - Planner, executor, validator, test-ID injector, and bug detective agents that produce and validate test suites
- [ ] **Phase 5: Workflow Orchestration** - Three workflow options, parallel execution, auto-advance pipeline, and checkpoint system
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
- [ ] 01-01-PLAN.md — Foundation modules: model-profiles, core, frontmatter
- [ ] 01-02-PLAN.md — Config and state management modules
- [ ] 01-03-PLAN.md — Mid-tier modules: roadmap, template, milestone
- [ ] 01-04-PLAN.md — Phase CRUD and standalone commands (commit system)
- [ ] 01-05-PLAN.md — Verify suite, init system, and CLI router

### Phase 2: QA Standards and Templates
**Goal**: Every QA artifact the system produces has a defined template with required sections, and all generated output conforms to documented QA standards
**Depends on**: Phase 1
**Requirements**: TMPL-01, TMPL-02, TMPL-03, TMPL-04, TMPL-05, TMPL-06, TMPL-07, TMPL-08, TMPL-09, TMPL-10
**Success Criteria** (what must be TRUE):
  1. Each template file exists with frontmatter metadata, required section headers, and placeholder content that agents can fill
  2. CLAUDE.md contains complete QA standards covering testing pyramid distribution, locator tier hierarchy, POM rules, assertion specificity rules, naming conventions, and quality gates
  3. Templates for analysis (QA_ANALYSIS.md), inventory (TEST_INVENTORY.md), scan manifest (SCAN_MANIFEST.md), and blueprint (QA_REPO_BLUEPRINT.md) each define the exact sections agents must populate
  4. Templates for validation, failure classification, test-ID audit, gap analysis, and QA audit reports each define structured output formats with scoring/classification fields
**Plans**: TBD

Plans:
- [ ] 02-01: TBD
- [ ] 02-02: TBD

### Phase 3: Discovery Agents
**Goal**: QA engineer can point the scanner at any supported repo and get a complete analysis of its architecture, risks, testable surfaces, and prioritized test cases
**Depends on**: Phase 1, Phase 2
**Requirements**: AGENT-01, AGENT-02
**Success Criteria** (what must be TRUE):
  1. Scanner agent reads a repo, detects its framework/stack (Node, Python, .NET, etc.), builds a file tree, and produces a SCAN_MANIFEST.md with testable surfaces identified
  2. Analyzer agent consumes SCAN_MANIFEST.md and produces QA_ANALYSIS.md with architecture overview, risk assessment (HIGH/MEDIUM/LOW), top 10 unit test targets, API targets, and testing pyramid distribution adjusted to the repo
  3. Analyzer agent produces TEST_INVENTORY.md with pyramid-based test cases (unit, integration, API, E2E) where every test case has a unique ID, target, concrete inputs, explicit expected outcome, and priority
  4. Both agents write output conforming to their respective templates from Phase 2
**Plans**: TBD

Plans:
- [ ] 03-01: TBD
- [ ] 03-02: TBD

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
**Plans**: TBD

Plans:
- [ ] 04-01: TBD
- [ ] 04-02: TBD
- [ ] 04-03: TBD

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
**Plans**: TBD

Plans:
- [ ] 05-01: TBD
- [ ] 05-02: TBD
- [ ] 05-03: TBD

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
**Plans**: TBD

Plans:
- [ ] 06-01: TBD
- [ ] 06-02: TBD
- [ ] 06-03: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Core Infrastructure | 0/5 | Not started | - |
| 2. QA Standards and Templates | 0/0 | Not started | - |
| 3. Discovery Agents | 0/0 | Not started | - |
| 4. Generation Agents | 0/0 | Not started | - |
| 5. Workflow Orchestration | 0/0 | Not started | - |
| 6. Delivery and User Experience | 0/0 | Not started | - |
