# Phase 2: QA Standards and Templates - Research

**Researched:** 2026-03-18
**Domain:** QA artifact template design + CLAUDE.md authoring for multi-agent QA system
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Full worked examples with real values (200+ lines each, like GSD templates)
- Include section descriptions, guidelines, anti-patterns, and filled example sections
- Agents produce better output when templates show exactly what "good" looks like
- All templates use the same example domain: e-commerce API (ShopFlow-style: products, orders, payments, auth)
- Consistent domain across all templates so agents understand the pattern cohesively
- Move existing qa-agent-gsd/CLAUDE.md to project root and enhance significantly
- Keep ALL existing QA standards (pyramid, locators, POM, assertions, naming, quality gates)
- Add agent pipeline rules, module boundaries, verification commands, git workflow, team settings, agent coordination rules
- Templates in `templates/` at project root (mirrors GSD pattern)
- template.cjs (from Phase 1) uses cmdTemplateSelect + cmdTemplateFill to find/fill them

### Claude's Discretion
- Exact frontmatter schema for each template
- Section ordering within templates
- Level of detail in anti-pattern sections
- Whether to include a "changelog" section in templates

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| TMPL-01 | QA_ANALYSIS.md template (architecture overview, risks, unit test targets, API targets, pyramid distribution) | Section structure defined by qa-repo-analyzer SKILL.md Step 2 + qa-analyze.md spec Milestone 2. Five required sections identified. |
| TMPL-02 | TEST_INVENTORY.md template (pyramid-based test cases: unit, integration, API, E2E, each with ID/target/inputs/outcome/priority) | Section structure defined by qa-repo-analyzer SKILL.md Step 3 + qa-analyze.md spec Milestone 3. Four pyramid tiers with per-case fields. |
| TMPL-03 | QA_REPO_BLUEPRINT.md template (repo name, folder structure, stack, configs, CI/CD, Definition of Done) | Section structure defined by qa-repo-analyzer SKILL.md Step 4 + qa-analyze.md spec Milestone 4 (no-QA-repo path). Six sections identified. |
| TMPL-04 | VALIDATION_REPORT.md template (pass/fail per file per layer, confidence level) | Section structure defined by qa-self-validator SKILL.md output section. Summary table + per-file details + unresolved issues + confidence. |
| TMPL-05 | SCAN_MANIFEST.md template (file tree, framework detection, testable surfaces) | Section structure defined by qa-testid-injector SKILL.md Phase 1 + data-testid-SKILL.md Phase 1. File list with priority ordering. |
| TMPL-06 | FAILURE_CLASSIFICATION_REPORT.md template (classification table, evidence, confidence levels) | Section structure defined by qa-bug-detective SKILL.md output section. Summary table (4 categories) + detailed per-failure analysis. |
| TMPL-07 | TESTID_AUDIT_REPORT.md template (coverage score, missing elements, proposed values by priority) | Section structure defined by qa-testid-injector SKILL.md Phase 2 + data-testid-SKILL.md Phase 2 AUDIT section. Coverage score + per-file detail tables. |
| TMPL-08 | GAP_ANALYSIS.md template (coverage map, missing tests prioritized, broken tests) | Section structure defined by qa-analyze.md spec Milestone 4 (QA-repo-exists path) + update-tests.md spec Milestone 1. Coverage gaps + quality assessment. |
| TMPL-09 | QA_AUDIT_REPORT.md template (6-dimension scoring, critical issues, recommendations) | Derived from update-tests.md spec Milestone 1 (TEST_AUDIT.md) enhanced with multi-dimensional scoring. Quality audit with actionable recommendations. |
| TMPL-10 | CLAUDE.md with complete QA standards (pyramid, locators, POM, assertions, naming, quality gates) | Base content from existing qa-agent-gsd/CLAUDE.md (6.9KB). Enhanced with agent pipeline rules, module boundaries, verification commands per CONTEXT.md decisions. |
</phase_requirements>

<research_summary>
## Summary

This phase creates 10 QA artifact templates and an enhanced CLAUDE.md that together form the "shared brain" of the multi-agent QA system. Every downstream agent (scanner, analyzer, planner, executor, validator, testid-injector, bug-detective) references these templates to know what sections to produce and CLAUDE.md to know what standards to enforce.

The research reveals that the exact section requirements for each template are already fully defined across three authoritative sources within the project: (1) the 6 SKILL.md files in `.claude/skills/`, (2) the 3 spec files in `qa-agent-gsd/specs/`, and (3) the `data-testid-SKILL.md` at project root. Cross-referencing these sources against REQUIREMENTS.md produces a complete section map for all 10 templates with no gaps.

The GSD template system establishes a clear pattern: YAML frontmatter for metadata, markdown sections for structure, `{placeholder}` syntax for fillable fields, worked examples showing "what good looks like," and guidelines sections documenting anti-patterns. The existing `template.cjs` from Phase 1 already supports `cmdTemplateSelect` and `cmdTemplateFill` operations that read from a `templates/` directory, so the QA templates must live at `templates/` in the project root.

**Primary recommendation:** Build all 10 templates sequentially, starting with the four analysis-pipeline templates (TMPL-01, TMPL-02, TMPL-03, TMPL-05) since they form the input chain, then the four validation/audit templates (TMPL-04, TMPL-06, TMPL-07, TMPL-08), then QA_AUDIT_REPORT (TMPL-09), and finally CLAUDE.md (TMPL-10) which references all templates and establishes the complete standard.
</research_summary>

<standard_stack>
## Standard Stack

