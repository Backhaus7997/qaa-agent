# Testing Guide

How to validate the QA Automation Agent against real repositories.

## Test Repos

Each workflow option requires a different type of repository to test against.

### Option 1 — Dev Only (No QA Repo)

Test the full generation pipeline: scan → analyze → generate → validate → deliver.

| Repo | Stack | Why it's good |
|------|-------|---------------|
| [devdbrandy/restful-ecommerce](https://github.com/devdbrandy/restful-ecommerce) | Node.js, Express | Minimalist e-commerce API. Products, orders, auth. Almost no tests — agent generates everything from scratch. |
| [themodernmonk7/E-commerce-API](https://github.com/themodernmonk7/E-commerce-API) | Express, MongoDB | Full CRUD: auth, products, orders, reviews. No QA repo. Good variety of endpoints. |
| [dinushchathurya/nodejs-ecommerce-api](https://github.com/dinushchathurya/nodejs-ecommerce-api) | Express, MongoDB | Full e-commerce: users, categories, products, orders, images. No tests. |

**How to test:**
```bash
git clone https://github.com/devdbrandy/restful-ecommerce.git /tmp/test-option1
cd /tmp/test-option1
# Open Claude Code in this directory, then:
/qa-start --dev-repo .
```

**Expected output:**
- SCAN_MANIFEST.md with Node.js/Express detection
- QA_ANALYSIS.md with architecture overview and risk assessment
- TEST_INVENTORY.md with 30+ test cases (pyramid-driven)
- QA_REPO_BLUEPRINT.md (since no QA repo exists)
- Generated test files (unit, API, E2E)
- VALIDATION_REPORT.md
- Draft PR with all artifacts

### Option 2 — Dev + Immature QA Repo

Test the gap analysis and augmentation pipeline.

| DEV Repo | Stack | QA Repo |
|----------|-------|---------|
| [oozdal/to-do-list-api](https://github.com/oozdal/to-do-list-api) | FastAPI, SQLAlchemy | Create a crude QA repo manually (see below) |
| [KenMwaura1/Fast-Api-example](https://github.com/KenMwaura1/Fast-Api-example) | FastAPI, PostgreSQL, SQLAlchemy | Create a crude QA repo manually (see below) |

**Creating a crude QA repo for testing:**

No open-source repos have intentionally bad tests. Create one manually:

```bash
mkdir /tmp/test-option2-qa
cd /tmp/test-option2-qa

# Create a broken test file with hardcoded tokens
cat > tests/test_api.py << 'EOF'
import requests

# TODO: ask Juan for new token
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.expired"
BASE_URL = "http://localhost:8000"

def test_get_todos():
    r = requests.get(f"{BASE_URL}/todos", headers={"Authorization": f"Bearer {TOKEN}"})
    assert r.status_code  # No specific assertion!

def test_create_todo():
    r = requests.post(f"{BASE_URL}/todos", json={"title": "test"})
    # No assertion at all
EOF

# Create a broken Selenium test
cat > old_tests/test_ui.py << 'EOF'
from selenium import webdriver
# This import doesn't work anymore
from selenium.webdriver.common.keys import Keys

def test_login():
    driver = webdriver.Chrome()  # Will fail - no ChromeDriver
    driver.get("http://localhost:3000/login")
    driver.find_element_by_class_name("login-btn").click()  # Deprecated API
EOF

# Create empty postman collection
echo '{"info": {"name": "Todo API"}, "item": []}' > postman/collection.json

# Bad README
echo "# QA Tests\nSome tests might need updating. Ask the team." > README.md

git init && git add -A && git commit -m "initial qa setup"
```

**How to test:**
```bash
cd /tmp/test-option2-dev  # The FastAPI dev repo
/qa-start --dev-repo . --qa-repo /tmp/test-option2-qa
```

**Expected output:**
- Maturity score < 30 → Option 2 detected
- GAP_ANALYSIS.md showing broken tests, missing coverage
- Fixed test files (imports, assertions, configs)
- New test cases added for uncovered features
- VALIDATION_REPORT.md

### Option 3 — Dev + Mature QA Repo

Test the surgical additions pipeline.

| QA Repo | Stack | Why it's good |
|---------|-------|---------------|
| [OmonUrkinbaev/playwright-qa-automation](https://github.com/OmonUrkinbaev/playwright-qa-automation) | Playwright, TypeScript, POM | Production-style: UI + API tests, POM, data-driven, flaky handling, CI pipelines. |
| [idavidov13/Playwright-Framework](https://github.com/idavidov13/Playwright-Framework) | Playwright, TypeScript, POM | Custom fixtures, API mocking, Zod validation, GitHub Actions + GitLab CI. |
| [nareshnavinash/playwright-TS-pom](https://github.com/nareshnavinash/playwright-TS-pom) | Playwright, TypeScript, POM | GitLab CI, DataDog integration, ESLint, junit + HTML reporting. |

**How to test:**
```bash
# Clone the app being tested (the QA repo tests against a demo app)
git clone https://github.com/OmonUrkinbaev/playwright-qa-automation.git /tmp/test-option3-qa

# You need the DEV repo that the QA repo tests against
# Check the QA repo's README for the target application URL/repo

/qa-start --dev-repo /tmp/test-option3-dev --qa-repo /tmp/test-option3-qa
```

**Expected output:**
- Maturity score > 70 → Option 3 detected
- GAP_ANALYSIS.md showing thin coverage areas only
- Only missing tests added — existing tests untouched
- Existing POM conventions respected
- VALIDATION_REPORT.md

## Validation Checklist

After each test run, verify:

- [ ] Correct workflow option detected (1, 2, or 3)
- [ ] SCAN_MANIFEST.md has correct framework detection
- [ ] QA_ANALYSIS.md has real architecture info (not generic)
- [ ] TEST_INVENTORY.md has concrete inputs and expected outcomes
- [ ] Generated test files follow CLAUDE.md standards
- [ ] All locators use Tier 1 (data-testid) or Tier 2 (ARIA roles)
- [ ] No assertions use toBeTruthy/toBeDefined
- [ ] POM has no assertions (if E2E tests generated)
- [ ] VALIDATION_REPORT.md shows 4-layer check results
- [ ] Draft PR created with full summary and reviewer checklist
- [ ] No hardcoded credentials in any generated file

## Troubleshooting Test Runs

| Issue | Fix |
|-------|-----|
| `gh: command not found` | Install GitHub CLI: `brew install gh` or `winget install GitHub.cli` |
| `gh auth` error | Run `gh auth login` first |
| Agent detects wrong framework | Check SCAN_MANIFEST.md — may need to adjust scanner detection patterns |
| Maturity score seems wrong | Review the 5 scoring dimensions in init.cjs cmdInitQaStart |
| Tests fail to validate | Check if the test framework is installed in the target repo |
