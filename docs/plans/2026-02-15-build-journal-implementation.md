# Build Journal Plugin — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Claude Code plugin that auto-captures build metadata during sessions and generates tiered retrospective documents with quad-write to project repo, Build Journal repo, Notion, and Google Sheets.

**Architecture:** A plugin with a SessionStart hook (2-question activation prompt), a main skill (retrospective generation with interview + auto-capture), and tiered markdown templates. The hook injects activation context; the skill handles data gathering, interview, template rendering, and quad-write output.

**Tech Stack:** Claude Code plugin system, bash hooks, SKILL.md, Notion MCP, Google Sheets (manual or MCP), Git CLI

---

### Task 1: Create plugin.json Manifest

**Files:**
- Create: `build-journal/.claude-plugin/plugin.json`

**Step 1: Create the plugin manifest**

```json
{
  "name": "build-journal",
  "version": "1.0.0",
  "description": "Auto-captures build metadata during coding sessions and generates tiered retrospective documents. Writes to project repo, central archive, Notion, and Google Sheets.",
  "author": {
    "name": "Ben Giordano",
    "email": "bengio777@gmail.com"
  },
  "repository": "https://github.com/bengio777/build-journal",
  "keywords": ["journal", "retrospective", "build-log", "documentation"],
  "skills": "./skills/",
  "hooks": "./hooks/"
}
```

**Step 2: Verify structure**

Run: `cat build-journal/.claude-plugin/plugin.json | python3 -m json.tool`
Expected: Valid JSON, no errors

**Step 3: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "feat: add plugin manifest"
```

---

### Task 2: Create SessionStart Hook

**Files:**
- Create: `build-journal/hooks/hooks.json`
- Create: `build-journal/hooks/session-start.sh`

**Step 1: Create hooks.json**

```json
{
  "description": "Build Journal session activation hook — asks user if they want tracking and end-of-session interview",
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh",
            "async": false
          }
        ]
      }
    ]
  }
}
```

**Step 2: Create session-start.sh**

This hook outputs JSON that injects context telling Claude to ask the two activation questions. The skill itself handles the actual questions via AskUserQuestion.

```bash
#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Build Journal plugin is active. At the START of this session, before doing any other work, ask the user these two questions using the AskUserQuestion tool (in a single call with both questions):\n\n1. 'Want Build Journal tracking this session?' (Yes / No)\n2. 'Want the end-of-session interview when we wrap up?' (Yes / No)\n\nIf the user declines tracking, do NOT mention Build Journal again this session.\n\nIf the user accepts tracking, watch for session-closing signals throughout the conversation:\n- Full retrospective triggers: 'closing out', 'project is done', 'wrapping up the build', 'session complete'\n- Daily recap triggers: 'done for the day', 'pausing work', 'picking this up tomorrow', 'stopping for now'\n\nWhen you detect these signals, invoke the build-journal skill."
  }
}
EOF

exit 0
```

**Step 3: Make hook executable**

Run: `chmod +x build-journal/hooks/session-start.sh`

**Step 4: Test hook runs without error**

Run: `bash build-journal/hooks/session-start.sh | python3 -m json.tool`
Expected: Valid JSON with `hookSpecificOutput.additionalContext` containing the activation prompt

**Step 5: Commit**

```bash
git add hooks/hooks.json hooks/session-start.sh
git commit -m "feat: add SessionStart hook for session activation"
```

---

### Task 3: Create Template Files

**Files:**
- Create: `build-journal/templates/quick.md`
- Create: `build-journal/templates/standard.md`
- Create: `build-journal/templates/full.md`

**Step 1: Create Quick template**

For small fixes and tweaks. 4 sections.

```markdown
# {{PROJECT_NAME}}: {{TOPIC}}
## Build Journal Entry — Quick

**Builder:** {{BUILDER}}
**Date:** {{DATE}}
**Repo:** {{REPO_NAME}}
**Tier:** Quick

---

## 1. Problem Statement

{{PROBLEM_STATEMENT}}

## 2. Solution

{{SOLUTION}}

## 3. Lessons Learned

{{LESSONS_LEARNED}}

## 4. Commit Log

| Hash | Date | Description |
|------|------|-------------|
{{COMMIT_LOG}}
```

**Step 2: Create Standard template**

For feature builds. 7 sections.

```markdown
# {{PROJECT_NAME}}: {{TOPIC}}
## Build Journal Entry — Standard

**Builder:** {{BUILDER}}
**Date:** {{DATE}}
**Repo:** {{REPO_NAME}}
**Status:** {{STATUS}}
**Tier:** Standard

---

## 1. Problem Statement

{{PROBLEM_STATEMENT}}

## 2. Solution

{{SOLUTION}}

## 3. Architecture

{{ARCHITECTURE}}

## 4. Component Specifications

{{COMPONENT_SPECS}}

## 5. Lessons Learned

{{LESSONS_LEARNED}}

## 6. Build History

{{BUILD_HISTORY}}

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
{{COMMIT_LOG}}
```

**Step 3: Create Full template**

For multi-day projects. All 10 sections. Based on Forget-Me-Not template.

```markdown
# {{PROJECT_NAME}}: {{TOPIC}}
## Build Journal Entry — Full

