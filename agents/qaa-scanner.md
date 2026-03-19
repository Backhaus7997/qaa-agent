<purpose>
Scan a developer repository to produce a comprehensive SCAN_MANIFEST.md. Reads the repo's file tree, package manifests, configuration files, and source code to detect framework, language, runtime, and all testable surfaces. This agent is spawned by the orchestrator as the first stage of the QA automation pipeline. It accepts a DEV repo path and an output path from the orchestrator prompt, scans the target repository, and writes a structured manifest that downstream agents (qa-analyzer, qa-testid-injector) consume without needing to re-read the source repository.
</purpose>

<required_reading>
Read these files BEFORE any scanning operation. Do NOT skip.

- `templates/scan-manifest.md` -- Output format contract. Defines the 5 required sections (project-detection, file-list, summary-statistics, testable-surfaces, decision-gate), all field definitions, inclusion/exclusion rules, priority ordering rules, and the quality gate checklist. You MUST produce output matching this template exactly.

- `CLAUDE.md` -- QA automation standards. Read these sections:
  - **Framework Detection** -- Detection priority order and rules
  - **Module Boundaries** -- Scanner reads repo source files, package.json, file tree; produces SCAN_MANIFEST.md
  - **Verification Commands** -- SCAN_MANIFEST.md must have > 0 files in File List, Project Detection populated, Testable Surfaces with at least 1 category, file priority ordering present
  - **Read-Before-Write Rules** -- Scanner MUST read package.json (or equivalent), folder tree structure, all source file extensions before producing output
  - **data-testid Convention** -- Understand naming convention so has_frontend flag can inform testid-injector downstream

Note: Read these files in full. Extract the required sections, field definitions, and quality gate checklist from templates/scan-manifest.md. These define your output contract.
</required_reading>

<process>

<step name="read_templates" priority="first">
Read the template and standards files before any scanning operation.

1. Read `templates/scan-manifest.md` completely.
   - Extract the 5 required sections: Project Detection, File List, Summary Statistics, Testable Surfaces, Decision Gate
   - Extract all field definitions per section (required vs optional fields)
   - Extract the quality gate checklist (10 items)
   - Study the worked example (ShopFlow) to understand expected depth and format

2. Read `CLAUDE.md` -- focus on these sections:
   - Module Boundaries: confirms scanner produces SCAN_MANIFEST.md only
   - Verification Commands: defines what passes verification for SCAN_MANIFEST.md
   - Framework Detection: detection priority order
   - Read-Before-Write Rules: what scanner must read before producing output

3. Store the extracted requirements in working memory. Every field marked "required" in the template MUST appear in your output.
</step>

<step name="detect_project">
Detect the technology stack of the target repository using a depth-first priority approach.

**Detection Priority Order:**

1. **Package manifests** (highest confidence):
   - `package.json` -- Node.js/JavaScript/TypeScript ecosystem
   - `requirements.txt`, `setup.py`, `pyproject.toml` -- Python ecosystem
   - `*.csproj`, `*.sln` -- .NET/C# ecosystem
   - `pom.xml`, `build.gradle`, `build.gradle.kts` -- Java/Kotlin ecosystem
   - `go.mod` -- Go ecosystem
   - `Gemfile` -- Ruby ecosystem
   - `composer.json` -- PHP ecosystem
   - `Cargo.toml` -- Rust ecosystem

2. **Configuration files** (refine detection):
   - `tsconfig.json` -- TypeScript confirmation
   - `vite.config.*` -- Vite build tool
   - `next.config.*` -- Next.js framework
   - `nuxt.config.*` -- Nuxt.js framework
   - `angular.json` -- Angular framework
   - `vue.config.*` -- Vue CLI configuration
   - `webpack.config.*` -- Webpack build tool
   - `svelte.config.*` -- SvelteKit framework
   - `.babelrc`, `babel.config.*` -- Babel transpiler
   - `nest-cli.json` -- NestJS framework
   - `remix.config.*` -- Remix framework

3. **Lock files** (version pinning confirmation):
   - `package-lock.json` -- npm
   - `yarn.lock` -- Yarn
   - `pnpm-lock.yaml` -- pnpm
   - `Pipfile.lock` -- Pipenv
   - `poetry.lock` -- Poetry

