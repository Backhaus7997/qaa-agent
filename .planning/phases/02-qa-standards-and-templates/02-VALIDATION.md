---
phase: 2
slug: qa-standards-and-templates
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-18
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Manual validation (markdown content) + frontmatter.cjs parsing |
| **Config file** | none — markdown templates, no test runner |
| **Quick run command** | `node -e "const fs=require('fs'); console.log(fs.readdirSync('templates').length + ' templates')"` |
| **Full suite command** | `node -e "const fs=require('fs'),p=require('path'); const t=fs.readdirSync('templates').filter(f=>f.endsWith('.md')); t.forEach(f=>{const c=fs.readFileSync(p.join('templates',f),'utf8'); console.log(f+': '+c.split('\\n').length+' lines, frontmatter:'+(c.startsWith('---')?'YES':'NO'))})"` |
| **Estimated runtime** | ~1 second |

---

## Sampling Rate

- **After every task commit:** Run quick run command
- **After every plan wave:** Run full suite command
- **Before `/gsd:verify-work`:** Full suite must show all 9 templates + CLAUDE.md
- **Max feedback latency:** 1 second

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 02-01-01 | 01 | 1 | TMPL-05 | unit | `test -f templates/scan-manifest.md && node -e "const c=require('fs').readFileSync('templates/scan-manifest.md','utf8'); console.log(c.includes('## Summary') && c.includes('## File Tree') && c.includes('## Testable Surfaces'))"` | ❌ W0 | ⬜ pending |
| 02-01-02 | 01 | 1 | TMPL-01 | unit | `test -f templates/qa-analysis.md && node -e "const c=require('fs').readFileSync('templates/qa-analysis.md','utf8'); console.log(c.includes('## Architecture Overview') && c.includes('## Risk Assessment') && c.includes('## Top 10 Unit Test Targets'))"` | ❌ W0 | ⬜ pending |
| 02-01-03 | 01 | 1 | TMPL-02 | unit | `test -f templates/test-inventory.md && node -e "const c=require('fs').readFileSync('templates/test-inventory.md','utf8'); console.log(c.includes('## Unit Tests') && c.includes('## API Tests') && c.includes('## E2E Smoke Tests'))"` | ❌ W0 | ⬜ pending |
| 02-02-01 | 02 | 1 | TMPL-03 | unit | `test -f templates/qa-repo-blueprint.md && node -e "const c=require('fs').readFileSync('templates/qa-repo-blueprint.md','utf8'); console.log(c.includes('## Recommended Stack') && c.includes('## Folder Structure'))"` | ❌ W0 | ⬜ pending |
| 02-02-02 | 02 | 1 | TMPL-04 | unit | `test -f templates/validation-report.md && node -e "const c=require('fs').readFileSync('templates/validation-report.md','utf8'); console.log(c.includes('## Summary') && c.includes('Layer') && c.includes('Confidence'))"` | ❌ W0 | ⬜ pending |
| 02-02-03 | 02 | 1 | TMPL-06 | unit | `test -f templates/failure-classification.md && node -e "const c=require('fs').readFileSync('templates/failure-classification.md','utf8'); console.log(c.includes('APPLICATION BUG') && c.includes('TEST CODE ERROR') && c.includes('Confidence'))"` | ❌ W0 | ⬜ pending |
| 02-03-01 | 03 | 1 | TMPL-07 | unit | `test -f templates/testid-audit-report.md && node -e "const c=require('fs').readFileSync('templates/testid-audit-report.md','utf8'); console.log(c.includes('## Coverage Score') && c.includes('data-testid'))"` | ❌ W0 | ⬜ pending |
| 02-03-02 | 03 | 1 | TMPL-08 | unit | `test -f templates/gap-analysis.md && node -e "const c=require('fs').readFileSync('templates/gap-analysis.md','utf8'); console.log(c.includes('## Coverage Map') && c.includes('## Missing Test Cases'))"` | ❌ W0 | ⬜ pending |
| 02-03-03 | 03 | 1 | TMPL-09 | unit | `test -f templates/qa-audit-report.md && node -e "const c=require('fs').readFileSync('templates/qa-audit-report.md','utf8'); console.log(c.includes('## Scores') && c.includes('Locators') && c.includes('Assertions'))"` | ❌ W0 | ⬜ pending |
| 02-04-01 | 04 | 2 | TMPL-10 | unit | `test -f CLAUDE.md && node -e "const c=require('fs').readFileSync('CLAUDE.md','utf8'); console.log(c.includes('## Testing Pyramid') && c.includes('## Module Boundaries') && c.includes('## Agent Pipeline'))"` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `templates/` directory exists
- [ ] CLAUDE.md at project root

*Wave 0 creates the files that subsequent waves validate.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Template examples are realistic | All TMPL-* | Automated checks verify section presence, not content quality | Review 2-3 templates for realistic ShopFlow examples |
| CLAUDE.md is comprehensive | TMPL-10 | Standards completeness requires human judgment | Review all sections for coverage |

---

## Validation Sign-Off

- [ ] All tasks have automated verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 1s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
