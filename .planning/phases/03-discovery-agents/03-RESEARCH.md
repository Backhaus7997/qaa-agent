# Phase 3: Discovery Agents - Research

**Researched:** 2026-03-19
**Domain:** Markdown workflow agent files for repo scanning and analysis
**Confidence:** HIGH

## Summary

Phase 3 creates two agent workflow files -- `agents/qaa-scanner.md` and `agents/qaa-analyzer.md` -- that will be spawned as subagents via `Task(subagent_type=...)` by the orchestrator in Phase 5. These are not code modules but markdown instruction files that a Claude Code subagent reads and follows. The GSD system already establishes the exact pattern: `<purpose>`, `<process>` with numbered steps, `<files_to_read>` / `<required_reading>`, `<output>`, and `<quality_gate>` / `<success_criteria>` XML-tagged sections. The three templates these agents must produce output matching (scan-manifest.md, qa-analysis.md, test-inventory.md) are already complete and define exact section requirements, field types, and worked examples.

The scanner agent reads a DEV repository's source files, detects the technology stack (10+ frameworks supported), builds an annotated file list, identifies testable surfaces, and writes SCAN_MANIFEST.md. The analyzer agent reads SCAN_MANIFEST.md + CLAUDE.md, produces QA_ANALYSIS.md (architecture, risks, targets, pyramid) and TEST_INVENTORY.md (fully specified test cases with IDs, inputs, outcomes), and optionally QA_REPO_BLUEPRINT.md (for Option 1 dev-only workflows). Both agents use file-based handoff exclusively -- no memory or env-var passing.

**Primary recommendation:** Build each agent .md as a self-contained workflow document following the GSD XML-tag structure, referencing templates via relative paths, and embedding the exact quality gate checklists from the template files into each agent's `<quality_gate>` section.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Agents are markdown workflow files in `agents/` directory at project root (not workflows/)
- Each agent .md follows GSD pattern: `<purpose>`, `<process>` with numbered steps, `<files_to_read>`, `<output>`, `<quality_gate>` checklist
- Spawned via Task(subagent_type='qaa-scanner', model='{scanner_model}') -- same as GSD
- model-profiles.cjs (from Phase 1) resolves the model for each agent type
- Orchestrator passes agent .md via @path reference in Task prompt
- Scanner: Deep scan: file tree + package detection + read source files to map entry points, API endpoints, models/schemas, services, middleware, external integrations
- Scanner: Produces rich SCAN_MANIFEST.md that analyzer can work from without re-reading source
- Scanner: Supports all common stacks: Node.js/Express, Python/FastAPI, .NET/ASP.NET, Java/Spring, Go, Ruby/Rails, PHP/Laravel, React/Next.js, Vue/Nuxt, Angular
- Scanner: Handles DEV repo only -- QA repo analysis is a separate concern (gap-analyzer in later phases)
- Scanner: Detects frontend components: framework (React/Vue/Angular), component files, interactive elements count, flags `has_frontend: true/false` for orchestrator to decide whether to spawn testid-injector
- Scanner: If framework can't be detected or no testable surfaces found: report + ask user (interactive checkpoint before analyzer runs)
- Analyzer: Full spec detail for every test case: ID, target (file:function or METHOD /endpoint), concrete inputs (actual values), explicit expected outcome (exact status/value), priority, mocks needed
- Analyzer: Matches the TEST_INVENTORY.md template format from Phase 2
- Analyzer: Test count is pyramid-driven: depends on repo size/complexity, follows pyramid distribution (60-70% unit, 20-25% API, 10-15% integration, 3-5% E2E)
- Analyzer: Produces interactive "Assumptions + Questions" checkpoint before generating full analysis -- catches misunderstandings early
- Handoff: File-based: scanner writes SCAN_MANIFEST.md to known path, orchestrator passes path to analyzer via `<files_to_read>`
- Handoff: Same pattern as GSD: files as state, fresh 200k context per agent
- Handoff: No content passing through orchestrator -- keeps orchestrator lean
- Error: Scanner: if framework unknown or no testable surfaces, pause and ask user for info (interactive checkpoint)
- Error: Analyzer: if SCAN_MANIFEST is incomplete, note gaps in QA_ANALYSIS.md assumptions section

