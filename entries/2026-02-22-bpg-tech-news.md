# BPG Tech News: v2.0 Multi-Cadence Restructure
## Build Journal Entry — Full

**Builder:** Benjamin Giordano + Claude Opus 4.6
**Build Date:** February 21–22, 2026 (2 sessions)
**Platform:** Claude Code Plugin + Next.js 16 + macOS launchd
**Status:** Complete (Phase 5 scheduling partial, Phase 6 email upgraded)
**Repos:** bengio777/BPG_Tech-News_Catalog, bengio777/bengio-marketplace, bengio777/tech-news-viewer_admin
**Tier:** Full

---

## 1. Problem Statement

What began as a proof-of-concept daily tech news briefing grew into a full product. The v1 system was a single-cadence daily briefing with 12 sources, no tabs, no dashboard, and a plain-text email. The goal became: automate a multi-cadence news workflow (daily/weekly/monthly) that actually produces something worth reading — with a tabbed dashboard, pre-fetched OSINT and podcast data, HTML email delivery, and unattended scheduling via launchd.

The scope expanded because the PoC worked well enough that it deserved to be a real tool.

## 2. Solution

A 7-phase restructure plan executed across two Claude Code sessions:

- **Phase 0**: Tab format system with `<!-- tab: Name -->` HTML comment markers + dual-mode dashboard parser (new tabbed format + backward-compatible legacy)
- **Phase 1**: Expanded daily pipeline from 12 to 23 sources across 3 tabs (AI News, Breakthroughs, Cyber Intel)
- **Phase 2**: Zero-token pre-fetch Python scripts for OSINT (CISA KEV, NVD, RSS) and podcasts (Spotify API, Apple Charts)
- **Phase 3**: Weekly command with synthesis skill, podcast curation, and 4-tab format
- **Phase 4**: Monthly command with long-form 5-section retrospective and dedicated MonthlyView component
- **Phase 5**: launchd scheduling (daily plist exists; weekly/monthly plists still needed)
- **Phase 6**: HTML + plain text email with 20px base font, cadence-aware subject lines

Critical fix in Session 2: Diagnosed and resolved `claude -p` hanging when passed slash commands. Root cause: `-p` mode sends literal text to the model — slash commands aren't parsed. Solution: rewrote `run-briefing.sh` to build a self-contained prompt by inlining command + skills + template content directly. Pipeline went from hanging indefinitely to completing in 3.5 minutes.

## 3. Architecture

```
                    launchd (6 AM daily)
                         |
                    run-briefing.sh
                    /           \
            Pre-fetch            Build prompt
            (Python)             (inline skills)
           /        \                |
    fetch-osint   fetch-podcasts   claude -p
    (CISA,NVD,    (Spotify,          |
     RSS)          Apple)        [research → curate → format]
                                     |
                              Write .md to BPG_Tech-News
                              Git commit + push
                              Email via SMTP
                                     |
                              Dashboard reads .md
                              (Next.js, localhost:3000)
```

**Three repos, three concerns:**
- `BPG_Tech-News_Catalog` — Pure content (markdown briefings)
- `bengio-marketplace` — Plugin code (skills, commands, templates, scripts)
- `tech-news-viewer_admin` — Dashboard app (Next.js)

## 4. Data Schema

**Tab format** — HTML comments as markers:
```markdown
<!-- tab: AI News -->
## Must-Read
- **[Title](url)** — summary. *Source: Name*
```

**Briefing cadences:**
| Cadence | Tabs | Output Path |
|---------|------|-------------|
| Daily | AI News (tiered), Breakthroughs (flat), Cyber Intel (4 sections) | `YYYY/week-WW/YYYY-MM-DD.md` |
| Weekly | Week in AI, Breakthroughs Recap, Cyber Weekly, Podcasts | `YYYY/week-WW/week-WW-recap.md` |
| Monthly | Long-form (no tabs): 5 sections with TOC | `YYYY/YYYY-MM-recap.md` |

**Pre-fetch JSON** (`~/.config/tech-news-briefing/prefetch/`):
- `osint-YYYY-MM-DD.json` — CISA KEV entries, NVD CVEs (CVSS >= 8.0), RSS items
- `podcasts-YYYY-MM-DD.json` — Spotify episodes from 18 shows, Apple Charts top 25

## 5. Component Specifications

