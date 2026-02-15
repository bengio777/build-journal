# Build Journal — Design Document

**Date:** 2026-02-15
**Builder:** Ben
**Status:** Approved, ready for implementation

---

## 1. Problem Statement

When building projects with Claude, valuable context gets lost — architecture decisions, lessons learned, debugging breakthroughs, and the narrative of how something came together. Without a capture system, this knowledge disappears when the session ends. Build Journal solves this by auto-capturing build metadata throughout a session and generating structured retrospectives that persist across projects.

## 2. Solution

A Claude Code plugin that silently tracks build activity during coding sessions, then generates tiered retrospective documents at session close or day's end. Output writes to four destinations: the project repo, a central Build Journal archive repo, Notion, and Google Sheets.

## 3. Activation Model

**SessionStart Hook** — Every session, two questions upfront:

1. "Want Build Journal tracking this session?" → enables silent auto-capture
2. "Want the end-of-session interview?" → flags whether to run the 3-5 targeted questions later

If tracking is declined, the plugin stays dormant for that session.

## 4. Two Trigger Modes

### Full Retrospective (build complete)

- **Triggers on:** "closing out this session", "project is done", "wrapping up the build", or clear session-closing indicators
- Runs the 3-5 question interview (if opted in at session start)
- Generates tiered template (Quick/Standard/Full based on scope)
- Writes to all four destinations

### Daily Recap (pausing mid-project)

- **Triggers on:** "done for the day", "pausing work", "picking this up tomorrow"
- 2-3 minute rapid-fire Q&A: what you accomplished, what's blocking, what's next
- Generates a lighter daily entry
- Appends to the project's ongoing journal

## 5. Auto-Capture (Silent, Throughout Session)

Data sources pulled automatically:

- **Git history:** commits, diffs, branches, timeline
- **Conversation context:** decisions, architecture discussions, problem-solving narrative
- **File changes:** new files, modified files, deletions, file manifest

## 6. Template Tiers

| Tier | Scope | Sections Included |
|------|-------|-------------------|
| **Quick** | Small fixes, tweaks | Problem, Solution, Lessons Learned, Commit Log |
| **Standard** | Feature builds | + Architecture, Component Specs, Build History |
| **Full** | Multi-day projects | + Data Schema, Reusable Pattern, File Manifest, Next Steps |

The skill assesses scope from git activity (commit count, file churn, time span) and asks the user to confirm the tier.

## 7. Interview Questions

### Full Retrospective (3-5 questions, asked if opted in)

- What problem were you solving? (confirms/refines auto-detected problem statement)
- What was the hardest part or biggest surprise?
- Any lessons worth recording for future builds?
- What would you do differently?
- What's next for this project?

### Daily Recap (2-3 rapid-fire questions)

- What did you accomplish today?
- Anything blocking or unresolved?
- What's the plan for next session?

## 8. Output Destinations (Quad-Write)

| Destination | Format | Location |
|-------------|--------|----------|
| Project repo | Markdown | `docs/build-journal/YYYY-MM-DD-<topic>.md` |
| Build Journal repo | Markdown | `entries/YYYY-MM-DD-<project>.md` |
| Notion | Database entry | Metadata: project, date, tier, status, summary |
| Google Sheets | Row | Summary fields for quick scanning/filtering |

## 9. Plugin Structure

```
build-journal/
├── .claude-plugin/
│   └── plugin.json               ← Plugin manifest
├── skills/
│   └── build-journal/
│       └── SKILL.md              ← Main retrospective skill
├── hooks/
│   └── session-start.md          ← 2-question activation prompt
├── entries/                      ← Central archive of all build journals
│   └── YYYY-MM-DD-<project>.md
├── templates/
│   ├── quick.md                  ← Small fixes/tweaks
│   ├── standard.md               ← Feature builds
│   └── full.md                   ← Multi-day projects (all 10 sections)
└── README.md
```

## 10. Reference

The Forget-Me-Not Build Template (`Forget-Me-Not_Build_Template.md`) serves as the gold-standard reference for what a Full-tier entry looks like. Its 10 sections map directly to the Full template.