### Claude's Discretion
- Exact file reading strategy within scanner (breadth-first vs depth-first)
- How to handle monorepos (multiple packages)
- Internal prompt engineering within agent .md files

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| AGENT-01 | qa-scanner agent reads repo, builds file tree, detects framework/stack, produces SCAN_MANIFEST.md | GSD workflow pattern documented, scan-manifest.md template defines exact output format (5 required sections: project-detection, file-list, summary-statistics, testable-surfaces, decision-gate), framework detection patterns catalogued for 10+ stacks |
| AGENT-02 | qa-analyzer agent produces QA_ANALYSIS.md (architecture, risks, top 10 targets, pyramid) and TEST_INVENTORY.md (pyramid-based test cases with IDs and explicit outcomes) | qa-analysis.md template defines 6 required sections with field specifications, test-inventory.md defines 5 sections with mandatory per-test-case fields, quality gate checklists ready to embed, qa-repo-analyzer SKILL.md defines execution steps |
</phase_requirements>

## Standard Stack

### Core
| Component | Location | Purpose | Why Standard |
|-----------|----------|---------|--------------|
| GSD workflow .md pattern | `C:/Users/mrrai/.claude/get-shit-done/workflows/*.md` | Structure template for agent files | Established pattern -- orchestrator already knows how to spawn and parse these |
| model-profiles.cjs | `bin/lib/model-profiles.cjs` | Resolves qaa-scanner and qaa-analyzer model assignments | Already implemented in Phase 1 with quality/balanced/budget mappings |
| qaa-tools.cjs | `bin/qaa-tools.cjs` | CLI agents call for commits, state updates | Already implemented -- agents call `node qaa-tools.cjs commit` etc. |
| Templates | `templates/scan-manifest.md`, `templates/qa-analysis.md`, `templates/test-inventory.md` | Define exact output format | Already implemented in Phase 2 -- agents reference these as their output contract |
| CLAUDE.md | `./CLAUDE.md` | QA standards, module boundaries, quality gates | Already 544 lines with complete agent pipeline rules, read-before-write rules, verification commands |

### Supporting
| Component | Location | Purpose | When to Use |
|-----------|----------|---------|-------------|
| qa-repo-blueprint.md | `templates/qa-repo-blueprint.md` | QA repo structure template | Analyzer produces this for Option 1 (dev-only) workflows |
| qa-repo-analyzer SKILL | `.claude/skills/qa-repo-analyzer/SKILL.md` | Defines analyzer execution steps | Analyzer agent should follow this skill's Step 0-4 pattern |
| qa-testid-injector SKILL | `.claude/skills/qa-testid-injector/SKILL.md` | Defines testid-injector capability | Scanner must output `has_frontend` flag so orchestrator can trigger this skill |

### No External Dependencies
These are markdown instruction files, not code modules. No npm packages, no build steps, no runtime dependencies. The agents rely entirely on Claude Code's built-in tools (Read, Write, Bash, Glob, Grep) and the project's existing `qaa-tools.cjs` CLI.

## Architecture Patterns

### Recommended Project Structure
```
agents/                          # NEW directory -- agent workflow files
  qaa-scanner.md                # Scanner agent workflow
  qaa-analyzer.md               # Analyzer agent workflow
```

The `agents/` directory lives at project root (not `workflows/` -- that is GSD-internal).

### Pattern 1: GSD Workflow .md Structure
**What:** XML-tagged markdown document that a Claude Code subagent reads as its instruction set
**When to use:** For every agent .md file in this project
**Exact sections (derived from studying execute-plan.md and quick.md):**

```markdown
<purpose>
One paragraph stating what this agent does and when it is spawned.
</purpose>

<required_reading>
Files this agent MUST read before any operation.
Lists specific file paths and templates.
</required_reading>

<process>

<step name="step_name" priority="first|normal">
Step description with substeps.

Bash commands for tool usage:
\`\`\`bash
node "bin/qaa-tools.cjs" command args
\`\`\`

Conditional logic documented inline.
</step>

<step name="next_step">
...
</step>

</process>

<output>
What this agent produces (file paths, formats).
</output>

<quality_gate>
Checklist that MUST pass before the agent considers itself done.
- [ ] Check 1
- [ ] Check 2
</quality_gate>

<success_criteria>
Summary of what "done" means for the orchestrator.
</success_criteria>
```