This phase produces markdown documents, not code. The "stack" is the template format conventions.

### Core
| Component | Source | Purpose | Why Standard |
|-----------|--------|---------|--------------|
| YAML frontmatter | GSD template pattern | Machine-readable metadata per template | template.cjs reads frontmatter; enables programmatic template selection |
| Markdown sections | GSD template pattern | Human-readable structure | Agents parse section headers to know where to write content |
| `{placeholder}` syntax | GSD template pattern | Fillable fields agents replace | template.cjs cmdTemplateFill uses this syntax |
| ShopFlow example domain | CONTEXT.md locked decision | Consistent worked examples across all 10 templates | Agents learn the pattern cohesively from one domain |

### Supporting
| Component | Source | Purpose | When to Use |
|-----------|--------|---------|-------------|
| frontmatter.cjs | Phase 1 output | Parse/reconstruct YAML frontmatter in templates | When templates need programmatic metadata extraction |
| template.cjs | Phase 1 output | Template selection and fill operations | When agents select or scaffold from templates |

### Template Format Pattern (from GSD)
Every QA template MUST follow this structure:
1. **YAML frontmatter** -- metadata block (template name, version, artifact type, required sections list)
2. **Title + purpose** -- what the artifact is and when to produce it
3. **Required sections** -- each section with header, description, and field definitions
4. **Worked example** -- 200+ lines of filled ShopFlow content showing "what good looks like"
5. **Guidelines** -- anti-patterns, quality rules, what to avoid
6. **Quality gate** -- checklist of mandatory checks before delivery
</standard_stack>

<architecture_patterns>
## Architecture Patterns

### Recommended Template Directory Structure
```
templates/
  qa-analysis.md              # TMPL-01: QA_ANALYSIS.md template
  test-inventory.md           # TMPL-02: TEST_INVENTORY.md template
  qa-repo-blueprint.md        # TMPL-03: QA_REPO_BLUEPRINT.md template
  validation-report.md        # TMPL-04: VALIDATION_REPORT.md template
  scan-manifest.md            # TMPL-05: SCAN_MANIFEST.md template
  failure-classification.md   # TMPL-06: FAILURE_CLASSIFICATION_REPORT.md template
  testid-audit-report.md      # TMPL-07: TESTID_AUDIT_REPORT.md template
  gap-analysis.md             # TMPL-08: GAP_ANALYSIS.md template
  qa-audit-report.md          # TMPL-09: QA_AUDIT_REPORT.md template
CLAUDE.md                     # TMPL-10: Project root, enhanced QA standards
```

### Pattern 1: GSD Template Structure
**What:** Every template follows frontmatter + structure + example + guidelines format
**When to use:** All 9 markdown templates (TMPL-01 through TMPL-09)
**Reference pattern from GSD `verification-report.md`:**
```markdown
---
template_name: [artifact-name]
version: 1.0
artifact_type: [qa-analysis | test-inventory | etc.]
produces: [ARTIFACT_NAME.md]
required_sections:
  - section_name
  - section_name
---

# [Artifact Name] Template

**Purpose:** [What this artifact communicates and who consumes it]
**Producer:** [Which agent creates this]
**Consumer:** [Which agent or human reads this]

## Required Sections

### Section 1: [Name]
**Description:** [What this section contains]
**Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| [field] | [type] | YES/NO | [what it means] |

[... more sections ...]

## Worked Example (ShopFlow E-Commerce API)

[Full 200+ line example with real ShopFlow data showing every section filled correctly]

## Guidelines

**DO:**
- [Positive instruction]

**DON'T:**
- [Anti-pattern with explanation]

## Quality Gate

- [ ] [Checklist item]
```

### Pattern 2: CLAUDE.md Enhancement Strategy
**What:** Layered enhancement of existing 6.9KB CLAUDE.md
**When to use:** TMPL-10 only
**Layer strategy:**
```
Layer 1: EXISTING QA Standards (preserved verbatim from qa-agent-gsd/CLAUDE.md)
  - Framework Detection
  - Testing Pyramid
  - Locator Strategy (with framework examples)
  - Page Object Model Rules
  - Test Spec Rules
  - Naming Conventions
  - Repo Structure
  - Test Data Rules
  - Analysis Documents
  - Quality Gates

Layer 2: Agent Pipeline Rules (NEW)
  - Pipeline stages: scan -> analyze -> [testid-inject] -> plan -> generate -> validate -> deliver
  - Stage transition rules
  - Handoff patterns between agents

Layer 3: Module Boundaries (NEW)
  - File ownership table (which agent owns which artifact)
  - Read-before-write rules per agent

Layer 4: Verification Commands (NEW)
  - Per-artifact verification commands
  - How to check each artifact type is valid

Layer 5: Git Workflow (NEW)
  - Branch naming: qa/auto-{project}-{date}
  - Commit format conventions
  - PR template reference

Layer 6: Team Settings (NEW)
  - Max concurrent agents
  - Worktree isolation
  - Dependency ordering

Layer 7: Agent Coordination (NEW)
  - How agents hand off
  - What to read before producing
  - Quality gates per artifact type
```

