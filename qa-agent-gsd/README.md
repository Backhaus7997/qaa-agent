# QA Agent

QA automation agent powered by GSD + Claude Code.

## How It Works

The `CLAUDE.md` file contains all QA standards (POM rules, locator hierarchy, assertion rules, naming conventions, test pyramid). Claude Code reads it automatically every time you open the project. You don't need to tell it anything — it already knows.

The `specs/` folder contains GSD specs for specific QA tasks. You run them with `/gsd:quick`.

## Prerequisites

- Claude Code (CLI or VS Code extension)
- GSD installed (`npx get-shit-done-cc@latest --global`)

## Setup

Copy `CLAUDE.md` and `specs/` into your QA project root:

```
your-qa-repo/
├── CLAUDE.md        ← copy this
├── specs/           ← copy this folder
│   ├── qa-analyze.md
│   ├── create-tests.md
│   └── update-tests.md
└── ... (your tests)
```

## Usage

Open Claude Code in your project, then:

**Analyze a repo:**
```
/gsd:quick run the qa-analyze spec against this repo
```

**Create tests for a feature:**
```
/gsd:quick run the create-tests spec for the login feature
```

**Improve existing tests:**
```
/gsd:quick run the update-tests spec on the tests/e2e folder
```

That's it. GSD handles the planning and execution, CLAUDE.md provides the QA knowledge.