**Key observations from GSD workflows:**
- Steps use `<step name="..." priority="...">` tags within `<process>`
- Steps contain inline bash examples for tool usage
- Conditional logic is documented with `<if condition>` tags or plain text "If X then Y"
- `<required_reading>` lists files with @path syntax for auto-resolution
- Quality gates are checklists with `- [ ]` items
- Success criteria are separate from quality gates -- quality gates are internal checks, success criteria are for the orchestrator

### Pattern 2: Template-Referenced Output
**What:** Agent reads the template file first, then produces output matching its structure exactly
**When to use:** Every agent that produces a QA artifact

The agent .md file should instruct the subagent to:
1. Read the template file (e.g., `templates/scan-manifest.md`)
2. Understand its required sections and field definitions
3. Produce output filling those exact sections with repo-specific data
4. Validate output against the template's quality gate checklist

### Pattern 3: File-Based Handoff
**What:** Agents communicate exclusively through files on disk -- no memory passing, no env vars
**When to use:** Always -- this is the only handoff mechanism

Flow:
1. Orchestrator spawns scanner with DEV repo path in prompt
2. Scanner writes `SCAN_MANIFEST.md` to a known output path
3. Orchestrator verifies SCAN_MANIFEST.md exists and passes verification
4. Orchestrator spawns analyzer with `<files_to_read>` pointing to SCAN_MANIFEST.md
5. Analyzer reads SCAN_MANIFEST.md + CLAUDE.md, produces QA_ANALYSIS.md + TEST_INVENTORY.md

### Pattern 4: Interactive Checkpoint Pattern
**What:** Agent pauses execution and returns structured state for the orchestrator to present to user
**When to use:** Scanner: framework detection failure or no testable surfaces. Analyzer: assumptions confirmation before generating full analysis.

From the GSD `checkpoint_return_for_orchestrator` pattern:
- Agent cannot interact with user directly when spawned via Task()
- Agent returns structured state: completed work + what's blocking + user-facing content + what's needed
- Orchestrator parses response, presents to user, spawns fresh continuation

For the analyzer's "Assumptions + Questions" checkpoint:
- Analyzer reads SCAN_MANIFEST.md
- Analyzer lists 3-8 assumptions with evidence from the code and 0-3 questions
- Analyzer returns this as a checkpoint return
- Orchestrator presents to user for confirmation
- Orchestrator spawns analyzer again (or continues) with confirmed assumptions

### Pattern 5: Scanner Framework Detection Strategy (Discretion Area)
**What:** How the scanner systematically detects the technology stack
**Recommended approach:** Depth-first by priority -- package files first, then config files, then file extensions, then source code patterns.