### Pattern 3: ShopFlow Example Domain
**What:** Consistent e-commerce API example across all templates
**When to use:** Every template's worked example section
**Domain entities:**
```
ShopFlow E-Commerce API:
  - Products: CRUD + images + SKU management + categories
  - Orders: state machine (pending -> confirmed -> shipped -> delivered -> cancelled)
  - Payments: Stripe integration, refunds, webhooks
  - Auth: JWT-based, register/login/refresh/logout
  - Inventory: stock reservation, low-stock alerts
  - Users: profiles, addresses, order history

Realistic file paths:
  - src/controllers/productController.ts
  - src/services/orderService.ts
  - src/middleware/authMiddleware.ts
  - src/models/Product.ts, Order.ts, User.ts, Payment.ts
  - src/routes/api/v1/products.ts, orders.ts, auth.ts
  - src/utils/validators.ts, priceCalculator.ts

Endpoints:
  - POST /api/v1/auth/register
  - POST /api/v1/auth/login
  - GET  /api/v1/products
  - GET  /api/v1/products/:id
  - POST /api/v1/orders
  - PATCH /api/v1/orders/:id/status
  - POST /api/v1/payments/charge
  - POST /api/v1/payments/webhook
```

### Anti-Patterns to Avoid
- **Generic placeholders instead of worked examples:** Templates with `[fill in here]` everywhere teach agents nothing. Every template MUST have a fully filled ShopFlow example.
- **Inconsistent domain across templates:** Using different example domains (e-commerce in one, social media in another) confuses agents about cross-template relationships.
- **Missing quality gates:** Templates without quality gate checklists produce artifacts that skip validation.
- **Frontmatter without required_sections list:** Agents need machine-readable section names to verify completeness.
- **Vague section descriptions:** "Include relevant information" teaches nothing. Be prescriptive: "Table with columns: Module, Function, Risk Level (HIGH/MEDIUM/LOW), Justification."
</architecture_patterns>

<template_section_maps>
## Template Section Maps

Cross-referenced from SKILL.md files, spec files, and data-testid-SKILL.md. Each template's exact required sections are documented below. The planner MUST use these maps as the source of truth for what each template contains.

### TMPL-01: QA_ANALYSIS.md
**Source:** qa-repo-analyzer SKILL.md Step 2 + qa-analyze.md spec Milestone 2
**Required sections:**
1. **Architecture Overview** -- System type, language, runtime, entry points table, internal layers
2. **External Dependencies** -- Table: dependency, purpose, risk level (HIGH/MEDIUM/LOW)
3. **Risk Assessment** -- Prioritized risks with justification (specific to the codebase, not generic)
4. **Top 10 Unit Test Targets** -- Table: module/function, why high-priority, complexity assessment
5. **API/Contract Test Targets** -- Endpoints needing contract testing
6. **Recommended Testing Pyramid** -- Percentages adjusted to THIS specific app's architecture

**ShopFlow example must show:** Node.js/Express/TypeScript stack, PostgreSQL with Prisma, Stripe integration as HIGH risk, JWT auth middleware as top unit test target, 65/15/15/5 pyramid split justified by heavy API layer.

### TMPL-02: TEST_INVENTORY.md
**Source:** qa-repo-analyzer SKILL.md Step 3 + qa-analyze.md spec Milestone 3 + CLAUDE.md Test Spec Rules
**Required sections:**
1. **Summary** -- Total test count by pyramid tier, coverage assessment
2. **Unit Tests (60-70%)** -- Per test: ID (UT-MODULE-NNN), target (file:function), what to validate, concrete inputs, mocks needed, explicit expected outcome, priority
3. **Integration/Contract Tests (10-15%)** -- Component interactions, API contracts
4. **API Tests (20-25%)** -- Per test: ID (API-RESOURCE-NNN), method + endpoint, request body/params, expected status + response shape
5. **E2E Smoke Tests (3-5%)** -- Max 3-8 critical user paths with full flow description

**ShopFlow example must show:** At least 3-5 test cases per tier with concrete values. Example: UT-PRICE-001 targeting `priceCalculator.ts:calculateOrderTotal` with input `[{sku: 'WIDGET-001', qty: 3, price: 29.99}]`, expected `89.97`, priority P0.

### TMPL-03: QA_REPO_BLUEPRINT.md
**Source:** qa-repo-analyzer SKILL.md Step 4 + qa-analyze.md spec Milestone 4 (no-QA-repo path)
**Required sections:**
1. **Project Info** -- Suggested repo name, relationship to dev repo
2. **Folder Structure** -- Complete tree with explanations per directory
3. **Recommended Stack** -- Framework, runner, reporter, assertion library
4. **Config Files** -- playwright.config.ts or equivalent, tsconfig, .env.example
5. **Execution Scripts** -- npm scripts for smoke (PR), regression (nightly), CI commands
6. **CI/CD Strategy** -- Smoke on PR, regression nightly, report generation
7. **Definition of Done** -- Checklist for when the QA repo is ready for use

**ShopFlow example must show:** Playwright + TypeScript stack, complete folder tree, npm scripts (`test:smoke`, `test:regression`, `test:api`), GitHub Actions CI config.

### TMPL-04: VALIDATION_REPORT.md
**Source:** qa-self-validator SKILL.md output section
**Required sections:**
1. **Summary** -- Table: Layer (Syntax/Structure/Dependencies/Logic), Status (PASS/FAIL), Issues Found count, Issues Fixed count
2. **File Details** -- Per file: Layer, Status, Details (what passed/failed)
3. **Unresolved Issues** -- Issues that could not be auto-fixed after 3 loops
4. **Fix Loop Log** -- Which loop (1/2/3), what was found, what was fixed
5. **Confidence Level** -- HIGH/MEDIUM/LOW with reasoning

**ShopFlow example must show:** 4 test files validated, 2 syntax issues found and fixed in loop 1, 1 logic issue (vague assertion) found and fixed in loop 2, final PASS with HIGH confidence.

