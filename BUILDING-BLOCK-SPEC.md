# AI Building Block Spec: Build Journal

## Execution Pattern
**Recommended Pattern:** Skill-Powered Prompt (plugin-hosted)
**Reasoning:**
- The core logic lives in a single SKILL.md file with clear phases (gather, assess, interview, generate, write)
- The plugin wrapper provides slash command entry, hooks for session detection, and template access
- No multi-agent orchestration needed — one skill handles the full flow
- Human-in-the-loop gates (tier confirmation, interview) fit the skill pattern naturally
- Templates are static assets loaded by the skill, not separate agents

---

## Scenario Summary
| Field | Value |
|-------|-------|
| **Workflow Name** | Build Journal |
| **Description** | Auto-capture build metadata during coding sessions and generate tiered retrospective documents with quad-write output to four destinations. |
| **Process Outcome** | Tiered retrospective entry written to project repo, central archive, Notion, and Google Sheets. |
| **Trigger** | User signals session wrap-up or explicitly activates via `/build-journal` or natural language. |
| **Type** | Augmented |
| **Business Process** | Engineering Productivity / Documentation |

---

## Step-by-Step Decomposition
| Step | Name | Autonomy Level | Building Block(s) | Tools / Connectors | Skill Candidate | HITL Gate |
|------|------|---------------|-------------------|-------------------|----------------|-----------|
| 1 | Activate Build Journal | Human | Plugin (slash command), Skill (trigger detection) | Claude Code CLI | — | User initiates |
| 2 | Auto-gather git data | AI-Deterministic | Skill | Git CLI | `build-journal` | — |
| 3 | Assess scope & recommend tier | AI-Deterministic | Skill | — | `build-journal` | — |
| 4 | Confirm tier selection | Human | — | — | — | User confirms or overrides |
| 5 | Run interview | AI + Human | Skill | AskUserQuestion | `build-journal` | User provides answers |
| 6 | Generate retrospective | AI-Semi-Autonomous | Skill, Templates | File system | `build-journal` | — |
| 7 | Quad-write to all destinations | AI-Semi-Autonomous | Skill, MCP connectors | Git CLI, Notion MCP, Google Sheets MCP | `build-journal` | — |
| 8 | Confirm completion | AI-Deterministic | Skill | — | `build-journal` | — |

## Autonomy Spectrum Summary

```
|--Human-----------|--AI-Deterministic--------|--AI-Semi-Autonomous--|--AI-Autonomous--|
    1, 4, 5              2, 3, 8                     6, 7
```

| Level | Steps | Count |
|-------|-------|-------|
| **Human** | Steps 1, 4, 5 | 3 |
| **AI-Deterministic** | Steps 2, 3, 8 | 3 |
| **AI-Semi-Autonomous** (with human review) | Steps 6, 7 | 2 |
| **AI-Autonomous** | — | 0 |

---

## Skill Candidates
### `build-journal`
- **Purpose:** Orchestrate the full retrospective lifecycle — from data gathering through multi-destination output.
- **Inputs:**

| Input | Source | Required |
|-------|--------|----------|
| Trigger signal | User (wrap-up phrase, slash command, natural language) | Yes |
| Tier confirmation | User (confirm or override) | Yes |
| Interview responses | User (3-5 or 2-3 answers) | Yes (if opted in) |
| Git history | Git CLI (auto-gathered) | No — graceful fallback |
| Conversation context | Current Claude session | Yes |

- **Outputs:**

| Output | Destination | Format |
|--------|-------------|--------|
| Retrospective entry | Project repo `docs/build-journal/` | Markdown |
| Central archive copy | `~/Projects/build-journal/entries/` | Markdown |
| Database entry | Notion — Build Journal Tracker | Page with properties |
| Summary row | Google Sheets — Build Journal Tracker | Spreadsheet row |
| Confirmation | Claude response | Text |

