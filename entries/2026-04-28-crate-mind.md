# Crate Mind — Daily Recap

**Date**: 2026-04-28
**Mode**: Daily Recap (PRD discovery + project setup; v0.1 working draft, paused mid-discovery)
**Project repo**: https://github.com/bengio777/crate-mind (private)
**Local path**: `~/Projects/crate-mind`
**Commits**: 1

## What this is

New solo project. Music library understanding tool for the **Curious Working DJ** — DJs with 2k–15k tracks scattered across iTunes/Spotify/Beatport/Rekordbox/USB who want to understand subgenre nuance and follow their own taste relationships into deeper discovery. Differentiation vs. Lexicon (closest commercial competitor): Crate Mind ships an education + relationship layer Lexicon doesn't have.

## Accomplished

Full PRD discovery session. Persona, JTBD, business model (B2C freemium + B2B intent data + affiliate), architecture (Tauri + SQLite + essentia.js + React/deck.gl, local-first), and multi-genre evidence model all locked. Phase 0 fully decided across 8 blocks. Phase 1 mostly walked across 7 blocks; only 1.7 affiliate retailers in progress.

Set up `~/Projects/crate-mind/` with PRD v0.1 working draft, PROGRESS.md, 5 research docs (Spotify API deprecation, competitive landscape, API availability matrix, DJ organizing schemas, affiliate programs), README, and .gitignore. Initialized git, created private GitHub repo `bengio777/crate-mind`, pushed initial commit.

## Hardest part / biggest surprise

**Spotify deprecated the Audio Features API for new apps in November 2024** (discovered mid-discovery via verification fetch). Forced an architectural reframing: Spotify is now a library/search/match source only — never the audio-truth source. essentia.js + local files become non-negotiable. This actually *sharpened* the product positioning: "your scattered library, understood" is stronger than "Spotify-powered DJ tool," and local-first architecture follows naturally.

## Lessons

- **Verify third-party API status mid-discovery, not after building.** Spotify's deprecation would have been a costly rebuild if discovered after Phase 0 was built.
- **Persona by intent beats persona by skill level.** "Curious Working DJ" (curiosity = intent) is sharper than "intermediate DJ." Bedroom + working DJ both fit because intent is shared.
- **Multi-genre is the model, not a feature.** Spotify track-level genre doesn't exist; artist tags are coarse. Build for multi-source evidence from schema up.
- **Don't compete on someone else's turf.** Mixed In Key/Lexicon/Rekordbox own harmonic mixing. Camelot deferred to Phase 3. Lead with the unowned ground: subgenre education + relationship discovery.

## What's next

1. Finish Phase 1.7 affiliate retailer walk (iTunes → Discogs → Juno → Bandcamp → Beatsource)
2. Beatport affiliate terms verification (Ben → contacts)
3. Define kill criteria + success metrics + instrumentation plan
4. Calibrate timeline based on hours/week commitment
5. Generate PRD v1.0 once discovery complete
6. Begin Phase 0 build

## Commits

| Hash | Date | Description |
|------|------|-------------|
| 385518a | 2026-04-28 | Initial PRD draft (v0.1) for Crate Mind |
