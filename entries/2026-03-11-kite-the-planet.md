# Kite the Planet: Dakhla Spot Page v0.1 + Research Infrastructure
## Build Journal Entry — Standard

**Builder:** Ben Giordano
**Date:** 2026-03-11
**Repo:** bengio777/KTP_V01
**Status:** Complete — deployed to production
**Tier:** Standard

---

## 1. Problem Statement

Kite the Planet needed a v0.1 spot page prototype to validate the editorial design direction and content architecture before wiring a CMS. The goal: build a full-fidelity Dakhla spot page from hardcoded research data, deploy it to Vercel, and get a clickable preview that could be reviewed and iterated on today.

Secondary problem: establishing a repeatable research methodology — how do you get Claude to produce spot-quality research (cultural depth, verified logistics, HITL gaps flagged) across 100+ planned spots? The answer required discovering the right search volume threshold: 40–50 web searches per spot to reach sufficient diversity of information for synthesis into KTP's spot tapestry (culture, activities, kite data, wind/water/tides, season, logistics, where to stay).

---

## 2. Solution

Built `/spots/dakhla` as a Next.js 15 App Router static page with 12 fully populated sections, deployed to `kitetheplanet.com/spots/dakhla`. All data hardcoded from a 612-line research package (48 searches, 65+ sources) into a typed `data.ts` file, keeping the rendering layer clean and ready for Sanity/Supabase swap later.

Design direction: dark editorial (Outside Magazine / Surfer Magazine web aesthetic). Zinc-950 base, teal accent, sticky section nav, card grids, full-viewport hero.

---

## 3. Architecture

```
app/spots/dakhla/
├── data.ts       — all hardcoded spot data, fully typed
└── page.tsx      — server component, 12 sections, no client state
```

**Key pattern:** `data.ts` acts as a typed contract between the research layer and the rendering layer. When Sanity is wired, `data.ts` gets replaced by Sanity queries with no changes to `page.tsx`.

---

## 4. Lessons Learned

**The research volume threshold is 40–50 searches per spot.** Below that: kite-only coverage. At 40–50: full picture (culture, indigenous identity, food, logistics, HITL gaps, differentiation angles competitors miss).

**Two-destination framing unlocks the page.** Every spot with seasonal duality needs to be framed as two destinations. For Dakhla: lagoon camp world (Apr–Oct) vs. wave camp world (Oct–Mar). Competitors blur this. KTP's advantage is making the duality explicit.

**HITL gaps are an editorial workflow tool.** Surfacing what can't be confirmed by web research gives the founder a checklist for the first local verification trip — real product feature, not a placeholder.

**`data.ts` as CMS contract.** Every field in `data.ts` maps to a future Sanity schema field. The upgrade path is clear: replace imports with queries, keep rendering untouched.

---

## 5. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| 444d0cb | 2026-03-11 | docs: add 10 spot research packages and updated agent definitions |
| 68c7922 | 2026-03-11 | feat: add project scaffolding, dev tools, and API registration scripts |
| 55dc1ff | 2026-03-11 | feat(spots): build Dakhla spot page v0.1 prototype |
| 8b87342 | 2026-03-11 | chore: ignore .worktrees directory |
| 77160fe | 2026-03-11 | feat(plan): add locale and currency system implementation plan |
| d399f7f | 2026-03-11 | docs(spec): finalize locale/currency spec — reviewer approved |
| 6a48a88 | 2026-03-11 | feat(spec): add locale and currency system design |