**Detection priority order:**
1. Package manifests: `package.json`, `requirements.txt`, `setup.py`, `pyproject.toml`, `*.csproj`, `pom.xml`, `build.gradle`, `go.mod`, `Gemfile`, `composer.json`
2. Configuration files: `tsconfig.json`, `vite.config.*`, `next.config.*`, `nuxt.config.*`, `angular.json`, `vue.config.*`, `webpack.config.*`
3. Lock files (for version pinning): `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
4. File extension frequency analysis: `.tsx`/`.jsx` = React, `.vue` = Vue, `.component.ts` = Angular
5. Source code patterns: import statements, decorator patterns, class inheritance

**Monorepo handling (Discretion Area):**
- Check for `workspaces` in package.json, `lerna.json`, `pnpm-workspace.yaml`, or `nx.json`
- If monorepo detected: scan each package/app as a separate unit
- Produce one SCAN_MANIFEST.md with packages listed as sections
- Include a `monorepo: true` flag and `packages` array in the output

### Anti-Patterns to Avoid
- **Embedding template content in the agent .md:** The agent should READ the template at runtime, not have template content copy-pasted into the agent file. Templates may evolve independently.
- **Agent-to-agent direct communication:** Agents must not assume they can call each other or share context. The orchestrator mediates all handoffs.
- **Hardcoding file paths in agent output:** The output path should come from the orchestrator prompt, not be hardcoded in the agent .md.
- **Skipping the read-before-write rule:** CLAUDE.md Section "Read-Before-Write Rules" mandates that both scanner and analyzer read their required inputs before producing output.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Model resolution | Custom logic in agent .md | `node qaa-tools.cjs resolve-model qaa-scanner` | Already implemented, returns correct model per profile |
| Git commits | Raw git commands in agent | `node qaa-tools.cjs commit "message" --files f1 f2` | Handles staging, message formatting, edge cases |
| State updates | Direct STATE.md editing | `node qaa-tools.cjs state update <field> <value>` | Preserves frontmatter, handles concurrent edits |
| Template reading | Inline template knowledge | `Read tool` on `templates/scan-manifest.md` at runtime | Templates may change -- always read fresh |
| Quality gate checks | Ad-hoc validation logic | Embed the template's quality gate checklist verbatim | Already validated in Phase 2 |
| Framework detection patterns | Custom regex per framework | File glob + package.json parsing via built-in tools | Glob/Read/Grep tools handle this natively |
| Frontmatter management | Manual YAML writing | `node qaa-tools.cjs frontmatter set/merge/get` | Already handles parsing, validation, and edge cases |

**Key insight:** These agents are instruction documents, not code. They direct a Claude Code subagent to use existing tools and infrastructure. The "don't hand-roll" principle means the agent .md should reference existing CLI commands and tools rather than describing novel algorithms.

## Common Pitfalls

### Pitfall 1: Agent .md Too Vague on Output Format
**What goes wrong:** Agent produces output that doesn't match the template structure, causing downstream agent failures.
**Why it happens:** The agent .md says "produce SCAN_MANIFEST.md" without specifying which sections are required or what fields each section needs.
**How to avoid:** Agent .md must instruct subagent to READ the template first and include the template's quality gate as the agent's own quality gate.
**Warning signs:** Review the agent .md -- if it doesn't reference `templates/scan-manifest.md` explicitly, it will produce inconsistent output.

### Pitfall 2: Scanner Missing File Types for Specific Stacks
**What goes wrong:** Scanner misses testable surfaces because it doesn't know the file patterns for a particular framework (e.g., `.razor` for ASP.NET Blazor, `.kt` for Kotlin Spring).
**Why it happens:** Detection logic only covers the "obvious" patterns.
**How to avoid:** The scanner agent .md should include a comprehensive table of framework-to-file-pattern mappings:
- Node.js/Express: `.ts`, `.js`, `.mjs`
- Python/FastAPI: `.py`
- .NET/ASP.NET: `.cs`, `.razor`, `.cshtml`
- Java/Spring: `.java`, `.kt`
- Go: `.go`
- Ruby/Rails: `.rb`, `.erb`
- PHP/Laravel: `.php`, `.blade.php`
- React/Next.js: `.tsx`, `.jsx`
- Vue/Nuxt: `.vue`, `.ts`
- Angular: `.component.ts`, `.service.ts`, `.module.ts`

### Pitfall 3: Analyzer Producing Vague Test Cases
**What goes wrong:** TEST_INVENTORY.md has test cases with outcomes like "returns correct data" instead of concrete values.
**Why it happens:** The analyzer doesn't have enough information from the scan manifest to produce specific values, or the agent .md doesn't enforce the specificity requirement strongly enough.
**How to avoid:** The analyzer's quality gate MUST include the anti-pattern check from CLAUDE.md: "No expected outcome says 'correct', 'proper', 'appropriate', or 'works' without defining what that means." The agent .md should contain explicit examples of good vs. bad test cases (reference the template's worked example).
**Warning signs:** Any test case where expected_outcome doesn't contain a number, specific string, specific error type, or specific state change.

### Pitfall 4: Scanner Not Detecting has_frontend Flag
**What goes wrong:** Orchestrator doesn't know whether to spawn testid-injector, breaking the pipeline conditional logic.
**Why it happens:** Scanner's decision gate produces PROCEED/STOP but omits the `has_frontend` field.
**How to avoid:** Scanner's output format MUST include `has_frontend: true/false` in the Decision Gate section. The scanner .md quality gate should explicitly check for this field.
**Warning signs:** Decision Gate section doesn't mention frontend detection.

### Pitfall 5: Checkpoint Return Format Incompatible with Orchestrator
**What goes wrong:** Scanner or analyzer returns a checkpoint in plain text format, but the orchestrator expects structured state.
**Why it happens:** Agent .md doesn't specify the checkpoint return format.
**How to avoid:** Both agent .md files should include the exact checkpoint return structure from GSD's `checkpoint_return_for_orchestrator` pattern: completed tasks table, current task (what's blocking), checkpoint details (user-facing content), and awaiting (what's needed from user).

### Pitfall 6: Analyzer Ignoring Read-Before-Write Rule
**What goes wrong:** Analyzer produces output without reading CLAUDE.md standards, resulting in test cases that don't follow QA standards (wrong ID format, missing mocks field, vague priorities).
**Why it happens:** The agent .md lists CLAUDE.md in `<required_reading>` but the subagent skips it to save context.
**How to avoid:** The `<required_reading>` section should mandate reading CLAUDE.md and specify which sections are critical (Testing Pyramid, Test Spec Rules, Naming Conventions, Quality Gates). The first step in the process should verify these files were read.

## Code Examples

### Scanner Agent .md Structure (Skeleton)

```markdown
<purpose>
Scan a developer repository to produce a comprehensive SCAN_MANIFEST.md.
Reads the repo's file tree, package manifests, config files, and source code
to detect framework, language, runtime, and all testable surfaces.
Spawned by the orchestrator as the first stage of the QA pipeline.
</purpose>

