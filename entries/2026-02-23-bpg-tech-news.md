# BPG Tech News: Vercel Deployment & Pipeline Hardening
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-02-23
**Repo:** bengio777/BPG_Tech-News, bengio777/tech-news-viewer_admin, bengio777/bengio-marketplace
**Status:** Complete
**Tier:** Standard

---

## 1. Problem Statement

The tech news dashboard only ran on localhost:3000 — accessible only from the Mac that generates the briefings. The goal was to deploy it to Vercel so it could be read from a phone or any device. Secondary goals: fix 14 stale Spotify podcast IDs that were silently failing, complete Phase 5 scheduling with weekly and monthly launchd plists, and add a second email recipient.

## 2. Solution

**Vercel deployment** — Rewrote the dashboard data layer (`briefings.ts`) with a dual-mode architecture: filesystem for local dev, GitHub API for Vercel. Content is fetched at build time (static generation), and a Vercel deploy hook is triggered by the pipeline after each briefing push to rebuild the site. No runtime API calls, no new dependencies.

**Spotify fix** — Used the Spotify Search API to look up correct show IDs for all 18 tracked podcasts. 14 of 18 were stale and returning 404s. Also caught a duplicate ID conflict (Latent Space and Cognitive Revolution shared the same ID) and a wrong-show result (Smashing Security search returned Darknet Diaries).

**Phase 5 scheduling** — Created two new launchd plists: weekly (Sunday 8 AM) and monthly (1st of month 9 AM). Loaded into launchctl alongside the existing daily plist.

## 3. Architecture

```
Pipeline (Mac)                        Vercel
─────────────                         ──────
run-briefing.sh                       tech-news-viewer
  ├─ Pre-fetch (Python)                 ├─ briefings.ts (dual data layer)
  ├─ claude -p (Sonnet)                 │   ├─ BRIEFINGS_DIR → filesystem
  ├─ git push → BPG_Tech-News_Catalog   │   └─ GITHUB_TOKEN → GitHub API
  └─ curl deploy hook ─────────────────►└─ Static rebuild on hook
```

**Key design decision**: Build-time static generation + deploy hook, not runtime GitHub API calls. Content changes 1-3x/day, so static builds are faster, cheaper, and simpler than SSR with API caching.

**Credential storage**: GitHub PAT and Vercel deploy hook URL stored in macOS Keychain via `security add-generic-password`, retrieved at runtime by `run-briefing.sh`. No secrets in code or config files.

## 4. Component Specifications

### Dual Data Layer (`briefings.ts`)
- **Filesystem path**: Dynamic `import("fs/promises")` when `BRIEFINGS_DIR` is set (local dev)
- **GitHub API path**: Trees API for indexing (`git/trees/main?recursive=1`), Contents API for file reads (base64 decode)
- **Conditional**: `USE_GITHUB = !BRIEFINGS_DIR && !!GITHUB_TOKEN && !!GITHUB_REPO`
- **All 7 exported functions unchanged** — zero impact on components or routes

### Spotify Show ID Fixes (`fetch-podcasts.py`)
- 14/18 IDs corrected via Spotify Search API
- Duplicate ID conflict resolved (Latent Space vs Cognitive Revolution)
- Smashing Security ID manually verified (search returned wrong show)
- Result: 53 items (28 Spotify episodes from 13 shows + 25 Apple Charts) vs previous 6 items

### Scheduling Plists
- `com.bengio.tech-news-briefing-weekly.plist` — Sunday 8 AM, passes "weekly" arg
- `com.bengio.tech-news-briefing-monthly.plist` — 1st of month 9 AM, passes "monthly" arg
- Both use `StartCalendarInterval` and separate log files

### Deploy Hook Integration (`run-briefing.sh`)
- Fires after `claude -p` exits with code 0
- Retrieves hook URL from Keychain at runtime
- Non-fatal: logs warning if hook fails, doesn't block pipeline

## 5. Retrospective

### What was the hardest part or biggest surprise?

Scope creep — again. The core challenge wasn't technical. Claude Code auto-resolved the Spotify stale IDs once API access was configured, and Vercel setup friction was handled by screenshot-loading errors into Claude for troubleshooting. The real tension was that this was an exciting side quest (taking something from localhost to a live website to share with a friend) while several course assignments for Hands-on AI were more directly relevant priorities. The excitement of deploying something live pulled focus.

### Lessons Learned

- **Scope creep awareness.** Exciting side quests (like "let me just deploy this real quick") can snowball into multi-hour sessions. Recognize the pull and timebox it.
- **Screenshot debugging works.** Loading error screenshots directly into Claude Code is an effective troubleshooting pattern — faster than describing the error in text.
- **Claude Code handles data fixes well.** Stale API data (78% of Spotify IDs dead) isn't scary when the agent can auto-resolve by searching the API. Don't manually maintain what can be programmatically fixed.
- **Vercel environment variables need `vercel env add`.** Passing `--env` flags during deploy doesn't persist them. Use the CLI or dashboard to set them at the project level.
- **Dual data layers are clean when conditional.** A single `USE_GITHUB` boolean at the top of the module, with two parallel implementations behind the same interface, keeps the code simple and testable.

### What would you do differently?

Plan the Vercel deployment step earlier. It should have been part of the original architecture, not an afterthought bolted on after the dashboard was already built for local-only use. The dual data layer was straightforward, but the repo/token/hook setup would have been smoother if designed in from the start.

### What's next?

Two priorities:
1. **Debug launchd + `claude -p` hangs.** The stuck daily job (PID running 8+ hours) and the weekly pipeline timeout (30+ min with no output) need investigation.
2. **Build a backend and remove the Mac dependency.** Move the pipeline to the cloud so briefings generate without the Mac running. This is the path to a fully autonomous system.

## 6. Build History

| Time | Milestone |
|------|-----------|
| Session start | Fixed 14 stale Spotify show IDs, resolved duplicate/wrong-show issues |
| Mid-session | Created weekly + monthly launchd plists, loaded into launchctl |
| Mid-session | Added email recipient (nicholaswolfe@gmail.com) |
| Late session | Rewrote briefings.ts with dual filesystem/GitHub data layer |
| Late session | Created GitHub fine-grained PAT, stored in Keychain |
| Late session | Deployed to Vercel, set env vars, verified at tech-news-viewer.vercel.app |
| End session | Added deploy hook to run-briefing.sh, tested rebuild trigger |

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| 3b4b1e9 | 2026-02-22 | fix: update Spotify show IDs in fetch-podcasts.py |
| 7d81094 | 2026-02-22 | feat: add weekly and monthly launchd plists (Phase 5) |
| 37b9e87 | 2026-02-22 | Backup run-briefing.sh and launchd plist to version control |
| e4c3396 | 2026-02-22 | tech-news-briefing v2.0.0: multi-cadence briefings, pre-fetch scripts |
| 1d16d65 | 2026-02-22 | Dashboard rebuild: tabbed briefings, weekly/monthly views, 20px base font |
| f95b93e | 2026-02-23 | feat: dual data layer for Vercel deployment |
| 2c76a74 | 2026-02-23 | feat: add Vercel deploy hook to run-briefing.sh |
