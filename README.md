# Build Journal

A Claude Code plugin that auto-captures build metadata during coding sessions and generates tiered retrospective documents with quad-write output.

## What It Does

Watches for session-closing signals (or explicit activation via `/build-journal`), auto-gathers git history and conversation context, runs an optional interview, and writes structured retrospectives to four destinations simultaneously.

## Installation

```bash
claude plugin add ~/Projects/build-journal
```

Or add via the bengio-marketplace:

```bash
claude plugin marketplace add https://github.com/bengio777/bengio-marketplace
claude plugin add build-journal@bengio-marketplace
```

## Usage

### Entry Points

| Method | When to Use |
|--------|------------|
| `/build-journal` | Explicit activation — confirms tracking, asks about interview |
| Natural language ("build journal", "track this build") | Contextual activation mid-session |
| Wrap-up signals ("closing out", "done for the day") | Auto-fires at session end regardless of prior activation |

### Two Modes

| Mode | Trigger | Output |
|------|---------|--------|
| **Full Retrospective** | Build/project is complete | Tiered entry (Quick/Standard/Full) with 3-5 question interview |
| **Daily Recap** | Pausing mid-project | Lightweight summary with 2-3 rapid-fire questions |

## Template Tiers

| Tier | Best For | Sections |
|------|----------|----------|
| **Quick** | Small fixes, tweaks (1-3 commits) | Problem, Solution, Lessons, Commits |
| **Standard** | Feature builds (4-10 commits) | + Architecture, Components, Build History |
| **Full** | Multi-day projects (10+ commits) | + Data Schema, File Manifest, Reusable Pattern, Next Steps |

## Quad-Write Destinations

Every entry is written to four places concurrently:

1. **Project repo** — `docs/build-journal/YYYY-MM-DD-<topic>.md`
2. **Central archive** — `~/Projects/build-journal/entries/YYYY-MM-DD-<project>.md`
3. **Notion** — Build Journal Tracker database
4. **Google Sheets** — Build Journal Tracker spreadsheet

If any destination fails, the others still succeed.

## Project Structure

```
build-journal/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   └── build-journal.md     # /build-journal slash command
├── docs/
│   └── plans/               # Design and implementation docs
├── entries/                  # Central archive of all retrospectives
├── hooks/
│   ├── hooks.json            # SessionStart hook (legacy)
│   └── session-start.sh
├── skills/
│   └── build-journal/
│       └── SKILL.md          # Core retrospective logic
├── templates/
│   ├── quick.md              # 4-section tier
│   ├── standard.md           # 7-section tier
│   └── full.md               # 10-section tier
├── README.md
└── WORKFLOW-DEFINITION.md    # SOP for the Build Journal workflow
```

## SOP

Full standard operating procedure: [WORKFLOW-DEFINITION.md](WORKFLOW-DEFINITION.md)

Also indexed at [workflow-definitions/build-journal.md](https://github.com/bengio777/workflow-definitions)

## Author

Ben Giordano — bengio777@gmail.com