### TMPL-05: SCAN_MANIFEST.md
**Source:** qa-testid-injector SKILL.md Phase 1 + data-testid-SKILL.md Phase 1 SCAN
**Required sections:**
1. **Project Detection** -- Framework detected, language, component file patterns
2. **File List** -- Table: file path, component name, interaction density (HIGH/MEDIUM/LOW), priority order
3. **Summary Statistics** -- Total files, files by framework, files by priority
4. **Testable Surfaces** -- Categorized list: pages, forms, API endpoints, business logic modules
5. **Decision Gate** -- If 0 component files found, STOP flag

**ShopFlow example must show:** React/TypeScript detection, 12-15 component files listed with priority ordering (CheckoutForm.tsx HIGH, ProductCard.tsx MEDIUM, Footer.tsx LOW).

### TMPL-06: FAILURE_CLASSIFICATION_REPORT.md
**Source:** qa-bug-detective SKILL.md output section
**Required sections:**
1. **Summary** -- Table: Classification (APPLICATION BUG / TEST CODE ERROR / ENVIRONMENT ISSUE / INCONCLUSIVE), Count, Auto-Fixed count, Needs Attention count
2. **Detailed Analysis** -- Per failure: test name, classification, confidence (HIGH/MEDIUM-HIGH/MEDIUM/LOW), file:line, error message, evidence (code snippet + reasoning), action taken, resolution
3. **Auto-Fix Log** -- What was fixed, what the fix was, confidence at time of fix
4. **Recommendations** -- Suggested next steps for each category

**ShopFlow example must show:** 5 failures classified: 2 APP BUGs (one in orderService state transition, one in payment webhook), 2 TEST CODE ERRORs (wrong selector, missing await -- both auto-fixed at HIGH confidence), 1 ENVIRONMENT ISSUE (database connection timeout).

### TMPL-07: TESTID_AUDIT_REPORT.md
**Source:** qa-testid-injector SKILL.md Phase 2 + data-testid-SKILL.md Phase 2 AUDIT section
**Required sections:**
1. **Summary** -- Files scanned count, elements with existing data-testid count, elements missing data-testid count (by P0/P1/P2)
2. **Coverage Score** -- Current % and after-injection %, formula: existing / total interactive elements
3. **File Details** -- Per file: component name, table with Line, Element type, Current Selector, Proposed data-testid value, Priority (P0/P1/P2)
4. **Naming Convention Compliance** -- Check against {context}-{description}-{element-type} pattern
5. **Decision Gate** -- Coverage thresholds: >90% selective, <50% full pass, 0% P0-first

**ShopFlow example must show:** LoginPage.tsx with 8 elements audited (4 P0, 3 P1, 1 P2), current coverage 25%, proposed values following naming convention (login-email-input, login-password-input, login-submit-btn, login-forgot-password-link).

### TMPL-08: GAP_ANALYSIS.md
**Source:** qa-analyze.md spec Milestone 4 (QA-repo-exists path) + update-tests.md spec
**Required sections:**
1. **Coverage Map** -- What exists vs what should exist, by module/feature
2. **Missing Tests** -- Prioritized list of test cases that don't exist yet, with IDs and expected outcomes
3. **Broken Tests** -- Tests that exist but fail, with failure reason
4. **Quality Assessment** -- Locator tier distribution, assertion quality, POM compliance rating
5. **Existing Test Inventory** -- What's already covered and working
6. **Recommendations** -- Prioritized action list: fix broken first, then add missing P0, then P1

**ShopFlow example must show:** Existing QA repo has 15 tests covering auth and products, but 0 order tests, 0 payment tests. 3 broken tests (stale selectors). Quality: 40% Tier 1 locators, 60% Tier 4. POM partially compliant (assertions found in 2 page objects).

### TMPL-09: QA_AUDIT_REPORT.md
**Source:** update-tests.md spec Milestone 1 (TEST_AUDIT) enhanced with multi-dimensional scoring
**Required sections:**
1. **Executive Summary** -- Overall health score (0-100) with letter grade
2. **6-Dimension Scoring** -- Table: Dimension, Score (0-100), Grade, Details
   - Dimensions: Locator Quality, Assertion Specificity, POM Compliance, Test Coverage, Naming Convention, Test Data Management
3. **Critical Issues** -- Issues that must be fixed immediately, with file + line + description
4. **Improvement Recommendations** -- Prioritized list with effort estimate (S/M/L)
5. **Test File Inventory** -- Total files, test cases, per-pyramid-tier breakdown
6. **Detailed Findings** -- Per file: issues found, severity (BLOCKER/WARNING/INFO), suggested fix

**ShopFlow example must show:** Overall score 62/100 (C), with Locator Quality 45 (Tier 4 heavy), Assertion Specificity 70 (some vague), POM Compliance 55 (assertions in POMs), Test Coverage 80, Naming Convention 65, Test Data 60 (some hardcoded).

### TMPL-10: CLAUDE.md (Enhanced)
**Source:** Existing qa-agent-gsd/CLAUDE.md + CONTEXT.md enhancement decisions
**Required sections (preserving existing + adding new):**

**EXISTING (preserved verbatim from current CLAUDE.md):**
1. Framework Detection
2. Testing Pyramid (with distribution percentages)
3. Locator Strategy (Tier 1-4 with framework examples)
4. Page Object Model Rules (6 rules + POM file structure)
5. Test Spec Rules (test case requirements + assertion examples)
6. Naming Conventions (table with patterns)
7. Repo Structure (recommended tree)
8. Test Data Rules
9. Analysis Documents (QA_ANALYSIS.md + TEST_INVENTORY.md section requirements)
10. Quality Gates (checklist)

