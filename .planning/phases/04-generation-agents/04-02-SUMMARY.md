---
phase: 04-generation-agents
plan: "02"
subsystem: agents
tags: [validator, bug-detective, validation, failure-classification, 4-layer, fix-loop, decision-tree]

# Dependency graph
requires:
  - phase: 02-qa-standards-templates
    provides: validation-report.md and failure-classification.md templates defining output format contracts
  - phase: 03-discovery-agents
    provides: established agent .md XML structure pattern (purpose, required_reading, process, output, quality_gate, success_criteria)
provides:
  - qaa-validator.md agent workflow (4-layer validation with fix loop)
  - qaa-bug-detective.md agent workflow (test execution and failure classification)
affects: [05-workflow-orchestration, 06-delivery-ux]

# Tech tracking
tech-stack:
  added: []
  patterns: [4-layer-validation, fix-loop-protocol, classification-decision-tree, confidence-based-auto-fix]

key-files:
  created:
    - agents/qaa-validator.md
    - agents/qaa-bug-detective.md
  modified: []

key-decisions:
  - "Validator encodes all 8 CONTEXT.md locked decisions in process step logic (self-fixes, fail-fast, max 3 loops, generated-only scope, Layer 4 cross-check, HIGH/MEDIUM/LOW fix confidence, fix history, no-commit)"
  - "Bug detective encodes all 3 CONTEXT.md locked decisions (never touches app code, actually runs tests, 4-category classification with evidence)"
  - "Both agents use CHECKPOINT_RETURN for escalation scenarios (validator: max loops exhausted, detective: no test runner detected)"

patterns-established:
  - "Fix confidence classification: HIGH=auto-apply, MEDIUM/LOW=flag for review -- applied to validator fix loop"
  - "Classification decision tree: structured branching logic for categorizing test failures with mandatory reasoning per classification"
  - "Quality gate verbatim embedding: template quality gate items copied exactly, then agent-specific checks appended"

requirements-completed: [AGENT-05, AGENT-07]

# Metrics
duration: 6min
completed: 2026-03-19
---

# Phase 4 Plan 2: Validator and Bug Detective Agent Workflows Summary

**4-layer test validation agent with 3-loop fix protocol and failure classification agent with decision-tree-based categorization and HIGH-confidence-only auto-fix**

## Performance

- **Duration:** 6 min
- **Started:** 2026-03-19T14:21:11Z
- **Completed:** 2026-03-19T14:27:11Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Created qaa-validator.md (450 lines) with 8 process steps encoding all 8 CONTEXT.md locked decisions for 4-layer sequential validation
- Created qaa-bug-detective.md (444 lines) with 8 process steps encoding all 3 CONTEXT.md locked decisions for test execution and failure classification
- Both agents follow the exact XML-tagged structure established by qaa-scanner.md and qaa-analyzer.md in Phase 3

## Task Commits

Each task was committed atomically:

1. **Task 1: Create qaa-validator.md agent workflow file** - `8518f10` (feat)
2. **Task 2: Create qaa-bug-detective.md agent workflow file** - `b38f998` (feat)

## Files Created/Modified
- `agents/qaa-validator.md` - 4-layer validation (syntax, structure, dependencies, logic) with fail-fast sequential execution, max 3 fix loops, HIGH-confidence auto-fixes only, VALIDATION_REPORT.md output, does NOT commit
- `agents/qaa-bug-detective.md` - Test suite execution and failure classification (APP BUG, TEST CODE ERROR, ENV ISSUE, INCONCLUSIVE) with evidence and confidence, auto-fixes TEST CODE ERROR at HIGH confidence only, never touches application code

## Decisions Made
None - followed plan as specified. All locked decisions from CONTEXT.md were encoded directly into process step logic.

## Deviations from Plan
None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Validator and bug detective agent workflows complete
- Ready for 04-03-PLAN.md: Test-ID injector agent workflow
- All 4 agents built so far (scanner, analyzer, validator, bug-detective) follow consistent XML-tagged structure
- Remaining for Phase 4: qaa-planner.md, qaa-executor.md (04-01), qaa-testid-injector.md (04-03)

## Self-Check: PASSED

- FOUND: agents/qaa-validator.md (450 lines, 6 XML sections, 8 process steps)
- FOUND: agents/qaa-bug-detective.md (444 lines, 6 XML sections, 8 process steps)
- FOUND: 04-02-SUMMARY.md
- FOUND: commit 8518f10 (Task 1)
- FOUND: commit b38f998 (Task 2)

---
*Phase: 04-generation-agents*
*Completed: 2026-03-19*
