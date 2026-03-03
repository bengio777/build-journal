# Hybrid Tech News Podcast Content Pipeline: Full Implementation
## Build Journal Entry — Full

**Builder:** Ben Giordano
**Build Date:** 2026-03-03
**Platform:** Claude Code plugin (macOS, launchd)
**Status:** Complete — All 30 Tasks Shipped
**Repo:** Tech-News_Podcast__Content-Pipeline__Sub-Agent-POC1
**Tier:** Full

---

## 1. Problem Statement

No multi-agent project in the HOAI Week 3 portfolio demonstrated a true fan-in → shared pipeline → fan-out architecture. Existing projects were siloed: tech-news briefings, podcast summaries, and the Blog Post Skill each produced value independently with no connective system. The result: no path to consistent Substack publishing, no voice reference library for autonomous drafting, no cross-content intelligence layer. The assignment required "Build an Autonomous Agent Workflow with Claude Code Subagents" — which required real subagent orchestration, not sequential skills.

---

## 2. Solution

Built the **Hybrid Tech News Podcast Content Pipeline** — a Claude Code plugin with 11 specialized subagents, 3 execution modes, a 2-phase operating model, a Vercel frontend for draft review, Notion content calendar integration, and macOS launchd scheduling.

**Phase 1 (posts 1–14):** Coached mode. Human-gated coaching at every Amuse-Bouche beat. Voice Capture agent collects reflection notes and writing examples after each post.

**Phase 2 (posts 15+):** Guided mode. Voice Synthesizer runs once after post 14, generating `voice/profile.md`. Drafter and Editor run autonomously grounded in synthesized voice rules.

---

## 3. Architecture

**Pattern:** Orchestrator-Workers. Central orchestrator detects input type and phase, dispatches subagents, state persists in JSON between pipeline pauses.

**3 execution modes:**
- `daily-post` (launchd 7am): briefing → top 3 candidates → `/select [1-3]` → coaching → draft → edit → voice capture → publish
- `/podcast-post [file]` (on-demand): episode → preprocess → coach → draft → edit → voice capture → publish
- `weekly-recap` (launchd Sunday 8pm): aggregate → themes → convergence → surprise gate → publish

**Frontend:** `~/Projects/content-pipeline-frontend` — static Next.js site. Publisher auto-pushes drafts; Vercel auto-deploys. Live at `https://content-pipeline-frontend-two.vercel.app`.

---

## 4. Key Lessons Learned

**Vercel stale `.vercel/project.json` causes silent misdeployment.** When forking a repo, the cloned `.vercel/` directory points to the original project. Always `rm -rf .vercel` before `vercel link` on a new repo.

**Code quality review caught a real production bug.** Missing `notFound()` guard on detail page would have caused 500s for invalid slugs. The review loop was worth the cost.

**Python quoted heredocs don't expand shell variables.** `<< 'PYEOF'` suppresses all expansion. Fix: pass values via env vars (`PENDING_FILE=...`) and read with `os.environ["PENDING_FILE"]`.

**Forked repos have invisible stale references.** Run a global search for the source repo name immediately after forking.

**Test the delivery mechanism before building agents.** launchd smoke test was Task 2 — confirmed `claude -p` fires correctly in launchd's restricted environment before any agents were written.

---

## 5. Build Summary

- **11 agents:** orchestrator, news-preprocessor, podcast-preprocessor, story-selector, story-coach, drafter, editor, voice-capture, voice-synthesizer, publisher, weekly-synthesizer
- **4 skills:** daily-post, podcast-post, select, weekly-recap
- **3 hooks:** pipeline-logger (PostToolUse), stale-state-guard (PreToolUse), check-pending
- **2 launchd plists:** daily (7am), weekly (Sunday 8pm) — loaded and verified
- **1 Vercel frontend:** deployed, auto-deploy on publisher push
- **1 Notion Content Calendar:** created via MCP, DB ID `1e73cbef3f29425ba49bbf952b923179`
- **2 end-to-end tests run:** news pipeline + podcast pipeline, 2 drafts published

---

## 6. Next Steps

- **Weekly pipeline test** (`/weekly-recap`) — run interactively with real week's content
- **Style Agents Plugin** — implementation plan written, execute in parallel session
- **Phase 2 activation** — automatic after post 14 (voice synthesizer detects example count)
- **Stretch goals** — email-reply resumption, autonomous story selection, self-validating editor