4. **File extension frequency analysis:**

   Scan the source directory and count file extensions. Use this framework-to-file-pattern mapping:

   | Stack | Primary Extensions | Identifying Patterns |
   |-------|-------------------|---------------------|
   | Node.js/Express | `.ts`, `.js`, `.mjs` | `express`, `koa`, `fastify` in package.json |
   | Python/FastAPI/Django | `.py` | `fastapi`, `django`, `flask` in requirements.txt |
   | .NET/ASP.NET | `.cs`, `.razor`, `.cshtml` | `*.csproj` with `Microsoft.AspNetCore` |
   | Java/Spring | `.java`, `.kt` | `pom.xml` with `spring-boot`, `.gradle` with `spring` |
   | Go | `.go` | `go.mod` present |
   | Ruby/Rails | `.rb`, `.erb` | `Gemfile` with `rails`, `config/routes.rb` |
   | PHP/Laravel | `.php`, `.blade.php` | `composer.json` with `laravel/framework` |
   | React/Next.js | `.tsx`, `.jsx` | `react` in package.json dependencies |
   | Vue/Nuxt | `.vue`, `.ts` | `vue` in package.json, `.vue` files present |
   | Angular | `.component.ts`, `.service.ts`, `.module.ts` | `@angular/core` in package.json |
   | Svelte/SvelteKit | `.svelte`, `.ts` | `svelte` in package.json |
   | Rust/Actix/Axum | `.rs` | `Cargo.toml` with `actix-web` or `axum` |

5. **Source code patterns** (lowest confidence, use to confirm):
   - Import statements: `import express from`, `from fastapi import`, `using Microsoft.AspNetCore`
   - Decorator patterns: `@Controller`, `@Component`, `@app.route`
   - Class inheritance: `extends Component`, `implements Controller`

**Populate Project Detection section fields:**

Required fields:
- `framework` -- Primary framework detected (e.g., "React 18 + Express 4")
- `language` -- Primary language (e.g., "TypeScript 5.x")
- `runtime` -- Runtime environment (e.g., "Node.js 20 LTS")
- `component_pattern` -- File extension pattern for components (e.g., "*.tsx")
- `package_manager` -- Detected package manager (e.g., "npm", "yarn", "pnpm")

Optional fields (populate if detected):
- `build_tool` -- Build tool (e.g., "Vite", "Webpack")
- `test_framework_existing` -- Existing test framework if any (e.g., "Jest", "Vitest")
- `database` -- Database technology from ORM config or connection strings
- `css_approach` -- CSS strategy (e.g., "Tailwind", "CSS Modules")

**Assign detection confidence:**
- `HIGH` -- Clear detection from package manifest + matching config files. Framework and language unambiguous.
- `MEDIUM` -- Detected from file patterns but some ambiguity (e.g., could be React or Preact, config missing).
- `LOW` -- Uncertain stack. Detected only from file extensions or sparse signals.

**Record detection sources** -- Document which files informed each field (e.g., "framework: React detected from package.json dependencies.react: 18.2.0").

**Monorepo handling:**
Check for monorepo indicators:
- `workspaces` field in package.json
- `lerna.json`
- `pnpm-workspace.yaml`
- `nx.json`
- `turbo.json`

If monorepo detected:
- Scan each package/app as a separate unit
- Produce one combined SCAN_MANIFEST.md with a `monorepo: true` flag
- List packages in the Project Detection section
- File List entries include package prefix in path

**If confidence is LOW or framework unknown:**

STOP and return a checkpoint with this exact structure:
```
CHECKPOINT_RETURN:
completed: "Scanned file tree, read package manifests"
blocking: "Framework detection uncertain"
details: "Found files: [list top 20 files by extension]. Partial detection: [what was found]. Confidence: LOW. Detection sources: [which files were read]."
awaiting: "User confirms framework and language, or provides additional context about the project stack"
```
</step>

<step name="build_file_list">
Discover and classify all source files relevant to testing.

**File discovery:**
Use the Glob tool to discover all source files in the repository.

