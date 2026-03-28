# Build Journal — Trip Builder Intelligence + Gear Locker Integration
**Date:** 2026-03-27
**Project:** Kite the Planet — `bengio777/KTP_V01`
**Tier:** Full
**Session type:** Product feature build — scoring engine, personalization, gear integration, global nav

---

## Problem

After weeks of data scraping, competitive research, marketing strategy, and infrastructure work, the product existed mostly as backend scaffolding. The front end was thin — a basic Trip Builder interview with flat scoring that didn't reflect a rider's actual preferences, no gear intelligence, no profile, no persistent navigation. The app wasn't yet something you could believe in. The founder needed to see the product's power and functionality linking together — real personalization, real recommendations, real output — to restore conviction and momentum.

---

## Solution

Seven commits transforming the Trip Builder from a basic wind-ranking tool into a personalised travel intelligence engine, wired to the rider's actual gear and profile.

**Trip Builder scoring engine (4 commits):**
- 6 preference multipliers: climate type, water temperature, spot type, skill floor, wind direction quality, crowd level — all scoring against user answers
- Wind consistency re-enabled (`WINDY_DATA_VERIFIED = true`) after 7 multipliers made it safe to bring back; score = 55% consistency + 45% wind quality
- Wind range sweet spot step (light/medium/powered/nuking) shifts the optimal scoring window rather than applying a penalty — a nuking rider genuinely doesn't want 15–22 kt spots
- `windMin` / `windMax` added to every spot recommendation for downstream use

**Kite sizing module (`lib/trip-builder/kite-sizing.ts`):**
- Formula: `(weight_kg / avg_wind_kts) × 2.2` (waves: 2.0, big_air: +1m²)
- Pack range: `rawSmall−1` to `rawBig+2` — asymmetric because being too big is more dangerous
- Output: money kite, pack sizes, leave-at-home list, gap detection, one-line message
- Research-calibrated at ~80 kg reference against kiteforum.com + Duotone/F-One/Core sizing guides

**Gear Locker profile section:**
- Rider profile UI above catalog/locker grid: weight (kg/lbs toggle), height (cm/ft toggle), foot stance, skill level, riding styles, wind range prefs
- Saves to `public.users` via Supabase; dirty tracking + save button + status line
- Supabase migration 011: 6 new columns applied to production

**Trip Builder → Locker connection:**
- When user selects "Yes, use my gear" at the locker step, fetches weight + kite sizes from Supabase after results load
- `getKiteAdvice()` computed per spot using `windMin`/`windMax` from the API
- Violet "Kite advice" card on each spot result: *"Your 9m is the money kite · leave your 12m and 15m at home"*
- Silent fallback if not logged in or weight not set

**Global NavBar:**
- Fixed top bar in root layout — KTP logo → home, Explore / Trip Builder / Gear Locker / Flights, profile icon → `/settings` (or Sign in)
- Active page highlighting via `usePathname`; hidden on `/auth/*`
- Removed inline nav from landing page; all pages now inherit automatically

---

## Architecture

**Scoring chain:** `windScore × wtMult × clMult × typeMult × skillMult × windMult × crowdMult = adjustedScore`
**Wind quality formula:** `overlap(spotRange, optimalWindow) / rangeSize × 100`
**Optimal window:** union of user-selected wind brackets (light 12–18 / medium 18–24 / powered 24–30 / nuking 30–40 kts)
**Kite sizing:** client-side pure function — no API call, runs after spot results load
**Profile storage:** `public.users` (not a separate profiles table) — columns added via migration 011
**NavBar:** `'use client'` component with `supabase.auth.onAuthStateChange` listener — no server round-trip

---

## Components Built

