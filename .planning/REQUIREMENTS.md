# Requirements: Capmation QA Automation Agent

**Defined:** 2026-03-18
**Core Value:** Any QA engineer can point the agent at a client repo and get a complete, standards-compliant test suite as a reviewable PR.

## v1 Requirements

### Core Infrastructure

- [x] **INFRA-01**: qa-tools.cjs CLI accepts init, state, config, commit commands with JSON output
- [x] **INFRA-02**: Model profiles system resolves agent-specific models from quality/balanced/budget/inherit profiles
- [x] **INFRA-03**: Config system reads/writes .planning/config.json with mode, granularity, parallelization, workflow flags
- [x] **INFRA-04**: State management creates and updates QA_STATE.md tracking scan→analyze→generate→validate→deliver pipeline
- [x] **INFRA-05**: Frontmatter parser reads/writes YAML frontmatter in all QA artifacts
- [x] **INFRA-06**: Atomic commit system stages specific files and commits with descriptive messages
- [x] **INFRA-07**: Init system returns all workflow context as single JSON (models, paths, flags, state)

### Agent Types

- [x] **AGENT-01**: qa-scanner agent reads repo, builds file tree, detects framework/stack, produces SCAN_MANIFEST.md
- [x] **AGENT-02**: qa-analyzer agent produces QA_ANALYSIS.md (architecture, risks, top 10 targets, pyramid) and TEST_INVENTORY.md (pyramid-based test cases with IDs and explicit outcomes)
- [ ] **AGENT-03**: qa-planner agent creates test generation plans with task breakdown, dependencies, and file assignments
- [ ] **AGENT-04**: qa-executor agent writes actual test files (POM, specs, fixtures, config) following CLAUDE.md standards
- [ ] **AGENT-05**: qa-validator agent runs 4-layer validation (syntax, structure, dependencies, logic) with max 3 fix loops
- [x] **AGENT-06**: qa-testid-injector agent scans frontend code, audits missing data-testid, injects following naming convention
- [ ] **AGENT-07**: qa-bug-detective agent classifies test failures as APP BUG / TEST ERROR / ENV ISSUE / INCONCLUSIVE with evidence

### Workflows

- [ ] **FLOW-01**: Option 1 workflow (dev-only): scan → analyze → [testid-inject if frontend] → plan → generate → validate → deliver
- [ ] **FLOW-02**: Option 2 workflow (dev + immature QA): scan both → gap analysis → fix broken → add missing → standardize → validate → deliver
- [ ] **FLOW-03**: Option 3 workflow (dev + mature QA): scan both → identify thin coverage → add only missing → validate → deliver
- [ ] **FLOW-04**: Wave-based parallel execution spawns independent agents simultaneously
- [ ] **FLOW-05**: Init system bootstraps workflow context in single command (qa-tools.cjs init <workflow>)
- [ ] **FLOW-06**: Auto-advance chain runs full pipeline (scan→analyze→generate→validate→deliver) without interaction
- [ ] **FLOW-07**: Checkpoint system pauses execution for human decisions and resumes with context

### Templates

- [x] **TMPL-01**: QA_ANALYSIS.md template (architecture overview, risks, unit test targets, API targets, pyramid distribution)
- [x] **TMPL-02**: TEST_INVENTORY.md template (pyramid-based test cases: unit → integration → API → E2E, each with ID/target/inputs/outcome/priority)
- [x] **TMPL-03**: QA_REPO_BLUEPRINT.md template (repo name, folder structure, stack, configs, CI/CD, Definition of Done)
- [x] **TMPL-04**: VALIDATION_REPORT.md template (pass/fail per file per layer, confidence level)
- [x] **TMPL-05**: SCAN_MANIFEST.md template (file tree, framework detection, testable surfaces)
- [x] **TMPL-06**: FAILURE_CLASSIFICATION_REPORT.md template (classification table, evidence, confidence levels)
- [x] **TMPL-07**: TESTID_AUDIT_REPORT.md template (coverage score, missing elements, proposed values by priority)
- [x] **TMPL-08**: GAP_ANALYSIS.md template (coverage map, missing tests prioritized, broken tests)
- [x] **TMPL-09**: QA_AUDIT_REPORT.md template (6-dimension scoring, critical issues, recommendations)
- [x] **TMPL-10**: CLAUDE.md with complete QA standards (pyramid, locators, POM, assertions, naming, quality gates)

