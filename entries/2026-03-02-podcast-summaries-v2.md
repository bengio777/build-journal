# Podcast Summaries: Autonomous Ingestion Pipeline + Content Expansion
## Build Journal Entry — Full

**Builder:** Ben Giordano
**Build Date:** 2026-03-02
**Platform:** Next.js / Vercel / GitHub Actions
**Status:** Complete — pipeline live, 18 episodes catalogued
**Repo:** https://github.com/bengio777/podcast-summaries
**Tier:** Full
**Session:** v2 (continues from v1 build journal, same day)

---

## 1. Problem Statement

The v1 build produced a working site with one real episode. The next problem: ingesting content was still manual, fragile, and required re-teaching Claude how to handle metadata with each new episode. There was no canonical source of truth for fields like `date`, `season`, `episode`, and `duration` — these were being skipped or guessed. Vercel deploys were manual (`vercel --prod`). GitHub had no auto-deploy. And Claude had no persistent permission set, so every fetch was an approval prompt.

The goal: make the ingestion pipeline fully autonomous. Paste episode content → done. No further input required.

---

## 2. Solution

Built a three-layer automation stack on top of the existing Next.js site:

1. **CLAUDE.md as workflow memory.** A project-level `CLAUDE.md` encodes the full ingestion pipeline — per-show metadata sources, frontmatter schema, security review checklist, commit/push sequence, and deploy verification. Claude reads this on session start and executes the full pipeline without prompting.

2. **settings.local.json as a permission whitelist.** Pre-approved domains and bash commands are registered in `.claude/settings.local.json`. Fetching `acquired.fm`, `podcasts.apple.com`, `open.spotify.com`, and running git commands requires zero approval prompts. This file is gitignored by design — permissions are local to the build environment.

3. **GitHub Actions for Vercel auto-deploy.** `.github/workflows/deploy.yml` triggers a production Vercel deploy on every push to main, using three repo secrets (`VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`). No manual `vercel --prod` needed after any commit.

With these three layers in place, the ingestion pipeline is: paste content → Claude parses, fetches metadata from canonical sources, writes file, reviews, commits, pushes → Vercel deploys automatically.

---

## 3. Architecture

```
content/shows/[show]/              Markdown files — the "database"
    index.md                       Show metadata
    YYYY-MM-DD-episode.md          Frontmatter + 8-section body

lib/markdown.ts                    getAllShows(), getShowEpisodes(), getEpisode()
                                   gray-matter + remark + sanitize-html

app/
    page.tsx                       Homepage (show grid)
    shows/[show]/page.tsx          Show landing page
    shows/[show]/[episode]/        Episode detail page

.github/workflows/deploy.yml       GitHub Actions → Vercel auto-deploy on push to main
CLAUDE.md                          Persistent autonomous pipeline instructions
.claude/settings.local.json        Pre-approved permissions (gitignored)
```

**Show/metadata source authority (encoded in CLAUDE.md):**
| Show | Date authority | Season/Episode | Duration |
|------|---------------|---------------|----------|
| Acquired | acquired.fm (Apple is 1 day late) | acquired.fm episode page | podcasts.apple.com |
| My First Million | mfmpod.com | Global sequential numbering | podcasts.apple.com |
| How I Built This | wondery.com | Sequential, no seasons | podcasts.apple.com |

---

## 4. Data Schema

### Episode Frontmatter (all shows)
```yaml
---
title: ""
show: [show-id]
date: "YYYY-MM-DD"       # Quoted — prevents gray-matter auto-parsing as JS Date
guests: []               # Explicit guest research step; don't infer from body text alone
youtube_url: ""          # Full URL or empty string; most Acquired episodes are audio-only
season: ""               # e.g. "Spring 2025", "Season 14", "" for no-season shows
episode: 1               # Integer
duration: "Xh Ym"        # ISO 8601 PT#H#M#S parsed to human-readable
youtube_comments: []     # Empty array; populated manually after ingestion
---
```

### Known Edge Cases
- **Apple Podcasts `P0D` bug:** Some episodes return `"duration":"P0D"` (Meta episode). Fallback: Spotify episode page.
- **Wrong episode ID:** Fetching by show feed ID + episode title match is safer than guessing `?i=` params.
- **Audio-only shows:** Acquired narrative episodes have no YouTube video; only interview specials (Ballmer, Starbucks/Schultz) do.