**NEW (per CONTEXT.md locked decisions):**
11. **Agent Pipeline Rules** -- Pipeline: scan -> analyze -> [testid-inject if frontend] -> plan -> generate -> validate -> deliver. Stage transition conditions. Which agent runs at each stage.
12. **Module Boundaries** -- File ownership table: scanner owns SCAN_MANIFEST, analyzer owns QA_ANALYSIS + TEST_INVENTORY + QA_REPO_BLUEPRINT, executor owns test files + POMs, validator owns VALIDATION_REPORT, testid-injector owns TESTID_AUDIT_REPORT + SCAN_MANIFEST, bug-detective owns FAILURE_CLASSIFICATION_REPORT.
13. **Verification Commands** -- Per artifact type: what command/check validates it (e.g., "VALIDATION_REPORT: all 4 layers must show PASS or have unresolved issues documented").
14. **Git Workflow** -- Branch naming: `qa/auto-{project}-{date}`. Commit format: `qa({agent}): {description}`. PR template reference.
15. **Team Settings** -- Max concurrent agents, worktree isolation rules, dependency ordering between agents.
16. **Agent Coordination Rules** -- Read-before-write rules: analyzer MUST read SCAN_MANIFEST before producing QA_ANALYSIS. Executor MUST read TEST_INVENTORY + CLAUDE.md before writing tests. Handoff patterns.
17. **data-testid Convention** -- Naming pattern: `{context}-{description}-{element-type}`. Element type suffix table. Context derivation rules. (Sourced from data-testid-SKILL.md)
</template_section_maps>

<dont_hand_roll>
## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Template format | Custom template syntax | GSD frontmatter + markdown + `{placeholder}` pattern | template.cjs already parses this format; consistency with Phase 1 |
| YAML frontmatter parsing | Custom parser | frontmatter.cjs from Phase 1 | Already built and tested in bin/lib/frontmatter.cjs |
| Template selection logic | New selection engine | cmdTemplateSelect from template.cjs | Already handles heuristic-based template selection |
| Quality gate checklists | Ad-hoc validation | Copy quality gate pattern from each SKILL.md | SKILL.md files define the exact checklist per artifact type |
| Section definitions | Invent section names | Cross-reference SKILL.md + specs for each template | Authoritative sources already define what each artifact contains |
| Test ID naming convention | Invent new convention | data-testid-SKILL.md naming rules | 15KB of battle-tested convention already documented |

**Key insight:** Nearly 100% of the section requirements for these templates are already defined in existing project documents (SKILL.md files, specs, data-testid-SKILL.md). The template creation task is primarily SYNTHESIS -- combining and formatting existing definitions into the GSD template pattern -- not INVENTION.
</dont_hand_roll>

<common_pitfalls>
## Common Pitfalls

### Pitfall 1: Templates That Are Too Abstract
**What goes wrong:** Templates with placeholder text like `[Insert architecture overview here]` give agents no guidance on depth, format, or quality expectations.
**Why it happens:** Template author focuses on section headers without worked examples.
**How to avoid:** Every template MUST have a fully worked ShopFlow example section showing 200+ lines of filled content. The example IS the specification.
**Warning signs:** Template has fewer than 150 lines total, no example section, or example section uses generic values.

### Pitfall 2: Inconsistent Section Names Between Templates and SKILL.md
**What goes wrong:** Template says "Risk Assessment" but SKILL.md says "Risk Analysis" -- agents can't match template to skill definition.
**Why it happens:** Template author paraphrases instead of using exact section names from source documents.
**How to avoid:** Use the EXACT section names from the SKILL.md and spec files documented in the Template Section Maps above. Cross-verify every section name against the source.
**Warning signs:** Section names in template don't match any SKILL.md or spec file verbatim.

### Pitfall 3: CLAUDE.md That Doesn't Reference Templates
**What goes wrong:** CLAUDE.md defines standards but agents don't know which template to use for which artifact.
**Why it happens:** CLAUDE.md and templates are created independently without cross-referencing.
**How to avoid:** CLAUDE.md's Module Boundaries section must explicitly state which template each agent uses. Add a "Templates" section linking artifact names to template file paths.
**Warning signs:** Agent code references an artifact type not mentioned in CLAUDE.md, or CLAUDE.md mentions an artifact without pointing to its template.

### Pitfall 4: Missing Agent Ownership in Module Boundaries
**What goes wrong:** Two agents produce conflicting artifacts, or an artifact has no producer defined.
**Why it happens:** Module boundary table doesn't cover all 7 agent types or all artifact types.
**How to avoid:** Verify the module boundary table in CLAUDE.md covers ALL agents (scanner, analyzer, planner, executor, validator, testid-injector, bug-detective) and ALL artifacts (10 templates + test files + POMs + fixtures).
**Warning signs:** An agent is listed in REQUIREMENTS.md but missing from the module boundary table.

### Pitfall 5: ShopFlow Example That Doesn't Cross-Reference
**What goes wrong:** QA_ANALYSIS.md example identifies `priceCalculator.ts` as a top target, but TEST_INVENTORY.md example doesn't include tests for it.
**Why it happens:** Templates are written in isolation without checking cross-template consistency.
**How to avoid:** Maintain a ShopFlow entity map and verify all templates reference the same files, endpoints, and business logic. The test inventory tests should map to the analysis targets.
**Warning signs:** Entity mentioned in one template (file path, endpoint, function) doesn't appear in any other template.