<required_reading>
Read these files before any scanning operation:
- templates/scan-manifest.md (output format contract)
- CLAUDE.md (QA standards and module boundaries -- sections: Framework Detection, Module Boundaries, Verification Commands)
</required_reading>

<process>

<step name="detect_project" priority="first">
1. Read package manifest (package.json, requirements.txt, etc.)
2. Read config files (tsconfig.json, vite.config.*, etc.)
3. Analyze file extension frequency
4. Populate Project Detection section with framework, language, runtime,
   component_pattern, package_manager
5. Assign detection confidence: HIGH/MEDIUM/LOW

If confidence is LOW or framework unknown:
  Return checkpoint: { blocking: "Framework detection uncertain",
    details: "Found: [files]. Detected: [partial]. Need user confirmation.",
    awaiting: "User confirms framework or provides info" }
</step>

<step name="build_file_list">
...file discovery and classification logic...
</step>

<step name="identify_testable_surfaces">
...surface categorization logic...
</step>

<step name="decision_gate">
...PROCEED/STOP logic with has_frontend flag...
</step>

<step name="write_output">
Write SCAN_MANIFEST.md to the output path specified by orchestrator.
Commit: node qaa-tools.cjs commit "qa(scanner): produce SCAN_MANIFEST.md for {project}" --files {output_path}
</step>

</process>

<quality_gate>
[Embed quality gate from templates/scan-manifest.md verbatim]
- [ ] has_frontend field present in Decision Gate (true/false)
- [ ] detection_confidence field present in Decision Gate (HIGH/MEDIUM/LOW)
</quality_gate>

<success_criteria>
- SCAN_MANIFEST.md exists at output path
- All 5 required sections populated
- Decision Gate is PROCEED or STOP with reason
- Return: file path, decision, has_frontend flag, detection confidence
</success_criteria>
```

### Analyzer Agent .md Structure (Skeleton)

```markdown
<purpose>
Analyze a scanned repository to produce QA_ANALYSIS.md and TEST_INVENTORY.md.
Consumes SCAN_MANIFEST.md (from scanner) and CLAUDE.md (QA standards) to
produce a complete testability report and pyramid-based test case inventory.
Spawned by orchestrator after scanner completes successfully.
</purpose>

<required_reading>
Read these files before any analysis operation:
- SCAN_MANIFEST.md (path provided by orchestrator in files_to_read)
- templates/qa-analysis.md (QA_ANALYSIS output format contract)
- templates/test-inventory.md (TEST_INVENTORY output format contract)
- templates/qa-repo-blueprint.md (QA_REPO_BLUEPRINT format -- produce if Option 1 workflow)
- CLAUDE.md (QA standards -- sections: Testing Pyramid, Test Spec Rules, Naming Conventions, Quality Gates, Module Boundaries)
</required_reading>

<process>

<step name="assumptions_checkpoint" priority="first">
Read SCAN_MANIFEST.md completely.
List 3-8 assumptions with evidence from the scan data.
List 0-3 questions that genuinely affect analysis quality.

Return checkpoint: {
  completed: "Read SCAN_MANIFEST.md, identified assumptions",
  blocking: "Need user confirmation on assumptions",
  details: { assumptions: [...], questions: [...] },
  awaiting: "User confirms assumptions or provides corrections"
}
</step>

<step name="produce_qa_analysis">
...architecture, risks, targets, pyramid analysis...
</step>