**Builder:** {{BUILDER}}
**Build Date:** {{DATE}}
**Platform:** {{PLATFORM}}
**Status:** {{STATUS}}
**Repo:** {{REPO_NAME}}
**Tier:** Full

---

## 1. Problem Statement

{{PROBLEM_STATEMENT}}

## 2. Solution

{{SOLUTION}}

## 3. Architecture

{{ARCHITECTURE}}

## 4. Data Schema

{{DATA_SCHEMA}}

## 5. Component Specifications

{{COMPONENT_SPECS}}

## 6. Lessons Learned

{{LESSONS_LEARNED}}

## 7. Build History

{{BUILD_HISTORY}}

## 8. Repository File Manifest

| File Path | Description |
|-----------|-------------|
{{FILE_MANIFEST}}

## 9. Reusable Architecture Pattern

{{REUSABLE_PATTERN}}

## 10. Next Steps

### Completed

{{COMPLETED_ITEMS}}

### Remaining

{{REMAINING_ITEMS}}
```

**Step 4: Commit**

```bash
git add templates/quick.md templates/standard.md templates/full.md
git commit -m "feat: add tiered build journal templates (quick, standard, full)"
```

---

### Task 4: Create the Build Journal Skill (SKILL.md)

**Files:**
- Create: `build-journal/skills/build-journal/SKILL.md`

**Step 1: Write the skill file**

This is the core of the plugin. The skill handles:
- Detecting trigger mode (full retrospective vs daily recap)
- Auto-gathering data from git and conversation context
- Running the interview (if opted in)
- Assessing scope and selecting template tier
- Generating the retrospective
- Quad-writing to all destinations

```markdown
---
name: build-journal
description: >
  Generate a build journal retrospective for the current project. Use this skill
  when the user says "build journal", "generate retrospective", "log this build",
  "capture this session", "closing out this session", "project is done", "wrapping
  up the build", "done for the day", "pausing work", "picking this up tomorrow",
  "stopping for now", or any clear signal that a build session or workday is ending.
  Also trigger when the user explicitly requests a build journal entry.
---

# Build Journal

Generate structured retrospective documents that capture what was built, how, and
what was learned. Two modes: Full Retrospective (build complete) and Daily Recap
(pausing mid-project).

## Detect Trigger Mode

Determine which mode based on the user's language:

**Full Retrospective** — build/project is complete:
- "closing out", "project is done", "wrapping up", "session complete", "build journal"
- Generates a tiered template (Quick/Standard/Full)
- Runs the 3-5 question interview if the user opted in at session start

**Daily Recap** — pausing, not finished:
- "done for the day", "pausing work", "picking this up tomorrow", "stopping for now"
- Runs a 2-3 minute rapid-fire Q&A
- Generates a lighter daily entry

If ambiguous, ask: "Are you wrapping up the project, or just pausing for today?"

## Step 1: Auto-Gather Data

Collect the following automatically before any interview:

### Git Data
Run these commands in the project directory:
- `git log --oneline --since="midnight"` (or full log for retrospective)
- `git log --format="%h|%ad|%s" --date=short` for commit table
- `git diff --stat HEAD~N` for file change summary (N = commits this session)
- `git remote get-url origin` for repo name

### File Manifest
- `find . -type f -not -path './.git/*' -not -path './node_modules/*'` for file listing
- Note new files created this session via `git log --diff-filter=A --name-only`

### Conversation Context
- Review the current conversation for:
  - Architecture decisions and rationale
  - Problems encountered and how they were solved
  - Tools, libraries, or patterns discussed
  - Any explicit "lesson learned" moments

## Step 2: Assess Scope and Select Tier

Based on auto-gathered data, assess the project scope:

| Signal | Suggests |
|--------|----------|
| 1-3 commits, 1-2 files changed | Quick |
| 4-10 commits, multiple files, single session | Standard |
| 10+ commits, multi-day, multiple components | Full |

Present the recommended tier and ask the user to confirm:
"Based on [X commits, Y files, Z sessions], I'd recommend a **[Tier]** entry. Sound right?"

## Step 3: Interview (If Opted In)

### Full Retrospective Interview (3-5 questions)

Use AskUserQuestion with open-ended questions, one at a time:

1. "What problem were you solving?" (refines auto-detected problem statement)
2. "What was the hardest part or biggest surprise?"
3. "Any lessons worth recording for future builds?"
4. "What would you do differently?"
5. "What's next for this project?"

Skip questions where the conversation context already provides a clear answer.
Mention what you found and ask if it's accurate instead.

### Daily Recap Interview (2-3 rapid-fire questions)

Use AskUserQuestion:

1. "What did you accomplish today?"
2. "Anything blocking or unresolved?"
3. "What's the plan for next session?"

## Step 4: Generate the Retrospective

Use the appropriate template from `${CLAUDE_PLUGIN_ROOT}/templates/`:
- `quick.md` for Quick tier
- `standard.md` for Standard tier
- `full.md` for Full tier