| File | What it does |
|---|---|
| `lib/trip-builder/score.ts` | Wind scoring — added WIND_RANGE_BRACKETS, getOptimalWindow, getAvgWindRange, flipped WINDY_DATA_VERIFIED |
| `lib/trip-builder/kite-sizing.ts` | New: kite advice engine — formula, pack range, gap detection, message builder |
| `lib/trip-builder/climate.ts` | Updated: climateMultiplier accepts string[] |
| `lib/trip-builder/spot-attributes.ts` | spotTypeMultiplier, skillFloorMultiplier, windDirMultiplier, crowdMultiplier |
| `app/api/trip-builder/recommend/route.ts` | windRange in request, windMin/windMax in response, 7-multiplier scoring chain |
| `app/trip-builder/TripBuilderClient.tsx` | windrange step, fetchLockerAdvice(), kiteAdviceMap state, SpotCard violet advice block |
| `app/gear-locker/page.tsx` | Full rewrite: RiderProfile UI, unit toggles, dirty tracking, saveProfile() |
| `supabase/migrations/011_rider_profile.sql` | weight_kg, height_cm, foot_stance, riding_styles, wind_range_prefs, skill_level |
| `app/components/NavBar.tsx` | New: global nav component |
| `app/layout.tsx` | NavBar + pt-14 wrapper added to root |

---

## Data Schema

**New columns on `public.users`:**
```sql
weight_kg        NUMERIC(5,1)
height_cm        INTEGER
foot_stance      TEXT CHECK (foot_stance IN ('regular', 'goofy'))
riding_styles    TEXT[] NOT NULL DEFAULT '{}'
wind_range_prefs TEXT[] NOT NULL DEFAULT '{}'
skill_level      skill_level_type
```

---

## Hardest Part

Notion MCP debugging — property name mismatches, schema validation errors, repeated failed writes. Time-consuming and friction-heavy relative to the value of the operation. The code builds were clean; the Notion integration was the friction point.

---

## Lessons

- **Scoring gates exist for a reason.** `WINDY_DATA_VERIFIED = false` was correct before multipliers existed. The right time to re-enable consistency data was after enough preference signals existed to prevent it from dominating. Architecture decisions that look like hacks often have legitimate reasoning — document the *why* so the unlock condition is clear.
- **Wind range as window shift, not multiplier.** A rider who wants nuking conditions should see nuking spots ranked first — not non-nuking spots with a mild penalty. Model the physics, not a proxy.
- **When GitHub-triggered Vercel deploys keep showing CANCELED, use `vercel --prod` from the CLI.** Bypasses the queue, clears stuck builds, deploys directly. Aliasing to production domain confirms success.
- **Notion MCP schema must be read before writing.** Never assume property names or types — retrieve the database schema first.

---

## Reusable Pattern

**Per-spot contextual advice from user profile:**
Fetch user profile after results load (not before) → compute advice client-side using spot's aggregated data → render as a dismissable card per spot. This pattern works for any enrichment that depends on both spot data and user profile: gear advice, wetsuit recommendations, skill warnings, travel cost estimates. The key: results render immediately at full quality, enrichment populates asynchronously without blocking.

---

## What's Next

Flight engine — make airline recommendations dynamic and genuinely useful. Move from static baggage fee lookups to real-time flight + true-cost surfacing per destination. Eventual goal: in-app booking path that saves the rider money and captures KTP affiliate revenue. This is the feature that turns the Trip Builder from a planning tool into a transaction engine.

---

## Commits

| Hash | Description |
|---|---|
| `8f9a2e8` | Trip Builder: 6 scoring signals + 4 new interview steps |
| `423ed32` | Trip Builder: climate multi-select + 5-bracket water temp |
| `7da8a4f` | Trip Builder: water temp multi-select + dual-unit temp display rule |
| `838c949` | Trip Builder: wind range sweet spot step + reintroduce wind consistency |
| `baeaff3` | Gear Locker: kite sizing engine + rider profile schema |
| `7a13320` | Gear Locker profile section + Trip Builder kite advice connection |
| `9bd614f` | Add global NavBar to root layout |

**Repo:** `https://github.com/bengio777/KTP_V01.git`
**Production:** `https://www.kitetheplanet.com`
