# Kite the Planet: Affiliate Registration & Site Launch
## Build Journal Entry — Standard

**Builder:** Benjamin Giordano
**Date:** 2026-03-08
**Repo:** kite-the-planet
**Status:** In Progress (v0.1 hello world live; full build continues)
**Tier:** Standard

---

## 1. Problem Statement

KTP needed to establish its affiliate revenue infrastructure and get a bare-bones site live at kitetheplanet.com before affiliate programs require a working URL. The session also needed to consolidate the project from two separate directories (KTP_V01 for docs, kite-the-planet for code) into a single canonical repo.

---

## 2. Solution

Completed affiliate registrations across four programs, deployed a Next.js hello world to Vercel, connected the GoDaddy domain via DNS, confirmed the site live at https://www.kitetheplanet.com, and migrated all project files into the `kite-the-planet` repo.

---

## 3. Architecture

- **Framework:** Next.js 15 (App Router, TypeScript, Tailwind CSS)
- **Hosting:** Vercel (project: `kite-the-planet` under `bengio777-3861s-projects`)
- **Domain:** kitetheplanet.com (GoDaddy) → Vercel via A + CNAME records
- **Repo structure:**
  ```
  kite-the-planet/
  ├── app/              # Next.js App Router
  ├── docs/
  │   ├── affiliate-setup/   # Registration docs for each program
  │   └── build-journal/     # This file
  ├── PRD-KiteThePlanet-v0.1.md
  └── kite-the-planet-spots.csv   # 198-spot global database
  ```

---

## 4. Component Specifications

### Affiliate Programs Registered

| Program | Network | Status | Commission | Cookie |
|---------|---------|--------|-----------|--------|
| Booking.com | Awin | 🔄 In Progress — financials pending | % of booking | 30 days |
| Expedia Group | creator.expediagroup.com | ✅ Registered — bank details pending | Up to 4% | 7 days |
| Hostelworld | Partnerize | 🔄 In Progress — verification email pending | CPA | 30 days |
| Skyscanner | Impact | ⏳ Blocked — needs live site + 1k followers | % of revenue | 30 days |

### DNS Configuration (GoDaddy → Vercel)

| Type | Name | Value |
|------|------|-------|
| A | `@` | `216.198.79.1` |
| CNAME | `www` | `9fc0d8abda215d31.vercel-dns-017.com.` |

### Hello World Page

Simple "Coming soon." page on `bg-sky-950` — minimal, on-brand, serves as placeholder and affiliate registration proof-of-life.

---

## 5. Lessons Learned

- **npm package names can't have capital letters** — `create-next-app` failed inside `KTP_V01/` because the directory name resolves to an invalid package name. Always scaffold Next.js apps in lowercase directories.
- **Playwright MCP browser sessions start fresh** — no existing login state. OAuth flows (Vercel via GitHub) require manual user authentication; automate form-filling only after auth is established.
- **Vercel uses new DNS IPs** — the documented A record (`76.76.21.21`) and CNAME (`cname.vercel-dns.com`) are legacy. Vercel now shows project-specific values (`216.198.79.1` and a unique CNAME per project). Always use what Vercel's UI shows.
- **GoDaddy default A record points to WebsiteBuilder** — new domains have a GoDaddy placeholder A record that must be replaced, not just added alongside.
- **Skyscanner Creator Programme requires 1,000+ followers** on a travel-focused channel. Register immediately after KTP Instagram clears that threshold.
- **Two affiliate programs per session is productive** — trying to do all four in one sitting caused diminishing returns on the later ones. Hostelworld's verification email still pending.

---

## 6. Build History

| Phase | What Happened |
|-------|---------------|
| Affiliate research | Reviewed PRD affiliate strategy; determined Awin (Booking.com), Expedia Group, Hostelworld, and Skyscanner as priority programs |
| Awin registration | Completed publisher signup: Editorial Content + Lead Gen (Content) + Newsletters + Linking via Landing Pages; Travel (8/11 sectors) + Retail (Sports Equipment, Sportswear, Photography); 246-char promo description |
| Expedia Creator | Registered with website + Instagram + YouTube; registration complete; bank details deferred |
| Skyscanner | Researched Creator Programme vs Standard Affiliate; blocked on follower count and live site requirement; parked with clear re-engagement criteria |
| Hostelworld | Registered via Partnerize; Vertical = Travel, Partner Type = Content; awaiting verification email |
| Next.js setup | Scaffolded in `kite-the-planet/` (lowercase); App Router, TypeScript, Tailwind; wrote minimal `page.tsx` |
| Vercel deployment | CLI deploy via `vercel` command; auto-linked to `bengio777-3861s-projects`; deployed to `kite-the-planet.vercel.app` |
| Domain connection | Added kitetheplanet.com + www to Vercel domains settings; updated GoDaddy DNS; SSL provisioned automatically |
| Site confirmed live | `https://www.kitetheplanet.com` serving "Kite the Planet / Coming soon." |
| Repo consolidation | Migrated docs, PRD, and spots CSV from KTP_V01 into kite-the-planet; KTP_V01 archived |

---

## 7. Commit Log

| Hash | Date | Description |
|------|------|-------------|
| 59df1e7 | 2026-03-08 | chore: migrate docs, PRD, and spots data from KTP_V01 |
| 4ef195a | 2026-03-08 | Initial commit from Create Next App |

---

## Pending Actions (Next Session)

- [ ] Awin: configure financials → apply to Booking.com advertiser program
- [ ] Expedia: add bank details at creator.expediagroup.com/app/settings/bank-details
- [ ] Hostelworld: complete Partnerize verification when email arrives
- [ ] Skyscanner: register when kitetheplanet.com live + KTP Instagram ≥ 1,000 followers
- [ ] Begin full KTP build in Cursor (Next.js + Supabase + Sanity CMS per PRD)