- **Decision Logic:**
  - Tier selection: 1-3 commits = Quick, 4-10 = Standard, 10+ = Full
  - Mode detection: "project done" triggers Full Retrospective; "done for the day" triggers Daily Recap
  - Interview skip: questions are omitted when conversation context already provides the answer

- **Failure Modes:**

| Failure | Impact | Handling |
|---------|--------|----------|
| Git repo not initialized | No auto-gathered data | Skip git commands; rely on interview |
| Notion MCP unavailable | 1 of 4 destinations skipped | Write to remaining 3; report skip |
| Google Sheets MCP unavailable | 1 of 4 destinations skipped | Write to remaining 3; report skip |
| Central archive path not found | 1 of 4 destinations skipped | Write to remaining 3; remind user |
| Template variables unpopulated | Broken output | Quality check catches `{{PLACEHOLDER}}` remnants before write |

---

## Step Sequence and Dependencies

```
Step 1: Activate Build Journal [Human]
    │
    ▼
Step 2: Auto-gather git data [AI]
    │
    ▼
Step 3: Assess scope & recommend tier [AI]
    │
    ▼
Step 4: Confirm tier selection [Human]
    │
    ▼
Step 5: Run interview [AI + Human]
    │
    ▼
Step 6: Generate retrospective [AI]
    │
    ▼
Step 7: Quad-write to all destinations [AI]
    │
    ▼
Step 8: Confirm completion [AI]
```

### Dependency Map

| Step | Depends On |
|------|-----------|
| Step 1 | Trigger (user signal) |
| Step 2 | Step 1 (activation) |
| Step 3 | Step 2 (git data collected) |
| Step 4 | Step 3 (tier recommendation presented) |
| Step 5 | Step 4 (tier confirmed) |
| Step 6 | Steps 2 + 5 (data + interview responses) |
| Step 7 | Step 6 (document generated) |
| Step 8 | Step 7 (writes attempted) |

### Parallel Opportunities
- Steps 2 and 3 could overlap — tier assessment begins as data streams in.
- Step 7 quad-write destinations execute concurrently (4 parallel writes).

### Critical Path
Activate (1) → Gather (2) → Assess (3) → Confirm (4) → Interview (5) → Generate (6) → Write (7) → Confirm (8)

---

## Prerequisites
- Claude Code with `build-journal` plugin installed at project scope
- Git repo initialized in the project being tracked
- Access to Notion "Build Journal Tracker" database
- Access to Google Sheets "Build Journal Tracker" spreadsheet

## Context Inventory

| Artifact | Type | Used By Steps | Status |
|----------|------|---------------|--------|
| SKILL.md | Skill definition | 2-8 | Exists |
| quick.md | Template | 6 | Exists |
| standard.md | Template | 6 | Exists |
| full.md | Template | 6 | Exists |
| plugin.json | Plugin manifest | 1 | Exists |
| build-journal.md (command) | Slash command | 1 | Exists |
| hooks.json | Hook config | 1 | Exists |

## Tools and Connectors

| Tool / Connector | Purpose | Used By Steps | Status |
|-----------------|---------|---------------|--------|
| Git CLI | Commit history, file diffs, repo metadata | 2 | Available |
| Notion MCP | Create page in Build Journal Tracker | 7 | Available |
| Google Sheets MCP | Append row to Build Journal Tracker | 7 | Available |
| File system | Read templates, write markdown files | 6, 7 | Available |

## Recommended Implementation Order
1. SKILL.md with data gathering and interview logic
2. Three tier templates (quick, standard, full)
3. Plugin manifest and slash command
4. Quad-write to local destinations (project repo + central archive)
5. Notion MCP integration
6. Google Sheets MCP integration
7. Hook for session-start tracking

## Where to Run
**Platform:** Claude Code (plugin)
**GitHub:** bengio777/build-journal
**Entry points:** `/build-journal` slash command, natural language triggers, wrap-up signal detection
