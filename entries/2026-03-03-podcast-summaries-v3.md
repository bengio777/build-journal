# podcast-summaries: Content Expansion — Session 3
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-03
**Repo:** bengio777/podcast-summaries
**Status:** Complete
**Tier:** Standard

---

## 1. Problem Statement

The autonomous ingestion pipeline established in Session 2 needed to be stress-tested across a wider range of episode types. Session 3's goal was to ingest 13 new Acquired episodes spanning regular narrative episodes, ACQ2 interview specials, multi-part series, and episodes with known sponsor inserts — while resolving a recurring metadata ambiguity: the "YouTube URL Provided" header flag in pasted content had proved unreliable in Session 2, and needed a documented handling strategy.

## 2. Solution

Ingested 13 episodes via the fully autonomous pipeline (parse → research → write → commit → push), refining metadata resolution patterns at each step:

- **Regular episodes** (Visa, Costco, Lockheed Martin, Nike, Nvidia I/II/III, Porsche, Walmart): sourced dates from acquired.fm, durations from Apple Podcasts ISO 8601 metadata, confirmed no YouTube URLs
- **ACQ2 interviews** (Charlie Munger, NVIDIA CEO Jensen Huang, Spotify CEO Daniel Ek): used `season: "ACQ2"`, `episode: 0`, surfaced Jensen Huang's YouTube URL via ytscribe.com; confirmed Daniel Ek video exists on Spotify only (not YouTube)
- **Sponsor insert handling** (Walmart/Ben Miller): correctly excluded sponsor ad segments from frontmatter `guests` array while preserving them in the Voices section body

GitHub 500 outage mid-session (18:59–19:30 UTC) was diagnosed immediately and commits held locally until recovery.

## 3. Architecture

No structural changes to the site or pipeline this session — pure content expansion. Existing patterns held:

- `content/shows/acquired/YYYY-MM-DD-slug.md` — markdown files with YAML frontmatter
- `season: "ACQ2"` / `episode: 0` convention for interview specials
- `guests: []` frontmatter vs. Voices section body as two distinct layers of attribution
- Apple Podcasts date = acquired.fm date + 1 day (confirmed again across 13 episodes)

## 4. Component Specifications

**New files added this session (13 episodes):**

| File | Show | Type |
|------|------|------|
| `2025-05-05-tsmc-founder-morris-chang.md` | Acquired | Regular (S: Spring 2025 E1) |
| `2023-11-26-visa.md` | Acquired | Regular (S13 E4) |
| `2023-10-29-charlie-munger.md` | Acquired | ACQ2 Interview |
| `2023-08-20-costco.md` | Acquired | Regular (S13 E2) |
| `2023-05-29-lockheed-martin.md` | Acquired | Regular (S12 E5) |
| `2023-10-15-nvidia-ceo-jensen-huang.md` | Acquired | ACQ2 Interview |
| `2023-07-24-nike.md` | Acquired | Regular (S13 E1) |
| `2023-09-05-nvidia-part-iii-dawn-of-ai-era.md` | Acquired | Regular (S13 E3) |
| `2022-03-27-nvidia-part-i-gpu-company.md` | Acquired | Regular (S10 E5) |
| `2022-04-20-nvidia-part-ii-machine-learning-company.md` | Acquired | Regular (S10 E6) |
| `2023-06-26-porsche.md` | Acquired | Regular (S12 E6) |
| `2023-05-17-spotify-ceo-daniel-ek.md` | Acquired | ACQ2 Interview |
| `2022-07-18-walmart.md` | Acquired | Regular (S11 E1) |

## 5. Lessons Learned

**"YouTube URL Provided" is a transcript artifact, not a promise.** The pasted content sometimes includes this header flag regardless of whether a YouTube URL was actually found. Resolution: always search independently via acquired.fm episode page + ytscribe.com. Only Jensen Huang's URL was surfaced this session (confirmed: `y6NfxiemvHg`); Porsche video confirmed to exist on acquired.fm but not surfaced publicly.

**Daniel Ek's video is Spotify-only.** acquired.fm says "filmed" but the video is embedded on Spotify, not YouTube. Leave `youtube_url: ""` and note this in the journal.

**Apple Podcasts date = acquired.fm + 1 day.** This pattern held across every episode this session without exception. When in doubt, acquired.fm is the canonical source.

**Sponsor inserts ≠ guests.** Walmart's Ben Miller (Fundrise sponsor) appeared in the pasted Voices section. Correctly excluded from `guests: []` frontmatter; kept in body for completeness. Pattern: if a person "joins briefly" to discuss a sponsor product, they are not a true interview guest.

**GitHub 500 during push is transient.** When git push returns a 500 from GitHub (not a 404, not an auth error), check githubstatus.com and hold — don't retry in a loop. Commit is safe locally; push when service recovers.

**Paste content may contain minor factual errors.** Walmart paste listed "Saul Price" (FedMart/Price Club founder); correct name is Sol Price. Corrected silently with proper Wikipedia link.

## 6. Build History

- Session 1 (2026-03-02): Scaffolded Next.js site, built UI, ingested first MFM and Acquired episodes
- Session 2 (2026-03-02): Wired autonomous pipeline (CLAUDE.md, settings.local.json, GitHub Actions), ingested 18 Acquired episodes across 2024–2025
- **Session 3 (2026-03-02/03): Ingested 13 more Acquired episodes spanning 2022–2025, refined metadata resolution patterns, handled GitHub outage**

Total episodes catalogued to date: ~38

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| 57d65fb | 2026-03-03 | Add Acquired: Walmart (Season 11 E1) |
| af7784c | 2026-03-03 | Add Acquired: Spotify CEO Daniel Ek (ACQ2 interview) |
| dfcb0dc | 2026-03-03 | Add Acquired: Porsche with Doug DeMuro (Season 12 E6) |
| 04b570a | 2026-03-03 | Add Acquired: Nvidia Part II - The Machine Learning Company (Season 10 E6) |
| 30f2c3e | 2026-03-03 | Add Acquired: Nvidia Part I - The GPU Company (Season 10 E5) |
| 3032115 | 2026-03-03 | Add Acquired: Nvidia Part III - Dawn of the AI Era (Season 13 E3) |
| 9f65169 | 2026-03-02 | Add Acquired: Nike (Season 13 E1) |
| cd2375c | 2026-03-02 | Add Acquired: NVIDIA CEO Jensen Huang interview (ACQ2) |
| c56c27b | 2026-03-02 | Add Acquired: Lockheed Martin (Season 12 E5) |
| 691ff24 | 2026-03-02 | Add Acquired: Costco (Season 13 E2) |
| cbabde1 | 2026-03-02 | Add Acquired: Charlie Munger interview (ACQ2) |
| 9a82649 | 2026-03-02 | Add Acquired: Visa (Season 13 E4) |
| b02b5a3 | 2026-03-02 | Add Acquired: TSMC Founder Morris Chang (Spring 2025 E1) |