<step name="produce_test_inventory">
...pyramid-based test cases with full spec detail...
</step>

<step name="produce_blueprint">
If Option 1 (dev-only) workflow: produce QA_REPO_BLUEPRINT.md
</step>

<step name="write_output">
Write QA_ANALYSIS.md and TEST_INVENTORY.md to output paths.
Commit: node qaa-tools.cjs commit "qa(analyzer): produce QA_ANALYSIS.md and TEST_INVENTORY.md" --files {paths}
</step>

</process>

<quality_gate>
[Embed quality gates from both templates/qa-analysis.md and templates/test-inventory.md]
Additional checks:
- [ ] No expected outcome uses "correct", "proper", "appropriate", or "works" without concrete value
- [ ] Pyramid percentages sum to 100%
- [ ] Test IDs are unique and follow naming convention
- [ ] Every unit test has all 7 mandatory fields
</quality_gate>

<success_criteria>
- QA_ANALYSIS.md exists with all 6 required sections
- TEST_INVENTORY.md exists with all 5 required sections
- Test case count follows pyramid distribution
- Return: file paths, total test count, pyramid breakdown, risk count
</success_criteria>
```

### How Orchestrator Spawns an Agent (Future Phase 5 Context)

```javascript
// Scanner spawning pattern (for context -- not built in Phase 3)
Task(
  prompt=`
Scan the repository at ${DEV_REPO_PATH}.

<files_to_read>
- agents/qaa-scanner.md (your workflow instructions)
- CLAUDE.md (QA standards you must follow)
- templates/scan-manifest.md (output format you must match)
</files_to_read>

<output>
Write SCAN_MANIFEST.md to: ${OUTPUT_DIR}/SCAN_MANIFEST.md
</output>
`,
  subagent_type="qaa-scanner",
  model="${scanner_model}",
  description="Scan: ${DEV_REPO_PATH}"
)
```

### qaa-tools.cjs Usage Within Agents

```bash
# Commit scan results
node bin/qaa-tools.cjs commit "qa(scanner): produce SCAN_MANIFEST.md for shopflow" --files SCAN_MANIFEST.md

# Update pipeline state
node bin/qaa-tools.cjs state update pipeline.scan_status complete

