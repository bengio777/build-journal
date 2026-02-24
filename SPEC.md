# Build Journal — Project Spec

**Project:** Build Journal

---

## Capabilities Demonstrated

### 1. Plugin architecture with skill, hooks, commands, and templates
**Met.** The project is structured as a Claude Code plugin with a `plugin.json` manifest, a `/build-journal` slash command, session-start hooks, a core SKILL.md, and three tier-specific templates. The plugin pattern allows the skill to be installed at project scope and activated via multiple entry points.
**Evidence:** `.claude-plugin/plugin.json`, `commands/build-journal.md`, `hooks/hooks.json`, `skills/build-journal/SKILL.md`, `templates/quick.md`, `templates/standard.md`, `templates/full.md`

### 2. Multi-modal trigger detection
**Met.** Three independent entry points converge on the same skill: explicit slash command (`/build-journal`), natural language detection via skill description matching, and wrap-up signal detection that fires regardless of prior activation state.
**Evidence:** `skills/build-journal/SKILL.md` (description field with trigger phrases), `commands/build-journal.md`

### 3. Automated data gathering with graceful fallback
**Met.** The skill auto-gathers git history, file diffs, repo metadata, and conversation context before any human interview. If git is unavailable, the workflow falls back to interview-only mode rather than failing.
**Evidence:** `skills/build-journal/SKILL.md` (Step 1: Auto-Gather Data)

### 4. Tiered output generation from templates
**Met.** Three template tiers (Quick: 4 sections, Standard: 7 sections, Full: 10 sections) scale output depth to match project scope. Tier is recommended automatically based on commit count and file changes, then confirmed by the user.
**Evidence:** `templates/quick.md`, `templates/standard.md`, `templates/full.md`, `skills/build-journal/SKILL.md` (Step 2: Assess Scope)

### 5. Quad-write to four concurrent destinations
**Met.** Every entry is written to project repo, central archive, Notion, and Google Sheets concurrently. Each destination is independent — if one fails, the others still succeed and the failure is reported.
**Evidence:** `skills/build-journal/SKILL.md` (Step 5: Quad-Write Output), `WORKFLOW-DEFINITION.md` (Step 7)

### 6. Human-in-the-loop gates at decision points
**Met.** Three explicit human checkpoints: activation (Step 1), tier confirmation (Step 4), and interview responses (Step 5). The AI never generates output without user confirmation of scope.
**Evidence:** `WORKFLOW-DEFINITION.md` (Steps 1, 4, 5)

---

## Deliverables

| # | Deliverable | File | Status |
|---|-------------|------|--------|
| 1 | Plugin manifest | `.claude-plugin/plugin.json` | Complete |
| 2 | Core skill definition | `skills/build-journal/SKILL.md` | Complete |
| 3 | Slash command | `commands/build-journal.md` | Complete |
| 4 | Session-start hook | `hooks/hooks.json`, `hooks/session-start.sh` | Complete |
| 5 | Quick template | `templates/quick.md` | Complete |
| 6 | Standard template | `templates/standard.md` | Complete |
| 7 | Full template | `templates/full.md` | Complete |
| 8 | Workflow definition (SOP) | `WORKFLOW-DEFINITION.md` | Complete |
| 9 | Building block spec | `BUILDING-BLOCK-SPEC.md` | Complete |
| 10 | Project spec | `SPEC.md` | Complete |
| 11 | README | `README.md` | Complete |

---

## Review Criteria

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Skill triggers on wrap-up signals, natural language, and slash command | Pass | `SKILL.md` description field covers all three paths |
| Auto-gathers git data without user input | Pass | `SKILL.md` Step 1 runs git commands automatically |
| Tier recommendation based on quantitative signals | Pass | Commit count / file count thresholds in `SKILL.md` Step 2 |
| Templates produce valid, complete markdown | Pass | All three templates in `templates/` with structured sections |
| Quad-write succeeds to at least 1 destination on any run | Pass | Independent write logic with per-destination failure handling |
| Human confirms tier before generation | Pass | Step 4 in workflow is an explicit HITL gate |
| SOP follows 8-section template | Pass | `WORKFLOW-DEFINITION.md` has all required sections |
| Plugin installs and activates in Claude Code | Pass | Plugin installed and producing entries in `entries/` directory |

---

## File Inventory

| File | Location | Purpose |
|------|----------|---------|
| `plugin.json` | `.claude-plugin/plugin.json` | Plugin manifest — name, version, entry points |
| `SKILL.md` | `skills/build-journal/SKILL.md` | Core skill — trigger detection, data gathering, interview, generation, quad-write |
| `build-journal.md` | `commands/build-journal.md` | Slash command definition for `/build-journal` |
| `hooks.json` | `hooks/hooks.json` | Hook configuration for session-start tracking |
| `session-start.sh` | `hooks/session-start.sh` | Session-start hook script |
| `quick.md` | `templates/quick.md` | Quick tier template (4 sections) |
| `standard.md` | `templates/standard.md` | Standard tier template (7 sections) |
| `full.md` | `templates/full.md` | Full tier template (10 sections) |
| `WORKFLOW-DEFINITION.md` | `WORKFLOW-DEFINITION.md` | Standard operating procedure |
| `BUILDING-BLOCK-SPEC.md` | `BUILDING-BLOCK-SPEC.md` | AI building block specification |
| `SPEC.md` | `SPEC.md` | Project spec (this file) |
| `README.md` | `README.md` | Project overview and installation guide |
| Retrospective entries | `entries/` | Central archive of generated retrospectives |
