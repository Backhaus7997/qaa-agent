---
name: qa-bug-detective
description: QA Bug Detective. Runs generated tests and classifies failures as APPLICATION BUG, TEST CODE ERROR, ENVIRONMENT ISSUE, or INCONCLUSIVE with evidence and confidence levels. Use when user wants to run tests and classify results, investigate test failures, determine if failures are bugs or test issues, debug failing tests, triage test results, or understand why tests are failing. Triggers on "run tests", "classify failures", "why is this failing", "test failures", "debug tests", "triage results", "is this a bug or test error", "investigate failures".
---

# QA Bug Detective

## Purpose

Run generated tests and classify every failure into one of four categories with evidence and confidence levels. Auto-fix TEST CODE ERRORS when confidence is HIGH.

## Classification Decision Tree

```
Test fails
├── Syntax/import error in TEST file?
│   └── YES → TEST CODE ERROR
├── Error occurs in PRODUCTION code path?
│   ├── Known bug / unexpected behavior? → APPLICATION BUG
│   └── Code works as designed but test expectation wrong? → TEST CODE ERROR
├── Connection refused / timeout / missing env var?
│   └── YES → ENVIRONMENT ISSUE
└── Can't determine?
    └── INCONCLUSIVE
```

## Classification Categories

### APPLICATION BUG
- Error manifests in production code (not test code)
- Stack trace points to src/ or app/ code
- Behavior contradicts documented requirements or API contracts
- **Action**: Report only. NEVER auto-fix application code.

### TEST CODE ERROR
- Import/require fails (wrong path, missing module)
- Selector doesn't match current DOM
- Assertion expects wrong value (test written incorrectly)
- Missing await, wrong API usage, stale fixture reference
- **Action**: Auto-fix if HIGH confidence. Report if MEDIUM or lower.

### ENVIRONMENT ISSUE
- Connection refused (database, API, external service)
- Timeout waiting for resource
- Missing environment variable
- File/directory not found (test infrastructure)
- **Action**: Report with suggested resolution steps.

### INCONCLUSIVE
- Error is ambiguous
- Could be multiple root causes
- Insufficient data to classify
- **Action**: Report with what's known, request more info.

## Evidence Requirements

Every classification MUST include:
1. **File path**: Exact file where error occurs
2. **Line number**: Specific line of failure
3. **Error message**: Complete error text
4. **Code snippet**: The specific code proving the classification
5. **Confidence level**: HIGH / MEDIUM-HIGH / MEDIUM / LOW
6. **Reasoning**: Why this classification, not another

## Confidence Levels

| Level | Definition |
|-------|------------|
| HIGH | Clear evidence in one direction, no ambiguity |
| MEDIUM-HIGH | Strong evidence but minor ambiguity |
| MEDIUM | Evidence points one way but alternatives exist |
| LOW | Insufficient data, multiple possible causes |

## Auto-Fix Rules

Only auto-fix when:
- Classification = TEST CODE ERROR
- Confidence = HIGH
- Fix is mechanical (import path, selector, assertion value, config)

Fix types:
- Import path corrections
- Selector updates (match current DOM/data-testid)
- Assertion value updates (match current actual behavior)
- Config fixes (baseURL, timeout values)
- Missing await keywords
- Fixture path corrections

**NEVER auto-fix**: Application bugs, environment issues, anything with confidence < HIGH.

## Output: FAILURE_CLASSIFICATION_REPORT.md

```markdown
# Failure Classification Report

## Summary
| Classification | Count | Auto-Fixed | Needs Attention |
|---------------|-------|-----------|----------------|
| APPLICATION BUG | N | 0 | N |
| TEST CODE ERROR | N | N | N |
| ENVIRONMENT ISSUE | N | 0 | N |
| INCONCLUSIVE | N | 0 | N |

## Detailed Analysis

### Failure 1: [test name]
- **Classification**: [category]
- **Confidence**: [level]
- **File**: [path]:[line]
- **Error**: [message]
- **Evidence**: [code snippet + reasoning]
- **Action Taken**: [auto-fixed / reported]
- **Resolution**: [what was fixed / what needs human attention]
```

## Quality Gate

- [ ] Every failure classified with evidence
- [ ] Confidence level assigned to each
- [ ] No application bugs auto-fixed
- [ ] Auto-fixes only applied at HIGH confidence
- [ ] FAILURE_CLASSIFICATION_REPORT.md produced
