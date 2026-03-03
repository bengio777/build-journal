# Hybrid Tech News Podcast Content Pipeline: Design and Planning Phase
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-03
**Repo:** Tech-News_Podcast__Content-Pipeline__Sub-Agent-POC1
**Status:** Planning Complete — Ready for Implementation
**Tier:** Standard

---

## 1. Problem Statement

No multi-agent project in the HOAI Week 3 portfolio demonstrated a true fan-in → shared pipeline → fan-out architecture. Existing projects (tech-news-briefing, podcast-summaries, Blog Post Skill) were siloed — each producing value independently with no system connecting them. The result: content was being consumed and generated with no path to consistent Substack publishing, no voice reference library for autonomous drafting, and no cross-content intelligence layer to identify themes and convergences across news and podcasts.

The assignment requirement — "Build an Autonomous Agent Workflow with Claude Code Subagents" — needed a project that demonstrated real subagent orchestration, not just sequential skills.

---

## 2. Solution

Designed the **Hybrid Tech News Podcast Content Pipeline** (`Tech-News_Podcast__Content-Pipeline__Sub-Agent-POC1`) — a new Claude Code plugin with 11 specialized subagents, 3 execution modes, and a 2-phase operating model.

The key architectural insight: the Blog Post Skill's 4 sub-agents are a shared processing pipeline. The new project adds upstream input adapters (news preprocessor, podcast preprocessor) and a content router, leaving the shared pipeline untouched. Fan-in → shared processing → fan-out.

**Phase 1 (posts 1–14):** Coached mode. Full human-gated coaching at every Amuse-Bouche beat. Voice Capture agent collects reflection notes and examples after each post. Builds the voice reference library from scratch.

**Phase 2 (posts 15+):** Guided mode. Voice Synthesizer runs once after post 14, generating `voice/profile.md`. Drafter and Editor run autonomously, grounded in real examples and synthesized voice rules. Single angle-approval gate only.

---

## 3. Architecture

**Pattern:** Orchestrator-Workers. Central orchestrator detects input type (news/podcast) and operating phase, dispatches specialized subagents, state persists in JSON files between pipeline pauses.

**3 execution modes:**
- **Daily news** (launchd 7am): briefing → top 3 candidates → selection email → `/select [1-3]` → Story Coach → Drafter → Editor → Voice Capture → Publisher
- **Podcast on-demand** (`/podcast-post [file]`): episode file → Story Coach → Drafter → Editor → Voice Capture → Publisher (skips Story Selector)
- **Weekly recap** (launchd Sunday 8pm): aggregates week's drafts + podcast summaries → theme extraction → convergence detection → "surprise of week" gate → Publisher

**Stack:** Claude Code plugin (markdown agents/skills) + shell hooks + JSON state + Python (Gmail SMTP) + Next.js 15 + Tailwind (Vercel frontend) + Notion MCP (content calendar metadata) + launchd (macOS scheduling)

**Source paths (read-only):**
- Tech news briefings: `/Users/benjamingiordano/BPG_Tech-News/YYYY/week-WW/YYYY-MM-DD.md`
- Podcast summaries: `/Users/benjamingiordano/Projects/podcast-summaries/content/shows/`

---

## 4. Component Specifications

| Component | Role | Phase |
|---|---|---|
| Orchestrator | Entry point. Detects phase, routes to preprocessor. Stale state check. | Both |
| News Preprocessor | Reads briefing, scores top 3 by recency + novelty + angle potential | Both |
| Podcast Preprocessor | Reads episode .md, extracts themes + memorable moments + 3 angle candidates | Both |
| Story Selector | Formats 3 candidates into selection email (with `/select` instructions), writes `pending-selection.json`, pauses pipeline | Both |
| Story Coach | Phase 1: 5 checkpoints (angle → anchor → details → dismount → hook). Phase 2: single angle approval. | Both |
| Drafter | Phase 1: section-by-section with reaction prompts. Phase 2: autonomous using `voice/profile.md` + examples. | Both |
| Editor | Phase 1: accept/reject per edit. Phase 2: autonomous brevity + hook + dismount pass. | Both |
| Voice Capture | Post-publish: 2 reflection questions. Saves to `voice/notes/` + `voice/examples/`. | Phase 1 only |
| Voice Synthesizer | Runs once after post 14. Writes `voice/profile.md`. Activates Phase 2. | Runs once |
| Publisher | Saves draft locally → GitHub commit → Notion calendar row. GitHub + Notion are non-critical. | Both |
| Weekly Synthesizer | Aggregates week's content, extracts themes, detects news-podcast convergences, prompts surprise gate, appends `themes.md`. | Both |

