# Build Journal — France + Italy + Portugal Spot Batch
**Date:** 2026-03-26
**Project:** Kite the Planet — `bengio777/KTP_V01`
**Tier:** Standard
**Session type:** Batch content build (continued across two conversations)

---

## Problem

KTP needed 16 new full spot pages covering France (5), Italy (3), and Portugal (8) — the European core of the 198-spot global database. Each destination required `data.ts` + `page.tsx` following the Phase 3 condensed template standard: mini maps above description, `coordinatesPending: false`, `#13192a` background, HITL review panel in dev mode, and distinct KTP differentiation angles (not generic travel writing).

---

## Solution

Built all 16 destinations as full-stack spot pages using the condensed template established at Hyères. Each `data.ts` includes 13+ exported sections (kiteSpots, monthlyWindData, kiteSizeGuide, activities, signatureDishes, restaurants, logisticsBlocks, ktpDifferentiation, verifiedFacts, hitlGaps, unverifiedFlags). Each `page.tsx` renders the condensed layout with contextual callout banners specific to each destination's key risk or differentiator.

Committed in 4 batches (France 1, Italy+Camargue, Portugal 1–4, Portugal 5–8), then admin registry and PROGRESS.md updated.

---

## Architecture

**Pattern:** Static content pages — `app/spots/[slug]/data.ts` + `app/spots/[slug]/page.tsx`
**Template:** Condensed (Hyères/Gruissan standard — shorter than the la-ventana 624-line original)
**Map embed:** Google Maps Embed API via `GOOGLE_MAPS_EMBED_KEY` — mini map in each spot card, hero map at top
**Mini map placement rule:** title + badge → mini map → shortDescription → disciplines → hazards → access
**Coordinate standard:** `coordinatesPending: false` throughout (one exception: Orbetello Giannella beach)

---

## Components Built

| Destination | Key Differentiator | kiteSpots |
|---|---|---|
| La Torche | Brittany NW Atlantic; Penmarc'h reef | 7 |
| Hyères / Almanarre | Peninsula flat water + Porquerolles | 6 |
| Gruissan | Lords of Tram Tramontane thermal | 6 |
| Arcachon Bay | Dune du Pilat; tidal bay sessions | 6 |
| Camargue | White horses + flamingos; Gitan pilgrimage | 5 |
| Lago di Garda | Pelèr/Ora dual named winds in one day | 5 |
| Puglia / Taranto | Mar Piccolo — only double-basin inland sea kite venue in Europe | 5 |
| Orbetello | RAMSAR tombolo lagoon + WWF reserve + kite venue | 4 |
| Viana do Castelo | Lima estuary + Atlantic wave; 15–20°C cold upwelling | 4 |
| Comporta | Sado dolphin RNES reserve; Sept > Aug recommendation | 4 |
| Sagres | Strongest NW at SW continental tip; size-down warning | 4 |
| Peniche | Baleal mid-tide timing; WSL Rip Curl Pro; Portugal best-value | 4 |
| Lagoa de Óbidos | Sandbar mouth migration — local briefing non-optional | 4 |
| Guincho | Sintra mountain thermal; 280+ wind days; 30km from Lisbon | 3 |
| Ericeira | World's 2nd World Surfing Reserve; kite/surf zone enforced | 4 |
| Costa da Caparica | 25 min from Lisbon by ferry (€2); weekday sessions essential | 4 |

---

## Lessons

- **Recurring quote typo:** Closing `'` instead of `"` in monthlyWindData notes strings — scan for `'$` pattern before committing any data.ts batch
- **Mini map placement is a contract:** title+badge → mini map → description — must be in ktp-spot-page skill references, not just CLAUDE.md
- **`coordinatesPending: false` as default:** Enables live user review on the published site; use `true` only for genuinely unverifiable coordinates
- **Long batch context management:** Commit every 3–4 pages + write explicit carry-over prompt for continuation sessions

---

## What's Next

Agent team — skills-first approach. Deconstruct each agent's role first, identify the skills each needs, build those skills before activating any agent. Prevents building ContentAgent before the research/brand-voice/data-retrieval skills that feed it exist.

---

## Commits

| Hash | Description |
|---|---|
| `6aa02ad` | France Batch 1: La Torche, Hyères, Gruissan, Arcachon |
| `1dd2aac` | Batch 2: Camargue, Lago di Garda, Puglia/Taranto, Orbetello |
| `b45686b` | Batch 3 Portugal: Viana do Castelo, Comporta, Sagres, Peniche |
| `9bea6d7` | MVP commit (Ericeira, Guincho, Lagoa de Óbidos + Restaurant interface fixes) |
| `1e45250` | Batch 4 final: Costa da Caparica |
| `5dc0376` | Admin registry: 16 new spots added |
| `46e1888` | PROGRESS.md session log |

**Repo:** `https://github.com/bengio777/KTP_V01.git`
