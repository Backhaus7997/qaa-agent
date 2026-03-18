---
phase: 1
slug: core-infrastructure
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-18
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | node --check (syntax validation for .cjs files) |
| **Config file** | none — no test framework, CLI validation only |
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
| 01-01-01 | 01 | 1 | INFRA-05 | unit | `node --check bin/lib/frontmatter.cjs` | ❌ W0 | ⬜ pending |
| 01-01-02 | 01 | 1 | INFRA-02 | unit | `node --check bin/lib/model-profiles.cjs` | ❌ W0 | ⬜ pending |
| 01-01-03 | 01 | 1 | INFRA-03 | unit | `node --check bin/lib/config.cjs` | ❌ W0 | ⬜ pending |
| 01-01-04 | 01 | 1 | INFRA-04 | unit | `node --check bin/lib/state.cjs` | ❌ W0 | ⬜ pending |
| 01-02-01 | 02 | 2 | INFRA-01 | integration | `node bin/qaa-tools.cjs init qa-start "test"` | ❌ W0 | ⬜ pending |
| 01-02-02 | 02 | 2 | INFRA-06 | integration | `node bin/qaa-tools.cjs commit --dry-run` | ❌ W0 | ⬜ pending |
| 01-02-03 | 02 | 2 | INFRA-07 | integration | `node bin/qaa-tools.cjs init qa-start "test" | jq .` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `bin/qaa-tools.cjs` — main CLI entry point (must exist before any validation)
- [ ] `bin/lib/` directory — all 12 library modules

*Wave 0 creates the files that subsequent waves validate.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Model profile resolution | INFRA-02 | Requires inspecting JSON output for correct model names | Run `node bin/qaa-tools.cjs init qa-start "test"` and verify model fields match quality profile |
| State pipeline tracking | INFRA-04 | Requires verifying QA_STATE.md content after state transitions | Run state commands and check file content for pipeline stages |

---

## Validation Sign-Off

- [ ] All tasks have automated verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 2s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