**Skills:** `daily-post`, `podcast-post`, `select [1-3]`, `weekly-recap`

**Hooks:** Pipeline Logger (PostToolUse → `pipeline-log.json`), Stale State Guard (PreToolUse → blocks stale runs)

**State files:** `pending-selection.json`, `pipeline-log.json`, `themes.md`, `selection-history.json`

---

## 5. Lessons Learned

**The absence of voice examples is a foundational constraint, not a detail.** The decision to build Phase 1 as a coaching mode wasn't a feature addition — it was architecturally necessary. No voice reference library means no grounded autonomous drafting. The 2-phase design emerged from this constraint and made the entire system stronger.

**Email-reply resumption is the right long-term vision, wrong MVP scope.** True async email-reply triggering requires inbound webhook infrastructure that adds meaningful complexity without changing the core pipeline. Deferred to Stretch Goal #1: email notification + `/select` command gives 90% of the experience at 20% of the complexity.

**The weekly synthesis layer elevated the design from pipeline to intelligence layer.** Adding theme extraction, convergence detection, and forward brief generation transformed the weekly recap from "summary of what I wrote" to "what patterns are emerging across my content consumption." This was the design moment that made the project worth building.

**Test the delivery mechanism before building agents.** launchd smoke test is Task 2 in Phase 0 — before any agents are written. Per CLAUDE.md standard: don't build 5 phases of code before confirming the scheduled trigger works.

**Naming iterations are worth it.** Three name revisions: "content pipeline" → "signal-to-story" (my suggestion) → "Hybrid Tech News Podcast Content Pipeline" (Ben's preference) → `Tech-News_Podcast__Content-Pipeline__Sub-Agent-POC1` (repo name). The final name is specific, searchable, and reflects both the content type and the architectural experiment.

**One clarifying question at a time prevents scope explosion.** The brainstorming session took 15+ questions across 30+ minutes. Each answer reshaped the architecture. Asking one question at a time prevented contradictory requirements from accumulating.

---

## 6. Build History

Single planning session, 2026-03-03.

1. Audited all 6 existing HOAI projects for subagent usage — found: none deployed, MEDDPICC designed but not coded
2. Identified 3 multi-agent linkage candidates (A: news→post pipeline, B: MEDDPICC research, C: podcast→post pipeline)
3. Clarified A vs C — source/destination flip; decided to unify both into a single fan-in architecture
4. Brainstormed unified architecture: content router + two preprocessors + shared Blog Post pipeline
5. Selected Approach A (plugin with orchestrator + specialized subagents) from 3 options
6. Conducted 4-section design review: Architecture → Agents → Data Flow → Error Handling/Testing
7. Added 2-phase voice-building model after discovering no voice reference examples exist
8. Scoped 3 stretch goals: email-reply resumption, autonomous story selection, self-validating editor
9. Created project directory `Tech-News_Podcast__Content-Pipeline__Sub-Agent-POC1`
10. Wrote and committed design document (279 lines)
11. Wrote and committed implementation plan (30 tasks, 7 phases, 2,169 lines)

---

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| 8c6b066 | 2026-03-03 | docs: add implementation plan (30 tasks, 7 phases) |
| 882bfb1 | 2026-03-03 | docs: add design document for Hybrid Tech News Podcast Content Pipeline |