### Plugin (v2.0.0)
| Component | File | Purpose |
|-----------|------|---------|
| research skill | `skills/research/SKILL.md` | 23 sources across 3 categories with URL enforcement rules |
| curation skill | `skills/curation/SKILL.md` | Scoring (Impact/Novelty/Relevance/Authority), tab routing, virality boost |
| formatting skill | `skills/formatting/SKILL.md` | Tab markers, per-item format, final check with homepage URL rejection |
| synthesis skill | `skills/synthesis/SKILL.md` | Cross-day pattern detection for weekly/monthly |
| podcasts skill | `skills/podcasts/SKILL.md` | Episode matching, chart cross-reference, categorization |
| daily command | `commands/briefing.md` | 9-step pipeline |
| weekly command | `commands/briefing-weekly.md` | 10-step pipeline with synthesis + podcasts |
| monthly command | `commands/briefing-monthly.md` | 9-step pipeline with deep retrospective |
| fetch-osint.py | `scripts/fetch-osint.py` | CISA KEV + NVD + RSS (stdlib only, Python 3.9+) |
| fetch-podcasts.py | `scripts/fetch-podcasts.py` | Spotify OAuth + Apple Charts (stdlib only) |
| send-email.py | `scripts/send-email.py` | Markdown → HTML conversion, MIMEMultipart, cadence subjects |

### Dashboard (Next.js 16)
| Component | Purpose |
|-----------|---------|
| `parser.ts` | Dual-mode: detects `<!-- tab: -->` markers or falls back to legacy single-tab |
| `types.ts` | Tab, Section, BriefingCadence, PodcastEpisode types |
| `briefings.ts` | Filesystem indexer for daily/weekly/monthly with 60s cache |
| `BriefingView.tsx` | Client component with useState tab switching |
| `TabBar.tsx` | Horizontal tab buttons, hidden for single-tab briefings |
| `SectionView.tsx` | Tier-colored dots, story + podcast rendering |
| `MonthlyView.tsx` | Long-form with TOC navigation |
| `SidebarClient.tsx` | Date list with W/M badges for weekly/monthly |

### Pipeline Config
| File | Purpose |
|------|---------|
| `run-briefing.sh` | Self-contained prompt builder, pre-fetch orchestration, cadence routing |
| `com.bengio.tech-news-briefing.plist` | launchd daily at 6 AM |

## 6. Lessons Learned

### Context management is the real bottleneck
The project grew large enough that a single Claude Code session couldn't hold it all. The first session ran out of context mid-build. The handoff summary + MEMORY.md approach worked, but losing context meant re-reading files and re-establishing understanding. **Takeaway: ship and test each phase fully before starting the next. Smaller increments, more commits, more verification points.**

### Test the production path early
The `claude -p` hanging issue wasn't discovered until Phase 5 testing — after all 6 phases of plugin code were written. The root cause (slash commands not parsed in `-p` mode) was fundamental to the delivery mechanism. If we'd tested a simple `claude -p` run in Phase 1, we'd have caught it immediately. **Takeaway: validate the deployment mechanism before building all the features that depend on it.**

### Self-contained prompts beat plugin discovery
The fix — inlining command + skills + template into one prompt for `claude -p` — is actually more robust than relying on plugin discovery. It works regardless of environment (launchd, nested sessions, CI). **Takeaway: for headless/automated runs, don't depend on runtime plugin resolution.**

### Pre-fetch scripts are a force multiplier
The Python pre-fetch scripts (OSINT + podcasts) add zero LLM tokens to the pipeline cost. They gather structured data that Claude then incorporates directly. 70 OSINT items and 25 podcast charts in seconds, for free. **Takeaway: separate deterministic data gathering from LLM reasoning.**

### Homepage URLs are a recurring LLM failure mode
When Claude can't find a specific article URL, it falls back to the homepage (e.g., `https://thehackernews.com/`). This required explicit skill-level rules: retry with quoted headline search, and drop the story entirely if no direct URL is found. **Takeaway: LLMs need explicit failure-mode instructions, not just happy-path instructions.**

## 7. Build History

### Session 1 (Feb 21–22, ~4 hours)
| Phase | What happened |
|-------|--------------|
| Phase 0 | Tab format + dashboard parser. Found `/m` multiline flag bug in regex. |
| Phase 1 | Expanded to 23 sources, 3-tab output. All skills rewritten. |
| Phase 2 | Pre-fetch scripts. Hit Python 3.9 union type syntax issue, fixed with `__future__`. |
| Phase 3 | Weekly command, synthesis + podcasts skills, sidebar badges. |
| Phase 4 | Monthly command, MonthlyView, plugin bumped to v2.0.0. |
| Testing | Weekly test: nested session error → fixed with `unset CLAUDECODE`. Second attempt produced wrong format → reverted. Third attempt hung 30+ min → killed. |
| Phase 6 | HTML email with 20px base font, cadence-aware subjects. |
| Font | Dashboard root font-size increased to 20px (25% increase per user request). |

### Session 2 (Feb 22, ~1.5 hours)
| Task | What happened |
|------|--------------|
| Diagnosis | Identified root cause: `claude -p` doesn't parse slash commands. |
| Fix | Rewrote `run-briefing.sh` with self-contained prompt builder. |
| Test | Weekly pipeline ran in 3.5 minutes. 17 stories, 4 tabs, committed, pushed, emailed. |
| URL rules | Added homepage URL rejection to research + formatting skills. |
| Git | Committed and pushed all 3 repos. Created `tech-news-viewer_admin` repo. |
| Rename | Renamed repos: `BPG_Tech-News_Catalog`, `tech-news-viewer_admin`. |