# Read frontmatter from scan manifest
node bin/qaa-tools.cjs frontmatter get SCAN_MANIFEST.md
```

## State of the Art

| Aspect | Current Approach | Notes |
|--------|------------------|-------|
| Agent format | Markdown workflow files with XML tags | GSD pattern, proven across 9+ GSD workflows |
| Agent spawning | Task() with subagent_type + model | Claude Code native, no external dependencies |
| Inter-agent communication | File-based artifacts on disk | GSD-proven, fresh 200k context per agent |
| Framework detection | Package manifest + config file analysis | No ML-based detection needed -- pattern matching suffices |
| Test case specification | Full spec detail per template | Already defined in Phase 2 templates |

**No deprecated patterns to avoid** -- this is a greenfield agent system built on current GSD patterns.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Manual validation (markdown workflow files are not unit-testable code) |
| Config file | None -- agents are instruction documents |
| Quick run command | `cat agents/qaa-scanner.md` (verify file exists and has required sections) |
| Full suite command | Manual review: verify XML tags, required_reading paths, quality gate completeness |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| AGENT-01 | Scanner agent produces SCAN_MANIFEST.md | manual-only | Verify file structure with grep for required XML tags | N/A -- agent .md files, not executable tests |
| AGENT-02 | Analyzer agent produces QA_ANALYSIS.md + TEST_INVENTORY.md | manual-only | Verify file structure with grep for required XML tags | N/A -- agent .md files, not executable tests |

**Manual-only justification:** Agent .md files are natural language instruction documents. They are verified by (1) structural checks (presence of XML tags, required sections), (2) reference checks (template paths resolve, qaa-tools.cjs commands are valid), and (3) functional validation when integrated in Phase 5 (orchestrator spawns them and verifies output). No unit test framework applies.

### Sampling Rate
- **Per task commit:** Verify agent .md has all required XML tags and references valid file paths
- **Per wave merge:** Cross-check both agents reference correct template paths and follow CLAUDE.md module boundaries
- **Phase gate:** Both agent .md files exist, structurally complete, and reference valid infrastructure

### Wave 0 Gaps
- [ ] `agents/` directory does not exist yet -- must be created
- [ ] No existing test infrastructure for markdown workflow files -- validation is structural/manual

## Open Questions

1. **Output path convention for SCAN_MANIFEST.md**
   - What we know: The orchestrator passes the output path to the agent. CLAUDE.md module boundaries show scanner produces SCAN_MANIFEST.md.
   - What's unclear: The exact directory where SCAN_MANIFEST.md is written. Options: project root, `.qaa/` directory, a configurable output dir.
   - Recommendation: Use a convention like `{qaa_output_dir}/SCAN_MANIFEST.md` where `qaa_output_dir` is passed by the orchestrator. For Phase 3, the agent .md should accept the output path as a parameter in the prompt, not hardcode it. This defers the path convention to Phase 5 (workflow orchestration).

2. **Analyzer: QA_REPO_BLUEPRINT.md production trigger**
   - What we know: The analyzer produces QA_REPO_BLUEPRINT.md for Option 1 (dev-only) workflows. Module boundaries confirm this.
   - What's unclear: How the analyzer knows it's running in Option 1 vs Option 2/3 context.
   - Recommendation: The orchestrator should pass a `workflow_option` parameter (1/2/3) in the prompt. The analyzer .md should document: "If workflow_option is 1: produce QA_REPO_BLUEPRINT.md. Otherwise: skip."

3. **Monorepo detection scope**
   - What we know: Claude's discretion area. Monorepos are common in enterprise repos.
   - What's unclear: Whether to produce one SCAN_MANIFEST.md per package or one combined manifest.
   - Recommendation: Produce one combined SCAN_MANIFEST.md with a `monorepo` flag and `packages` section listing each package. This preserves the single-file handoff pattern. The analyzer can then produce per-package analysis sections within a single QA_ANALYSIS.md.

## Sources

### Primary (HIGH confidence)
- `C:/Users/mrrai/.claude/get-shit-done/workflows/execute-plan.md` -- GSD workflow structure with XML-tagged sections, step patterns, checkpoint protocol, deviation rules (493 lines studied)
- `C:/Users/mrrai/.claude/get-shit-done/workflows/quick.md` -- GSD workflow with Task() spawning patterns, subagent_type usage, file-based handoff (718 lines studied)
- `C:/Users/mrrai/.claude/get-shit-done/workflows/plan-phase.md` -- GSD orchestrator pattern for researcher/planner/checker agent spawning (80 lines studied)
- `templates/scan-manifest.md` -- Scanner output format contract (313 lines, 5 required sections, worked example with 32 files)
- `templates/qa-analysis.md` -- Analyzer QA_ANALYSIS output format (381 lines, 6 required sections, worked example)
- `templates/test-inventory.md` -- Analyzer TEST_INVENTORY output format (582 lines, 5 sections, 45 worked example test cases)
- `CLAUDE.md` -- Module boundaries, read-before-write rules, verification commands, agent coordination rules (544 lines)
- `.claude/skills/qa-repo-analyzer/SKILL.md` -- Analyzer execution steps: Step 0-4 pattern (collect context, assumptions checkpoint, QA_ANALYSIS, TEST_INVENTORY, QA_REPO_BLUEPRINT)
- `.claude/skills/qa-testid-injector/SKILL.md` -- Testid-injector capability definition (scanner must output has_frontend flag)
- `bin/lib/model-profiles.cjs` -- Model profile mappings: scanner gets opus/sonnet/haiku, analyzer gets opus/sonnet/haiku
- `bin/qaa-tools.cjs` -- CLI router with commit, state, frontmatter, template commands (603 lines)

### Secondary (MEDIUM confidence)
- `.planning/phases/03-discovery-agents/03-CONTEXT.md` -- User decisions locked during discussion phase

### Tertiary (LOW confidence)
None -- all findings verified against primary project sources.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- all infrastructure already built in Phase 1-2, verified by reading source
- Architecture: HIGH -- GSD workflow pattern studied across 3 workflow files (execute-plan, quick, plan-phase), pattern is consistent and well-established
- Pitfalls: HIGH -- derived from template quality gates and CLAUDE.md verification commands (concrete, not speculative)
- Agent structure: HIGH -- derived from direct study of GSD workflows, not hypothetical

**Research date:** 2026-03-19
**Valid until:** 2026-04-19 (stable -- markdown workflow pattern unlikely to change)
