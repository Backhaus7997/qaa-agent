---
phase: 02-qa-standards-and-templates
plan: "03"
subsystem: testing
tags: [templates, audit, gap-analysis, test-id, scoring, quality-assessment]

# Dependency graph
requires:
  - phase: 02-qa-standards-and-templates
    provides: "Template format conventions (frontmatter + sections + examples + guidelines pattern from plans 01/02)"
provides:
  - "TESTID_AUDIT_REPORT.md template for testid-injector agent (coverage scoring, per-file detail tables, naming compliance)"
  - "GAP_ANALYSIS.md template for analyzer agent (coverage map, missing/broken tests, quality assessment, recommendations)"
  - "QA_AUDIT_REPORT.md template for validator agent (6-dimension scoring, critical issues, detailed per-file findings)"
affects: [phase-03-discovery-agents, phase-04-generation-agents, phase-05-workflow-orchestration]

# Tech tracking
tech-stack:
  added: []
  patterns: [six-dimension-weighted-scoring, coverage-map-matrix, decision-gate-thresholds, per-file-audit-tables]

key-files:
  created:
    - templates/testid-audit-report.md
    - templates/gap-analysis.md
    - templates/qa-audit-report.md
  modified: []

key-decisions:
  - "ShopFlow example consistent across all 3 templates: same files (LoginPage.tsx, CheckoutForm.tsx, ProductCard.tsx), same 15-test baseline, same 2-of-5 module coverage pattern"
  - "6-dimension scoring weights: Locator 20%, Assertion 20%, POM 15%, Coverage 20%, Naming 15%, Test Data 10% -- prioritizing selector resilience and assertion quality"
  - "Decision gate thresholds for testid-injector: >90% SELECTIVE, 50-90% TARGETED, <50% FULL PASS, 0% P0 FIRST"
  - "Quality assessment in gap-analysis covers 4 dimensions (locators, assertions, POM, naming) vs 6 in audit-report (adds coverage + test data)"

patterns-established:
  - "Audit template pattern: coverage scoring + per-file detail tables + compliance checks + decision gate"
  - "Gap analysis pattern: coverage map matrix + missing/broken test separation + quality assessment + prioritized recommendations"
  - "6-dimension scoring pattern: independent dimension scores with weights summing to 100%, weighted average produces overall score with letter grade"

requirements-completed: [TMPL-07, TMPL-08, TMPL-09]

# Metrics
duration: 7min
completed: 2026-03-18
---

# Phase 02 Plan 03: Audit and Gap Templates Summary

**Three audit/assessment templates with scoring systems, coverage metrics, and ShopFlow worked examples: TESTID_AUDIT_REPORT (19% coverage audit with naming compliance), GAP_ANALYSIS (coverage map showing 2/5 modules covered), QA_AUDIT_REPORT (62/100 six-dimension quality scoring)**

## Performance

- **Duration:** 7 min
- **Started:** 2026-03-18T19:30:59Z
- **Completed:** 2026-03-18T19:37:59Z
- **Tasks:** 3
- **Files modified:** 3

## Accomplishments
- Created TESTID_AUDIT_REPORT.md template (355 lines) with coverage scoring, per-file detail tables for 6 component files, naming convention compliance audit, and decision gate with 4 coverage-based injection strategies
- Created GAP_ANALYSIS.md template (410 lines) with coverage map matrix, 10 missing test specifications prioritized by P0/P1/P2, 3 broken test diagnoses, 4-dimension quality assessment, and existing test inventory
- Created QA_AUDIT_REPORT.md template (466 lines) with 6-dimension weighted scoring system, explicit formula calculation, 3 BLOCKER-severity critical issues, 8 improvement recommendations with score impact projections, and detailed per-file findings for 6 files

## Task Commits

Each task was committed atomically:

1. **Task 1: Create TESTID_AUDIT_REPORT.md template (TMPL-07)** - `6995bac` (feat)
2. **Task 2: Create GAP_ANALYSIS.md template (TMPL-08)** - `780d609` (feat)
3. **Task 3: Create QA_AUDIT_REPORT.md template (TMPL-09)** - `106048c` (feat)

## Files Created/Modified
- `templates/testid-audit-report.md` - Test ID audit report template: coverage scoring, per-file element tables with proposed data-testid values, naming convention compliance, decision gate
- `templates/gap-analysis.md` - Gap analysis template: coverage map matrix, missing/broken tests, quality assessment across 4 dimensions, prioritized recommendations
- `templates/qa-audit-report.md` - QA audit report template: 6-dimension weighted scoring (locator quality, assertion specificity, POM compliance, test coverage, naming convention, test data management), critical issues, detailed per-file findings

## Decisions Made
- ShopFlow example data kept consistent with plan 01 and plan 02 templates: same component files (LoginPage.tsx, CheckoutForm.tsx, ProductCard.tsx), same 15-test baseline, same partial coverage pattern
- 6-dimension scoring weights chosen to prioritize selector resilience and assertion quality (20% each) over naming conventions and test data management (15% and 10%)
- Gap analysis distinguishes between missing tests (need writing) and broken tests (need fixing) as separate sections because they require different actions
- Quality assessment in gap-analysis uses 4 dimensions (subset) vs 6 in audit-report (full) to avoid redundancy -- gap-analysis focuses on what to improve, audit-report quantifies how much

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All 3 audit/assessment templates complete, ready for Plan 04 (Enhanced CLAUDE.md)
- Templates cross-reference each other: testid-audit coverage feeds gap-analysis coverage map, gap-analysis feeds audit report
- All 9 of 9 templates now exist in the templates/ directory (6 from plans 01-02, 3 from this plan)

## Self-Check: PASSED

- [x] templates/testid-audit-report.md exists (354 lines)
- [x] templates/gap-analysis.md exists (409 lines)
- [x] templates/qa-audit-report.md exists (465 lines)
- [x] Commit 6995bac exists (Task 1)
- [x] Commit 780d609 exists (Task 2)
- [x] Commit 106048c exists (Task 3)

---
*Phase: 02-qa-standards-and-templates*
*Completed: 2026-03-18*
