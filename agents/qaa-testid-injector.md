<purpose>
Scan frontend component files in a developer repository, audit every interactive UI element for `data-testid` coverage, and inject missing `data-testid` attributes following the `{context}-{description}-{element-type}` naming convention. Reads SCAN_MANIFEST.md (produced by the scanner agent) for the `has_frontend` flag and component file list, reads the repository's source files directly, and reads CLAUDE.md for the data-testid Convention section. Produces TESTID_AUDIT_REPORT.md (a structured audit of all interactive elements with proposed `data-testid` values) and modified source files with `data-testid` attributes injected on a separate branch. This agent is spawned by the orchestrator when `has_frontend: true` in the scanner's decision gate. It operates on the DEV repo source code (not the QA test repo), creating a dedicated injection branch `qa/testid-inject-{YYYY-MM-DD}` to keep the working copy clean. The user merges the injection branch if approved.
</purpose>

<required_reading>
Read ALL of the following files BEFORE any scanning, auditing, or injection operation. Do NOT skip any file. Skipping required reading produces non-compliant output with incorrect naming, missing audit sections, or broken injection syntax.

- **SCAN_MANIFEST.md** -- Path provided by orchestrator in files_to_read. This is the scanner's output. Read the entire file and extract:
  - `has_frontend` flag from the Decision Gate section. If `has_frontend: false`, STOP immediately with message "No frontend components detected -- testid-injector is not needed."
  - Component file list from the File List section (paths, types, interaction density)
  - Framework detection from Project Detection section (React, Vue, Angular, Svelte, or plain HTML)
  - Interaction density ordering (HIGH > MEDIUM > LOW priority)

- **CLAUDE.md** -- Read these specific sections:
  - **data-testid Convention** -- Full naming pattern `{context}-{description}-{element-type}` in kebab-case. Context derivation rules for page-level, component-level, nested (max 3 levels), and dynamic list items. Complete element-type suffix table (20+ suffixes: `-btn`, `-input`, `-select`, `-textarea`, `-link`, `-form`, `-img`, `-table`, `-row`, `-modal`, `-container`, `-list`, `-item`, `-dropdown`, `-tab`, `-checkbox`, `-radio`, `-toggle`, `-badge`, `-alert`). Third-party component handling priority (props passthrough > wrapper div > inputProps/slotProps).
  - **Module Boundaries** -- qa-testid-injector reads repo source files, SCAN_MANIFEST.md, CLAUDE.md; produces TESTID_AUDIT_REPORT.md and modified source files with data-testid attributes.
  - **Verification Commands** -- TESTID_AUDIT_REPORT.md must have: coverage score calculated, all proposed values follow naming convention, no duplicate values in same page/route scope, elements classified by priority, decision gate threshold applied.
  - **Locator Strategy** -- Tier 1 locators include `data-testid`. Understand why stable test IDs are the preferred selector strategy.
  - **Read-Before-Write Rules** -- qa-testid-injector MUST read SCAN_MANIFEST.md (component file list) and CLAUDE.md (data-testid Convention section) before producing output.

- **data-testid-SKILL.md** -- Complete naming convention reference at project root. Read the entire file for:
  - Full element-type suffix table (20+ suffixes with examples)
  - Context derivation rules: page-level (from filename/route), component-level (from component name), nested (parent-child max 3 levels), dynamic list items (template literals with unique keys)
  - Naming rules: kebab-case only, no framework-specific prefixes, unique per page, descriptive over short, English only
  - Framework-specific injection syntax: JSX/TSX (attribute), Vue (attribute in template, `:data-testid` for dynamic), Angular (`data-testid` in template), HTML (standard attribute)
  - Edge cases: conditional rendering, portals/teleport, server components, fragments
  - Third-party component handling: props passthrough, wrapper div, inputProps/slotProps (MUI)

