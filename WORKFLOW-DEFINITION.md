# Build Journal

**Status:** Deployed
**Type:** Augmented
**Business Process:** Engineering Productivity / Documentation
**Trigger:** User signals session wrap-up or explicitly activates Build Journal
**Process Outcome:** Tiered retrospective entry written to four destinations (project repo, central archive, Notion, Google Sheets)

**Assets Used:**
- build-journal (Claude Code Plugin — orchestrates skill, hooks, and templates)
- build-journal skill (SKILL.md — main retrospective logic)
- Quick / Standard / Full templates

---

## Overview

Auto-capture build metadata during coding sessions and generate structured retrospective documents. Two modes: Full Retrospective (build/project complete) and Daily Recap (pausing mid-project). Output writes to four destinations simultaneously for redundancy and discoverability.

## Prerequisites

- [ ] Claude Code with `build-journal` plugin installed at project scope
- [ ] Git repo initialized in the project being tracked
- [ ] Access to Notion "Build Journal Tracker" database
- [ ] Access to Google Sheets "Build Journal Tracker" spreadsheet

## Trigger

**When:** User signals session wrap-up, explicitly says "/build-journal", or uses a natural language trigger phrase
**Frequency:** On-demand — runs at the end of any coding session

---

## Procedure

### Step 1: Activate Build Journal (Human)

Choose your entry path:

- **Slash command:** `/build-journal` — explicit activation; confirms tracking is on and asks about the end-of-session interview
- **Natural language:** Say "build journal", "start build journal", "track this build", "let's capture what we're building", or similar
- **Wrap-up signal:** Say "closing out", "done for the day", "wrapping up", "project is done" — fires directly without prior activation

**Decision Point:** If the trigger is a wrap-up signal, skip ahead to Step 2 immediately. If it's an activation trigger, confirm tracking and ask: "Want the end-of-session interview when we wrap up?"

### Step 2: Auto-gather build data (AI)

Collect the following automatically before any interview:

1. **Git log** — `git log --oneline` for commits this session
2. **File change summary** — `git diff --stat` for files touched
3. **Repo name** — `git remote get-url origin`
4. **File manifest** — new files created via `git log --diff-filter=A --name-only`
5. **Conversation context** — architecture decisions, problems solved, tools discussed, explicit lessons

### Step 3: Assess scope and recommend tier (AI)

| Signal | Suggests |
|--------|----------|
| 1-3 commits, 1-2 files changed | Quick |
| 4-10 commits, multiple files, single session | Standard |
| 10+ commits, multi-day, multiple components | Full |

Present: "Based on [X commits, Y files], I'd recommend a **[Tier]** entry. Sound right?"

### Step 4: Confirm tier selection (Human)

User confirms or overrides the recommended tier.

### Step 5: Run the interview (AI + Human)

**Full Retrospective (3-5 questions):**
1. "What problem were you solving?"
2. "What was the hardest part or biggest surprise?"
3. "Any lessons worth recording for future builds?"
4. "What would you do differently?"
5. "What's next for this project?"

Skip questions where the conversation context already provides a clear answer.

**Daily Recap (2-3 rapid-fire questions):**
1. "What did you accomplish today?"
2. "Anything blocking or unresolved?"
3. "What's the plan for next session?"

### Step 6: Generate the retrospective (AI)

Render the appropriate template (`quick.md`, `standard.md`, or `full.md`) with auto-gathered data and interview responses. For Daily Recaps, use the lightweight inline format.

### Step 7: Quad-write to all destinations (AI)

Write the generated document to four places concurrently:

1. **Project repo** — `docs/build-journal/YYYY-MM-DD-<topic>.md` (create directory if needed; git add + commit)
2. **Central archive** — `~/Projects/build-journal/entries/YYYY-MM-DD-<project>.md` (git add + commit)
3. **Notion** — Build Journal Tracker database via `notion-create-pages` MCP
4. **Google Sheets** — Build Journal Tracker spreadsheet via MCP or manual

If any destination fails, continue with the others and report what succeeded.

### Step 8: Confirm completion (AI)

Brief confirmation: "Build journal entry saved to [destinations that succeeded]. [N] commits captured, [Tier] tier."

---

## Outputs

| Output | Destination | Format |
|--------|-------------|--------|
| Retrospective entry | Project repo `docs/build-journal/` | Markdown |
| Central archive copy | `~/Projects/build-journal/entries/` | Markdown |
| Database entry | Notion — Build Journal Tracker | Page with properties |
| Summary row | Google Sheets — Build Journal Tracker | Spreadsheet row |
| Confirmation | Claude response | Text |

## Quality Checks

- [ ] Auto-gathered git data accurately reflects the session's work
- [ ] Tier recommendation matches actual project scope
- [ ] All four quad-write destinations received the entry (or failures reported)
- [ ] Template variables fully populated — no `{{PLACEHOLDER}}` text remains
- [ ] Commit messages in the project repo and central archive are descriptive

## When Things Go Wrong

| Problem | Solution |
|---------|----------|
| Git repo not initialized | Skip git auto-gather; interview generates the content manually |
| Notion MCP unavailable | Write to the other 3 destinations; report the skip |
| Google Sheets MCP unavailable | Write to the other 3 destinations; report the skip |
| Tier feels wrong after generation | Regenerate using a different tier template |
| Session had no meaningful work | Decline tracking or generate a minimal Quick entry noting the pause |
| Central archive repo not found | Write to the other 3 destinations; remind user to check path |

---

## Automation Notes

**Platform:** Claude Code (plugin)
**Plugin:** build-journal (v1.0.0)
**GitHub Repository:** bengio777/build-journal

**Entry Points:**
1. `/build-journal` slash command (primary — explicit activation)
2. Natural language triggers via skill description (contextual detection)
3. Wrap-up signal detection (always fires regardless of prior activation)

**Template Tiers:**
- `quick.md` — 4 sections (Problem, Solution, Lessons, Commits)
- `standard.md` — 7 sections (+ Architecture, Components, Build History)
- `full.md` — 10 sections (+ Data Schema, File Manifest, Reusable Pattern, Next Steps)

**Human Checkpoints:** Steps 1, 4, 5 (activation, tier confirmation, interview responses)
**Workflow Type:** Augmented (human-driven, AI-automated capture and generation)