### Pitfall 6: Frontmatter Schema Misalignment with template.cjs
**What goes wrong:** Templates have frontmatter that template.cjs can't parse, or frontmatter fields that no code reads.
**Why it happens:** Frontmatter designed without checking what cmdTemplateSelect and cmdTemplateFill expect.
**How to avoid:** Check template.cjs source: it looks for task count, decision mentions, and file mentions. Frontmatter needs to be valid YAML. The `reconstructFrontmatter` function from frontmatter.cjs must be able to round-trip it.
**Warning signs:** Running frontmatter.cjs parse on a template produces errors.
</common_pitfalls>

<code_examples>
## Code Examples

### Template Frontmatter Pattern
```yaml
# Source: GSD template pattern analysis (verification-report.md, summary-standard.md)
---
template_name: qa-analysis
version: "1.0"
artifact_type: analysis
produces: QA_ANALYSIS.md
producer_agent: qa-analyzer
consumer_agents:
  - qa-planner
  - qa-executor
required_sections:
  - architecture-overview
  - external-dependencies
  - risk-assessment
  - top-10-unit-targets
  - api-contract-targets
  - recommended-testing-pyramid
example_domain: shopflow
---
```

### ShopFlow Example: QA_ANALYSIS.md Architecture Overview Section
```markdown
## Architecture Overview

| Property | Value |
|----------|-------|
| System Type | REST API (monolith) |
| Language | TypeScript 5.3 |
| Runtime | Node.js 20 LTS |
| Framework | Express 4.18 |
| Database | PostgreSQL 15 via Prisma 5.7 |
| Authentication | JWT (jsonwebtoken + bcrypt) |
| Payment | Stripe SDK 14.x |
| Deployment | Docker + AWS ECS |

### Entry Points

| Route File | Base Path | Methods | Auth Required |
|------------|-----------|---------|---------------|
| src/routes/api/v1/auth.ts | /api/v1/auth | POST register, POST login, POST refresh, POST logout | No (register/login), Yes (refresh/logout) |
| src/routes/api/v1/products.ts | /api/v1/products | GET list, GET :id, POST create, PUT :id, DELETE :id | No (GET), Yes (POST/PUT/DELETE) |
| src/routes/api/v1/orders.ts | /api/v1/orders | GET list, GET :id, POST create, PATCH :id/status | Yes (all) |
| src/routes/api/v1/payments.ts | /api/v1/payments | POST charge, POST refund, POST webhook | Yes (charge/refund), No (webhook) |

### Internal Layers

```
src/
  routes/       → HTTP routing, input validation
  controllers/  → Request/response handling, calls services
  services/     → Business logic, calls models
  models/       → Prisma schema + custom methods
  middleware/   → Auth (JWT verify), rate limiting, error handler
  utils/        → Price calculator, validators, date helpers
```
```

### ShopFlow Example: TEST_INVENTORY.md Unit Test Entry
```markdown
### UT-PRICE-001: Calculate Order Total with Multiple Items
- **Target:** `src/utils/priceCalculator.ts:calculateOrderTotal`
- **What to validate:** Correctly sums line items with quantity multiplication
- **Inputs:** `[{sku: 'WIDGET-001', qty: 3, unitPrice: 29.99}, {sku: 'GADGET-002', qty: 1, unitPrice: 149.50}]`
- **Mocks:** None (pure function)
- **Expected outcome:** Returns `239.47` (29.99 * 3 + 149.50)
- **Priority:** P0

### UT-PRICE-002: Calculate Order Total with Discount Code
- **Target:** `src/utils/priceCalculator.ts:applyDiscount`
- **What to validate:** Applies percentage discount correctly, rounds to 2 decimal places
- **Inputs:** `{subtotal: 239.47, discountCode: 'SAVE10', discountPercent: 10}`
- **Mocks:** None (pure function)
- **Expected outcome:** Returns `215.52` (239.47 * 0.90, rounded)
- **Priority:** P1

### UT-AUTH-001: Hash Password with bcrypt
- **Target:** `src/services/authService.ts:hashPassword`
- **What to validate:** Produces a bcrypt hash that validates against the original password
- **Inputs:** `'SecureP@ss123!'`
- **Mocks:** None
- **Expected outcome:** `bcrypt.compare('SecureP@ss123!', result)` returns `true`; result starts with `$2b$`
- **Priority:** P0
```

### ShopFlow Example: TESTID_AUDIT_REPORT.md File Detail
```markdown
### LoginPage.tsx -- LoginPage Component

| Line | Element | Current Selector | Proposed data-testid | Priority |
|------|---------|-----------------|----------------------|----------|
| 18 | `<form>` | `className="login-form"` | `login-form` | P0 |
| 22 | `<input type="email">` | `name="email"` | `login-email-input` | P0 |
| 28 | `<input type="password">` | `name="password"` | `login-password-input` | P0 |
| 34 | `<button type="submit">` | `className="btn-primary"` | `login-submit-btn` | P0 |
| 40 | `<a href="/forgot-password">` | none | `login-forgot-password-link` | P1 |
| 45 | `<a href="/register">` | none | `login-register-link` | P1 |
| 50 | `<div className="error">` | `className="error-message"` | `login-error-alert` | P1 |
| 55 | `<img>` | `className="logo"` | `login-logo-img` | P2 |
```