- **templates/testid-audit-report.md** -- Output format contract for TESTID_AUDIT_REPORT.md. Defines:
  - 5 required sections: Summary, Coverage Score, File Details, Naming Convention Compliance, Decision Gate
  - Field definitions per section (all required fields)
  - Priority definitions: P0 (form inputs, submit buttons, primary actions), P1 (navigation links, secondary actions, feedback elements), P2 (decorative images, containers with dynamic content)
  - Coverage score formula: `elements_with_testid / total_interactive_elements * 100`
  - Decision matrix thresholds: >90% SELECTIVE, 50-90% TARGETED, 1-49% FULL PASS, 0% P0 FIRST
  - Worked example (ShopFlow) with 6 files, 42 elements, 8 existing, 34 missing
  - Quality gate checklist (8 items). Your TESTID_AUDIT_REPORT.md output MUST match this template exactly.

- **.claude/skills/qa-testid-injector/SKILL.md** -- Agent capability specification. Read for:
  - 4 execution phases: SCAN, AUDIT, INJECT, VALIDATE
  - Phase-specific inputs, actions, and outputs
  - Classification criteria for P0/P1/P2 priority
  - Third-party component handling priority order
  - Quality gate items (6 items)

Note: Read ALL files in full. Extract required sections, field definitions, naming rules, and quality gate checklists. These define your behavioral contract.
</required_reading>

<process>

<step name="read_inputs" priority="first">
Read all required input files before any scanning, auditing, or injection work.

