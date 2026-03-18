---
phase: 1
slug: core-infrastructure
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-18
---

# Phase 1 -- Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | node --check (syntax validation for .cjs files) |
| **Config file** | none -- no test framework, CLI validation only |
| **Quick run command** | `node bin/qaa-tools.cjs --help` |
| **Full suite command** | `node bin/qaa-tools.cjs init qa-start "test" && node bin/qaa-tools.cjs config-get mode && node bin/qaa-tools.cjs state json` |
| **Estimated runtime** | ~2 seconds |

---

## Sampling Rate

- **After every task commit:** Run `node bin/qaa-tools.cjs --help`
- **After every plan wave:** Run full suite command
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 2 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 01-01-01 | 01 | 1 | INFRA-05 | unit | `node --check bin/lib/frontmatter.cjs` | W0 | pending |
| 01-01-02 | 01 | 1 | INFRA-02 | unit | `node --check bin/lib/model-profiles.cjs` | W0 | pending |
| 01-01-03 | 01 | 1 | INFRA-03 | unit | `node --check bin/lib/config.cjs` | W0 | pending |
| 01-01-04 | 01 | 1 | INFRA-04 | unit | `node --check bin/lib/state.cjs` | W0 | pending |
| 01-02-01 | 02 | 2 | INFRA-03 | unit | `node --check bin/lib/config.cjs && node -e "const c = require('./bin/lib/config.cjs'); console.log(typeof c.cmdConfigEnsureSection, typeof c.cmdConfigSet, typeof c.cmdConfigGet, typeof c.cmdConfigSetModelProfile)"` | W0 | pending |
| 01-02-02 | 02 | 2 | INFRA-04 | unit | `node --check bin/lib/state.cjs && node -e "const s = require('./bin/lib/state.cjs'); console.log(typeof s.writeStateMd, typeof s.cmdStateJson, typeof s.stateExtractField, typeof s.cmdStateAdvancePlan)"` | W0 | pending |
| 01-03-01 | 03 | 3 | INFRA-01 | unit | `node --check bin/lib/roadmap.cjs && node -e "const r = require('./bin/lib/roadmap.cjs'); console.log(typeof r.cmdRoadmapGetPhase, typeof r.cmdRoadmapAnalyze, typeof r.cmdRoadmapUpdatePlanProgress)"` | W0 | pending |
| 01-03-02 | 03 | 3 | INFRA-01 | unit | `node --check bin/lib/template.cjs && node -e "const t = require('./bin/lib/template.cjs'); console.log(typeof t.cmdTemplateSelect, typeof t.cmdTemplateFill)"` | W0 | pending |
| 01-03-03 | 03 | 3 | INFRA-01 | unit | `node --check bin/lib/milestone.cjs && node -e "const m = require('./bin/lib/milestone.cjs'); console.log(typeof m.cmdRequirementsMarkComplete, typeof m.cmdMilestoneComplete)"` | W0 | pending |
| 01-04-01 | 04 | 4 | INFRA-06 | unit | `node --check bin/lib/phase.cjs && node -e "const p = require('./bin/lib/phase.cjs'); console.log(Object.keys(p).join(', '))"` | W0 | pending |
| 01-04-02 | 04 | 4 | INFRA-06 | unit | `node --check bin/lib/commands.cjs && node -e "const c = require('./bin/lib/commands.cjs'); console.log(typeof c.cmdCommit, typeof c.cmdResolveModel, typeof c.cmdScaffold, typeof c.cmdWebsearch)"` | W0 | pending |
| 01-05-01 | 05 | 5 | INFRA-01 | unit | `node --check bin/lib/verify.cjs && node -e "const v = require('./bin/lib/verify.cjs'); console.log(Object.keys(v).join(', '))"` | W0 | pending |
| 01-05-02 | 05 | 5 | INFRA-07 | unit | `node --check bin/lib/init.cjs && node -e "const i = require('./bin/lib/init.cjs'); console.log(Object.keys(i).join(', '))"` | W0 | pending |
| 01-05-03 | 05 | 5 | INFRA-01 | integration | `node --check bin/qaa-tools.cjs && node bin/qaa-tools.cjs resolve-model qaa-executor --raw 2>/dev/null; echo "exit:$?"` | W0 | pending |

*Status: pending / green / red / flaky*

---

## Wave 0 Requirements

- [ ] `bin/qaa-tools.cjs` -- main CLI entry point (must exist before any validation)
- [ ] `bin/lib/` directory -- all 12 library modules

*Wave 0 creates the files that subsequent waves validate.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Model profile resolution | INFRA-02 | Requires inspecting JSON output for correct model names | Run `node bin/qaa-tools.cjs init qa-start "test"` and verify model fields match quality profile |
| State pipeline tracking | INFRA-04 | Requires verifying QA_STATE.md content after state transitions | Run state commands and check file content for pipeline stages (scan_status, analyze_status, generate_status, validate_status, deliver_status) |

---

## Validation Sign-Off

- [ ] All tasks have automated verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 2s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
