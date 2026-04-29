# KTP: Insurance & Rescue Partnership Research

## Build Journal Entry — Standard

**Builder:** Benjamin Giordano
**Build Date:** 2026-04-26 → 2026-04-28 (continuous session)
**Platform:** Claude Code (Opus 4.7, 1M context)
**Status:** Complete — research foundation shipped; partner-application work moves to async pursuit
**Repos:** `bengio777/KTP_V01`, `bengio777/agent-skills`
**Tier:** Standard

---

## 1. Problem Statement

Trip Builder's insurance card slot was empty. Generic travel insurance often excludes kitesurfing in the fine print. KTP's audience flies from 30+ countries to remote destinations where evacuation costs hit six figures, and there was no canonical reference for **(a)** which carriers actually cover kitesurfing, **(b)** which have affiliate programs and at what economics, **(c)** how to route by buyer residency × destination, **(d)** what the underlying injury risk actually is to back the pitch with evidence.

Three artefacts needed: a partner directory (supply side), an injury data report (demand side), and a tactical pursuit plan (what to do this week).

## 2. Solution

Four documents in a new `docs/partnerships-and-affiliates/insurance-and-rescue/` folder:

| File | Purpose |
|---|---|
| `insurance-and-rescue-partners.md` | Verified ~70 providers across global insurers, regional EU/AU/LATAM/Asia brokers, medevac memberships, and 11 affiliate networks. Routing matrix, never-recommend list, gap analysis, 15-step pursuit roadmap. |
| `injury-and-incident-statistics.md` | Actuarial-grade data for kitesurf, windsurf, wing foiling. 12 headline stats from peer-reviewed sources, cross-sport comparison vs surf/snowboard/scuba/MTB/paragliding, 27-destination risk matrix, rescue infrastructure mapping, 14 case studies. |
| `the-case-for-insurance-and-rescue.md` | Publication-ready user-facing argument distinguishing travel insurance (pays bill) from medevac membership (extracts you). Honest "when not to buy" section, affiliate disclosure. |
| `pursuit-plan.md` | Tactical companion translating research into a focused this-week action plan. Tier 1 (apply this week) through Tier 4 (defer/skip), with sequencing logic, 5-point pre-wiring verification checklist, inline status table. |

Plus adjacent system updates:

- `~/.claude/skills/ktp-affiliate-status/SKILL.md` — added critical kitesurf-coverage warnings (SafetyWing Essential excludes kite, World Nomads kite-in-Standard correction, Allianz UK exclusion), expanded "Researched, ready to apply" section with 9 entries, two-layer insurance routing architecture
- Notion AI Building Blocks — `ktp-affiliate-status` entry refreshed with expanded scope, GitHub URL, Status=Deployed
- Notion KTP Task Tracker — high-priority "Build personal assistant + scheduler + task management agent" entry created with full context for design-time
- Scheduled remote agent `trig_015QbQ6r1ukpCfG2cPCuYvEp` for 2026-05-08 to chase Tier-1 application status (read-only investigation; reports back with wins / still-pending / next action)

## 3. Architecture

Research orchestration was the interesting architecture piece. Two parallel research rounds, each dispatching 4 specialized general-purpose subagents in parallel:

**Round 1 — Insurance partners (4 agents):**
1. Adventure-focused global insurers
2. Regional insurers (dual-axis: residency × destination — initial agent pushed back on scope; restarted with Tier 1 only)
3. Medical evacuation services
4. Affiliate network coverage

**Round 2 — Injury statistics (4 agents):**
1. Kitesurfing global epidemiology
2. Windsurfing global stats (older literature, head-to-head with kite)
3. Wing foiling + foil-strike trauma
4. Regional/destination incident & rescue infrastructure

Each agent produced a 200–400 line report with citations. Synthesis happened in main session. Folder structure mirrors the data architecture: vertical subfolders (`insurance-and-rescue/`, `kite-schools/`) under the unified `partnerships-and-affiliates/` parent, with horizontal infrastructure (`affiliate-setup/` for network application how-tos) kept at top level.

## 4. Build History

| Commit | Date | What |
|---|---|---|
| (unrecorded git mv) | 2026-04-26 | Renamed `docs/partnerships/` → `docs/partnerships-and-affiliates/`; created `insurance-and-rescue/` and `kite-schools/` subfolders; moved `iko-pitch.md` |
| `a50dd97` | 2026-04-26 | `[UPDATE] ktp-affiliate-status: Insurance & rescue research integration` (skills repo) |
| `18a1185` | 2026-04-26 | `docs(partnerships): add insurance & rescue partner map, injury data, and user-facing case` (KTP) — 4 files / 1187 insertions |
| `6b80037` | 2026-04-28 | `docs(partnerships): add insurance & rescue pursuit-plan` (KTP) — tactical companion |
| `75e943d` | 2026-04-28 | `[UPDATE] ktp-spot-builder: tagline voice ref + new components + registry sync` (skills repo) — opportunistic batch with adjacent stale changes |