## 8. Repository File Manifest

| File Path | Description |
|-----------|-------------|
| `bengio-marketplace/plugins/tech-news-briefing/.claude-plugin/plugin.json` | Plugin manifest v2.0.0 |
| `bengio-marketplace/.../commands/briefing.md` | Daily 9-step pipeline |
| `bengio-marketplace/.../commands/briefing-weekly.md` | Weekly 10-step pipeline |
| `bengio-marketplace/.../commands/briefing-monthly.md` | Monthly 9-step pipeline |
| `bengio-marketplace/.../skills/research/SKILL.md` | 23 sources, URL enforcement |
| `bengio-marketplace/.../skills/curation/SKILL.md` | Scoring, tab routing, virality boost |
| `bengio-marketplace/.../skills/formatting/SKILL.md` | Tab markers, homepage URL rejection |
| `bengio-marketplace/.../skills/synthesis/SKILL.md` | Cross-day pattern detection |
| `bengio-marketplace/.../skills/podcasts/SKILL.md` | Episode matching + charts |
| `bengio-marketplace/.../templates/daily.md` | 3-tab daily template |
| `bengio-marketplace/.../templates/weekly.md` | 4-tab weekly template |
| `bengio-marketplace/.../templates/monthly.md` | 5-section monthly template |
| `bengio-marketplace/.../scripts/fetch-osint.py` | CISA KEV + NVD + RSS pre-fetch |
| `bengio-marketplace/.../scripts/fetch-podcasts.py` | Spotify + Apple Charts pre-fetch |
| `bengio-marketplace/.../scripts/send-email.py` | HTML email with markdown conversion |
| `tech-news-viewer/src/lib/types.ts` | Tab, Section, BriefingCadence types |
| `tech-news-viewer/src/lib/parser.ts` | Dual-mode tab parser |
| `tech-news-viewer/src/lib/briefings.ts` | Filesystem indexer with cache |
| `tech-news-viewer/src/components/BriefingView.tsx` | Tabbed briefing viewer |
| `tech-news-viewer/src/components/TabBar.tsx` | Tab navigation |
| `tech-news-viewer/src/components/SectionView.tsx` | Story/podcast renderer |
| `tech-news-viewer/src/components/MonthlyView.tsx` | Long-form monthly layout |
| `tech-news-viewer/src/components/SidebarClient.tsx` | Date list with W/M badges |
| `tech-news-viewer/src/app/layout.tsx` | Root layout with 20px font |
| `~/.config/tech-news-briefing/run-briefing.sh` | Self-contained prompt builder |
| `~/Library/LaunchAgents/com.bengio.tech-news-briefing.plist` | Daily 6 AM schedule |

## 9. Reusable Architecture Pattern

**Self-contained prompt builder for headless Claude runs:**

When running `claude -p` from scripts or cron/launchd, don't pass slash commands or rely on plugin discovery. Instead:
1. Read the command file, strip YAML frontmatter
2. Append all referenced skill content
3. Append the template
4. Resolve `${CLAUDE_PLUGIN_ROOT}` to the actual path
5. Pass the assembled prompt directly to `claude -p`

This pattern works in any environment (launchd, SSH, CI) without needing plugin configuration.

**Pre-fetch + LLM pipeline:**

Separate deterministic data gathering (API calls, RSS parsing) into Python scripts that run before the LLM. Output structured JSON. The LLM reads the JSON and incorporates it. Zero token cost for the data gathering phase, and the LLM gets clean structured input instead of having to navigate web pages.

## 10. Next Steps

### Completed
- [x] Phase 0: Tab format + dashboard parser
- [x] Phase 1: 23-source daily pipeline with 3 tabs
- [x] Phase 2: OSINT + podcast pre-fetch scripts
- [x] Phase 3: Weekly command with synthesis + podcasts
- [x] Phase 4: Monthly command with MonthlyView
- [x] Phase 6: HTML email with 20px base font
- [x] Fix: `claude -p` self-contained prompt approach
- [x] Fix: URL enforcement (no homepage links)
- [x] Dashboard: 25% font increase
- [x] GitHub: All 3 repos pushed and renamed

### Remaining
- [ ] Phase 5: Weekly (Sunday 8 AM) + monthly (1st of month 9 AM) launchd plists
- [ ] Spotify Keychain credentials setup for podcast episode fetching
- [ ] Notion: Register v2.0.0 building blocks in AI Building Blocks database
- [ ] Test daily pipeline with URL enforcement rules (next 6 AM run)
- [ ] Investigate if Vercel deployment makes sense for the dashboard