### CLAUDE.md: Module Boundaries Table Pattern
```markdown
## Module Boundaries

| Agent | Reads | Produces | Template |
|-------|-------|----------|----------|
| qa-scanner | repo source files | SCAN_MANIFEST.md | templates/scan-manifest.md |
| qa-analyzer | SCAN_MANIFEST.md | QA_ANALYSIS.md, TEST_INVENTORY.md, QA_REPO_BLUEPRINT.md | templates/qa-analysis.md, templates/test-inventory.md, templates/qa-repo-blueprint.md |
| qa-planner | TEST_INVENTORY.md, QA_ANALYSIS.md | Generation plan (internal) | -- |
| qa-executor | TEST_INVENTORY.md, CLAUDE.md | test files, POMs, fixtures, configs | templates (qa-template-engine patterns) |
| qa-validator | generated test files | VALIDATION_REPORT.md | templates/validation-report.md |
| qa-testid-injector | repo source files | SCAN_MANIFEST.md, TESTID_AUDIT_REPORT.md, modified source files | templates/scan-manifest.md, templates/testid-audit-report.md |
| qa-bug-detective | test execution results | FAILURE_CLASSIFICATION_REPORT.md | templates/failure-classification.md |

**Rule:** An agent MUST NOT produce artifacts assigned to another agent. An agent MUST read all artifacts listed in its "Reads" column before producing output.
```

### CLAUDE.md: Agent Pipeline Rules Pattern
```markdown
## Agent Pipeline

### Option 1: Dev-Only Repo
```
scan -> analyze -> [testid-inject if frontend] -> plan -> generate -> validate -> deliver
```

### Stage Transitions
| From | To | Condition |
|------|----|-----------|
| scan | analyze | SCAN_MANIFEST.md exists and has > 0 testable surfaces |
| analyze | testid-inject | QA_ANALYSIS.md exists AND frontend components detected |
| analyze | plan | QA_ANALYSIS.md + TEST_INVENTORY.md exist (skip testid-inject if no frontend) |
| plan | generate | Generation plan approved (or auto-approved in auto-advance mode) |
| generate | validate | All planned test files exist on disk |
| validate | deliver | VALIDATION_REPORT.md shows PASS or max fix loops exhausted |
```
</code_examples>

<sota_updates>
## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Flat markdown checklists for QA | Structured templates with frontmatter + worked examples | 2025 (GSD pattern) | Agents produce dramatically better output when templates show full examples |
| Single CLAUDE.md with just standards | CLAUDE.md as agent coordination hub + QA standards | 2025-2026 | Multi-agent systems need ownership tables and handoff rules, not just coding standards |
| Generic test naming | Convention-based IDs (UT-MODULE-NNN, API-RESOURCE-NNN) | Established pattern | Traceability from test to requirement to code |
| Manual test-ID assignment | data-testid convention with automated injection | 2024-2025 | Pipeline automation requires stable selectors before test generation |

**Current best practices for QA artifact templates:**
- Frontmatter metadata enables programmatic template operations
- Worked examples (not just placeholders) are the strongest form of specification
- Cross-template consistency (same domain, same entities) builds agent understanding
- Quality gates as checklists prevent incomplete artifacts from entering the pipeline
</sota_updates>

<validation_architecture>
## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual validation (markdown content) + frontmatter.cjs parsing |
| Config file | None -- templates are markdown, validated by structure checks |
| Quick run command | `node bin/lib/frontmatter.cjs` parse on each template to verify valid YAML |
| Full suite command | Verify all 9 templates exist in templates/, each has valid frontmatter, CLAUDE.md exists at root with all required sections |

### Phase Requirements to Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| TMPL-01 | QA_ANALYSIS.md template exists with 6 required sections | structure check | `node -e "const f=require('fs');const c=f.readFileSync('templates/qa-analysis.md','utf8');['Architecture Overview','External Dependencies','Risk Assessment','Top 10','API','Testing Pyramid'].forEach(s=>{if(!c.includes(s))throw new Error('Missing: '+s)});console.log('PASS')"` | Wave 0 |
| TMPL-02 | TEST_INVENTORY.md template exists with pyramid tiers | structure check | `node -e "const f=require('fs');const c=f.readFileSync('templates/test-inventory.md','utf8');['Unit Tests','Integration','API Tests','E2E'].forEach(s=>{if(!c.includes(s))throw new Error('Missing: '+s)});console.log('PASS')"` | Wave 0 |
| TMPL-03 | QA_REPO_BLUEPRINT.md template exists with 7 sections | structure check | Similar pattern: check for Folder Structure, Recommended Stack, Config Files, CI/CD, Definition of Done | Wave 0 |
| TMPL-04 | VALIDATION_REPORT.md template exists with 4 layers | structure check | Check for Syntax, Structure, Dependencies, Logic, Confidence Level | Wave 0 |
| TMPL-05 | SCAN_MANIFEST.md template exists with file list + detection | structure check | Check for Project Detection, File List, Testable Surfaces | Wave 0 |
| TMPL-06 | FAILURE_CLASSIFICATION_REPORT.md template with 4 categories | structure check | Check for APPLICATION BUG, TEST CODE ERROR, ENVIRONMENT ISSUE, INCONCLUSIVE | Wave 0 |
| TMPL-07 | TESTID_AUDIT_REPORT.md template with coverage score | structure check | Check for Coverage Score, File Details, Naming Convention | Wave 0 |
| TMPL-08 | GAP_ANALYSIS.md template with coverage map | structure check | Check for Coverage Map, Missing Tests, Broken Tests, Quality Assessment | Wave 0 |
| TMPL-09 | QA_AUDIT_REPORT.md template with 6-dimension scoring | structure check | Check for 6-Dimension Scoring, Critical Issues, Recommendations | Wave 0 |
| TMPL-10 | CLAUDE.md at root with all sections | structure check | Check for existing sections (Framework Detection through Quality Gates) + new sections (Agent Pipeline, Module Boundaries, Verification Commands, Git Workflow, Team Settings, Agent Coordination) | Wave 0 |