Notion writes (separate from git): AI Building Blocks `ktp-affiliate-status` page updated; KTP Task Tracker entry `350fb3a7-cad4-81ff-8b2c-cc3f8b78b004` created.

Remote routine created: `trig_015QbQ6r1ukpCfG2cPCuYvEp` fires once on 2026-05-08T15:00:00Z.

## 5. Lessons Learned

- **Subagent pushback is a feature, not noise.** The first regional-insurers agent stopped mid-task and proposed three scoped alternatives (Tier 1 / split sessions / single-pass with mixed confidence) instead of producing low-confidence rows. The instinct was correct; restarting with sharper scope (Tier 1 only, dual-axis residency × destination) produced a stronger result. Encode this in agent prompts: explicit permission to pause and propose scope reduction beats forced completion.

- **Dual-axis routing is non-obvious until it isn't.** Initial framing was "find best insurer per region." Real product question is "kitesurfer from country X going to country Y — which insurer (a) sells to residents of X, (b) covers travel to Y, (c) covers kitesurfing." A Brazilian broker with global coverage may not be sold to US residents; a US broker may exclude Asia destinations. The matrix shape captures this; a flat list does not.

- **Research has a "supply vs demand" structure that maps to documents.** Keeping the partner directory and the injury statistics in separate files (cross-linked) produces cleaner artefacts than a single mega-document. Different audiences, different update cadences, different lifetimes.

- **Folder restructure mid-session is cheap if nothing else references the old paths.** Moving `partnerships/` → `partnerships-and-affiliates/` before content was published cost one PROGRESS.md path edit. Doing it after publication would have been worse.

- **Don't commit third-party skills to a personal skills repo.** Initial instinct was to batch-sync 5 untracked skills from `~/.claude/skills/`. Closer look revealed all 5 were authored by Josh Anderson / Firecrawl / "josh" — not Ben's. The repo's commit history is solo-authored. Pollution avoided by checking before committing.

- **"Cookie outliers" matter more than headline commission rates.** SafetyWing's 364-day cookie + Genki's 365-day cookie + Globelink's 90-day cookie are doing more work than the percentage rate alone, because insurance shoppers convert 14–45 days post-research. Optimizing for headline % without checking cookie window misses the actual revenue driver.

## 6. Next Steps

### Completed this session
- 4 reference docs in canonical folder
- Skill registry synchronized (GitHub commit + Notion entry refreshed)
- High-priority follow-up task in KTP Task Tracker
- Scheduled remote agent for 10-day status chase
- PROGRESS.md session log entries

### Remaining (Ben's court, not chat-hanging)
- **Tier 1 partner applications (~2.5h focused block):** Awin, CJ unblock, Heymondo direct + Yazing, Globelink direct, Global Rescue Safe Travel Partner. Per `pursuit-plan.md`.
- **Build the personal-assistant agent** — high-priority entry now in KTP Task Tracker. Run `agent-selection-coach` skill at design time per project CLAUDE.md.
- **Pre-wiring verification checklist** runs once per approved insurer before Trip Builder gets the link — pull policy PDF, confirm upgrade requirement, residency restriction, destination exclusion list, kitesurf-as-main-purpose allowance.
- **The empty Trip Builder insurance card** itself — needs design + build once partner apps come back. Routing logic already mapped in the residency × destination matrix.
- **Gap-fill research** for AU/NZ residents, South Africa residents, Asia ex-Singapore, France 2-week leisure trips, SafetyWing kitesurf PDF verification, Battleface policy text. Each is a 30-min focused investigation.
- **Strategic data moat:** spot pages with explicit hazard tagging (offshore-wind risk, shore-launch density, bottom hardness, reef proximity, rescue-station distance) become an underwriting input no insurer can get from any other source. Worth pitching to Global Rescue / Battleface / Heymondo at contract stage.

### Items intentionally not touched
- `M CLAUDE.md` in KTP repo — your manual edit, your call to commit
- Pre-existing deletions (`docs/plans/2026-04-25-supabase-migration-history-repair.md`, `supabase/migrations/20260425000001_spot_ambassadors.sql`) — not from this session
- 5 untracked third-party skills in `~/.claude/skills/` (`context-checkpoint`, `firecrawl-disabled`, `powerpoint-design`, `pptx`, `serpapi`) — authored by others; don't belong in your solo-authored agent-skills repo
