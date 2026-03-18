---
phase: 02-qa-standards-and-templates
plan: "02"
subsystem: templates
tags: [qa-repo-blueprint, validation-report, failure-classification, playwright, shopflow, markdown-templates]

# Dependency graph
requires:
  - phase: 01-core-infrastructure
    provides: template.cjs for template selection/fill, frontmatter.cjs for YAML parsing
provides:
  - QA_REPO_BLUEPRINT.md template defining test repo structure, stack, configs, CI/CD, and DoD
  - VALIDATION_REPORT.md template defining 4-layer validation output with fix loop tracking
  - FAILURE_CLASSIFICATION_REPORT.md template defining 4-category failure triage with evidence
affects: [03-discovery-agents, 04-generation-agents, qa-analyzer, qa-validator, qa-bug-detective]

# Tech tracking
tech-stack:
  added: []
  patterns: [GSD template format with frontmatter + sections + worked-example + guidelines + quality-gate]

key-files:
  created:
    - templates/qa-repo-blueprint.md
    - templates/validation-report.md
    - templates/failure-classification.md
  modified: []

key-decisions:
  - "All three templates use Playwright+TypeScript as the ShopFlow example stack for cross-template consistency"
  - "Validation report uses quantitative confidence criteria (HIGH/MEDIUM/LOW) based on layers passing, unresolved count, and fix loops"
  - "Failure classification requires mandatory classification reasoning explaining why a category was chosen over alternatives"

patterns-established:
  - "Template structure: YAML frontmatter -> Title+Purpose -> Required Sections with field tables -> Worked Example (200+ lines) -> Guidelines (DO/DON'T) -> Quality Gate checklist"
  - "ShopFlow cross-template consistency: same file paths (orderService.ts, paymentController.ts, priceCalculator.ts), endpoints, and test IDs across all templates"

requirements-completed: [TMPL-03, TMPL-04, TMPL-06]

# Metrics
duration: 6min
completed: 2026-03-18
---

# Phase 2 Plan 02: Blueprint and Validation Templates Summary

**Three validation/delivery pipeline templates (QA_REPO_BLUEPRINT, VALIDATION_REPORT, FAILURE_CLASSIFICATION) with 4-layer validation structure, 4-category failure triage, and complete ShopFlow worked examples totaling 1,270+ lines**

## Performance

- **Duration:** 6 min
- **Started:** 2026-03-18T19:30:58Z
- **Completed:** 2026-03-18T19:37:17Z
- **Tasks:** 3
- **Files created:** 3

## Accomplishments
- QA_REPO_BLUEPRINT.md template with 7 sections (Project Info through Definition of Done), complete Playwright config, GitHub Actions CI YAML, and 12-item DoD checklist (637 lines)
- VALIDATION_REPORT.md template with 4-layer validation (Syntax/Structure/Dependencies/Logic), fix loop progression tracking, and quantitative confidence criteria (244 lines)
- FAILURE_CLASSIFICATION_REPORT.md template with 4-category classification (APPLICATION BUG / TEST CODE ERROR / ENVIRONMENT ISSUE / INCONCLUSIVE), decision tree, 5-failure ShopFlow example with evidence, and auto-fix log (392 lines)

## Task Commits

Each task was committed atomically:

1. **Task 1: Create QA_REPO_BLUEPRINT.md template (TMPL-03)** - `affba56` (feat)
2. **Task 2: Create VALIDATION_REPORT.md template (TMPL-04)** - `bd5b83b` (feat)
3. **Task 3: Create FAILURE_CLASSIFICATION_REPORT.md template (TMPL-06)** - `3fd9b02` (feat)

## Files Created/Modified
- `templates/qa-repo-blueprint.md` - QA repo structure template with folder tree, stack, configs, CI/CD, and Definition of Done
- `templates/validation-report.md` - 4-layer validation output template with fix loop log and confidence level
- `templates/failure-classification.md` - Test failure classification template with evidence requirements and auto-fix log

## Decisions Made
- All three templates use the same ShopFlow e-commerce domain with consistent file paths (orderService.ts, paymentController.ts, priceCalculator.ts, LoginPage.ts) for cross-template coherence
- Validation report confidence criteria are quantitative: HIGH requires all PASS + 0 unresolved + max 1 loop; MEDIUM requires all PASS after fixes + 0-2 minor unresolved; LOW means any FAIL or critical unresolved
- Failure classification mandates classification reasoning per failure explaining why the chosen category was selected over alternatives (prevents lazy classification)
- Auto-fix restricted to TEST CODE ERROR with HIGH confidence only; APPLICATION BUGs are never auto-fixed

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Three of six validation/delivery templates now exist (blueprint, validation report, failure classification)
- Plan 02-03 can proceed to create audit and gap templates (TESTID_AUDIT_REPORT, GAP_ANALYSIS, QA_AUDIT_REPORT)
- Cross-template ShopFlow consistency established: same file paths, modules, and endpoints used in all three templates

---

## Self-Check: PASSED

- FOUND: templates/qa-repo-blueprint.md
- FOUND: templates/validation-report.md
- FOUND: templates/failure-classification.md
- FOUND: .planning/phases/02-qa-standards-and-templates/02-02-SUMMARY.md
- FOUND: commit affba56
- FOUND: commit bd5b83b
- FOUND: commit 3fd9b02

---
*Phase: 02-qa-standards-and-templates*
*Completed: 2026-03-18*