---

## 5. Component Specifications

### CLAUDE.md (Autonomous Pipeline Orchestrator)
The single most important artifact of this session. Encodes:
- Per-show metadata sources with exact authority hierarchy
- Frontmatter schema with all edge-case notes
- Security review checklist (accuracy, attribution, no hallucinated quotes, schema compliance)
- Commit message format: `"Add [Show]: [Episode Title] ([Season] E[N])"`
- Vercel deployment verification step (`vercel ls` after ~60 seconds)
- One-time Vercel secrets setup instructions for new environments

### .github/workflows/deploy.yml (CI/CD)
Triggered on `push` to `main`. Installs `vercel@latest`, runs `vercel --prod --yes` with three secrets injected as env vars. ~60 second deploy time. No Node version pinning needed — Vercel CLI handles runtime.

### settings.local.json (Permission Layer)
Pre-approved Bash commands: `git add*`, `git commit*`, `git push*`, `git status*`, `git diff*`, `git log*`, `git mv*`, `vercel*`, `npm run build`. Pre-approved WebFetch domains: `acquired.fm`, `podcasts.apple.com`, `open.spotify.com`. Plus `WebSearch` (unrestricted). Gitignored — these permissions are environment-local, not committed.

### Content Expansion (this session)
| Show | Episodes added | Notes |
|------|---------------|-------|
| Acquired | 12 (v1 had 0 real) | Season + episode + duration added to all |
| My First Million | 5 real (+ ep. 511 from v1) | ep. 794–799 range |
| How I Built This | 0 new | Placeholder only |

Total: 18 real episodes catalogued across 3 shows.

---

## 6. Lessons Learned

### CLAUDE.md is project memory
The most durable lesson: encoding the pipeline in CLAUDE.md means you never re-explain workflow rules. Claude reads it on session start and executes. This is the right layer for workflow instructions — not the conversation, not a README, not comments in code. CLAUDE.md = the persistent brain of the automation.

