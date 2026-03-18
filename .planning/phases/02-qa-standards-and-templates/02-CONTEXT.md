# Phase 2: QA Standards and Templates - Context

**Gathered:** 2026-03-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Create all 10 QA artifact templates and a comprehensive CLAUDE.md. Templates define the exact sections and format that agents produce when generating QA artifacts. CLAUDE.md is the shared brain — QA standards + agent coordination rules. No agents or workflows — just the documents they reference.

</domain>

<decisions>
## Implementation Decisions

### Template Depth
- Full worked examples with real values (200+ lines each, like GSD templates)
- Include section descriptions, guidelines, anti-patterns, and filled example sections
- Agents produce better output when templates show exactly what "good" looks like
- All templates use the same example domain: e-commerce API (ShopFlow-style: products, orders, payments, auth)
- Consistent domain across all templates so agents understand the pattern cohesively

### CLAUDE.md Strategy
- Move existing qa-agent-gsd/CLAUDE.md to project root and enhance significantly
- Keep ALL existing QA standards (pyramid, locators, POM, assertions, naming, quality gates)
- Add agent pipeline rules: which agent owns which artifacts, pipeline stage transitions, handoff patterns, commit message conventions
- Add module boundaries: file ownership table (scanner → SCAN_MANIFEST, analyzer → QA_ANALYSIS, executor → test files, etc.)
- Add verification commands for each artifact type
- Add git workflow: branch naming (qa/auto-{project}-{date}), commit format, PR template
- Add team settings: max agents, worktree isolation, dependency ordering
- Add agent coordination rules: how agents hand off, what to read before producing, quality gates per artifact
- Full GSD-style comprehensive CLAUDE.md — the most complete version

### Template Location
- Templates in `templates/` at project root (mirrors GSD pattern)
- template.cjs (from Phase 1) uses cmdTemplateSelect + cmdTemplateFill to find/fill them
- File names match artifact names: `qa-analysis.md`, `test-inventory.md`, `scan-manifest.md`, etc.

### Claude's Discretion
- Exact frontmatter schema for each template
- Section ordering within templates
- Level of detail in anti-pattern sections
- Whether to include a "changelog" section in templates

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Existing QA Standards
- `qa-agent-gsd/CLAUDE.md` — Current QA standards (6.9KB) to be moved and enhanced
- `qa-agent-gsd/specs/qa-analyze.md` — Spec for analysis workflow (defines QA_ANALYSIS.md and TEST_INVENTORY.md sections)
- `qa-agent-gsd/specs/create-tests.md` — Spec for test creation (defines POM and test file structure)
- `qa-agent-gsd/specs/update-tests.md` — Spec for test improvement (defines TEST_AUDIT.md and UPDATE_REPORT.md)

### Skill Definitions (define what agents produce)
- `.claude/skills/qa-repo-analyzer/SKILL.md` — Defines QA_ANALYSIS.md + TEST_INVENTORY.md + QA_REPO_BLUEPRINT.md sections
- `.claude/skills/qa-self-validator/SKILL.md` — Defines VALIDATION_REPORT.md sections
- `.claude/skills/qa-bug-detective/SKILL.md` — Defines FAILURE_CLASSIFICATION_REPORT.md sections
- `.claude/skills/qa-testid-injector/SKILL.md` — Defines SCAN_MANIFEST.md + TESTID_AUDIT_REPORT.md sections
- `.claude/skills/qa-template-engine/SKILL.md` — Defines test template patterns

### GSD Templates (reference for structure patterns)
- `C:/Users/mrrai/.claude/get-shit-done/templates/` — 20+ GSD templates showing the worked-example pattern to replicate

### Original Project Spec (data-testid and detailed QA rules)
- `data-testid-SKILL.md` — Comprehensive test-ID naming convention and injection rules

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `qa-agent-gsd/CLAUDE.md` — 6.9KB of QA standards to be moved/enhanced (testing pyramid, locator hierarchy, POM rules, assertion rules, naming conventions, quality gates)
- 6 SKILL.md files define agent output formats — templates should match these definitions
- `bin/lib/template.cjs` — Template select/fill commands ready to consume templates from `templates/` directory
- `data-testid-SKILL.md` — 15KB of test-ID convention details for TESTID_AUDIT_REPORT.md template

### Established Patterns
- GSD templates use frontmatter + markdown sections + `{placeholder}` syntax for template.cjs filling
- Each GSD template has: header block, structured sections, example content, guidelines section

### Integration Points
- Templates go in `templates/` — template.cjs reads from this directory
- CLAUDE.md goes at project root — Claude Code reads it automatically
- Agents reference templates by name via `qaa-tools.cjs template select <type>`

</code_context>

<specifics>
## Specific Ideas

- E-commerce API example domain: products (CRUD + images + SKU), orders (state machine), payments (Stripe), auth (JWT), inventory (stock reservation)
- ShopFlow from the original spec is the reference — use realistic file paths, endpoint names, and business logic examples
- Every template example should have at least 3-5 filled test cases showing the exact format agents should produce

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-qa-standards-and-templates*
*Context gathered: 2026-03-18*