### Delivery

- [ ] **DLVR-01**: Agent creates feature branch following naming convention qa/auto-{project}-{date}
- [ ] **DLVR-02**: Agent commits all artifacts atomically with descriptive messages
- [ ] **DLVR-03**: Agent pushes branch and creates PR via gh CLI with summary template
- [ ] **DLVR-04**: PR template includes analysis summary, test counts, coverage metrics, validation status

### User Experience

- [ ] **UX-01**: /qa-start slash command orchestrates full pipeline based on repo count (1 or 2)
- [ ] **UX-02**: /qa-analyze slash command runs analysis-only (no test generation, no PR)
- [ ] **UX-03**: /qa-validate slash command validates existing test files and classifies failures
- [ ] **UX-04**: Additional slash commands for focused tasks (/qa-testid, /qa-fix, /qa-pom, /qa-audit, /qa-gap, /qa-blueprint, /qa-report, /qa-pyramid)
- [ ] **UX-05**: README.md explains installation, configuration, and usage for any QA engineer

## v2 Requirements

### Advanced Workflows

- **ADV-01**: Multi-repo orchestration (analyze multiple client repos in batch)
- **ADV-02**: Historical tracking (compare QA quality across runs)
- **ADV-03**: Custom rule profiles (per-client QA standard overrides)

### Integration

- **INT-01**: CI/CD pipeline templates (GitHub Actions, Azure Pipelines, GitLab CI)
- **INT-02**: Slack/Teams notifications on PR creation
- **INT-03**: Coverage reporting integration (Allure, HTML Reporter)

### Performance

- **PERF-01**: Incremental analysis (only re-analyze changed files)
- **PERF-02**: Cached scan manifests (skip full scan on re-run)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Cloud deployment | Local-only by design -- each engineer runs from terminal |
| External frameworks (LangGraph, Ruflo) | Claude Code native -- no external dependencies |
| Test execution against live environments | Agent generates code, doesn't run against prod |
| Real-time collaboration | One agent per engineer per run |
| Custom UI/dashboard | Terminal interaction via Claude Code only |
| Auto-merging PRs | Human review gate is intentional |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| INFRA-01 | Phase 1 | Complete |
| INFRA-02 | Phase 1 | Complete |
| INFRA-03 | Phase 1 | Complete |
| INFRA-04 | Phase 1 | Complete |
| INFRA-05 | Phase 1 | Complete |
| INFRA-06 | Phase 1 | Complete |
| INFRA-07 | Phase 1 | Complete |
| TMPL-01 | Phase 2 | Complete |
| TMPL-02 | Phase 2 | Complete |
| TMPL-03 | Phase 2 | Complete |
| TMPL-04 | Phase 2 | Complete |
| TMPL-05 | Phase 2 | Complete |
| TMPL-06 | Phase 2 | Complete |
| TMPL-07 | Phase 2 | Complete |
| TMPL-08 | Phase 2 | Complete |
| TMPL-09 | Phase 2 | Complete |
| TMPL-10 | Phase 2 | Pending |
| AGENT-01 | Phase 3 | Complete |
| AGENT-02 | Phase 3 | Complete |
| AGENT-03 | Phase 4 | Pending |
| AGENT-04 | Phase 4 | Pending |
| AGENT-05 | Phase 4 | Pending |
| AGENT-06 | Phase 4 | Complete |
| AGENT-07 | Phase 4 | Pending |
| FLOW-01 | Phase 5 | Pending |
| FLOW-02 | Phase 5 | Pending |
| FLOW-03 | Phase 5 | Pending |
| FLOW-04 | Phase 5 | Pending |
| FLOW-05 | Phase 5 | Pending |
| FLOW-06 | Phase 5 | Pending |
| FLOW-07 | Phase 5 | Pending |
| DLVR-01 | Phase 6 | Pending |
| DLVR-02 | Phase 6 | Pending |
| DLVR-03 | Phase 6 | Pending |
| DLVR-04 | Phase 6 | Pending |
| UX-01 | Phase 6 | Pending |
| UX-02 | Phase 6 | Pending |
| UX-03 | Phase 6 | Pending |
| UX-04 | Phase 6 | Pending |
| UX-05 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 40 total
- Mapped to phases: 40
- Unmapped: 0

---
*Requirements defined: 2026-03-18*
*Last updated: 2026-03-18 after roadmap creation*
