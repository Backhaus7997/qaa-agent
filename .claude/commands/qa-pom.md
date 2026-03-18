# Generate Page Object Models

Create or refactor Page Object Model files for a set of pages/views. Follows CLAUDE.md POM rules strictly.

## Instructions

### Step 1: Gather Input

Ask the user for:
1. Which pages/views need POMs? (URLs, component names, or "scan the app")
2. Framework (Playwright/Cypress/Selenium — auto-detect if possible)
3. Path where POMs should be created

### Step 2: Analyze Pages

For each target page:
- Identify all interactive elements
- Map user actions (click, type, select, navigate)
- Identify state queries (is visible, get text, get count)
- Note transitions to other pages

### Step 3: Create BasePage (if not exists)

```typescript
// BasePage provides shared methods for all page objects
export class BasePage {
  constructor(protected page: Page) {}

  async navigate(path: string) { ... }
  async waitForLoad() { ... }
  async screenshot(name: string) { ... }
  async getTitle(): Promise<string> { ... }
}
```

### Step 4: Create Feature POMs

For each page, following CLAUDE.md rules:

1. **One class per page** — no god objects
2. **No assertions** — assertions belong in test specs
3. **Locators as properties** — using Tier 1 selectors (data-testid, ARIA roles)
4. **Actions return void or next page** — for fluent chaining
5. **State queries return data** — let tests decide what to assert

```typescript
export class LoginPage extends BasePage {
  // Locators (Tier 1 — data-testid)
  readonly emailInput = this.page.getByTestId('login-email-input');
  readonly passwordInput = this.page.getByTestId('login-password-input');
  readonly submitButton = this.page.getByTestId('login-submit-btn');
  readonly errorMessage = this.page.getByTestId('login-error-alert');

  // Actions
  async login(email: string, password: string): Promise<DashboardPage> { ... }

  // State queries
  async getErrorText(): Promise<string> { ... }
  async isErrorVisible(): Promise<boolean> { ... }
}
```

### Step 5: Validate

- All locators follow CLAUDE.md tier hierarchy
- No assertions in any POM file
- All POMs extend BasePage
- Naming follows convention: [PageName]Page.[ext]

$ARGUMENTS
