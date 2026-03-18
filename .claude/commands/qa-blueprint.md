# QA Repository Blueprint

Generate a complete QA repo structure blueprint for a project that has no QA repo yet. Includes folder structure, recommended stack, config files, and execution scripts.

## Instructions

### Step 1: Gather Input

Ask the user for:
1. Path to the DEV repo
2. Preferred test framework (or auto-detect from DEV repo's tech stack)
3. CI/CD platform (GitHub Actions, Azure Pipelines, GitLab CI, etc.)

### Step 2: Analyze DEV Repo

Determine:
- Tech stack (language, runtime, framework)
- Frontend vs backend vs full-stack
- API style (REST, GraphQL, gRPC)
- Authentication method
- Database type
- External integrations

### Step 3: Generate QA_REPO_BLUEPRINT.md

```markdown
# QA Repository Blueprint: [Project Name]

## Recommended Stack
- Test runner: [Playwright/Cypress/Jest/pytest/xUnit...]
- API testing: [supertest/requests/RestSharp...]
- Assertions: [expect/assert/should...]
- Mocking: [MSW/responses/Moq...]
- Reporting: [Allure/HTML Reporter...]

## Folder Structure
```
qa-[project-name]/
├── tests/
│   ├── e2e/
│   │   ├── smoke/           # P0 tests — every PR
│   │   └── regression/      # Full suite — nightly
│   ├── api/                 # API-level tests
│   ├── unit/                # Unit tests
│   └── contract/            # Contract tests (if microservices)
├── pages/                   # Page Object Models
│   ├── base/
│   │   └── BasePage.[ext]
│   └── [feature]/
│       └── [Feature]Page.[ext]
├── fixtures/                # Test data
├── config/                  # Test configs
├── reports/                 # Generated (gitignored)
├── [config files]           # playwright.config.ts, etc.
├── .env.example             # Required env vars
└── README.md                # How to run tests
```

## Config Files (generated)
...

## CI/CD Pipeline
...

## Definition of Done
- [ ] All test files follow naming convention
- [ ] POM structure established
- [ ] Fixtures use env vars, no hardcoded credentials
- [ ] CI pipeline runs smoke tests on PR
- [ ] README explains setup and execution
```

### Step 4: Scaffold (Optional)

Ask the user if they want to create the actual folder structure and config files on disk.

$ARGUMENTS
