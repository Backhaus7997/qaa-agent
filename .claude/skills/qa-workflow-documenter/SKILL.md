---
name: qa-workflow-documenter
description: QA Workflow Documenter. Generates structured QA workflow documentation with decision trees, playbooks, and AI interaction protocols. Use when user wants to document QA processes, create testing playbooks, define workflow steps, document QA procedures, create decision trees for testing, or standardize QA processes. Triggers on "document workflow", "QA process", "testing playbook", "workflow documentation", "QA procedures", "decision tree", "standardize process", "document QA steps".
---

# QA Workflow Documenter

## Purpose

Generate structured, AI-specific QA workflow documentation with decision trees, playbooks, and AI interaction protocols. Every step answers: WHO does it, WHAT they do, WHAT input they need, WHAT output they produce.

## Core Principle

**AI-first language**: Use precise verbs — scan, extract, classify, generate, validate. Never use vague terms like "review", "check", "handle".

## Output Artifacts

1. **WORKFLOW_[NAME].md** — Step-by-step workflow with decision gates
2. **DECISION_TREE.md** — Visual decision trees for key branch points
3. **AI_PROMPTS_CATALOG.md** — Reusable prompt patterns for each workflow step
4. **CHECKLIST.md** — Pre/post verification checklists

## Workflow Template Structure

### Header Block
```markdown
# Workflow: [Name]
**Version**: [semver]
**Applies to**: [project types / tech stacks]
**Prerequisites**: [what must exist before starting]
**Estimated duration**: [time range]
**Actors**: [AI Agent, QA Engineer, Team Lead]
```

### Step Format
```markdown
## Step N: [Name]
**Actor**: [who executes this step]
**Input**: [what they receive]
**Action**: [precise description using action verbs]
**Output**: [what they produce]
**Decision Gate**: [condition to proceed vs branch]

### AI Prompt Pattern
[If this step involves an AI agent, include the prompt template]
```

## Workflow Types

### 1. Repository Intake Workflow
New repo arrives -> scan -> classify -> assess risk -> recommend strategy

### 2. Test Case Generation Workflow
Analysis done -> select targets -> generate cases -> validate -> deliver

### 3. QA Repo Bootstrap Workflow
Blueprint ready -> create structure -> generate configs -> seed initial tests

### 4. Validation & Bug Triage Workflow
Tests generated -> run -> classify failures -> fix loop -> report

### 5. Test Maintenance Workflow
Existing tests -> audit -> prioritize fixes -> apply -> verify

## Decision Tree Format

```markdown
## Decision: [What decision]

```
[Question]?
├── YES → [Action A]
│   └── [Sub-question]?
│       ├── YES → [Action A1]
│       └── NO → [Action A2]
└── NO → [Action B]
```
```

## Quality Gate

- [ ] Every step has Actor, Input, Action, Output
- [ ] No vague verbs (review → scan + classify, check → validate against criteria)
- [ ] Decision gates have clear YES/NO branches
- [ ] AI prompt patterns included for AI-executed steps
- [ ] Prerequisites listed for every workflow
- [ ] Output artifacts named and described