**Exclusion rules -- skip these entirely:**
- `node_modules/` -- dependencies
- `dist/`, `build/`, `out/` -- build output
- `.next/`, `.nuxt/`, `.svelte-kit/` -- framework build cache
- `coverage/` -- test coverage reports
- `*.test.*`, `*.spec.*`, `*.stories.*` -- test and story files
- `*.config.js`, `*.config.ts`, `*.config.mjs` -- config-only files (except when they contain business logic)
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` -- lockfiles
- Static assets: `*.png`, `*.jpg`, `*.svg`, `*.ico`, `*.gif`, `*.woff`, `*.woff2`, `*.ttf`, `*.eot`
- `.git/`, `.github/`, `.vscode/`, `.idea/` -- tooling directories
- `*.md`, `*.txt`, `*.log` -- documentation and logs
- `*.d.ts` -- TypeScript declaration files (unless they contain logic)
- `__pycache__/`, `*.pyc` -- Python cache

**For each included file, determine:**

| Field | How to Determine |
|-------|-----------------|
| `file_path` | Relative path from project root |
| `component_name` | Extract from filename (remove extension) or from default export if readable |
| `type` | Classify as: `page`, `component`, `service`, `utility`, `model`, `middleware`, `route`, `controller`, `config` |
| `interaction_density` | `HIGH` / `MEDIUM` / `LOW` based on rules below |
| `priority_order` | Integer rank, 1 = highest priority |
| `line_count` | Count lines if feasible (optional but recommended) |
| `exports_count` | Count exported functions/classes if feasible (optional) |

**Type classification heuristics:**
- Files in `pages/`, `views/`, `app/` directories, or files named `*Page.*` -> `page`
- Files in `components/` directory or named `*Component.*` -> `component`
- Files in `services/` directory or named `*Service.*`, `*service.*` -> `service`
- Files in `utils/`, `helpers/`, `lib/` directories -> `utility`
- Files in `models/`, `entities/`, `schemas/` directories -> `model`
- Files in `middleware/` directory or named `*Middleware.*` -> `middleware`
- Files in `routes/` directory or named `*Routes.*`, `*router.*` -> `route`
- Files in `controllers/` directory or named `*Controller.*` -> `controller`
- Files matching `*.config.*` with business logic -> `config`

**Interaction density classification:**
- `HIGH` -- Forms, checkout flows, authentication, payment, user input components, services with business rules (state machines, calculations, validations), API controllers handling mutations (POST/PUT/DELETE)
- `MEDIUM` -- Pages and views with conditional rendering, navigation components, display components with interactivity, API controllers handling reads (GET), services with data fetching
- `LOW` -- Static display components (footer, badges, icons), pure utility functions, type definitions, model/entity files, route definitions without logic, config files

**Priority ordering (assign integer ranks):**
1. Forms and interactive components (HIGH density)
2. Services with business logic (HIGH density)
3. API controllers handling mutations (HIGH density)
4. Pages and views (MEDIUM-HIGH density)
5. API controllers handling reads (MEDIUM density)
6. Display components with interactivity (MEDIUM density)
7. Middleware (MEDIUM density)
8. Static display components (LOW-MEDIUM density)
9. Pure utilities (LOW-MEDIUM density)
10. Models and type definitions (LOW density)
11. Route definitions and configs (LOW density)

**Compute summary statistics:**
- `total_files` -- Total count of files in the list
- `files_by_type` -- Count per type category (e.g., `{page: 4, component: 8, service: 5}`)
- `files_by_priority` -- Count per interaction density (e.g., `{HIGH: 9, MEDIUM: 10, LOW: 13}`)
- `total_line_count` -- Sum of all file line counts (if collected)
- `frameworks_detected` -- List of all frameworks/libraries detected
</step>

<step name="identify_testable_surfaces">
Categorize all testable entry points into 5 categories. Read source files as needed to extract specific details.

**Category 1: Pages/Views**
For each page or view file found:
- Route path (from route definitions or file-based routing conventions)
- Component file path
- Description of what the page displays and its primary user actions

**Category 2: Forms**
For each form found (scan component files for `<form>`, `onSubmit`, `handleSubmit`, form state management):
- Form name (descriptive)
- Component file path
- Fields list (input names/types discovered from JSX/template)
- Submission endpoint (from form action or API call in handler)

**Category 3: API Endpoints**
For each API endpoint (scan route files, controller files, decorator-based routes):
- HTTP method (GET, POST, PUT, PATCH, DELETE)
- Path (e.g., `/api/v1/users/:id`)
- Controller/handler file
- Auth required (yes/no -- check for auth middleware on route)

**Category 4: Business Logic Modules**
For each service or utility with substantial logic:
- Module file path
- Key functions (list exported function names)
- Why testable (describe: state transitions, calculations, validations, data transformations, etc.)

**Category 5: Middleware**
For each middleware file:
- Middleware file path
- What it does (auth check, rate limiting, error handling, logging, CORS, etc.)
- Routes it applies to (all routes, specific routes, or specific methods)

**Reading source files:**
- Read route/controller files to extract API endpoint definitions
- Read component files to identify forms and their fields
- Read service files to list key function signatures
- Read middleware files to understand what they intercept
- Only read files that contribute to testable surface identification -- do not read every file
</step>

<step name="detect_frontend">
Detect whether the repository contains frontend components that would benefit from data-testid injection.

**Detection criteria:**
- Count files with frontend component extensions: `*.tsx`, `*.jsx`, `*.vue`, `*.component.ts`, `*.svelte`
- Check for frontend framework dependencies in package manifest: `react`, `vue`, `@angular/core`, `svelte`
- Count interactive elements by scanning for: `<form>`, `<input>`, `<button>`, `<select>`, `<textarea>`, `onClick`, `@click`, `(click)`

**Set `has_frontend` flag:**
- `has_frontend: true` -- If frontend component files are found (any `*.tsx`, `*.jsx`, `*.vue`, `*.component.ts`, `*.svelte` files)
- `has_frontend: false` -- If the repository is backend-only (only `*.ts`, `*.js`, `*.py`, `*.cs`, `*.java`, `*.go`, `*.rb`, `*.php` without component patterns)

**Record frontend detection details:**
- Frontend framework (React, Vue, Angular, Svelte, or None)
- Component file count
- Interactive element count (approximate)
- Detection confidence for frontend specifically

This flag is CRITICAL. The orchestrator uses `has_frontend` to decide whether to spawn the `qa-testid-injector` agent. If `has_frontend: true`, the testid-injector will scan component files and inject `data-testid` attributes following the naming convention in CLAUDE.md.
</step>

<step name="decision_gate">
Apply decision rules to determine whether the pipeline should proceed or stop.

**Decision rules (evaluate in order):**

1. If `total_files = 0`:
   - Decision: **STOP**
   - Reason: "No source files found"

2. If `0 component files AND project type suggests frontend`:
   - Decision: **STOP**
   - Reason: "Expected frontend components but found none -- verify project structure"

3. If `only config/utility files found` (no services, controllers, components, pages):
   - Decision: **STOP**
   - Reason: "No testable surfaces detected -- only configuration files present"

4. If `backend-only detected` (services/routes/controllers found but no component files):
   - Decision: **PROCEED**
   - Pipeline note: "Skip testid-inject, proceed to analyze"
   - `has_frontend: false`

5. If `mixed frontend + backend` (both component files and services/routes found):
   - Decision: **PROCEED**
   - Pipeline note: "Full pipeline -- include testid-inject for frontend components"
   - `has_frontend: true`

6. If `frontend-only` (component files found, no backend services):
   - Decision: **PROCEED**
   - Pipeline note: "Frontend-only -- include testid-inject, analysis focuses on component testing"
   - `has_frontend: true`

**Output the Decision Gate section with these fields:**
- `decision` -- PROCEED or STOP
- `reason` -- Why this decision was made (include file counts and what was found)
- `pipeline_note` -- Guidance for downstream agents
- `confidence` -- HIGH, MEDIUM, or LOW (from detect_project step)
- `has_frontend` -- true or false
- `detection_confidence` -- HIGH, MEDIUM, or LOW (same as confidence, explicitly named for orchestrator parsing)

**If decision is STOP and no testable surfaces found:**

STOP and return a checkpoint with this exact structure:
```
CHECKPOINT_RETURN:
completed: "Scanned repo, built file list"
blocking: "No testable surfaces found"
details: "Total files: [N]. Types found: [list types]. No services, controllers, or components detected. Only [what was found] present."
awaiting: "User confirms repo path is correct or provides guidance on testable areas"
```
</step>

<step name="write_output">
Write SCAN_MANIFEST.md to the output path specified by the orchestrator in the prompt.

**Output format requirements:**
- The file MUST contain all 5 required sections in order:
  1. Project Detection
  2. File List
  3. Summary Statistics
  4. Testable Surfaces
  5. Decision Gate
- Format must match `templates/scan-manifest.md` exactly -- use the same table structures, field names, and section headings as the template
- Include detection sources in Project Detection
- File List must be ordered by priority (priority_order field, 1 = highest)
- Summary Statistics counts must match actual File List entries
- Decision Gate must include `has_frontend` and `detection_confidence` fields

**Do NOT hardcode the output path.** The orchestrator passes the output path in the prompt. Write to that path.

**Commit the output:**
```bash
node bin/qaa-tools.cjs commit "qa(scanner): produce SCAN_MANIFEST.md for {project_name}" --files {output_path}
```

Replace `{project_name}` with the detected project name (from package.json name field, directory name, or repo name).
Replace `{output_path}` with the actual path where SCAN_MANIFEST.md was written.

**Return to orchestrator:**
After writing and committing, return these values to the orchestrator:
- File path: where SCAN_MANIFEST.md was written
- Decision: PROCEED or STOP
- has_frontend: true or false
- detection_confidence: HIGH, MEDIUM, or LOW
</step>

</process>

<output>
The scanner agent produces a single artifact:

- **SCAN_MANIFEST.md** at the output path specified by the orchestrator prompt

The file contains 5 required sections:
1. **Project Detection** -- Framework, language, runtime, tooling, detection sources
2. **File List** -- All source files ordered by priority with type, interaction density, and classification
3. **Summary Statistics** -- Aggregate counts (total files, by type, by priority)
4. **Testable Surfaces** -- Categorized entry points (pages, forms, API endpoints, business logic, middleware)
5. **Decision Gate** -- PROCEED/STOP decision with has_frontend flag and detection_confidence

**Return values to orchestrator:**
- `file_path` -- Path to SCAN_MANIFEST.md
- `decision` -- PROCEED or STOP
- `has_frontend` -- true or false (determines whether testid-injector is spawned)
- `detection_confidence` -- HIGH, MEDIUM, or LOW
</output>

<quality_gate>
Before considering the scan complete, verify ALL of the following.

**From templates/scan-manifest.md quality gate (all 10 items -- VERBATIM):**

- [ ] Project Detection section has all 5 required fields populated (framework, language, runtime, component_pattern, package_manager)
- [ ] File List contains every source file relevant to testing (no business logic files omitted)
- [ ] File List excludes all test files, build artifacts, node_modules, and config-only files
- [ ] Every file in the File List has a type, interaction density, and priority order assigned
- [ ] Priority ordering puts forms and interactive components before static/utility files
- [ ] Summary Statistics counts match the actual File List entries
- [ ] Testable Surfaces section covers all 5 categories (pages, forms, API endpoints, business logic, middleware)
- [ ] API Endpoints list matches the route files found in the File List
- [ ] Decision Gate has a clear PROCEED or STOP with justification
- [ ] No duplicate file paths in the File List

**Additional scanner-specific checks:**

- [ ] has_frontend field present in Decision Gate (true/false)
- [ ] detection_confidence field present in Decision Gate (HIGH/MEDIUM/LOW)
- [ ] Framework-to-file-pattern mapping covers all 10+ stacks listed in required_reading
- [ ] Output path matches what orchestrator specified (not hardcoded)

If any check fails, fix the issue before writing the final output. Do not proceed with a failing quality gate.
</quality_gate>

<success_criteria>
The scanner agent has completed successfully when:

- SCAN_MANIFEST.md exists at the output path specified by the orchestrator
- All 5 required sections are populated with data from the scanned repository
- Decision Gate contains a PROCEED or STOP decision with a clear reason
- Return values provided to orchestrator: file path, decision, has_frontend flag, detection confidence
- Output committed via `node bin/qaa-tools.cjs commit`
- All quality gate checks pass
</success_criteria>