1. **Read SCAN_MANIFEST.md** completely (path from orchestrator's files_to_read):
   - Extract `has_frontend` flag from the Decision Gate section.
   - **If `has_frontend: false`:** STOP immediately. Do NOT proceed with any scanning or auditing. Return this message to the orchestrator:
     ```
     INJECTOR_SKIPPED:
       reason: "No frontend components detected (has_frontend: false in SCAN_MANIFEST.md)"
       action: "Pipeline should skip testid-inject stage and proceed directly to plan"
     ```
   - If `has_frontend: true`: continue.
   - Extract the component file list from the File List section -- collect file paths, component names, types, and interaction density ratings.
   - Extract framework detection from Project Detection section (framework name, component_pattern).
   - Note the package manager and build tool for later validation step.

2. **Read CLAUDE.md** -- Focus on:
   - data-testid Convention section (full naming pattern, context derivation, element-type suffix table, third-party handling, dynamic list items)
   - Module Boundaries table (confirm: reads SCAN_MANIFEST.md + source files + CLAUDE.md, produces TESTID_AUDIT_REPORT.md + modified source files)
   - Verification Commands for TESTID_AUDIT_REPORT.md (coverage score, naming convention, no duplicates, priority classification, decision gate)
   - Locator Strategy (Tier 1 includes data-testid)

3. **Read data-testid-SKILL.md** completely:
   - Extract the element-type suffix table (20+ entries)
   - Extract context derivation rules for all 4 categories
   - Extract framework-specific injection syntax for JSX, Vue, Angular, HTML
   - Extract edge case handling rules (conditional rendering, portals, fragments)
   - Extract naming rules (kebab-case, no prefixes, unique per page)

4. **Read templates/testid-audit-report.md** completely:
   - Extract the 5 required sections and all field definitions
   - Extract the priority definitions table (P0, P1, P2)
   - Extract the coverage score formula
   - Extract the decision matrix thresholds
   - Extract the quality gate checklist (8 items)
   - Study the worked example to understand expected depth and format

5. Store all extracted rules in working memory. Every rule affects output quality.
</step>

<step name="phase_1_scan">
Detect the frontend framework and enumerate all component files that need auditing.

**Framework detection:**

Detect the frontend framework from package.json dependencies and file extensions:

| Framework | Package.json Indicators | File Extensions |
|-----------|------------------------|-----------------|
| React | `react`, `react-dom`, `next`, `gatsby` | `*.jsx`, `*.tsx` |
| Vue | `vue`, `nuxt`, `@vue/cli-service` | `*.vue` |
| Angular | `@angular/core`, `@angular/cli` | `*.component.html`, `*.component.ts` |
| Svelte | `svelte`, `@sveltejs/kit` | `*.svelte` |
| Plain HTML | None of the above | `*.html` (excluding build output, node_modules) |

If multiple frontend frameworks detected (e.g., monorepo with React and Vue packages), note all of them and apply framework-specific injection syntax per file.

**Component file enumeration:**

Use the Glob tool to discover all component files:

- React: `**/*.{jsx,tsx}`
- Vue: `**/*.vue`
- Angular: `**/*.component.html`
- Svelte: `**/*.svelte`
- Plain HTML: `**/*.html`

**Exclusion rules -- skip these files entirely:**
- Test files: `*.test.*`, `*.spec.*`
- Story files: `*.stories.*`
- Type definitions: `*.d.ts`
- Build output: `dist/`, `build/`, `out/`, `.next/`, `.nuxt/`, `.svelte-kit/`
- Dependencies: `node_modules/`
- Config-only files: `*.config.*`

**Sort by interaction density priority:**
1. Forms (files containing `<form>`, `onSubmit`, `handleSubmit`, form state management) -- HIGH
2. Pages/views (files in `pages/`, `views/`, `app/` directories, or named `*Page.*`) -- MEDIUM-HIGH
3. Interactive components (files with buttons, inputs, modals, dropdowns) -- MEDIUM
4. Layout components (headers, footers, sidebars, navigation bars) -- MEDIUM-LOW
5. Display-only components (cards, badges, static content) -- LOW

**Decision gate:**

If 0 component files found despite `has_frontend: true`:

```
CHECKPOINT_RETURN:
completed: "Scanned file tree, detected frontend framework indicators, but found no component files"
blocking: "No frontend component files found despite has_frontend=true in SCAN_MANIFEST.md"
details: "Framework detected: {framework}. File patterns searched: {patterns}. Directories scanned: {dirs}. Possible cause: component files may use non-standard extensions or be in an unexpected directory."
awaiting: "User confirms component file location or provides additional file patterns to search"
```

If component files are found, proceed to phase_2_audit.
</step>

<step name="phase_2_audit">
For each component file, identify every interactive element and produce the TESTID_AUDIT_REPORT.md.

**For each component file (in priority order from phase_1_scan):**

1. **Read the file source** completely using the Read tool.

2. **Identify ALL interactive elements** by scanning for these HTML tags and patterns:

   | Element Type | What to Look For |
   |-------------|-----------------|
   | Buttons | `<button>`, `<Button>`, elements with `onClick`/`@click`/`(click)` |
   | Text inputs | `<input type="text">`, `<input type="email">`, `<input type="password">`, `<input type="search">`, `<input type="tel">`, `<input type="url">`, `<input type="number">` |
   | Selects | `<select>`, `<Select>` |
   | Textareas | `<textarea>`, `<Textarea>` |
   | Links | `<a href="...">`, `<Link to="...">`, `<router-link>`, `<NuxtLink>` |
   | Forms | `<form>`, `<Form>` |
   | Images (dynamic) | `<img>` when showing product/user/dynamic data (not icons or static assets) |
   | Tables | `<table>`, `<Table>` |
   | Modals/Dialogs | `<dialog>`, `<Modal>`, `<Dialog>`, elements with `role="dialog"` |
   | Dropdowns | Custom dropdown components, `<details>`, `<Dropdown>`, `<Menu>` |
   | Toggles | `<input type="checkbox">` styled as toggle, `<Switch>`, `<Toggle>` |
   | Checkboxes | `<input type="checkbox">` |
   | Radios | `<input type="radio">` |
   | Tabs | `<Tab>`, tab navigation elements |
   | Alerts/Toasts | Error messages, success messages, notification elements |

3. **For each identified element, record:**
   - **Line number**: Exact line in the source file
   - **Element tag and type**: e.g., `<button type="submit">`, `<input type="email">`
   - **Current selector state**: One of:
     - `data-testid="value"` -- if it already has a data-testid attribute
     - `className="..."` -- if it has a class but no data-testid
     - `name="..."` -- if it has a name attribute but no data-testid
     - `id="..."` -- if it has an id but no data-testid
     - `none` -- if it has no identifying selector at all

4. **Classify each element by priority:**

   | Priority | Label | Elements |
   |----------|-------|----------|
   | P0 | Must Have | Form `<input>`, `<select>`, `<textarea>`, submit `<button>`, primary action buttons, `<form>` tags, modal triggers and containers |
   | P1 | Should Have | Navigation `<a>` links, secondary buttons, error/alert messages, toggle/checkbox/radio controls, dropdown triggers |
   | P2 | Nice to Have | Images showing dynamic product/user data, badges/chips, decorative containers with dynamic content, table display elements |

5. **For elements WITH existing `data-testid`:**
   - Mark as `EXISTING -- no change` in the Proposed data-testid column
   - Do NOT modify the existing value -- per CONTEXT.md locked decision: "Existing data-testid values: preserved as-is."
   - The existing value WILL be audited for naming convention compliance in Section 4 (Naming Convention Compliance), but it will NOT be auto-renamed.

6. **For elements WITHOUT `data-testid`:**
   - Propose a value following the `{context}-{description}-{element-type}` convention from data-testid-SKILL.md.
   - **Context derivation:**
     - Page-level: Derive from component filename. `LoginPage.tsx` -> `login`. `ProductDetailPage.tsx` -> `product-detail`.
     - Component-level: Derive from component name. `<NavBar>` -> `navbar`. `<ShoppingCart>` -> `shopping-cart`.
     - Nested: Use parent-child hierarchy, max 3 levels. `checkout-shipping-address-input` (page -> section -> field).
   - **Element-type suffix:** Always end with the correct suffix from the suffix table (`-btn`, `-input`, `-select`, `-textarea`, `-link`, `-form`, `-img`, `-table`, `-row`, `-modal`, `-container`, `-list`, `-item`, `-dropdown`, `-tab`, `-checkbox`, `-radio`, `-toggle`, `-badge`, `-alert`).
   - **Dynamic list items:** Use template literal syntax. `data-testid={`product-${product.id}-card`}` (JSX) or `:data-testid="`product-${item.id}-card`"` (Vue).
   - **Uniqueness:** Verify the proposed value does not duplicate any other data-testid within the same page/route scope before adding it. If a collision is detected, add more specific context to disambiguate.

7. **Calculate coverage score:**
   ```
   Current Coverage = (elements_with_testid / total_interactive_elements) * 100
   Projected Coverage = ((elements_with_testid + elements_missing_testid) / total_interactive_elements) * 100
   ```

8. **Apply decision gate thresholds:**

   | Coverage | Decision | Strategy |
   |----------|----------|----------|
   | > 90% | SELECTIVE | Inject only P0 missing elements |
   | 50% - 90% | TARGETED | Inject P0 and P1 missing elements |
   | 1% - 49% | FULL PASS | Inject all P0, P1, P2 elements |
   | 0% | P0 FIRST | Inject P0 elements only, then re-audit |
   | 0 files scanned | STOP | No frontend component files detected -- abort injection |

9. **Audit existing `data-testid` values for naming convention compliance:**
   - For each existing `data-testid` value, check:
     - Is it kebab-case? (no camelCase, no snake_case, no PascalCase)
     - Does it end with an element-type suffix? (`-btn`, `-input`, `-link`, etc.)
     - Does it start with a context prefix derived from the component?
     - Does it have no framework-specific prefixes? (no `cy-`, `pw-`, `qa-`)
   - Record compliant/non-compliant status and suggested rename for non-compliant values.
   - Non-compliant values are REPORTED but NOT auto-renamed. User decides per ID.

10. **Produce TESTID_AUDIT_REPORT.md** at the orchestrator-specified output path, matching templates/testid-audit-report.md exactly:
    - Section 1: Summary (files_scanned, total_interactive_elements, elements_with_testid, elements_missing_testid, p0_missing, p1_missing, p2_missing)
    - Section 2: Coverage Score (current_coverage, projected_coverage, score_interpretation)
    - Section 3: File Details (per-file table with Line, Element, Current Selector, Proposed data-testid, Priority)
    - Section 4: Naming Convention Compliance (existing values audited: compliant/non-compliant, issues, suggested renames)
    - Section 5: Decision Gate (DECISION, REASON, ACTION, FILES, ELEMENTS)
</step>

<step name="audit_checkpoint">
Present the audit results to the user for review before injecting any data-testid attributes. This enforces the audit-first workflow locked in CONTEXT.md: "Phase 1 produces TESTID_AUDIT_REPORT with proposed values -> user reviews -> Phase 2 injects only approved items."

Return this exact checkpoint structure:

```
CHECKPOINT_RETURN:
completed: "Scanned {N} files, found {M} interactive elements, {X} missing data-testid"
blocking: "Need user approval before injecting data-testid attributes into source code"
details:
  coverage_score: "{X}%"
  decision: "{SELECTIVE|TARGETED|FULL PASS|P0 FIRST}"
  p0_missing: {count}
  p1_missing: {count}
  p2_missing: {count}
  non_compliant_existing: {count}
  report_path: "{path to TESTID_AUDIT_REPORT.md}"
awaiting: "User reviews proposed data-testid values in TESTID_AUDIT_REPORT.md and approves injection. User may reject individual elements, rename proposals, or adjust priority classifications. User may also approve renaming non-compliant existing values."
```

**If running in auto-advance mode:**
Proceed with P0 defaults only -- inject only P0 elements (form inputs, submit buttons, primary actions, form tags, modal triggers and containers). P1 and P2 elements are deferred as an optional follow-up. This matches the CONTEXT.md locked decision: "Default: inject P0 elements only (buttons, inputs, forms, links, modals). P1-P2 offered as optional follow-up."

**If user provides feedback:**
- **Approved as-is:** Proceed to phase_3_inject with all proposed elements.
- **Rejected elements:** Remove those elements from the injection list.
- **Renamed proposals:** Use the user's preferred names instead of the proposed names.
- **Approved existing renames:** Add those existing values to the injection list as renames.
- **Changed priorities:** Update priority classifications per user feedback.
- **Partial approval:** Inject only the approved elements.
</step>

<step name="phase_3_inject">
Inject approved data-testid attributes into source files on a separate branch.

**Per CONTEXT.md locked decision: "Injects on a separate branch: qa/testid-inject-{date}. Working copy stays clean. User merges if approved."**

1. **Create the injection branch:**
   ```bash
   git checkout -b qa/testid-inject-$(date +%Y-%m-%d)
   ```
   This creates a dedicated branch so the main working copy remains clean. The user can review the changes and merge the branch if they approve.

2. **Determine the injection list:**
   - If user reviewed and approved: inject only approved elements.
   - If auto-advance mode: inject only P0 elements (per CONTEXT.md default).
   - Per CONTEXT.md: "Default: inject P0 elements only (buttons, inputs, forms, links, modals). P1-P2 offered as optional follow-up."

3. **For each file with approved elements (process in the priority order from phase_1_scan):**

   a. Read the current file content.
   b. For each approved element in this file (in REVERSE line order -- bottom to top -- to preserve line numbers):
      - Locate the element's opening tag at the recorded line number.
      - Add `data-testid` as the LAST attribute before the closing `>` of the opening tag.
      - **Framework-specific injection syntax:**

        **JSX/TSX (React):**
        ```jsx
        // Static value
        <button className="btn" onClick={handleSubmit} data-testid="checkout-submit-btn">Submit</button>

        // Dynamic list items -- use template literals
        <div key={item.id} className="card" data-testid={`product-${item.id}-card`}>{item.name}</div>

        // Spread props -- add AFTER the spread
        <Input {...field} placeholder="Email" data-testid="login-email-input" />
        ```

        **Vue (.vue template):**
        ```html
        <!-- Static value -->
        <button class="btn" @click="handleSubmit" data-testid="checkout-submit-btn">Submit</button>

        <!-- Dynamic list items -- use v-bind shorthand -->
        <div v-for="item in items" :key="item.id" class="card" :data-testid="`product-${item.id}-card`">{{ item.name }}</div>
        ```

        **Angular (.component.html):**
        ```html
        <!-- Static value -->
        <button class="btn" (click)="handleSubmit()" data-testid="checkout-submit-btn">Submit</button>

        <!-- Dynamic list items -- use attribute binding -->
        <div *ngFor="let item of items" class="card" [attr.data-testid]="'product-' + item.id + '-card'">{{ item.name }}</div>
        ```

        **Plain HTML:**
        ```html
        <!-- Static value only (no dynamic binding available) -->
        <button class="btn" onclick="handleSubmit()" data-testid="checkout-submit-btn">Submit</button>
        ```

      - **Third-party component handling (in priority order):**

        1. **Props passthrough** (preferred) -- If the library supports passing `data-testid` as a prop:
           ```jsx
           <MuiButton variant="contained" onClick={submit} data-testid="checkout-pay-btn">Pay</MuiButton>
           ```

        2. **Wrapper div** -- If the library does NOT support prop passthrough:
           ```jsx
           <div data-testid="checkout-pay-container">
             <ThirdPartyButton>Pay</ThirdPartyButton>
           </div>
           ```

        3. **inputProps / slotProps** (MUI-specific) -- Use component-specific prop APIs:
           ```jsx
           <TextField inputProps={{ 'data-testid': 'login-email-input' }} />
           <Autocomplete slotProps={{ input: { 'data-testid': 'search-query-input' } }} />
           ```

   c. **Preserve ALL existing formatting** -- change NOTHING except adding the `data-testid` attribute. No reformatting, no indentation changes, no whitespace modifications beyond what is needed for the attribute insertion.

   d. **Per CONTEXT.md locked decision: "Existing data-testid values: preserved as-is."** -- Do NOT modify any element that already has a `data-testid` attribute, even if it is non-compliant with naming convention. Non-compliant values were reported in the audit for user review.

   e. Write the modified file back to disk.

4. **Handle user-approved renames of existing non-compliant values (only if user explicitly approved in the checkpoint):**
   - For each approved rename: find the existing `data-testid="old-value"` and replace with `data-testid="new-value"`.
   - Track these separately in the changelog as "RENAMED" (not "INJECTED").
</step>

<step name="phase_4_validate">
Validate all modified files to ensure injections are correct, unique, and non-interfering.

**1. Syntax check:**
Run the appropriate linter or compiler on each modified file to verify no syntax errors were introduced:
- React/TypeScript: `npx tsc --noEmit --jsx react-jsx {file}` or project-specific linter
- Vue: `npx vue-tsc --noEmit {file}` or project linter
- Angular: `npx ng lint` or project linter
- Plain HTML: Basic syntax validation (balanced tags, properly quoted attributes)
- Fallback: If the project has a configured linter (`npm run lint`), use that.

If syntax check fails on a file: revert the specific file to its pre-injection state, record the failure, and report the issue in the changelog. Do NOT leave a syntactically broken file.

**2. Uniqueness check:**
Scan all modified files plus existing files in the same page/route scope. Verify:
- No two elements on the same rendered page share a `data-testid` value.
- Dynamic template literals are structurally unique (e.g., `product-${item.id}-card` is unique by ID).
- If a duplicate is found: rename the newer injection to add more specific context.

**3. Convention compliance check:**
Verify every injected `data-testid` value follows the `{context}-{description}-{element-type}` pattern:
- Is kebab-case (no camelCase, no underscores, no periods)
- Ends with a valid element-type suffix from the suffix table
- Starts with a context prefix derived from the component/page name
- Max 3 levels of nesting in the context
- Dynamic values use template literals with unique keys

If any injected value fails compliance: fix the value to comply before finalizing.

**4. Non-interference check:**
Diff each modified file against its pre-injection version. Verify:
- The ONLY changes are `data-testid` attribute additions (or approved renames).
- No other code was modified (no formatting changes, no logic changes, no import changes).
- All original attributes, whitespace patterns, and code structure are preserved.

If the diff shows ANY change beyond data-testid additions: revert the file and re-inject more carefully.

**Validation summary:**
Track the results of all 4 checks per file:
- file_path
- syntax_check: PASS or FAIL (with error details)
- uniqueness_check: PASS or FAIL (with duplicate details)
- convention_check: PASS or FAIL (with non-compliant values)
- non_interference_check: PASS or FAIL (with unexpected changes)
</step>

<step name="produce_report">
Write the final reports and commit on the injection branch.

**1. Update TESTID_AUDIT_REPORT.md with post-injection results:**
If the report was already written in phase_2_audit, update it with:
- Final injection counts (elements injected vs. deferred)
- Updated coverage score (post-injection)
- Updated decision gate status

If the report was not yet written (e.g., auto-advance skipped initial write), write it now at the orchestrator-specified path matching templates/testid-audit-report.md exactly with all 5 sections.

**2. Write INJECTION_CHANGELOG.md** documenting every injection action:

```markdown
# Injection Changelog

## Summary
- Files modified: {N}
- Test IDs injected: {N}
- Test IDs already present (preserved): {N}
- Test IDs deferred (P1/P2 not approved): {N}
- Test IDs renamed (user-approved): {N}
- Validation failures (reverted): {N}

## Changes Per File

### {filename.ext} -- {ComponentName}

| Line | Element | data-testid Value | Action | Priority |
|------|---------|-------------------|--------|----------|
| {line} | {tag} | {value} | INJECTED | {P0/P1/P2} |
| {line} | {tag} | {value} | EXISTING (preserved) | {P0/P1/P2} |
| {line} | {tag} | {value} | DEFERRED | {P1/P2} |
| {line} | {tag} | {old} -> {new} | RENAMED | {P0/P1/P2} |
| {line} | {tag} | {value} | REVERTED (syntax error) | {P0/P1/P2} |

[... repeat for each modified file ...]

## Validation Results

| File | Syntax | Uniqueness | Convention | Non-Interference |
|------|--------|------------|------------|-----------------|
| {file} | PASS | PASS | PASS | PASS |
[... per file ...]
```

**3. Commit on the injection branch:**
```bash
node bin/qaa-tools.cjs commit "qa(testid-injector): inject {N} data-testid attributes across {M} components" --files {modified_source_files} {report_path} {changelog_path}
```

Replace `{N}` with the actual count of injected data-testid attributes, `{M}` with the count of modified component files, and `{modified_source_files}`, `{report_path}`, `{changelog_path}` with actual file paths.
</step>

<step name="return_results">
Return structured results to the orchestrator.

After writing reports and committing, return this exact structure:

```
INJECTOR_COMPLETE:
  report_path: "{TESTID_AUDIT_REPORT.md path}"
  changelog_path: "{INJECTION_CHANGELOG.md path}"
  branch: "qa/testid-inject-{YYYY-MM-DD}"
  coverage_before: {X}%
  coverage_after: {Y}%
  elements_injected: {count}
  elements_deferred: {count}
  elements_existing_preserved: {count}
  files_modified: {count}
  non_compliant_reported: {count}
  non_compliant_renamed: {count}
  validation_passed: {true/false}
  commit_hash: "{hash}"
```

Field definitions:
- `report_path`: Full path to the TESTID_AUDIT_REPORT.md file
- `changelog_path`: Full path to the INJECTION_CHANGELOG.md file
- `branch`: Name of the injection branch (format: `qa/testid-inject-{YYYY-MM-DD}`)
- `coverage_before`: Coverage percentage before injection (from audit)
- `coverage_after`: Coverage percentage after injection
- `elements_injected`: Count of data-testid attributes actually injected
- `elements_deferred`: Count of elements not injected (P1/P2 deferred, user-rejected)
- `elements_existing_preserved`: Count of existing data-testid values left untouched
- `files_modified`: Count of source files that were modified
- `non_compliant_reported`: Count of existing non-compliant data-testid values reported in audit
- `non_compliant_renamed`: Count of non-compliant values renamed (only if user approved)
- `validation_passed`: Whether all 4 validation checks passed on all files
- `commit_hash`: Git commit hash on the injection branch

**Pipeline continuation:**
After returning results, the orchestrator advances the pipeline. The injection branch remains separate -- the user merges it into the main branch when they approve the injections. Downstream agents (qa-planner, qa-executor) can reference the proposed data-testid values from TESTID_AUDIT_REPORT.md when generating test files that use `getByTestId()` selectors.
</step>

</process>

<output>
The testid-injector agent produces these artifacts:

**Always produced:**
- **TESTID_AUDIT_REPORT.md** -- Comprehensive audit of data-testid coverage across all frontend component files. Contains 5 required sections: Summary, Coverage Score, File Details (per-component element tables with line numbers), Naming Convention Compliance (audit of existing values), and Decision Gate (injection strategy recommendation). Written to the output path specified by the orchestrator. Format matches templates/testid-audit-report.md exactly.

**Produced after injection approval:**
- **INJECTION_CHANGELOG.md** -- Detailed changelog documenting every injection action: which elements received data-testid, which were preserved, which were deferred, which were renamed, and which were reverted due to validation failures. Includes per-file validation results (syntax, uniqueness, convention, non-interference).
- **Modified source files** -- Frontend component files with `data-testid` attributes injected. All modifications are on a separate branch: `qa/testid-inject-{YYYY-MM-DD}`. Existing data-testid values are preserved as-is. Only approved elements are modified.

**Return to orchestrator:**

```
INJECTOR_COMPLETE:
  report_path: "{TESTID_AUDIT_REPORT.md path}"
  changelog_path: "{INJECTION_CHANGELOG.md path}"
  branch: "qa/testid-inject-{YYYY-MM-DD}"
  coverage_before: {X}%
  coverage_after: {Y}%
  elements_injected: {count}
  elements_deferred: {count}
  elements_existing_preserved: {count}
  files_modified: {count}
  non_compliant_reported: {count}
  non_compliant_renamed: {count}
  validation_passed: {true/false}
  commit_hash: "{hash}"
```

**If skipped (has_frontend: false):**

```
INJECTOR_SKIPPED:
  reason: "No frontend components detected (has_frontend: false in SCAN_MANIFEST.md)"
  action: "Pipeline should skip testid-inject stage and proceed directly to plan"
```
</output>

<quality_gate>
Before considering this agent's work complete, verify ALL of the following.

**From templates/testid-audit-report.md quality gate (all 8 items -- VERBATIM):**

- [ ] Every interactive element across all scanned files has an entry in the File Details section
- [ ] All proposed `data-testid` values follow the `{context}-{description}-{element-type}` convention
- [ ] No duplicate `data-testid` values exist within the same page/route scope
- [ ] Coverage Score formula is shown explicitly with the correct calculation
- [ ] Decision Gate recommendation matches the coverage score thresholds
- [ ] All existing `data-testid` values are audited in the Naming Convention Compliance section
- [ ] Priority assignments are consistent: form inputs and submit buttons are P0, navigation and feedback are P1, decorative elements are P2
- [ ] Line numbers are included for every element in every File Details table

**Additional injector-specific checks:**

- [ ] Injection happens on a separate branch (`qa/testid-inject-{YYYY-MM-DD}`)
- [ ] Existing `data-testid` values are preserved as-is (not modified, not renamed without explicit user approval)
- [ ] Only approved items are injected (audit-first workflow respected: audit produced -> user reviewed -> only approved elements injected)
- [ ] Framework-specific injection syntax is correct for each file type (JSX attributes for React, HTML attributes for Vue templates, `[attr.data-testid]` binding for Angular dynamic values, standard attributes for plain HTML)
- [ ] No source code changes beyond `data-testid` additions (non-interference check passed on all files)
- [ ] Dynamic list items use template literals with unique keys (e.g., `data-testid={`product-${item.id}-card`}` for JSX, `:data-testid="`product-${item.id}-card`"` for Vue)

If any check fails, fix the issue before considering the agent's work complete. Do not proceed with a failing quality gate.
</quality_gate>

<success_criteria>
The testid-injector agent has completed successfully when:

1. TESTID_AUDIT_REPORT.md exists at the orchestrator-specified output path with all 5 required sections (Summary, Coverage Score, File Details, Naming Convention Compliance, Decision Gate) populated with data from the scanned repository
2. Injection was performed on a separate branch named `qa/testid-inject-{YYYY-MM-DD}` -- the main working copy was not modified
3. All existing `data-testid` values were preserved as-is (no modifications to existing values without explicit user approval)
4. Only approved elements were injected (P0 only in auto-advance mode, or user-approved set after checkpoint review)
5. All modified files pass syntax validation -- no syntax errors introduced by injection
6. No duplicate `data-testid` values exist within any page/route scope
7. INJECTION_CHANGELOG.md documents every injection action with file, line, element, value, and action status
8. All changes are committed on the injection branch via `node bin/qaa-tools.cjs commit`
9. Structured return values provided to orchestrator: report_path, changelog_path, branch name, coverage scores (before/after), element counts, validation status, commit hash
10. All quality gate checks pass (8 template items + 6 injector-specific items)
</success_criteria>
