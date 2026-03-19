---
phase: 5
slug: workflow-orchestration
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-19
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | node CLI validation + markdown structural checks |
| **Config file** | none |
| **Quick run command** | `node bin/qaa-tools.cjs init qa-start 2>&1 | node -e "JSON.parse(require('fs').readFileSync('/dev/stdin','utf8'))"` |
| **Full suite command** | Quick run + `test -f agents/qa-pipeline-orchestrator.md` |
| **Estimated runtime** | ~2 seconds |

---

## Sampling Rate

- **After every task commit:** Run quick run command
- **After every plan wave:** Run full suite command
- **Max feedback latency:** 2 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 01 | 1 | FLOW-05 | unit | `node bin/qaa-tools.cjs init qa-start 2>&1 \| node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); const req=['option','scanner_model','pipeline','dev_repo_path']; const m=req.filter(k=>!(k in d)); process.exit(m.length?1:0)"` | ❌ W0 | ⬜ pending |
| 05-01-02 | 01 | 1 | FLOW-05 | integration | `node bin/qaa-tools.cjs init qa-start 2>&1 \| node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); console.log('option='+d.option+' models='+(d.scanner_model?'YES':'NO'))"` | ❌ W0 | ⬜ pending |
| 05-02-01 | 02 | 2 | FLOW-01,02,03,06,07 | unit | `test -f agents/qa-pipeline-orchestrator.md && node -e "const c=require('fs').readFileSync('agents/qa-pipeline-orchestrator.md','utf8'); const checks=['option_1','option_2','option_3','auto_advance','CHECKPOINT_RETURN','scan_stage','analyze_stage','generate_stage','validate_stage','deliver_stage','maturity_score','sequential']; const m=checks.filter(k=>!c.includes(k)); console.log(m.length?'MISSING:'+m.join(','):'ALL OK'); process.exit(m.length?1:0)"` | ❌ W0 | ⬜ pending |
| 05-02-02 | 02 | 2 | FLOW-04 | unit | `test -f agents/qa-pipeline-orchestrator.md && node -e "const c=require('fs').readFileSync('agents/qa-pipeline-orchestrator.md','utf8'); const s=['spawn_scanner','spawn_analyzer','spawn_planner','spawn_executor','spawn_validator','spawn_bug_detective']; const m=s.filter(k=>!c.includes(k)); console.log(m.length?'MISSING:'+m.join(','):'ALL OK'); process.exit(m.length?1:0)"` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `bin/lib/init.cjs` updated with cmdInitQaStart
- [ ] `agents/qa-pipeline-orchestrator.md` created

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Option routing correctness | FLOW-01,02,03 | Requires reading orchestrator logic for 3 paths | Review stage sequences for each option in orchestrator .md |
| Auto-advance safe/risky distinction | FLOW-06 | Requires understanding checkpoint classification | Verify scanner/analyzer = safe, validator = risky in orchestrator |
| Checkpoint resume with fresh agent | FLOW-07 | Architectural pattern, not runtime-testable | Review CHECKPOINT_RETURN handling in orchestrator |

---

## Validation Sign-Off

- [ ] All tasks have automated verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 2s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
