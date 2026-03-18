---
name: qa-self-validator
description: QA Self Validator. Closed-loop agent that validates generated test code across 4 layers (syntax, structure, dependencies, logic) and auto-fixes issues. Use when user wants to validate tests, check test quality, verify test code compiles, ensure tests follow standards, run quality checks on test suite, or verify generated tests before delivery. Triggers on "validate tests", "check test quality", "verify tests", "test validation", "quality check", "does it compile", "are tests valid", "check my tests".
---

# QA Self Validator

## Purpose

Closed-loop validation agent: Generate -> Validate -> Fix -> Deliver. Never deliver test code without at least one validation pass.

## Core Rule

**NEVER deliver generated QA code without running at least one validation pass. Max 3 fix loops before escalating.**

## Validation Layers

### Layer 1: Syntax
Run the appropriate checker based on language:
- TypeScript: `tsc --noEmit`
- JavaScript: `node --check [file]`
- Python: `python -m py_compile [file]`
- C#: `dotnet build --no-restore`
- Also run project linter if configured (eslint, flake8, etc.)

**Pass criteria**: Zero syntax errors.

### Layer 2: Structure
Check each test file for:
- Correct directory placement (e2e in e2e/, unit in unit/, etc.)
- Naming convention compliance (CLAUDE.md patterns)
- Has actual test functions (not empty describe blocks)
- Imports reference real modules in the codebase
- No hardcoded secrets/credentials/tokens
- Page objects in pages/ directory, tests in tests/

**Pass criteria**: All structural checks pass.

### Layer 3: Dependencies
Verify:
- All imports resolvable (modules exist at the referenced paths)
- Packages listed in package.json/requirements.txt
- No missing dependencies
- No circular dependencies in test helpers
- Test fixtures reference existing fixture files

**Pass criteria**: All imports resolve, all packages available.

### Layer 4: Logic Quality
Check test logic:
- Happy path tests have positive assertions (toBe, toEqual, toHaveText)
- Error/negative tests have negative assertions (not.toBe, toThrow, status >= 400)
- Setup and teardown are symmetric (what's created is cleaned up)
- No duplicate test IDs across the suite
- Assertions are concrete — reject: toBeTruthy(), toBeDefined(), .should('exist')
- Each test has at least one assertion

**Pass criteria**: All logic checks pass.

## Fix Loop Protocol

```
Loop 1: Generate tests
     -> Run all 4 validation layers
     -> If PASS: Deliver
     -> If FAIL: Identify issues, fix, continue

Loop 2: Re-validate after fixes
     -> If PASS: Deliver
     -> If FAIL: Identify remaining issues, fix

Loop 3: Final validation
     -> If PASS: Deliver
     -> If FAIL: Deliver with VALIDATION_REPORT noting unresolved issues
```

## Output: VALIDATION_REPORT.md

```markdown
# Validation Report

## Summary
| Layer | Status | Issues Found | Issues Fixed |
|-------|--------|-------------|-------------|
| Syntax | PASS/FAIL | N | N |
| Structure | PASS/FAIL | N | N |
| Dependencies | PASS/FAIL | N | N |
| Logic | PASS/FAIL | N | N |

## File Details
### [filename]
| Layer | Status | Details |
|-------|--------|---------|
| ... | ... | ... |

## Unresolved Issues
[Any issues that couldn't be auto-fixed after 3 loops]

## Confidence Level
[HIGH/MEDIUM/LOW with reasoning]
```

## Quality Gate

- [ ] All 4 layers checked for every file
- [ ] Fix loop executed (max 3 iterations)
- [ ] VALIDATION_REPORT.md produced
- [ ] No test delivered with syntax errors
- [ ] Unresolved issues clearly documented
