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