Fill in all template variables with auto-gathered data + interview responses.
For Daily Recaps, use a simplified format (no template file needed):

```markdown
# {{PROJECT_NAME}} — Daily Recap
**Date:** {{DATE}}
**Commits today:** {{COMMIT_COUNT}}

## Accomplished
{{ACCOMPLISHMENTS}}

## Blockers / Open Items
{{BLOCKERS}}

## Next Session
{{NEXT_PLANS}}

## Commits
| Hash | Description |
|------|-------------|
{{COMMIT_LOG}}
```

## Step 5: Quad-Write Output

Write the generated document to all four destinations concurrently:

### 1. Project Repo
- Path: `docs/build-journal/YYYY-MM-DD-<topic>.md`
- Create the `docs/build-journal/` directory if it doesn't exist
- Git add and commit: `git commit -m "docs: add build journal entry for <topic>"`

### 2. Build Journal Repo (Central Archive)
- Path: `~/Projects/build-journal/entries/YYYY-MM-DD-<project-name>.md`
- Git add and commit in that repo
- For daily recaps, append to existing entry if one exists for this project

### 3. Notion
- Database: Build Journal Tracker (will be created during setup)
- Fields: Project Name, Date, Tier (Quick/Standard/Full), Status (Complete/In Progress),
  Summary (first 2-3 sentences), Repo URL, Entry Type (Retrospective/Daily Recap)
- Use `notion-create-pages` MCP tool

### 4. Google Sheets
- Spreadsheet: Build Journal Tracker (will be created during setup)
- Columns: Project Name, Date, Tier, Status, Summary, Repo URL, Entry Type, Commit Count
- Use Google Sheets MCP or manual entry

If any destination fails, continue with the others and report what succeeded.

## After Writing

Confirm briefly: "Build journal entry saved to [destinations that succeeded]. [Commit count]
commits captured, [tier] tier."

Keep it short — the user just finished a build and wants to wrap up.
```

**Step 2: Verify skill frontmatter is valid YAML**

Run: `head -5 build-journal/skills/build-journal/SKILL.md`
Expected: Valid YAML frontmatter with `name` and `description`

**Step 3: Commit**

```bash
git add skills/build-journal/SKILL.md
git commit -m "feat: add build-journal skill with auto-capture and interview flow"
```

---

### Task 5: Create GitHub Repo and Push

**Files:**
- No new files

**Step 1: Create the GitHub repo**

Run: `cd ~/Projects/build-journal && gh repo create build-journal --public --source=. --push --description "Claude Code plugin: auto-capture build retrospectives with tiered templates and quad-write output"`

Expected: Repo created at `https://github.com/bengio777/build-journal` (or user's GitHub username)

**Step 2: Verify remote**

Run: `git remote -v`
Expected: origin pointing to the new GitHub repo

---

### Task 6: Create entries/ Directory with .gitkeep

**Files:**
- Create: `build-journal/entries/.gitkeep`

**Step 1: Create the entries directory**

The central archive directory needs to exist in the repo even when empty.

```bash
mkdir -p entries && touch entries/.gitkeep
```

**Step 2: Commit**

```bash
git add entries/.gitkeep
git commit -m "feat: add entries directory for central build journal archive"
```

---

### Task 7: Install Plugin Locally

**Files:**
- No new files created in the plugin repo

**Step 1: Verify the plugin structure is complete**

Run: `find ~/Projects/build-journal -type f -not -path '*/.git/*' | sort`

Expected file tree:
```
.claude-plugin/plugin.json
docs/plans/2026-02-15-build-journal-design.md
docs/plans/2026-02-15-build-journal-implementation.md
entries/.gitkeep
hooks/hooks.json
hooks/session-start.sh
skills/build-journal/SKILL.md
templates/full.md
templates/quick.md
templates/standard.md
```

**Step 2: Install the plugin**

The plugin needs to be registered with Claude Code. Check how existing custom plugins are installed — likely via `claude plugin add` or by adding to the plugins config.

Run: `claude plugin add ~/Projects/build-journal`

If that command doesn't exist, the alternative is symlinking or adding the path to Claude Code's plugin configuration.

**Step 3: Verify plugin appears in Claude Code**

Start a new Claude Code session and verify:
- The SessionStart hook fires and asks the two activation questions
- The `build-journal` skill appears in the available skills list

---

### Task 8: Test End-to-End Flow

**Step 1: Start a new Claude Code session**

Expected: SessionStart hook fires, asks:
1. "Want Build Journal tracking this session?"
2. "Want the end-of-session interview?"

Answer yes to both.

**Step 2: Make a small change in a test project**

Create a test file, commit it — simulate a quick build.

**Step 3: Trigger a retrospective**

Say: "I'm wrapping up this build"

Expected: Skill activates, auto-gathers git data, recommends Quick tier, runs interview, generates entry, writes to project repo and Build Journal repo.

**Step 4: Verify output**

- Check `docs/build-journal/` in the test project for the generated entry
- Check `~/Projects/build-journal/entries/` for the central archive copy
- Verify the markdown follows the Quick template structure

**Step 5: Commit and push**

```bash
cd ~/Projects/build-journal && git add -A && git push
```