### settings.local.json is gitignored by design — use this
The fact that `.claude/settings.local.json` is gitignored is a feature, not a limitation. It means permission sets are scoped to the local build environment. Don't try to commit them. This makes the permission layer: explicit (you know exactly what's pre-approved), local (doesn't pollute the repo), and durable (persists across sessions on this machine).

### Test the delivery mechanism before building features
Don't build 5 phases of content and pipeline before confirming Vercel will actually deploy. In this build, auto-deploy wasn't working for 40+ minutes before the root cause was diagnosed (GitHub → Vercel integration not connected; fix: GitHub Actions workflow). The right order: smoke test the deploy path first, then build content on top of it.

### Source authority matters — always identify the canonical source per field
Apple Podcasts dates are consistently 1 day late vs. acquired.fm canonical dates. This caused a batch of 7 episodes to be committed with wrong dates before being corrected in a follow-up commit. Rule: for every metadata field, explicitly name the canonical source and document it in CLAUDE.md. Never infer from secondary sources.

### Disambiguation before ingestion
When two episodes share a subject (TSMC narrative vs. TSMC interview), parse structural signals before writing the file. The interview episode has the subject as a "Voice" (Section 2); the narrative episode has them as a "Subject" (Section 3). Same show, same topic — different episode type and different metadata treatment.

---

## 7. Build History (this session)

| # | Commit | Description |
|---|--------|-------------|
| 1 | `da3c82b` | Add 3 My First Million episodes (ep. 795, 798, 799) |
| 2 | `532486f` | Add 2 My First Million episodes (ep. 794, 796) |
| 3 | `736d7fa` | Add 5 Acquired podcast episodes from Summer/Fall 2025 |
| 4 | `e6eaea8` | Add 7 Acquired podcast episodes from 2024 |
| 5 | `52a4252` | Fix dates on 7 new Acquired episodes to match acquired.fm |
| 6 | `5437158` | Redesign UI with dark header band and improved readability |
| 7 | `6ba5d02` | Add season, episode, and duration metadata to all Acquired episodes |
| 8 | `f2cbdb8` | Add project CLAUDE.md with autonomous ingestion workflow |
| 9 | `e439e33` | Expand pipeline: auto-deploy, security review, all shows, delete Nike placeholder |
| 10 | `3a1658a` | Test auto-deploy via GitHub Actions |
| 11 | `adf0d81` | Add Acquired: Renaissance Technologies (S14 E3) |
| 12 | `bfb2b09` | Add Acquired: Rolex (Spring 2025 E2) |
| 13 | `409f20d` | Add Acquired: Starbucks with Howard Schultz (S14 E5) |
| 14 | `f66e896` | Add Acquired: TSMC Remastered (S9 E3, Jan 2025) |
| 15 | `b02b5a3` | Add Acquired: TSMC Founder Morris Chang (Spring 2025 E1) |

---

## 8. Repository File Manifest

| File Path | Description |
|-----------|-------------|
| `CLAUDE.md` | Autonomous ingestion pipeline instructions — canonical source for Claude's workflow |
| `.github/workflows/deploy.yml` | GitHub Actions: auto-deploy to Vercel production on push to main |
| `.claude/settings.local.json` | Pre-approved permissions (gitignored — not in repo) |
| `lib/markdown.ts` | Core content utility: gray-matter + remark + sanitize-html |
| `app/page.tsx` | Homepage — show grid |
| `app/shows/[show]/page.tsx` | Show landing page — episode list |
| `app/shows/[show]/[episode]/page.tsx` | Episode detail — full 8-section prose render |
| `app/not-found.tsx` | Custom 404 |
| `content/shows/acquired/` | 13 Acquired episodes (12 narrative + 1 interview) |
| `content/shows/my-first-million/` | 6 MFM episodes |
| `content/shows/how-i-built-this/` | 1 placeholder episode (Airbnb) |
| `docs/build-journal/` | Build journal entries (v1 + this v2) |
| `docs/plans/` | Design document + implementation plan from v1 |

---

## 9. Reusable Architecture Pattern

**The Autonomous Ingestion Pipeline Pattern**

This build produced a generalizable pattern for any content-driven static site where human curation is the bottleneck:

```
[Human provides raw content]
         ↓
[CLAUDE.md encodes: parse → enrich → validate → write → commit → deploy]
         ↓
[settings.local.json pre-approves all sub-steps]
         ↓
[GitHub Actions handles CI/CD — no manual deploy commands]
         ↓
[Static site renders from file-based content at build time]
```

Key properties of this pattern:
- **Zero re-explanation overhead:** CLAUDE.md persists across sessions
- **Zero approval friction:** settings.local.json pre-approves trusted operations
- **Zero manual deploy steps:** GitHub Actions handles Vercel on every push
- **Source authority is explicit:** CLAUDE.md documents canonical sources per field, preventing data quality drift

Applicable to: any markdown-driven static site (blog, wiki, knowledge base, portfolio) where a human provides structured content and wants automated enrichment + publication.

---

## 10. Next Steps

### Completed
- [x] Next.js 15 + Tailwind + TypeScript scaffold
- [x] File-based markdown content system with frontmatter schema
- [x] Homepage, show pages, episode detail pages
- [x] Sanitized HTML rendering (XSS-safe)
- [x] Jest tests for markdown utility
- [x] UI redesign with dark header band
- [x] Season / episode / duration metadata on all episodes
- [x] CLAUDE.md autonomous ingestion pipeline
- [x] GitHub Actions + Vercel auto-deploy
- [x] settings.local.json permission whitelist
- [x] 18 real episodes catalogued across 3 shows
- [x] Deployed to Vercel production

### Remaining
- [ ] **Cross-episode analysis engine** — query across all summaries to find common themes, recurring mental models, and trends across Acquired + MFM + HIBT. Distill into original essays and posts. (Highest priority — this is the core intellectual value proposition of the project.)
- [ ] **Comments section** — public reader comments per episode. Must be built with injection-safe architecture (parameterized queries or server-side validation). Proof-of-concept for full-stack feature.
- [ ] **Admin portal** — authenticated interface for managing episodes without CLI. Useful as a practical security and auth implementation exercise.
- [ ] **UI improvements** — filtering by show/season, search, mobile layout refinement
- [ ] **YouTube comments** — manually curate top comments for Starbucks (Schultz) and Steve Ballmer episodes (both have YouTube URLs)
- [ ] **How I Built This real episodes** — replace Airbnb placeholder with actual listened episodes
- [ ] **MFM continued** — ingest additional episodes as they are listened to