### Sampling Rate
- **Per task commit:** Verify template has valid frontmatter and required section headers
- **Per wave merge:** Run all structure checks across all templates
- **Phase gate:** All 10 artifacts exist, all structure checks pass, cross-template ShopFlow consistency verified

### Wave 0 Gaps
- [ ] `templates/` directory -- must be created (does not exist yet)
- [ ] All 9 template files -- none exist yet
- [ ] CLAUDE.md at project root -- does not exist yet (only exists at qa-agent-gsd/qa-agent-gsd/CLAUDE.md)
</validation_architecture>

<open_questions>
## Open Questions

1. **How should template.cjs interact with QA templates?**
   - What we know: template.cjs currently supports `summary`, `plan`, and `verification` template types via cmdTemplateFill. It has cmdTemplateSelect that analyzes plan files to choose summary templates.
   - What's unclear: Should template.cjs be extended to support QA artifact template types (qa-analysis, test-inventory, etc.), or will agents read templates directly via file read?
   - Recommendation: For Phase 2, agents will read templates directly as markdown files. template.cjs extension for QA types is a Phase 3+ concern when agents are implemented. Templates just need to exist at `templates/` with valid content.

2. **Should CLAUDE.md reference the original specs or fully subsume them?**
   - What we know: Spec files (qa-analyze.md, create-tests.md, update-tests.md) exist at qa-agent-gsd/specs/ and define workflow milestones. CLAUDE.md currently references "Analysis Documents" section.
   - What's unclear: Whether enhanced CLAUDE.md should duplicate all spec content or just reference spec files.
   - Recommendation: CLAUDE.md should contain the STANDARDS (what quality looks like) and the MODULE BOUNDARIES (who produces what). Spec files contain WORKFLOW (step-by-step process) and remain separate. CLAUDE.md references specs but doesn't duplicate them.

3. **Should templates include a "Changelog" section?**
   - What we know: This is at Claude's discretion per CONTEXT.md.
   - What's unclear: Whether agents would populate a changelog section.
   - Recommendation: Do NOT include a changelog section. Templates define the output format; versioning is handled by git. Adding unused sections dilutes template quality.
</open_questions>

<sources>
## Sources

### Primary (HIGH confidence)
- `.claude/skills/qa-repo-analyzer/SKILL.md` -- QA_ANALYSIS.md, TEST_INVENTORY.md, QA_REPO_BLUEPRINT.md section definitions
- `.claude/skills/qa-self-validator/SKILL.md` -- VALIDATION_REPORT.md section definitions
- `.claude/skills/qa-bug-detective/SKILL.md` -- FAILURE_CLASSIFICATION_REPORT.md section definitions
- `.claude/skills/qa-testid-injector/SKILL.md` -- SCAN_MANIFEST.md, TESTID_AUDIT_REPORT.md section definitions
- `.claude/skills/qa-template-engine/SKILL.md` -- Test template patterns, POM generation rules
- `.claude/skills/qa-workflow-documenter/SKILL.md` -- Workflow documentation patterns
- `data-testid-SKILL.md` -- Comprehensive test-ID naming convention (15KB)
- `qa-agent-gsd/qa-agent-gsd/CLAUDE.md` -- Existing QA standards (6.9KB) to be preserved
- `qa-agent-gsd/qa-agent-gsd/specs/qa-analyze.md` -- Analysis workflow spec
- `qa-agent-gsd/qa-agent-gsd/specs/create-tests.md` -- Test creation spec
- `qa-agent-gsd/qa-agent-gsd/specs/update-tests.md` -- Test update spec
- `bin/lib/template.cjs` -- Template engine source code
- `C:/Users/mrrai/.claude/get-shit-done/templates/` -- GSD template pattern reference (8 templates studied)

### Secondary (MEDIUM confidence)
- `.planning/REQUIREMENTS.md` -- TMPL-01 through TMPL-10 requirement definitions
- `.planning/ROADMAP.md` -- Phase 2 success criteria
- `.planning/phases/02-qa-standards-and-templates/02-CONTEXT.md` -- Locked decisions

### Tertiary (LOW confidence)
- None -- all findings verified against project source files
</sources>

<metadata>
## Metadata

**Research scope:**
- Core technology: Markdown template design, YAML frontmatter, multi-agent QA system documentation
- Ecosystem: GSD template pattern, frontmatter.cjs, template.cjs from Phase 1
- Patterns: Template structure (frontmatter + sections + example + guidelines), worked example design, cross-template consistency
- Pitfalls: Abstract templates, section name mismatches, missing agent ownership, cross-template inconsistency

**Confidence breakdown:**
- Standard stack: HIGH -- all patterns verified from existing GSD templates and Phase 1 code
- Architecture: HIGH -- template directory structure and CLAUDE.md enhancement layers directly derived from CONTEXT.md decisions and existing codebase
- Template section maps: HIGH -- every section cross-referenced against SKILL.md files, spec files, and data-testid-SKILL.md
- Pitfalls: HIGH -- based on analysis of what makes GSD templates effective vs what fails
- Code examples: HIGH -- derived directly from SKILL.md content and existing CLAUDE.md

**Research date:** 2026-03-18
**Valid until:** 2026-04-18 (30 days -- template pattern is stable, no external dependencies)
</metadata>

---

*Phase: 02-qa-standards-and-templates*
*Research completed: 2026-03-18*
*Ready for planning: yes*
