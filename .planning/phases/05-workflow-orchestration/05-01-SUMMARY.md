---
phase: 05-workflow-orchestration
plan: 01
subsystem: infra
tags: [cli, init, maturity-scoring, workflow-routing, pipeline-state]

# Dependency graph
requires:
  - phase: 01-core-infrastructure
    provides: CLI tooling, init system pattern, core.cjs utilities, state management
provides:
  - cmdInitQaStart function in init.cjs returning full workflow context
  - qa-start CLI route in qaa-tools.cjs init router
  - Maturity scoring algorithm (0-100) for QA repo assessment
  - Workflow option detection (1/2/3) based on repo paths and maturity
affects: [05-02-orchestrator, 06-delivery]

# Tech tracking
tech-stack:
  added: []
  patterns: [maturity-scoring, recursive-file-finder, argv-parsing-in-init]

key-files:
  created: []
  modified:
    - bin/lib/init.cjs
    - bin/qaa-tools.cjs

key-decisions:
  - "Maturity scoring implemented inline in init.cjs using fs.readdirSync with 3-level recursive helper -- no external dependencies"
  - "Score=0 edge case falls back to Option 1 with descriptive maturity_note field"
  - "Threshold boundaries: <70 -> Option 2, >=70 -> Option 3, matching RESEARCH.md spec"

patterns-established:
  - "argv-based parameter passing: init functions parse --dev-repo and --qa-repo from process.argv"
  - "Maturity scoring dimensions: POM(25), Assertion(25), CI/CD(20), Fixtures(15), Naming(15)"

requirements-completed: [FLOW-05]

# Metrics
duration: 2min
completed: 2026-03-19
---

# Phase 5 Plan 1: Init qa-start Function and CLI Integration Summary

**cmdInitQaStart init variant returning workflow option, 7 agent models, maturity scoring (0-100), repo paths, config flags, and pipeline state in a single JSON call**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-19T15:41:55Z
- **Completed:** 2026-03-19T15:44:10Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Added cmdInitQaStart function to init.cjs with maturity scoring across 5 dimensions (POM usage, assertion quality, CI/CD integration, fixture management, naming convention)
- Implemented workflow option detection: option=1 (single repo/empty QA), option=2 (immature QA, score <70), option=3 (mature QA, score >=70)
- Routed qa-start in CLI router with usage documentation and error message update
- Handles all edge cases: no QA repo (option=1), nonexistent QA repo path (score=0, option=1 fallback), empty QA repo (score=0, option=1 with maturity_note)

## Task Commits

Each task was committed atomically:

1. **Task 1: Add cmdInitQaStart function to init.cjs** - `b0cc84e` (feat)
2. **Task 2: Add qa-start case to CLI router in qaa-tools.cjs** - `bcaed8d` (feat)

## Files Created/Modified
- `bin/lib/init.cjs` - Added cmdInitQaStart function with maturity scoring, option detection, and full result object; added export
- `bin/qaa-tools.cjs` - Added qa-start case in init switch, updated error message and usage comment

## Decisions Made
- Maturity scoring uses a recursive file finder helper (findFilesRecursive) limited to 3 levels deep, excluding node_modules and .git directories
- Assertion quality sampling reads up to 10 test files and counts concrete vs vague assertion patterns using regex matching
- CI/CD detection checks .github/workflows/ directory (reading first file) plus Jenkinsfile, .gitlab-ci.yml, azure-pipelines.yml for test command presence

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- init qa-start returns everything the orchestrator needs to bootstrap
- Ready for Plan 02: QA pipeline orchestrator that calls init qa-start at startup and routes based on option value
- All 7 agent model resolutions working (scanner, analyzer, planner, executor, validator, detective, injector)

## Self-Check: PASSED

- [x] bin/lib/init.cjs exists with cmdInitQaStart function and export
- [x] bin/qaa-tools.cjs exists with qa-start case, usage comment, and error list
- [x] 05-01-SUMMARY.md exists
- [x] Commit b0cc84e exists (Task 1)
- [x] Commit bcaed8d exists (Task 2)

---
*Phase: 05-workflow-orchestration*
*Completed: 2026-03-19*
